From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 11/11] net: Add netif_is_l3_slave
Date: Fri, 18 Sep 2015 10:06:25 -0700
Message-ID: <1442595985-7049-12-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35496 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbbIRRGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:52 -0400
Received: by pacfv12 with SMTP id fv12so56838334pac.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:52 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplifies ops checking. An L3 master is expected to define l3mdev_ops
at a minimum.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         |  6 +++---
 include/linux/netdevice.h |  5 +++++
 net/l3mdev/l3mdev.c       | 13 ++++---------
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 8fe7b0adaeb2..bf48c8b448fc 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -39,8 +39,6 @@
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
-#define vrf_is_slave(dev)   ((dev)->flags & IFF_SLAVE)
-
 #define vrf_master_get_rcu(dev) \
 	((struct net_device *)rcu_dereference(dev->rx_handler_data))
 
@@ -433,6 +431,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_unregister;
 
 	port_dev->flags |= IFF_SLAVE;
+	port_dev->priv_flags |= IFF_L3MDEV;
 	__vrf_insert_slave(queue, slave);
 	cycle_netdev(port_dev);
 
@@ -447,7 +446,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (netif_is_l3_master(port_dev) || vrf_is_slave(port_dev))
+	if (netif_is_l3_master(port_dev) || netif_is_l3_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev);
@@ -462,6 +461,7 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 
 	netdev_upper_dev_unlink(port_dev, dev);
 	port_dev->flags &= ~IFF_SLAVE;
+	port_dev->priv_flags &= ~IFF_L3MDEV;
 
 	netdev_rx_handler_unregister(port_dev);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index daffe38b49fc..ae95d922a569 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3829,6 +3829,11 @@ static inline bool netif_is_l3_master(const struct net_device *dev)
 	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_L3MDEV;
 }
 
+static inline bool netif_is_l3_slave(const struct net_device *dev)
+{
+	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_L3MDEV;
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
1.9.1
