From: <Mario_Limonciello@Dell.com>
Subject: [PATCH] Setup PHYs for rtl8101/2(e) hardware
Date: Wed, 2 Jul 2008 01:24:10 -0500
Message-ID: <E6FF208A16840D4EBAA31D261B15A50601415DC7@ausx3mpc121.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>, <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:55938 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582AbYGBG2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 02:28:36 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello:

In comparing the differences with the Realtek release r8101-1.008.05-1 of their r8101 driver, I found a handful of differences in  the startup procedures of the r8169 driver.  I isolated two sets of fixes that get rid of transient errors when loading the drivers.

Signed-off-by: Mario Limonciello <Mario_Limonciello@Dell.com> <mailto:Mario_Limonciello@Dell.com> 
---
 drivers/net/r8169.c |   29 +++++++++++++++++++++++++++--
 1 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4c5a875..89def08 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1139,6 +1139,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
         { 0x7cf00000, 0x34000000,    RTL_GIGA_MAC_VER_13 },
         { 0x7cf00000, 0x34200000,    RTL_GIGA_MAC_VER_16 },
         { 0x7c800000, 0x34000000,    RTL_GIGA_MAC_VER_16 },
+        /* 8101E */
+        { 0x7c800000, 0x24800000,    RTL_GIGA_MAC_VER_16 },
+        /* 8102E */
+        { 0x7c800000, 0x34800000,    RTL_GIGA_MAC_VER_16 },
         /* FIXME: where did these entries come from ? -- FR */
         { 0xfc800000, 0x38800000,    RTL_GIGA_MAC_VER_15 },
         { 0xfc800000, 0x30800000,    RTL_GIGA_MAC_VER_14 },
@@ -1299,6 +1303,21 @@ static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
     rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8101_hw_phy_config(void __iomem *ioaddr)
+{
+    struct phy_reg phy_reg_init[] = {
+        { 0x1f, 0x0000 },
+        { 0x11, mdio_read(ioaddr,0x11) | 0x1000 },
+        { 0x19, mdio_read(ioaddr,0x19) | 0x2000 },
+        { 0x1f, 0x0003 },
+        { 0x08, 0x441D },
+        { 0x01, 0xc066 },
+        { 0x1f, 0x0000 }
+    };
+
+    rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
     struct rtl8169_private *tp = netdev_priv(dev);
@@ -1316,6 +1335,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
     case RTL_GIGA_MAC_VER_04:
         rtl8169sb_hw_phy_config(ioaddr);
         break;
+    case RTL_GIGA_MAC_VER_13:
+    case RTL_GIGA_MAC_VER_16:
+        rtl8101_hw_phy_config(ioaddr);
     case RTL_GIGA_MAC_VER_18:
         rtl8168cp_hw_phy_config(ioaddr);
         break;
@@ -1438,8 +1460,11 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
     rtl_hw_phy_config(dev);
 
-    dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
-    RTL_W8(0x82, 0x01);
+    if (tp->mac_version != RTL_GIGA_MAC_VER_13 && tp->mac_version != RTL_GIGA_MAC_VER_16)
+    {
+        dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+        RTL_W8(0x82, 0x01);
+    }
 
     pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 
-- 


