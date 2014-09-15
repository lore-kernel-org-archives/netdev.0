From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/3] bonding: consolidate the two rlb_next_rx_slave functions into one
Date: Mon, 15 Sep 2014 17:19:33 +0200
Message-ID: <1410794375-7386-2-git-send-email-nikolay@redhat.com>
References: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752959AbaIOPUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 11:20:04 -0400
In-Reply-To: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__rlb_next_rx_slave() is a copy of rlb_next_rx_slave() with the
difference that it uses rcu primitives to walk the slave list. We don't
need the two functions and can make rlb_next_rx_slave() a wrapper for
callers which hold RTNL.
So add a comment and ASSERT_RTNL() to make sure what is intended.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 38 ++++++++++----------------------------
 1 file changed, 10 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 85af961f1317..4efdeb67ab7c 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -334,14 +334,15 @@ out:
 	return RX_HANDLER_ANOTHER;
 }
 
-static struct slave *rlb_next_rx_slave(struct bonding *bond)
+/* Caller must hold rcu_read_lock() */
+static struct slave *__rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *before = NULL, *rx_slave = NULL, *slave;
 	struct list_head *iter;
 	bool found = false;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (!bond_slave_can_tx(slave))
 			continue;
 		if (!found) {
@@ -366,35 +367,16 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 	return rx_slave;
 }
 
-/* Caller must hold rcu_read_lock() */
-static struct slave *__rlb_next_rx_slave(struct bonding *bond)
+/* Caller must hold RTNL, rcu_read_lock is obtained only to silence checkers */
+static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *before = NULL, *rx_slave = NULL, *slave;
-	struct list_head *iter;
-	bool found = false;
+	struct slave *rx_slave;
 
-	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (!bond_slave_can_tx(slave))
-			continue;
-		if (!found) {
-			if (!before || before->speed < slave->speed)
-				before = slave;
-		} else {
-			if (!rx_slave || rx_slave->speed < slave->speed)
-				rx_slave = slave;
-		}
-		if (slave == bond_info->rx_slave)
-			found = true;
-	}
-	/* we didn't find anything after the current or we have something
-	 * better before and up to the current slave
-	 */
-	if (!rx_slave || (before && rx_slave->speed < before->speed))
-		rx_slave = before;
+	ASSERT_RTNL();
 
-	if (rx_slave)
-		bond_info->rx_slave = rx_slave;
+	rcu_read_lock();
+	rx_slave = __rlb_next_rx_slave(bond);
+	rcu_read_unlock();
 
 	return rx_slave;
 }
-- 
1.9.3
