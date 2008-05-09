From: Brice Goglin <brice@myri.com>
Subject: [PATCH 14/16] myri10ge: add multislices support
Date: Fri, 09 May 2008 02:21:49 +0200
Message-ID: <4823991D.2090906@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1886 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753971AbYEIAVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:21:33 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add multi-slice/MSI-X support. By default, a single slice
(and the normal firmware) are used.  To enable msi-x, multi-slice
mode, one must load the driver with myri10ge_max_slices set to
either -1, or something larger than 1.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  684 +++++++++++++++++++++++++---------------
 1 file changed, 442 insertions(+), 242 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:14:33.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:15:17.000000000 +0200
@@ -185,11 +185,13 @@
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+	char irq_desc[32];
 };
 
 struct myri10ge_priv {
-	struct myri10ge_slice_state ss;
+	struct myri10ge_slice_state *ss;
 	int tx_boundary;	/* boundary transmits cannot cross */
+	int num_slices;
 	int running;		/* running?             */
 	int csum_flag;		/* rx_csums?            */
 	int small_bytes;
@@ -208,6 +210,8 @@
 	dma_addr_t cmd_bus;
 	struct pci_dev *pdev;
 	int msi_enabled;
+	int msix_enabled;
+	struct msix_entry *msix_vectors;
 	u32 link_state;
 	unsigned int rdma_tags_available;
 	int intr_coal_delay;
@@ -244,6 +248,8 @@
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
 static char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
+static char *myri10ge_fw_rss_unaligned = "myri10ge_rss_ethp_z8e.dat";
+static char *myri10ge_fw_rss_aligned = "myri10ge_rss_eth_z8e.dat";
 
 static char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
@@ -321,6 +327,14 @@
 module_param(myri10ge_wcfifo, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled");
 
+static int myri10ge_max_slices = 1;
+module_param(myri10ge_max_slices, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_max_slices, "Max tx/rx queues");
+
+static int myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
+module_param(myri10ge_rss_hash, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_rss_hash, "Type of RSS hashing to do");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -657,7 +671,7 @@
 	return 0;
 }
 
-static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
+static int myri10ge_load_firmware(struct myri10ge_priv *mgp, int adopt)
 {
 	char __iomem *submit;
 	__be32 buf[16] __attribute__ ((__aligned__(8)));
@@ -667,6 +681,8 @@
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
 	if (status) {
+		if (!adopt)
+			return status;
 		dev_warn(&mgp->pdev->dev, "hotplug firmware loading failed\n");
 
 		/* Do not attempt to adopt firmware if there
@@ -859,7 +875,8 @@
 static int myri10ge_reset(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_cmd cmd;
-	int status;
+	struct myri10ge_slice_state *ss;
+	int i, status;
 	size_t bytes;
 
 	/* try to send a reset command to the card to see if it
@@ -872,20 +889,74 @@
 	}
 
 	(void)myri10ge_dma_test(mgp, MXGEFW_DMA_TEST);
+	/*
+	 * Use non-ndis mcp_slot (eg, 4 bytes total,
+	 * no toeplitz hash value returned.  Older firmware will
+	 * not understand this command, but will use the correct
+	 * sized mcp_slot, so we ignore error returns
+	 */
+	cmd.data0 = MXGEFW_RSS_MCP_SLOT_TYPE_MIN;
+	(void)myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE, &cmd, 0);
 
 	/* Now exchange information about interrupts  */
 
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	memset(mgp->ss.rx_done.entry, 0, bytes);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss[0].rx_done.entry);
 	cmd.data0 = (u32) bytes;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.rx_done.bus);
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA, &cmd, 0);
+
+	/*
+	 * Even though we already know how many slices are supported
+	 * via myri10ge_probe_slices() MXGEFW_CMD_GET_MAX_RSS_QUEUES
+	 * has magic side effects, and must be called after a reset.
+	 * It must be called prior to calling any RSS related cmds,
+	 * including assigning an interrupt queue for anything but
+	 * slice 0.  It must also be called *after*
+	 * MXGEFW_CMD_SET_INTRQ_SIZE, since the intrq size is used by
+	 * the firmware to compute offsets.
+	 */
+
+	if (mgp->num_slices > 1) {
+
+		/* ask the maximum number of slices it supports */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			dev_err(&mgp->pdev->dev,
+				"failed to get number of slices\n");
+		}
+
+		/*
+		 * MXGEFW_CMD_ENABLE_RSS_QUEUES must be called prior
+		 * to setting up the interrupt queue DMA
+		 */
+
+		cmd.data0 = mgp->num_slices;
+		cmd.data1 = 1;	/* use MSI-X */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			dev_err(&mgp->pdev->dev,
+				"failed to set number of slices\n");
+
+			return status;
+		}
+	}
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->rx_done.bus);
+		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->rx_done.bus);
+		cmd.data2 = i;
+		status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_DMA,
+					    &cmd, 0);
+	};
 
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
-	mgp->ss.irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		ss->irq_claim =
+		    (__iomem __be32 *) (mgp->sram + cmd.data0 + 8 * i);
+	}
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
 				    &cmd, 0);
 	mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
