From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/4] net: dsa: remove copy of master ethtool_ops
Date: Tue, 19 Sep 2017 11:56:57 -0400
Message-ID: <20170919155700.14474-2-vivien.didelot@savoirfairelinux.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to store a copy of the master ethtool ops, storing the
original pointer in DSA and the new one in the master netdev itself is
enough.

In the meantime, set orig_ethtool_ops to NULL when restoring the master
ethtool ops and check the presence of the master original ethtool ops as
well as its needed functions before calling them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  1 -
 net/dsa/dsa.c     |  8 ++++----
 net/dsa/slave.c   | 19 +++++++++++--------
 3 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index dd44d6ce1097..8dee216a5a9b 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -188,7 +188,6 @@ struct dsa_port {
 	/*
 	 * Original copy of the master netdev ethtool_ops
 	 */
-	struct ethtool_ops	ethtool_ops;
 	const struct ethtool_ops *orig_ethtool_ops;
 };
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 03c58b0eb082..abadf7b49236 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -124,11 +124,10 @@ int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 	if (!cpu_ops)
 		return -ENOMEM;
 
-	memcpy(&cpu_dp->ethtool_ops, master->ethtool_ops,
-	       sizeof(struct ethtool_ops));
 	cpu_dp->orig_ethtool_ops = master->ethtool_ops;
-	memcpy(cpu_ops, &cpu_dp->ethtool_ops,
-	       sizeof(struct ethtool_ops));
+	if (cpu_dp->orig_ethtool_ops)
+		memcpy(cpu_ops, cpu_dp->orig_ethtool_ops, sizeof(*cpu_ops));
+
 	dsa_cpu_port_ethtool_init(cpu_ops);
 	master->ethtool_ops = cpu_ops;
 
@@ -138,6 +137,7 @@ int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
 {
 	cpu_dp->netdev->ethtool_ops = cpu_dp->orig_ethtool_ops;
+	cpu_dp->orig_ethtool_ops = NULL;
 }
 
 void dsa_cpu_dsa_destroy(struct dsa_port *port)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2afa99506f8b..2ff4f907d137 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -574,12 +574,13 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
 	struct dsa_switch *ds = cpu_dp->ds;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	s8 cpu_port = cpu_dp->index;
 	int count = 0;
 
-	if (cpu_dp->ethtool_ops.get_sset_count) {
-		count = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
-		cpu_dp->ethtool_ops.get_ethtool_stats(dev, stats, data);
+	if (ops && ops->get_sset_count && ops->get_ethtool_stats) {
+		count = ops->get_sset_count(dev, ETH_SS_STATS);
+		ops->get_ethtool_stats(dev, stats, data);
 	}
 
 	if (ds->ops->get_ethtool_stats)
@@ -591,10 +592,11 @@ static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
 	struct dsa_switch *ds = cpu_dp->ds;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	int count = 0;
 
-	if (cpu_dp->ethtool_ops.get_sset_count)
-		count += cpu_dp->ethtool_ops.get_sset_count(dev, sset);
+	if (ops && ops->get_sset_count)
+		count += ops->get_sset_count(dev, sset);
 
 	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
 		count += ds->ops->get_sset_count(ds);
@@ -608,6 +610,7 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
 	struct dsa_switch *ds = cpu_dp->ds;
+	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	s8 cpu_port = cpu_dp->index;
 	int len = ETH_GSTRING_LEN;
 	int mcount = 0, count;
@@ -619,9 +622,9 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 	/* We do not want to be NULL-terminated, since this is a prefix */
 	pfx[sizeof(pfx) - 1] = '_';
 
-	if (cpu_dp->ethtool_ops.get_sset_count) {
-		mcount = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
-		cpu_dp->ethtool_ops.get_strings(dev, stringset, data);
+	if (ops && ops->get_sset_count && ops->get_strings) {
+		mcount = ops->get_sset_count(dev, ETH_SS_STATS);
+		ops->get_strings(dev, stringset, data);
 	}
 
 	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
-- 
2.14.1
