From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 08/27] bonding: remove bond_for_each_slave_continue_reverse()
Date: Tue, 17 Sep 2013 02:46:33 +0200
Message-ID: <1379378812-18346-9-git-send-email-vfalico@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab3IQArE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:47:04 -0400
In-Reply-To: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only use it in rollback scenarios and can easily use the standart
bond_for_each_dev() instead.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2  -> v3:
    Add the forgotten _continue to the subject.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Move the patch right before we change bond_for_each_slave() conversion,
    so that we don't have to convert bond_for_each_slave_reverse() too.

 drivers/net/bonding/bond_alb.c  | 14 ++++++++------
 drivers/net/bonding/bond_main.c | 34 ++++++++++++++++++++++------------
 drivers/net/bonding/bonding.h   | 10 ----------
 3 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c3dcc6b..46f6b40 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1246,9 +1246,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
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
@@ -1274,10 +1274,12 @@ unwind:
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
index f862dc8..3956478 100644
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
@@ -3468,7 +3472,7 @@ static int bond_neigh_setup(struct net_device *dev,
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
+	struct slave *slave, *rollback_slave;
 	int res = 0;
 
 	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
@@ -3517,13 +3521,16 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
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
 
@@ -3540,8 +3547,8 @@ unwind:
 static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave, *rollback_slave;
 	struct sockaddr *sa = addr, tmp_sa;
-	struct slave *slave;
 	int res = 0;
 
 	if (bond->params.mode == BOND_MODE_ALB)
@@ -3607,13 +3614,16 @@ unwind:
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
index 6d1a893..141ddc3 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -120,16 +120,6 @@
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
