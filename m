From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 15/22] net: phy: micrel: parse of nodes at probe
Date: Tue, 11 Nov 2014 18:37:33 +0100
Message-ID: <1415727460-20417-16-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Parse the "micrel,led-mode" property at probe, rather than at config_init
time in the led-setup helper itself.

Note that the bogus parent->of_node bit is removed.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 189fddb829bc..928248187a11 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -79,6 +79,7 @@ struct kszphy_type {
 
 struct kszphy_priv {
 	const struct kszphy_type *type;
+	int led_mode;
 };
 
 static const struct kszphy_type ksz8021_type = {
@@ -186,24 +187,9 @@ static int ks8737_config_intr(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
-static int kszphy_setup_led(struct phy_device *phydev, u32 reg)
+static int kszphy_setup_led(struct phy_device *phydev, u32 reg, int val)
 {
-
-	struct device *dev = &phydev->dev;
-	struct device_node *of_node = dev->of_node;
 	int rc, temp, shift;
-	u32 val;
-
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
-
-	if (of_property_read_u32(of_node, "micrel,led-mode", &val))
-		return 0;
-
-	if (val > 3) {
-		dev_err(&phydev->dev, "invalid led mode: 0x%02x\n", val);
-		return -EINVAL;
-	}
 
 	switch (reg) {
 	case MII_KSZPHY_CTRL_1:
@@ -261,8 +247,8 @@ static int kszphy_config_init(struct phy_device *phydev)
 
 	type = priv->type;
 
-	if (type->led_mode_reg)
-		kszphy_setup_led(phydev, type->led_mode_reg);
+	if (priv->led_mode >= 0)
+		kszphy_setup_led(phydev, type->led_mode_reg, priv->led_mode);
 
 	return 0;
 }
@@ -531,7 +517,9 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 static int kszphy_probe(struct phy_device *phydev)
 {
 	const struct kszphy_type *type = phydev->drv->driver_data;
+	struct device_node *np = phydev->dev.of_node;
 	struct kszphy_priv *priv;
+	int ret;
 
 	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
@@ -541,6 +529,21 @@ static int kszphy_probe(struct phy_device *phydev)
 
 	priv->type = type;
 
+	if (type->led_mode_reg) {
+		ret = of_property_read_u32(np, "micrel,led-mode",
+				&priv->led_mode);
+		if (ret)
+			priv->led_mode = -1;
+
+		if (priv->led_mode > 3) {
+			dev_err(&phydev->dev, "invalid led mode: 0x%02x\n",
+					priv->led_mode);
+			priv->led_mode = -1;
+		}
+	} else {
+		priv->led_mode = -1;
+	}
+
 	return 0;
 }
 
-- 
2.0.4
