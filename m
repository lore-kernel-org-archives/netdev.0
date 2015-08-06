From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 7/7] net: dsa: mv88e6xxx: rework FDB add/del operations
Date: Thu,  6 Aug 2015 01:44:08 -0400
Message-ID: <1438839848-505-8-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Add a low level function for the ATU Load operation, and provide FDB add
and delete wrappers functions.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |   2 +
 drivers/net/dsa/mv88e6352.c |   2 +
 drivers/net/dsa/mv88e6xxx.c | 110 +++++++++++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx.h |   8 ++--
 4 files changed, 80 insertions(+), 42 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index b99fa50..735f04c 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -116,6 +116,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_join_bridge       = mv88e6xxx_join_bridge,
 	.port_leave_bridge      = mv88e6xxx_leave_bridge,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 0a77135..191fb25 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -341,6 +341,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.port_fdb_add		= mv88e6xxx_port_fdb_add,
+	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6cad168..39203bb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1214,59 +1214,42 @@ static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, u8 addr[ETH_ALEN])
 	return 0;
 }
 
-static int __mv88e6xxx_port_fdb_cmd(struct dsa_switch *ds, int port,
-				    const unsigned char *addr, int state)
+static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
+			       struct mv88e6xxx_atu_entry *entry)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	u8 fid = ps->fid[port];
+	u16 reg = 0;
 	int ret;
 
 	ret = _mv88e6xxx_atu_wait(ds);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_write(ds, addr);
+	ret = _mv88e6xxx_atu_mac_write(ds, entry->mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA,
-				   (0x10 << port) | state);
-	if (ret)
-		return ret;
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_LOAD_DB);
+		if (entry->trunk) {
+			reg |= GLOBAL_ATU_DATA_TRUNK;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
 
-	return ret;
-}
+		reg |= (entry->portv_trunkid << shift) & mask;
+	}
 
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
-{
-	int state = is_multicast_ether_addr(addr) ?
-		GLOBAL_ATU_DATA_STATE_MC_STATIC :
-		GLOBAL_ATU_DATA_STATE_UC_STATIC;
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
+	reg |= entry->state & GLOBAL_ATU_DATA_STATE_MASK;
 
-	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, state);
-	mutex_unlock(&ps->smi_mutex);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, reg);
+	if (ret < 0)
+		return ret;
 
-	return ret;
-}
-
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr,
-				       GLOBAL_ATU_DATA_STATE_UNUSED);
-	mutex_unlock(&ps->smi_mutex);
-
-	return ret;
+	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
 static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
@@ -1329,6 +1312,57 @@ static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
 	return -ENOENT;
 }
 
+static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port, u16 vid,
+				    const u8 addr[ETH_ALEN], u8 state)
+{
+	struct mv88e6xxx_atu_entry entry = { 0 };
+	int ret;
+
+	ret = _mv88e6xxx_port_vid_to_fid(ds, port, vid);
+	if (ret < 0)
+		return ret;
+
+	entry.fid = ret;
+	entry.state = state;
+	ether_addr_copy(entry.mac, addr);
+	if (state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		entry.trunk = false;
+		entry.portv_trunkid = BIT(port);
+	}
+
+	return _mv88e6xxx_atu_load(ds, &entry);
+}
+
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port, u16 vid,
+			   const u8 addr[ETH_ALEN])
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 state = is_multicast_ether_addr(addr) ?
+		GLOBAL_ATU_DATA_STATE_MC_STATIC :
+		GLOBAL_ATU_DATA_STATE_UC_STATIC;
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_port_fdb_load(ds, port, vid, addr, state);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port, u16 vid,
+			   const u8 addr[ETH_ALEN])
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 state = GLOBAL_ATU_DATA_STATE_UNUSED;
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_port_fdb_load(ds, port, vid, addr, state);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
 			       u8 addr[ETH_ALEN], bool *is_static)
 {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index d9bd6a0..1821095 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -423,13 +423,13 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
-int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
-int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
-			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
 int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port, u16 vid,
+			   const u8 addr[ETH_ALEN]);
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port, u16 vid,
+			   const u8 addr[ETH_ALEN]);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port, u16 *vid,
 			       u8 addr[ETH_ALEN], bool *is_static);
 
-- 
2.4.6
