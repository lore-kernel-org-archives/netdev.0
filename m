From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/10] net: dsa: mv88e6xxx: add mv88e6xxx_num_ports helper
Date: Thu, 29 Sep 2016 12:21:57 -0400
Message-ID: <20160929162202.10685-6-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an mv88e6xxx_num_ports helper instead of digging in the chip info
structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 30 +++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global2.c   |  8 ++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  5 +++++
 3 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6a55bba..9056d9e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -613,7 +613,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
 
 	if ((mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip)) &&
-	    (port >= chip->info->num_ports - 2)) {
+	    (port >= mv88e6xxx_num_ports(chip) - 2)) {
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
@@ -1112,7 +1112,7 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
 	struct net_device *bridge = chip->ports[port].bridge_dev;
-	const u16 mask = (1 << chip->info->num_ports) - 1;
+	const u16 mask = (1 << mv88e6xxx_num_ports(chip)) - 1;
 	struct dsa_switch *ds = chip->ds;
 	u16 output_ports = 0;
 	u16 reg;
@@ -1123,7 +1123,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 		output_ports = mask;
 	} else {
-		for (i = 0; i < chip->info->num_ports; ++i) {
+		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 			/* allow sending frames to every group member */
 			if (bridge && chip->ports[i].bridge_dev == bridge)
 				output_ports |= BIT(i);
@@ -1279,7 +1279,7 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 			return err;
 	}
 
-	for (i = 0; i < chip->info->num_ports; ++i) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u16 reg = regs[i / 4];
 
@@ -1308,7 +1308,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 	u16 regs[3] = { 0 };
 	int i, err;
 
-	for (i = 0; i < chip->info->num_ports; ++i) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
 		u8 data = entry->data[i];
 
@@ -1658,7 +1658,7 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	bitmap_zero(fid_bitmap, MV88E6XXX_N_FID);
 
 	/* Set every FID bit used by the (un)bridged ports */
-	for (i = 0; i < chip->info->num_ports; ++i) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		err = _mv88e6xxx_port_fid_get(chip, i, fid);
 		if (err)
 			return err;
@@ -1708,7 +1708,7 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 		return err;
 
 	/* exclude all ports except the CPU and DSA ports */
-	for (i = 0; i < chip->info->num_ports; ++i)
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
 		vlan.data[i] = dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i)
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
@@ -1797,7 +1797,7 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 		if (vlan.vid > vid_end)
 			break;
 
-		for (i = 0; i < chip->info->num_ports; ++i) {
+		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
 				continue;
 
@@ -1959,7 +1959,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
-	for (i = 0; i < chip->info->num_ports; ++i) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
 			continue;
 
@@ -2340,7 +2340,7 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	/* Assign the bridge and remap each port's VLANTable */
 	chip->ports[port].bridge_dev = bridge;
 
-	for (i = 0; i < chip->info->num_ports; ++i) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 		if (chip->ports[i].bridge_dev == bridge) {
 			err = _mv88e6xxx_port_based_vlan_map(chip, i);
 			if (err)
@@ -2364,7 +2364,7 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	/* Unassign the bridge and remap each port's VLANTable */
 	chip->ports[port].bridge_dev = NULL;
 
-	for (i = 0; i < chip->info->num_ports; ++i)
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
 		if (i == port || chip->ports[i].bridge_dev == bridge)
 			if (_mv88e6xxx_port_based_vlan_map(chip, i))
 				netdev_warn(ds->ports[i].netdev,
@@ -2384,7 +2384,7 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	int i;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < chip->info->num_ports; i++) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
 		err = mv88e6xxx_port_read(chip, i, PORT_CONTROL, &reg);
 		if (err)
 			return err;
@@ -2885,7 +2885,7 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 		goto unlock;
 
 	/* Setup Switch Port Registers */
-	for (i = 0; i < chip->info->num_ports; i++) {
+	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
 		err = mv88e6xxx_setup_port(chip, i);
 		if (err)
 			goto unlock;
@@ -2933,7 +2933,7 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	u16 val;
 	int err;
 
-	if (phy >= chip->info->num_ports)
+	if (phy >= mv88e6xxx_num_ports(chip))
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
@@ -2948,7 +2948,7 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	struct mv88e6xxx_chip *chip = bus->priv;
 	int err;
 
-	if (phy >= chip->info->num_ports)
+	if (phy >= mv88e6xxx_num_ports(chip))
 		return 0xffff;
 
 	mutex_lock(&chip->reg_lock);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index f31d553..cf686e7 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -74,7 +74,7 @@ static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
 static int mv88e6xxx_g2_trunk_mask_write(struct mv88e6xxx_chip *chip, int num,
 					 bool hask, u16 mask)
 {
-	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	const u16 port_mask = BIT(mv88e6xxx_num_ports(chip)) - 1;
 	u16 val = (num << 12) | (mask & port_mask);
 
 	if (hask)
@@ -88,7 +88,7 @@ static int mv88e6xxx_g2_trunk_mask_write(struct mv88e6xxx_chip *chip, int num,
 static int mv88e6xxx_g2_trunk_mapping_write(struct mv88e6xxx_chip *chip, int id,
 					    u16 map)
 {
-	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	const u16 port_mask = BIT(mv88e6xxx_num_ports(chip)) - 1;
 	u16 val = (id << 11) | (map & port_mask);
 
 	return mv88e6xxx_g2_update(chip, GLOBAL2_TRUNK_MAPPING, val);
@@ -96,7 +96,7 @@ static int mv88e6xxx_g2_trunk_mapping_write(struct mv88e6xxx_chip *chip, int id,
 
 static int mv88e6xxx_g2_clear_trunk(struct mv88e6xxx_chip *chip)
 {
-	const u16 port_mask = BIT(chip->info->num_ports) - 1;
+	const u16 port_mask = BIT(mv88e6xxx_num_ports(chip)) - 1;
 	int i, err;
 
 	/* Clear all eight possible Trunk Mask vectors */
@@ -125,7 +125,7 @@ static int mv88e6xxx_g2_clear_irl(struct mv88e6xxx_chip *chip)
 	int port, err;
 
 	/* Init all Ingress Rate Limit resources of all ports */
-	for (port = 0; port < chip->info->num_ports; ++port) {
+	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
 		/* XXX newer chips (like 88E6390) have different 2-bit ops */
 		err = mv88e6xxx_g2_write(chip, GLOBAL2_IRL_CMD,
 					 GLOBAL2_IRL_CMD_OP_INIT_ALL |
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 20fe6c6..cf639ed 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -737,6 +737,11 @@ static inline unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_chip *chip)
 	return chip->info->num_databases;
 }
 
+static inline unsigned int mv88e6xxx_num_ports(struct mv88e6xxx_chip *chip)
+{
+	return chip->info->num_ports;
+}
+
 int mv88e6xxx_read(struct mv88e6xxx_chip *chip, int addr, int reg, u16 *val);
 int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
-- 
2.10.0
