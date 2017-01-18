From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/2] net: dsa: use cpu_switch instead of ds[0]
Date: Tue, 17 Jan 2017 20:41:39 -0500
Message-ID: <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DSA Ethernet switches are true Linux devices, the CPU
switch is not necessarily the first one. If its address is higher than
the second switch on the same MDIO bus, its index will be 1, not 0.

Avoid any confusion by using dst->cpu_switch instead of dst->ds[0].

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c         | 2 +-
 net/dsa/dsa2.c        | 8 ++++----
 net/dsa/slave.c       | 6 +++---
 net/dsa/tag_brcm.c    | 2 +-
 net/dsa/tag_qca.c     | 2 +-
 net/dsa/tag_trailer.c | 2 +-
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index cb42655ba7da..87f2a9c9fa12 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -868,7 +868,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->ds[0]);
+	dsa_cpu_port_ethtool_restore(dst->cpu_switch);
 
 	dev_put(dst->master_netdev);
 }
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index a9bf28d9f41f..634c6700a179 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -381,8 +381,8 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (dst->ds[0]) {
-		err = dsa_cpu_port_ethtool_setup(dst->ds[0]);
+	if (dst->cpu_switch) {
+		err = dsa_cpu_port_ethtool_setup(dst->cpu_switch);
 		if (err)
 			return err;
 	}
@@ -426,8 +426,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	if (dst->ds[0])
-		dsa_cpu_port_ethtool_restore(dst->ds[0]);
+	if (dst->cpu_switch)
+		dsa_cpu_port_ethtool_restore(dst->cpu_switch);
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0cdcaf526987..b8e58689a9a1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -781,7 +781,7 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 					   uint64_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->ds[0];
+	struct dsa_switch *ds = dst->cpu_switch;
 	s8 cpu_port = dst->cpu_port;
 	int count = 0;
 
@@ -798,7 +798,7 @@ static void dsa_cpu_port_get_ethtool_stats(struct net_device *dev,
 static int dsa_cpu_port_get_sset_count(struct net_device *dev, int sset)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->ds[0];
+	struct dsa_switch *ds = dst->cpu_switch;
 	int count = 0;
 
 	if (dst->master_ethtool_ops.get_sset_count)
@@ -814,7 +814,7 @@ static void dsa_cpu_port_get_strings(struct net_device *dev,
 				     uint32_t stringset, uint8_t *data)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
-	struct dsa_switch *ds = dst->ds[0];
+	struct dsa_switch *ds = dst->cpu_switch;
 	s8 cpu_port = dst->cpu_port;
 	int len = ETH_GSTRING_LEN;
 	int mcount = 0, count;
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index 21bffde6e4bf..af82927674e0 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -102,7 +102,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (unlikely(dst == NULL))
 		goto out_drop;
 
-	ds = dst->ds[0];
+	ds = dst->cpu_switch;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (skb == NULL)
diff --git a/net/dsa/tag_qca.c b/net/dsa/tag_qca.c
index 0c90cacee7aa..736ca8e8c31e 100644
--- a/net/dsa/tag_qca.c
+++ b/net/dsa/tag_qca.c
@@ -104,7 +104,7 @@ static int qca_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	/* This protocol doesn't support cascading multiple switches so it's
 	 * safe to assume the switch is first in the tree
 	 */
-	ds = dst->ds[0];
+	ds = dst->cpu_switch;
 	if (!ds)
 		goto out_drop;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 5e3903eb1afa..271128a2dc64 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -67,7 +67,7 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	if (unlikely(dst == NULL))
 		goto out_drop;
-	ds = dst->ds[0];
+	ds = dst->cpu_switch;
 
 	skb = skb_unshare(skb, GFP_ATOMIC);
 	if (skb == NULL)
-- 
2.11.0
