From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy registers directly
Date: Fri, 28 Jul 2017 17:11:57 +0200
Message-ID: <20170728151157.28983-5-privat@egil-hjelmeland.no>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Indirect access (PMI) to phy register only work in I2C mode. In
MDIO mode phy registers must be accessed directly. Introduced
struct lan9303_phy_ops to handle the two modes.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 20 +++++++++++++-------
 drivers/net/dsa/lan9303.h      | 11 +++++++++++
 drivers/net/dsa/lan9303_i2c.c  |  2 ++
 drivers/net/dsa/lan9303_mdio.c | 21 +++++++++++++++++++++
 4 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 9427c3b0ced2..9910fc9d5dd6 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -334,6 +334,12 @@ static int lan9303_indirect_phy_write(struct lan9303 *chip, int addr,
 	return ret;
 }
 
+const struct lan9303_phy_ops lan9303_indirect_phy_ops = {
+	.phy_read = lan9303_indirect_phy_read,
+	.phy_write = lan9303_indirect_phy_write,
+};
+EXPORT_SYMBOL(lan9303_indirect_phy_ops);
+
 static int lan9303_switch_wait_for_completion(struct lan9303 *chip)
 {
 	int ret, i;
@@ -435,7 +441,7 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
 	 * 0xffff is returned on MDIO read with no response.
 	 */
-	reg = lan9303_indirect_phy_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
+	reg = chip->ops->phy_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
 	if (reg < 0) {
 		dev_err(chip->dev, "Failed to detect phy config: %d\n", reg);
 		return reg;
@@ -726,7 +732,7 @@ static int lan9303_phy_read(struct dsa_switch *ds, int phy, int regnum)
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_indirect_phy_read(chip, phy, regnum);
+	return chip->ops->phy_read(chip, phy, regnum);
 }
 
 static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
@@ -740,7 +746,7 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_indirect_phy_write(chip, phy, regnum, val);
+	return chip->ops->phy_write(chip, phy, regnum, val);
 }
 
 static int lan9303_port_enable(struct dsa_switch *ds, int port,
@@ -773,13 +779,13 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
-		lan9303_indirect_phy_write(chip, chip->phy_addr_sel_strap + 1,
-					   MII_BMCR, BMCR_PDOWN);
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
+				  MII_BMCR, BMCR_PDOWN);
 		break;
 	case 2:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
-		lan9303_indirect_phy_write(chip, chip->phy_addr_sel_strap + 2,
-					   MII_BMCR, BMCR_PDOWN);
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
+				  MII_BMCR, BMCR_PDOWN);
 		break;
 	default:
 		dev_dbg(chip->dev,
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index d1512dad2d90..4d8be555ff4d 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -2,6 +2,15 @@
 #include <linux/device.h>
 #include <net/dsa.h>
 
+struct lan9303;
+
+struct lan9303_phy_ops {
+	/* PHY 1 and 2 access*/
+	int	(*phy_read)(struct lan9303 *chip, int port, int regnum);
+	int	(*phy_write)(struct lan9303 *chip, int port,
+			     int regnum, u16 val);
+};
+
 struct lan9303 {
 	struct device *dev;
 	struct regmap *regmap;
@@ -11,9 +20,11 @@ struct lan9303 {
 	bool phy_addr_sel_strap;
 	struct dsa_switch *ds;
 	struct mutex indirect_mutex; /* protect indexed register access */
+	const struct lan9303_phy_ops *ops;
 };
 
 extern const struct regmap_access_table lan9303_register_set;
+extern const struct lan9303_phy_ops lan9303_indirect_phy_ops;
 
 int lan9303_probe(struct lan9303 *chip, struct device_node *np);
 int lan9303_remove(struct lan9303 *chip);
diff --git a/drivers/net/dsa/lan9303_i2c.c b/drivers/net/dsa/lan9303_i2c.c
index ab3ce0da5071..24ec20f7f444 100644
--- a/drivers/net/dsa/lan9303_i2c.c
+++ b/drivers/net/dsa/lan9303_i2c.c
@@ -63,6 +63,8 @@ static int lan9303_i2c_probe(struct i2c_client *client,
 	i2c_set_clientdata(client, sw_dev);
 	sw_dev->chip.dev = &client->dev;
 
+	sw_dev->chip.ops = &lan9303_indirect_phy_ops;
+
 	ret = lan9303_probe(&sw_dev->chip, client->dev.of_node);
 	if (ret != 0)
 		return ret;
diff --git a/drivers/net/dsa/lan9303_mdio.c b/drivers/net/dsa/lan9303_mdio.c
index 2db7970fc88c..fc16668a487f 100644
--- a/drivers/net/dsa/lan9303_mdio.c
+++ b/drivers/net/dsa/lan9303_mdio.c
@@ -67,6 +67,25 @@ static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
 	return 0;
 }
 
+int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int reg, u16 val)
+{
+	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
+
+	return mdiobus_write_nested(sw_dev->device->bus, phy, reg, val);
+}
+
+int lan9303_mdio_phy_read(struct lan9303 *chip, int phy,  int reg)
+{
+	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
+
+	return mdiobus_read_nested(sw_dev->device->bus, phy, reg);
+}
+
+static const struct lan9303_phy_ops lan9303_mdio_phy_ops = {
+	.phy_read = lan9303_mdio_phy_read,
+	.phy_write = lan9303_mdio_phy_write,
+};
+
 static const struct regmap_config lan9303_mdio_regmap_config = {
 	.reg_bits = 8,
 	.val_bits = 32,
@@ -108,6 +127,8 @@ static int lan9303_mdio_probe(struct mdio_device *mdiodev)
 	dev_set_drvdata(&mdiodev->dev, sw_dev);
 	sw_dev->chip.dev = &mdiodev->dev;
 
+	sw_dev->chip.ops = &lan9303_mdio_phy_ops;
+
 	ret = lan9303_probe(&sw_dev->chip, mdiodev->dev.of_node);
 	if (ret != 0)
 		return ret;
-- 
2.11.0
