From: Robert Olsson <robert@herjulf.net>
Subject: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 2/5 for net-next-2.6
Date: Mon, 23 Nov 2009 23:51:44 +0100
Message-ID: <19211.4608.525880.115370@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av11-2-sn2.hy.skanova.net ([81.228.8.184]:51287 "EHLO
	av11-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZKWXTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 18:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>



diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index edd03b7..d2a729b 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -272,6 +272,53 @@ struct ethtool_stats {
 	__u64	data[0];
 };
 
+/* Diagmostic Monitoring Interface Data -- DOM */
+struct ethtool_phy_diag {
+	__u32 cmd;
+	/* A0 page */
+	__u16 type;
+	__u16 wavelength;
+	/* A2 page */
+	__u16 alarm; 
+	__u16 warning; 
+	__s16 temp;
+	__u16 temp_slope;
+	__s16 temp_offset;
+	__u16 vcc;
+	__u16 vcc_slope;
+	__s16 vcc_offset;
+	__u16 tx_bias;
+	__u16 tx_bias_slope;
+	__s16 tx_bias_offset;
+	__u16 tx_pwr;
+	__u16 tx_pwr_slope;
+	__s16 tx_pwr_offset;
+	__u16 rx_pwr;
+	__u32 rx_pwr_cal[5];
+
+	/* Thresholds */
+  	__s16 temp_alt;
+  	__s16 temp_aht;
+  	__s16 temp_wlt;
+  	__s16 temp_wht;
+  	__u16 vcc_alt;
+  	__u16 vcc_aht;
+  	__u16 vcc_wlt;
+  	__u16 vcc_wht;
+  	__u16 tx_bias_alt;
+  	__u16 tx_bias_aht;
+  	__u16 tx_bias_wlt;
+  	__u16 tx_bias_wht;
+  	__u16 tx_pwr_alt;
+  	__u16 tx_pwr_aht;
+  	__u16 tx_pwr_wlt;
+  	__u16 tx_pwr_wht;
+  	__u16 rx_pwr_alt;
+  	__u16 rx_pwr_aht;
+  	__u16 rx_pwr_wlt;
+  	__u16 rx_pwr_wht;
+};
+
 struct ethtool_perm_addr {
 	__u32	cmd;		/* ETHTOOL_GPERMADDR */
 	__u32	size;
@@ -499,6 +546,7 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	int     (*get_phy_diag)(struct net_device *, struct ethtool_phy_diag*);
 };
 #endif /* __KERNEL__ */
 
@@ -557,6 +605,7 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
+#define ETHTOOL_GPHYDIAG        0x00000035 /* Get PHY diagnostics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8aee58..f4a1eae 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -893,6 +893,21 @@ static int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
+static int ethtool_phy_diag(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_phy_diag pd;
+
+	if (!dev->ethtool_ops->get_phy_diag)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_phy_diag(dev, &pd); /* FIXME */
+	
+	if (copy_to_user(useraddr, &pd, sizeof(pd)))
+		 return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1112,6 +1127,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_RESET:
 		rc = ethtool_reset(dev, useraddr);
 		break;
+	case ETHTOOL_GPHYDIAG:
+		rc = ethtool_phy_diag(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
