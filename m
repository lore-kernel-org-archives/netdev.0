From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 04/12] net: dsa: mv88e6xxx: extract trunk mapping
Date: Mon, 18 Jul 2016 20:45:32 -0400
Message-ID: <20160719004540.1066-5-vivien.didelot@savoirfairelinux.com>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Trunk Mask and Trunk Mapping registers are two Global 2 indirect
accesses to trunking configuration.

Add helpers for these tables and simplify the Global 2 setup.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 68 ++++++++++++++++++++++++-----------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 2 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9b2525a..d18e5c8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3151,6 +3151,49 @@ static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+static int mv88e6xxx_g2_trunk_mask_write(struct mv88e6xxx_chip *chip, int num,
+					 bool hask, u16 mask)
+{
+	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	u16 val = (num << 12) | (mask & port_mask);
+
+	if (hask)
+		val |= GLOBAL2_TRUNK_MASK_HASK;
+
+	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_TRUNK_MASK, val);
+}
+
+static int mv88e6xxx_g2_trunk_mapping_write(struct mv88e6xxx_chip *chip, int id,
+					    u16 map)
+{
+	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	u16 val = (id << 11) | (map & port_mask);
+
+	return mv88e6xxx_update(chip, REG_GLOBAL2, GLOBAL2_TRUNK_MAPPING, val);
+}
+
+static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
+{
+	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	int i, err;
+
+	/* Clear all eight possible Trunk Mask vectors */
+	for (i = 0; i < 8; ++i) {
+		err = mv88e6xxx_g2_trunk_mask_write(chip, i, false, port_mask);
+		if (err)
+			return err;
+	}
+
+	/* Clear all sixteen possible Trunk ID routing vectors */
+	for (i = 0; i < 16; ++i) {
+		err = mv88e6xxx_g2_trunk_mapping_write(chip, i, 0);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	int err;
@@ -3180,27 +3223,10 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Clear all trunk masks. */
-	for (i = 0; i < 8; i++) {
-		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL2,
-					   GLOBAL2_TRUNK_MASK,
-					   0x8000 |
-					   (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
-					   ((1 << chip->info->num_ports) - 1));
-		if (err)
-			return err;
-	}
-
-	/* Clear all trunk mappings. */
-	for (i = 0; i < 16; i++) {
-		err = _mv88e6xxx_reg_write(
-			chip, REG_GLOBAL2,
-			GLOBAL2_TRUNK_MAPPING,
-			GLOBAL2_TRUNK_MAPPING_UPDATE |
-			(i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
-		if (err)
-			return err;
-	}
+	/* Clear all trunk masks and mapping. */
+	err = mv88e6xxx_g2_clear_trunk(chip);
+	if (err)
+		return err;
 
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 390dac5..876d9ea 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -294,6 +294,7 @@
 #define GLOBAL2_TRUNK_MASK	0x07
 #define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
 #define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
+#define GLOBAL2_TRUNK_MASK_HASK			BIT(11)
 #define GLOBAL2_TRUNK_MAPPING	0x08
 #define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
 #define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
-- 
2.9.0
