From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 06/10] net: phy: micrel: add support for clock-mode select to KSZ8081/KSZ8091
Date: Wed, 19 Nov 2014 12:59:19 +0100
Message-ID: <1416398363-32306-7-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micrel KSZ8081 and KSZ8091 PHYs have the RMII Reference Clock Select
bit, which is used to select 25 or 50 MHz clock mode.

Note that on some revisions of the PHY (e.g. KSZ8081RND) the function of
this bit is inverted so that setting it enables 25 rather than 50 MHz
mode. Add a new device-tree property
"micrel,rmii-reference-clock-select-25-mhz" to describe this.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 Documentation/devicetree/bindings/net/micrel.txt |  4 ++--
 drivers/net/phy/micrel.c                         | 11 ++++++-----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index 30062fae5623..a1bab5eaae02 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -22,5 +22,5 @@ Optional properties:
  - clocks, clock-names: contains clocks according to the common clock bindings.
 
               supported clocks:
-	      - KSZ8021, KSZ8031: "rmii-ref": The RMII refence input clock. Used
-		to determine the XI input clock.
+	      - KSZ8021, KSZ8031, KSZ8081, KSZ8091: "rmii-ref": The RMII
+		refence input clock. Used to determine the XI input clock.
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index d2e790cd3651..04fbee846b66 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -102,6 +102,7 @@ static const struct kszphy_type ksz8051_type = {
 static const struct kszphy_type ksz8081_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
 	.has_broadcast_disable	= true,
+	.has_rmii_ref_clk_sel	= true,
 };
 
 static int kszphy_extended_write(struct phy_device *phydev,
@@ -548,16 +549,16 @@ static int kszphy_probe(struct phy_device *phydev)
 	clk = devm_clk_get(&phydev->dev, "rmii-ref");
 	if (!IS_ERR(clk)) {
 		unsigned long rate = clk_get_rate(clk);
+		bool rmii_ref_clk_sel_25_mhz;
 
 		priv->rmii_ref_clk_sel = type->has_rmii_ref_clk_sel;
+		rmii_ref_clk_sel_25_mhz = of_property_read_bool(np,
+				"micrel,rmii-reference-clock-select-25-mhz");
 
-		/* FIXME: add support for PHY revisions that have this bit
-		 * inverted (e.g. through new property or based on PHY ID).
-		 */
 		if (rate > 24500000 && rate < 25500000) {
-			priv->rmii_ref_clk_sel_val = false;
+			priv->rmii_ref_clk_sel_val = rmii_ref_clk_sel_25_mhz;
 		} else if (rate > 49500000 && rate < 50500000) {
-			priv->rmii_ref_clk_sel_val = true;
+			priv->rmii_ref_clk_sel_val = !rmii_ref_clk_sel_25_mhz;
 		} else {
 			dev_err(&phydev->dev, "Clock rate out of range: %ld\n", rate);
 			return -EINVAL;
-- 
2.0.4
