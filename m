From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 5/8] net: dsa: mv88e6xxx: rework FDB add/del operations
Date: Mon, 10 Aug 2015 09:09:50 -0400
Message-ID: <1439212193-7673-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:51565 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbbHJNKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 09:10:17 -0400
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a mv88e6xxx_atu_entry structure and a low level function for the ATU
Load operation, and provide FDB add and delete wrappers functions.

This implementation handles the eventual trunk mapping. If the related
bit is set, then the ATU data register would contain the trunk ID, and
not the port vector.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 69 +++++++++++++++++++++++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx.h | 10 +++++++
 2 files changed, 67 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 00f983b..2bf8f57 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1214,29 +1214,74 @@ static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, unsigned char *addr)
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
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
+
+		if (entry->trunk) {
+			reg |= GLOBAL_ATU_DATA_TRUNK;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
+
+		reg |= (entry->portv_trunkid << shift) & mask;
+	}
+
+	reg |= entry->state & GLOBAL_ATU_DATA_STATE_MASK;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, reg);
+	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_LOAD_DB);
+	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
+}
 
-	return ret;
+static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (vid == 0)
+		return ps->fid[port];
+
+	return -ENOENT;
+}
+
+static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
+				    const unsigned char *addr, u16 vid,
+				    u8 state)
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
 }
 
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
@@ -1249,7 +1294,7 @@ int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, state);
+	ret = _mv88e6xxx_port_fdb_load(ds, port, addr, vid, state);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -1262,7 +1307,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr,
+	ret = _mv88e6xxx_port_fdb_load(ds, port, addr, vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&ps->smi_mutex);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 0cf470c..bd42a15 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -207,6 +207,8 @@
 #define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_DATA		0x0c
 #define GLOBAL_ATU_DATA_TRUNK			BIT(15)
+#define GLOBAL_ATU_DATA_TRUNK_ID_MASK		0x00f0
+#define GLOBAL_ATU_DATA_TRUNK_ID_SHIFT		4
 #define GLOBAL_ATU_DATA_PORT_VECTOR_MASK	0x3ff0
 #define GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT	4
 #define GLOBAL_ATU_DATA_STATE_MASK		0x0f
@@ -313,6 +315,14 @@
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
-- 
2.5.0
