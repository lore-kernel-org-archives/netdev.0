From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 12/13] r8169: add a new 8168 flavor (ter)
Date: Sun, 29 Jun 2008 16:48:34 +0200
Message-ID: <20080629144834.GM1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46580 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704AbYF2OtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:49:00 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taken from Realtek's 8.006.00 r8168 driver.

I have left some bits related to jumbo frame aside for now.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   41 +++++++++++++++++++++++++++++++++++++++--
 1 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f47d951..47fa19b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -106,7 +106,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
 	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
-	RTL_GIGA_MAC_VER_22 = 0x16  // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
+	RTL_GIGA_MAC_VER_23 = 0x17  // 8168CP
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -134,7 +135,8 @@ static const struct {
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1219,6 +1221,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168B family. */
+		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
@@ -1466,6 +1469,21 @@ static void rtl8168cw_hw_phy_config(void __iomem *ioaddr)
 	rtl8168cz_hw_phy_config(ioaddr);
 }
 
+static void rtl8168cy_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x1d, 0x3d98 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1507,6 +1525,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_22:
 		rtl8168cw_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_23:
+		rtl8168cy_hw_phy_config(ioaddr);
+		break;
+
 	default:
 		break;
 	}
@@ -2408,6 +2430,17 @@ static void rtl_hw_start_8168cw(void __iomem *ioaddr, struct pci_dev *pdev)
 	__rtl_hw_start_8168cpx(ioaddr, pdev);
 }
 
+static void rtl_hw_start_8168cy(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
+
+	rtl8168c_cpcmd_quirk(ioaddr);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2473,6 +2506,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168cw(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_23:
+		rtl_hw_start_8168cy(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

