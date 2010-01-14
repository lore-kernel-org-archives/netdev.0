From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 1/3] venet-macvlan: allow rt netlink to create venet macvlan
	devices
Date: Thu, 14 Jan 2010 16:53:02 -0500
Message-ID: <20100114215302.4958.36917.stgit@mimic.site>
References: <20100114215058.4958.87746.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932342Ab0ANVxg@vger.kernel.org>
In-Reply-To: <20100114215058.4958.87746.stgit@mimic.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit: 0698047f0e3c189b5c511959b59e9614c901dabf,
which allowed in-kernel modules to create macvlans. This patch
then adds support for creating a venet macvlan via rt netlink.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c                   |   72 ++----
 include/linux/macvlan.h                 |    6 -
 kernel/vbus/devices/venet/device.c      |    8 +
 kernel/vbus/devices/venet/macvlan.c     |  360 ++++++++++++++++++++-----------
 kernel/vbus/devices/venet/tap.c         |    3 
 kernel/vbus/devices/venet/venetdevice.h |    3 
 6 files changed, 265 insertions(+), 187 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6b98b26..0a389b8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -208,7 +208,7 @@ static const struct header_ops macvlan_hard_header_ops = {
 	.cache_update	= eth_header_cache_update,
 };
 
-int macvlan_open(struct net_device *dev)
+static int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
@@ -235,7 +235,7 @@ out:
 	return err;
 }
 
-int macvlan_stop(struct net_device *dev)
+static int macvlan_stop(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
@@ -316,7 +316,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
@@ -440,7 +440,7 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree(port);
 }
 
-void macvlan_transfer_operstate(struct net_device *dev)
+static void macvlan_transfer_operstate(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct net_device *lowerdev = vlan->lowerdev;
@@ -458,7 +458,6 @@ void macvlan_transfer_operstate(struct net_device *dev)
 			netif_carrier_off(dev);
 	}
 }
-EXPORT_SYMBOL_GPL(macvlan_transfer_operstate);
 
 int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
@@ -472,47 +471,11 @@ int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 EXPORT_SYMBOL_GPL(macvlan_validate);
 
-int macvlan_link_lowerdev(struct net_device *dev,
-						  struct net_device *lowerdev)
-{
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvlan_port *port;
-	int err = 0;
-
-	if (lowerdev->macvlan_port == NULL) {
-		err = macvlan_port_create(lowerdev);
-		if (err < 0)
-			return err;
-	}
-	port = lowerdev->macvlan_port;
-
-	vlan->lowerdev = lowerdev;
-	vlan->dev      = dev;
-	vlan->port     = port;
-	vlan->receive  = netif_rx;
-
-	macvlan_init(dev);
-
-	list_add_tail(&vlan->list, &port->vlans);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(macvlan_link_lowerdev);
-
-void macvlan_unlink_lowerdev(struct net_device *dev)
-{
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvlan_port *port = vlan->port;
-
-	list_del(&vlan->list);
-
-	if (list_empty(&port->vlans))
-		macvlan_port_destroy(port->dev);
-}
-EXPORT_SYMBOL_GPL(macvlan_unlink_lowerdev);
-
 int macvlan_newlink(struct net_device *dev,
 		    struct nlattr *tb[], struct nlattr *data[])
 {
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port;
 	struct net_device *lowerdev;
 	int err;
 
@@ -539,14 +502,23 @@ int macvlan_newlink(struct net_device *dev,
 	if (!tb[IFLA_ADDRESS])
 		random_ether_addr(dev->dev_addr);
 
-	err = macvlan_link_lowerdev(dev, lowerdev);
-	if (err < 0)
-		return err;
+	if (lowerdev->macvlan_port == NULL) {
+		err = macvlan_port_create(lowerdev);
+		if (err < 0)
+			return err;
+	}
+	port = lowerdev->macvlan_port;
+
+	vlan->lowerdev = lowerdev;
+	vlan->dev      = dev;
+	vlan->port     = port;
+	vlan->receive  = netif_rx;
 
 	err = register_netdevice(dev);
 	if (err < 0)
 		return err;
 
+	list_add_tail(&vlan->list, &port->vlans);
 	macvlan_transfer_operstate(dev);
 	return 0;
 }
@@ -554,8 +526,14 @@ EXPORT_SYMBOL_GPL(macvlan_newlink);
 
 void macvlan_dellink(struct net_device *dev)
 {
-	macvlan_unlink_lowerdev(dev);
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port = vlan->port;
+
+	list_del(&vlan->list);
 	unregister_netdevice(dev);
+
+	if (list_empty(&port->vlans))
+		macvlan_port_destroy(port->dev);
 }
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
diff --git a/include/linux/macvlan.h b/include/linux/macvlan.h
index cf8738a..3f3c6c3 100644
--- a/include/linux/macvlan.h
+++ b/include/linux/macvlan.h
@@ -24,12 +24,6 @@ struct macvlan_dev {
 };
 
 extern int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev);
-extern int macvlan_link_lowerdev(struct net_device *dev,
-						  struct net_device *lowerdev);
-
-extern void macvlan_unlink_lowerdev(struct net_device *dev);
-
-extern void macvlan_transfer_operstate(struct net_device *dev);
 
 extern void macvlan_setup(struct net_device *dev);
 
diff --git a/kernel/vbus/devices/venet/device.c b/kernel/vbus/devices/venet/device.c
index d12257b..a657707 100644
--- a/kernel/vbus/devices/venet/device.c
+++ b/kernel/vbus/devices/venet/device.c
@@ -1999,7 +1999,7 @@ venetdev_flushrx(struct venetdev *priv)
 	return 0;
 }
 
