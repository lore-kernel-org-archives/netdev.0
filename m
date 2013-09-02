From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 11/21] bonding: remove bond_for_each_slave_reverse()
Date: Mon,  2 Sep 2013 23:39:15 +0200
Message-ID: <1378157965-17537-12-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759150Ab3IBVj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:26 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only use it in rollback scenarios and can easily use the standart
bond_for_each_dev() instead.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c  | 14 ++++++++------
 drivers/net/bonding/bond_main.c | 34 ++++++++++++++++++++++------------
 drivers/net/bonding/bonding.h   | 10 ----------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a277465..bda976f 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1248,9 +1248,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
  */
 static int alb_set_mac_address(struct bonding *bond, void *addr)
 {
-	char tmp_addr[ETH_ALEN];
-	struct slave *slave;
+	struct slave *slave, *rollback_slave;
 	struct sockaddr sa;
+	char tmp_addr[ETH_ALEN];
 	int res;
 
 	if (bond->alb_info.rlb_enabled)
@@ -1276,10 +1276,12 @@ unwind:
 	sa.sa_family = bond->dev->type;
 
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave_continue_reverse(bond, slave) {
-		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
-		dev_set_mac_address(slave->dev, &sa);
-		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
+	bond_for_each_slave(bond, rollback_slave) {
+		if (rollback_slave == slave)
+			break;
+		memcpy(tmp_addr, rollback_slave->dev->dev_addr, ETH_ALEN);
+		dev_set_mac_address(rollback_slave->dev, &sa);
+		memcpy(rollback_slave->dev->dev_addr, tmp_addr, ETH_ALEN);
 	}
 
 	return res;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 427d943..0a4aa0d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -332,7 +332,7 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 				__be16 proto, u16 vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
+	struct slave *slave, *rollback_slave;
 	int res;
 
 	bond_for_each_slave(bond, slave) {
@@ -344,9 +344,13 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 	return 0;
 
 unwind:
-	/* unwind from the slave that failed */
-	bond_for_each_slave_continue_reverse(bond, slave)
-		vlan_vid_del(slave->dev, proto, vid);
+	/* unwind to the slave that failed */
+	bond_for_each_slave(bond, rollback_slave) {
+		if (rollback_slave == slave)
+			break;
+
+		vlan_vid_del(rollback_slave->dev, proto, vid);
+	}
 
 	return res;
 }
@@ -3477,7 +3481,7 @@ static int bond_neigh_setup(struct net_device *dev,
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
+	struct slave *slave, *rollback_slave;
 	int res = 0;
 
 	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
@@ -3526,13 +3530,16 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
 unwind:
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave_continue_reverse(bond, slave) {
+	bond_for_each_slave(bond, rollback_slave) {
 		int tmp_res;
 
-		tmp_res = dev_set_mtu(slave->dev, bond_dev->mtu);
+		if (rollback_slave == slave);
+			break;
+
+		tmp_res = dev_set_mtu(rollback_slave->dev, bond_dev->mtu);
 		if (tmp_res) {
 			pr_debug("unwind err %d dev %s\n",
-				 tmp_res, slave->dev->name);
+				 tmp_res, rollback_slave->dev->name);
 		}
 	}
 
@@ -3549,8 +3556,8 @@ unwind:
 static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave, *rollback_slave;
 	struct sockaddr *sa = addr, tmp_sa;
-	struct slave *slave;
 	int res = 0;
 
 	if (bond->params.mode == BOND_MODE_ALB)
@@ -3616,13 +3623,16 @@ unwind:
 	tmp_sa.sa_family = bond_dev->type;
 
 	/* unwind from head to the slave that failed */
-	bond_for_each_slave_continue_reverse(bond, slave) {
+	bond_for_each_slave(bond, rollback_slave) {
 		int tmp_res;
 
-		tmp_res = dev_set_mac_address(slave->dev, &tmp_sa);
+		if (rollback_slave == slave)
+			break;
+
+		tmp_res = dev_set_mac_address(rollback_slave->dev, &tmp_sa);
 		if (tmp_res) {
 			pr_debug("unwind err %d dev %s\n",
-				 tmp_res, slave->dev->name);
+				 tmp_res, rollback_slave->dev->name);
 		}
 	}
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 7cb60f9..8c11f96 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -122,16 +122,6 @@
 #define bond_for_each_slave_rcu(bond, pos) \
 	list_for_each_entry_rcu(pos, &(bond)->slave_list, list)
 
-/**
- * bond_for_each_slave_reverse - iterate in reverse from a given position
- * @bond:	the bond holding this list
- * @pos:	slave to continue from
- *
- * Caller must hold bond->lock
- */
-#define bond_for_each_slave_continue_reverse(bond, pos) \
-	list_for_each_entry_continue_reverse(pos, &(bond)->slave_list, list)
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern atomic_t netpoll_block_tx;
 
-- 
1.8.4
