From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] Support for new rtl810x hardware
Date: Fri, 01 Aug 2008 17:24:42 +0200
Message-ID: <48932ABA.2000205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbYHAPZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 11:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The support is taken from Realtek's driver r8101 version 1.007.00.
I tested the patch on RTL8102EL hardware with success.

The patch is against r8169 branch of Francois's repository.

The code uses rtl8168_csi_access_enable, rtl8168_tx_performance_tweak
and rtl8168_ephy_init because the apropriate code in Realtek's driver
is pretty same. So it could be better to rename these functions
like rtl_csi_access_enable,... to avoid confusing.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dda27bd..83a5104 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -107,7 +107,10 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
 	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
 	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
-	RTL_GIGA_MAC_VER_23 = 0x17  // 8168CP
+	RTL_GIGA_MAC_VER_23 = 0x17, // 8168CP
+	RTL_GIGA_MAC_VER_24 = 0x18, // 8102E
+	RTL_GIGA_MAC_VER_25 = 0x19, // 8102EL
+	RTL_GIGA_MAC_VER_26 = 0x1a  // 8102EL
 };

 #define _R(NAME,MAC,MASK) \
@@ -136,7 +139,10 @@ static const struct {
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880)  // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880), // PCI-E
+	_R("RTL8102e",		RTL_GIGA_MAC_VER_24, 0xff7e1880), // PCI-E
+	_R("RTL8102el",		RTL_GIGA_MAC_VER_25, 0xff7e1880), // PCI-E
+	_R("RTL8102el",		RTL_GIGA_MAC_VER_26, 0xff7e1880), // PCI-E
 };
 #undef _R

@@ -823,11 +829,14 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		}
 	}

-	/* The 8100e/8101e do Fast Ethernet only. */
+	/* The 8100e/8101e/8102e(l) do Fast Ethernet only. */
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_24) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_25) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_26)) {
 		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
 		    netif_msg_link(tp)) {
 			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
@@ -1241,6 +1250,12 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
 		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
 		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7cf00000, 0x34800000,       RTL_GIGA_MAC_VER_24 },
+		{ 0x7cf00000, 0x24800000,       RTL_GIGA_MAC_VER_24 },
+		{ 0x7cf00000, 0x34900000,       RTL_GIGA_MAC_VER_25 },
+		{ 0x7cf00000, 0x24900000,       RTL_GIGA_MAC_VER_25 },
+		{ 0x7c800000, 0x34800000,       RTL_GIGA_MAC_VER_26 },
+		{ 0x7c800000, 0x24800000,       RTL_GIGA_MAC_VER_26 },
 		/* FIXME: where did these entries come from ? -- FR */
 		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
 		{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
@@ -1486,6 +1501,34 @@ static void rtl8168cy_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }

+static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0003 },
+		{ 0x07, 0xa17b },
+		{ 0x04, 0xc066 },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 }
+	};
+		
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	mdio_patch(ioaddr, 0x11, 0x1000);
+	mdio_patch(ioaddr, 0x19, 0x2000);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8102el_hw_phy_config(void __iomem *ioaddr)
+{
+       struct phy_reg phy_reg_init[] = {
+               { 0x1f, 0x0000 },
+               { 0x11, 0x15c0 },
+               { 0x19, 0x2080 },
+               { 0x1f, 0x0000 },
+       };
+
+       rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1530,6 +1573,13 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_23:
 		rtl8168cy_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_24:
+		rtl8102e_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_25:
+	case RTL_GIGA_MAC_VER_26:
+		rtl8102el_hw_phy_config(ioaddr);
+		break;

 	default:
 		break;
@@ -2548,6 +2598,54 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }

+static void rtl_hw_start_8101e(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8101e[] = {
+		{ 0x01,	0,	0x6e65 },
+		{ 0x02,	0,	0x091f },
+		{ 0x03,	0,	0xc2f9 },
+		{ 0x06,	0,	0xafb5 },
+		{ 0x07,	0,	0x0e00 },
+		{ 0x19,	0,	0xec80 },
+		{ 0x01,	0,	0x2e65 },
+		{ 0x01,	0,	0x6e65 }
+	};
+	u8 cfg1;
+
+	rtl8168_csi_access_enable(ioaddr);
+
+	rtl8168_tx_performance_tweak(pdev, 0x5000);
+
+	RTL_W8(Config1, 0xdf);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	cfg1 = RTL_R8(Config1);
+	if ((cfg1 & LEDS0) && (cfg1 & LEDS1))
+		RTL_W8(Config1, RTL_R8(Config1) & ~(LEDS0));
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) &
+		~((1 << 15) | (1 << 14) | (1 << 12) | (1 << 11) |
+		  (1 << 10) | (1 <<  9) | (1 <<  8) | (1 <<  7) |
+		  (1 <<  4) | (1 <<  3)));
+
+	rtl8168_ephy_init(ioaddr, e_info_8101e, ARRAY_SIZE(e_info_8101e));
+}
+
+static void rtl_hw_start_8102el(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl8168_csi_access_enable(ioaddr);
+
+	rtl8168_tx_performance_tweak(pdev, 0x5000);
+
+	RTL_W8(Config1, 0x0f);
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) &
+		~((1 << 15) | (1 << 14) | (1 << 12) | (1 << 11) |
+		  (1 << 10) | (1 <<  9) | (1 <<  8) | (1 <<  7) |
+		  (1 <<  4) | (1 <<  3)));
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2564,6 +2662,21 @@ static void rtl_hw_start_8101(struct net_device *dev)
 		}
 	}

+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_24:
+		rtl_hw_start_8101e(ioaddr, pdev);
+		break;
+
+	case RTL_GIGA_MAC_VER_25:
+		rtl_hw_start_8102el(ioaddr, pdev);
+		rtl8168_ephy_write(ioaddr, 0x03, 0xc2f9);
+		break;
+
+	case RTL_GIGA_MAC_VER_26:
+		rtl_hw_start_8102el(ioaddr, pdev);
+		break;
+	}
+
 	RTL_W8(Cfg9346, Cfg9346_Unlock);

 	RTL_W8(EarlyTxThres, EarlyTxThld);
