From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer settings
Date: Tue, 29 Jul 2014 17:10:38 +0530
Message-ID: <1406634039-15030-3-git-send-email-_govind@gmx.com>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:56433 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466AbaG2Lld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 07:41:33 -0400
In-Reply-To: <1406634039-15030-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new ethtool_cmd for setting DMA buffer relate settings.
As of now rx_copybreak is the only parameter support.

Reserving more space in struct ethtool_buffparam for upcoming parameters like
tx_copybreak etc.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/linux/ethtool.h      |  7 +++++++
 include/uapi/linux/ethtool.h | 16 ++++++++++++++++
 net/core/ethtool.c           | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e658229..5893034 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -184,6 +184,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  * @get_module_eeprom: Get the eeprom information from the plug-in module
  * @get_eee: Get Energy-Efficient (EEE) supported and status.
  * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
+ * @get_buffparam: Get DMA buffer related settings.
+ * @set_buffparam: Set DMA buffer related settings. Returns a negative error
+ *	code or zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -257,6 +260,10 @@ struct ethtool_ops {
 				     struct ethtool_eeprom *, u8 *);
 	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
 	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
+	void	(*get_buffparam)(struct net_device *,
+				 struct ethtool_buffparam *);
+	int	(*set_buffparam)(struct net_device *,
+				 struct ethtool_buffparam *);
 
 
 };
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index e3c7a71..8c44104 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -440,6 +440,20 @@ struct ethtool_ringparam {
 };
 
 /**
+ * struct ethtool_buffparam - DMA buffer parameters
+ * @rx_copybreak_cur: current receive DMA buff rx_copybreak.
+ * @rx_copybreak_min: min rx_copybreak set by driver.
+ * @rx_copybreak_max: Max rx_copybreak set by driver.
+ * @reserved: reserve room for future use.
+ */
+struct ethtool_buffparam {
+	__u32	cmd;
+	__u32	rx_copybreak_cur;
+	__u32	rx_copybreak_max;
+	__u8	reserved[84];
+};
+
+/**
  * struct ethtool_channels - configuring number of network channel
  * @cmd: ETHTOOL_{G,S}CHANNELS
  * @max_rx: Read only. Maximum number of receive channel the driver support.
@@ -1152,6 +1166,8 @@ enum ethtool_sfeatures_retval_bits {
 
 #define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+#define ETHTOOL_GBUFFPARAM	0x00000048 /* Get DMA buff parameter */
+#define ETHTOOL_SBUFFPARAM	0x00000049 /* Set DMA buff parameter */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 17cb912..24fce27 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1146,6 +1146,31 @@ static int ethtool_set_ringparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ringparam(dev, &ringparam);
 }
 
+static int ethtool_get_buffparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_buffparam buffparam;
+
+	if (!dev->ethtool_ops->get_buffparam)
+		return -EOPNOTSUPP;
+	dev->ethtool_ops->get_buffparam(dev, &buffparam);
+	if (copy_to_user(useraddr, &buffparam, sizeof(buffparam)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int ethtool_set_buffparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_buffparam buffparam;
+
+	if (!dev->ethtool_ops->set_buffparam)
+		return -EOPNOTSUPP;
+	if (copy_from_user(&buffparam, useraddr, sizeof(buffparam)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_buffparam(dev, &buffparam);
+}
+
 static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
 						   void __user *useraddr)
 {
@@ -1670,6 +1695,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GCHANNELS:
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
+	case ETHTOOL_GBUFFPARAM:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -1857,6 +1883,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GMODULEEEPROM:
 		rc = ethtool_get_module_eeprom(dev, useraddr);
 		break;
+	case ETHTOOL_GBUFFPARAM:
+		rc = ethtool_get_buffparam(dev, useraddr);
+		break;
+	case ETHTOOL_SBUFFPARAM:
+		rc = ethtool_set_buffparam(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.0.3
