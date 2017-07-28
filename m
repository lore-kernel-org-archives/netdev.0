From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 3/4] net: dsa: lan9303: Renamed indirect phy access functions
Date: Fri, 28 Jul 2017 17:11:56 +0200
Message-ID: <20170728151157.28983-4-privat@egil-hjelmeland.no>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Preparing for the following fix of MDIO phy access:

Renamed functions that access PHY 1 and 2 indirectly through PMI
registers.

 lan9303_port_phy_reg_wait_for_completion() to
 lan9303_indirect_phy_wait_for_completion()

 lan9303_port_phy_reg_read() to
 lan9303_indirect_phy_read()

 lan9303_port_phy_reg_write() to
 lan9303_indirect_phy_write()

Also changed "val" parameter of lan9303_indirect_phy_write() to u16,
for clarity.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 96ebeb9bd59a..9427c3b0ced2 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -248,7 +248,7 @@ static int lan9303_virt_phy_reg_write(struct lan9303 *chip, int regnum, u16 val)
 	return regmap_write(chip->regmap, LAN9303_VIRT_PHY_BASE + regnum, val);
 }
 
-static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
+static int lan9303_indirect_phy_wait_for_completion(struct lan9303 *chip)
 {
 	int ret, i;
 	u32 reg;
@@ -268,7 +268,7 @@ static int lan9303_port_phy_reg_wait_for_completion(struct lan9303 *chip)
 	return -EIO;
 }
 
-static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
+static int lan9303_indirect_phy_read(struct lan9303 *chip, int addr, int regnum)
 {
 	int ret;
 	u32 val;
@@ -278,7 +278,7 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 
 	mutex_lock(&chip->indirect_mutex);
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -287,7 +287,7 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 	if (ret)
 		goto on_error;
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -305,8 +305,8 @@ static int lan9303_port_phy_reg_read(struct lan9303 *chip, int addr, int regnum)
 	return ret;
 }
 
-static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
-				 unsigned int val)
+static int lan9303_indirect_phy_write(struct lan9303 *chip, int addr,
+				      int regnum, u16 val)
 {
 	int ret;
 	u32 reg;
@@ -317,7 +317,7 @@ static int lan9303_phy_reg_write(struct lan9303 *chip, int addr, int regnum,
 
 	mutex_lock(&chip->indirect_mutex);
 
-	ret = lan9303_port_phy_reg_wait_for_completion(chip);
+	ret = lan9303_indirect_phy_wait_for_completion(chip);
 	if (ret)
 		goto on_error;
 
@@ -435,7 +435,7 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	 * 0x0000, which means 'phy_addr_sel_strap' is 1 and the IDs are 1-2-3.
 	 * 0xffff is returned on MDIO read with no response.
 	 */
-	reg = lan9303_port_phy_reg_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
+	reg = lan9303_indirect_phy_read(chip, 3, MII_LAN911X_SPECIAL_MODES);
 	if (reg < 0) {
 		dev_err(chip->dev, "Failed to detect phy config: %d\n", reg);
 		return reg;
@@ -726,7 +726,7 @@ static int lan9303_phy_read(struct dsa_switch *ds, int phy, int regnum)
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_port_phy_reg_read(chip, phy, regnum);
+	return lan9303_indirect_phy_read(chip, phy, regnum);
 }
 
 static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
@@ -740,7 +740,7 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
 	if (phy > phy_base + 2)
 		return -ENODEV;
 
-	return lan9303_phy_reg_write(chip, phy, regnum, val);
+	return lan9303_indirect_phy_write(chip, phy, regnum, val);
 }
 
 static int lan9303_port_enable(struct dsa_switch *ds, int port,
@@ -773,13 +773,13 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
-		lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
-				      MII_BMCR, BMCR_PDOWN);
+		lan9303_indirect_phy_write(chip, chip->phy_addr_sel_strap + 1,
+					   MII_BMCR, BMCR_PDOWN);
 		break;
 	case 2:
 		lan9303_disable_packet_processing(chip, LAN9303_PORT_2_OFFSET);
-		lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 2,
-				      MII_BMCR, BMCR_PDOWN);
+		lan9303_indirect_phy_write(chip, chip->phy_addr_sel_strap + 2,
+					   MII_BMCR, BMCR_PDOWN);
 		break;
 	default:
 		dev_dbg(chip->dev,
-- 
2.11.0
