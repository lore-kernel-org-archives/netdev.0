From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 01/13] net: dsa: lan9303: Fixed MDIO interface
Date: Wed, 7 Jun 2017 13:38:41 +0200
Message-ID: <d9d0c4972c784ad2a56ee2f2a67bb690@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes after testing on actual HW:

- lan9303_mdio_write()/_read() must multiply register number
  by 4 to get offset

- Indirect access (PMI) to phy register only work in I2C mode. In
  MDIO mode phy registers must be accessed directly. Introduced
  struct lan9303_phy_ops to handle the two modes. Renamed functions
  to clarify.

- lan9303_detect_phy_setup() : Failed MDIO read return 0xffff.
  Handle that.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 42 +++++++++++++++++++++++++++---------------
 drivers/net/dsa/lan9303.h      | 11 +++++++++++
 drivers/net/dsa/lan9303_i2c.c  |  2 ++
 drivers/net/dsa/lan9303_mdio.c | 34 ++++++++++++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index cd76e61f1fca..e622db586c3d 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -20,6 +20,9 @@
 
 #include "lan9303.h"
 
+/* 13.2 System Control and Status Registers
+ * Multiply register number by 4 to get address offset.
+ */
 #define LAN9303_CHIP_REV 0x14
 # define LAN9303_CHIP_ID 0x9303
 #define LAN9303_IRQ_CFG 0x15
@@ -53,6 +56,9 @@
 #define LAN9303_VIRT_PHY_BASE 0x70
 #define LAN9303_VIRT_SPECIAL_CTRL 0x77
 
+/*13.4 Switch Fabric Control and Status Registers
+ * Accessed indirectly via SWITCH_CSR_CMD, SWITCH_CSR_DATA.
+ */
 #define LAN9303_SW_DEV_ID 0x0000
 #define LAN9303_SW_RESET 0x0001
 #define LAN9303_SW_RESET_RESET BIT(0)
@@ -242,7 +248,7 @@ static int lan9303_virt_phy_reg_write(struct lan9303 *chip, int regnum, u16 val)
 	return regmap_write(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, val);
 }
 
-static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
+static int lan9303_indirect_phy_wait_for_completion(struct lan9303 *chip)
 {
 	int ret, i;
 	u32 reg;
@@ -262,7 +268,7 @@ static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
 	return -EIO;
 }
 
-static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
+static int lan9303_indirect_phy_read(struct lan9303 *chip, int addr, int regnum)
 {
 	int ret;
 	u32 val;
@@ -272,7 +278,7 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 
 	mutex_lock(&chip->indirect_mutex);
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -281,7 +287,7 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 	if (ret)
 		goto on_error;
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -299,8 +305,8 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 	return ret;
 }
 
-static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
-				 unsigned int val)
+static int lan9303_indirect_phy_write(struct lan9303 *chip, int addr,
+				      int regnum, u16 val)
 {
 	int ret;
 	u32 reg;
@@ -311,7 +317,7 @@ static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
 
 	mutex_lock(&chip->indirect_mutex);
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -328,6 +334,11 @@ static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
 	return ret;
 }
 
+const struct lan9303_phy_ops lan9303_indirect_phy_ops = {
+	.phy_read = lan9303_indirect_phy_read,
+	.phy_write = lan9303_indirect_phy_write,
+};
+
 static int lan9303_switch_wait_for_completion(struct lan9303 *chip)
 {
 	int ret, i;
@@ -427,14 +438,15 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	 * Special reg 18 of phy 3 reads as 0x0000, if 'phy_addr_sel_strap' is 0
 	 * and the IDs are 0-1-2, else it contains something different from
 	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
+	 * 0xffff is returned for failed MDIO access.
 	 */
-	reg = lan9303_port_phy_reg_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
+	reg = chip->ops->phy_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
 	if (reg < 0) {
 		dev_err(chip->dev, "Failed to detect phy config: %d\n", reg);
 		return reg;
 	}
 
-	if (reg != 0)
+	if ((reg != 0) && (reg != 0xffff))
 		chip->phy_addr_sel_strap = 1;
 	else
 		chip->phy_addr_sel_strap = 0;
@@ -719,7 +731,7 @@ static int lan9303_phy_read(struct dsa_switch *ds, int phy, int regnum)
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_port_phy_reg_read(chip, phy, regnum);
+	return chip->ops->phy_read(chip, phy, regnum);
 }
 
 static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
