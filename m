From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 4/4] bonding: add proper __rcu annotation for current_arp_slave
Date: Tue, 15 Jul 2014 06:56:56 -0700
Message-ID: <1405432616-12414-5-git-send-email-edumazet@google.com>
References: <1405432616-12414-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:65272 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbaGON5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 09:57:03 -0400
Received: by mail-vc0-f201.google.com with SMTP id hu12so327668vcb.4
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 06:57:02 -0700 (PDT)
In-Reply-To: <1405432616-12414-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using __rcu annotation actually helps to spot all accesses to
bond->current_arp_slave are correctly protected, with LOCKDEP support.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_main.c | 15 +++++++++------
 drivers/net/bonding/bonding.h   |  2 +-
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6a331bbcf43a..24d4c07bd434 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1711,7 +1711,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	oldcurrent = rcu_access_pointer(bond->curr_active_slave);
 
-	bond->current_arp_slave = NULL;
+	RCU_INIT_POINTER(bond->current_arp_slave, NULL);
 
 	if (!all && (!bond->params.fail_over_mac ||
 		     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
@@ -2569,7 +2569,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 		 * before being taken out
 		 */
 		if (!bond_is_active_slave(slave) &&
-		    !bond->current_arp_slave &&
+		    !rcu_access_pointer(bond->current_arp_slave) &&
 		    !bond_time_in_interval(bond, last_rx, 3)) {
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
@@ -2615,12 +2615,15 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			if (rtnl_dereference(bond->curr_active_slave) != slave ||
 			    (!rtnl_dereference(bond->curr_active_slave) &&
 			     bond_time_in_interval(bond, trans_start, 1))) {
+				struct slave *current_arp_slave;
+
+				current_arp_slave = rtnl_dereference(bond->current_arp_slave);
 				slave->link = BOND_LINK_UP;
-				if (bond->current_arp_slave) {
+				if (current_arp_slave) {
 					bond_set_slave_inactive_flags(
-						bond->current_arp_slave,
+						current_arp_slave,
 						BOND_SLAVE_NOTIFY_NOW);
-					bond->current_arp_slave = NULL;
+					RCU_INIT_POINTER(bond->current_arp_slave, NULL);
 				}
 
 				pr_info("%s: link status definitely up for interface %s\n",
@@ -2646,7 +2649,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				bond->dev->name, slave->dev->name);
 
 			if (slave == rtnl_dereference(bond->curr_active_slave)) {
-				bond->current_arp_slave = NULL;
+				RCU_INIT_POINTER(bond->current_arp_slave, NULL);
 				goto do_failover;
 			}
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index d03d2ae4d3af..b2e548e9d738 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,7 +195,7 @@ struct slave {
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
 	struct   slave __rcu *curr_active_slave;
-	struct   slave *current_arp_slave;
+	struct   slave __rcu *current_arp_slave;
 	struct   slave *primary_slave;
 	bool     force_primary;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
-- 
2.0.0.526.g5318336