@@ -899,18 +970,25 @@
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	memset(mgp->ss.rx_done.entry, 0, bytes);
-
 	/* reset mcp/driver shared state back to 0 */
-	mgp->ss.tx.req = 0;
-	mgp->ss.tx.done = 0;
-	mgp->ss.tx.pkt_start = 0;
-	mgp->ss.tx.pkt_done = 0;
-	mgp->ss.rx_big.cnt = 0;
-	mgp->ss.rx_small.cnt = 0;
-	mgp->ss.rx_done.idx = 0;
-	mgp->ss.rx_done.cnt = 0;
+
 	mgp->link_changes = 0;
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+
+		memset(ss->rx_done.entry, 0, bytes);
+		ss->tx.req = 0;
+		ss->tx.done = 0;
+		ss->tx.pkt_start = 0;
+		ss->tx.pkt_done = 0;
+		ss->rx_big.cnt = 0;
+		ss->rx_small.cnt = 0;
+		ss->rx_done.idx = 0;
+		ss->rx_done.cnt = 0;
+		ss->tx.wake_queue = 0;
+		ss->tx.stop_queue = 0;
+	}
+
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_pause(mgp, mgp->pause);
 	myri10ge_set_multicast_list(mgp->dev);
@@ -1095,9 +1173,10 @@
 		rx_frags[0].size -= MXGEFW_PAD;
 		len -= MXGEFW_PAD;
 		lro_receive_frags(&ss->rx_done.lro_mgr, rx_frags,
-				  len, len,
 				  /* opaque, will come back in get_frag_header */
+				  len, len,
 				  (void *)(__force unsigned long)csum, csum);
+
 		return 1;
 	}
 