@@ -733,7 +745,7 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_phy_reg_write(chip, phy, regnum, val);
+	return chip->ops->phy_write(chip, phy, regnum, val);
 }
 
 static int lan9303_port_enable(struct dsa_switch *ds, int port,
@@ -766,13 +778,13 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
-		lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
-				      MII_BMCR, BMCR_PDOWN);
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
+				  MII_BMCR, BMCR_PDOWN);
 		break;
 	case 2:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
-		lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 2,
-				      MII_BMCR, BMCR_PDOWN);
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
+				  MII_BMCR, BMCR_PDOWN);
 		break;
 	default:
 		dev_dbg(chip->dev,
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index d1512dad2d90..444d00b460e1 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -2,6 +2,15 @@
 #include <linux/device.h>
 #include <net/dsa.h>
 
+struct lan9303;
+
+struct lan9303_phy_ops {
+	/* PHY 1 &2 access*/
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
index 93c36c0541cf..94df12c5362f 100644
--- a/drivers/net/dsa/lan9303_mdio.c
+++ b/drivers/net/dsa/lan9303_mdio.c
@@ -39,6 +39,7 @@ static void lan9303_mdio_real_write(struct mdio_device *mdio, int reg, u16 val)
 static int lan9303_mdio_write(void *ctx, uint32_t reg, uint32_t val)
 {
 	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
+	reg <<= 2; /* reg num to offset */
 
 	mutex_lock(&sw_dev->device->bus->mdio_lock);
 	lan9303_mdio_real_write(sw_dev->device, reg, val & 0xffff);
@@ -56,6 +57,7 @@ static u16 lan9303_mdio_real_read(struct mdio_device *mdio, int reg)
 static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
 {
 	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
+	reg <<= 2; /* reg num to offset */
 
 	mutex_lock(&sw_dev->device->bus->mdio_lock);
 	*val = lan9303_mdio_real_read(sw_dev->device, reg);
@@ -65,6 +67,36 @@ static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
 	return 0;
 }
 
+int lan9303_mdio_phy_write(struct lan9303 *chip, int phy, int regnum, u16 val)
+{
+	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
+	struct mdio_device *mdio = sw_dev->device;
+
+	mutex_lock(&mdio->bus->mdio_lock);
+	mdio->bus->write(mdio->bus, phy, regnum, val);
+	mutex_unlock(&mdio->bus->mdio_lock);
+
+	return 0;
+}
+
+int lan9303_mdio_phy_read(struct lan9303 *chip, int phy,  int reg)
+{
+	struct lan9303_mdio *sw_dev = dev_get_drvdata(chip->dev);
+	struct mdio_device *mdio = sw_dev->device;
+	int val;
+
+	mutex_lock(&mdio->bus->mdio_lock);
+	val  =  mdio->bus->read(mdio->bus, phy, reg);
+	mutex_unlock(&mdio->bus->mdio_lock);
+
+	return val;
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
@@ -106,6 +138,8 @@ static int lan9303_mdio_probe(struct mdio_device *mdiodev)
 	dev_set_drvdata(&mdiodev->dev, sw_dev);
 	sw_dev->chip.dev = &mdiodev->dev;
 
+	sw_dev->chip.ops = &lan9303_mdio_phy_ops;
+
 	ret = lan9303_probe(&sw_dev->chip, mdiodev->dev.of_node);
 	if (ret != 0)
 		return ret;
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
