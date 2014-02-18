From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 2/3] bonding: add new slave param and bond_slave_state_notify()
Date: Mon, 17 Feb 2014 18:07:06 -0800
Message-ID: <5310.1392689226@death.nxdomain>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-3-git-send-email-dingtianhong@huawei.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, cwang@twopensource.com,
	jiri@resnulli.us, thomas@glanzmann.de, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56222 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaBRCHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 21:07:13 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 17 Feb 2014 19:07:12 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 882881FF004B
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:07:10 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I26fI110289592
	for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 03:06:41 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I278q7008830
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 19:07:10 -0700
In-reply-to: <1392626151-23916-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>Add a new slave parameter which called should_notify, if the slave's state
>changed and don't notify yet, the parameter will be set to 1, and then if
>the slave's state changed again, the param will be set to 0, it indicate that
>the slave's state has been restored, no need to notify any one.
>
>The bond_slave_state_notify() will check whether the status changed and then
>decide to notify or not.
>
>Cc: Jay Vosburgh <fubar@us.ibm.com>
>Cc: Veaceslav Falico <vfalico@redhat.com>
>Cc: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bonding.h | 44 +++++++++++++++++++++++++++++++++++++++++--
> 1 file changed, 42 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index d210124..4d0cd41 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -195,7 +195,8 @@ struct slave {
> 	s8     new_link;
> 	u8     backup:1,   /* indicates backup slave. Value corresponds with
> 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
>-	       inactive:1; /* indicates inactive slave */
>+	       inactive:1, /* indicates inactive slave */
>+	       should_notify:1; /* indicateds whether the state changed */
> 	u8     duplex;
> 	u32    original_mtu;
> 	u32    link_failure_count;
>@@ -311,8 +312,47 @@ static inline void bond_set_slave_state(struct slave *slave,
> 	else
> 		return;
>
>-	if (notify)
>+	if (notify) {
> 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
>+		slave->should_notify = 0;
>+	} else {
>+		if (slave->should_notify)
>+			slave->should_notify = 0;
>+		else
>+			slave->should_notify = 1;
>+	}
>+}
>+
>+static inline void bond_slave_state_notify(struct bonding *bond,
>+					   bool rtnl_locked)
>+{
>+	struct list_head *iter;
>+	struct slave *tmp;
>+
>+	rcu_read_lock();
>+	bond_for_each_slave_rcu(bond, tmp, iter) {
>+		if (tmp->should_notify) {
>+			rcu_read_unlock();
>+			goto should_notify;
>+		}
>+	}
>+	rcu_read_unlock();
>+	return;
>+
>+should_notify:
>+
>+	if (!rtnl_locked && !rtnl_trylock())
>+		return;
>+
>+	bond_for_each_slave(bond, tmp, iter) {
>+		if (tmp->should_notify) {
>+			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_KERNEL);
>+			tmp->should_notify = 0;
>+		}
>+	}
>+
>+	if (!rtnl_locked)
>+		rtnl_unlock();
> }

	This function (bond_slave_state_notify) seems overly complicated
given that there appears to be only one caller.  In particular, why
bother with the "rtnl_locked" flag at all, when it is never called with
it set to true?  Really, with only one caller (in patch 3 of the
series), I'm not convinced this even needs to be a separate function.

	-J

>
> static inline void bond_slave_state_change(struct bonding *bond)
>-- 
>1.8.0

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
