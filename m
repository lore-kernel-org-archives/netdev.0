From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v3] bonding: fix system hang due to fast igmp timer rescheduling
Date: Thu,  1 Aug 2013 11:51:42 +0200
Message-ID: <1375350702-7777-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167Ab3HAJzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 05:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nikolay Aleksandrov" <nikolay@redhat.com>

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
Also adjust the timer in bond_change_active_slave to be 1 jiffy, since
most of the time it's called with rtnl already held.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v3: learn to spell my name :-)
v2: adjust bond_change_active_slave's mcast_work delay to 1 jiffy because
it's called with rtnl held most of the time as Jay suggested

 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index da3af63..bc3578e 100644
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
@@ -1084,7 +1084,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	    ((USES_PRIMARY(bond->params.mode) && new_active) ||
 	     bond->params.mode == BOND_MODE_ROUNDROBIN)) {
 		bond->igmp_retrans = bond->params.resend_igmp;
-		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
+		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
 	}
 }
 
-- 
1.8.1.4
