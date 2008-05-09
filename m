From: Brice Goglin <brice@myri.com>
Subject: [PATCH 10/16] myri10ge: move data structures into a single slice
Date: Fri, 09 May 2008 02:20:03 +0200
Message-ID: <482398B3.4080305@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934381AbYEIAq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:28 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare and simplify multislice rx support, add a single slice
structure and move some fields in there.
No functional change yet.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  594 +++++++++++++++++++++-------------------
 1 file changed, 316 insertions(+), 278 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:10:57.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:11:31.000000000 +0200
@@ -144,11 +144,13 @@
 	char *req_bytes;
 	struct myri10ge_tx_buffer_state *info;
 	int mask;		/* number of transmit slots -1  */
-	int boundary;		/* boundary transmits cannot cross */
 	int req ____cacheline_aligned;	/* transmit slots submitted     */
 	int pkt_start;		/* packets started */
+	int stop_queue;
+	int linearized;
 	int done ____cacheline_aligned;	/* transmit slots completed     */
 	int pkt_done;		/* packets completed */
+	int wake_queue;
 };
 
 struct myri10ge_rx_done {
@@ -160,29 +162,49 @@
 	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
 };
 
-struct myri10ge_priv {
-	int running;		/* running?             */
-	int csum_flag;		/* rx_csums?            */
+struct myri10ge_slice_netstats {
+	unsigned long rx_packets;
+	unsigned long tx_packets;
+	unsigned long rx_bytes;
+	unsigned long tx_bytes;
+	unsigned long rx_dropped;
+	unsigned long tx_dropped;
+};
+
+struct myri10ge_slice_state {
 	struct myri10ge_tx_buf tx;	/* transmit ring        */
 	struct myri10ge_rx_buf rx_small;
 	struct myri10ge_rx_buf rx_big;
 	struct myri10ge_rx_done rx_done;
+	struct net_device *dev;
+	struct napi_struct napi;
+	struct myri10ge_priv *mgp;
+	struct myri10ge_slice_netstats stats;
+	__be32 __iomem *irq_claim;
+	struct mcp_irq_data *fw_stats;
+	dma_addr_t fw_stats_bus;
+	int watchdog_tx_done;
+	int watchdog_tx_req;
+};
+
+struct myri10ge_priv {
+	struct myri10ge_slice_state ss;
+	int tx_boundary;	/* boundary transmits cannot cross */
+	int running;		/* running?             */
+	int csum_flag;		/* rx_csums?            */
 	int small_bytes;
 	int big_bytes;
 	struct net_device *dev;
-	struct napi_struct napi;
 	struct net_device_stats stats;
+	spinlock_t stats_lock;
 	u8 __iomem *sram;
 	int sram_size;
 	unsigned long board_span;
 	unsigned long iomem_base;
-	__be32 __iomem *irq_claim;
 	__be32 __iomem *irq_deassert;
 	char *mac_addr_string;
 	struct mcp_cmd_response *cmd;
 	dma_addr_t cmd_bus;
-	struct mcp_irq_data *fw_stats;
-	dma_addr_t fw_stats_bus;
 	struct pci_dev *pdev;
 	int msi_enabled;
 	u32 link_state;
@@ -191,17 +213,12 @@
 	__be32 __iomem *intr_coal_delay_ptr;
 	int mtrr;
 	int wc_enabled;
-	int wake_queue;
-	int stop_queue;
 	int down_cnt;
 	wait_queue_head_t down_wq;
 	struct work_struct watchdog_work;
 	struct timer_list watchdog_timer;
-	int watchdog_tx_done;
-	int watchdog_tx_req;
-	int watchdog_pause;
 	int watchdog_resets;
-	int tx_linearized;
+	int watchdog_pause;
 	int pause;
 	char *fw_name;
 	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
@@ -643,7 +660,7 @@
 		}
 		dev_info(&mgp->pdev->dev,
 			 "Successfully adopted running firmware\n");
-		if (mgp->tx.boundary == 4096) {
+		if (mgp->tx_boundary == 4096) {
 			dev_warn(&mgp->pdev->dev,
 				 "Using firmware currently running on NIC"
 				 ".  For optimal\n");
@@ -654,7 +671,7 @@
 		}
 
 		mgp->fw_name = "adopted";
-		mgp->tx.boundary = 2048;
+		mgp->tx_boundary = 2048;
 		return status;
 	}
 
@@ -780,7 +797,7 @@
 	 * transfers took to complete.
 	 */
 
-	len = mgp->tx.boundary;
+	len = mgp->tx_boundary;
 
 	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
 	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
@@ -842,17 +859,17 @@
 
 	/* Now exchange information about interrupts  */
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	memset(mgp->rx_done.entry, 0, bytes);
+	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 	cmd.data0 = (u32) bytes;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.rx_done.bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.rx_done.bus);
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA, &cmd, 0);
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
-	mgp->irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
+	mgp->ss.irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
 				    &cmd, 0);
 	mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
@@ -866,17 +883,17 @@
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	memset(mgp->rx_done.entry, 0, bytes);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */
-	mgp->tx.req = 0;
-	mgp->tx.done = 0;
-	mgp->tx.pkt_start = 0;
-	mgp->tx.pkt_done = 0;
-	mgp->rx_big.cnt = 0;
-	mgp->rx_small.cnt = 0;
-	mgp->rx_done.idx = 0;
-	mgp->rx_done.cnt = 0;
+	mgp->ss.tx.req = 0;
+	mgp->ss.tx.done = 0;
+	mgp->ss.tx.pkt_start = 0;
+	mgp->ss.tx.pkt_done = 0;
+	mgp->ss.rx_big.cnt = 0;
+	mgp->ss.rx_small.cnt = 0;
+	mgp->ss.rx_done.idx = 0;
+	mgp->ss.rx_done.cnt = 0;
 	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -1028,9 +1045,10 @@
 				 * page into an skb */
 
 static inline int
-myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		 int bytes, int len, __wsum csum)
 {
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
 	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
 	int i, idx, hlen, remainder;
@@ -1060,11 +1078,10 @@
 		rx_frags[0].page_offset += MXGEFW_PAD;
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
-		lro_receive_frags(&mgp->rx_done.lro_mgr, rx_frags,
+		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
 				  len, len,
-				 /* opaque, will come back in get_frag_header */
-				  (void *)(__force unsigned long)csum,
-				  csum);
+				  /* opaque, will come back in get_frag_header */
+				  (void *)(__force unsigned long)csum, csum);
 		return 1;
 	}
 
@@ -1104,10 +1121,11 @@
 	return 1;
 }
 
-static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
+static inline void
+myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 {
-	struct pci_dev *pdev = mgp->pdev;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct pci_dev *pdev = ss->mgp->pdev;
+	struct myri10ge_tx_buf *tx = &ss->tx;
 	struct sk_buff *skb;
 	int idx, len;
 
@@ -1125,8 +1143,8 @@
 		len = pci_unmap_len(&tx->info[idx], len);
 		pci_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
-			mgp->stats.tx_bytes += skb->len;
-			mgp->stats.tx_packets++;
+			ss->stats.tx_bytes += skb->len;
+			ss->stats.tx_packets++;
 			dev_kfree_skb_irq(skb);
 			if (len)
 				pci_unmap_single(pdev,
@@ -1142,16 +1160,18 @@
 		}
 	}
 	/* start the queue if we've stopped it */
-	if (netif_queue_stopped(mgp->dev)
+	if (netif_queue_stopped(ss->dev)
 	    && tx->req - tx->done < (tx->mask >> 1)) {
-		mgp->wake_queue++;
-		netif_wake_queue(mgp->dev);
+		tx->wake_queue++;
+		netif_wake_queue(ss->dev);
 	}
 }
 
