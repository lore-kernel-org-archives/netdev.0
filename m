From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/8] net: dsa: mv88e6xxx: prefix Global Monitor Control macros
Date: Thu, 15 Jun 2017 12:14:04 -0400
Message-ID: <20170615161406.20546-7-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global Monitor Control Register macros
(which became the Global Monitor & MGMT Control Register with 88E6390)
and give a clear 16-bit registers representation.

Use __bf_shf to get the shift value at compile time instead of adding
new defined macros for it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global1.c | 65 ++++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global1.h | 38 ++++++++++++----------
 2 files changed, 60 insertions(+), 43 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 63e3ad1ba52a..ee77840d5271 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -12,6 +12,8 @@
  * (at your option) any later version.
  */
 
+#include <linux/bitfield.h>
+
 #include "chip.h"
 #include "global1.h"
 
@@ -247,17 +249,17 @@ int mv88e6095_g1_set_egress_port(struct mv88e6xxx_chip *chip, int port)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_MONITOR_CONTROL, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6185_G1_MONITOR_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~(GLOBAL_MONITOR_CONTROL_INGRESS_MASK |
-		 GLOBAL_MONITOR_CONTROL_EGRESS_MASK);
+	reg &= ~(MV88E6185_G1_MONITOR_CTL_INGRESS_DEST_MASK |
+		 MV88E6185_G1_MONITOR_CTL_EGRESS_DEST_MASK);
 
-	reg |= port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT;
+	reg |= port << __bf_shf(MV88E6185_G1_MONITOR_CTL_INGRESS_DEST_MASK) |
+		port << __bf_shf(MV88E6185_G1_MONITOR_CTL_EGRESS_DEST_MASK);
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	return mv88e6xxx_g1_write(chip, MV88E6185_G1_MONITOR_CTL, reg);
 }
 
 /* Older generations also call this the ARP destination. It has been
@@ -269,14 +271,14 @@ int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
 	u16 reg;
 	int err;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_MONITOR_CONTROL, &reg);
+	err = mv88e6xxx_g1_read(chip, MV88E6185_G1_MONITOR_CTL, &reg);
 	if (err)
 		return err;
 
-	reg &= ~GLOBAL_MONITOR_CONTROL_ARP_MASK;
-	reg |= port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	reg &= ~MV88E6185_G1_MONITOR_CTL_ARP_DEST_MASK;
+	reg |= port << __bf_shf(MV88E6185_G1_MONITOR_CTL_ARP_DEST_MASK);
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	return mv88e6xxx_g1_write(chip, MV88E6185_G1_MONITOR_CTL, reg);
 }
 
 static int mv88e6390_g1_monitor_write(struct mv88e6xxx_chip *chip,
@@ -284,55 +286,66 @@ static int mv88e6390_g1_monitor_write(struct mv88e6xxx_chip *chip,
 {
 	u16 reg;
 
-	reg = GLOBAL_MONITOR_CONTROL_UPDATE | pointer | data;
+	reg = MV88E6390_G1_MONITOR_MGMT_CTL_UPDATE | pointer | data;
 
-	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
+	return mv88e6xxx_g1_write(chip, MV88E6390_G1_MONITOR_MGMT_CTL, reg);
 }
 
 int mv88e6390_g1_set_egress_port(struct mv88e6xxx_chip *chip, int port)
 {
+	u16 ptr;
 	int err;
 
-	err = mv88e6390_g1_monitor_write(chip, GLOBAL_MONITOR_CONTROL_INGRESS,
-					 port);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_INGRESS_DEST;
+	err = mv88e6390_g1_monitor_write(chip, ptr, port);
 	if (err)
 		return err;
 
-	return mv88e6390_g1_monitor_write(chip, GLOBAL_MONITOR_CONTROL_EGRESS,
-					  port);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_EGRESS_DEST;
+	err = mv88e6390_g1_monitor_write(chip, ptr, port);
+	if (err)
+		return err;
+
+	return 0;
 }
 
 int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
 {
-	return mv88e6390_g1_monitor_write(chip, GLOBAL_MONITOR_CONTROL_CPU_DEST,
-					  port);
+	u16 ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_CPU_DEST;
+
+	return mv88e6390_g1_monitor_write(chip, ptr, port);
 }
 
 int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 {
+	u16 ptr;
 	int err;
 
 	/* 01:c2:80:00:00:00:00-01:c2:80:00:00:00:07 are Management */