@@ -1236,7 +1315,7 @@
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 {
-	struct mcp_irq_data *stats = mgp->ss.fw_stats;
+	struct mcp_irq_data *stats = mgp->ss[0].fw_stats;
 
 	if (unlikely(stats->stats_updated)) {
 		unsigned link_up = ntohl(stats->link_up);
@@ -1302,6 +1381,13 @@
 	u32 send_done_count;
 	int i;
 
+	/* an interrupt on a non-zero slice is implicitly valid
+	 * since MSI-X irqs are not shared */
+	if (ss != mgp->ss) {
+		netif_rx_schedule(ss->dev, &ss->napi);
+		return (IRQ_HANDLED);
+	}
+
 	/* make sure it is our IRQ, and that the DMA has finished */
 	if (unlikely(!stats->valid))
 		return (IRQ_NONE);
@@ -1311,7 +1397,7 @@
 	if (stats->valid & 1)
 		netif_rx_schedule(ss->dev, &ss->napi);
 
-	if (!mgp->msi_enabled) {
+	if (!mgp->msi_enabled && !mgp->msix_enabled) {
 		put_be32(0, mgp->irq_deassert);
 		if (!myri10ge_deassert_wait)
 			stats->valid = 0;
@@ -1446,10 +1532,10 @@
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 
-	ring->rx_mini_max_pending = mgp->ss.rx_small.mask + 1;
-	ring->rx_max_pending = mgp->ss.rx_big.mask + 1;
+	ring->rx_mini_max_pending = mgp->ss[0].rx_small.mask + 1;
+	ring->rx_max_pending = mgp->ss[0].rx_big.mask + 1;
 	ring->rx_jumbo_max_pending = 0;
-	ring->tx_max_pending = mgp->ss.rx_small.mask + 1;
+	ring->tx_max_pending = mgp->ss[0].rx_small.mask + 1;
 	ring->rx_mini_pending = ring->rx_mini_max_pending;
 	ring->rx_pending = ring->rx_max_pending;
 	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
@@ -1497,7 +1583,7 @@
 	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
 	"tx_heartbeat_errors", "tx_window_errors",
 	/* device-specific stats */
-	"tx_boundary", "WC", "irq", "MSI",
+	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
 	"link_changes", "link_up", "dropped_link_overflow",
@@ -1524,23 +1610,31 @@
 static void
 myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	int i;
+
 	switch (stringset) {
 	case ETH_SS_STATS:
 		memcpy(data, *myri10ge_gstrings_main_stats,
 		       sizeof(myri10ge_gstrings_main_stats));
 		data += sizeof(myri10ge_gstrings_main_stats);
-		memcpy(data, *myri10ge_gstrings_slice_stats,
-		       sizeof(myri10ge_gstrings_slice_stats));
-		data += sizeof(myri10ge_gstrings_slice_stats);
+		for (i = 0; i < mgp->num_slices; i++) {
+			memcpy(data, *myri10ge_gstrings_slice_stats,
+			       sizeof(myri10ge_gstrings_slice_stats));
+			data += sizeof(myri10ge_gstrings_slice_stats);
+		}
 		break;
 	}
 }
 
 static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
 {
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MYRI10GE_MAIN_STATS_LEN + MYRI10GE_SLICE_STATS_LEN;
+		return MYRI10GE_MAIN_STATS_LEN +
+		    mgp->num_slices * MYRI10GE_SLICE_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1552,6 +1646,7 @@
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 	struct myri10ge_slice_state *ss;
+	int slice;
 	int i;
 
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
@@ -1561,6 +1656,7 @@
 	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
+	data[i++] = (unsigned int)mgp->msix_enabled;
 	data[i++] = (unsigned int)mgp->read_dma;
 	data[i++] = (unsigned int)mgp->write_dma;
 	data[i++] = (unsigned int)mgp->read_write_dma;
@@ -1569,7 +1665,7 @@
 	data[i++] = (unsigned int)mgp->link_changes;
 
 	/* firmware stats are useful only in the first slice */
-	ss = &mgp->ss;
+	ss = &mgp->ss[0];
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
 	data[i++] =
@@ -1585,24 +1681,27 @@
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
 	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
 
-	data[i++] = 0;
-	data[i++] = (unsigned int)ss->tx.pkt_start;
-	data[i++] = (unsigned int)ss->tx.pkt_done;
-	data[i++] = (unsigned int)ss->tx.req;
-	data[i++] = (unsigned int)ss->tx.done;
-	data[i++] = (unsigned int)ss->rx_small.cnt;
-	data[i++] = (unsigned int)ss->rx_big.cnt;
-	data[i++] = (unsigned int)ss->tx.wake_queue;
-	data[i++] = (unsigned int)ss->tx.stop_queue;
-	data[i++] = (unsigned int)ss->tx.linearized;
-	data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
-	data[i++] = ss->rx_done.lro_mgr.stats.flushed;
-	if (ss->rx_done.lro_mgr.stats.flushed)
-		data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
-		    ss->rx_done.lro_mgr.stats.flushed;
-	else
-		data[i++] = 0;
-	data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
+	for (slice = 0; slice < mgp->num_slices; slice++) {
+		ss = &mgp->ss[slice];
+		data[i++] = slice;
+		data[i++] = (unsigned int)ss->tx.pkt_start;
+		data[i++] = (unsigned int)ss->tx.pkt_done;
+		data[i++] = (unsigned int)ss->tx.req;
+		data[i++] = (unsigned int)ss->tx.done;
+		data[i++] = (unsigned int)ss->rx_small.cnt;
+		data[i++] = (unsigned int)ss->rx_big.cnt;
+		data[i++] = (unsigned int)ss->tx.wake_queue;
+		data[i++] = (unsigned int)ss->tx.stop_queue;
+		data[i++] = (unsigned int)ss->tx.linearized;
+		data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
+		data[i++] = ss->rx_done.lro_mgr.stats.flushed;
+		if (ss->rx_done.lro_mgr.stats.flushed)
+			data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
+			    ss->rx_done.lro_mgr.stats.flushed;
+		else
+			data[i++] = 0;
+		data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
+	}
 }
 
 static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
@@ -1645,12 +1744,15 @@
 	struct net_device *dev = mgp->dev;
 	int tx_ring_size, rx_ring_size;
 	int tx_ring_entries, rx_ring_entries;
-	int i, status;
+	int i, slice, status;
 	size_t bytes;
 
 	/* get ring sizes */
+	slice = ss - mgp->ss;
+	cmd.data0 = slice;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_RING_SIZE, &cmd, 0);
 	tx_ring_size = cmd.data0;
+	cmd.data0 = slice;
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
 	if (status != 0)
 		return status;
@@ -1715,15 +1817,17 @@
 				mgp->small_bytes + MXGEFW_PAD, 0);
 
 	if (ss->rx_small.fill_cnt < ss->rx_small.mask + 1) {
-		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
-		       dev->name, ss->rx_small.fill_cnt);
+		printk(KERN_ERR
+		       "myri10ge: %s:slice-%d: alloced only %d small bufs\n",
+		       dev->name, slice, ss->rx_small.fill_cnt);
 		goto abort_with_rx_small_ring;
 	}
 
 	myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 0);
 	if (ss->rx_big.fill_cnt < ss->rx_big.mask + 1) {
-		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
-		       dev->name, ss->rx_big.fill_cnt);
+		printk(KERN_ERR
+		       "myri10ge: %s:slice-%d: alloced only %d big bufs\n",
+		       dev->name, slice, ss->rx_big.fill_cnt);
 		goto abort_with_rx_big_ring;
 	}
 
@@ -1775,6 +1879,10 @@
 	struct myri10ge_tx_buf *tx;
 	int i, len, idx;
 
