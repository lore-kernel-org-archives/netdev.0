From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 12/14] r8169: support additional 8168cp chipset
Date: Fri, 10 Oct 2008 23:47:09 +0200
Message-ID: <20081010214709.GL27195@electric-eye.fr.zoreil.com>
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
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34004 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759270AbYJJVrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:47:48 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taken from Realtek's 8.007.00 r8168 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Fixed-by: Ivan Vecera <ivecera@redhat.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4edc6b0..96b9b0b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -112,7 +112,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
 	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
 	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
-	RTL_GIGA_MAC_VER_23 = 0x17  // 8168CP
+	RTL_GIGA_MAC_VER_23 = 0x17, // 8168CP
+	RTL_GIGA_MAC_VER_24 = 0x18  // 8168CP
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -145,7 +146,8 @@ static const struct {
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880)  // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -1223,9 +1225,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168C family. */
+		{ 0x7cf00000, 0x3ca00000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
-		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_23 },
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
 		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
@@ -1559,6 +1562,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168c_4_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
 		rtl8168cp_2_hw_phy_config(ioaddr);
 		break;
 
@@ -2532,6 +2536,22 @@ static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
+static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	/* Magic. */
+	RTL_W8(DBG_REG, 0x20);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
 static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
 	static struct ephy_info e_info_8168c_1[] = {
@@ -2642,6 +2662,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168cp_2(ioaddr, pdev);
 	break;
 
+	case RTL_GIGA_MAC_VER_24:
+		rtl_hw_start_8168cp_3(ioaddr, pdev);
+	break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
-- 
1.5.3.3

