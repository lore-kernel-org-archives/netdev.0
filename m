From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 10/20] net: dsa: mv88e6xxx: setup a dsa_port
Date: Wed, 27 Apr 2016 18:30:07 -0400
Message-ID: <1461796217-18893-11-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Change the mv88e6xxx_setup_port function to take a dsa_port structure as
parameter instead of a port index. This will help us get rid of the
private bridge_dev pointer.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 64 ++++++++++++++++++++++++---------------------
 1 file changed, 34 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 00a0b92..0687894 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2317,7 +2317,7 @@ static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
 	return ret;
 }
 
-static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
+static int mv88e6xxx_setup_port(struct dsa_switch *ds, struct dsa_port *dp)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -2335,8 +2335,10 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * and all DSA ports to their maximum bandwidth and
 		 * full duplex.
 		 */
-		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
-		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
+		reg = _mv88e6xxx_reg_read(ds, REG_PORT(dp->port),
+					  PORT_PCS_CTRL);
+		if (dsa_is_cpu_port(ds, dp->port) ||
+		    dsa_is_dsa_port(ds, dp->port)) {
 			reg &= ~PORT_PCS_CTRL_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
@@ -2350,7 +2352,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_PCS_CTRL_UNFORCED;
 		}
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_PCS_CTRL, reg);
 		if (ret)
 			goto abort;
@@ -2378,7 +2380,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
-	if (dsa_is_cpu_port(ds, port)) {
+	if (dsa_is_cpu_port(ds, dp->port)) {
 		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
 			reg |= PORT_CONTROL_DSA_TAG;
 		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
@@ -2400,7 +2402,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
-	if (dsa_is_dsa_port(ds, port)) {
+	if (dsa_is_dsa_port(ds, dp->port)) {
 		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
 			reg |= PORT_CONTROL_DSA_TAG;
 		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
@@ -2409,13 +2411,13 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
 		}
 
-		if (port == dsa_upstream_port(ds))
+		if (dp->port == dsa_upstream_port(ds))
 			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 	}
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
-					   PORT_CONTROL, reg);
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port), PORT_CONTROL,
+					   reg);
 		if (ret)
 			goto abort;
 	}
@@ -2424,7 +2426,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * powered down.
 	 */
 	if (mv88e6xxx_6352_family(ds)) {
-		ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
+		ret = _mv88e6xxx_reg_read(ds, REG_PORT(dp->port), PORT_STATUS);
 		if (ret < 0)
 			goto abort;
 		ret &= PORT_STATUS_CMODE_MASK;
@@ -2460,14 +2462,14 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		/* enable forwarding of unknown multicast addresses to
 		 * the upstream port
 		 */
-		if (port == dsa_upstream_port(ds))
+		if (dp->port == dsa_upstream_port(ds))
 			reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
 	}
 
 	reg |= PORT_CONTROL_2_8021Q_DISABLED;
 
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_CONTROL_2, reg);
 		if (ret)
 			goto abort;
@@ -2478,17 +2480,18 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
 	 */
-	reg = 1 << port;
+	reg = 1 << dp->port;
 	/* Disable learning for CPU port */
-	if (dsa_is_cpu_port(ds, port))
+	if (dsa_is_cpu_port(ds, dp->port))
 		reg = 0;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port), PORT_ASSOC_VECTOR,
+				   reg);
 	if (ret)
 		goto abort;
 
 	/* Egress rate control 2: disable egress rate control. */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_RATE_CONTROL_2,
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port), PORT_RATE_CONTROL_2,
 				   0x0000);
 	if (ret)
 		goto abort;
@@ -2500,7 +2503,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * be paused for by the remote end or the period of
 		 * time that this port can pause the remote end.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_PAUSE_CTRL, 0x0000);
 		if (ret)
 			goto abort;
@@ -2509,12 +2512,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * address database entries that this port is allowed
 		 * to use.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_ATU_CONTROL, 0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_PRI_OVERRIDE, 0x0000);
 		if (ret)
 			goto abort;
@@ -2522,14 +2525,14 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_ETH_TYPE, ETH_P_EDSA);
 		if (ret)
 			goto abort;
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_TAG_REGMAP_0123, 0x3210);
 		if (ret)
 			goto abort;
@@ -2537,7 +2540,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		/* Tag Remap 2: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_TAG_REGMAP_4567, 0x7654);
 		if (ret)
 			goto abort;
@@ -2548,7 +2551,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
 	    mv88e6xxx_6320_family(ds)) {
 		/* Rate Control: disable ingress rate limiting. */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port),
 					   PORT_RATE_CONTROL, 0x0001);
 		if (ret)
 			goto abort;
@@ -2557,7 +2560,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1, 0x0000);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port), PORT_CONTROL_1,
+				   0x0000);
 	if (ret)
 		goto abort;
 
@@ -2565,18 +2569,18 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * database, and allow bidirectional communication between the
 	 * CPU and DSA port(s), and the other ports.
 	 */
-	ret = _mv88e6xxx_port_fid_set(ds, port, 0);
+	ret = _mv88e6xxx_port_fid_set(ds, dp->port, 0);
 	if (ret)
 		goto abort;
 
-	ret = _mv88e6xxx_port_based_vlan_map(ds, port);
+	ret = _mv88e6xxx_port_based_vlan_map(ds, dp->port);
 	if (ret)
 		goto abort;
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(dp->port), PORT_DEFAULT_VLAN,
 				   0x0000);
 abort:
 	mutex_unlock(&ps->smi_mutex);
@@ -2586,11 +2590,11 @@ abort:
 int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_port *dp;
 	int ret;
-	int i;
 
-	for (i = 0; i < ps->info->num_ports; i++) {
-		ret = mv88e6xxx_setup_port(ds, i);
+	dsa_switch_for_each_port(ds, dp, ps->info->num_ports) {
+		ret = mv88e6xxx_setup_port(ds, dp);
 		if (ret < 0)
 			return ret;
 	}
-- 
2.8.0
