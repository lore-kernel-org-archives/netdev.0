From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/8] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 14:36:34 -0400
Message-ID: <20170929183635.8122-8-vivien.didelot@savoirfairelinux.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With DSA, a master net device (CPU facing interface) has a dsa_ptr
pointer to which hangs a dsa_switch_tree. This is not correct because a
master interface is wired to a dedicated switch port, and because we can
theoretically have several master interfaces pointing to several CPU
ports of the same switch fabric.

Change the master interface's dsa_ptr for the CPU dsa_port pointer.
This is a step towards supporting multiple CPU ports. Also remove
dsa_get_cpu_port which is now unneeded.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/netdevice.h |  4 ++--
 net/dsa/dsa.c             |  6 +++---
 net/dsa/dsa2.c            |  2 +-
 net/dsa/dsa_priv.h        |  5 -----
 net/dsa/legacy.c          |  2 +-
 net/dsa/master.c          | 15 +++++----------
 net/dsa/tag_brcm.c        |  3 +--
 net/dsa/tag_dsa.c         |  3 ++-
 net/dsa/tag_edsa.c        |  3 ++-
 net/dsa/tag_ksz.c         |  3 +--
 net/dsa/tag_lan9303.c     |  3 +--
 net/dsa/tag_mtk.c         |  3 +--
 net/dsa/tag_qca.c         |  3 +--
 net/dsa/tag_trailer.c     |  3 +--
 14 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..e1d6ef130611 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -55,7 +55,7 @@
 struct netpoll_info;
 struct device;
 struct phy_device;
-struct dsa_switch_tree;
+struct dsa_port;
 
 /* 802.11 specific */
 struct wireless_dev;
@@ -1752,7 +1752,7 @@ struct net_device {
 	struct vlan_info __rcu	*vlan_info;
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
-	struct dsa_switch_tree	*dsa_ptr;
+	struct dsa_port		*dsa_ptr;
 #endif
 #if IS_ENABLED(CONFIG_TIPC)
 	struct tipc_bearer __rcu *tipc_ptr;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 81c852e32821..51ca2a524a27 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -160,12 +160,12 @@ EXPORT_SYMBOL_GPL(dsa_dev_to_net_device);
 static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 			  struct packet_type *pt, struct net_device *unused)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct sk_buff *nskb = NULL;
 	struct pcpu_sw_netstats *s;
 	struct dsa_slave_priv *p;
 
-	if (unlikely(dst == NULL)) {
+	if (unlikely(!cpu_dp)) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -174,7 +174,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	nskb = dst->rcv(skb, dev, pt);
+	nskb = cpu_dp->rcv(skb, dev, pt);
 	if (!nskb) {
 		kfree_skb(skb);
 		return 0;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index b71e3bb478e4..62302558f38c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -438,7 +438,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dst->cpu_dp->netdev->dsa_ptr = dst;
+	dst->cpu_dp->netdev->dsa_ptr = dst->cpu_dp;
 
 	err = dsa_master_ethtool_setup(dst->cpu_dp->netdev);
 	if (err)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 6dbed23ffe83..2495f7bdefa2 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -182,9 +182,4 @@ static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
 	return p->dp->cpu_dp->netdev;
 }
 
-static inline struct dsa_port *dsa_get_cpu_port(struct dsa_switch_tree *dst)
-{
-	return dst->cpu_dp;
-}
-
 #endif
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 96c7e3f8b8bb..71917505a5cc 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -607,7 +607,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
-	dev->dsa_ptr = dst;
+	dev->dsa_ptr = dst->cpu_dp;
 
 	return dsa_master_ethtool_setup(dst->cpu_dp->netdev);
 }
diff --git a/net/dsa/master.c b/net/dsa/master.c
index ef15d35f1574..5f3f57e372e0 100644
--- a/net/dsa/master.c
+++ b/net/dsa/master.c
@@ -16,8 +16,7 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 					 struct ethtool_stats *stats,
 					 uint64_t *data)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	struct dsa_switch *ds = cpu_dp->ds;
 	int port = cpu_dp->index;
@@ -34,8 +33,7 @@ static void dsa_master_get_ethtool_stats(struct net_device *dev,
 
 static int dsa_master_get_sset_count(struct net_device *dev, int sset)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	struct dsa_switch *ds = cpu_dp->ds;
 	int count = 0;
@@ -52,8 +50,7 @@ static int dsa_master_get_sset_count(struct net_device *dev, int sset)
 static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 				   uint8_t *data)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	const struct ethtool_ops *ops = cpu_dp->orig_ethtool_ops;
 	struct dsa_switch *ds = cpu_dp->ds;
 	int port = cpu_dp->index;
@@ -90,8 +87,7 @@ static void dsa_master_get_strings(struct net_device *dev, uint32_t stringset,
 
 int dsa_master_ethtool_setup(struct net_device *dev)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	struct ethtool_ops *ops;
 
@@ -114,8 +110,7 @@ int dsa_master_ethtool_setup(struct net_device *dev)
 
 void dsa_master_ethtool_restore(struct net_device *dev)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 
 	dev->ethtool_ops = cpu_dp->orig_ethtool_ops;
 	cpu_dp->orig_ethtool_ops = NULL;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index dbb016434ace..67e0e9fd3d16 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -92,8 +92,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 static struct sk_buff *brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				    struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	int source_port;
 	u8 *brcm_tag;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index fbf9ca954773..60679d64fd07 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -67,7 +67,8 @@ static struct sk_buff *dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = cpu_dp->dst;
 	struct dsa_switch *ds;
 	u8 *dsa_header;
 	int source_device;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 76367ba1b2e2..15c75b31d0d5 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -80,7 +80,8 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 				struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = cpu_dp->dst;
 	struct dsa_switch *ds;
 	u8 *edsa_header;
 	int source_device;
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 010ca0a336c4..fdf54b8379a2 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -80,8 +80,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *tag;
 	int source_port;
diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index f0b51acf36ac..1134ff08ce63 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -71,8 +71,7 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 			struct packet_type *pt)
 {
 	u16 *lan9303_tag;
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	unsigned int source_port;
 
diff --git a/net/dsa/tag_mtk.c b/net/dsa/tag_mtk.c
index ef0364b82241..5c755c5b303f 100644
--- a/net/dsa/tag_mtk.c
+++ b/net/dsa/tag_mtk.c
@@ -46,8 +46,7 @@ static struct sk_buff *mtk_tag_xmit(struct sk_buff *skb,
 static struct sk_buff *mtk_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dst->cpu_dp;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	int port;
 	__be16 *phdr, hdr;
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 1d4c70711c0f..98618ca6eef6 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -65,8 +65,7 @@ static struct sk_buff *qca_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds;
 	u8 ver;
 	int port;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d2fd4923aa3e..e185f5083558 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -58,8 +58,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct sk_buff *trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 				   struct packet_type *pt)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
 	struct dsa_switch *ds = cpu_dp->ds;
 	u8 *trailer;
 	int source_port;
-- 
2.14.1
