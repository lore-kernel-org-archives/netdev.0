From: Alexander Graf <agraf@suse.de>
Subject: [PATCH v2 2/2] phy dp83867: Make rgmii parameters optional
Date: Mon, 16 May 2016 20:52:43 +0200
Message-ID: <1463424763-58807-2-git-send-email-agraf@suse.de>
References: <1463424763-58807-1-git-send-email-agraf@suse.de>
Cc: linux-kernel@vger.kernel.org, michal.simek@xilinx.com,
	Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463424763-58807-1-git-send-email-agraf@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If you compile without OF_MDIO support in an RGMII configuration, we fail
to configure the dp83867 phy today by writing garbage into its configuration
registers.

On the other hand if you do compile with OF_MDIO and the phy gets loaded via
device tree, you have to have the properties set in the device tree, otherwise
we fail to load the driver and don't even attach the generic phy driver to
the interface anymore.

To make things slightly more consistent, make the rgmii configuration properties
optional and allow a user to omit them in their device tree.

Signed-off-by: Alexander Graf <agraf@suse.de>
---
 drivers/net/phy/dp83867.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 94cc278..1b01680 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -65,6 +65,7 @@ struct dp83867_private {
 	int rx_id_delay;
 	int tx_id_delay;
 	int fifo_depth;
+	int values_are_sane;
 };
 
 static int dp83867_ack_interrupt(struct phy_device *phydev)
@@ -113,15 +114,30 @@ static int dp83867_of_init(struct phy_device *phydev)
 	ret = of_property_read_u32(of_node, "ti,rx-internal-delay",
 				   &dp83867->rx_id_delay);
 	if (ret)
-		return ret;
+		goto invalid_dt;
 
 	ret = of_property_read_u32(of_node, "ti,tx-internal-delay",
 				   &dp83867->tx_id_delay);
 	if (ret)
-		return ret;
+		goto invalid_dt;
 
-	return of_property_read_u32(of_node, "ti,fifo-depth",
+	ret = of_property_read_u32(of_node, "ti,fifo-depth",
 				   &dp83867->fifo_depth);
+	if (ret)
+		goto invalid_dt;
+
+	dp83867->values_are_sane = 1;
+
+	return 0;
+
+invalid_dt:
+	phydev_err(phydev, "missing properties in device tree");
+
+	/*
+	 * We can still run with a broken dt by not using any of the optional
+	 * parameters, so just don't set dp83867->values_are_sane.
+	 */
+	return 0;
 }
 #else
 static int dp83867_of_init(struct phy_device *phydev)
@@ -150,6 +166,15 @@ static int dp83867_config_init(struct phy_device *phydev)
 		dp83867 = (struct dp83867_private *)phydev->priv;
 	}
 
+	/*
+	 * With no or broken device tree, we don't have the values that we would
+	 * want to configure the phy with. In that case, cross our fingers and
+	 * assume that firmware did everything correctly for us or that we don't
+	 * need them.
+	 */
+	if (!dp83867->values_are_sane)
+		return 0;
+
 	if (phy_interface_is_rgmii(phydev)) {
 		ret = phy_write(phydev, MII_DP83867_PHYCTRL,
 			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
-- 
1.8.5.6
