From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 01/12] net: dsa: mv88e6xxx: remove basic function flags
Date: Mon, 18 Jul 2016 20:45:29 -0400
Message-ID: <20160719004540.1066-2-vivien.didelot@savoirfairelinux.com>
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

All 88E6xxx Marvell switches (even the old not supported yet 88E6060)
have at least an ATU, per-port STP states and VLAN map, to run basic
switch functions such as Spanning Tree and port based VLANs.

Get rid of the related MV88E6XXX_FLAG_{ATU,PORTSTATE,VLANTABLE} flags,
as they are defaults to every chip.

This enables STP on 6185 and removes many inconsistencies on others.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 23 ------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 46 +++++------------------------------
 2 files changed, 6 insertions(+), 63 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5cb06f7..3feb842 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1460,9 +1460,6 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 	int stp_state;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PORTSTATE))
-		return;
-
 	switch (state) {
 	case BR_STATE_DISABLED:
 		stp_state = PORT_CONTROL_STATE_DISABLED;
@@ -2398,11 +2395,6 @@ static int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 				      const struct switchdev_obj_port_fdb *fdb,
 				      struct switchdev_trans *trans)
 {
-	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
-
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
-		return -EOPNOTSUPP;
-
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -2418,9 +2410,6 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
-		return;
-
 	mutex_lock(&chip->reg_lock);
 	if (_mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port].netdev,
@@ -2434,9 +2423,6 @@ static int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int ret;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&chip->reg_lock);
 	ret = _mv88e6xxx_port_fdb_load(chip, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
@@ -2542,9 +2528,6 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	u16 fid;
 	int err;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_ATU))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&chip->reg_lock);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
@@ -2587,9 +2570,6 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 	int i, err = 0;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VLANTABLE))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&chip->reg_lock);
 
 	/* Assign the bridge and remap each port's VLANTable */
@@ -2614,9 +2594,6 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	struct net_device *bridge = chip->ports[port].bridge_dev;
 	int i;
 
-	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VLANTABLE))
-		return;
-
 	mutex_lock(&chip->reg_lock);
 
 	/* Unassign the bridge and remap each port's VLANTable */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 83f0662..2ff62f4 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -374,11 +374,6 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
-	/* Address Translation Unit.
-	 * The ATU is used to lookup and learn MAC addresses. See GLOBAL_ATU_OP.
-	 */
-	MV88E6XXX_CAP_ATU,
-
 	/* Energy Efficient Ethernet.
 	 */
 	MV88E6XXX_CAP_EEE,
@@ -394,11 +389,6 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_MULTI_CHIP,
 
-	/* Port State Filtering for 802.1D Spanning Tree.
-	 * See PORT_CONTROL_STATE_* values in the PORT_CONTROL register.
-	 */
-	MV88E6XXX_CAP_PORTSTATE,
-
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
 	 */
@@ -430,12 +420,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_TEMP,
 	MV88E6XXX_CAP_TEMP_LIMIT,
 
-	/* In-chip Port Based VLANs.
-	 * Each port VLANTable register (see PORT_BASE_VLAN) is used to restrict
-	 * the output (or egress) ports to which it is allowed to send frames.
-	 */
-	MV88E6XXX_CAP_VLANTABLE,
-
 	/* VLAN Table Unit.
 	 * The VTU is used to program 802.1Q VLANs. See GLOBAL_VTU_OP.
 	 */
@@ -443,11 +427,9 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_MULTI_CHIP	BIT(MV88E6XXX_CAP_MULTI_CHIP)
-#define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
@@ -455,22 +437,17 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
-#define MV88E6XXX_FLAG_VLANTABLE	BIT(MV88E6XXX_CAP_VLANTABLE)
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_STU |		\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
@@ -481,51 +458,40 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_PORTSTATE |	\
+	(MV88E6XXX_FLAG_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_ATU |		\
-	 MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_MULTI_CHIP |	\
-	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_PPU_ACTIVE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_STU |		\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
 	 MV88E6XXX_FLAG_TEMP_LIMIT |	\
-	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 struct mv88e6xxx_info {
-- 
2.9.0
