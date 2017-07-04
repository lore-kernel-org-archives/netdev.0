From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 2/2] net: phy: dp83867: add workaround for incorrect RX_CTRL pin strap
Date: Tue, 4 Jul 2017 16:23:24 +0530
Message-ID: <ec36b7bd213daca6b319d854799fb86ee794d0e8.1499162046.git.nsekhar@ti.com>
References: <cover.1499162046.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Device Tree Mailing List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Linux OMAP Mailing List <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1499162046.git.nsekhar-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>

The data manual for DP83867IR/CR, SNLS484E[1], revised march 2017,
advises that strapping RX_DV/RX_CTRL pin in mode 1 and 2 is not
supported (see note below Table 5 (4-Level Strap Pins)).

There are some boards which have the pin strapped this way and need
software workaround suggested by the data manual. Bit[7] of
Configuration Register 4 (address 0x0031) must be cleared to 0. This
ensures proper operation of the PHY.

Implement driver support for device-tree property meant to advertise
the wrong strapping.

[1] http://www.ti.com/lit/ds/snls484e/snls484e.pdf

Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
[nsekhar-l0cyMroinI0@public.gmane.org: rebase to mainline, code simplification]
Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
---
 drivers/net/phy/dp83867.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index b57f20e552ba..c1ab976cc800 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -91,6 +91,7 @@ struct dp83867_private {
 	int fifo_depth;
 	int io_impedance;
 	int port_mirroring;
+	bool rxctrl_strap_quirk;
 };
 
 static int dp83867_ack_interrupt(struct phy_device *phydev)
@@ -164,6 +165,9 @@ static int dp83867_of_init(struct phy_device *phydev)
 	else if (of_property_read_bool(of_node, "ti,min-output-impedance"))
 		dp83867->io_impedance = DP83867_IO_MUX_CFG_IO_IMPEDANCE_MIN;
 
+	dp83867->rxctrl_strap_quirk = of_property_read_bool(of_node,
+					"ti,dp83867-rxctrl-strap-quirk");
+
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
 	if (ret &&
@@ -214,6 +218,13 @@ static int dp83867_config_init(struct phy_device *phydev)
 		dp83867 = (struct dp83867_private *)phydev->priv;
 	}
 
+	/* RX_DV/RX_CTRL strapped in mode 1 or mode 2 workaround */
+	if (dp83867->rxctrl_strap_quirk) {
+		val = phy_read_mmd(phydev, DP83867_DEVADDR, DP83867_CFG4);
+		val &= ~BIT(7);
+		phy_write_mmd(phydev, DP83867_DEVADDR, DP83867_CFG4, val);
+	}
+
 	if (phy_interface_is_rgmii(phydev)) {
 		val = phy_read(phydev, MII_DP83867_PHYCTRL);
 		if (val < 0)
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