-static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
+static inline int
+myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 {
-	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
+	struct myri10ge_rx_done *rx_done = &ss->rx_done;
+	struct myri10ge_priv *mgp = ss->mgp;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1167,11 +1187,11 @@
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
 		if (length <= mgp->small_bytes)
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_small,
+			rx_ok = myri10ge_rx_done(ss, &ss->rx_small,
 						 mgp->small_bytes,
 						 length, checksum);
 		else
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_big,
+			rx_ok = myri10ge_rx_done(ss, &ss->rx_big,
 						 mgp->big_bytes,
 						 length, checksum);
 		rx_packets += rx_ok;
@@ -1182,25 +1202,25 @@
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
-	mgp->stats.rx_packets += rx_packets;
-	mgp->stats.rx_bytes += rx_bytes;
+	ss->stats.rx_packets += rx_packets;
+	ss->stats.rx_bytes += rx_bytes;
 
 	if (myri10ge_lro)
 		lro_flush_all(&rx_done->lro_mgr);
 
 	/* restock receive rings if needed */
-	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	if (ss->rx_small.fill_cnt - ss->rx_small.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 					mgp->small_bytes + MXGEFW_PAD, 0);
-	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+	if (ss->rx_big.fill_cnt - ss->rx_big.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
 
 	return work_done;
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 {
-	struct mcp_irq_data *stats = mgp->fw_stats;
+	struct mcp_irq_data *stats = mgp->ss.fw_stats;
 
 	if (unlikely(stats->stats_updated)) {
 		unsigned link_up = ntohl(stats->link_up);
@@ -1227,9 +1247,9 @@
 			}
 		}
 		if (mgp->rdma_tags_available !=
-		    ntohl(mgp->fw_stats->rdma_tags_available)) {
+		    ntohl(stats->rdma_tags_available)) {
 			mgp->rdma_tags_available =
-			    ntohl(mgp->fw_stats->rdma_tags_available);
+			    ntohl(stats->rdma_tags_available);
 			printk(KERN_WARNING "myri10ge: %s: RDMA timed out! "
 			       "%d tags left\n", mgp->dev->name,
 			       mgp->rdma_tags_available);
@@ -1242,26 +1262,27 @@
 
 static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
-	struct myri10ge_priv *mgp =
-	    container_of(napi, struct myri10ge_priv, napi);
-	struct net_device *netdev = mgp->dev;
+	struct myri10ge_slice_state *ss =
+	    container_of(napi, struct myri10ge_slice_state, napi);
+	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
 	/* process as many rx events as NAPI will allow */
-	work_done = myri10ge_clean_rx_done(mgp, budget);
+	work_done = myri10ge_clean_rx_done(ss, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		put_be32(htonl(3), mgp->irq_claim);
+		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
 }
 
 static irqreturn_t myri10ge_intr(int irq, void *arg)
 {
-	struct myri10ge_priv *mgp = arg;
-	struct mcp_irq_data *stats = mgp->fw_stats;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct myri10ge_slice_state *ss = arg;
+	struct myri10ge_priv *mgp = ss->mgp;
+	struct mcp_irq_data *stats = ss->fw_stats;
+	struct myri10ge_tx_buf *tx = &ss->tx;
 	u32 send_done_count;
 	int i;
 
@@ -1272,7 +1293,7 @@
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(mgp->dev, &mgp->napi);
+		netif_rx_schedule(ss->dev, &ss->napi);
 
 	if (!mgp->msi_enabled) {
 		put_be32(0, mgp->irq_deassert);
@@ -1289,7 +1310,7 @@
 		/* check for transmit completes and receives */
 		send_done_count = ntohl(stats->send_done_count);
 		if (send_done_count != tx->pkt_done)
-			myri10ge_tx_done(mgp, (int)send_done_count);
+			myri10ge_tx_done(ss, (int)send_done_count);
 		if (unlikely(i > myri10ge_max_irq_loops)) {
 			printk(KERN_WARNING "myri10ge: %s: irq stuck?\n",
 			       mgp->dev->name);
@@ -1304,7 +1325,7 @@
 
 	myri10ge_check_statblock(mgp);
 
-	put_be32(htonl(3), mgp->irq_claim + 1);
+	put_be32(htonl(3), ss->irq_claim + 1);
 	return (IRQ_HANDLED);
 }
 
@@ -1409,10 +1430,10 @@
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 
-	ring->rx_mini_max_pending = mgp->rx_small.mask + 1;
-	ring->rx_max_pending = mgp->rx_big.mask + 1;
+	ring->rx_mini_max_pending = mgp->ss.rx_small.mask + 1;
+	ring->rx_max_pending = mgp->ss.rx_big.mask + 1;
 	ring->rx_jumbo_max_pending = 0;
-	ring->tx_max_pending = mgp->rx_small.mask + 1;
+	ring->tx_max_pending = mgp->ss.rx_small.mask + 1;
 	ring->rx_mini_pending = ring->rx_mini_max_pending;
 	ring->rx_pending = ring->rx_max_pending;
 	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
@@ -1452,7 +1473,7 @@
 	return 0;
 }
 
-static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
+static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
 	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
@@ -1462,28 +1483,39 @@
 	/* device-specific stats */
 	"tx_boundary", "WC", "irq", "MSI",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
-	"serial_number", "tx_pkt_start", "tx_pkt_done",
-	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
+	"serial_number", "watchdog_resets",
 	"link_changes", "link_up", "dropped_link_overflow",
 	"dropped_link_error_or_filtered",
 	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
 	"dropped_unicast_filtered", "dropped_multicast_filtered",
 	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
-	"dropped_no_big_buffer", "LRO aggregated", "LRO flushed",
+	"dropped_no_big_buffer"
+};
+
+static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
+	"----------- slice ---------",
+	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
+	"rx_small_cnt", "rx_big_cnt",
+	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
+	    "LRO flushed",
 	"LRO avg aggr", "LRO no_desc"
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
-#define MYRI10GE_STATS_LEN	ARRAY_SIZE(myri10ge_gstrings_stats)
+#define MYRI10GE_MAIN_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_main_stats)
+#define MYRI10GE_SLICE_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_slice_stats)
 
 static void
 myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
 {
 	switch (stringset) {
 	case ETH_SS_STATS:
-		memcpy(data, *myri10ge_gstrings_stats,
-		       sizeof(myri10ge_gstrings_stats));
+		memcpy(data, *myri10ge_gstrings_main_stats,
+		       sizeof(myri10ge_gstrings_main_stats));
+		data += sizeof(myri10ge_gstrings_main_stats);
+		memcpy(data, *myri10ge_gstrings_slice_stats,
+		       sizeof(myri10ge_gstrings_slice_stats));
+		data += sizeof(myri10ge_gstrings_slice_stats);
 		break;
 	}
 }
@@ -1492,7 +1524,7 @@
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MYRI10GE_STATS_LEN;
+		return MYRI10GE_MAIN_STATS_LEN + MYRI10GE_SLICE_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1503,12 +1535,13 @@
 			   struct ethtool_stats *stats, u64 * data)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	struct myri10ge_slice_state *ss;
 	int i;
 
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
-	data[i++] = (unsigned int)mgp->tx.boundary;
+	data[i++] = (unsigned int)mgp->tx_boundary;
 	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
@@ -1516,40 +1549,44 @@
 	data[i++] = (unsigned int)mgp->write_dma;
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
-	data[i++] = (unsigned int)mgp->tx.pkt_start;
-	data[i++] = (unsigned int)mgp->tx.pkt_done;
-	data[i++] = (unsigned int)mgp->tx.req;
-	data[i++] = (unsigned int)mgp->tx.done;
-	data[i++] = (unsigned int)mgp->rx_small.cnt;
-	data[i++] = (unsigned int)mgp->rx_big.cnt;
-	data[i++] = (unsigned int)mgp->wake_queue;
-	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-	data[i++] = (unsigned int)mgp->tx_linearized;
 	data[i++] = (unsigned int)mgp->link_changes;
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->link_up);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
-	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_link_error_or_filtered);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_pause);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_phy);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_crc32);
+
+	/* firmware stats are useful only in the first slice */
+	ss = &mgp->ss;
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
 	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_unicast_filtered);
+	    (unsigned int)ntohl(ss->fw_stats->dropped_link_error_or_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_pause);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_phy);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_crc32);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_unicast_filtered);
 	data[i++] =
