From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: mv88e6xxx: provide a PHY setup helper
Date: Fri, 26 May 2017 18:03:05 -0400
Message-ID: <20170526220307.23503-2-vivien.didelot@savoirfairelinux.com>
References: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similarly to the VTU, PVT and ATU setup, provide a mv88e6xxx_phy_setup
helper which wraps mv88e6xxx_ppu_enable, so that no more PPU-related
functions are exposed outside of phy.c.

Thus make mv88e6xxx_ppu_enable static.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 11 ++++-------
 drivers/net/dsa/mv88e6xxx/phy.c  |  7 ++++++-
 drivers/net/dsa/mv88e6xxx/phy.h  |  2 +-
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 742c0eae7fa3..7f5f44f89389 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2034,13 +2034,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	u32 upstream_port = dsa_upstream_port(ds);
 	int err;
 
-	/* Enable the PHY Polling Unit if present, don't discard any packets,
-	 * and mask all interrupt sources.
-	 */
-	err = mv88e6xxx_ppu_enable(chip);
-	if (err)
-		return err;
-
 	if (chip->info->ops->g1_set_cpu_port) {
 		err = chip->info->ops->g1_set_cpu_port(chip, upstream_port);
 		if (err)
@@ -2140,6 +2133,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	err = mv88e6xxx_phy_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_vtu_setup(chip);
 	if (err)
 		goto unlock;
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 0d3e8aaedf50..b865b1e2b103 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -124,7 +124,7 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 	return chip->info->ops->ppu_disable(chip);
 }
 
-int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
+static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
 	if (!chip->info->ops->ppu_enable)
 		return 0;
@@ -241,3 +241,8 @@ void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 	if (chip->info->ops->ppu_enable && chip->info->ops->ppu_disable)
 		mv88e6xxx_ppu_state_destroy(chip);
 }
+
+int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_ppu_enable(chip);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index 0961d781b726..dfa98549dfcd 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -30,8 +30,8 @@ int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			   int addr, int reg, u16 *val);
 int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 			    int addr, int reg, u16 val);
-int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip);
+int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip);
 
 #endif /*_MV88E6XXX_PHY_H */
-- 
2.13.0
