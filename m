From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [NET] ethtool: Add LRO support
Date: Tue, 31 Jul 2007 13:21:02 -0700
Message-ID: <20070731202102.15755.72525.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759392AbXGaUVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:21:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/ethtool.h   |    8 +++++++
 include/linux/netdevice.h |    1 +
 net/core/ethtool.c        |   54 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3a63224..ab9d688 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -274,6 +274,8 @@ int ethtool_op_get_perm_addr(struct net_device *dev,
 			     struct ethtool_perm_addr *addr, u8 *data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
+u32 ethtool_op_get_lro(struct net_device *dev);
+int ethtool_op_set_lro(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -305,6 +307,8 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
  * set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
  * set_ufo: Turn UDP fragmentation offload on or off
+ * get_lro: Report whether large receive offload is enabled
+ * set_lro: Turn large receive offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -373,6 +377,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	u32     (*get_lro)(struct net_device *);
+	int     (*set_lro)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -414,6 +420,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GLRO		0x00000025 /* Get LRO enable (ethtool_value) */
+#define ETHTOOL_SLRO		0x00000026 /* Set LRO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..4863ffc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -341,6 +341,7 @@ struct net_device
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
+#define NETIF_F_LRO		32768	/* Has large receive offload */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0b531e9..23ccaa1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -104,7 +104,6 @@ int ethtool_op_get_perm_addr(struct net_device *dev, struct ethtool_perm_addr *a
 	return 0;
 }
 
-
 u32 ethtool_op_get_ufo(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_UFO) != 0;
@@ -119,6 +118,20 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
 	return 0;
 }
 
+u32 ethtool_op_get_lro(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_LRO) != 0;
+}
+
+int ethtool_op_set_lro(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_LRO;
+	else
+		dev->features &= ~NETIF_F_LRO;
+	return 0;
+}
+
 /* Handlers for each ethtool command */
 
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
@@ -514,6 +527,13 @@ static int __ethtool_set_sg(struct net_device *dev, u32 data)
 		if (err)
 			return err;
 	}
+
+	if (!data && dev->ethtool_ops->set_lro) {
+		err = dev->ethtool_ops->set_lro(dev, 0);
+		if (err)
+			return err;
+	}
+
 	return dev->ethtool_ops->set_sg(dev, data);
 }
 
@@ -625,6 +645,29 @@ static int ethtool_set_ufo(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_ufo(dev, edata.data);
 }
 
+static int ethtool_get_lro(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GLRO };
+
+	edata.data = dev->features & NETIF_F_LRO;
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_lro(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+	if (edata.data)
+		dev->features |= NETIF_F_LRO;
+	else
+		dev->features &= ~NETIF_F_LRO;
+	return 0;
+}
+
 static int ethtool_get_gso(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata = { ETHTOOL_GGSO };
@@ -840,6 +883,7 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
+	case ETHTOOL_GLRO:
 	case ETHTOOL_GGSO:
 		break;
 	default:
@@ -953,6 +997,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SUFO:
 		rc = ethtool_set_ufo(dev, useraddr);
 		break;
+	case ETHTOOL_GLRO:
+		rc = ethtool_get_lro(dev, useraddr);
+		break;
+	case ETHTOOL_SLRO:
+		rc = ethtool_set_lro(dev, useraddr);
+		break;
 	case ETHTOOL_GGSO:
 		rc = ethtool_get_gso(dev, useraddr);
 		break;
@@ -994,3 +1044,5 @@ EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
 EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 EXPORT_SYMBOL(ethtool_op_set_ufo);
 EXPORT_SYMBOL(ethtool_op_get_ufo);
+EXPORT_SYMBOL(ethtool_op_set_lro);
+EXPORT_SYMBOL(ethtool_op_get_lro);
