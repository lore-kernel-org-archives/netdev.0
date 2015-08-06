From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 6/7] net: dsa: mv88e6xxx: rework FDB getnext operation
Date: Thu,  6 Aug 2015 01:44:07 -0400
Message-ID: <1438839848-505-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds a low level _mv88e6xxx_atu_getnext function and helpers
to rewrite the mv88e6xxx_port_fdb_getnext operation.

A mv88e6xxx_atu_entry structure is added for convenient access to the
hardware, and GLOBAL_ATU_FID is defined instead of the raw 0x01 value.

The previous implementation did not handle the eventual trunk mapping.
If the related bit is set, then the ATU data register would contain the
trunk ID, and not the port vector.

Check this in the FDB getnext operation and do not handle it (yet).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 97 +++++++++++++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx.h | 15 ++++++-
 4 files changed, 87 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index cfa21ed..b99fa50 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -116,6 +116,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge       = mv88e6xxx_join_bridge,
 	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index eb4630f..0a77135 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -341,6 +341,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9dad0a7..6cad168 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -964,7 +964,7 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 	if (ret < 0)
 		return ret;
 
@@ -1269,12 +1269,14 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
-				    unsigned char *addr, bool *is_static)
+static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
+				  const u8 addr[ETH_ALEN],
+				  struct mv88e6xxx_atu_entry *entry)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid = ps->fid[port];
-	int ret, state;
+	struct mv88e6xxx_atu_entry next = { 0 };
+	int ret;
+
+	next.fid = fid;
 
 	ret = _mv88e6xxx_atu_wait(ds);
 	if (ret < 0)
@@ -1284,39 +1286,84 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
 	if (ret < 0)
 		return ret;
 
-	do {
-		ret = _mv88e6xxx_atu_cmd(ds, fid,  GLOBAL_ATU_OP_GET_NEXT_DB);
-		if (ret < 0)
-			return ret;
+	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	if (ret < 0)
+		return ret;
 
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
-		if (ret < 0)
-			return ret;
-		state = ret & GLOBAL_ATU_DATA_STATE_MASK;
-		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			return -ENOENT;
-	} while (!(((ret >> 4) & 0xff) & (1 << port)));
+	ret = _mv88e6xxx_atu_mac_read(ds, next.mac);
+	if (ret < 0)
+		return ret;
 
-	ret = _mv88e6xxx_atu_mac_read(ds, addr);
+	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
 	if (ret < 0)
 		return ret;
 
-	*is_static = state == (is_multicast_ether_addr(addr) ?
-			       GLOBAL_ATU_DATA_STATE_MC_STATIC :
-			       GLOBAL_ATU_DATA_STATE_UC_STATIC);
+	next.state = ret & GLOBAL_ATU_DATA_STATE_MASK;
+	if (next.state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
+
+		if (ret & GLOBAL_ATU_DATA_TRUNK) {
+			next.trunk = true;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			next.trunk = false;
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
+
+		next.portv_trunkid = (ret & mask) >> shift;
+	}
 
+	*entry = next;
 	return 0;
 }
 
-/* get next entry for port */
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static)
+static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (vid == 0)
+		return ps->fid[port];
+
+	return -ENOENT;
+}
+
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
+			       u8 addr[ETH_ALEN], bool *is_static)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_atu_entry next;
+	u16 fid;
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_getnext(ds, port, addr, is_static);
+
+	ret = _mv88e6xxx_port_vid_to_fid(ds, port, *vid);
+	if (ret < 0)
+		goto unlock;
+	fid = ret;
+
+	do {
+		if (is_broadcast_ether_addr(addr)) {
+			ret = -ENOENT;
+			goto unlock;
+		}
+
+		ret = _mv88e6xxx_atu_getnext(ds, fid, addr, &next);
+		if (ret < 0)
+			goto unlock;
+
+		ether_addr_copy(addr, next.mac);
+
+		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
+			continue;
+	} while (next.trunk || (next.portv_trunkid & BIT(port)) == 0);
+
+	*is_static = next.state == (is_multicast_ether_addr(addr) ?
+				    GLOBAL_ATU_DATA_STATE_MC_STATIC :
+				    GLOBAL_ATU_DATA_STATE_UC_STATIC);
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6d65b99..d9bd6a0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -172,6 +172,7 @@
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
+#define GLOBAL_ATU_FID		0x01	/* 6097 6165 6351 6352 */
 #define GLOBAL_CONTROL		0x04
 #define GLOBAL_CONTROL_SW_RESET		BIT(15)
 #define GLOBAL_CONTROL_PPU_ENABLE	BIT(14)
@@ -206,6 +207,8 @@
 #define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_DATA		0x0c
 #define GLOBAL_ATU_DATA_TRUNK			BIT(15)
+#define GLOBAL_ATU_DATA_TRUNK_ID_MASK		0x00f0
+#define GLOBAL_ATU_DATA_TRUNK_ID_SHIFT		4
 #define GLOBAL_ATU_DATA_PORT_VECTOR_MASK	0x3ff0
 #define GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT	4
 #define GLOBAL_ATU_DATA_STATE_MASK		0x0f
@@ -312,6 +315,14 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+struct mv88e6xxx_atu_entry {
+	u16	fid;
+	u8	state;
+	bool	trunk;
+	u16	portv_trunkid;
+	u8	mac[ETH_ALEN];
+};
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -416,11 +427,11 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
-int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
-			       unsigned char *addr, bool *is_static);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
+			       u8 addr[ETH_ALEN], bool *is_static);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.4.6
