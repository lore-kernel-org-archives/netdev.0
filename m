From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v3 2/4] net: phy: dp83867: add support for MAC impedance configuration
Date: Thu, 6 Oct 2016 10:43:53 +0530
Message-ID: <20161006051355.15947-3-mugunthanvnm@ti.com>
References: <20161006051355.15947-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Russell King <linux@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sekhar Nori <nsekhar@ti.com>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161006051355.15947-1-mugunthanvnm@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for programmable MAC impedance configuration

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/dp83867.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 91177a4..1b63924 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -33,6 +33,7 @@
 /* Extended Registers */
 #define DP83867_RGMIICTL	0x0032
 #define DP83867_RGMIIDCTL	0x0086
+#define DP83867_IO_MUX_CFG	0x0170
 
 #define DP83867_SW_RESET	BIT(15)
 #define DP83867_SW_RESTART	BIT(14)
@@ -62,10 +63,17 @@
 /* RGMIIDCTL bits */
 #define DP83867_RGMII_TX_CLK_DELAY_SHIFT	4
 
+/* IO_MUX_CFG bits */
+#define DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL	0x1f
+
+#define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX	0x0
+#define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MIN	0x1f
+
 struct dp83867_private {
 	int rx_id_delay;
 	int tx_id_delay;
 	int fifo_depth;
+	int io_impedance;
 };
 
 static int dp83867_ack_interrupt(struct phy_device *phydev)
@@ -111,6 +119,14 @@ static int dp83867_of_init(struct phy_device *phydev)
 	if (!of_node)
 		return -ENODEV;
 
+	dp83867->io_impedance = -EINVAL;
+
+	/* Optional configuration */
+	if (of_property_read_bool(of_node, "ti,max-output-impedance"))
+		dp83867->io_impedance = DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX;
+	else if (of_property_read_bool(of_node, "ti,min-output-impedance"))
+		dp83867->io_impedance = DP83867_IO_MUX_CFG_IO_IMPEDANCE_MIN;
+
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
 	if (ret)
@@ -184,6 +200,18 @@ static int dp83867_config_init(struct phy_device *phydev)
 
 		phy_write_mmd_indirect(phydev, DP83867_RGMIIDCTL,
 				       DP83867_DEVADDR, delay);
+
+		if (dp83867->io_impedance >= 0) {
+			val = phy_read_mmd_indirect(phydev, DP83867_IO_MUX_CFG,
+						    DP83867_DEVADDR);
+
+			val &= ~DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
+			val |= dp83867->io_impedance &
+			       DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
+
+			phy_write_mmd_indirect(phydev, DP83867_IO_MUX_CFG,
+					       DP83867_DEVADDR, val);
+		}
 	}
 
 	return 0;
-- 
2.10.0.372.g6fe1b14
