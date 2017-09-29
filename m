From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 6/7] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 17:19:20 -0400
Message-ID: <20170929211921.5571-7-vivien.didelot@savoirfairelinux.com>
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

With DSA, a master net device (CPU facing interface) has a dsa_ptr
pointer to which hangs a dsa_switch_tree. This is not correct because a
master interface is wired to a dedicated switch port, and because we can
theoretically have several master interfaces pointing to several CPU
ports of the same switch fabric.

Change the master interface's dsa_ptr for the CPU dsa_port pointer.
This is a step towards supporting multiple CPU ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/netdevice.h |  4 ++--
 net/dsa/dsa.c             |  6 +++---
 net/dsa/dsa2.c            |  2 +-
 net/dsa/dsa_priv.h        |  3 ++-
 net/dsa/legacy.c          |  2 +-
 net/dsa/master.c          | 15 +++++----------
 6 files changed, 14 insertions(+), 18 deletions(-)

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
index 9397291bb3aa..2850077cc9cc 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -116,7 +116,8 @@ void dsa_master_ethtool_restore(struct net_device *dev);
 static inline struct net_device *dsa_master_get_slave(struct net_device *dev,
 						      int device, int port)
 {
-	struct dsa_switch_tree *dst = dev->dsa_ptr;
+	struct dsa_port *cpu_dp = dev->dsa_ptr;
+	struct dsa_switch_tree *dst = cpu_dp->dst;
 	struct dsa_switch *ds;
 
 	if (device < 0 || device >= DSA_MAX_SWITCHES)
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
-- 
2.14.1
