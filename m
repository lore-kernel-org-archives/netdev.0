From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: fix system hang due to fast igmp timer rescheduling
Date: Tue, 30 Jul 2013 11:40:40 -0700
Message-ID: <7289.1375209640@death.nxdomain>
References: <1375205852-31325-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:38006 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757146Ab3G3Spt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 14:45:49 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 30 Jul 2013 12:45:45 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BB6AD1FF001F
	for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 12:35:22 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UIeieU121620
	for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 12:40:44 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UIeg9q000934
	for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 12:40:44 -0600
In-reply-to: <1375205852-31325-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>
>After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event")
>we try to acquire rtnl in bond_resend_igmp_join_requests but it can be
>scheduled with rtnl already held (e.g. when bond_change_active_slave is
>called with rtnl) causing a loop of immediate reschedules + calls because
>rtnl_trylock fails each time since it's being already held.
>For me this issue leads to system hangs very easy:
>modprobe bonding; ifconfig bond0 up; ifenslave bond0 eth0; rmmod
>bonding;

	I believe that bond_change_active_slave is always called with
rtnl held, and it is the only caller of bond_resend_igmp_join_requests
(well, "caller" in the sense that it queues the delayed work for
mcast_work that runs the function, currently with delay of 0).

>The fix is to introduce a small (1 jiffy) delay which is enough for the
>sections holding rtnl to finish without putting any strain on the system.

	Should the delay also be in the bond_change_active_slave queue
work call as well, to eliminate one loop of the "rtnl_trylock failing ->
queue_delayed_work" sequence in bond_resend_igmp_join_requests?

	-J

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_main.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index da3af63..9d94313 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -723,7 +723,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
> static void bond_resend_igmp_join_requests(struct bonding *bond)
> {
> 	if (!rtnl_trylock()) {
>-		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
>+		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
> 		return;
> 	}
> 	call_netdevice_notifiers(NETDEV_RESEND_IGMP, bond->dev);
>-- 
>1.8.1.4

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
