From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 11/11] net: Add netif_is_l3_slave
Date: Thu, 24 Sep 2015 18:21:07 -0600
Message-ID: <1443140467-69297-12-git-send-email-dsa@cumulusnetworks.com>
References: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33854 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbbIYAVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:21:42 -0400
Received: by padhy16 with SMTP id hy16so87546616pad.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:21:31 -0700 (PDT)
In-Reply-To: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because IPv6 addrconf keys off of IFF_SLAVE can not use it for
slave detection. Add a new private flag and add netif_is_l3_slave
function for checking it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         |  8 +++-----
 include/linux/netdevice.h |  7 +++++++
 net/l3mdev/l3mdev.c       | 13 ++++---------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index f0a1008d482a..d3919bb261cc 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -39,8 +39,6 @@
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
-#define vrf_is_slave(dev)   ((dev)->flags & IFF_SLAVE)
-
 #define vrf_master_get_rcu(dev) \
 	((struct net_device *)rcu_dereference(dev->rx_handler_data))
 
@@ -432,7 +430,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 	if (ret < 0)
 		goto out_unregister;
 
-	port_dev->flags |= IFF_SLAVE;
+	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	__vrf_insert_slave(queue, slave);
 	cycle_netdev(port_dev);
 
@@ -447,7 +445,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (netif_is_l3_master(port_dev) || vrf_is_slave(port_dev))
+	if (netif_is_l3_master(port_dev) || netif_is_l3_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev);
@@ -461,7 +459,7 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 	struct slave *slave;
 
 	netdev_upper_dev_unlink(port_dev, dev);
-	port_dev->flags &= ~IFF_SLAVE;
+	port_dev->priv_flags &= ~IFF_L3MDEV_SLAVE;
 
 	netdev_rx_handler_unregister(port_dev);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7d3cb9f39ce..0ba36d45de5a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1260,6 +1260,7 @@ struct net_device_ops {
  * @IFF_L3MDEV_MASTER: device is an L3 master device
  * @IFF_NO_QUEUE: device can run without qdisc attached
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
+ * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1285,6 +1286,7 @@ enum netdev_priv_flags {
 	IFF_L3MDEV_MASTER		= 1<<20,
 	IFF_NO_QUEUE			= 1<<21,
 	IFF_OPENVSWITCH			= 1<<22,
+	IFF_L3MDEV_SLAVE		= 1<<23,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -3829,6 +3831,11 @@ static inline bool netif_is_l3_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_L3MDEV_MASTER;
 }
 
+static inline bool netif_is_l3_slave(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_L3MDEV_SLAVE;
+}
+
 static inline bool netif_is_bridge_master(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_EBRIDGE;
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 52e6ece48c3d..2d440ba72439 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -16,12 +16,11 @@ int l3mdev_master_ifindex_rcu(struct net_device *dev)
 	if (netif_is_l3_master(dev)) {
 		ifindex = dev->ifindex;
 
-	} else if (dev->flags & IFF_SLAVE) {
+	} else if (netif_is_l3_slave(dev)) {
 		struct net_device *master;
 
 		master = netdev_master_upper_dev_get_rcu(dev);
-		if (netif_is_l3_master(master))
-			ifindex = master->ifindex;
+		ifindex = master->ifindex;
 	}
 
 	return ifindex;
@@ -44,7 +43,7 @@ u32 l3mdev_fib_table_rcu(const struct net_device *dev)
 		if (dev->l3mdev_ops->l3mdev_fib_table)
 			tb_id = dev->l3mdev_ops->l3mdev_fib_table(dev);
 
-	} else if (dev->flags & IFF_SLAVE) {
+	} else if (netif_is_l3_slave(dev)) {
 		/* TO-DO: remove the need for typecast.
 		 * Users of netdev_master_upper_dev_get_rcu need non-const,
 		 * but current inet_*type functions take a const
@@ -53,11 +52,7 @@ u32 l3mdev_fib_table_rcu(const struct net_device *dev)
 		const struct net_device *master;
 
 		master = netdev_master_upper_dev_get_rcu(_dev);
-		if (!master)
-			return 0;
-
-		if (netif_is_l3_master(master) &&
-		    master->l3mdev_ops->l3mdev_fib_table)
+		if (master->l3mdev_ops->l3mdev_fib_table)
 			tb_id = master->l3mdev_ops->l3mdev_fib_table(master);
 	}
 
-- 
2.3.8 (Apple Git-58)
