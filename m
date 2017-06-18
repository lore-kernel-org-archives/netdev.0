From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: better IEEE Prio Mapping Table description
Date: Sat, 17 Jun 2017 23:07:14 -0400
Message-ID: <20170618030714.32667-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kill the remaining shift macro in favor of calculating at compile time
its value from the more descriptive mask, which gives us a better
representation of the register layout.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 11 +++++------
 drivers/net/dsa/mv88e6xxx/port.h |  4 +++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 73d825e08be3..a7801f6668a5 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -12,6 +12,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/bitfield.h>
 #include <linux/if_bridge.h>
 #include <linux/phy.h>
 
@@ -912,15 +913,13 @@ int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port)
 }
 
 static int mv88e6xxx_port_ieeepmt_write(struct mv88e6xxx_chip *chip,
-					int port, u16 table,
-					u8 pointer, u16 data)
+					int port, u16 table, u8 ptr, u16 data)
 {
 	u16 reg;
 
-	reg = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE |
-		table |
-		(pointer << MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT) |
-		data;
+	reg = MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE | table |
+		(ptr << __bf_shf(MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_PTR_MASK)) |
+		(data & MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_DATA_MASK);
 
 	return mv88e6xxx_port_write(chip, port,
 				    MV88E6390_PORT_IEEE_PRIO_MAP_TABLE, reg);
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 8a34ea7c868a..8f3991bf1851 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -222,6 +222,7 @@
 /* Offset 0x18: IEEE Priority Mapping Table */
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE			0x18
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_UPDATE		0x8000
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_MASK			0x7000
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_INGRESS_PCP		0x0000
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_PCP	0x1000
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_PCP	0x2000
@@ -229,7 +230,8 @@
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_GREEN_DSCP	0x5000
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_YELLOW_DSCP	0x6000
 #define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_EGRESS_AVB_DSCP	0x7000
-#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_POINTER_SHIFT	9
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_PTR_MASK		0x0e00
+#define MV88E6390_PORT_IEEE_PRIO_MAP_TABLE_DATA_MASK		0x01ff
 
 /* Offset 0x18: Port IEEE Priority Remapping Registers (0-3) */
 #define MV88E6095_PORT_IEEE_PRIO_REMAP_0123	0x18
-- 
2.13.1
