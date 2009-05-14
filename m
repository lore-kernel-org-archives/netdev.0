From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: allow true forced mode setting
Date: Thu, 14 May 2009 23:46:05 +0200
Message-ID: <20090514214605.GB6374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vincent Steenhoute <vsteenhoute@novell.com>,
	Jean Delvare <jdelvare@suse.de>,
	Martin Michlmayr <tbm@cyrius.com>,
	Xose Vazquez Perez <xose.vazquez@gmail.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47058 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752592AbZENVpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 17:45:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to mostly historic reasons, including a lack of reliability
of the link handling (especially with the older 8169), the
current r8169 driver emulates forced mode setting by limiting
the advertised modes.

With this change the driver allows real 10/100 forced mode
settings on the 8169 and 8101/8102.

Original idea by Vincent Steenhoute. The RTL_GIGA_MAC_VER_03
tweak was extracted from Realtek's v6.009.00 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jean Delvare <jdelvare@suse.de>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |  111 ++++++++++++++++++++++++++------------------------
 1 files changed, 58 insertions(+), 53 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f86bf31..81ab2f0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -843,75 +843,80 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	int auto_nego, giga_ctrl;
-
-	auto_nego = mdio_read(ioaddr, MII_ADVERTISE);
-	auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
-		       ADVERTISE_100HALF | ADVERTISE_100FULL);
-	giga_ctrl = mdio_read(ioaddr, MII_CTRL1000);
-	giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+	int giga_ctrl, bmcr;
 
 	if (autoneg == AUTONEG_ENABLE) {
+		int auto_nego;
+
+		auto_nego = mdio_read(ioaddr, MII_ADVERTISE);
 		auto_nego |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
 			      ADVERTISE_100HALF | ADVERTISE_100FULL);
-		giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-	} else {
-		if (speed == SPEED_10)
-			auto_nego |= ADVERTISE_10HALF | ADVERTISE_10FULL;
-		else if (speed == SPEED_100)
-			auto_nego |= ADVERTISE_100HALF | ADVERTISE_100FULL;
-		else if (speed == SPEED_1000)
-			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-
-		if (duplex == DUPLEX_HALF)
-			auto_nego &= ~(ADVERTISE_10FULL | ADVERTISE_100FULL);
-
-		if (duplex == DUPLEX_FULL)
-			auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_100HALF);
+		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-		/* This tweak comes straight from Realtek's driver. */
-		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
-		    ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-		     (tp->mac_version == RTL_GIGA_MAC_VER_16))) {
-			auto_nego = ADVERTISE_100HALF | ADVERTISE_CSMA;
-		}
-	}
+		giga_ctrl = mdio_read(ioaddr, MII_CTRL1000);
+		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
-	/* The 8100e/8101e/8102e do Fast Ethernet only. */
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_07) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_08) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_09) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_10) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
-		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
-		    netif_msg_link(tp)) {
+		/* The 8100e/8101e/8102e do Fast Ethernet only. */
+		if ((tp->mac_version != RTL_GIGA_MAC_VER_07) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_08) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_09) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_10) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_13) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
+		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
+			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
+		} else if (netif_msg_link(tp)) {
 			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
 			       dev->name);
 		}
-		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
-	}
 
-	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
+
+		if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+		    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+		    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
+			/*
+			 * Wake up the PHY.
+			 * Vendor specific (0x1f) and reserved (0x0e) MII
+			 * registers.
+			 */
+			mdio_write(ioaddr, 0x1f, 0x0000);
+			mdio_write(ioaddr, 0x0e, 0x0000);
+		}
+
+		mdio_write(ioaddr, MII_ADVERTISE, auto_nego);
+		mdio_write(ioaddr, MII_CTRL1000, giga_ctrl);
+	} else {
+		giga_ctrl = 0;
+
+		if (speed == SPEED_10)
+			bmcr = 0;
+		else if (speed == SPEED_100)
+			bmcr = BMCR_SPEED100;
+		else
+			return -EINVAL;
+
+		if (duplex == DUPLEX_FULL)
+			bmcr |= BMCR_FULLDPLX;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
-		/*
-		 * Wake up the PHY.
-		 * Vendor specific (0x1f) and reserved (0x0e) MII registers.
-		 */
 		mdio_write(ioaddr, 0x1f, 0x0000);
-		mdio_write(ioaddr, 0x0e, 0x0000);
 	}
 
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
-	mdio_write(ioaddr, MII_ADVERTISE, auto_nego);
-	mdio_write(ioaddr, MII_CTRL1000, giga_ctrl);
-	mdio_write(ioaddr, MII_BMCR, BMCR_ANENABLE | BMCR_ANRESTART);
+	mdio_write(ioaddr, MII_BMCR, bmcr);
+
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_03) {
+		if ((speed == SPEED_100) && (autoneg != AUTONEG_ENABLE)) {
+			mdio_write(ioaddr, 0x17, 0x2138);
+			mdio_write(ioaddr, 0x0e, 0x0260);
+		} else {
+			mdio_write(ioaddr, 0x17, 0x2108);
+			mdio_write(ioaddr, 0x0e, 0x0000);
+		}
+	}
+
 	return 0;
 }
 
-- 
1.6.0.6