-	    (unsigned int)ntohl(mgp->fw_stats->dropped_multicast_filtered);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_runt);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_overrun);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_small_buffer);
-	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_big_buffer);
-	data[i++] = mgp->rx_done.lro_mgr.stats.aggregated;
-	data[i++] = mgp->rx_done.lro_mgr.stats.flushed;
-	if (mgp->rx_done.lro_mgr.stats.flushed)
-		data[i++] = mgp->rx_done.lro_mgr.stats.aggregated /
-		    mgp->rx_done.lro_mgr.stats.flushed;
+	    (unsigned int)ntohl(ss->fw_stats->dropped_multicast_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_runt);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_overrun);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
+
+	data[i++] = 0;
+	data[i++] = (unsigned int)ss->tx.pkt_start;
+	data[i++] = (unsigned int)ss->tx.pkt_done;
+	data[i++] = (unsigned int)ss->tx.req;
+	data[i++] = (unsigned int)ss->tx.done;
+	data[i++] = (unsigned int)ss->rx_small.cnt;
+	data[i++] = (unsigned int)ss->rx_big.cnt;
+	data[i++] = (unsigned int)ss->tx.wake_queue;
+	data[i++] = (unsigned int)ss->tx.stop_queue;
+	data[i++] = (unsigned int)ss->tx.linearized;
+	data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
+	data[i++] = ss->rx_done.lro_mgr.stats.flushed;
+	if (ss->rx_done.lro_mgr.stats.flushed)
+		data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
+		    ss->rx_done.lro_mgr.stats.flushed;
 	else
 		data[i++] = 0;
-	data[i++] = mgp->rx_done.lro_mgr.stats.no_desc;
+	data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
 }
 
 static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
@@ -1585,19 +1622,17 @@
 	.get_msglevel = myri10ge_get_msglevel
 };
 
-static int myri10ge_allocate_rings(struct net_device *dev)
+static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct myri10ge_cmd cmd;
+	struct net_device *dev = mgp->dev;
 	int tx_ring_size, rx_ring_size;
 	int tx_ring_entries, rx_ring_entries;
 	int i, status;
 	size_t bytes;
 
-	mgp = netdev_priv(dev);
-
 	/* get ring sizes */
-
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
@@ -1607,144 +1642,142 @@
 
 	tx_ring_entries = tx_ring_size / sizeof(struct mcp_kreq_ether_send);
 	rx_ring_entries = rx_ring_size / sizeof(struct mcp_dma_addr);
-	mgp->tx.mask = tx_ring_entries - 1;
-	mgp->rx_small.mask = mgp->rx_big.mask = rx_ring_entries - 1;
+	ss->tx.mask = tx_ring_entries - 1;
+	ss->rx_small.mask = ss->rx_big.mask = rx_ring_entries - 1;
 
 	status = -ENOMEM;
 
 	/* allocate the host shadow rings */
 
 	bytes = 8 + (MYRI10GE_MAX_SEND_DESC_TSO + 4)
-	    * sizeof(*mgp->tx.req_list);
-	mgp->tx.req_bytes = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->tx.req_bytes == NULL)
+	    * sizeof(*ss->tx.req_list);
+	ss->tx.req_bytes = kzalloc(bytes, GFP_KERNEL);
+	if (ss->tx.req_bytes == NULL)
 		goto abort_with_nothing;
 
 	/* ensure req_list entries are aligned to 8 bytes */
-	mgp->tx.req_list = (struct mcp_kreq_ether_send *)
-	    ALIGN((unsigned long)mgp->tx.req_bytes, 8);
+	ss->tx.req_list = (struct mcp_kreq_ether_send *)
+	    ALIGN((unsigned long)ss->tx.req_bytes, 8);
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_small.shadow);
-	mgp->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_small.shadow == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_small.shadow);
+	ss->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_small.shadow == NULL)
 		goto abort_with_tx_req_bytes;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_big.shadow);
-	mgp->rx_big.shadow = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_big.shadow == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_big.shadow);
+	ss->rx_big.shadow = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_big.shadow == NULL)
 		goto abort_with_rx_small_shadow;
 
 	/* allocate the host info rings */
 
-	bytes = tx_ring_entries * sizeof(*mgp->tx.info);
-	mgp->tx.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->tx.info == NULL)
+	bytes = tx_ring_entries * sizeof(*ss->tx.info);
+	ss->tx.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->tx.info == NULL)
 		goto abort_with_rx_big_shadow;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_small.info);
-	mgp->rx_small.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_small.info == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_small.info);
+	ss->rx_small.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_small.info == NULL)
 		goto abort_with_tx_info;
 
-	bytes = rx_ring_entries * sizeof(*mgp->rx_big.info);
-	mgp->rx_big.info = kzalloc(bytes, GFP_KERNEL);
-	if (mgp->rx_big.info == NULL)
+	bytes = rx_ring_entries * sizeof(*ss->rx_big.info);
+	ss->rx_big.info = kzalloc(bytes, GFP_KERNEL);
+	if (ss->rx_big.info == NULL)
 		goto abort_with_rx_small_info;
 
 	/* Fill the receive rings */
-	mgp->rx_big.cnt = 0;
-	mgp->rx_small.cnt = 0;
-	mgp->rx_big.fill_cnt = 0;
-	mgp->rx_small.fill_cnt = 0;
-	mgp->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
-	mgp->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
-	mgp->rx_small.watchdog_needed = 0;
-	mgp->rx_big.watchdog_needed = 0;
-	myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	ss->rx_big.cnt = 0;
+	ss->rx_small.cnt = 0;
+	ss->rx_big.fill_cnt = 0;
+	ss->rx_small.fill_cnt = 0;
+	ss->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
+	ss->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
+	ss->rx_small.watchdog_needed = 0;
+	ss->rx_big.watchdog_needed = 0;
+	myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 				mgp->small_bytes + MXGEFW_PAD, 0);
 