-	err = mv88e6390_g1_monitor_write(
-		chip, GLOBAL_MONITOR_CONTROL_0180C280000000XLO, 0xff);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000000XLO;
+	err = mv88e6390_g1_monitor_write(chip, ptr, 0xff);
 	if (err)
 		return err;
 
 	/* 01:c2:80:00:00:00:08-01:c2:80:00:00:00:0f are Management */
-	err = mv88e6390_g1_monitor_write(
-		chip, GLOBAL_MONITOR_CONTROL_0180C280000000XHI, 0xff);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000000XHI;
+	err = mv88e6390_g1_monitor_write(chip, ptr, 0xff);
 	if (err)
 		return err;
 
 	/* 01:c2:80:00:00:00:20-01:c2:80:00:00:00:27 are Management */
-	err = mv88e6390_g1_monitor_write(
-		chip, GLOBAL_MONITOR_CONTROL_0180C280000002XLO, 0xff);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000002XLO;
+	err = mv88e6390_g1_monitor_write(chip, ptr, 0xff);
 	if (err)
 		return err;
 
 	/* 01:c2:80:00:00:00:28-01:c2:80:00:00:00:2f are Management */
-	return mv88e6390_g1_monitor_write(
-		chip, GLOBAL_MONITOR_CONTROL_0180C280000002XHI, 0xff);
+	ptr = MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000002XHI;
+	err = mv88e6390_g1_monitor_write(chip, ptr, 0xff);
+	if (err)
+		return err;
+
+	return 0;
 }
 
 /* Offset 0x1c: Global Control 2 */
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index af1a510f7a45..020b21c0c9c3 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -156,23 +156,27 @@
 #define GLOBAL_IP_PRI_7		0x17
 #define GLOBAL_IEEE_PRI		0x18
 #define GLOBAL_CORE_TAG_TYPE	0x19
-#define GLOBAL_MONITOR_CONTROL	0x1a
-#define GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT	12
-#define GLOBAL_MONITOR_CONTROL_INGRESS_MASK	(0xf << 12)
-#define GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT	8
-#define GLOBAL_MONITOR_CONTROL_EGRESS_MASK	(0xf << 8)
-#define GLOBAL_MONITOR_CONTROL_ARP_SHIFT	4
-#define GLOBAL_MONITOR_CONTROL_ARP_MASK	        (0xf << 4)
-#define GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT	0
-#define GLOBAL_MONITOR_CONTROL_ARP_DISABLED	(0xf0)
-#define GLOBAL_MONITOR_CONTROL_UPDATE			BIT(15)
-#define GLOBAL_MONITOR_CONTROL_0180C280000000XLO	(0x00 << 8)
-#define GLOBAL_MONITOR_CONTROL_0180C280000000XHI	(0x01 << 8)
-#define GLOBAL_MONITOR_CONTROL_0180C280000002XLO	(0x02 << 8)
-#define GLOBAL_MONITOR_CONTROL_0180C280000002XHI	(0x03 << 8)
-#define GLOBAL_MONITOR_CONTROL_INGRESS			(0x20 << 8)
-#define GLOBAL_MONITOR_CONTROL_EGRESS			(0x21 << 8)
-#define GLOBAL_MONITOR_CONTROL_CPU_DEST			(0x30 << 8)
+
+/* Offset 0x1A: Monitor Control */
+#define MV88E6185_G1_MONITOR_CTL			0x1a
+#define MV88E6185_G1_MONITOR_CTL_INGRESS_DEST_MASK	0xf000
+#define MV88E6185_G1_MONITOR_CTL_EGRESS_DEST_MASK	0x0f00
+#define MV88E6185_G1_MONITOR_CTL_ARP_DEST_MASK	        0x00f0
+#define MV88E6352_G1_MONITOR_CTL_CPU_DEST_MASK	        0x00f0
+#define MV88E6352_G1_MONITOR_CTL_MIRROR_DEST_MASK	0x000f
+
+/* Offset 0x1A: Monitor & MGMT Control Register */
+#define MV88E6390_G1_MONITOR_MGMT_CTL				0x1a
+#define MV88E6390_G1_MONITOR_MGMT_CTL_UPDATE			0x8000
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_MASK			0x3f00
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000000XLO	0x0000
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000000XHI	0x0100
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000002XLO	0x0200
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_0180C280000002XHI	0x0300
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_INGRESS_DEST		0x2000
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_EGRESS_DEST		0x2100
+#define MV88E6390_G1_MONITOR_MGMT_CTL_PTR_CPU_DEST		0x3000
+#define MV88E6390_G1_MONITOR_MGMT_CTL_DATA_MASK			0x00ff
 
 /* Offset 0x1C: Global Control 2 */
 #define MV88E6XXX_G1_CTL2			0x1c
-- 
2.13.1
