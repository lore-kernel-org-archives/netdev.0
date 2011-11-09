From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 5/9] forcedeth: implement ndo_get_stats64() API
Date: Wed,  9 Nov 2011 14:09:19 -0800
Message-ID: <14be343e242ede786e387b1d22f0a9259ec7d862.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit implements the ndo_get_stats64() API for forcedeth. Since
these stats are being updated from different contexts (process and
timer), this commit adds protection (locking + atomic variables).

Tested:
  16-way SMP x86_64 ->
  RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |  132 +++++++++++++++++++++++--------
 1 files changed, 99 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0071d5c..0b4fd1a 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -692,6 +692,19 @@ struct nv_ethtool_stats {
 #define NV_DEV_STATISTICS_V2_COUNT (NV_DEV_STATISTICS_V3_COUNT - 3)
 #define NV_DEV_STATISTICS_V1_COUNT (NV_DEV_STATISTICS_V2_COUNT - 6)
 
+/* driver statistics */
+struct nv_driver_stat {
+	atomic_t delta;  /* increase since last nv_update_stats() */
+	u64 total;  /* cumulative, requires netdev_priv(dev)->stats_lock */
+};
+
+#define NV_DRIVER_STAT_ATOMIC_INC(ptr_stat) /* atomic */ \
+	({ atomic_inc(&(ptr_stat)->delta); })
+#define NV_DRIVER_STAT_UPDATE_TOTAL(ptr_stat) /* requires stats_lock */ \
+	({ (ptr_stat)->total += atomic_xchg(&(ptr_stat)->delta, 0); })
+#define NV_DRIVER_STAT_GET_TOTAL(ptr_stat) /* requires stats_lock */ \
+	((ptr_stat)->total)
+
 /* diagnostics */
 #define NV_TEST_COUNT_BASE 3
 #define NV_TEST_COUNT_EXTENDED 4
@@ -736,6 +749,12 @@ struct nv_skb_map {
  * - tx setup is lockless: it relies on netif_tx_lock. Actual submission
  *	needs netdev_priv(dev)->lock :-(
  * - set_multicast_list: preparation lockless, relies on netif_tx_lock.
+ *
+ * Stats are protected with stats_lock:
+ * - updated by nv_do_stats_poll (timer). This is meant to avoid
+ *   integer wraparound in the NIC stats registers, at low frequency
+ *   (0.1 Hz)
+ * - updated by nv_get_ethtool_stats + nv_get_stats64
  */
 
 /* in dev: base, irq */
@@ -745,9 +764,10 @@ struct fe_priv {
 	struct net_device *dev;
 	struct napi_struct napi;
 
-	/* General data:
-	 * Locking: spin_lock(&np->lock); */
+	/* stats are updated in syscall and timer */
+	spinlock_t stats_lock;
 	struct nv_ethtool_stats estats;
+
 	int in_shutdown;
 	u32 linkspeed;
 	int duplex;
@@ -797,6 +817,7 @@ struct fe_priv {
 	struct timer_list stats_poll;
 	u32 nic_poll_irq;
 	int rx_ring_size;
+	struct nv_driver_stat stat_rx_missed_errors;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -819,6 +840,7 @@ struct fe_priv {
 	struct nv_skb_map *tx_change_owner;
 	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
+	struct nv_driver_stat stat_tx_dropped;
 
 	/* msi/msi-x fields */
 	u32 msi_flags;
@@ -1635,11 +1657,19 @@ static void nv_mac_reset(struct net_device *dev)
 	pci_push(base);
 }
 
-static void nv_get_hw_stats(struct net_device *dev)
+/* Caller must appropriately lock netdev_priv(dev)->stats_lock */
+static void nv_update_stats(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
+	/* If it happens that this is run in top-half context, then
+	 * replace the spin_lock of stats_lock with
+	 * spin_lock_irqsave() in calling functions. */
+	WARN_ONCE(in_irq(), "forcedeth: estats spin_lock(_bh) from top-half");
+	assert_spin_locked(&np->stats_lock);
+
+	/* query hardware */
 	np->estats.tx_bytes += readl(base + NvRegTxCnt);
 	np->estats.tx_zero_rexmt += readl(base + NvRegTxZeroReXmt);
 	np->estats.tx_one_rexmt += readl(base + NvRegTxOneReXmt);
@@ -1695,37 +1725,61 @@ static void nv_get_hw_stats(struct net_device *dev)
 		np->estats.tx_multicast += readl(base + NvRegTxMulticast);
 		np->estats.tx_broadcast += readl(base + NvRegTxBroadcast);
 	}
+
+	/* update software stats */
+	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_tx_dropped);
+	NV_DRIVER_STAT_UPDATE_TOTAL(&np->stat_rx_missed_errors);
 }
 
 /*
- * nv_get_stats: dev->get_stats function
+ * nv_get_stats64: dev->ndo_get_stats64 function
  * Get latest stats value from the nic.
  * Called with read_lock(&dev_base_lock) held for read -
  * only synchronized against unregister_netdevice.
  */
-static struct net_device_stats *nv_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64*
+nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
+	__acquires(&netdev_priv(dev)->stats_lock)
+	__releases(&netdev_priv(dev)->stats_lock)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* If the nic supports hw counters then retrieve latest values */
-	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
-		nv_get_hw_stats(dev);
-
-		/* copy to net_device stats */
-		dev->stats.rx_packets = np->estats.rx_packets;
-		dev->stats.tx_packets = np->estats.tx_packets;
-		dev->stats.rx_bytes = np->estats.rx_bytes;
-		dev->stats.tx_bytes = np->estats.tx_bytes;
-		dev->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
-		dev->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
-		dev->stats.rx_crc_errors = np->estats.rx_crc_errors;
-		dev->stats.rx_over_errors = np->estats.rx_over_errors;
-		dev->stats.rx_fifo_errors = np->estats.rx_drop_frame;
-		dev->stats.rx_errors = np->estats.rx_errors_total;
-		dev->stats.tx_errors = np->estats.tx_errors_total;
-	}
-
-	return &dev->stats;
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1
+			       | DEV_HAS_STATISTICS_V2
+			       | DEV_HAS_STATISTICS_V3)) {
+		spin_lock_bh(&np->stats_lock);
+
+		nv_update_stats(dev);
+
+		/* generic stats */
+		storage->rx_packets = np->estats.rx_packets;
+		storage->tx_packets = np->estats.tx_packets;
+		storage->rx_bytes   = np->estats.rx_bytes;
+		storage->tx_bytes   = np->estats.tx_bytes;
+		storage->rx_errors  = np->estats.rx_errors_total;
+		storage->tx_errors  = np->estats.tx_errors_total;
+		storage->tx_dropped = NV_DRIVER_STAT_GET_TOTAL(
+			&np->stat_tx_dropped);
+		storage->multicast  = np->estats.rx_multicast;
+
+		/* detailed rx_errors */
+		storage->rx_length_errors = np->estats.rx_length_error;
+		storage->rx_over_errors   = np->estats.rx_over_errors;
+		storage->rx_crc_errors    = np->estats.rx_crc_errors;
+		storage->rx_frame_errors  = np->estats.rx_frame_align_error;
+		storage->rx_fifo_errors   = np->estats.rx_drop_frame;
+		storage->rx_missed_errors = NV_DRIVER_STAT_GET_TOTAL(
+			&np->stat_rx_missed_errors);
+
+		/* detailed tx_errors */
+		storage->tx_carrier_errors = np->estats.tx_carrier_errors;
+		storage->tx_fifo_errors    = np->estats.tx_fifo_errors;
+
+		spin_unlock_bh(&np->stats_lock);
+	}
+
+	return storage;
 }
 
 /*
@@ -1927,7 +1981,7 @@ static void nv_drain_tx(struct net_device *dev)
 			np->tx_ring.ex[i].buflow = 0;
 		}
 		if (nv_release_txskb(np, &np->tx_skb[i]))
-			dev->stats.tx_dropped++;
+			NV_DRIVER_STAT_ATOMIC_INC(&np->stat_tx_dropped);
 		np->tx_skb[i].dma = 0;
 		np->tx_skb[i].dma_len = 0;
 		np->tx_skb[i].dma_single = 0;
@@ -2648,7 +2702,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					/* the rest are hard errors */
 					else {
 						if (flags & NV_RX_MISSEDFRAME)
-							dev->stats.rx_missed_errors++;
+							NV_DRIVER_STAT_ATOMIC_INC(&np->stat_rx_missed_errors);
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
@@ -3900,11 +3954,18 @@ static void nv_poll_controller(struct net_device *dev)
 #endif
 
 static void nv_do_stats_poll(unsigned long data)
+	__acquires(&netdev_priv(dev)->stats_lock)
+	__releases(&netdev_priv(dev)->stats_lock)
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 
-	nv_get_hw_stats(dev);
+	/* If lock is currently taken, the stats are being refreshed
+	 * and hence fresh enough */
+	if (spin_trylock(&np->stats_lock)) {
+		nv_update_stats(dev);
+		spin_unlock(&np->stats_lock);
+	}
 
 	if (!np->in_shutdown)
 		mod_timer(&np->stats_poll,
@@ -4549,14 +4610,18 @@ static int nv_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *estats, u64 *buffer)
+static void nv_get_ethtool_stats(struct net_device *dev,
+				 struct ethtool_stats *estats, u64 *buffer)
+	__acquires(&netdev_priv(dev)->stats_lock)
+	__releases(&netdev_priv(dev)->stats_lock)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
-	/* update stats */
-	nv_get_hw_stats(dev);
-
-	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
+	spin_lock_bh(&np->stats_lock);
+	nv_update_stats(dev);
+	memcpy(buffer, &np->estats,
+	       nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
+	spin_unlock_bh(&np->stats_lock);
 }
 
 static int nv_link_test(struct net_device *dev)
@@ -5194,7 +5259,7 @@ static int nv_close(struct net_device *dev)
 static const struct net_device_ops nv_netdev_ops = {
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
-	.ndo_get_stats		= nv_get_stats,
+	.ndo_get_stats64	= nv_get_stats64,
 	.ndo_start_xmit		= nv_start_xmit,
 	.ndo_tx_timeout		= nv_tx_timeout,
 	.ndo_change_mtu		= nv_change_mtu,
@@ -5211,7 +5276,7 @@ static const struct net_device_ops nv_netdev_ops = {
 static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
-	.ndo_get_stats		= nv_get_stats,
+	.ndo_get_stats64	= nv_get_stats64,
 	.ndo_start_xmit		= nv_start_xmit_optimized,
 	.ndo_tx_timeout		= nv_tx_timeout,
 	.ndo_change_mtu		= nv_change_mtu,
@@ -5250,6 +5315,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->dev = dev;
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->stats_lock);
 	SET_NETDEV_DEV(dev, &pci_dev->dev);
 
 	init_timer(&np->oom_kick);
-- 
1.7.3.1