-void venetdev_init(struct venetdev *device, struct net_device *dev)
+void venetdev_common_init(struct venetdev *device)
 {
 	device->vbus.import      = &venetdev_flat_import;
 	device->vbus.export      = &venetdev_flat_export;
@@ -2018,8 +2018,12 @@ void venetdev_init(struct venetdev *device, struct net_device *dev)
 	device->netif.rxq.completed = 0;
 	init_waitqueue_head(&device->netif.rxq.wq);
 
-	device->netif.dev = dev;
 	device->netif.out = venetdev_out;
+}
+
+void venetdev_dev_init(struct venetdev *device, struct net_device *dev)
+{
+	device->netif.dev = dev;
 
 	ether_setup(dev); /* assign some of the fields */
 
diff --git a/kernel/vbus/devices/venet/macvlan.c b/kernel/vbus/devices/venet/macvlan.c
index 8d5800a..29e8e13 100644
--- a/kernel/vbus/devices/venet/macvlan.c
+++ b/kernel/vbus/devices/venet/macvlan.c
@@ -44,6 +44,8 @@
 #include <linux/kthread.h>
 #include <linux/ktime.h>
 #include <linux/macvlan.h>
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
 
 #include "venetdevice.h"
 
@@ -60,13 +62,20 @@ MODULE_LICENSE("GPL");
 #  define PDEBUG(fmt, args...) /* not debugging: nothing */
 #endif
 
+struct venetmacv_netdev {
+	struct macvlan_dev mvdev;
+	const struct net_device_ops *macvlan_netdev_ops;
+	struct venetmacv *vdev;
+};
+
 struct venetmacv {
-	struct macvlan_dev mdev;
-	unsigned char ll_ifname[IFNAMSIZ];
+	struct venetmacv_netdev *mdev;
 	struct venetdev dev;
-	const struct net_device_ops *macvlan_netdev_ops;
+	unsigned char macv_ifname[IFNAMSIZ];
 };
 
+static struct venetmacv_netdev *find_macvenet(char *ifname);
+
 static inline struct venetmacv *conn_to_macv(struct vbus_connection *conn)
 {
 	return container_of(conn, struct venetmacv, dev.vbus.conn);
@@ -90,22 +99,22 @@ struct venetmacv *vbusdev_to_macv(struct vbus_device *vdev)
 	return container_of(vdev, struct venetmacv, dev.vbus.dev);
 }
 
-static int
-venetmacv_tx(struct sk_buff *skb, struct net_device *dev)
-{
-	struct venetmacv *priv = netdev_priv(dev);
-
-	return venetdev_xmit(skb, &priv->dev);
-}
-
 static int venetmacv_receive(struct sk_buff *skb)
 {
-	struct venetmacv *priv = netdev_priv(skb->dev);
+	struct venetmacv_netdev *priv = netdev_priv(skb->dev);
+	struct venetmacv *macv = priv->vdev;
 	int err;
 
+
+	if (!macv) {
+		PDEBUG("venetmacv_receive: vbus dev not connected \
+			- dropping..\n");
+		return NET_RX_DROP;
+	}
+
 	if (netif_queue_stopped(skb->dev)) {
 		PDEBUG("venetmacv_receive: queue congested - dropping..\n");
-		priv->dev.netif.stats.tx_dropped++;
+		macv->dev.netif.stats.tx_dropped++;
 		return NET_RX_DROP;
 	}
 	err = skb_linearize(skb);
@@ -115,26 +124,23 @@ static int venetmacv_receive(struct sk_buff *skb)
 		return -1;
 	}
 	skb_push(skb, ETH_HLEN);
-	return venetmacv_tx(skb, skb->dev);
+	return venetdev_xmit(skb, &macv->dev);
 }
 
 static void
 venetmacv_vlink_release(struct vbus_connection *conn)
 {
-	struct venetmacv *macv = conn_to_macv(conn);
-	macvlan_unlink_lowerdev(macv->mdev.dev);
 	venetdev_vlink_release(conn);
 }
 
 static void
 venetmacv_vlink_up(struct venetdev *vdev)
 {
-	struct venetmacv *macv = venetdev_to_macv(vdev);
 	int ret;
 
 	if (vdev->netif.link) {
 		rtnl_lock();
-		ret = macv->macvlan_netdev_ops->ndo_open(vdev->netif.dev);
+		ret = dev_open(vdev->netif.dev);
 		rtnl_unlock();
 		if (ret)
 			printk(KERN_ERR "macvlan_open failed %d!\n", ret);
@@ -144,12 +150,11 @@ venetmacv_vlink_up(struct venetdev *vdev)
 static void
 venetmacv_vlink_down(struct venetdev *vdev)
 {
-	struct venetmacv *macv = venetdev_to_macv(vdev);
 	int ret;
 
 	if (vdev->netif.link) {
 		rtnl_lock();
-		ret = macv->macvlan_netdev_ops->ndo_stop(vdev->netif.dev);
+		ret = dev_close(vdev->netif.dev);
 		rtnl_unlock();
 		if (ret)
 			printk(KERN_ERR "macvlan close failed %d!\n", ret);
@@ -201,7 +206,6 @@ venetmacv_intf_connect(struct vbus_device_interface *intf,
 {
 	struct venetmacv *macv = vbusintf_to_macv(intf);
 	unsigned long flags;
-	int ret;
 
 	PDEBUG("connect\n");
 
@@ -227,23 +231,11 @@ venetmacv_intf_connect(struct vbus_device_interface *intf,
 
 	vbus_memctx_get(ctx);
 
-	if (!macv->mdev.lowerdev) {
-		spin_unlock_irqrestore(&macv->dev.lock, flags);
-		return -ENXIO;
-	}
-
-	ret = macvlan_link_lowerdev(macv->mdev.dev, macv->mdev.lowerdev);
-
-	if (ret) {
+	if (!macv->mdev) {
 		spin_unlock_irqrestore(&macv->dev.lock, flags);
-		printk(KERN_ERR "macvlan_link_lowerdev: failed\n");
 		return -ENXIO;
 	}
 
-	macvlan_transfer_operstate(macv->mdev.dev);
-
-	macv->mdev.receive = venetmacv_receive;
-
 	spin_unlock_irqrestore(&macv->dev.lock, flags);
 
 	*conn = &macv->dev.vbus.conn;
@@ -323,13 +315,13 @@ venetmacv_device_release(struct vbus_device *dev)
 {
 	struct venetmacv *macv = vbusdev_to_macv(dev);
 
-	if (macv->mdev.lowerdev) {
-		dev_put(macv->mdev.lowerdev);
-		macv->mdev.lowerdev = NULL;
+	if (macv->mdev) {
+		dev_put(macv->mdev->mvdev.dev);
+		macv->mdev->vdev = NULL;
+		macv->dev.netif.dev = NULL;
+		macv->mdev = NULL;
 	}
 
-	venetdev_netdev_unregister(&macv->dev);
-	free_netdev(macv->mdev.dev);
 }
 
 
@@ -341,10 +333,10 @@ static struct vbus_device_ops venetmacv_device_ops = {
 
 #define VENETMACV_TYPE "venet-macvlan"
 static ssize_t
-ll_ifname_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
+macv_ifname_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
 				const char *buf, size_t count)
 {
-	struct venetmacv *priv = vbusdev_to_macv(dev);
+	struct venetmacv *macv = vbusdev_to_macv(dev);
 	size_t len;
 
 	len = strlen(buf);
@@ -352,52 +344,59 @@ ll_ifname_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
 	if (len >= IFNAMSIZ)
 		return -EINVAL;
 
-	if (priv->dev.vbus.opened)
+	if (macv->dev.vbus.opened)
 		return -EINVAL;
 
-	memcpy(priv->ll_ifname, buf, count);
+	memcpy(macv->macv_ifname, buf, count);
 
 	/* remove trailing newline if present */
-	if (priv->ll_ifname[count-1] == '\n')
-		priv->ll_ifname[count-1] = '\0';
+	if (macv->macv_ifname[count-1] == '\n')
+		macv->macv_ifname[count-1] = '\0';
 
-	if (priv->mdev.lowerdev) {
-		dev_put(priv->mdev.lowerdev);
-		priv->mdev.lowerdev = NULL;
+	if (macv->mdev) {
+		dev_put(macv->mdev->mvdev.dev);
+		macv->mdev = NULL;
 	}
 
-	priv->mdev.lowerdev = dev_get_by_name(dev_net(priv->mdev.dev),
-						priv->ll_ifname);
+	macv->mdev = find_macvenet(macv->macv_ifname);
 
-	if (!priv->mdev.lowerdev)
+	if (!macv->mdev)
 		return -ENXIO;
 
+	macv->mdev->vdev = macv;
+	macv->dev.netif.dev = macv->mdev->mvdev.dev;
+
 	return len;
 }
 
 static ssize_t
-ll_ifname_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
+macv_ifname_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
 			   char *buf)
 {
 	struct venetmacv *priv = vbusdev_to_macv(dev);
 
-	return snprintf(buf, PAGE_SIZE, "%s\n", priv->ll_ifname);
+	return snprintf(buf, PAGE_SIZE, "%s\n", priv->macv_ifname);
 }
 
-static struct vbus_device_attribute attr_ll_ifname =
-__ATTR(ll_ifname, S_IRUGO | S_IWUSR, ll_ifname_show, ll_ifname_store);
+static struct vbus_device_attribute attr_macv_ifname =
+__ATTR(macv_ifname, S_IRUGO | S_IWUSR, macv_ifname_show, macv_ifname_store);
 
 static ssize_t
 clientmac_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
 		const char *buf, size_t count)
 {
 	struct venetmacv *macv = vbusdev_to_macv(dev);
+	const struct net_device_ops *ops;
+	struct sockaddr saddr;
 	int ret;
 
 	ret = attr_cmac.store(dev, attr, buf, count);
 
-	if (ret == count)
-		memcpy(macv->mdev.dev->dev_addr, macv->dev.cmac, ETH_ALEN);
+	if (ret == count && macv->mdev) {
+		ops = macv->mdev->macvlan_netdev_ops;
+		memcpy(saddr.sa_data, buf, ETH_ALEN);
+		ops->ndo_set_mac_address(macv->dev.netif.dev, (void *)&saddr);
+	}
 
 	return ret;
 }
@@ -407,22 +406,60 @@ static struct vbus_device_attribute attr_clientmac =
 
 
 static ssize_t
+macv_enabled_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
+		  char *buf)
+{
+	struct venetdev *priv = vdev_to_priv(dev);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n", priv->netif.enabled);
+}
+
+static ssize_t
 macv_enabled_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
 		   const char *buf, size_t count)
 {
+	struct venetdev *priv = vdev_to_priv(dev);
 	struct venetmacv *macv = vbusdev_to_macv(dev);
-	int ret;
+	const struct net_device_ops *ops = macv->mdev->macvlan_netdev_ops;
+	struct sockaddr saddr;
+	int enabled = -1;
+	int ret = 0;
 
-	if (!macv->mdev.lowerdev)
-		return -ENXIO;
+	/* the following check is redundant, just being safe */
+	if (!priv->netif.dev || !macv->mdev)
+		return -ENODEV;
 
-	ret = attr_enabled.store(dev, attr, buf, count);
+	if (count > 0)
+		sscanf(buf, "%d", &enabled);
 
-	return ret;
+	if (enabled != 0 && enabled != 1)
+		return -EINVAL;
+
+	if (enabled && !priv->netif.enabled) {
+		memcpy(saddr.sa_data, priv->cmac, ETH_ALEN);
+		rtnl_lock();
+		venetdev_open(priv);
+		ops->ndo_set_mac_address(priv->netif.dev, (void *)&saddr);
+		rtnl_unlock();
+	}
+
+	if (!enabled && priv->netif.enabled) {
+		rtnl_lock();
+		venetdev_stop(priv);
+		rtnl_unlock();
+	}
+
+	if (ret < 0)
+		return ret;
+
+	priv->netif.enabled = enabled;
+
+	return count;
 }
 
 static struct vbus_device_attribute attr_macv_enabled =
-	__ATTR(enabled, S_IRUGO | S_IWUSR, enabled_show, macv_enabled_store);
+	__ATTR(enabled, S_IRUGO | S_IWUSR, macv_enabled_show,
+		macv_enabled_store);
 
 static struct attribute *attrs[] = {
 	&attr_clientmac.attr,
@@ -430,7 +467,7 @@ static struct attribute *attrs[] = {
 	&attr_burstthresh.attr,
 	&attr_txmitigation.attr,
 	&attr_ifname.attr,
-	&attr_ll_ifname.attr,
+	&attr_macv_ifname.attr,
 	NULL,
 };
 
@@ -441,109 +478,95 @@ static struct attribute_group venetmacv_attr_group = {
 static int
 venetmacv_netdev_open(struct net_device *dev)
 {
-	struct venetmacv *priv = netdev_priv(dev);
-	int ret = 0;
+	struct venetmacv_netdev *priv = netdev_priv(dev);
 
-	venetdev_open(&priv->dev);
-
-	if (priv->dev.vbus.link) {
-		ret = priv->macvlan_netdev_ops->ndo_open(priv->mdev.dev);
-	}
-
-	return ret;
+	return priv->macvlan_netdev_ops->ndo_open(dev);
 }
 
 static int
 venetmacv_netdev_stop(struct net_device *dev)
 {
-	struct venetmacv *priv = netdev_priv(dev);
-	int needs_stop = false;
-	int ret = 0;
-
-	if (priv->dev.netif.link)
-		needs_stop = true;
-
-	venetdev_stop(&priv->dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
 
-	if (priv->dev.vbus.link && needs_stop)
-		ret = priv->macvlan_netdev_ops->ndo_stop(dev);
-
-	return ret;
-}
-
-static void
-venetmacv_netdev_uninit(struct net_device *dev)
-{
-	struct venetmacv *macv = netdev_priv(dev);
-
-	if (macv->mdev.lowerdev) {
-		dev_put(macv->mdev.lowerdev);
-		macv->mdev.lowerdev = NULL;
-		memset(macv->ll_ifname, '\0', IFNAMSIZ);
-	}
-
-	macv->dev.netif.enabled = 0;
+	return priv->macvlan_netdev_ops->ndo_stop(dev);
 }
 
 /*
  * out routine for macvlan
  */
-
 static int
 venetmacv_out(struct venetdev *vdev, struct sk_buff *skb)
 {
 	struct venetmacv *macv = venetdev_to_macv(vdev);
-	skb->dev = macv->mdev.lowerdev;
-	skb->protocol = eth_type_trans(skb, macv->mdev.lowerdev);
+	struct venetmacv_netdev *priv = NULL;
+
+	if (!macv->mdev)
+		return -EIO;
+
+	priv = netdev_priv(vdev->netif.dev);
+	skb->dev = priv->mvdev.dev;
+	skb->protocol = eth_type_trans(skb, skb->dev);
 	skb_push(skb, ETH_HLEN);
-	return macv->macvlan_netdev_ops->ndo_start_xmit(skb, macv->mdev.dev);
+	return priv->macvlan_netdev_ops->ndo_start_xmit(skb, skb->dev);
 }
 
 static int
 venetmacv_netdev_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct venetmacv *priv = netdev_priv(dev);
-
-	return venetmacv_out(&priv->dev, skb);
+	/* this function should generally not be used
+	   the out routine is used by the venetdevice
+	   for dequeuing and transmitting frames from
+	   guest/userspace context */
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	return venetmacv_out(&priv->vdev->dev, skb);
 }
 
 static struct net_device_stats *
 venetmacv_netdev_stats(struct net_device *dev)
 {
-	struct venetmacv *priv = netdev_priv(dev);
-	return venetdev_get_stats(&priv->dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	struct venetmacv *macv = priv->vdev;
+
+	/* return netdev's stats block when vbus
+	   device is unconnected - this is ugly */
+	if (macv)
+		return venetdev_get_stats(&macv->dev);
+	else
+		return &dev->stats;
 }
 
 static int venetmacv_set_mac_address(struct net_device *dev, void *p)
 {
-	struct venetmacv *priv = netdev_priv(dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	struct venetdev *vdev = &priv->vdev->dev;
+	struct sockaddr *saddr = p;
 	int ret;
 
 	ret = priv->macvlan_netdev_ops->ndo_set_mac_address(dev, p);
 
 	if (!ret)
-		memcpy(priv->dev.cmac, p, ETH_ALEN);
+		memcpy(vdev->cmac, saddr->sa_data, ETH_ALEN);
 
 	return ret;
 }
 
 static int venetmacv_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct venetmacv *priv = netdev_priv(dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
 
 	return priv->macvlan_netdev_ops->ndo_change_mtu(dev, new_mtu);
 }
 
 static void venetmacv_change_rx_flags(struct net_device *dev, int change)
 {
-	struct venetmacv *priv = netdev_priv(dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
 
 	priv->macvlan_netdev_ops->ndo_change_rx_flags(dev, change);
 }
 
 static void venetmacv_set_multicast_list(struct net_device *dev)
 {
-	struct venetmacv *priv = netdev_priv(dev);
+	struct venetmacv_netdev *priv = netdev_priv(dev);
 
 	priv->macvlan_netdev_ops->ndo_set_multicast_list(dev);
 }
@@ -560,7 +583,77 @@ static struct net_device_ops venetmacv_netdev_ops = {
 	.ndo_start_xmit         = venetmacv_netdev_tx,
 	.ndo_do_ioctl           = venetdev_netdev_ioctl,
 	.ndo_get_stats          = venetmacv_netdev_stats,
-	.ndo_uninit             = venetmacv_netdev_uninit,
+};
+
+static int macvenet_newlink(struct net_device *dev,
+			    struct nlattr *tb[], struct nlattr *data[])
+{
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	int err;
+
+	err = macvlan_newlink(dev, tb, data);
+	if (err)
+		goto out1;
+
+	priv->mvdev.receive = venetmacv_receive;
+	priv->macvlan_netdev_ops = dev->netdev_ops;
+	dev->netdev_ops = &venetmacv_netdev_ops;
+
+	return 0;
+
+out1:
+	return err;
+}
+
+static void macvenet_dellink(struct net_device *dev)
+{
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	struct venetmacv *vdev = priv->vdev;
+
+	macvlan_dellink(dev);
+	priv->mvdev.receive = netif_rx;
+	if (vdev) {
+		dev_put(dev);
+		vdev->dev.netif.dev = NULL;
+		vdev->mdev = NULL;
+		if (vdev->dev.netif.enabled) {
+			venetdev_stop(&vdev->dev);
+			vdev->dev.netif.enabled = 0;
+		}
+	}
+}
+
+static void macvenet_setup(struct net_device *dev)
+{
+	struct venetmacv_netdev *priv = netdev_priv(dev);
+	memset(priv, 0, sizeof(*priv));
+	macvlan_setup(dev);
+}
+
+static struct venetmacv_netdev *find_macvenet(char *ifname)
+{
+	struct venetmacv_netdev *macv = NULL;
+	struct net_device *dev = NULL;
+	struct net *net = current->nsproxy->net_ns;
+
+	if (strncmp("macvenet", ifname, 8))
+		return NULL;
+
+	dev = dev_get_by_name(net, ifname);
+
+	if (dev)
+		macv = netdev_priv(dev);
+
+	return macv;
+}
+
+static struct rtnl_link_ops venetmacv_link_ops __read_mostly = {
+	.kind = "macvenet",
+	.priv_size = sizeof(struct venetmacv_netdev),
+	.setup = macvenet_setup,
+	.validate = macvlan_validate,
+	.newlink = macvenet_newlink,
+	.dellink = macvenet_dellink,
 };
 
 /*
@@ -571,20 +664,14 @@ static int
 venetmacv_device_create(struct vbus_devclass *dc,
 						struct vbus_device **vdev)
 {
-	struct net_device *dev;
 	struct venetmacv *priv;
 	struct vbus_device *_vdev;
 
-	dev = alloc_netdev(sizeof(struct venetmacv), "macvenet%d",
-					   macvlan_setup);
-
+	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
 
-	dev->destructor = NULL;
-
-	if (!dev)
+	if (!priv)
 		return -ENOMEM;
 
-	priv = netdev_priv(dev);
 	memset(priv, 0, sizeof(*priv));
 
 	spin_lock_init(&priv->dev.lock);
@@ -600,16 +687,11 @@ venetmacv_device_create(struct vbus_devclass *dc,
 	_vdev->ops             = &venetmacv_device_ops;
 	_vdev->attrs           = &venetmacv_attr_group;
 
-	venetdev_init(&priv->dev, dev);
+	*vdev = _vdev;
 
-	priv->mdev.dev = dev;
+	venetdev_common_init(&priv->dev);
 	priv->dev.netif.out = venetmacv_out;
 
-	priv->macvlan_netdev_ops = dev->netdev_ops;
-	dev->netdev_ops = &venetmacv_netdev_ops;
-
-	*vdev = _vdev;
-
 	return 0;
 }
 
@@ -625,11 +707,29 @@ static struct vbus_devclass venetmacv_devclass = {
 
 static int __init venetmacv_init(void)
 {
-	return vbus_devclass_register(&venetmacv_devclass);
+	int err = 0;
+
+	err = rtnl_link_register(&venetmacv_link_ops);
+
+	if (err < 0)
+		goto out;
+
+	err = vbus_devclass_register(&venetmacv_devclass);
+
+	if (err)
+		goto out2;
+
+	return 0;
+out2:
+	rtnl_link_unregister(&venetmacv_link_ops);
+
+out:
+	return err;
 }
 
 static void __exit venetmacv_cleanup(void)
 {
+	rtnl_link_unregister(&venetmacv_link_ops);
 	vbus_devclass_unregister(&venetmacv_devclass);
 }
 
diff --git a/kernel/vbus/devices/venet/tap.c b/kernel/vbus/devices/venet/tap.c
index b40c315..dd5ae3c 100644
--- a/kernel/vbus/devices/venet/tap.c
+++ b/kernel/vbus/devices/venet/tap.c
@@ -258,7 +258,8 @@ venettap_device_create(struct vbus_devclass *dc,
 	_vdev->ops             = &venettap_device_ops;
 	_vdev->attrs           = &venettap_attr_group;
 
-	venetdev_init(priv, dev);
+	venetdev_common_init(priv);
+	venetdev_dev_init(priv, dev);
 
 	dev->netdev_ops = &venettap_netdev_ops;
 
diff --git a/kernel/vbus/devices/venet/venetdevice.h b/kernel/vbus/devices/venet/venetdevice.h
index 6fa3dee..9e51621 100644
--- a/kernel/vbus/devices/venet/venetdevice.h
+++ b/kernel/vbus/devices/venet/venetdevice.h
@@ -163,7 +163,8 @@ int venetdev_vlink_shm(struct vbus_connection *conn,
 		   struct shm_signal *signal, unsigned long flags);
 void  venetdev_vlink_release(struct vbus_connection *conn);
 void  venetdev_vlink_close(struct vbus_connection *conn);
-void venetdev_init(struct venetdev *vdev, struct net_device *dev);
+void venetdev_common_init(struct venetdev *vdev);
+void venetdev_dev_init(struct venetdev *vdev, struct net_device *dev);
 
 extern struct vbus_device_attribute attr_cmac;
 extern struct vbus_device_attribute attr_hmac;
