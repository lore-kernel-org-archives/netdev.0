From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/6] net: dsa: mv88e6xxx: add helper to hardware reset
Date: Wed, 30 Nov 2016 17:59:26 -0500
Message-ID: <20161130225930.25510-3-vivien.didelot@savoirfairelinux.com>
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

Add an helper to toggle the eventual GPIO connected to the reset pin.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c89701e..4a862c2 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2361,6 +2361,19 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 }
 
+static void mv88e6xxx_hardware_reset(struct mv88e6xxx_chip *chip)
+{
+	struct gpio_desc *gpiod = chip->reset;
+
+	/* If there is a GPIO connected to the reset pin, toggle it */
+	if (gpiod) {
+		gpiod_set_value_cansleep(gpiod, 1);
+		usleep_range(10000, 20000);
+		gpiod_set_value_cansleep(gpiod, 0);
+		usleep_range(10000, 20000);
+	}
+}
+
 static int mv88e6xxx_disable_ports(struct mv88e6xxx_chip *chip)
 {
 	int i, err;
@@ -2385,7 +2398,6 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
 	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
-	struct gpio_desc *gpiod = chip->reset;
 	unsigned long timeout;
 	u16 reg;
 	int err;
@@ -2394,13 +2406,7 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* If there is a gpio connected to the reset pin, toggle it */
-	if (gpiod) {
-		gpiod_set_value_cansleep(gpiod, 1);
-		usleep_range(10000, 20000);
-		gpiod_set_value_cansleep(gpiod, 0);
-		usleep_range(10000, 20000);
-	}
+	mv88e6xxx_hardware_reset(chip);
 
 	/* Reset the switch. Keep the PPU active if requested. The PPU
 	 * needs to be active to support indirect phy register access
-- 
2.10.2