+	/* If not allocated, skip it */
+	if (ss->tx.req_list == NULL)
+		return;
+
 	for (i = ss->rx_big.cnt; i < ss->rx_big.fill_cnt; i++) {
 		idx = i & ss->rx_big.mask;
 		if (i == ss->rx_big.fill_cnt - 1)
@@ -1837,25 +1945,67 @@
 static int myri10ge_request_irq(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
+	struct myri10ge_slice_state *ss;
+	struct net_device *netdev = mgp->dev;
+	int i;
 	int status;
 
+	mgp->msi_enabled = 0;
+	mgp->msix_enabled = 0;
+	status = 0;
 	if (myri10ge_msi) {
-		status = pci_enable_msi(pdev);
-		if (status != 0)
-			dev_err(&pdev->dev,
-				"Error %d setting up MSI; falling back to xPIC\n",
-				status);
-		else
-			mgp->msi_enabled = 1;
-	} else {
-		mgp->msi_enabled = 0;
+		if (mgp->num_slices > 1) {
+			status =
+			    pci_enable_msix(pdev, mgp->msix_vectors,
+					    mgp->num_slices);
+			if (status == 0) {
+				mgp->msix_enabled = 1;
+			} else {
+				dev_err(&pdev->dev,
+					"Error %d setting up MSI-X\n", status);
+				return status;
+			}
+		}
+		if (mgp->msix_enabled == 0) {
+			status = pci_enable_msi(pdev);
+			if (status != 0) {
+				dev_err(&pdev->dev,
+					"Error %d setting up MSI; falling back to xPIC\n",
+					status);
+			} else {
+				mgp->msi_enabled = 1;
+			}
+		}
 	}
-	status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
-			     mgp->dev->name, mgp);
-	if (status != 0) {
-		dev_err(&pdev->dev, "failed to allocate IRQ\n");
-		if (mgp->msi_enabled)
-			pci_disable_msi(pdev);
+	if (mgp->msix_enabled) {
+		for (i = 0; i < mgp->num_slices; i++) {
+			ss = &mgp->ss[i];
+			snprintf(ss->irq_desc, sizeof(ss->irq_desc),
+				 "%s:slice-%d", netdev->name, i);
+			status = request_irq(mgp->msix_vectors[i].vector,
+					     myri10ge_intr, 0, ss->irq_desc,
+					     ss);
+			if (status != 0) {
+				dev_err(&pdev->dev,
+					"slice %d failed to allocate IRQ\n", i);
+				i--;
+				while (i >= 0) {
+					free_irq(mgp->msix_vectors[i].vector,
+						 &mgp->ss[i]);
+					i--;
+				}
+				pci_disable_msix(pdev);
+				return status;
+			}
+		}
+	} else {
+		status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
+				     mgp->dev->name, &mgp->ss[0]);
+		if (status != 0) {
+			dev_err(&pdev->dev, "failed to allocate IRQ\n");
+			if (mgp->msi_enabled)
+				pci_disable_msi(pdev);
+		}
 	}
 	return status;
 }
@@ -1863,10 +2013,18 @@
 static void myri10ge_free_irq(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
+	int i;
 
-	free_irq(pdev->irq, mgp);
+	if (mgp->msix_enabled) {
+		for (i = 0; i < mgp->num_slices; i++)
+			free_irq(mgp->msix_vectors[i].vector, &mgp->ss[i]);
+	} else {
+		free_irq(pdev->irq, &mgp->ss[0]);
+	}
 	if (mgp->msi_enabled)
 		pci_disable_msi(pdev);
+	if (mgp->msix_enabled)
+		pci_disable_msix(pdev);
 }
 
 static int
@@ -1928,7 +2086,6 @@
 	return 0;
 }
 
-#if 0
 static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
 {
 	struct myri10ge_cmd cmd;
@@ -1996,14 +2153,15 @@
 	}
 	return 0;
 }
-#endif
 
 static int myri10ge_open(struct net_device *dev)
 {
+	struct myri10ge_slice_state *ss;
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
+	int i, status, big_pow2, slice;
+	u8 *itable;
 	struct net_lro_mgr *lro_mgr;
-	int status, big_pow2;
 
 	if (mgp->running != MYRI10GE_ETH_STOPPED)
 		return -EBUSY;
@@ -2015,6 +2173,48 @@
 		goto abort_with_nothing;
 	}
 
+	if (mgp->num_slices > 1) {
+		cmd.data0 = mgp->num_slices;
+		cmd.data1 = 1;	/* use MSI-X */
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
+					   &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to set number of slices\n",
+			       dev->name);
+			goto abort_with_nothing;
+		}
+		/* setup the indirection table */
+		cmd.data0 = mgp->num_slices;
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_TABLE_SIZE,
+					   &cmd, 0);
+
+		status |= myri10ge_send_cmd(mgp,
+					    MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
+					    &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to setup rss tables\n",
+			       dev->name);
+		}
+
+		/* just enable an identity mapping */
+		itable = mgp->sram + cmd.data0;
+		for (i = 0; i < mgp->num_slices; i++)
+			__raw_writeb(i, &itable[i]);
+
+		cmd.data0 = 1;
+		cmd.data1 = myri10ge_rss_hash;
+		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_RSS_ENABLE,
+					   &cmd, 0);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to enable slices\n",
+			       dev->name);
+			goto abort_with_nothing;
+		}
+	}
+
 	status = myri10ge_request_irq(mgp);
 	if (status != 0)
 		goto abort_with_nothing;