-	if (mgp->rx_small.fill_cnt < mgp->rx_small.mask + 1) {
+	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
 		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
-		       dev->name, mgp->rx_small.fill_cnt);
+		       dev->name, ss->rx_small.fill_cnt);
 		goto abort_with_rx_small_ring;
 	}
 
-	myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
-	if (mgp->rx_big.fill_cnt < mgp->rx_big.mask + 1) {
+	myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
+	if (ss->rx_big.fill_cnt < ss->rx_big.mask + 1) {
 		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
-		       dev->name, mgp->rx_big.fill_cnt);
+		       dev->name, ss->rx_big.fill_cnt);
 		goto abort_with_rx_big_ring;
 	}
 
 	return 0;
 
 abort_with_rx_big_ring:
-	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
-		int idx = i & mgp->rx_big.mask;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
+		int idx = i & ss->rx_big.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_big.info[idx],
 				       mgp->big_bytes);
-		put_page(mgp->rx_big.info[idx].page);
+		put_page(ss->rx_big.info[idx].page);
 	}
 
 abort_with_rx_small_ring:
-	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
-		int idx = i & mgp->rx_small.mask;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
+		int idx = i & ss->rx_small.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_small.info[idx],
 				       mgp->small_bytes + MXGEFW_PAD);
-		put_page(mgp->rx_small.info[idx].page);
+		put_page(ss->rx_small.info[idx].page);
 	}
 
-	kfree(mgp->rx_big.info);
+	kfree(ss->rx_big.info);
 
 abort_with_rx_small_info:
-	kfree(mgp->rx_small.info);
+	kfree(ss->rx_small.info);
 
 abort_with_tx_info:
-	kfree(mgp->tx.info);
+	kfree(ss->tx.info);
 
 abort_with_rx_big_shadow:
-	kfree(mgp->rx_big.shadow);
+	kfree(ss->rx_big.shadow);
 
 abort_with_rx_small_shadow:
-	kfree(mgp->rx_small.shadow);
+	kfree(ss->rx_small.shadow);
 
 abort_with_tx_req_bytes:
-	kfree(mgp->tx.req_bytes);
-	mgp->tx.req_bytes = NULL;
-	mgp->tx.req_list = NULL;
+	kfree(ss->tx.req_bytes);
+	ss->tx.req_bytes = NULL;
+	ss->tx.req_list = NULL;
 
 abort_with_nothing:
 	return status;
 }
 
-static void myri10ge_free_rings(struct net_device *dev)
+static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
 	struct myri10ge_tx_buf *tx;
 	int i, len, idx;
 
-	mgp = netdev_priv(dev);
-
-	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
-		idx = i & mgp->rx_big.mask;
-		if (i == mgp->rx_big.fill_cnt - 1)
-			mgp->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
+		idx = i & ss->rx_big.mask;
+		if (i == ss->rx_big.fill_cnt - 1)
+			ss->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_big.info[idx],
 				       mgp->big_bytes);
-		put_page(mgp->rx_big.info[idx].page);
+		put_page(ss->rx_big.info[idx].page);
 	}
 
-	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
-		idx = i & mgp->rx_small.mask;
-		if (i == mgp->rx_small.fill_cnt - 1)
-			mgp->rx_small.info[idx].page_offset =
+	for (i = ss->rx_small.cnt; i < ss->rx_small.fill_cnt; i++) {
+		idx = i & ss->rx_small.mask;
+		if (i == ss->rx_small.fill_cnt - 1)
+			ss->rx_small.info[idx].page_offset =
 			    MYRI10GE_ALLOC_SIZE;
-		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+		myri10ge_unmap_rx_page(mgp->pdev, &ss->rx_small.info[idx],
 				       mgp->small_bytes + MXGEFW_PAD);
-		put_page(mgp->rx_small.info[idx].page);
+		put_page(ss->rx_small.info[idx].page);
 	}
-	tx = &mgp->tx;
+	tx = &ss->tx;
 	while (tx->done != tx->req) {
 		idx = tx->done & tx->mask;
 		skb = tx->info[idx].skb;
@@ -1755,7 +1788,7 @@
 		len = pci_unmap_len(&tx->info[idx], len);
 		pci_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
-			mgp->stats.tx_dropped++;
+			ss->stats.tx_dropped++;
 			dev_kfree_skb_any(skb);
 			if (len)
 				pci_unmap_single(mgp->pdev,
@@ -1770,19 +1803,19 @@
 					       PCI_DMA_TODEVICE);
 		}
 	}
-	kfree(mgp->rx_big.info);
+	kfree(ss->rx_big.info);
 
-	kfree(mgp->rx_small.info);
+	kfree(ss->rx_small.info);
 
-	kfree(mgp->tx.info);
+	kfree(ss->tx.info);
 
-	kfree(mgp->rx_big.shadow);
+	kfree(ss->rx_big.shadow);
 
-	kfree(mgp->rx_small.shadow);
+	kfree(ss->rx_small.shadow);
 
-	kfree(mgp->tx.req_bytes);
-	mgp->tx.req_bytes = NULL;
-	mgp->tx.req_list = NULL;
+	kfree(ss->tx.req_bytes);
+	ss->tx.req_bytes = NULL;
+	ss->tx.req_list = NULL;
 }
 
 static int myri10ge_request_irq(struct myri10ge_priv *mgp)
@@ -1881,13 +1914,11 @@
 
 static int myri10ge_open(struct net_device *dev)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	struct net_lro_mgr *lro_mgr;
 	int status, big_pow2;
 
-	mgp = netdev_priv(dev);
-
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
 
