From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: handle SERDES error appropriately
Date: Fri, 26 May 2017 18:02:42 -0400
Message-ID: <20170526220242.23353-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mv88e6xxx_serdes_power returns an error, so no need to print an error
message inside of it. Rather print it in its caller when the error is
ignored, which is in the mv88e6xxx_port_disable void function.

Catch and return its error in the counterpart mv88e6xxx_port_enable.

Fixes: 04aca9938255 ("dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c2f38f6770aa..742c0eae7fa3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1806,16 +1806,10 @@ static int mv88e6xxx_setup_egress_floods(struct mv88e6xxx_chip *chip, int port)
 static int mv88e6xxx_serdes_power(struct mv88e6xxx_chip *chip, int port,
 				  bool on)
 {
-	int err = 0;
+	if (chip->info->ops->serdes_power)
+		return chip->info->ops->serdes_power(chip, port, on);
 
-	if (chip->info->ops->serdes_power) {
-		err = chip->info->ops->serdes_power(chip, port, on);
-		if (err)
-			dev_err(chip->dev,
-				"Failed to change SERDES power: %d\n", err);
-	}
-
-	return err;
+	return 0;
 }
 
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
@@ -1982,10 +1976,10 @@ static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
 				 struct phy_device *phydev)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	int err = 0;
+	int err;
 
 	mutex_lock(&chip->reg_lock);
-	mv88e6xxx_serdes_power(chip, port, true);
+	err = mv88e6xxx_serdes_power(chip, port, true);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -1997,7 +1991,8 @@ static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 
 	mutex_lock(&chip->reg_lock);
-	mv88e6xxx_serdes_power(chip, port, false);
+	if (mv88e6xxx_serdes_power(chip, port, false))
+		dev_err(chip->dev, "failed to power off SERDES\n");
 	mutex_unlock(&chip->reg_lock);
 }
 
-- 
2.13.0
