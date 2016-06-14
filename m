From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing mode to info
Date: Tue, 14 Jun 2016 14:31:53 -0400
Message-ID: <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the SMI address of the switch chip on the SMI master bus is not
zero, some chips (e.g. 88E6352) use an indirect access through two SMI
Command and Data registers, while others (e.g. 88E6060) still use a
direct access.

Add a capability flag to describe chips supporting the Multi-chip
Addressing Mode.

Use the SMI indirect access ops only for switches with this flag and
change the direct SMI direct access ops to support non-zero chip
address.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c |  6 +++---
 drivers/net/dsa/mv88e6xxx.h | 16 +++++++++++++++-
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fc28a6c..8e12246 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -52,7 +52,7 @@ static int mv88e6xxx_smi_direct_read(struct mii_bus *bus, int sw_addr,
 {
 	int ret;
 
-	ret = mdiobus_read_nested(bus, addr, reg);
+	ret = mdiobus_read_nested(bus, sw_addr + addr, reg);
 	if (ret < 0)
 		return ret;
 
@@ -66,7 +66,7 @@ static int mv88e6xxx_smi_direct_write(struct mii_bus *bus, int sw_addr,
 {
 	int ret;
 
-	ret = mdiobus_write_nested(bus, addr, reg, val);
+	ret = mdiobus_write_nested(bus, sw_addr + addr, reg, val);
 	if (ret < 0)
 		return ret;
 
@@ -3681,7 +3681,7 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
 	u16 id;
 
 	ops = &mv88e6xxx_smi_direct_ops;
-	if (sw_addr > 0)
+	if (sw_addr > 0 && info->flags & MV88E6XXX_FLAG_MULTI_CHIP)
 		ops = &mv88e6xxx_smi_indirect_ops;
 
 	if (ops->read(bus, sw_addr, info->port_base_addr, PORT_SWITCH_ID, &id))
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 100e4e6..3a5ef6a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -387,6 +387,12 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEPROM,
 
+	/* Multi-chip Addressing Mode.
+	 * Some chips require an indirect SMI access when their SMI device
+	 * address is not zero. to See SMI Command and Data Registers.
+	 */
+	MV88E6XXX_CAP_MULTI_CHIP,
+
 	/* Port State Filtering for 802.1D Spanning Tree.
 	 * See PORT_CONTROL_STATE_* values in the PORT_CONTROL register.
 	 */
@@ -439,6 +445,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
+#define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
 #define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
@@ -452,25 +459,29 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_STU |		\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
+	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
@@ -479,6 +490,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_ATU |		\
 	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -490,6 +502,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -503,6 +516,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_ATU |		\
 	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
+	 MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-- 
2.8.3
