From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 1/9] net: dsa: mv88e6xxx: add accessors for PTP/TAI registers
Date: Thu, 28 Sep 2017 10:25:33 -0500
Message-ID: <1506612341-18061-2-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "Vivien Didelot" <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements support for accessing PTP/TAI registers through
the AVB register interface in the Global 2 register.

The register interface differs slightly between different models; older
models use a 3-bit operations field, while newer models use a 2-bit
field. The operations values and the special "global port" values are
different between the two. This is a similar split to the differences
in the "Ingress Rate" register between models, so, like in that case,
we call the two variants "6352" and "6390" and create an ops structure
to abstract between the two.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    |   9 ++
 drivers/net/dsa/mv88e6xxx/chip.h    |  17 ++++
 drivers/net/dsa/mv88e6xxx/global2.c | 173 ++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.h |  27 +++++-
 4 files changed, 225 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6678aa..67efa7b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2783,6 +2783,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 	.serdes_power = mv88e6352_serdes_power,
+	.avb_ops = &mv88e6352_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6290_ops = {
@@ -2819,6 +2820,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 	.serdes_power = mv88e6390_serdes_power,
+	.avb_ops = &mv88e6390_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6320_ops = {
@@ -2852,6 +2854,7 @@ static const struct mv88e6xxx_ops mv88e6320_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
+	.avb_ops = &mv88e6352_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6321_ops = {
@@ -2883,6 +2886,7 @@ static const struct mv88e6xxx_ops mv88e6321_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6185_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6185_g1_vtu_loadpurge,
+	.avb_ops = &mv88e6352_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6341_ops = {
@@ -2918,6 +2922,7 @@ static const struct mv88e6xxx_ops mv88e6341_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.avb_ops = &mv88e6390_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6350_ops = {
@@ -2984,6 +2989,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.reset = mv88e6352_g1_reset,
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
+	.avb_ops = &mv88e6352_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6352_ops = {
@@ -3020,6 +3026,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.vtu_getnext = mv88e6352_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6352_g1_vtu_loadpurge,
 	.serdes_power = mv88e6352_serdes_power,
+	.avb_ops = &mv88e6352_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6390_ops = {
@@ -3058,6 +3065,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 	.serdes_power = mv88e6390_serdes_power,
+	.avb_ops = &mv88e6390_avb_ops,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3096,6 +3104,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.vtu_getnext = mv88e6390_g1_vtu_getnext,
 	.vtu_loadpurge = mv88e6390_g1_vtu_loadpurge,
 	.serdes_power = mv88e6390_serdes_power,
+	.avb_ops = &mv88e6390_avb_ops,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 334f6f7..d99d592 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -146,6 +146,7 @@ struct mv88e6xxx_vtu_entry {
 
 struct mv88e6xxx_bus_ops;
 struct mv88e6xxx_irq_ops;
+struct mv88e6xxx_avb_ops;
 
 struct mv88e6xxx_irq {
 	u16 masked;
@@ -342,6 +343,9 @@ struct mv88e6xxx_ops {
 			   struct mv88e6xxx_vtu_entry *entry);
 	int (*vtu_loadpurge)(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
+
+	/* Interface to the AVB/PTP registers */
+	const struct mv88e6xxx_avb_ops *avb_ops;
 };
 
 struct mv88e6xxx_irq_ops {
@@ -353,6 +357,19 @@ struct mv88e6xxx_irq_ops {
 	void (*irq_free)(struct mv88e6xxx_chip *chip);
 };
 
+struct mv88e6xxx_avb_ops {
+	int (*port_ptp_read)(struct mv88e6xxx_chip *chip, int port, int addr,
+			     u16 *data, int len);
+	int (*port_ptp_write)(struct mv88e6xxx_chip *chip, int port, int addr,
+			      u16 data);
+	int (*ptp_read)(struct mv88e6xxx_chip *chip, int addr, u16 *data,
+			int len);
+	int (*ptp_write)(struct mv88e6xxx_chip *chip, int addr, u16 data);
+	int (*tai_read)(struct mv88e6xxx_chip *chip, int addr, u16 *data,
+			int len);
+	int (*tai_write)(struct mv88e6xxx_chip *chip, int addr, u16 data);
+};
+
 #define STATS_TYPE_PORT		BIT(0)
 #define STATS_TYPE_BANK0	BIT(1)
 #define STATS_TYPE_BANK1	BIT(2)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index af07278..b6d0c71 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -590,6 +590,179 @@ int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+/* Offset 0x16: AVB Command Register
+ * Offset 0x17: AVB Data Register
+ *
+ * There are two different versions of this register interface:
+ *    "6352": 3-bit "op" field, 4-bit "port" field.
+ *    "6390": 2-bit "op" field, 5-bit "port" field.
+ *
+ * The "op" codes are different between the two, as well as the special
+ * port fields for global PTP and TAI configuration.
+ */
+
+/* mv88e6xxx_g2_avb_read -- Read one or multiple 16-bit words.
+ * The hardware supports snapshotting up to four contiguous registers.
+ */
+static int mv88e6xxx_g2_avb_read(struct mv88e6xxx_chip *chip, u16 readop,
+				 u16 *data, int len)
+{
+	int err;
+	int i;
+
+	/* Hardware can only snapshot four words. */
+	if (unlikely(len > 4))
+		return -E2BIG;
+
+	err = mv88e6xxx_g2_update(chip, MV88E6352_G2_AVB_CMD, readop);
+	if (err)
+		return err;
+
+	for (i = 0; i < len; ++i) {
+		err = mv88e6xxx_g2_read(chip, MV88E6352_G2_AVB_DATA,
+					&data[i]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+/* mv88e6xxx_g2_avb_write -- Write one 16-bit word. */
+static int mv88e6xxx_g2_avb_write(struct mv88e6xxx_chip *chip, u16 writeop,
+				  u16 data)
+{
+	int err;
+
+	err = mv88e6xxx_g2_write(chip, MV88E6352_G2_AVB_DATA, data);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g2_update(chip, MV88E6352_G2_AVB_CMD, writeop);
+}
+
+static int mv88e6352_port_ptp_read(struct mv88e6xxx_chip *chip, int port,
+				   int addr, u16 *data, int len)
+{
+	u16 readop = (len == 1 ? MV88E6352_G2_AVB_CMD_OP_READ :
+				 MV88E6352_G2_AVB_CMD_OP_READ_INCR) |
+		     (port << 8) | (MV88E6352_G2_AVB_CMD_BLOCK_PTP << 5) |
+		     addr;
+
+	return mv88e6xxx_g2_avb_read(chip, readop, data, len);
+}
+
+static int mv88e6352_port_ptp_write(struct mv88e6xxx_chip *chip, int port,
+				    int addr, u16 data)
+{
+	u16 writeop = MV88E6352_G2_AVB_CMD_OP_WRITE | (port << 8) |
+		      (MV88E6352_G2_AVB_CMD_BLOCK_PTP << 5) | addr;
+
+	return mv88e6xxx_g2_avb_write(chip, writeop, data);
+}
+
+static int mv88e6352_ptp_read(struct mv88e6xxx_chip *chip, int addr,
+			      u16 *data, int len)
+{
+	return mv88e6352_port_ptp_read(chip,
+				       MV88E6352_G2_AVB_CMD_PORT_PTPGLOBAL,
+				       addr, data, len);
+}
+
+static int mv88e6352_ptp_write(struct mv88e6xxx_chip *chip, int addr,
+			       u16 data)
+{
+	return mv88e6352_port_ptp_write(chip,
+					MV88E6352_G2_AVB_CMD_PORT_PTPGLOBAL,
+					addr, data);
+}
+
+static int mv88e6352_tai_read(struct mv88e6xxx_chip *chip, int addr,
+			      u16 *data, int len)
+{
+	return mv88e6352_port_ptp_read(chip,
+				       MV88E6352_G2_AVB_CMD_PORT_TAIGLOBAL,
+				       addr, data, len);
+}
+
+static int mv88e6352_tai_write(struct mv88e6xxx_chip *chip, int addr,
+			       u16 data)
+{
+	return mv88e6352_port_ptp_write(chip,
+					MV88E6352_G2_AVB_CMD_PORT_TAIGLOBAL,
+					addr, data);
+}
+
+const struct mv88e6xxx_avb_ops mv88e6352_avb_ops = {
+	.port_ptp_read		= mv88e6352_port_ptp_read,
+	.port_ptp_write		= mv88e6352_port_ptp_write,
+	.ptp_read		= mv88e6352_ptp_read,
+	.ptp_write		= mv88e6352_ptp_write,
+	.tai_read		= mv88e6352_tai_read,
+	.tai_write		= mv88e6352_tai_write,
+};
+
+static int mv88e6390_port_ptp_read(struct mv88e6xxx_chip *chip, int port,
+				   int addr, u16 *data, int len)
+{
+	u16 readop = (len == 1 ? MV88E6390_G2_AVB_CMD_OP_READ :
+				 MV88E6390_G2_AVB_CMD_OP_READ_INCR) |
+		     (port << 8) | (MV88E6352_G2_AVB_CMD_BLOCK_PTP << 5) |
+		     addr;
+
+	return mv88e6xxx_g2_avb_read(chip, readop, data, len);
+}
+
+static int mv88e6390_port_ptp_write(struct mv88e6xxx_chip *chip, int port,
+				    int addr, u16 data)
+{
+	u16 writeop = MV88E6390_G2_AVB_CMD_OP_WRITE | (port << 8) |
+		      (MV88E6352_G2_AVB_CMD_BLOCK_PTP << 5) | addr;
+
+	return mv88e6xxx_g2_avb_write(chip, writeop, data);
+}
+
+static int mv88e6390_ptp_read(struct mv88e6xxx_chip *chip, int addr,
+			      u16 *data, int len)
+{
+	return mv88e6390_port_ptp_read(chip,
+				       MV88E6390_G2_AVB_CMD_PORT_PTPGLOBAL,
+				       addr, data, len);
+}
+
+static int mv88e6390_ptp_write(struct mv88e6xxx_chip *chip, int addr,
+			       u16 data)
+{
+	return mv88e6390_port_ptp_write(chip,
+					MV88E6390_G2_AVB_CMD_PORT_PTPGLOBAL,
+					addr, data);
+}
+
+static int mv88e6390_tai_read(struct mv88e6xxx_chip *chip, int addr,
+			      u16 *data, int len)
+{
+	return mv88e6390_port_ptp_read(chip,
+				       MV88E6390_G2_AVB_CMD_PORT_TAIGLOBAL,
+				       addr, data, len);
+}
+
+static int mv88e6390_tai_write(struct mv88e6xxx_chip *chip, int addr,
+			       u16 data)
+{
+	return mv88e6390_port_ptp_write(chip,
+					MV88E6390_G2_AVB_CMD_PORT_TAIGLOBAL,
+					addr, data);
+}
+
+const struct mv88e6xxx_avb_ops mv88e6390_avb_ops = {
+	.port_ptp_read		= mv88e6390_port_ptp_read,
+	.port_ptp_write		= mv88e6390_port_ptp_write,
+	.ptp_read		= mv88e6390_ptp_read,
+	.ptp_write		= mv88e6390_ptp_write,
+	.tai_read		= mv88e6390_tai_read,
+	.tai_write		= mv88e6390_tai_write,
+};
+
 /* Offset 0x18: SMI PHY Command Register
  * Offset 0x19: SMI PHY Data Register
  */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 669f590..642d2b0 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -149,7 +149,26 @@
 #define MV88E6390_G2_EEPROM_ADDR_MASK	0xffff
 
 /* Offset 0x16: AVB Command Register */
-#define MV88E6352_G2_AVB_CMD		0x16
+#define MV88E6352_G2_AVB_CMD			0x16
+#define MV88E6352_G2_AVB_CMD_BUSY		0x8000
+#define MV88E6352_G2_AVB_CMD_OP_READ		0x4000
+#define MV88E6352_G2_AVB_CMD_OP_READ_INCR	0x6000
+#define MV88E6352_G2_AVB_CMD_OP_WRITE		0x3000
+#define MV88E6390_G2_AVB_CMD_OP_READ		0x0000
+#define MV88E6390_G2_AVB_CMD_OP_READ_INCR	0x4000
+#define MV88E6390_G2_AVB_CMD_OP_WRITE		0x6000
+#define MV88E6352_G2_AVB_CMD_PORT_MASK		0x0f00
+#define MV88E6352_G2_AVB_CMD_PORT_TAIGLOBAL	0xe
+#define MV88E6352_G2_AVB_CMD_PORT_PTPGLOBAL	0xf
+#define MV88E6390_G2_AVB_CMD_PORT_MASK		0x1f00
+#define MV88E6390_G2_AVB_CMD_PORT_TAIGLOBAL	0x1e
+#define MV88E6390_G2_AVB_CMD_PORT_PTPGLOBAL	0x1f
+#define MV88E6352_G2_AVB_CMD_BLOCK_PTP		0
+#define MV88E6352_G2_AVB_CMD_BLOCK_AVB		1
+#define MV88E6352_G2_AVB_CMD_BLOCK_QAV		2
+#define MV88E6352_G2_AVB_CMD_BLOCK_QVB		3
+#define MV88E6352_G2_AVB_CMD_BLOCK_MASK		0x00e0
+#define MV88E6352_G2_AVB_CMD_ADDR_MASK		0x001f
 
 /* Offset 0x17: AVB Data Register */
 #define MV88E6352_G2_AVB_DATA		0x17
@@ -267,6 +286,9 @@ int mv88e6xxx_g2_pot_clear(struct mv88e6xxx_chip *chip);
 extern const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops;
 extern const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops;
 
+extern const struct mv88e6xxx_avb_ops mv88e6352_avb_ops;
+extern const struct mv88e6xxx_avb_ops mv88e6390_avb_ops;
+
 #else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
@@ -382,6 +404,9 @@ static inline int mv88e6xxx_g2_pot_clear(struct mv88e6xxx_chip *chip)
 static const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {};
 static const struct mv88e6xxx_irq_ops mv88e6390_watchdog_ops = {};
 
+static const struct mv88e6xxx_avb_ops mv88e6352_avb_ops = {};
+static const struct mv88e6xxx_avb_ops mv88e6390_avb_ops = {};
+
 #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 #endif /* _MV88E6XXX_GLOBAL2_H */
-- 
2.1.4
