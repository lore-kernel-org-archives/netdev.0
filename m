From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Fri, 08 Jun 2007 15:00:07 -0700
Message-ID: <20070608220007.31573.14931.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arjan@linux.intel.com
To: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63612 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937752AbXFHWAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 18:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A lot of netdevices implement their own variant of printk and use
use variations of dev_printk, printk or others that use msg_enable,
which has been an eyesore with countless variations across drivers.

This patch implements a standard ndev_printk and derivatives
such as ndev_err, ndev_info, ndev_warn that allows drivers to
transparently use both the msg_enable and a generic netdevice
message layout. It moves the msg_enable over to the net_device
struct and allows drivers to obsolete ethtool handling code of
the msg_enable value.

The current code has each driver contain a copy of msg_enable and
handle the setting/changing through ethtool that way. Since the
netdev name is stored in the net_device struct, those two are
not coherently available in a uniform way across all drivers (a
single macro or function would not work since all drivers name
their net_device members differently). This makes netdevice
driver writes reinvent the wheel over and over again.

It thus makes sense to move msg_enable to the net_device. This
gives us the opportunity to (1) initialize it by default with a
globally sane value, (2) remove msg_enable handling code w/r
ethtool for drivers that know and use the msg_enable member
of the net_device struct. (3) Ethtool code can just modify the
net_device msg_enable for drivers that do not have custom
msg_enable get/set handlers so converted drivers lose some
code for that as well.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/netdevice.h |   24 ++++++++++++++++++++++++
 net/core/dev.c            |   10 ++++++++++
 net/core/ethtool.c        |   14 +++++++-------
 3 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a70f55..5551b63 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -540,6 +540,8 @@ struct net_device
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
 	struct attribute_group  *sysfs_groups[3];
+
+	int			msg_enable;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -838,6 +840,28 @@ enum {
 	NETIF_MSG_WOL		= 0x4000,
 };
 
+#define ndev_printk(kern_level, netif_level, netdev, format, arg...) \
+	do { if ((netdev)->msg_enable & NETIF_MSG_##netif_level) { \
+		printk(kern_level "%s: " format, \
+		(netdev)->name, ## arg); } } while (0)
+
+#ifdef DEBUG
+#define ndev_dbg(level, netdev, format, arg...) \
+	ndev_printk(KERN_DEBUG, level, netdev, format, ## arg)
+#else
+#define ndev_dbg(level, netdev, format, arg...) \
+	do { (void)(netdev); } while (0)
+#endif
+
+#define ndev_err(level, netdev, format, arg...) \
+	ndev_printk(KERN_ERR, level, netdev, format, ## arg)
+#define ndev_info(level, netdev, format, arg...) \
+	ndev_printk(KERN_INFO, level, netdev, format, ## arg)
+#define ndev_warn(level, netdev, format, arg...) \
+	ndev_printk(KERN_WARNING, level, netdev, format, ## arg)
+#define ndev_notice(level, netdev, format, arg...) \
+	ndev_printk(KERN_NOTICE, level, netdev, format, ## arg)
+
 #define netif_msg_drv(p)	((p)->msg_enable & NETIF_MSG_DRV)
 #define netif_msg_probe(p)	((p)->msg_enable & NETIF_MSG_PROBE)
 #define netif_msg_link(p)	((p)->msg_enable & NETIF_MSG_LINK)
diff --git a/net/core/dev.c b/net/core/dev.c
index 5a7f20f..e854c09 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3376,6 +3376,16 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 		dev->priv = netdev_priv(dev);
 
 	dev->get_stats = internal_stats;
+	dev->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK;
+#ifdef DEBUG
+	/* put these to good use: */
+	dev->msg_enable |= NETIF_MSG_TIMER | NETIF_MSG_IFDOWN |
+	                   NETIF_MSG_IFUP | NETIF_MSG_RX_ERR |
+	                   NETIF_MSG_TX_ERR | NETIF_MSG_TX_QUEUED |
+	                   NETIF_MSG_INTR | NETIF_MSG_TX_DONE |
+	                   NETIF_MSG_RX_STATUS | NETIF_MSG_PKTDATA |
+	                   NETIF_MSG_HW | NETIF_MSG_WOL;
+#endif
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 8d5e5a0..ff8d52f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -234,9 +234,9 @@ static int ethtool_get_msglevel(struct net_device *dev, char __user *useraddr)
 	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
 
 	if (!dev->ethtool_ops->get_msglevel)
-		return -EOPNOTSUPP;
-
-	edata.data = dev->ethtool_ops->get_msglevel(dev);
+		edata.data = dev->msg_enable;
+	else
+		edata.data = dev->ethtool_ops->get_msglevel(dev);
 
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
@@ -247,13 +247,13 @@ static int ethtool_set_msglevel(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
 
-	if (!dev->ethtool_ops->set_msglevel)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
 
-	dev->ethtool_ops->set_msglevel(dev, edata.data);
+	if (!dev->ethtool_ops->set_msglevel)
+		dev->msg_enable = edata.data;
+	else
+		dev->ethtool_ops->set_msglevel(dev, edata.data);
 	return 0;
 }
 
