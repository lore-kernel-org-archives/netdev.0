From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 4/4] net: dsa: Introduce dsa_get_cpu_port()
Date: Tue, 13 Jun 2017 12:17:25 -0700
Message-ID: <20170613191725.26625-5-f.fainelli@gmail.com>
References: <20170613191725.26625-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36828 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdFMTRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 15:17:42 -0400
Received: by mail-wr0-f195.google.com with SMTP id 77so2672708wrb.3
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 12:17:42 -0700 (PDT)
In-Reply-To: <20170613191725.26625-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a helper function which will return a reference to the CPU
port used in a dsa_switch_tree. Right now this is a singleton, but this
will change once we introduce multi-CPU port support, so ease the
transition by converting the affected code paths.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h    |  5 +++++
 net/dsa/slave.c       | 31 ++++++++++++++++---------------
 net/dsa/tag_brcm.c    |  5 ++---
 net/dsa/tag_ksz.c     |  5 ++---
 net/dsa/tag_qca.c     |  3 ++-
 net/dsa/tag_trailer.c |  5 ++---
 6 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7c2326f3b538..55982cc39b24 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -188,4 +188,9 @@ static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 	return p->dp->cpu_dp->netdev;
 }
 
+static inline struct dsa_port *dsa_get_cpu_port(struct dsa_switch_tree *dst)
+{
+	return dst->cpu_dp;
+}
+
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 427f8afcfaf3..845e0c3f871e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -520,14 +520,14 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 					   uint64_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_dp->ds;
-	s8 cpu_port = dst->cpu_dp->index;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
+	s8 cpu_port = cpu_dp->index;
 	int count = 0;
 
-	if (dst->cpu_dp->ethtool_ops.get_sset_count) {
-		count = dst->cpu_dp->ethtool_ops.get_sset_count(dev,
-							       ETH_SS_STATS);
-		dst->cpu_dp->ethtool_ops.get_ethtool_stats(dev, stats, data);
+	if (cpu_dp->ethtool_ops.get_sset_count) {
+		count = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
+		cpu_dp->ethtool_ops.get_ethtool_stats(dev, stats, data);
 	}
 
 	if (ds->ops->get_ethtool_stats)
@@ -537,11 +537,12 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_dp->ds;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
 	int count = 0;
 
-	if (dst->cpu_dp->ethtool_ops.get_sset_count)
-		count += dst->cpu_dp->ethtool_ops.get_sset_count(dev, sset);
+	if (cpu_dp->ethtool_ops.get_sset_count)
+		count += cpu_dp->ethtool_ops.get_sset_count(dev, sset);
 
 	if (sset == ETH_SS_STATS && ds->ops->get_sset_count)
 		count += ds->ops->get_sset_count(ds);
@@ -553,8 +554,9 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 				     uint32_t stringset, uint8_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->cpu_dp->ds;
-	s8 cpu_port = dst->cpu_dp->index;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
+	s8 cpu_port = cpu_dp->index;
 	int len = ETH_GSTRING_LEN;
 	int mcount = 0, count;
 	unsigned int i;
@@ -565,10 +567,9 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 	/* We do not want to be NULL-terminated, since this is a prefix */
 	pfx[sizeof(pfx) - 1] = '_';
 
-	if (dst->cpu_dp->ethtool_ops.get_sset_count) {
-		mcount = dst->cpu_dp->ethtool_ops.get_sset_count(dev,
-								ETH_SS_STATS);
-		dst->cpu_dp->ethtool_ops.get_strings(dev, stringset, data);
+	if (cpu_dp->ethtool_ops.get_sset_count) {
+		mcount = cpu_dp->ethtool_ops.get_sset_count(dev, ETH_SS_STATS);
+		cpu_dp->ethtool_ops.get_strings(dev, stringset, data);
 	}
 
 	if (stringset == ETH_SS_STATS && ds->ops->get_strings) {
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index c03860907f28..c697d9815177 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -93,12 +93,11 @@ static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				    struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
 	int source_port;
 	u8 *brcm_tag;
 
-	ds = dst->cpu_dp->ds;
-
 	if (unlikely(!pskb_may_pull(skb, BRCM_TAG_LEN)))
 		return NULL;
 
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index b94a334a1d02..fab41de8e983 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -75,12 +75,11 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *tag;
 	int source_port;
 
-	ds = dst->cpu_dp->ds;
-
 	tag = skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
 
 	source_port = tag[0] & 7;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 4f43cf0b4eff..1867a3d11f28 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -67,6 +67,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
 	struct dsa_switch *ds;
 	u8 ver;
 	int port;
@@ -95,7 +96,7 @@ static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* This protocol doesn't support cascading multiple switches so it's
 	 * safe to assume the switch is first in the tree
 	 */
-	ds = dst->cpu_dp->ds;
+	ds = cpu_dp->ds;
 	if (!ds)
 		return NULL;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b4f6db094409..172f13167896 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -61,12 +61,11 @@ static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds;
+	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *trailer;
 	int source_port;
 
-	ds = dst->cpu_dp->ds;
-
 	if (skb_linearize(skb))
 		return NULL;
 
-- 
2.9.3
