From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 5/11] bonding: create bond_first_slave_rcu()
Date: Wed, 11 Dec 2013 13:00:48 +0800
Message-ID: <52A7F180.4070500@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:8151 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab3LKFBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 00:01:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_first_slave_rcu() will be used to instead of bond_first_slave()
in rcu_read_lock().

According to the Jay Vosburgh's suggestion, the struct netdev_adjacent
should hide from users who wanted to use it directly. so I package a
new function to get the first slave of the bond.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bonding.h |  4 ++++
 include/linux/netdevice.h     |  1 +
 net/core/dev.c                | 21 +++++++++++++++++++++
 3 files changed, 26 insertions(+)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 77a07a1..9337f8a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -91,6 +91,10 @@
 		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
 		NULL)
 
+/* Caller must have rcu_read_lock */
+#define bond_first_slave_rcu(bond) \
+	netdev_lower_get_first_private_rcu(bond->dev)
+
 #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
 #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15fa01c..abfcfad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2869,6 +2869,7 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
 
 void *netdev_adjacent_get_private(struct list_head *adj_list);
+void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ffc52e..51feddb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4570,6 +4570,27 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 EXPORT_SYMBOL(netdev_lower_get_next_private_rcu);
 
 /**
+ * netdev_lower_get_first_private_rcu - Get the first ->private from the
+ *				       lower neighbour list, RCU
+ *				       variant
+ * @dev: device
+ *
+ * Gets the first netdev_adjacent->private from the dev's lower neighbour
+ * list. The caller must hold RCU read lock.
+ */
+void *netdev_lower_get_first_private_rcu(struct net_device *dev)
+{
+	struct netdev_adjacent *lower;
+
+	lower = list_first_or_null_rcu(&dev->adj_list.lower,
+			struct netdev_adjacent, list);
+	if (lower)
+		return lower->private;
+	return NULL;
+}
+EXPORT_SYMBOL(netdev_lower_get_first_private_rcu);
+
+/**
  * netdev_master_upper_dev_get_rcu - Get master upper device
  * @dev: device
  *
-- 
1.8.2.1
