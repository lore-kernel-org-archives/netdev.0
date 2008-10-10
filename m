From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 13/14] r8169: preliminary 8168d support
Date: Fri, 10 Oct 2008 23:47:58 +0200
Message-ID: <20081010214758.GM27195@electric-eye.fr.zoreil.com>
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
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34035 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759698AbYJJVtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:49:04 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taken from Realtek's 8.007.00 r8168 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Fixed-by: Ivan Vecera <ivecera@redhat.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   99 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 97 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 96b9b0b..02b11a0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -113,7 +113,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
 	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
 	RTL_GIGA_MAC_VER_23 = 0x17, // 8168CP
-	RTL_GIGA_MAC_VER_24 = 0x18  // 8168CP
+	RTL_GIGA_MAC_VER_24 = 0x18, // 8168CP
+	RTL_GIGA_MAC_VER_25 = 0x19  // 8168D
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -147,7 +148,8 @@ static const struct {
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, 0xff7e1880)  // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, 0xff7e1880), // PCI-E
+	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_25, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1224,6 +1226,9 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
+		/* 8168D family. */
+		{ 0x7c800000, 0x28000000,	RTL_GIGA_MAC_VER_25 },
+
 		/* 8168C family. */
 		{ 0x7cf00000, 0x3ca00000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
@@ -1499,6 +1504,76 @@ static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
 	rtl8168c_3_hw_phy_config(ioaddr);
 }
 
+static void rtl8168d_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init_0[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x09, 0x2770 },
+		{ 0x08, 0x04d0 },
+		{ 0x0b, 0xad15 },
+		{ 0x0c, 0x5bf0 },
+		{ 0x1c, 0xf101 },
+		{ 0x1f, 0x0003 },
+		{ 0x14, 0x94d7 },
+		{ 0x12, 0xf4d6 },
+		{ 0x09, 0xca0f },
+		{ 0x1f, 0x0002 },
+		{ 0x0b, 0x0b10 },
+		{ 0x0c, 0xd1f7 },
+		{ 0x1f, 0x0002 },
+		{ 0x06, 0x5461 },
+		{ 0x1f, 0x0002 },
+		{ 0x05, 0x6662 },
+		{ 0x1f, 0x0000 },
+		{ 0x14, 0x0060 },
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf8a0 },
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0xffc2 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+
+	if (mdio_read(ioaddr, 0x06) == 0xc400) {
+		struct phy_reg phy_reg_init_1[] = {
+			{ 0x1f, 0x0005 },
+			{ 0x01, 0x0300 },
+			{ 0x1f, 0x0000 },
+			{ 0x11, 0x401c },
+			{ 0x16, 0x4100 },
+			{ 0x1f, 0x0005 },
+			{ 0x07, 0x0010 },
+			{ 0x05, 0x83dc },
+			{ 0x06, 0x087d },
+			{ 0x05, 0x8300 },
+			{ 0x06, 0x0101 },
+			{ 0x06, 0x05f8 },
+			{ 0x06, 0xf9fa },
+			{ 0x06, 0xfbef },
+			{ 0x06, 0x79e2 },
+			{ 0x06, 0x835f },
+			{ 0x06, 0xe0f8 },
+			{ 0x06, 0x9ae1 },
+			{ 0x06, 0xf89b },
+			{ 0x06, 0xef31 },
+			{ 0x06, 0x3b65 },
+			{ 0x06, 0xaa07 },
+			{ 0x06, 0x81e4 },
+			{ 0x06, 0xf89a },
+			{ 0x06, 0xe5f8 },
+			{ 0x06, 0x9baf },
+			{ 0x06, 0x06ae },
+			{ 0x05, 0x83dc },
+			{ 0x06, 0x8300 },
+		};
+
+		rtl_phy_write(ioaddr, phy_reg_init_1,
+			      ARRAY_SIZE(phy_reg_init_1));
+	}
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
 static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1565,6 +1640,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_24:
 		rtl8168cp_2_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_25:
+		rtl8168d_hw_phy_config(ioaddr);
+		break;
 
 	default:
 		break;
@@ -2595,6 +2673,19 @@ static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
+static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2666,6 +2757,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168cp_3(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_25:
+		rtl_hw_start_8168d(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

