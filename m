From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/4] net: dsa: Relocate master ethtool operations
Date: Tue, 13 Jun 2017 12:17:23 -0700
Message-ID: <20170613191725.26625-3-f.fainelli@gmail.com>
References: <20170613191725.26625-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34414 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdFMTRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 15:17:38 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so33339317wrc.1
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 12:17:37 -0700 (PDT)
In-Reply-To: <20170613191725.26625-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relocate master_ethtool_ops and master_orig_ethtool_ops into struct
dsa_port in order to be both consistent, and make things self contained
within the dsa_port structure.

This is a preliminary change to supporting multiple CPU port interfaces.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 17 +++++------------
 net/dsa/dsa.c     | 16 ++++++----------
 net/dsa/slave.c   | 16 ++++++++--------
 3 files changed, 19 insertions(+), 30 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b2fb53f5e28e..7e93869819f9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -122,12 +122,6 @@ struct dsa_switch_tree {
 	 */
 	struct dsa_platform_data	*pd;
 
-	/*
-	 * Reference to network device to use, and which tagging
-	 * protocol to use.
-	 */
-	struct net_device	*master_netdev;
-
 	/* Copy of tag_ops->rcv for faster access in hot path */
 	struct sk_buff *	(*rcv)(struct sk_buff *skb,
 				       struct net_device *dev,
@@ -135,12 +129,6 @@ struct dsa_switch_tree {
 				       struct net_device *orig_dev);
 
 	/*
-	 * Original copy of the master netdev ethtool_ops
-	 */
-	struct ethtool_ops	master_ethtool_ops;
-	const struct ethtool_ops *master_orig_ethtool_ops;
-
-	/*
 	 * The switch port to which the CPU is attached.
 	 */
 	struct dsa_port		*cpu_dp;
@@ -189,6 +177,11 @@ struct dsa_port {
 	u8			stp_state;
 	struct net_device	*bridge_dev;
 	struct devlink_port	devlink_port;
+	/*
+	 * Original copy of the master netdev ethtool_ops
+	 */
+	struct ethtool_ops	ethtool_ops;
+	const struct ethtool_ops *orig_ethtool_ops;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6aacc2314a8f..416ac4ef9ba9 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -118,15 +118,16 @@ int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 	struct net_device *master;
 	struct ethtool_ops *cpu_ops;
 
-	master = ds->dst->cpu_dp->netdev;
+	master = cpu_dp->netdev;
+
 	cpu_ops = devm_kzalloc(ds->dev, sizeof(*cpu_ops), GFP_KERNEL);
 	if (!cpu_ops)
 		return -ENOMEM;
 
-	memcpy(&ds->dst->master_ethtool_ops, master->ethtool_ops,
+	memcpy(&cpu_dp->ethtool_ops, master->ethtool_ops,
 	       sizeof(struct ethtool_ops));
-	ds->dst->master_orig_ethtool_ops = master->ethtool_ops;
-	memcpy(cpu_ops, &ds->dst->master_ethtool_ops,
+	cpu_dp->orig_ethtool_ops = master->ethtool_ops;
+	memcpy(cpu_ops, &cpu_dp->ethtool_ops,
 	       sizeof(struct ethtool_ops));
 	dsa_cpu_port_ethtool_init(cpu_ops);
 	master->ethtool_ops = cpu_ops;
@@ -136,12 +137,7 @@ int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 
 void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
 {
-	struct dsa_switch *ds = cpu_dp->ds;
-	struct net_device *master;
-
-	master = ds->dst->cpu_dp->netdev;
-
-	master->ethtool_ops = ds->dst->master_orig_ethtool_ops;
+	cpu_dp->netdev->ethtool_ops = cpu_dp->orig_ethtool_ops;
 }
 
 void dsa_cpu_dsa_destroy(struct dsa_port *port)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 95031b31d64b..c33db4e3b445 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -524,10 +524,10 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 	s8 cpu_port = dst->cpu_dp->index;
 	int count = 0;
 
-	if (dst->master_ethtool_ops.get_sset_count) {
-		count = dst->master_ethtool_ops.get_sset_count(dev,
+	if (dst->cpu_dp->ethtool_ops.get_sset_count) {
+		count = dst->cpu_dp->ethtool_ops.get_sset_count(dev,
 							       ETH_SS_STATS);
-		dst->master_ethtool_ops.get_ethtool_stats(dev, stats, data);
+		dst->cpu_dp->ethtool_ops.get_ethtool_stats(dev, stats, data);
 	}
 
 	if (ds->ops->get_ethtool_stats)
@@ -540,8 +540,8 @@ static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 	struct dsa_switch *ds = dst->cpu_dp->ds;
 	int count = 0;
 
-	if (dst->master_ethtool_ops.get_sset_count)
-		count += dst->master_ethtool_ops.get_sset_count(dev, sset);
+	if (dst->cpu_dp->ethtool_ops.get_sset_count)
+		count += dst->cpu_dp->ethtool_ops.get_sset_count(dev, sset);
 
 	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
 		count += ds->ops->get_sset_count(ds);
@@ -565,10 +565,10 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 	/* We do not want to be NULL-terminated, since this is a prefix */
 	pfx[sizeof(pfx) - 1] = '_';
 
-	if (dst->master_ethtool_ops.get_sset_count) {
-		mcount = dst->master_ethtool_ops.get_sset_count(dev,
+	if (dst->cpu_dp->ethtool_ops.get_sset_count) {
+		mcount = dst->cpu_dp->ethtool_ops.get_sset_count(dev,
 								ETH_SS_STATS);
-		dst->master_ethtool_ops.get_strings(dev, stringset, data);
+		dst->cpu_dp->ethtool_ops.get_strings(dev, stringset, data);
 	}
 
 	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
-- 
2.9.3
