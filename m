From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 07/13] r8169: add MAC identifiers
Date: Thu, 18 Oct 2007 23:01:38 +0200
Message-ID: <20071018210138.GH31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40506 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbXJRVF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:05:56 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The identifiers have been extracted from Realtek's drivers:
- version 8.002.00 of the r8168 driver
- version 6.002.00 of the r8169 driver
- version 1.002.00 of the r8101 driver

1. RTL_GIGA_MAC_VER_17 (8168Bf) is isolated from RTL_GIGA_MAC_VER_12 (8168Be)
   Both are still handled the same in rtl8169_set_speed_xmii and in
   rtl_set_rx_mode to avoid changes of behavior in this patch.

2. RTL_GIGA_MAC_VER_16 (8101Ec) is isolated from RTL_GIGA_MAC_VER_13 (8101Eb)
   Same thing as above with relation to rtl8169_set_speed_xmii,
   rtl_set_rx_mode and rtl_hw_start_8101.

3. The remaining new identifiers should not hurt.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   87 +++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 64 insertions(+), 23 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c290aa5..9deda50 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -112,10 +112,15 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
-	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
-	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
-	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
-	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101 ?
+	RTL_GIGA_MAC_VER_15 = 0x0f, // 8101 ?
+	RTL_GIGA_MAC_VER_16 = 0x11, // 8101Ec
+	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
+	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
+	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
+	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
 };
 
 enum phy_version {
@@ -145,7 +150,12 @@ static const struct {
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
 	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, 0xff7e1880), // PCI-E 8139
-	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880)  // PCI-E 8139
+	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880), // PCI-E 8139
+	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_17, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -716,7 +726,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		/* This tweak comes straight from Realtek's driver. */
 		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_13)) {
+		    ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+		     (tp->mac_version == RTL_GIGA_MAC_VER_16))) {
 			auto_nego = ADVERTISE_100HALF | ADVERTISE_CSMA;
 		}
 	}
@@ -724,7 +735,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 	/* The 8100e/8101e do Fast Ethernet only. */
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
 		    netif_msg_link(tp)) {
 			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
@@ -735,7 +747,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
@@ -1113,26 +1126,51 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	 */
 	const struct {
 		u32 mask;
+		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		{ 0x38800000,	RTL_GIGA_MAC_VER_15 },
-		{ 0x38000000,	RTL_GIGA_MAC_VER_12 },
-		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
-		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
-		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
-		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
-		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
-		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
-		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
-		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
-		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
+		/* 8168B family. */
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
+		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+
+		/* 8168B family. */
+		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
+		{ 0x7cf00000, 0x38500000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x38000000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
+
+		/* 8101 family. */
+		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
+		/* FIXME: where did these entries come from ? -- FR */
+		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
+		{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
+
+		/* 8110 family. */
+		{ 0xfc800000, 0x98000000,	RTL_GIGA_MAC_VER_06 },
+		{ 0xfc800000, 0x18000000,	RTL_GIGA_MAC_VER_05 },
+		{ 0xfc800000, 0x10000000,	RTL_GIGA_MAC_VER_04 },
+		{ 0xfc800000, 0x04000000,	RTL_GIGA_MAC_VER_03 },
+		{ 0xfc800000, 0x00800000,	RTL_GIGA_MAC_VER_02 },
+		{ 0xfc800000, 0x00000000,	RTL_GIGA_MAC_VER_01 },
+
+		{ 0x00000000, 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0xfc800000;
-	while ((reg & p->mask) != p->mask)
+	reg = RTL_R32(TxConfig);
+	while ((reg & p->mask) != p->val)
 		p++;
 	tp->mac_version = p->mac_version;
+
+	if (p->mask == 0x00000000) {
+		struct pci_dev *pdev = tp->pci_dev;
+
+		dev_info(&pdev->dev, "unknown MAC (%08x)\n", reg);
+	}
 }
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
@@ -2074,7 +2112,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		pci_write_config_word(pdev, 0x68, 0x00);
 		pci_write_config_word(pdev, 0x69, 0x08);
 	}
@@ -3030,7 +3069,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		mc_filter[0] = 0xffffffff;
 		mc_filter[1] = 0xffffffff;
 	}
-- 
1.5.2.4