@@ -2038,41 +2238,6 @@
 	if (myri10ge_small_bytes > 0)
 		mgp->small_bytes = myri10ge_small_bytes;
 
-	/* get the lanai pointers to the send and receive rings */
-
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
-	mgp->ss.tx.lanai =
-	    (struct mcp_kreq_ether_send __iomem *)(mgp->sram + cmd.data0);
-
-	status |=
-	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET, &cmd, 0);
-	mgp->ss.rx_small.lanai =
-	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
-
-	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
-	mgp->ss.rx_big.lanai =
-	    (struct mcp_kreq_ether_recv __iomem *)(mgp->sram + cmd.data0);
-
-	if (status != 0) {
-		printk(KERN_ERR
-		       "myri10ge: %s: failed to get ring sizes or locations\n",
-		       dev->name);
-		mgp->running = MYRI10GE_ETH_STOPPED;
-		goto abort_with_irq;
-	}
-
-	if (myri10ge_wcfifo && mgp->wc_enabled) {
-		mgp->ss.tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
-		mgp->ss.rx_small.wc_fifo =
-		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
-		mgp->ss.rx_big.wc_fifo =
-		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_BIG;
-	} else {
-		mgp->ss.tx.wc_fifo = NULL;
-		mgp->ss.rx_small.wc_fifo = NULL;
-		mgp->ss.rx_big.wc_fifo = NULL;
-	}
-
 	/* Firmware needs the big buff size as a power of 2.  Lie and
 	 * tell him the buffer is larger, because we only use 1
 	 * buffer/pkt, and the mtu will prevent overruns.
@@ -2087,9 +2252,44 @@
 		mgp->big_bytes = big_pow2;
 	}
 
-	status = myri10ge_allocate_rings(&mgp->ss);
-	if (status != 0)
-		goto abort_with_irq;
+	/* setup the per-slice data structures */
+	for (slice = 0; slice < mgp->num_slices; slice++) {
+		ss = &mgp->ss[slice];
+
+		status = myri10ge_get_txrx(mgp, slice);
+		if (status != 0) {
+			printk(KERN_ERR
+			       "myri10ge: %s: failed to get ring sizes or locations\n",
+			       dev->name);
+			goto abort_with_rings;
+		}
+		status = myri10ge_allocate_rings(ss);
+		if (status != 0)
+			goto abort_with_rings;
+		if (slice == 0)
+			status = myri10ge_set_stats(mgp, slice);
+		if (status) {
+			printk(KERN_ERR
+			       "myri10ge: %s: Couldn't set stats DMA\n",
+			       dev->name);
+			goto abort_with_rings;
+		}
+
+		lro_mgr = &ss->rx_done.lro_mgr;
+		lro_mgr->dev = dev;
+		lro_mgr->features = LRO_F_NAPI;
+		lro_mgr->ip_summed = CHECKSUM_COMPLETE;
+		lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+		lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
+		lro_mgr->lro_arr = ss->rx_done.lro_desc;
+		lro_mgr->get_frag_header = myri10ge_get_frag_header;
+		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
+		if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+			lro_mgr->max_aggr = MAX_SKB_FRAGS;
+
+		/* must happen prior to any irq */
+		napi_enable(&(ss)->napi);
+	}
 
 	/* now give firmware buffers sizes, and MTU */
 	cmd.data0 = dev->mtu + ETH_HLEN + VLAN_HLEN;
