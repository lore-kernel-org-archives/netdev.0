From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/7] net: dsa: use cpu_dp in master code
Date: Fri, 29 Sep 2017 17:19:16 -0400
Message-ID: <20170929211921.5571-3-vivien.didelot@savoirfairelinux.com>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make it clear that the master device is linked to a CPU port by using
"cpu_dp" for the dsa_port variable in master.c instead of "port", then
use a "port" variable to describe the port index, as usually seen in
other places of DSA core.

This will make the future patch touching dsa_ptr more readable. There is
no functional changes.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/master.c | 42 ++++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/dsa/master.c b/net/dsa/master.c
index 5e5147ec5a44..ef15d35f1574 100644
--- a/net/dsa/master.c
+++ b/net/dsa/master.c
@@ -17,9 +17,10 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 					 uint64_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *port = dst->cpu_dp;
-	struct dsa_switch *ds = port->ds;
-	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
+	struct dsa_switch *ds = cpu_dp->ds;
+	int port = cpu_dp->index;
 	int count = 0;
 
 	if (ops && ops->get_sset_count && ops->get_ethtool_stats) {
@@ -28,15 +29,15 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 	}
 
 	if (ds->ops->get_ethtool_stats)
-		ds->ops->get_ethtool_stats(ds, port->index, data + count);
+		ds->ops->get_ethtool_stats(ds, port, data + count);
 }
 
 static int dsa_master_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *port = dst->cpu_dp;
-	struct dsa_switch *ds = port->ds;
-	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
+	struct dsa_switch *ds = cpu_dp->ds;
 	int count = 0;
 
 	if (ops && ops->get_sset_count)
@@ -52,16 +53,17 @@ static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 				   uint8_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *port = dst->cpu_dp;
-	struct dsa_switch *ds = port->ds;
-	const struct ethtool_ops *ops = port->orig_ethtool_ops;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
+	struct dsa_switch *ds = cpu_dp->ds;
+	int port = cpu_dp->index;
 	int len = ETH_GSTRING_LEN;
 	int mcount = 0, count;
 	unsigned int i;
 	uint8_t pfx[4];
 	uint8_t *ndata;
 
-	snprintf(pfx, sizeof(pfx), "p%.2d", port->index);
+	snprintf(pfx, sizeof(pfx), "p%.2d", port);
 	/* We do not want to be NULL-terminated, since this is a prefix */
 	pfx[sizeof(pfx) - 1] = '_';
 
@@ -76,7 +78,7 @@ static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 		 * the output after to prepend our CPU port prefix we
 		 * constructed earlier
 		 */
-		ds->ops->get_strings(ds, port->index, ndata);
+		ds->ops->get_strings(ds, port, ndata);
 		count = ds->ops->get_sset_count(ds);
 		for (i = 0; i < count; i++) {
 			memmove(ndata + (i * len + sizeof(pfx)),
@@ -89,17 +91,17 @@ static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 int dsa_master_ethtool_setup(struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *port = dst->cpu_dp;
-	struct dsa_switch *ds = port->ds;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_switch *ds = cpu_dp->ds;
 	struct ethtool_ops *ops;
 
 	ops = devm_kzalloc(ds->dev, sizeof(*ops), GFP_KERNEL);
 	if (!ops)
 		return -ENOMEM;
 
-	port->orig_ethtool_ops = dev->ethtool_ops;
-	if (port->orig_ethtool_ops)
-		memcpy(ops, port->orig_ethtool_ops, sizeof(*ops));
+	cpu_dp->orig_ethtool_ops = dev->ethtool_ops;
+	if (cpu_dp->orig_ethtool_ops)
+		memcpy(ops, cpu_dp->orig_ethtool_ops, sizeof(*ops));
 
 	ops->get_sset_count = dsa_master_get_sset_count;
 	ops->get_ethtool_stats = dsa_master_get_ethtool_stats;
@@ -113,8 +115,8 @@ int dsa_master_ethtool_setup(struct net_device *dev)
 void dsa_master_ethtool_restore(struct net_device *dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *port = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dst->cpu_dp;
 
-	dev->ethtool_ops = port->orig_ethtool_ops;
-	port->orig_ethtool_ops = NULL;
+	dev->ethtool_ops = cpu_dp->orig_ethtool_ops;
+	cpu_dp->orig_ethtool_ops = NULL;
 }
-- 
2.14.1
