From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 11/21] net: dsa: mv88e6xxx: factorize ATU access
Date: Fri,  6 May 2016 17:57:13 -0400
Message-ID: <1462571843-14397-12-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a MV88E6XXX_FLAG_ATU flag to identify switch models with an Address
Translation Unit.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  4 ++++
 drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++++++
 drivers/net/dsa/mv88e6xxx.h | 24 ++++++++++++++++++------
 3 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index da5aa9c..45cce4f 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -141,6 +141,10 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
+	.port_fdb_prepare       = mv88e6xxx_port_fdb_prepare,
+	.port_fdb_add           = mv88e6xxx_port_fdb_add,
+	.port_fdb_del           = mv88e6xxx_port_fdb_del,
+	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7994486..dbbda4e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2267,6 +2267,11 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
 			       const struct switchdev_obj_port_fdb *fdb,
 			       struct switchdev_trans *trans)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	/* We don't need any dynamic resource from the kernel (yet),
 	 * so skip the prepare phase.
 	 */
@@ -2282,6 +2287,9 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 		GLOBAL_ATU_DATA_STATE_UC_STATIC;
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port], "failed to load MAC address\n");
@@ -2294,6 +2302,9 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
@@ -2399,6 +2410,9 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	u16 fid;
 	int err;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_ATU))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 4f21206..192292f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -351,6 +351,11 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* Address Translation Unit.
+	 * The ATU is used to lookup and learn MAC addresses. See GLOBAL_ATU_OP.
+	 */
+	MV88E6XXX_CAP_ATU,
+
 	/* Energy Efficient Ethernet.
 	 */
 	MV88E6XXX_CAP_EEE,
@@ -402,6 +407,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
@@ -414,12 +420,14 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
-	(MV88E6XXX_FLAG_PPU |		\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_PPU |		\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
@@ -428,12 +436,14 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_TEMP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
-	(MV88E6XXX_FLAG_PPU |		\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6320	\
-	(MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
@@ -444,7 +454,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_PORTSTATE |	\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
 	 MV88E6XXX_FLAG_SWITCH_MAC |	\
 	 MV88E6XXX_FLAG_TEMP |		\
@@ -452,7 +463,8 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
-	(MV88E6XXX_FLAG_EEE |		\
+	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_EEPROM |	\
 	 MV88E6XXX_FLAG_PORTSTATE |	\
 	 MV88E6XXX_FLAG_SMI_PHY |	\
-- 
2.8.2
