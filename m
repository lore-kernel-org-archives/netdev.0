From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/3] net: phy: dp83867: add support for MAC impedance configuration
Date: Wed, 20 Jul 2016 20:26:13 +0530
Message-ID: <20160720145614.13132-3-mugunthanvnm@ti.com>
References: <20160720145614.13132-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@armlinux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>, <devicetree@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:60043 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754501AbcGTO5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 10:57:18 -0400
In-Reply-To: <20160720145614.13132-1-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for programmable MAC impedance configuration

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/dp83867.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 91177a4..ace3558 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -33,6 +33,7 @@
 /* Extended Registers */
 #define DP83867_RGMIICTL	0x0032
 #define DP83867_RGMIIDCTL	0x0086
+#define DP83867_IO_MUX_CFG	0x0170
 
 #define DP83867_SW_RESET	BIT(15)
 #define DP83867_SW_RESTART	BIT(14)
@@ -62,10 +63,14 @@
 /* RGMIIDCTL bits */
 #define DP83867_RGMII_TX_CLK_DELAY_SHIFT	4
 
+/* IO_MUX_CFG bits */
+#define DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL	0x1F
+
 struct dp83867_private {
 	int rx_id_delay;
 	int tx_id_delay;
 	int fifo_depth;
+	int io_impedance;
 };
 
 static int dp83867_ack_interrupt(struct phy_device *phydev)
@@ -111,6 +116,12 @@ static int dp83867_of_init(struct phy_device *phydev)
 	if (!of_node)
 		return -ENODEV;
 
+	dp83867->io_impedance = -EINVAL;
+
+	/* Optional configuration */
+	of_property_read_u32(of_node, "ti,impedance-control",
+			     &dp83867->io_impedance);
+
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
 	if (ret)
@@ -184,6 +195,17 @@ static int dp83867_config_init(struct phy_device *phydev)
 
 		phy_write_mmd_indirect(phydev, DP83867_RGMIIDCTL,
 				       DP83867_DEVADDR, delay);
+
+		if (dp83867->io_impedance >= 0) {
+			val = phy_read_mmd_indirect(phydev,
+						    DP83867_IO_MUX_CFG,
+						    DP83867_DEVADDR);
+			val &= ~DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
+			val |= dp83867->io_impedance &
+			       DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
+			phy_write_mmd_indirect(phydev, DP83867_IO_MUX_CFG,
+					       DP83867_DEVADDR, val);
+		}
 	}
 
 	return 0;
-- 
2.9.2.368.g08bb350