@@ -2106,25 +2306,15 @@
 		goto abort_with_rings;
 	}
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->ss.fw_stats_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->ss.fw_stats_bus);
-	cmd.data2 = sizeof(struct mcp_irq_data);
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
-	if (status == -ENOSYS) {
-		dma_addr_t bus = mgp->ss.fw_stats_bus;
-		bus += offsetof(struct mcp_irq_data, send_done_count);
-		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
-		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
-		status = myri10ge_send_cmd(mgp,
-					   MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,
-					   &cmd, 0);
-		/* Firmware cannot support multicast without STATS_DMA_V2 */
-		mgp->fw_multicast_support = 0;
-	} else {
-		mgp->fw_multicast_support = 1;
-	}
-	if (status) {
-		printk(KERN_ERR "myri10ge: %s: Couldn't set stats DMA\n",
+	/*
+	 * Set Linux style TSO mode; this is needed only on newer
+	 *  firmware versions.  Older versions default to Linux
+	 *  style TSO
+	 */
+	cmd.data0 = 0;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_TSO_MODE, &cmd, 0);
+	if (status && status != -ENOSYS) {
+		printk(KERN_ERR "myri10ge: %s: Couldn't set TSO mode\n",
 		       dev->name);
 		goto abort_with_rings;
 	}
@@ -2132,21 +2322,6 @@
 	mgp->link_state = ~0U;
 	mgp->rdma_tags_available = 15;
 
-	lro_mgr = &mgp->ss.rx_done.lro_mgr;
-	lro_mgr->dev = dev;
-	lro_mgr->features = LRO_F_NAPI;
-	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
-	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
-	lro_mgr->lro_arr = mgp->ss.rx_done.lro_desc;
-	lro_mgr->get_frag_header = myri10ge_get_frag_header;
-	lro_mgr->max_aggr = myri10ge_lro_max_pkts;
-	lro_mgr->frag_align_pad = 2;
-	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
-		lro_mgr->max_aggr = MAX_SKB_FRAGS;
-
-	napi_enable(&mgp->ss.napi);	/* must happen prior to any irq */
-
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
 		printk(KERN_ERR "myri10ge: %s: Couldn't bring up link\n",
@@ -2154,8 +2329,6 @@
 		goto abort_with_rings;
 	}
 
-	mgp->ss.tx.wake_queue = 0;
-	mgp->ss.tx.stop_queue = 0;
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
@@ -2163,9 +2336,9 @@
 	return 0;
 
 abort_with_rings:
-	myri10ge_free_rings(&mgp->ss);
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_free_rings(&mgp->ss[i]);
 
-abort_with_irq:
 	myri10ge_free_irq(mgp);
 
 abort_with_nothing:
@@ -2178,16 +2351,19 @@
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
 	int status, old_down_cnt;
+	int i;
 
 	if (mgp->running != MYRI10GE_ETH_RUNNING)
 		return 0;
 
-	if (mgp->ss.tx.req_bytes == NULL)
+	if (mgp->ss[0].tx.req_bytes == NULL)
 		return 0;
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	napi_disable(&mgp->ss.napi);
+	for (i = 0; i < mgp->num_slices; i++) {
+		napi_disable(&mgp->ss[i].napi);
+	}
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 	old_down_cnt = mgp->down_cnt;
@@ -2203,7 +2379,8 @@
 
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
-	myri10ge_free_rings(&mgp->ss);
+	for (i = 0; i < mgp->num_slices; i++)
+		myri10ge_free_rings(&mgp->ss[i]);
 
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return 0;
@@ -2324,7 +2501,7 @@
 	u8 flags, odd_flag;
 
 	/* always transmit through slot 0 */
-	ss = &mgp->ss;
+	ss = mgp->ss;
 	tx = &ss->tx;
 again:
 	req = tx->req_list;
@@ -2629,7 +2806,21 @@
 static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
-	return &mgp->stats;
+	struct myri10ge_slice_netstats *slice_stats;
+	struct net_device_stats *stats = &mgp->stats;
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+	for (i = 0; i < mgp->num_slices; i++) {
+		slice_stats = &mgp->ss[i].stats;
+		stats->rx_packets += slice_stats->rx_packets;
+		stats->tx_packets += slice_stats->tx_packets;
+		stats->rx_bytes += slice_stats->rx_bytes;
+		stats->tx_bytes += slice_stats->tx_bytes;
+		stats->rx_dropped += slice_stats->rx_dropped;
+		stats->tx_dropped += slice_stats->tx_dropped;
+	}
+	return stats;
 }
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
@@ -2840,10 +3031,10 @@
  *
  * If the driver can neither enable ECRC nor verify that it has
  * already been enabled, then it must use a firmware image which works
- * around unaligned completion packets (myri10ge_ethp_z8e.dat), and it
+ * around unaligned completion packets (myri10ge_rss_ethp_z8e.dat), and it
  * should also ensure that it never gives the device a Read-DMA which is
  * larger than 2KB by setting the tx_boundary to 2KB.  If ECRC is
- * enabled, then the driver should use the aligned (myri10ge_eth_z8e.dat)
+ * enabled, then the driver should use the aligned (myri10ge_rss_eth_z8e.dat)
  * firmware image, and set tx_boundary to 4KB.
  */
 
@@ -2872,7 +3063,7 @@
 	 * completions) in order to see if it works on this host.
 	 */
 	mgp->fw_name = myri10ge_fw_aligned;
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0) {
 		goto abort;
 	}
@@ -3053,6 +3244,7 @@
 	struct myri10ge_tx_buf *tx;
 	u32 reboot;
 	int status;
+	int i;
 	u16 cmd, vendor;
 
 	mgp->watchdog_resets++;
@@ -3100,20 +3292,26 @@
 
 		printk(KERN_ERR "myri10ge: %s: device timeout, resetting\n",
 		       mgp->dev->name);
