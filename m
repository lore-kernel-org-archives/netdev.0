From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/9] net: dsa: mv88e6xxx: extract device mapping
Date: Thu,  7 Jul 2016 08:57:52 -0400
Message-ID: <20160707125758.1547-4-vivien.didelot@savoirfairelinux.com>
References: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Device Mapping register is an indirect table access.

Provide helpers to access this table and explicit the checking of the
new DSA_RTABLE_NONE routing table value.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 49 ++++++++++++++++++++++++++++------------
 1 file changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1e39fa6..9b37310 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3094,9 +3094,39 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
+					     int target, int port)
+{
+	u16 val = GLOBAL2_DEVICE_MAPPING_UPDATE | (target << 8) | (port & 0xf);
+
+	return mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING, val);
+}
+
+static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
+{
+	int target, port;
+	int err;
+
+	/* Initialize the routing port to the 32 possible target devices */
+	for (target = 0; target < 32; ++target) {
+		port = 0xf;
+
+		if (target < DSA_MAX_SWITCHES) {
+			port = chip->ds->rtable[target];
+			if (port == DSA_RTABLE_NONE)
+				port = 0xf;
+		}
+
+		err = mv88e6xxx_g2_device_mapping_write(chip, target, port);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
 static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
-	struct dsa_switch *ds = chip->ds;
 	int err;
 	int i;
 
@@ -3120,20 +3150,9 @@ static int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 		return err;
 
 	/* Program the DSA routing table. */
-	for (i = 0; i < 32; i++) {
-		int nexthop = 0x1f;
-
-		if (i != ds->index && i < DSA_MAX_SWITCHES)
-			nexthop = ds->rtable[i] & 0x1f;
-
-		err = _mv88e6xxx_reg_write(
-			chip, REG_GLOBAL2,
-			GLOBAL2_DEVICE_MAPPING,
-			GLOBAL2_DEVICE_MAPPING_UPDATE |
-			(i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) | nexthop);
-		if (err)
-			return err;
-	}
+	err = mv88e6xxx_g2_set_device_mapping(chip);
+	if (err)
+		return err;
 
 	/* Clear all trunk masks. */
 	for (i = 0; i < 8; i++) {
-- 
2.9.0
