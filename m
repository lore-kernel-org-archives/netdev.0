From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 5/10] bonding: create bond_first_slave_rcu()
Date: Mon, 11 Nov 2013 20:36:41 +0800
Message-ID: <5280CF59.5090202@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:33960 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab3KKMk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:40:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_first_slave_rcu() will be used to instead of bond_first_slave()
in rcu_read_lock().

So move the struct netdev_adjacent to the netdevice.h and make the
bond_first_slave_rcu() could use the struct.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h |  9 +++++++++
 include/linux/netdevice.h     | 16 ++++++++++++++++
 net/core/dev.c                | 16 ----------------
 3 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 77a07a1..5d37606 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -91,6 +91,15 @@
 		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
 		NULL)
 
+/* Caller must have rcu_read_lock */
+#define bond_first_slave_rcu(bond) \
+	({struct list_head *__ptr = (bond_slave_list(bond)); \
+	 struct list_head *__next = ACCESS_ONCE(__ptr->next); \
+	 likely(__ptr != __next) ? \
+	 list_entry_rcu(__next, struct netdev_adjacent, list)->private : \
+		NULL; \
+	 })
+
 #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
 #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15fa01c..7ca0fc8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2839,6 +2839,22 @@ extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
 
+struct netdev_adjacent {
+	struct net_device *dev;
+
+	/* upper master flag, there can only be one master device per list */
+	bool master;
+
+	/* counter for the number of times this device was added to us */
+	u16 ref_nr;
+
+	/* private field for the users */
+	void *private;
+
+	struct list_head list;
+	struct rcu_head rcu;
+};
+
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 bool netdev_has_any_upper_dev(struct net_device *dev);
 struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ffc52e..bcc5001 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4377,22 +4377,6 @@ softnet_break:
 	goto out;
 }
 
-struct netdev_adjacent {
-	struct net_device *dev;
-
-	/* upper master flag, there can only be one master device per list */
-	bool master;
-
-	/* counter for the number of times this device was added to us */
-	u16 ref_nr;
-
-	/* private field for the users */
-	void *private;
-
-	struct list_head list;
-	struct rcu_head rcu;
-};
-
 static struct netdev_adjacent *__netdev_find_adj_rcu(struct net_device *dev,
 						     struct net_device *adj_dev,
 						     struct list_head *adj_list)
-- 
1.8.2.1
