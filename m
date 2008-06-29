From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 11/13] r8169: add a new 8168 flavor (bis)
Date: Sun, 29 Jun 2008 16:47:42 +0200
Message-ID: <20080629144742.GL1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46567 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760580AbYF2OsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:48:05 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taken from Realtek's 8.006.00 r8168 driver.

I have left some bits related to jumbo frame aside for now.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 968494e..f47d951 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -105,7 +105,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
-	RTL_GIGA_MAC_VER_21 = 0x15  // 8168C
+	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16  // 8168C
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -132,7 +133,8 @@ static const struct {
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1221,6 +1223,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
 		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
+		{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
 		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
 
 		/* 8168B family. */
@@ -1458,6 +1461,11 @@ static void rtl8168cz_hw_phy_config(void __iomem *ioaddr)
 	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
+static void rtl8168cw_hw_phy_config(void __iomem *ioaddr)
+{
+	rtl8168cz_hw_phy_config(ioaddr);
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1496,6 +1504,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_21:
 		rtl8168cz_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_22:
+		rtl8168cw_hw_phy_config(ioaddr);
+		break;
 	default:
 		break;
 	}
@@ -2390,6 +2401,13 @@ static void rtl_hw_start_8168cz(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_hw_start_8168cx(ioaddr, pdev);
 }
 
+static void rtl_hw_start_8168cw(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_csi_access_enable(ioaddr);
+
+	__rtl_hw_start_8168cpx(ioaddr, pdev);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2451,6 +2469,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168cz(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_22:
+		rtl_hw_start_8168cw(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

