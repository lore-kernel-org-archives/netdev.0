From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 09/13] r8169: make room for more phy init changes
Date: Thu, 18 Oct 2007 23:01:55 +0200
Message-ID: <20071018210155.GJ31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36947 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754783AbXJRVHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:07:17 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code is reworked to easily add phy-dependant init changes.
No change of behavior should be noticed.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   56 ++++++++++++++++++++++++++++----------------------
 1 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3a3ba79..aed36b7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1168,10 +1168,8 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_hw_phy_config(struct net_device *dev)
+static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	struct {
 		u16 regs[5]; /* Beware of bit-sign propagation */
 	} phy_magic[5] = { {
@@ -1204,27 +1202,6 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	}, *p = phy_magic;
 	unsigned int i;
 
-	rtl8169_print_mac_version(tp);
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-
-	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
-	dprintk("Do final_reg2.cfg\n");
-
-	/* Shazam ! */
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
-		mdio_write(ioaddr, 31, 0x0002);
-		mdio_write(ioaddr,  1, 0x90d0);
-		mdio_write(ioaddr, 31, 0x0000);
-		return;
-	}
-
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
-		return;
-
 	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
 	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
 	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
@@ -1243,6 +1220,35 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
 }
 
+static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
+{
+	mdio_write(ioaddr, 31, 0x0002);
+	mdio_write(ioaddr,  1, 0x90d0);
+	mdio_write(ioaddr, 31, 0x0000);
+}
+
+static void rtl_hw_phy_config(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl8169_print_mac_version(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01:
+		break;
+	case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03:
+		rtl8169s_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_04:
+		rtl8169sb_hw_phy_config(ioaddr);
+		break;
+	default:
+		break;
+	}
+}
+
 static void rtl8169_phy_timer(unsigned long __opaque)
 {
 	struct net_device *dev = (struct net_device *)__opaque;
@@ -1349,7 +1355,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl8169_hw_phy_config(dev);
+	rtl_hw_phy_config(dev);
 
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
-- 
1.5.2.4

