From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: fix system hang due to fast igmp timer rescheduling
Date: Tue, 30 Jul 2013 19:37:32 +0200
Message-ID: <1375205852-31325-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725Ab3G3RlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 13:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event")
we try to acquire rtnl in bond_resend_igmp_join_requests but it can be
scheduled with rtnl already held (e.g. when bond_change_active_slave is
called with rtnl) causing a loop of immediate reschedules + calls because
rtnl_trylock fails each time since it's being already held.
For me this issue leads to system hangs very easy:
modprobe bonding; ifconfig bond0 up; ifenslave bond0 eth0; rmmod
bonding;

The fix is to introduce a small (1 jiffy) delay which is enough for the
sections holding rtnl to finish without putting any strain on the system.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index da3af63..9d94313 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -723,7 +723,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 static void bond_resend_igmp_join_requests(struct bonding *bond)
 {
 	if (!rtnl_trylock()) {
-		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
+		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
 		return;
 	}
 	call_netdevice_notifiers(NETDEV_RESEND_IGMP, bond->dev);
-- 
1.8.1.4
