From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 11/12] net: dsa: mv88e6xxx: add G1 helper for ageing time
Date: Mon, 18 Jul 2016 20:45:39 -0400
Message-ID: <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
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

All Marvell switch chips from (88E6060 to 88E6390) have a ATU Control
register containing bits 11:4 to configure an ATU Age Time quotient.

However the coefficient used to calculate the ATU Age Time vary with the
models. E.g. 88E6060, 88E6352 and 88E6390 use respectively 16, 15 and
3.75 seconds.

Add a age_time_coeff to the info structure to handle this and a Global 1
helper to set the default age time of 5 minutes in the setup code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 58 ++++++++++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 2 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bc26b4f..8e24c65 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2975,6 +2975,33 @@ static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 			       (addr[4] << 8) | addr[5]);
 }
 
+static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
+				     unsigned int msecs)
+{
+	const unsigned int coeff = chip->info->age_time_coeff;
+	const unsigned int min = 0x01 * coeff;
+	const unsigned int max = 0xff * coeff;
+	u8 age_time;
+	u16 val;
+	int err;
+
+	if (msecs < min || msecs > max)
+		return -ERANGE;
+
+	/* Round to nearest multiple of coeff */
+	age_time = (msecs + coeff / 2) / coeff;
+
+	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, &val);
+	if (err)
+		return err;
+
+	/* AgeTime is 11:4 bits */
+	val &= ~0xff0;
+	val |= age_time << 4;
+
+	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, val);
+}
+
 static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -3012,18 +3039,22 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	/* Clear all the VTU and STU entries */
+	err = _mv88e6xxx_vtu_stu_flush(chip);
+	if (err < 0)
+		return err;
+
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
-				   0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
+	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+			      GLOBAL_ATU_CONTROL_LEARN2ALL);
 	if (err)
 		return err;
 
-	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(chip);
-	if (err < 0)
+	err = mv88e6xxx_g1_set_age_time(chip, 300000);
+	if (err)
 		return err;
 
 	/* Clear all ATU entries */
@@ -3634,6 +3665,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 10,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	},
 
@@ -3644,6 +3676,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 11,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	},
 
@@ -3654,6 +3687,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 3,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3664,6 +3698,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 8,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3674,6 +3709,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 6,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3684,6 +3720,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 6,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3694,6 +3731,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3704,6 +3742,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3714,6 +3753,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3724,6 +3764,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3734,6 +3775,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 10,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3744,6 +3786,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3754,6 +3797,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3764,6 +3808,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3774,6 +3819,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3784,6 +3830,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3794,6 +3841,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 };
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 9ea5363..899ca1d 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -568,6 +568,7 @@ struct mv88e6xxx_info {
 	unsigned int num_databases;
 	unsigned int num_ports;
 	unsigned int port_base_addr;
+	unsigned int age_time_coeff;
 	unsigned long flags;
 };
 
-- 
2.9.0
