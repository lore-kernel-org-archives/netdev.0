From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 08/13] r8169: remove dead wood
Date: Thu, 18 Oct 2007 23:01:45 +0200
Message-ID: <20071018210145.GI31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36944 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758569AbXJRVGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:06:53 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   66 +-------------------------------------------------
 1 files changed, 2 insertions(+), 64 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9deda50..3a3ba79 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -123,15 +123,6 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
 };
 
-enum phy_version {
-	RTL_GIGA_PHY_VER_C = 0x03, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_D = 0x04, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
-	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
-	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
-};
-
 #define _R(NAME,MAC,MASK) \
 	{ .name = NAME, .mac_version = MAC, .RxConfigMask = MASK }
 
@@ -406,7 +397,6 @@ struct rtl8169_private {
 	u32 msg_enable;
 	int chipset;
 	int mac_version;
-	int phy_version;
 	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
 	u32 dirty_rx;
@@ -1178,50 +1168,6 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_get_phy_version(struct rtl8169_private *tp,
-				    void __iomem *ioaddr)
-{
-	const struct {
-		u16 mask;
-		u16 set;
-		int phy_version;
-	} phy_info[] = {
-		{ 0x000f, 0x0002, RTL_GIGA_PHY_VER_G },
-		{ 0x000f, 0x0001, RTL_GIGA_PHY_VER_F },
-		{ 0x000f, 0x0000, RTL_GIGA_PHY_VER_E },
-		{ 0x0000, 0x0000, RTL_GIGA_PHY_VER_D } /* Catch-all */
-	}, *p = phy_info;
-	u16 reg;
-
-	reg = mdio_read(ioaddr, MII_PHYSID2) & 0xffff;
-	while ((reg & p->mask) != p->set)
-		p++;
-	tp->phy_version = p->phy_version;
-}
-
-static void rtl8169_print_phy_version(struct rtl8169_private *tp)
-{
-	struct {
-		int version;
-		char *msg;
-		u32 reg;
-	} phy_print[] = {
-		{ RTL_GIGA_PHY_VER_G, "RTL_GIGA_PHY_VER_G", 0x0002 },
-		{ RTL_GIGA_PHY_VER_F, "RTL_GIGA_PHY_VER_F", 0x0001 },
-		{ RTL_GIGA_PHY_VER_E, "RTL_GIGA_PHY_VER_E", 0x0000 },
-		{ RTL_GIGA_PHY_VER_D, "RTL_GIGA_PHY_VER_D", 0x0000 },
-		{ 0, NULL, 0x0000 }
-	}, *p;
-
-	for (p = phy_print; p->msg; p++) {
-		if (tp->phy_version == p->version) {
-			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
-			return;
-		}
-	}
-	dprintk("phy_version == Unknown\n");
-}
-
 static void rtl8169_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1259,12 +1205,9 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	unsigned int i;
 
 	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
-	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
-		return;
 
 	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
 	dprintk("Do final_reg2.cfg\n");
@@ -1309,7 +1252,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
-	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		return;
@@ -1344,8 +1286,7 @@ static inline void rtl8169_delete_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	del_timer_sync(timer);
@@ -1356,8 +1297,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -1675,10 +1615,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
-	rtl8169_get_phy_version(tp, ioaddr);
 
 	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
 
 	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
 		if (tp->mac_version == rtl_chip_info[i].mac_version)
-- 
1.5.2.4

