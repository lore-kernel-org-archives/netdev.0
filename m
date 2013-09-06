From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Fri, 6 Sep 2013 15:28:07 +0800
Message-ID: <52298407.9040103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:24577 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IFH22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 03:28:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
(bonding: initial RCU conversion) has convert the roundrobin, active-backup,
broadcast and xor xmit path to rcu protection, the performance will be better
for these mode, so this time, convert xmit path for 3ad mode.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 32 ++++++++++++++------------------
 drivers/net/bonding/bonding.h  | 33 ++++++++++++++++++++++++++++++++-
 2 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 0d8f427..13f1deb 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -143,7 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
  */
 static inline struct port *__get_first_port(struct bonding *bond)
 {
-	struct slave *first_slave = bond_first_slave(bond);
+	struct slave *first_slave = bond_first_slave_rcu(bond);
 
 	return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
 }
@@ -163,7 +163,7 @@ static inline struct port *__get_next_port(struct port *port)
 	// If there's no bond for this port, or this is the last slave
 	if (bond == NULL)
 		return NULL;
-	slave_next = bond_next_slave(bond, slave);
+	slave_next = bond_next_slave_rcu(bond, slave);
 	if (!slave_next || bond_is_first_slave(bond, slave_next))
 		return NULL;
 
@@ -2417,16 +2417,14 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
-	struct slave *slave, *start_at;
 	struct bonding *bond = netdev_priv(dev);
+	struct slave *slave;
 	int slave_agg_no;
 	int slaves_in_agg;
 	int agg_id;
-	int i;
 	struct ad_info ad_info;
 	int res = 1;
 
-	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2444,13 +2442,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
 
-	bond_for_each_slave(bond, slave) {
+	bond_for_each_slave_rcu(bond, slave) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
 		if (agg && (agg->aggregator_identifier == agg_id)) {
-			slave_agg_no--;
-			if (slave_agg_no < 0)
-				break;
+			if (--slave_agg_no < 0) {
+				if (SLAVE_IS_OK(slave)) {
+					res = bond_dev_queue_xmit(bond,
+						skb, slave->dev);
+					goto out;
+				}
+			}
 		}
 	}
 
@@ -2460,23 +2462,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	start_at = slave;
-
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		int slave_agg_id = 0;
+	bond_for_each_slave_rcu(bond, slave) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
-		if (agg)
-			slave_agg_id = agg->aggregator_identifier;
-
-		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
+		if (SLAVE_IS_OK(slave) && agg &&
+			agg->aggregator_identifier == agg_id) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
 	}
 
 out:
-	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f7ab161..419161d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -74,13 +74,35 @@
 /* slave list primitives */
 #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
 
+/* slave list primitives, Caller must hold rcu_read_lock */
+#define bond_to_slave_rcu(ptr) list_entry_rcu(ptr, struct slave, list)
+
+/* bond_is_empty return NULL if slave list is empty*/
+#define bond_is_empty(bond) \
+	(list_empty(&(bond)->slave_list))
+
+/* bond_is_empty_rcu return NULL if slave list is empty*/
+#define bond_is_empty_rcu(bond) \
+	(!list_first_or_null_rcu(&(bond)->slave_list, struct slave, list))
+
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
 #define bond_first_slave(bond) \
 	list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
 #define bond_last_slave(bond) \
-	(list_empty(&(bond)->slave_list) ? NULL : \
+	(bond_is_empty(bond) ? NULL : \
 					   bond_to_slave((bond)->slave_list.prev))
 
+/**
+ * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an empty list
+ * Caller must hold rcu_read_lock
+ */
+#define bond_first_slave_rcu(bond) \
+	(bond_is_empty_rcu(bond) ? NULL : \
+					bond_to_slave_rcu((bond)->slave_list.next))
+#define bond_last_slave_rcu(bond) \
+	(bond_is_empty_rcu(bond) ? NULL : \
+					bond_to_slave_rcu((bond)->slave_list.prev))
+
 #define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
 #define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
 
@@ -93,6 +115,15 @@
 	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
 					  bond_to_slave((pos)->list.prev))
 
+/* Since bond_first/last_slave_rcu can return NULL, these can return NULL too */
+#define bond_next_slave_rcu(bond, pos) \
+	(bond_is_last_slave(bond, pos) ? bond_first_slave_rcu(bond) : \
+					 bond_to_slave_rcu((pos)->list.next))
+
+#define bond_prev_slave_rcu(bond, pos) \
+	(bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
+					  bond_to_slave_rcu((pos)->list.prev))
+
 /**
  * bond_for_each_slave_from - iterate the slaves list from a starting point
  * @bond:	the bond holding this list.
-- 
1.8.2.1
