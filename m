From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 3/3] bonding: Fix the RTNL assertion failed for 802.3ad state machine
Date: Mon, 17 Feb 2014 18:06:12 -0800
Message-ID: <5300.1392689172@death.nxdomain>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-4-git-send-email-dingtianhong@huawei.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, cwang@twopensource.com,
	jiri@resnulli.us, thomas@glanzmann.de, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38179 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaBRCGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 21:06:19 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 17 Feb 2014 19:06:19 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 47B461FF003F
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:06:16 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I25kHP6553970
	for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 03:05:46 +0100
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I26ELr011877
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:06:15 -0700
In-reply-to: <1392626151-23916-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The 802.3ad state machine don't run in RTNL, but when the slave's
>state changed, the rtmsg_ifinfo will be called, it will cause
>warning message because the RTML is not locked, acquiring RTNL
>for the __enable_port and __disable_port cases is difficult, as
>those calls generally already hold the state machine lock, and
>can't unconditionally call rtnl_lock because either they already
>hold RTNL (for calls via bond_3ad_unbind_slave) or due to the
>potential for deadlock with bond_3ad_adapter_speed_changed,
>bond_3ad_adapter_duplex_changed, bond_3ad_link_change, or
>bond_3ad_update_lacp_rate. All four of those are called with RTNL
>held, and acquire the state machine lock second, The calling contexts for
>__enable_port and __disable_port already hold the state machine lock,
>and may or may not need RTNL.
>
>So according to the Jay's opinion, the __enable_port and __disable_port
>should not call rtmsg_ifinfo in the state machine lock, any change in
>the state of slave could set a flag in the slave, it will indicated that
>an rtmsg_ifinfo should be called at the end of the state machine.

	To clarify, my opinion being referenced here was really asking
Scott Feldman <sfeldma@cumulusnetworks.com> if: (a) the calls had to be
synchronous, and, (b) if the intermediate calls to adjust flags within
the ARP monitor "cycle through slaves looking for a functional slave"
all required notifications.  My suspicion is that the answer to both of
those is "no," but I haven't heard from Scott.

>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_3ad.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index cce1f1b..e80b78f 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -181,7 +181,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
>  */
> static inline void __disable_port(struct port *port)
> {
>-	bond_set_slave_inactive_flags(port->slave);
>+	bond_set_slave_flags(port->slave, BOND_STATE_BACKUP, false);
> }
>
> /**
>@@ -193,7 +193,7 @@ static inline void __enable_port(struct port *port)
> 	struct slave *slave = port->slave;
>
> 	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev))
>-		bond_set_slave_active_flags(slave);
>+		bond_set_slave_flags(slave, BOND_STATE_ACTIVE, false);

	I don't agree that we need to have two separate systems (your
new bond_set_slave_flags plus bond_set_slave_{active,inactive}_flags)
that both tweak the "active" or "inactive" flags for a slave.  It would
be much cleaner and consistent with the current code to add a "notify"
boolean to the existing functions.

	-J

> }
>
> /**
>@@ -2123,6 +2123,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> re_arm:
> 	rcu_read_unlock();
> 	read_unlock(&bond->lock);
>+	bond_slave_state_notify(bond, false);
> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
> }
>
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