@@ -1924,16 +1955,16 @@
 	/* get the lanai pointers to the send and receive rings */
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
-	mgp->tx.lanai =
+	mgp->ss.tx.lanai =
 	    (struct mcp_kreq_ether_send __iomem *)(mgp->sram + cmd.data0);
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET, &cmd, 0);
-	mgp->rx_small.lanai =
+	mgp->ss.rx_small.lanai =
 	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
-	mgp->rx_big.lanai =
+	mgp->ss.rx_big.lanai =
 	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
 
 	if (status != 0) {
@@ -1945,15 +1976,15 @@
 	}
 
 	if (myri10ge_wcfifo && mgp->wc_enabled) {
-		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
-		mgp->rx_small.wc_fifo =
+		mgp->ss.tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
+		mgp->ss.rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
-		mgp->rx_big.wc_fifo =
+		mgp->ss.rx_big.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_BIG;
 	} else {
-		mgp->tx.wc_fifo = NULL;
-		mgp->rx_small.wc_fifo = NULL;
-		mgp->rx_big.wc_fifo = NULL;
+		mgp->ss.tx.wc_fifo = NULL;
+		mgp->ss.rx_small.wc_fifo = NULL;
+		mgp->ss.rx_big.wc_fifo = NULL;
 	}
 
 	/* Firmware needs the big buff size as a power of 2.  Lie and
@@ -1970,7 +2001,7 @@
 		mgp->big_bytes = big_pow2;
 	}
 
-	status = myri10ge_allocate_rings(dev);
+	status = myri10ge_allocate_rings(&mgp->ss);
 	if (status != 0)
 		goto abort_with_irq;
 
@@ -1989,12 +2020,12 @@
 		goto abort_with_rings;
 	}
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->fw_stats_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->fw_stats_bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.fw_stats_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.fw_stats_bus);
 	cmd.data2 = sizeof(struct mcp_irq_data);
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
 	if (status == -ENOSYS) {
-		dma_addr_t bus = mgp->fw_stats_bus;
+		dma_addr_t bus = mgp->ss.fw_stats_bus;
 		bus += offsetof(struct mcp_irq_data, send_done_count);
 		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
 		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
@@ -2015,20 +2046,20 @@
 	mgp->link_state = ~0U;
 	mgp->rdma_tags_available = 15;
 
-	lro_mgr = &mgp->rx_done.lro_mgr;
+	lro_mgr = &mgp->ss.rx_done.lro_mgr;
 	lro_mgr->dev = dev;
 	lro_mgr->features = LRO_F_NAPI;
 	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
 	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
 	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
-	lro_mgr->lro_arr = mgp->rx_done.lro_desc;
+	lro_mgr->lro_arr = mgp->ss.rx_done.lro_desc;
 	lro_mgr->get_frag_header = myri10ge_get_frag_header;
 	lro_mgr->max_aggr = myri10ge_lro_max_pkts;
 	lro_mgr->frag_align_pad = 2;
 	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
 		lro_mgr->max_aggr = MAX_SKB_FRAGS;
 
-	napi_enable(&mgp->napi);	/* must happen prior to any irq */
+	napi_enable(&mgp->ss.napi);	/* must happen prior to any irq */
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
@@ -2037,8 +2068,8 @@
 		goto abort_with_rings;
 	}
 
-	mgp->wake_queue = 0;
-	mgp->stop_queue = 0;
+	mgp->ss.tx.wake_queue = 0;
+	mgp->ss.tx.stop_queue = 0;
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
@@ -2046,7 +2077,7 @@
 	return 0;
 
 abort_with_rings:
-	myri10ge_free_rings(dev);
+	myri10ge_free_rings(&mgp->ss);
 
 abort_with_irq:
 	myri10ge_free_irq(mgp);