-		tx = &mgp->ss.tx;
-		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, tx->req, tx->done,
-		       tx->pkt_start, tx->pkt_done,
-		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
-		msleep(2000);
-		printk(KERN_INFO "myri10ge: %s: %d %d %d %d %d\n",
-		       mgp->dev->name, tx->req, tx->done,
-		       tx->pkt_start, tx->pkt_done,
-		       (int)ntohl(mgp->ss.fw_stats->send_done_count));
+		for (i = 0; i < mgp->num_slices; i++) {
+			tx = &mgp->ss[i].tx;
+			printk(KERN_INFO
+			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->req, tx->done,
+			       tx->pkt_start, tx->pkt_done,
+			       (int)ntohl(mgp->ss[i].fw_stats->
+					  send_done_count));
+			msleep(2000);
+			printk(KERN_INFO
+			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
+			       mgp->dev->name, i, tx->req, tx->done,
+			       tx->pkt_start, tx->pkt_done,
+			       (int)ntohl(mgp->ss[i].fw_stats->
+					  send_done_count));
+		}
 	}
 	rtnl_lock();
 	myri10ge_close(mgp->dev);
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0)
 		printk(KERN_ERR "myri10ge: %s: failed to load firmware\n",
 		       mgp->dev->name);
@@ -3133,50 +3331,59 @@
 {
 	struct myri10ge_priv *mgp;
 	struct myri10ge_slice_state *ss;
+	int i, reset_needed;
 	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
-	rx_pause_cnt = ntohl(mgp->ss.fw_stats->dropped_pause);
+	rx_pause_cnt = ntohl(mgp->ss[0].fw_stats->dropped_pause);
+	for (i = 0, reset_needed = 0;
+	     i < mgp->num_slices && reset_needed == 0; ++i) {
 
-	ss = &mgp->ss;
-	if (ss->rx_small.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
-					mgp->small_bytes + MXGEFW_PAD, 1);
-		if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
-		    myri10ge_fill_thresh)
-			ss->rx_small.watchdog_needed = 0;
-	}
-	if (ss->rx_big.watchdog_needed) {
-		myri10ge_alloc_rx_pages(mgp, &ss->rx_big, mgp->big_bytes, 1);
-		if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
-		    myri10ge_fill_thresh)
-			ss->rx_big.watchdog_needed = 0;
-	}
-
-	if (ss->tx.req != ss->tx.done &&
-	    ss->tx.done == ss->watchdog_tx_done &&
-	    ss->watchdog_tx_req != ss->watchdog_tx_done) {
-		/* nic seems like it might be stuck.. */
-		if (rx_pause_cnt != mgp->watchdog_pause) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "myri10ge %s:"
-				       "TX paused, check link partner\n",
-				       mgp->dev->name);
-		} else {
-			schedule_work(&mgp->watchdog_work);
-			return;
+		ss = &mgp->ss[i];
+		if (ss->rx_small.watchdog_needed) {
+			myri10ge_alloc_rx_pages(mgp, &ss->rx_small,
+						mgp->small_bytes + MXGEFW_PAD,
+						1);
+			if (ss->rx_small.fill_cnt - ss->rx_small.cnt >=
+			    myri10ge_fill_thresh)
+				ss->rx_small.watchdog_needed = 0;
+		}
+		if (ss->rx_big.watchdog_needed) {
+			myri10ge_alloc_rx_pages(mgp, &ss->rx_big,
+						mgp->big_bytes, 1);
+			if (ss->rx_big.fill_cnt - ss->rx_big.cnt >=
+			    myri10ge_fill_thresh)
+				ss->rx_big.watchdog_needed = 0;
+		}
+
+		if (ss->tx.req != ss->tx.done &&
+		    ss->tx.done == ss->watchdog_tx_done &&
+		    ss->watchdog_tx_req != ss->watchdog_tx_done) {
+			/* nic seems like it might be stuck.. */
+			if (rx_pause_cnt != mgp->watchdog_pause) {
+				if (net_ratelimit())
+					printk(KERN_WARNING "myri10ge %s:"
+					       "TX paused, check link partner\n",
+					       mgp->dev->name);
+			} else {
+				reset_needed = 1;
+			}
 		}
+		ss->watchdog_tx_done = ss->tx.done;
+		ss->watchdog_tx_req = ss->tx.req;
 	}
-	/* rearm timer */
-	mod_timer(&mgp->watchdog_timer,
-		  jiffies + myri10ge_watchdog_timeout * HZ);
-	ss->watchdog_tx_done = ss->tx.done;
-	ss->watchdog_tx_req = ss->tx.req;
 	mgp->watchdog_pause = rx_pause_cnt;
+
+	if (reset_needed) {
+		schedule_work(&mgp->watchdog_work);
+	} else {
+		/* rearm timer */
+		mod_timer(&mgp->watchdog_timer,
+			  jiffies + myri10ge_watchdog_timeout * HZ);
+	}
 }
 
