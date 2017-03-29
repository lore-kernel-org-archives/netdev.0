From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/9] net: dsa: mv88e6xxx: use 4-bit port for PVT data
Date: Wed, 29 Mar 2017 16:30:13 -0400
Message-ID: <20170329203020.27042-3-vivien.didelot@savoirfairelinux.com>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Cross-chip Port Based VLAN Table (PVT) supports two indexing modes,
one using 5-bit for device and 4-bit for port, the other using 4-bit for
device and 5-bit for port, configured via the Global 2 Misc register.

Only 4 bits for the source port are needed when interconnecting 88E6xxx
switch devices since they all support less than 16 physical ports. The
full 5 bits are needed when interconnecting a device with 98DXxxx switch
devices since they support more than 16 physical ports.

Add a mv88e6xxx_pvt_setup helper to set the 4-bit port PVT mode, which
will be extended later to also initialize the PVT content.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 15 +++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 19 +++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.h   |  7 +++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 4 files changed, 42 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8f1f881d0375..4aa083674a00 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1198,6 +1198,17 @@ static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
 }
 
+static int mv88e6xxx_pvt_setup(struct mv88e6xxx_chip *chip)
+{
+	if (!mv88e6xxx_has_pvt(chip))
+		return 0;
+
+	/* Clear 5 Bit Port for usage with Marvell Link Street devices:
+	 * use 4 bits for the Src_Port/Src_Trunk and 5 bits for the Src_Dev.
+	 */
+	return mv88e6xxx_g2_misc_5_bit_port(chip, false);
+}
+
 static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
@@ -2594,6 +2605,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	err = mv88e6xxx_pvt_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_atu_setup(chip);
 	if (err)
 		goto unlock;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 77053f60fb84..001ef7d69bc6 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -783,6 +783,25 @@ static int mv88e6xxx_g2_watchdog_setup(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+/* Offset 0x1D: Misc Register */
+
+int mv88e6xxx_g2_misc_5_bit_port(struct mv88e6xxx_chip *chip, bool port_5_bit)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_MISC, &val);
+	if (err)
+		return err;
+
+	if (port_5_bit)
+		val |= GLOBAL2_MISC_5_BIT_PORT;
+	else
+		val &= ~GLOBAL2_MISC_5_BIT_PORT;
+
+	return mv88e6xxx_g2_write(chip, GLOBAL2_MISC, val);
+}
+
 static void mv88e6xxx_g2_irq_mask(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index f8b6dd93213a..fb69062902a9 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -42,6 +42,8 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 
+int mv88e6xxx_g2_misc_5_bit_port(struct mv88e6xxx_chip *chip, bool port_5_bit);
+
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
@@ -110,6 +112,11 @@ static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
+int mv88e6xxx_g2_misc_5_bit_port(struct mv88e6xxx_chip *chip, bool port_5_bit)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	return -EOPNOTSUPP;
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 97dd3e2d2a56..bcaa55b20f5a 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -439,6 +439,7 @@
 #define GLOBAL2_WDOG_FORCE_IRQ			BIT(0)
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
+#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
 
 #define MV88E6XXX_N_FID		4096
 
-- 
2.12.1
