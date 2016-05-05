From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 08/20] net: dsa: mv88e6xxx: factorize bridge support
Date: Thu,  5 May 2016 18:40:52 -0400
Message-ID: <1462488064-1841-9-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add MV88E6XXX_FLAG_PORTSTATE and MV88E6XXX_FLAG_VLANTABLE flags to
identify switch models with required 802.1D operations.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  3 +++
 drivers/net/dsa/mv88e6131.c | 13 +++++++++----
 drivers/net/dsa/mv88e6171.c | 24 ++++++++++++++++--------
 drivers/net/dsa/mv88e6352.c | 24 ++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.c |  9 +++++++++
 drivers/net/dsa/mv88e6xxx.h | 13 +++++++++++++
 6 files changed, 68 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index e5335c2..05d5196 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -136,6 +136,9 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_bridge_join	= mv88e6xxx_port_bridge_join,
+	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
+	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 89cabbf..125fbbb 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -24,28 +24,32 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
-		.flags = MV88E6XXX_FLAG_PPU,
+		.flags = MV88E6XXX_FLAG_PPU |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
-		.flags = MV88E6XXX_FLAG_PPU,
+		.flags = MV88E6XXX_FLAG_PPU |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
-		.flags = MV88E6XXX_FLAG_PPU,
+		.flags = MV88E6XXX_FLAG_PPU |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
-		.flags = MV88E6XXX_FLAG_PPU,
+		.flags = MV88E6XXX_FLAG_PPU |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}
 };
 
@@ -168,6 +172,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
+	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,
 	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 6953d12..8ba338d 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,36 +24,44 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY |
+		.flags = MV88E6XXX_FLAG_PORTSTATE |
+			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
-			MV88E6XXX_FLAG_TEMP,
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY |
+		.flags = MV88E6XXX_FLAG_PORTSTATE |
+			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
-			MV88E6XXX_FLAG_TEMP,
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY |
+		.flags = MV88E6XXX_FLAG_PORTSTATE |
+			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
-			MV88E6XXX_FLAG_TEMP,
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY |
+		.flags = MV88E6XXX_FLAG_PORTSTATE |
+			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
-			MV88E6XXX_FLAG_TEMP,
+			MV88E6XXX_FLAG_TEMP |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index d4ebfb3..a67dcf9 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -31,10 +31,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
@@ -43,10 +45,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -55,10 +59,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -67,10 +73,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -79,10 +87,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
@@ -91,10 +101,12 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.num_ports = 7,
 		.flags = MV88E6XXX_FLAG_EEE |
 			MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_PORTSTATE |
 			MV88E6XXX_FLAG_SMI_PHY |
 			MV88E6XXX_FLAG_SWITCH_MAC |
 			MV88E6XXX_FLAG_TEMP |
-			MV88E6XXX_FLAG_TEMP_LIMIT,
+			MV88E6XXX_FLAG_TEMP_LIMIT |
+			MV88E6XXX_FLAG_VLANTABLE,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4ed6379..c6e4254e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1359,6 +1359,9 @@ void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int stp_state;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_PORTSTATE))
+		return;
+
 	switch (state) {
 	case BR_STATE_DISABLED:
 		stp_state = PORT_CONTROL_STATE_DISABLED;
@@ -2420,6 +2423,9 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i, err = 0;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
+		return -EOPNOTSUPP;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Assign the bridge and remap each port's VLANTable */
@@ -2444,6 +2450,9 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	struct net_device *bridge = ps->ports[port].bridge_dev;
 	int i;
 
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_VLANTABLE))
+		return;
+
 	mutex_lock(&ps->smi_mutex);
 
 	/* Unassign the bridge and remap each port's VLANTable */
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 305bccf..bf8475b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -360,6 +360,11 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEPROM,
 
+	/* Port State Filtering for 802.1D Spanning Tree.
+	 * See PORT_CONTROL_STATE_* values in the PORT_CONTROL register.
+	 */
+	MV88E6XXX_CAP_PORTSTATE,
+
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
 	 */
@@ -383,16 +388,24 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_TEMP,
 	MV88E6XXX_CAP_TEMP_LIMIT,
+
+	/* In-chip Port Based VLANs.
+	 * Each port VLANTable register (see PORT_BASE_VLAN) is used to restrict
+	 * the output (or egress) ports to which it is allowed to send frames.
+	 */
+	MV88E6XXX_CAP_VLANTABLE,
 };
 
 /* Bitmask of capabilities */
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
+#define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
 #define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
 #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
 #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
+#define MV88E6XXX_FLAG_VLANTABLE	BIT(MV88E6XXX_CAP_VLANTABLE)
 
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
-- 
2.8.2
