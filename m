From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 17/20] net: dsa: mv88e6xxx: factorize port bridge change
Date: Wed, 27 Apr 2016 18:30:14 -0400
Message-ID: <1461796217-18893-18-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement a mv88e6xxx_port_bridge_change function to factorize the
configuration needed when a port joins or leaves a bridge group.

This will simplify the implementation of cross-chip bridging.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 67 +++++++++++++++++++++++++++------------------
 1 file changed, 40 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8004d00..25852ee 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1150,6 +1150,24 @@ static int _mv88e6xxx_port_map_vlantable(struct dsa_switch *ds,
 	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
+static int _mv88e6xxx_remap_vlantable(struct dsa_switch *ds,
+				      struct net_device *bridge)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_port *intp;
+	int err;
+
+	dsa_switch_for_each_port(ds, intp, ps->info->num_ports) {
+		if (intp->br == bridge) {
+			err = _mv88e6xxx_port_map_vlantable(ds, intp);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
 void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -2229,51 +2247,46 @@ unlock:
 	return err;
 }
 
-int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
-			       struct net_device *bridge)
+int mv88e6xxx_port_bridge_change(struct dsa_switch *ds, struct dsa_port *dp,
+				 struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct dsa_port *intp;
 	int err;
 
-	if (dsa_port_is_external(dp, ds))
-		return -EOPNOTSUPP;
-
 	mutex_lock(&ps->smi_mutex);
 
-	/* Remap each port's VLANTable */
-	dsa_switch_for_each_port(ds, intp, ps->info->num_ports) {
-		if (intp->br == bridge) {
-			err = _mv88e6xxx_port_map_vlantable(ds, intp);
+	if (dsa_port_is_external(dp, ds)) {
+		err = -EOPNOTSUPP;
+	} else {
+		/* Remap VLANTable of concerned in-chip ports */
+		if (!dp->br) {
+			err = _mv88e6xxx_port_map_vlantable(ds, dp);
 			if (err)
-				break;
+				goto unlock;
 		}
+
+		err = _mv88e6xxx_remap_vlantable(ds, bridge);
+		if (err)
+			goto unlock;
 	}
 
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return err;
 }
 
+int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
+			       struct net_device *bridge)
+{
+	return mv88e6xxx_port_bridge_change(ds, dp, bridge);
+}
+
 void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
 				 struct net_device *bridge)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct dsa_port *intp;
-
-	if (dsa_port_is_external(dp, ds))
-		return;
-
-	mutex_lock(&ps->smi_mutex);
-
-	/* Remap each port's VLANTable */
-	dsa_switch_for_each_port(ds, intp, ps->info->num_ports)
-		if (intp == dp || intp->br == bridge)
-			if (_mv88e6xxx_port_map_vlantable(ds, intp))
-				netdev_warn(ds->ports[intp->port],
-					    "failed to remap\n");
-
-	mutex_unlock(&ps->smi_mutex);
+	if (mv88e6xxx_port_bridge_change(ds, dp, bridge))
+		netdev_err(ds->ports[dp->port], "failed to unbridge\n");
 }
 
 static void mv88e6xxx_bridge_work(struct work_struct *work)
-- 
2.8.0
