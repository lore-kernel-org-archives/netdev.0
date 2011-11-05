From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v3 8/9] forcedeth: 64-bit stats
Date: Fri,  4 Nov 2011 18:53:32 -0700
Message-ID: <4c77142ad7c6019e908884723d3c299163a55e2e.1320457247.git.david.decotigny@google.com>
References: <cover.1320457247.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320457247.git.david.decotigny@google.com>
In-Reply-To: <cover.1320457247.git.david.decotigny@google.com>
References: <cover.1320457247.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This converts forcedeth stats to be 64-bits. It also improves
accounting for dropped rx frames.

Tested:
  16-way SMP x86_64 ->
  RX bytes:7244556582 (7.2 GB)  TX bytes:181904254 (181.9 MB)



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   69 +++++++++++++++++++-----------
 1 files changed, 44 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 90cdf26..08c512b 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -799,6 +799,8 @@ struct fe_priv {
 	struct timer_list stats_poll;
 	u32 nic_poll_irq;
 	int rx_ring_size;
+	unsigned long stats_rx_dropped;
+	unsigned long stats_rx_missed_errors;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -821,6 +823,7 @@ struct fe_priv {
 	struct nv_skb_map *tx_change_owner;
 	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
+	unsigned long stats_tx_dropped;
 
 	/* msi/msi-x fields */
 	u32 msi_flags;
@@ -1700,33 +1703,47 @@ static void nv_get_hw_stats(struct net_device *dev)
 }
 
 /*
- * nv_get_stats: dev->get_stats function
+ * nv_get_stats: dev->ndo_get_stats64 function
  * Get latest stats value from the nic.
  * Called with read_lock(&dev_base_lock) held for read -
  * only synchronized against unregister_netdevice.
  */
-static struct net_device_stats *nv_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64*
+nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* If the nic supports hw counters then retrieve latest values */
-	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1
+			       | DEV_HAS_STATISTICS_V2
+			       | DEV_HAS_STATISTICS_V3)) {
 		nv_get_hw_stats(dev);
 
-		/* copy to net_device stats */
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
+		/* generic stats */
+		storage->rx_packets = np->estats.rx_packets;
+		storage->tx_packets = np->estats.tx_packets;
+		storage->rx_bytes   = np->estats.rx_bytes;
+		storage->tx_bytes   = np->estats.tx_bytes;
+		storage->rx_errors  = np->estats.rx_errors_total;
+		storage->tx_errors  = np->estats.tx_errors_total;
+		storage->rx_dropped = np->stats_rx_dropped;
+		storage->tx_dropped = np->stats_tx_dropped;
+		storage->multicast  = np->estats.rx_multicast;
+
+		/* detailed rx_errors */
+		storage->rx_length_errors = np->estats.rx_length_error;
+		storage->rx_over_errors   = np->estats.rx_over_errors;
+		storage->rx_crc_errors    = np->estats.rx_crc_errors;
+		storage->rx_frame_errors  = np->estats.rx_frame_align_error;
+		storage->rx_fifo_errors   = np->estats.rx_drop_frame;
+		storage->rx_missed_errors = np->stats_rx_missed_errors;
+
+		/* detailed tx_errors */
+		storage->tx_carrier_errors = np->estats.tx_carrier_errors;
+		storage->tx_fifo_errors    = np->estats.tx_fifo_errors;
+	}
+
+	return storage;
 }
 
 /*
@@ -1759,8 +1776,10 @@ static int nv_alloc_rx(struct net_device *dev)
 				np->put_rx.orig = np->first_rx.orig;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			np->stats_rx_dropped++;
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -1791,8 +1810,10 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 				np->put_rx.ex = np->first_rx.ex;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else
+		} else {
+			np->stats_rx_dropped++;
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -1928,7 +1949,7 @@ static void nv_drain_tx(struct net_device *dev)
 			np->tx_ring.ex[i].buflow = 0;
 		}
 		if (nv_release_txskb(np, &np->tx_skb[i]))
-			dev->stats.tx_dropped++;
+			np->stats_tx_dropped++;
 		np->tx_skb[i].dma = 0;
 		np->tx_skb[i].dma_len = 0;
 		np->tx_skb[i].dma_single = 0;
@@ -2651,7 +2672,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					/* the rest are hard errors */
 					else {
 						if (flags & NV_RX_MISSEDFRAME)
-							dev->stats.rx_missed_errors++;
+							np->stats_rx_missed_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
@@ -2694,7 +2715,6 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
 		napi_gro_receive(&np->napi, skb);
-		dev->stats.rx_packets++;
 next_pkt:
 		if (unlikely(np->get_rx.orig++ == np->last_rx.orig))
 			np->get_rx.orig = np->first_rx.orig;
@@ -2777,7 +2797,6 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				__vlan_hwaccel_put_tag(skb, vid);
 			}
 			napi_gro_receive(&np->napi, skb);
-			dev->stats.rx_packets++;
 		} else {
 			dev_kfree_skb(skb);
 		}
@@ -5199,7 +5218,7 @@ static int nv_close(struct net_device *dev)
 static const struct net_device_ops nv_netdev_ops = {
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
-	.ndo_get_stats		= nv_get_stats,
+	.ndo_get_stats64	= nv_get_stats64,
 	.ndo_start_xmit		= nv_start_xmit,
 	.ndo_tx_timeout		= nv_tx_timeout,
 	.ndo_change_mtu		= nv_change_mtu,
@@ -5216,7 +5235,7 @@ static const struct net_device_ops nv_netdev_ops = {
 static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_open		= nv_open,
 	.ndo_stop		= nv_close,
-	.ndo_get_stats		= nv_get_stats,
+	.ndo_get_stats64	= nv_get_stats64,
 	.ndo_start_xmit		= nv_start_xmit_optimized,
 	.ndo_tx_timeout		= nv_tx_timeout,
 	.ndo_change_mtu		= nv_change_mtu,
-- 
1.7.3.1