@@ -2058,21 +2089,19 @@
 
 static int myri10ge_close(struct net_device *dev)
 {
-	struct myri10ge_priv *mgp;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	int status, old_down_cnt;
 
-	mgp = netdev_priv(dev);
-
 	if (mgp->running != MYRI10GE_ETH_RUNNING)
 		return 0;
 
-	if (mgp->tx.req_bytes == NULL)
+	if (mgp->ss.tx.req_bytes == NULL)
 		return 0;
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	napi_disable(&mgp->napi);
+	napi_disable(&mgp->ss.napi);
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 	old_down_cnt = mgp->down_cnt;
@@ -2088,7 +2117,7 @@
 
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
-	myri10ge_free_rings(dev);
+	myri10ge_free_rings(&mgp->ss);
 
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return 0;
@@ -2184,7 +2213,7 @@
 
 /*
  * Transmit a packet.  We need to split the packet so that a single
- * segment does not cross myri10ge->tx.boundary, so this makes segment
+ * segment does not cross myri10ge->tx_boundary, so this makes segment
  * counting tricky.  So rather than try to count segments up front, we
  * just give up if there are too few segments to hold a reasonably
  * fragmented packet currently available.  If we run
@@ -2195,8 +2224,9 @@
 static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct myri10ge_slice_state *ss;
 	struct mcp_kreq_ether_send *req;
-	struct myri10ge_tx_buf *tx = &mgp->tx;
+	struct myri10ge_tx_buf *tx;
 	struct skb_frag_struct *frag;
 	dma_addr_t bus;
 	u32 low;
@@ -2207,6 +2237,9 @@
 	int cum_len, seglen, boundary, rdma_count;
 	u8 flags, odd_flag;
 
+	/* always transmit through slot 0 */
+	ss = &mgp->ss;
+	tx = &ss->tx;
 again:
 	req = tx->req_list;
 	avail = tx->mask - 1 - (tx->req - tx->done);
@@ -2221,7 +2254,7 @@
 
 	if ((unlikely(avail < max_segments))) {
 		/* we are out of transmit resources */
-		mgp->stop_queue++;
+		tx->stop_queue++;
 		netif_stop_queue(dev);
 		return 1;
 	}
@@ -2283,7 +2316,7 @@
 			if (skb_padto(skb, ETH_ZLEN)) {
 				/* The packet is gone, so we must
 				 * return 0 */
-				mgp->stats.tx_dropped += 1;
+				ss->stats.tx_dropped += 1;
 				return 0;
 			}
 			/* adjust the len to account for the zero pad
@@ -2325,7 +2358,7 @@
 
 	while (1) {
 		/* Break the SKB or Fragment up into pieces which
-		 * do not cross mgp->tx.boundary */
+		 * do not cross mgp->tx_boundary */
 		low = MYRI10GE_LOWPART_TO_U32(bus);
 		high_swapped = htonl(MYRI10GE_HIGHPART_TO_U32(bus));
 		while (len) {
@@ -2335,7 +2368,8 @@
 			if (unlikely(count == max_segments))
 				goto abort_linearize;
 
-			boundary = (low + tx->boundary) & ~(tx->boundary - 1);
+			boundary =
+			    (low + mgp->tx_boundary) & ~(mgp->tx_boundary - 1);
 			seglen = boundary - low;
 			if (seglen > len)
 				seglen = len;
@@ -2419,7 +2453,7 @@
 		myri10ge_submit_req_wc(tx, tx->req_list, count);
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
-		mgp->stop_queue++;
+		tx->stop_queue++;
 		netif_stop_queue(dev);
 	}
 	dev->trans_start = jiffies;
@@ -2461,12 +2495,12 @@
 	if (skb_linearize(skb))
 		goto drop;
 
-	mgp->tx_linearized++;
+	tx->linearized++;
 	goto again;
 
 drop:
 	dev_kfree_skb_any(skb);
-	mgp->stats.tx_dropped += 1;
+	ss->stats.tx_dropped += 1;
 	return 0;
 
 }
@@ -2474,7 +2508,7 @@
 static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *segs, *curr;
-	struct myri10ge_priv *mgp = dev->priv;
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	int status;
 
 	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
@@ -2514,14 +2548,13 @@
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
 {
+	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
-	struct myri10ge_priv *mgp;
 	struct dev_mc_list *mc_list;
 	__be32 data[2] = { 0, 0 };
 	int err;
 	DECLARE_MAC_BUF(mac);
 
-	mgp = netdev_priv(dev);
 	/* can be called from atomic contexts,
 	 * pass 1 to force atomicity in myri10ge_send_cmd() */
 	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
@@ -2723,9 +2756,9 @@
  * already been enabled, then it must use a firmware image which works
  * around unaligned completion packets (myri10ge_ethp_z8e.dat), and it
  * should also ensure that it never gives the device a Read-DMA which is
- * larger than 2KB by setting the tx.boundary to 2KB.  If ECRC is
+ * larger than 2KB by setting the tx_boundary to 2KB.  If ECRC is
  * enabled, then the driver should use the aligned (myri10ge_eth_z8e.dat)
- * firmware image, and set tx.boundary to 4KB.
+ * firmware image, and set tx_boundary to 4KB.
  */
 
 static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
@@ -2734,7 +2767,7 @@
 	struct device *dev = &pdev->dev;
 	int status;
 
-	mgp->tx.boundary = 4096;
+	mgp->tx_boundary = 4096;
 	/*
 	 * Verify the max read request size was set to 4KB
 	 * before trying the test with 4KB.
@@ -2746,7 +2779,7 @@
 	}
 	if (status != 4096) {
 		dev_warn(dev, "Max Read Request size != 4096 (%d)\n", status);
-		mgp->tx.boundary = 2048;
+		mgp->tx_boundary = 2048;
 	}
 	/*
 	 * load the optimized firmware (which assumes aligned PCIe
@@ -2779,7 +2812,7 @@
 			 "Please install up to date fw\n");
 abort:
 	/* fall back to using the unaligned firmware */
-	mgp->tx.boundary = 2048;
+	mgp->tx_boundary = 2048;
 	mgp->fw_name = myri10ge_fw_unaligned;
 
 }
@@ -2800,7 +2833,7 @@
 		if (link_width < 8) {
 			dev_info(&mgp->pdev->dev, "PCIE x%d Link\n",
 				 link_width);
-			mgp->tx.boundary = 4096;
+			mgp->tx_boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
 		} else {
 			myri10ge_firmware_probe(mgp);
@@ -2809,12 +2842,12 @@
 		if (myri10ge_force_firmware == 1) {
 			dev_info(&mgp->pdev->dev,
 				 "Assuming aligned completions (forced)\n");
-			mgp->tx.boundary = 4096;
+			mgp->tx_boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
 		} else {
 			dev_info(&mgp->pdev->dev,
 				 "Assuming unaligned completions (forced)\n");
-			mgp->tx.boundary = 2048;
+			mgp->tx_boundary = 2048;
 			mgp->fw_name = myri10ge_fw_unaligned;
 		}
 	}