-#if 0
 static void myri10ge_free_slices(struct myri10ge_priv *mgp)
 {
 	struct myri10ge_slice_state *ss;
@@ -3360,14 +3567,12 @@
 	mgp->fw_name = old_fw;
 	myri10ge_load_firmware(mgp, 0);
 }
-#endif
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct myri10ge_priv *mgp;
 	struct device *dev = &pdev->dev;
-	size_t bytes;
 	int i;
 	int status = -ENXIO;
 	int dac_enabled;
@@ -3382,7 +3587,6 @@
 
 	mgp = netdev_priv(netdev);
 	mgp->dev = netdev;
-	netif_napi_add(netdev, &mgp->ss.napi, myri10ge_poll, myri10ge_napi_weight);
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -3428,11 +3632,6 @@
 	if (mgp->cmd == NULL)
 		goto abort_with_netdev;
 
-	mgp->ss.fw_stats = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-					   &mgp->ss.fw_stats_bus, GFP_KERNEL);
-	if (mgp->ss.fw_stats == NULL)
-		goto abort_with_cmd;
-
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
 	mgp->mtrr = -1;
@@ -3469,26 +3668,24 @@
 	for (i = 0; i < ETH_ALEN; i++)
 		netdev->dev_addr[i] = mgp->mac_addr[i];
 
-	/* allocate rx done ring */
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	mgp->ss.rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
-						&mgp->ss.rx_done.bus, GFP_KERNEL);
-	if (mgp->ss.rx_done.entry == NULL)
-		goto abort_with_ioremap;
-	memset(mgp->ss.rx_done.entry, 0, bytes);
-
 	myri10ge_select_firmware(mgp);
 
-	status = myri10ge_load_firmware(mgp);
+	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed to load firmware\n");
-		goto abort_with_rx_done;
+		goto abort_with_ioremap;
+	}
+	myri10ge_probe_slices(mgp);
+	status = myri10ge_alloc_slices(mgp);
+	if (status != 0) {
+		dev_err(&pdev->dev, "failed to alloc slice state\n");
+		goto abort_with_firmware;
 	}
 
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed reset\n");
-		goto abort_with_firmware;
+		goto abort_with_slices;
 	}
 
 	pci_set_drvdata(pdev, mgp);
@@ -3533,24 +3730,27 @@
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_state;
 	}
-	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
-		 (mgp->msi_enabled ? "MSI" : "xPIC"),
-		 netdev->irq, mgp->tx_boundary, mgp->fw_name,
-		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+	if (mgp->msix_enabled)
+		dev_info(dev, "%d MSI-X IRQs, tx bndry %d, fw %s, WC %s\n",
+			 mgp->num_slices, mgp->tx_boundary, mgp->fw_name,
+			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+	else
+		dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+			 mgp->msi_enabled ? "MSI" : "xPIC",
+			 netdev->irq, mgp->tx_boundary, mgp->fw_name,
+			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
 
 abort_with_state:
 	pci_restore_state(pdev);
 
+abort_with_slices:
+	myri10ge_free_slices(mgp);
+
 abort_with_firmware:
 	myri10ge_dummy_rdma(mgp, 0);
 
-abort_with_rx_done:
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
-
 abort_with_ioremap:
 	iounmap(mgp->sram);
 
@@ -3559,10 +3759,6 @@
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
-
-abort_with_cmd:
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
@@ -3583,7 +3779,6 @@
 {
 	struct myri10ge_priv *mgp;
 	struct net_device *netdev;
-	size_t bytes;
 
 	mgp = pci_get_drvdata(pdev);
 	if (mgp == NULL)
@@ -3598,19 +3793,15 @@
 	/* avoid a memory leak */
 	pci_restore_state(pdev);
 
-	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
-	dma_free_coherent(&pdev->dev, bytes,
-			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
-
 	iounmap(mgp->sram);
 
 #ifdef CONFIG_MTRR
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
 #endif
-	dma_free_coherent(&pdev->dev, sizeof(*mgp->ss.fw_stats),
-			  mgp->ss.fw_stats, mgp->ss.fw_stats_bus);
-
+	myri10ge_free_slices(mgp);
+	if (mgp->msix_vectors != NULL)
+		kfree(mgp->msix_vectors);
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
@@ -3643,6 +3834,15 @@
 {
 	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
 	       MYRI10GE_VERSION_STR);
+
+	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_SRC_PORT ||
+	    myri10ge_rss_hash < MXGEFW_RSS_HASH_TYPE_IPV4) {
+		printk(KERN_ERR
+		       "%s: Illegal rssh hash type %d, defaulting to source port\n",
+		       myri10ge_driver.name, myri10ge_rss_hash);
+		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
+	}
+
 	return pci_register_driver(&myri10ge_driver);
 }
 


