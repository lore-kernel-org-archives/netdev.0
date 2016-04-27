From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 11/20] net: dsa: mv88e6xxx: use bridge from dsa_port
Date: Wed, 27 Apr 2016 18:30:08 -0400
Message-ID: <1461796217-18893-12-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Change the _mv88e6xxx_port_based_vlan_map function for a
_mv88e6xxx_port_map_vlantable which takes a dsa_port structure as
parameter. This allows us to iterate on dsa_port's bridge device pointer
and thus get rid of the private bridge_dev structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 48 ++++++++++++++++++++++-----------------------
 drivers/net/dsa/mv88e6xxx.h |  1 -
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 0687894..89d0206 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1111,27 +1111,29 @@ static int _mv88e6xxx_port_state(struct dsa_switch *ds, int port, u8 state)
 	return ret;
 }
 
-static int _mv88e6xxx_port_based_vlan_map(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_port_map_vlantable(struct dsa_switch *ds,
+					 struct dsa_port *dp)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	struct net_device *bridge = ps->ports[port].bridge_dev;
 	const u16 mask = (1 << ps->info->num_ports) - 1;
 	u16 output_ports = 0;
+	int port = dp->port;
+	struct dsa_port *intp;
 	int reg;
-	int i;
 
 	/* allow CPU port or DSA link(s) to send frames to every port */
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 		output_ports = mask;
 	} else {
-		for (i = 0; i < ps->info->num_ports; ++i) {
+		dsa_switch_for_each_port(ds, intp, ps->info->num_ports) {
 			/* allow sending frames to every group member */
-			if (bridge && ps->ports[i].bridge_dev == bridge)
-				output_ports |= BIT(i);
+			if (intp->br && intp->br == dp->br)
+				output_ports |= BIT(intp->port);
 
 			/* allow sending frames to CPU port and DSA link(s) */
-			if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
-				output_ports |= BIT(i);
+			if (dsa_is_cpu_port(ds, intp->port) ||
+			    dsa_is_dsa_port(ds, intp->port))
+				output_ports |= BIT(intp->port);
 		}
 	}
 
@@ -2207,16 +2209,15 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
 			       struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i, err;
+	struct dsa_port *intp;
+	int err;
 
 	mutex_lock(&ps->smi_mutex);
 
-	/* Assign the bridge and remap each port's VLANTable */
-	ps->ports[dp->port].bridge_dev = bridge;
-
-	for (i = 0; i < ps->info->num_ports; ++i) {
-		if (ps->ports[i].bridge_dev == bridge) {
-			err = _mv88e6xxx_port_based_vlan_map(ds, i);
+	/* Remap each port's VLANTable */
+	dsa_switch_for_each_port(ds, intp, ps->info->num_ports) {
+		if (intp->br == bridge) {
+			err = _mv88e6xxx_port_map_vlantable(ds, intp);
 			if (err)
 				break;
 		}
@@ -2231,17 +2232,16 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
 				 struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
+	struct dsa_port *intp;
 
 	mutex_lock(&ps->smi_mutex);
 
-	/* Unassign the bridge and remap each port's VLANTable */
-	ps->ports[dp->port].bridge_dev = NULL;
-
-	for (i = 0; i < ps->info->num_ports; ++i)
-		if (i == dp->port || ps->ports[i].bridge_dev == bridge)
-			if (_mv88e6xxx_port_based_vlan_map(ds, i))
-				netdev_warn(ds->ports[i], "failed to remap\n");
+	/* Remap each port's VLANTable */
+	dsa_switch_for_each_port(ds, intp, ps->info->num_ports)
+		if (intp == dp || intp->br == bridge)
+			if (_mv88e6xxx_port_map_vlantable(ds, intp))
+				netdev_warn(ds->ports[intp->port],
+					    "failed to remap\n");
 
 	mutex_unlock(&ps->smi_mutex);
 }
@@ -2573,7 +2573,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, struct dsa_port *dp)
 	if (ret)
 		goto abort;
 
-	ret = _mv88e6xxx_port_based_vlan_map(ds, dp->port);
+	ret = _mv88e6xxx_port_map_vlantable(ds, dp);
 	if (ret)
 		goto abort;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index c49a514..56e3347 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -378,7 +378,6 @@ struct mv88e6xxx_vtu_stu_entry {
 };
 
 struct mv88e6xxx_priv_port {
-	struct net_device *bridge_dev;
 	u8 state;
 };
 
-- 
2.8.0
