From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [NET] ethtool: Add LRO support
Date: Thu, 09 Aug 2007 09:41:17 -0700
Message-ID: <20070809164117.9907.23351.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ossthema@de.ibm.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18469 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765745AbXHIQlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 12:41:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/ethtool.h   |    8 +++++++
 include/linux/netdevice.h |    1 +
 net/core/ethtool.c        |   53 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 23ccea8..a97248e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -272,6 +272,8 @@ u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
+u32 ethtool_op_get_lro(struct net_device *dev);
+int ethtool_op_set_lro(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -303,6 +305,8 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
  * set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
  * set_ufo: Turn UDP fragmentation offload on or off
+ * get_lro: Report whether large receive offload is enabled
+ * set_lro: Turn large receive offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -369,6 +373,8 @@ struct ethtool_ops {
 	void	(*complete)(struct net_device *);
 	u32     (*get_ufo)(struct net_device *);
 	int     (*set_ufo)(struct net_device *, u32);
+	u32     (*get_lro)(struct net_device *);
+	int     (*set_lro)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -410,6 +416,8 @@ struct ethtool_ops {
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
index 2ab0a60..65f751b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -109,6 +109,20 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
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
@@ -504,6 +518,13 @@ static int __ethtool_set_sg(struct net_device *dev, u32 data)
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
 
@@ -615,6 +636,29 @@ static int ethtool_set_ufo(struct net_device *dev, char __user *useraddr)
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
@@ -816,6 +860,7 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
+	case ETHTOOL_GLRO:
 	case ETHTOOL_GGSO:
 		break;
 	default:
@@ -929,6 +974,12 @@ int dev_ethtool(struct ifreq *ifr)
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
@@ -960,3 +1011,5 @@ EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
 EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
 EXPORT_SYMBOL(ethtool_op_set_ufo);
 EXPORT_SYMBOL(ethtool_op_get_ufo);
+EXPORT_SYMBOL(ethtool_op_set_lro);
+EXPORT_SYMBOL(ethtool_op_get_lro);