@@ -2931,6 +2964,7 @@
 {
 	struct myri10ge_priv *mgp =
 	    container_of(work, struct myri10ge_priv, watchdog_work);
+	struct myri10ge_tx_buf *tx;
 	u32 reboot;
 	int status;
 	u16 cmd, vendor;
@@ -2980,15 +3014,16 @@
 
 		printk(KERN_ERR "myri10ge: %s: device timeout, resetting\n",
 		       mgp->dev->name);
+		tx = &mgp->ss.tx;
 		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, mgp->tx.req, mgp->tx.done,
-		       mgp->tx.pkt_start, mgp->tx.pkt_done,
-		       (int)ntohl(mgp->fw_stats->send_done_count));
+		       mgp->dev->name, tx->req, tx->done,
+		       tx->pkt_start, tx->pkt_done,
+		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
 		msleep(2000);
 		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, mgp->tx.req, mgp->tx.done,
-		       mgp->tx.pkt_start, mgp->tx.pkt_done,
-		       (int)ntohl(mgp->fw_stats->send_done_count));
+		       mgp->dev->name, tx->req, tx->done,
+		       tx->pkt_start, tx->pkt_done,
+		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
 	}
 	rtnl_lock();
 	myri10ge_close(mgp->dev);
@@ -3011,28 +3046,31 @@
 static void myri10ge_watchdog_timer(unsigned long arg)
 {
 	struct myri10ge_priv *mgp;
+	struct myri10ge_slice_state *ss;
 	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
-	if (mgp->rx_small.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+	rx_pause_cnt = ntohl(mgp->ss.fw_stats->dropped_pause);
+
+	ss = &mgp->ss;
+	if (ss->rx_small.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
 					mgp->small_bytes + MXGEFW_PAD, 1);
-		if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt >=
+		if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
 		    myri10ge_fill_thresh)
-			mgp->rx_small.watchdog_needed = 0;
+			ss->rx_small.watchdog_needed = 0;
 	}
-	if (mgp->rx_big.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 1);
-		if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt >=
+	if (ss->rx_big.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 1);
+		if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
 		    myri10ge_fill_thresh)
-			mgp->rx_big.watchdog_needed = 0;
+			ss->rx_big.watchdog_needed = 0;
 	}
-	rx_pause_cnt = ntohl(mgp->fw_stats->dropped_pause);
 
-	if (mgp->tx.req != mgp->tx.done &&
-	    mgp->tx.done == mgp->watchdog_tx_done &&
-	    mgp->watchdog_tx_req != mgp->watchdog_tx_done) {
+	if (ss->tx.req != ss->tx.done &&
+	    ss->tx.done == ss->watchdog_tx_done &&
+	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
 		/* nic seems like it might be stuck.. */
 		if (rx_pause_cnt != mgp->watchdog_pause) {
 			if (net_ratelimit())
@@ -3047,8 +3085,8 @@
 	/* rearm timer */
 	mod_timer(&mgp->watchdog_timer,
 		  jiffies + myri10ge_watchdog_timeout * HZ);
-	mgp->watchdog_tx_done = mgp->tx.done;
-	mgp->watchdog_tx_req = mgp->tx.req;
+	ss->watchdog_tx_done = ss->tx.done;
+	ss->watchdog_tx_req = ss->tx.req;
 	mgp->watchdog_pause = rx_pause_cnt;
 }
 
@@ -3072,7 +3110,7 @@
 
 	mgp = netdev_priv(netdev);
 	mgp->dev = netdev;
-	netif_napi_add(netdev, &mgp->napi, myri10ge_poll, myri10ge_napi_weight);
+	netif_napi_add(netdev, &mgp->ss.napi, myri10ge_poll, myri10ge_napi_weight);
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -3118,9 +3156,9 @@
 	if (mgp->cmd == NULL)
 		goto abort_with_netdev;
 
-	mgp->fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-					   &mgp->fw_stats_bus, GFP_KERNEL);
-	if (mgp->fw_stats == NULL)
+	mgp->ss.fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+					   &mgp->ss.fw_stats_bus, GFP_KERNEL);
+	if (mgp->ss.fw_stats == NULL)
 		goto abort_with_cmd;
 
 	mgp->board_span = pci_resource_len(pdev, 0);
@@ -3160,12 +3198,12 @@
 		netdev->dev_addr[i] = mgp->mac_addr[i];
 
 	/* allocate rx done ring */
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
-	mgp->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
-						&mgp->rx_done.bus, GFP_KERNEL);
-	if (mgp->rx_done.entry == NULL)
+	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	mgp->ss.rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
+						&mgp->ss.rx_done.bus, GFP_KERNEL);
+	if (mgp->ss.rx_done.entry == NULL)
 		goto abort_with_ioremap;
-	memset(mgp->rx_done.entry, 0, bytes);
+	memset(mgp->ss.rx_done.entry, 0, bytes);
 
 	myri10ge_select_firmware(mgp);
 
@@ -3225,7 +3263,7 @@
 	}
 	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 		 (mgp->msi_enabled ? "MSI" : "xPIC"),
-		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
+		 netdev->irq, mgp->tx_boundary, mgp->fw_name,
 		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
@@ -3237,9 +3275,9 @@
 	myri10ge_dummy_rdma(mgp, 0);
 
 abort_with_rx_done:
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
+	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->rx_done.entry, mgp->rx_done.bus);
+			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 
 abort_with_ioremap:
 	iounmap(mgp->sram);
@@ -3249,8 +3287,8 @@
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-			  mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
 
 abort_with_cmd:
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
@@ -3288,9 +3326,9 @@
 	/* avoid a memory leak */
 	pci_restore_state(pdev);
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
+	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->rx_done.entry, mgp->rx_done.bus);
+			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 
 	iounmap(mgp->sram);
 
@@ -3298,8 +3336,8 @@
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->fw_stats),
-			  mgp->fw_stats, mgp->fw_stats_bus);
+	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
+			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
 
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);


