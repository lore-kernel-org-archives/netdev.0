From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 20/20] net: dsa: mv88e6xxx: setup PVT on cross-chip ops
Date: Wed, 27 Apr 2016 18:30:17 -0400
Message-ID: <1461796217-18893-21-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Switches with a Cross-chip Port VLAN Table are currently configured to
allow cross-chip frames to egress any internal ports. This means that
unbridged cross-chip ports can actually talk to each other, and this is
not what we want.

In order to restrict that, we need to setup the PVT entry for an
external port when it joins or leave a bridge group crossing the switch.

Also initialize the PVT to forbid egressing of cross-chip frames to
internal user ports by default.

Note that a PVT-less switch cannot forbid such frames to egress its
internal ports, unless the kernel supports VLAN filtering. In such
systems, a bridge group is also implemented as a 802.1Q VLAN and thus a
global VTU-based logic can be used to correctly implement cross-chip
hardware bridging. Warn the user if the setup doesn't respect this.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 98 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4341ffd..e0f9e93 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2272,8 +2272,29 @@ static int _mv88e6xxx_pvt_cmd(struct dsa_switch *ds, int src_dev, int src_port,
 	return _mv88e6xxx_pvt_wait(ds);
 }
 
+static int _mv88e6xxx_pvt_write(struct dsa_switch *ds, int src_dev,
+				int src_port, u16 data)
+{
+	int err;
+
+	err = _mv88e6xxx_pvt_wait(ds);
+	if (err)
+		return err;
+
+	err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_PVT_DATA, data);
+	if (err)
+		return err;
+
+        return _mv88e6xxx_pvt_cmd(ds, src_dev, src_port,
+				  GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN);
+}
+
 static int _mv88e6xxx_pvt_init(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_port *intp;
+	int src_dev, src_port;
+	u16 pv = 0;
 	int err;
 
 	/* Clear 5 Bit Port for usage with Marvell Link Street devices:
@@ -2284,8 +2305,60 @@ static int _mv88e6xxx_pvt_init(struct dsa_switch *ds)
 	if (err)
 		return err;
 
-	/* Allow any cross-chip frames to egress any internal ports */
-	return _mv88e6xxx_pvt_cmd(ds, 0, 0, GLOBAL2_PVT_ADDR_OP_INIT_ONES);
+	/* Forbid cross-chip frames to egress internal ports */
+	dsa_switch_for_each_port(ds, intp, ps->info->num_ports)
+		if (dsa_is_cpu_port(ds, intp->port) ||
+		    dsa_is_dsa_port(ds, intp->port))
+			pv |= BIT(intp->port);
+
+	for (src_dev = 0; src_dev < 32; ++src_dev) {
+		for (src_port = 0; src_port < 16; ++src_port) {
+			err = _mv88e6xxx_pvt_write(ds, src_dev, src_port, pv);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
+static int _mv88e6xxx_port_map_pvt(struct dsa_switch *ds, struct dsa_port *dp)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_port *intp;
+	u16 pvlan = 0;
+
+	/* Cross-chip frames can egress CPU and DSA ports, and bridge members */
+	dsa_switch_for_each_port(ds, intp, ps->info->num_ports)
+		if (dsa_is_cpu_port(ds, intp->port) ||
+		    dsa_is_dsa_port(ds, intp->port) ||
+		    (intp->br && intp->br == dp->br))
+			pvlan |= BIT(intp->port);
+
+	return _mv88e6xxx_pvt_write(ds, dp->ds->index, dp->port, pvlan);
+}
+
+static int _mv88e6xxx_remap_pvt(struct dsa_switch *ds,
+				struct net_device *bridge)
+{
+	struct dsa_switch *dsa_sw;
+	struct dsa_port *dsa_p;
+	int err;
+
+	dsa_tree_for_each_switch(ds->dst, dsa_sw) {
+		if (dsa_sw == ds)
+			continue;
+
+		dsa_switch_for_each_port(dsa_sw, dsa_p, DSA_MAX_PORTS) {
+			if (dsa_p->br == bridge) {
+				err = _mv88e6xxx_port_map_pvt(ds, dsa_p);
+				if (err)
+					return err;
+			}
+		}
+	}
+
+	return 0;
 }
 
 int mv88e6xxx_port_bridge_change(struct dsa_switch *ds, struct dsa_port *dp,
@@ -2297,7 +2370,19 @@ int mv88e6xxx_port_bridge_change(struct dsa_switch *ds, struct dsa_port *dp,
 	mutex_lock(&ps->smi_mutex);
 
 	if (dsa_port_is_external(dp, ds)) {
-		err = -EOPNOTSUPP;
+		/* Forbidding hardware bridging of cross-chip frames requires a
+		 * Cross-chip Port VLAN Table (PVT), unless VLAN filtering is
+		 * enabled, in which case a global VTU-based logic works.
+		 */
+		if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PVT)) {
+			err = _mv88e6xxx_port_map_pvt(ds, dp);
+		} else if (IS_ENABLED(CONFIG_BRIDGE_VLAN_FILTERING)) {
+			err = 0;
+		} else {
+			pr_warn("%s: cannot prevent cross-chip frames without CONFIG_BRIDGE_VLAN_FILTERING\n",
+				ps->info->name);
+			err = -EOPNOTSUPP;
+		}
 	} else {
 		/* Remap VLANTable of concerned in-chip ports */
 		if (!dp->br) {
@@ -2309,6 +2394,13 @@ int mv88e6xxx_port_bridge_change(struct dsa_switch *ds, struct dsa_port *dp,
 		err = _mv88e6xxx_remap_vlantable(ds, bridge);
 		if (err)
 			goto unlock;
+
+		/* Remap PVT entries of concerned cross-chip ports */
+		if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PVT)) {
+			err = _mv88e6xxx_remap_pvt(ds, bridge);
+			if (err)
+				goto unlock;
+		}
 	}
 
 unlock:
-- 
2.8.0
