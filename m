From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/6] net: dsa: mv88e6xxx: add helper for switch ready
Date: Wed, 30 Nov 2016 17:59:29 -0500
Message-ID: <20161130225930.25510-6-vivien.didelot@savoirfairelinux.com>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All Marvell switches (even 88E6060) have a bit to inform that the switch
is ready to accept frames. Implement that in  mv88e6xxx_g1_init_ready().

If the switch has a PPU, we must wait until its state is active polling,
otherwise we cannot access PortStatus registers. Nicely wrap all that in
a mv88e6xxx_wait_switch_ready() helper for the switch reset code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 52 +++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 15 ++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  1 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 4 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index db4014c..f5d5370 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2363,6 +2363,36 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_wait_switch_ready(struct mv88e6xxx_chip *chip)
+{
+	const unsigned long timeout = jiffies + 1 * HZ;
+	bool ready;
+	int err;
+
+	/* Wait up to 1 second for switch to be ready.
+	 * The switch is ready when all units inside the device (ATU, VTU, etc.)
+	 * have finished their initialization and are ready to accept frames.
+	 */
+	while (time_before(jiffies, timeout)) {
+		err = mv88e6xxx_g1_init_ready(chip, &ready);
+		if (err)
+			return err;
+
+		if (ready)
+			break;
+
+		usleep_range(1000, 2000);
+	}
+
+	if (time_after(jiffies, timeout))
+		return -ETIMEDOUT;
+
+	/* If there is a PPU, the PortStatus registers must not be written to by
+	 * software until the PPU is active polling, so wait until then.
+	 */
+	return mv88e6xxx_ppu_wait(chip, true);
+}
+
 static int mv88e6xxx_software_reset(struct mv88e6xxx_chip *chip)
 {
 	if (chip->info->ops->reset)
@@ -2406,10 +2436,6 @@ static int mv88e6xxx_disable_ports(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
-	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
-	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
-	unsigned long timeout;
-	u16 reg;
 	int err;
 
 	err = mv88e6xxx_disable_ports(chip);
@@ -2422,23 +2448,7 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		err = mv88e6xxx_g1_read(chip, 0x00, &reg);
-		if (err)
-			return err;
-
-		if ((reg & is_reset) == is_reset)
-			break;
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		err = -ETIMEDOUT;
-	else
-		err = 0;
-
-	return err;
+	return mv88e6xxx_wait_switch_ready(chip);
 }
 
 static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 371d96a..4d69cec 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -66,6 +66,21 @@ int mv88e6352_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling)
 	return 0;
 }
 
+int mv88e6xxx_g1_init_ready(struct mv88e6xxx_chip *chip, bool *ready)
+{
+	u16 val;
+	int err;
+
+	/* Check the value of the InitReady bit 11 */
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
+	if (err)
+		return err;
+
+	*ready = !!(val & GLOBAL_STATUS_INIT_READY);
+
+	return 0;
+}
+
 /* Offset 0x04: Switch Global Control Register */
 
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index cdccf473..6f0fb7f 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -22,6 +22,7 @@ int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
 
 int mv88e6185_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling);
 int mv88e6352_g1_ppu_polling(struct mv88e6xxx_chip *chip, bool *polling);
+int mv88e6xxx_g1_init_ready(struct mv88e6xxx_chip *chip, bool *ready);
 
 int mv88e6185_g1_reset(struct mv88e6xxx_chip *chip);
 int mv88e6352_g1_reset(struct mv88e6xxx_chip *chip);
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9ae228c..cd0f414 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -180,6 +180,7 @@
 #define GLOBAL_STATUS_PPU_STATE_INITIALIZING	(0x1 << 14)
 #define GLOBAL_STATUS_PPU_STATE_DISABLED	(0x2 << 14)
 #define GLOBAL_STATUS_PPU_STATE_POLLING		(0x3 << 14)
+#define GLOBAL_STATUS_INIT_READY	BIT(11)
 #define GLOBAL_STATUS_IRQ_AVB		8
 #define GLOBAL_STATUS_IRQ_DEVICE	7
 #define GLOBAL_STATUS_IRQ_STATS		6
-- 
2.10.2
