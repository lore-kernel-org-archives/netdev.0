From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 10/14] r8169: add a new 8168cp flavor
Date: Fri, 10 Oct 2008 23:45:45 +0200
Message-ID: <20081010214545.GJ27195@electric-eye.fr.zoreil.com>
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
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33978 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764767AbYJJVqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:46:42 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taken from Realtek's 8.006.00 r8168 driver.

I have left some bits related to jumbo frame aside for now.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   49 +++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9a0d4e6..775dc84 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -111,7 +111,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
 	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
-	RTL_GIGA_MAC_VER_22 = 0x16  // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
+	RTL_GIGA_MAC_VER_23 = 0x17  // 8168CP
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -143,7 +144,8 @@ static const struct {
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1221,6 +1223,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168B family. */
+		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
@@ -1380,7 +1383,7 @@ static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0000 },
@@ -1393,6 +1396,21 @@ static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
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
 static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1525,7 +1543,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168bef_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_18:
-		rtl8168cp_hw_phy_config(ioaddr);
+		rtl8168cp_1_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_19:
 		rtl8168c_1_hw_phy_config(ioaddr);
@@ -1539,6 +1557,10 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_22:
 		rtl8168c_4_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_23:
+		rtl8168cp_2_hw_phy_config(ioaddr);
+		break;
+
 	default:
 		break;
 	}
@@ -2481,7 +2503,7 @@ static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	static struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
@@ -2498,6 +2520,17 @@ static void rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
+static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
 static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	static struct ephy_info e_info_8168c_1[] = {
@@ -2585,7 +2618,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	break;
 
 	case RTL_GIGA_MAC_VER_18:
-		rtl_hw_start_8168cp(ioaddr, pdev);
+		rtl_hw_start_8168cp_1(ioaddr, pdev);
 	break;
 
 	case RTL_GIGA_MAC_VER_19:
@@ -2604,6 +2637,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168c_4(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_23:
+		rtl_hw_start_8168cp_2(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

