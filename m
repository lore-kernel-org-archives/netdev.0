From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/9] net: dsa: use dsa_is_user_port everywhere
Date: Thu, 26 Oct 2017 11:22:55 -0400
Message-ID: <20171026152259.3123-6-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the DSA code still check ds->enabled_port_mask directly to
inspect a given port type instead of using the provided dsa_is_user_port
helper. Change this.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c     | 9 ++++-----
 drivers/net/dsa/bcm_sf2_cfp.c | 2 +-
 drivers/net/dsa/mt7530.c      | 4 ++--
 drivers/net/dsa/qca8k.c       | 4 ++--
 net/dsa/dsa.c                 | 2 +-
 net/dsa/legacy.c              | 4 ++--
 6 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 2574a52ee161..7f47400e557e 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -652,8 +652,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	 * bcm_sf2_sw_setup
 	 */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if ((1 << port) & ds->enabled_port_mask ||
-		    dsa_is_cpu_port(ds, port))
+		if (dsa_is_user_port(ds, port) || dsa_is_cpu_port(ds, port))
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
@@ -676,7 +675,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 		bcm_sf2_gphy_enable_set(ds, true);
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if ((1 << port) & ds->enabled_port_mask)
+		if (dsa_is_user_port(ds, port))
 			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
@@ -771,7 +770,7 @@ static void bcm_sf2_sw_configure_vlan(struct dsa_switch *ds)
 	bcm_sf2_vlan_op(priv, ARLA_VTBL_CMD_CLEAR);
 
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
-		if (!((1 << port) & ds->enabled_port_mask))
+		if (!dsa_is_user_port(ds, port))
 			continue;
 
 		core_writel(priv, 1, CORE_DEFAULT_1Q_TAG_P(port));
@@ -786,7 +785,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	/* Enable all valid ports and disable those unused */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
 		/* IMP port receives special treatment */
-		if ((1 << port) & ds->enabled_port_mask)
+		if (dsa_is_user_port(ds, port))
 			bcm_sf2_port_setup(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
diff --git a/drivers/net/dsa/bcm_sf2_cfp.c b/drivers/net/dsa/bcm_sf2_cfp.c
index 4feb507eeee0..b721a2009b50 100644
--- a/drivers/net/dsa/bcm_sf2_cfp.c
+++ b/drivers/net/dsa/bcm_sf2_cfp.c
@@ -750,7 +750,7 @@ static int bcm_sf2_cfp_rule_set(struct dsa_switch *ds, int port,
 	port_num = fs->ring_cookie / SF2_NUM_EGRESS_QUEUES;
 
 	if (fs->ring_cookie == RX_CLS_FLOW_DISC ||
-	    !(BIT(port_num) & ds->enabled_port_mask) ||
+	    !dsa_is_user_port(ds, port_num) ||
 	    port_num >= priv->hw_params.num_ports)
 		return -EINVAL;
 	/*
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 21431be2831e..d1d4eea6a875 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -781,7 +781,7 @@ mt7530_port_bridge_join(struct dsa_switch *ds, int port,
 		 * same bridge. If the port is disabled, port matrix is kept
 		 * and not being setup until the port becomes enabled.
 		 */
-		if (ds->enabled_port_mask & BIT(i) && i != port) {
+		if (dsa_is_user_port(ds, i) && i != port) {
 			if (dsa_to_port(ds, i)->bridge_dev != bridge)
 				continue;
 			if (priv->ports[i].enable)
@@ -818,7 +818,7 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 		 * in the same bridge. If the port is disabled, port matrix
 		 * is kept and not being setup until the port becomes enabled.
 		 */
-		if (ds->enabled_port_mask & BIT(i) && i != port) {
+		if (dsa_is_user_port(ds, i) && i != port) {
 			if (dsa_to_port(ds, i)->bridge_dev != bridge)
 				continue;
 			if (priv->ports[i].enable)
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index d1b0b1fb632f..37125858fe80 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -536,7 +536,7 @@ qca8k_setup(struct dsa_switch *ds)
 
 	/* Disable MAC by default on all user ports */
 	for (i = 1; i < QCA8K_NUM_PORTS; i++)
-		if (ds->enabled_port_mask & BIT(i))
+		if (dsa_is_user_port(ds, i))
 			qca8k_port_set_status(priv, i, 0);
 
 	/* Forward all unknown frames to CPU port for Linux processing */
@@ -556,7 +556,7 @@ qca8k_setup(struct dsa_switch *ds)
 		}
 
 		/* Invividual user ports get connected to CPU port only */
-		if (ds->enabled_port_mask & BIT(i)) {
+		if (dsa_is_user_port(ds, i)) {
 			int shift = 16 * (i % 2);
 
 			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(i),
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index a3abf7a7b9a2..fe0081730305 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -201,7 +201,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 #ifdef CONFIG_PM_SLEEP
 static bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
-	return ds->enabled_port_mask & (1 << p) && ds->ports[p].slave;
+	return dsa_is_user_port(ds, p) && ds->ports[p].slave;
 }
 
 int dsa_switch_suspend(struct dsa_switch *ds)
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 93c1c43bcc58..0b79c6171d0d 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -190,7 +190,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		ds->ports[i].dn = cd->port_dn[i];
 		ds->ports[i].cpu_dp = dst->cpu_dp;
 
-		if (!(ds->enabled_port_mask & (1 << i)))
+		if (dsa_is_user_port(ds, i))
 			continue;
 
 		ret = dsa_slave_create(&ds->ports[i], cd->port_names[i]);
@@ -258,7 +258,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
 	/* Destroy network devices for physical switch ports. */
 	for (port = 0; port < ds->num_ports; port++) {
-		if (!(ds->enabled_port_mask & (1 << port)))
+		if (!dsa_is_user_port(ds, port))
 			continue;
 
 		if (!ds->ports[port].slave)
-- 
2.14.3
