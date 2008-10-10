From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 09/14] r8169: add a new 8168c flavor (bis)
Date: Fri, 10 Oct 2008 23:44:57 +0200
Message-ID: <20081010214457.GI27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37968 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760553AbYJJVpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:45:32 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
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
index 9681aca..9a0d4e6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -110,7 +110,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
-	RTL_GIGA_MAC_VER_21 = 0x15  // 8168C
+	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16  // 8168C
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -141,7 +142,8 @@ static const struct {
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1223,6 +1225,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
 		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
+		{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
 		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
 
 		/* 8168B family. */
@@ -1469,6 +1472,11 @@ static void rtl8168c_3_hw_phy_config(void __iomem *ioaddr)
 	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
+static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
+{
+	rtl8168c_3_hw_phy_config(ioaddr);
+}
+
 static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1528,6 +1536,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_21:
 		rtl8168c_3_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_22:
+		rtl8168c_4_hw_phy_config(ioaddr);
+		break;
 	default:
 		break;
 	}
@@ -2523,6 +2534,13 @@ static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_hw_start_8168c_2(ioaddr, pdev);
 }
 
+static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	__rtl_hw_start_8168cp(ioaddr, pdev);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2582,6 +2600,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168c_3(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_22:
+		rtl_hw_start_8168c_4(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

