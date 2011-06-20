From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/5] vxge: fix 64 bit access on 32 bit platforms
Date: Mon, 20 Jun 2011 13:35:07 -0700
Message-ID: <20110620203602.653878704@vyatta.com>
References: <20110620203506.363818794@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40991 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754985Ab1FTUpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 16:45:31 -0400
Content-Disposition: inline; filename=vxge-stats-sync.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to add stat_sync wrapper around 64 bit statistic values.
Fix wraparound bug in lockup detector where it is unsafely comparing
64 bit value that is not atomic. Since only care about detecting activity
just looking at current low order bits will work.

Remove unused entries in old vxge_sw_stats structure.
Change the error counters to unsigned long since they won't grow so large
as to have to be 64 bits.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxge/vxge-main.c	2011-06-20 11:46:03.811996124 -0700
+++ b/drivers/net/vxge/vxge-main.c	2011-06-20 12:19:42.023994994 -0700
@@ -296,11 +296,13 @@ vxge_rx_complete(struct vxge_ring *ring,
 	skb_record_rx_queue(skb, ring->driver_id);
 	skb->protocol = eth_type_trans(skb, ring->ndev);
 
+	u64_stats_update_begin(&ring->stats.syncp);
 	ring->stats.rx_frms++;
 	ring->stats.rx_bytes += pkt_length;
 
 	if (skb->pkt_type == PACKET_MULTICAST)
 		ring->stats.rx_mcast++;
+	u64_stats_update_end(&ring->stats.syncp);
 
 	vxge_debug_rx(VXGE_TRACE,
 		"%s: %s:%d  skb protocol = %d",
@@ -592,8 +594,10 @@ vxge_xmit_compl(struct __vxge_hw_fifo *f
 		vxge_hw_fifo_txdl_free(fifo_hw, dtr);
 
 		/* Updating the statistics block */
+		u64_stats_update_begin(&fifo->stats.syncp);
 		fifo->stats.tx_frms++;
 		fifo->stats.tx_bytes += skb->len;
+		u64_stats_update_end(&fifo->stats.syncp);
 
 		*done_skb++ = skb;
 
@@ -2630,11 +2634,16 @@ static void vxge_poll_vp_lockup(unsigned
 	struct vxge_vpath *vpath;
 	struct vxge_ring *ring;
 	int i;
+	unsigned long rx_frms;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		ring = &vdev->vpaths[i].ring;
+
+		/* Truncated to machine word size number of frames */
+		rx_frms = ACCESS_ONCE(ring->stats.rx_frms);
+
 		/* Did this vpath received any packets */
-		if (ring->stats.prev_rx_frms == ring->stats.rx_frms) {
+		if (ring->stats.prev_rx_frms == rx_frms) {
 			status = vxge_hw_vpath_check_leak(ring->handle);
 
 			/* Did it received any packets last time */
@@ -2654,7 +2663,7 @@ static void vxge_poll_vp_lockup(unsigned
 				}
 			}
 		}
-		ring->stats.prev_rx_frms = ring->stats.rx_frms;
+		ring->stats.prev_rx_frms = rx_frms;
 		ring->last_status = status;
 	}
 
@@ -3125,14 +3134,36 @@ vxge_get_stats64(struct net_device *dev,
 
 	/* net_stats already zeroed by caller */
 	for (k = 0; k < vdev->no_of_vpath; k++) {
-		net_stats->rx_packets += vdev->vpaths[k].ring.stats.rx_frms;
-		net_stats->rx_bytes += vdev->vpaths[k].ring.stats.rx_bytes;
-		net_stats->rx_errors += vdev->vpaths[k].ring.stats.rx_errors;
-		net_stats->multicast += vdev->vpaths[k].ring.stats.rx_mcast;
-		net_stats->rx_dropped += vdev->vpaths[k].ring.stats.rx_dropped;
-		net_stats->tx_packets += vdev->vpaths[k].fifo.stats.tx_frms;
-		net_stats->tx_bytes += vdev->vpaths[k].fifo.stats.tx_bytes;
-		net_stats->tx_errors += vdev->vpaths[k].fifo.stats.tx_errors;
+		struct vxge_ring_stats *rxstats = &vdev->vpaths[k].ring.stats;
+		struct vxge_fifo_stats *txstats = &vdev->vpaths[k].fifo.stats;
+		unsigned int start;
+		u64 packets, bytes, multicast;
+
+		do {
+			start = u64_stats_fetch_begin(&rxstats->syncp);
+
+			packets   = rxstats->rx_frms;
+			multicast = rxstats->rx_mcast;
+			bytes     = rxstats->rx_bytes;
+		} while (u64_stats_fetch_retry(&rxstats->syncp, start));
+
+		net_stats->rx_packets += packets;
+		net_stats->rx_bytes += bytes;
+		net_stats->multicast += multicast;
+
+		net_stats->rx_errors += rxstats->rx_errors;
+		net_stats->rx_dropped += rxstats->rx_dropped;
+
+		do {
+			start = u64_stats_fetch_begin(&txstats->syncp);
+
+			packets = txstats->tx_frms;
+			bytes   = txstats->tx_bytes;
+		} while (u64_stats_fetch_retry(&txstats->syncp, start));
+
+		net_stats->tx_packets += packets;
+		net_stats->tx_bytes += bytes;
+		net_stats->tx_errors += txstats->tx_errors;
 	}
 
 	return net_stats;
--- a/drivers/net/vxge/vxge-main.h	2011-06-20 11:46:33.195996108 -0700
+++ b/drivers/net/vxge/vxge-main.h	2011-06-20 12:16:35.527995099 -0700
@@ -201,30 +201,14 @@ struct vxge_msix_entry {
 /* Software Statistics */
 
 struct vxge_sw_stats {
-	/* Network Stats (interface stats) */
-
-	/* Tx */
-	u64 tx_frms;
-	u64 tx_errors;
-	u64 tx_bytes;
-	u64 txd_not_free;
-	u64 txd_out_of_desc;
 
 	/* Virtual Path */
-	u64 vpaths_open;
-	u64 vpath_open_fail;
-
-	/* Rx */
-	u64 rx_frms;
-	u64 rx_errors;
-	u64 rx_bytes;
-	u64 rx_mcast;
+	unsigned long vpaths_open;
+	unsigned long vpath_open_fail;
 
 	/* Misc. */
-	u64 link_up;
-	u64 link_down;
-	u64 pci_map_fail;
-	u64 skb_alloc_fail;
+	unsigned long link_up;
+	unsigned long link_down;
 };
 
 struct vxge_mac_addrs {
@@ -237,12 +221,14 @@ struct vxge_mac_addrs {
 struct vxgedev;
 
 struct vxge_fifo_stats {
+	struct u64_stats_sync	syncp;
 	u64 tx_frms;
-	u64 tx_errors;
 	u64 tx_bytes;
-	u64 txd_not_free;
-	u64 txd_out_of_desc;
-	u64 pci_map_fail;
+
+	unsigned long tx_errors;
+	unsigned long txd_not_free;
+	unsigned long txd_out_of_desc;
+	unsigned long pci_map_fail;
 };
 
 struct vxge_fifo {
@@ -264,14 +250,16 @@ struct vxge_fifo {
 } ____cacheline_aligned;
 
 struct vxge_ring_stats {
-	u64 prev_rx_frms;
+	struct u64_stats_sync syncp;
 	u64 rx_frms;
-	u64 rx_errors;
-	u64 rx_dropped;
-	u64 rx_bytes;
 	u64 rx_mcast;
-	u64 pci_map_fail;
-	u64 skb_alloc_fail;
+	u64 rx_bytes;
+
+	unsigned long rx_errors;
+	unsigned long rx_dropped;
+	unsigned long prev_rx_frms;
+	unsigned long pci_map_fail;
+	unsigned long skb_alloc_fail;
 };
 
 struct vxge_ring {


