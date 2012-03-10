From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 7/8] r8169: move rtl_cfg_info closer to its caller.
Date: Sat, 10 Mar 2012 23:20:49 +0100
Message-ID: <20120310222049.GH9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41111 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752952Ab2CJWWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:22:02 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  118 ++++++++++++++++-----------------
 1 files changed, 57 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 12329c5..390e69a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -255,10 +255,6 @@ enum cfg_version {
 	RTL_CFG_2
 };
 
-static void rtl_hw_start_8169(struct net_device *);
-static void rtl_hw_start_8168(struct net_device *);
-static void rtl_hw_start_8101(struct net_device *);
-
 static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
@@ -3438,63 +3434,6 @@ static int rtl_tbi_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data
 	return -EOPNOTSUPP;
 }
 
-static const struct rtl_cfg_info {
-	void (*hw_start)(struct net_device *);
-	unsigned int region;
-	unsigned int align;
-	u16 event_slow;
-	unsigned features;
-	u8 default_ver;
-} rtl_cfg_infos [] = {
-	[RTL_CFG_0] = {
-		.hw_start	= rtl_hw_start_8169,
-		.region		= 1,
-		.align		= 0,
-		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver,
-		.features	= RTL_FEATURE_GMII,
-		.default_ver	= RTL_GIGA_MAC_VER_01,
-	},
-	[RTL_CFG_1] = {
-		.hw_start	= rtl_hw_start_8168,
-		.region		= 2,
-		.align		= 8,
-		.event_slow	= SYSErr | LinkChg | RxOverflow,
-		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
-		.default_ver	= RTL_GIGA_MAC_VER_11,
-	},
-	[RTL_CFG_2] = {
-		.hw_start	= rtl_hw_start_8101,
-		.region		= 2,
-		.align		= 8,
-		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
-				  PCSTimeout,
-		.features	= RTL_FEATURE_MSI,
-		.default_ver	= RTL_GIGA_MAC_VER_13,
-	}
-};
-
-/* Cfg9346_Unlock assumed. */
-static unsigned rtl_try_msi(struct rtl8169_private *tp,
-			    const struct rtl_cfg_info *cfg)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned msi = 0;
-	u8 cfg2;
-
-	cfg2 = RTL_R8(Config2) & ~MSIEnable;
-	if (cfg->features & RTL_FEATURE_MSI) {
-		if (pci_enable_msi(tp->pci_dev)) {
-			netif_info(tp, hw, tp->dev, "no MSI. Back to INTx.\n");
-		} else {
-			cfg2 |= MSIEnable;
-			msi = RTL_FEATURE_MSI;
-		}
-	}
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
-		RTL_W8(Config2, cfg2);
-	return msi;
-}
-
 static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 {
 	if (tp->features & RTL_FEATURE_MSI) {
@@ -6053,6 +5992,63 @@ static const struct net_device_ops rtl_netdev_ops = {
 
 };
 
+static const struct rtl_cfg_info {
+	void (*hw_start)(struct net_device *);
+	unsigned int region;
+	unsigned int align;
+	u16 event_slow;
+	unsigned features;
+	u8 default_ver;
+} rtl_cfg_infos [] = {
+	[RTL_CFG_0] = {
+		.hw_start	= rtl_hw_start_8169,
+		.region		= 1,
+		.align		= 0,
+		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver,
+		.features	= RTL_FEATURE_GMII,
+		.default_ver	= RTL_GIGA_MAC_VER_01,
+	},
+	[RTL_CFG_1] = {
+		.hw_start	= rtl_hw_start_8168,
+		.region		= 2,
+		.align		= 8,
+		.event_slow	= SYSErr | LinkChg | RxOverflow,
+		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
+		.default_ver	= RTL_GIGA_MAC_VER_11,
+	},
+	[RTL_CFG_2] = {
+		.hw_start	= rtl_hw_start_8101,
+		.region		= 2,
+		.align		= 8,
+		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
+				  PCSTimeout,
+		.features	= RTL_FEATURE_MSI,
+		.default_ver	= RTL_GIGA_MAC_VER_13,
+	}
+};
+
+/* Cfg9346_Unlock assumed. */
+static unsigned rtl_try_msi(struct rtl8169_private *tp,
+			    const struct rtl_cfg_info *cfg)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	unsigned msi = 0;
+	u8 cfg2;
+
+	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	if (cfg->features & RTL_FEATURE_MSI) {
+		if (pci_enable_msi(tp->pci_dev)) {
+			netif_info(tp, hw, tp->dev, "no MSI. Back to INTx.\n");
+		} else {
+			cfg2 |= MSIEnable;
+			msi = RTL_FEATURE_MSI;
+		}
+	}
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_06)
+		RTL_W8(Config2, cfg2);
+	return msi;
+}
+
 static int __devinit
 rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-- 
1.7.7.6
