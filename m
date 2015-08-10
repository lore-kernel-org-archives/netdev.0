From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 6/8] net: dsa: mv88e6xxx: rework FDB Get Next operation
Date: Mon, 10 Aug 2015 09:09:51 -0400
Message-ID: <1439212193-7673-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a low level _mv88e6xxx_atu_getnext function for convenient access to
the hardware, and rework the FDB Get Next operation.

This will ease the future integration with VLAN IDs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 80 +++++++++++++++++++++++++++++++++------------
 1 file changed, 59 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2bf8f57..d840490 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1314,12 +1314,14 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
-				    unsigned char *addr, bool *is_static)
+static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
+				  const unsigned char *addr,
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
@@ -1329,27 +1331,36 @@ static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
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
+
+	*entry = next;
 	return 0;
 }
 
@@ -1358,10 +1369,37 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			       unsigned char *addr, u16 *vid, bool *is_static)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
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
-- 
2.5.0
