From: Eli Cohen <eli@mellanox.co.il>
Subject: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 26 May 2010 11:17:02 +0300
Message-ID: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rdreier@cisco.com, yevgenyp@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:54136 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751618Ab0EZIQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 04:16:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, there are no means to know which port of a hardware device a netdev
interface uses. This patch adds a new field to struct net_device that is used
to store this value. The network driver should use the SET_NETDEV_PORT_NUM()
macro to set the port number for the device it manages. For drivers that do not
set a value, a default value of 1 is set at alloc_netdev_mq().
This patch also makes use of this feature in the mlx4_en driver.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    1 +
 include/linux/netdevice.h    |    6 ++++++
 net/core/dev.c               |    1 +
 net/core/net-sysfs.c         |    2 ++
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 6c2b15b..d3df609 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -978,6 +978,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
+	SET_NETDEV_PORT_NUM(dev, port);
 
 	/*
 	 * Initialize driver private data
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3857517..2a52a6a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -843,6 +843,7 @@ struct net_device {
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
+	unsigned short          port_num;	/* for multiport devices */
 
 	struct netdev_hw_addr_list	uc;	/* Secondary unicast
 						   mac addresses */
@@ -1080,6 +1081,11 @@ static inline void *netdev_priv(const struct net_device *dev)
  */
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
+/*
+ * Set the port number of the physical device that this port net device uses
+ */
+#define SET_NETDEV_PORT_NUM(net, portnum)	((net)->port_num = (portnum))
+
 /**
  *	netif_napi_add - initialize a napi context
  *	@dev:  network device
diff --git a/net/core/dev.c b/net/core/dev.c
index 264137f..8e2f5df 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5471,6 +5471,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->_tx = tx;
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
+	dev->port_num = 1;
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 59cfc7d..c3d9b39 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -97,6 +97,7 @@ NETDEVICE_SHOW(ifindex, fmt_dec);
 NETDEVICE_SHOW(features, fmt_long_hex);
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
+NETDEVICE_SHOW(port_num, fmt_dec);
 
 /* use same locking rules as GIFHWADDR ioctl's */
 static ssize_t show_address(struct device *dev, struct device_attribute *attr,
@@ -299,6 +300,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(features, S_IRUGO, show_features, NULL),
 	__ATTR(type, S_IRUGO, show_type, NULL),
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
+	__ATTR(port_num, S_IRUGO, show_port_num, NULL),
 	__ATTR(address, S_IRUGO, show_address, NULL),
 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
 	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
-- 
1.7.1

