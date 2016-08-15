From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/6] net: dsa: mv88e6xxx: rename _mv88e6xxx_wait
Date: Mon, 15 Aug 2016 17:18:57 -0400
Message-ID: <20160815211902.2236-2-vivien.didelot@savoirfairelinux.com>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that there is no locked version of the wait routine anymore, rename
the _ prefixed version and make it use the new read API.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 63 +++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d36aedd..a5a96bc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -216,6 +216,28 @@ static int mv88e6xxx_write(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
+			  u16 mask)
+{
+	unsigned long timeout = jiffies + HZ / 10;
+
+	while (time_before(jiffies, timeout)) {
+		u16 val;
+		int err;
+
+		err = mv88e6xxx_read(chip, addr, reg, &val);
+		if (err)
+			return err;
+
+		if (!(val & mask))
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+
+	return -ETIMEDOUT;
+}
+
 /* Indirect write to single pointer-data register with an Update bit */
 static int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 			    u16 update)
@@ -819,35 +841,16 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
-static int _mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int reg, int offset,
-			   u16 mask)
-{
-	unsigned long timeout = jiffies + HZ / 10;
-
-	while (time_before(jiffies, timeout)) {
-		int ret;
-
-		ret = _mv88e6xxx_reg_read(chip, reg, offset);
-		if (ret < 0)
-			return ret;
-		if (!(ret & mask))
-			return 0;
-
-		usleep_range(1000, 2000);
-	}
-	return -ETIMEDOUT;
-}
-
 static int mv88e6xxx_mdio_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
-			       GLOBAL2_SMI_OP_BUSY);
+	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_SMI_OP,
+			      GLOBAL2_SMI_OP_BUSY);
 }
 
 static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
-			       GLOBAL_ATU_OP_BUSY);
+	return mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
+			      GLOBAL_ATU_OP_BUSY);
 }
 
 static int mv88e6xxx_mdio_read_indirect(struct mv88e6xxx_chip *chip,
@@ -1227,8 +1230,8 @@ static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_chip *chip,
 
 static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_VTU_OP,
-			       GLOBAL_VTU_OP_BUSY);
+	return mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_VTU_OP,
+			      GLOBAL_VTU_OP_BUSY);
 }
 
 static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
@@ -2949,8 +2952,8 @@ static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
 			break;
 
 		/* Wait for the operation to complete */
-		err = _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
-				      GLOBAL2_IRL_CMD_BUSY);
+		err = mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_IRL_CMD,
+				     GLOBAL2_IRL_CMD_BUSY);
 		if (err)
 			break;
 	}
@@ -3004,9 +3007,9 @@ static int mv88e6xxx_g2_clear_pot(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_g2_eeprom_wait(struct mv88e6xxx_chip *chip)
 {
-	return _mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD,
-			       GLOBAL2_EEPROM_CMD_BUSY |
-			       GLOBAL2_EEPROM_CMD_RUNNING);
+	return mv88e6xxx_wait(chip, REG_GLOBAL2, GLOBAL2_EEPROM_CMD,
+			      GLOBAL2_EEPROM_CMD_BUSY |
+			      GLOBAL2_EEPROM_CMD_RUNNING);
 }
 
 static int mv88e6xxx_g2_eeprom_cmd(struct mv88e6xxx_chip *chip, u16 cmd)
-- 
2.9.3
