From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 3/3] e1000: bundle xdp xmit routines
Date: Mon, 12 Sep 2016 15:14:17 -0700
Message-ID: <20160912221417.5610.37355.stgit@john-Precision-Tower-5810>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, intel-wired-lan@lists.osuosl.org,
        u9012063@gmail.com, netdev@vger.kernel.org
To: bblanco@plumgrid.com, john.fastabend@gmail.com,
        alexei.starovoitov@gmail.com, jeffrey.t.kirsher@intel.com,
        brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34376 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbcILWOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:14:38 -0400
Received: by mail-oi0-f67.google.com with SMTP id c129so5480766oih.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:14:38 -0700 (PDT)
In-Reply-To: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000 supports a single TX queue so it is being shared with the stack
when XDP runs XDP_TX action. This requires taking the xmit lock to
ensure we don't corrupt the tx ring. To avoid taking and dropping the
lock per packet this patch adds a bundling implementation to submit
a bundle of packets to the xmit routine.

I tested this patch running e1000 in a VM using KVM over a tap
device using pktgen to generate traffic along with 'ping -f -l 100'.

Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |   10 +++
 drivers/net/ethernet/intel/e1000/e1000_main.c |   80 +++++++++++++++++++------
 2 files changed, 70 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 5cf8a0a..877b377 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -133,6 +133,8 @@ struct e1000_adapter;
 #define E1000_TX_QUEUE_WAKE	16
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define E1000_RX_BUFFER_WRITE	16 /* Must be power of 2 */
+/* How many XDP XMIT buffers to bundle into one xmit transaction */
+#define E1000_XDP_XMIT_BUNDLE_MAX E1000_RX_BUFFER_WRITE
 
 #define AUTO_ALL_MODES		0
 #define E1000_EEPROM_82544_APM	0x0004
@@ -168,6 +170,11 @@ struct e1000_rx_buffer {
 	dma_addr_t dma;
 };
 
+struct e1000_rx_buffer_bundle {
+	struct e1000_rx_buffer *buffer;
+	u32 length;
+};
+
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
 	void *desc;
@@ -206,6 +213,9 @@ struct e1000_rx_ring {
 	struct e1000_rx_buffer *buffer_info;
 	struct sk_buff *rx_skb_top;
 
+	/* array of XDP buffer information structs */
+	struct e1000_rx_buffer_bundle *xdp_buffer;
+
 	/* cpu for rx queue */
 	int cpu;
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 232b927..31489d4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -848,6 +848,15 @@ static int e1000_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct bpf_prog *old_prog;
 
+	if (!adapter->rx_ring[0].xdp_buffer) {
+		int size = sizeof(struct e1000_rx_buffer_bundle) *
+				E1000_XDP_XMIT_BUNDLE_MAX;
+
+		adapter->rx_ring[0].xdp_buffer = vzalloc(size);
+		if (!adapter->rx_ring[0].xdp_buffer)
+			return -ENOMEM;
+	}
+
 	old_prog = xchg(&adapter->prog, prog);
 	if (old_prog) {
 		synchronize_net();
@@ -1319,6 +1328,9 @@ static void e1000_remove(struct pci_dev *pdev)
 	if (adapter->prog)
 		bpf_prog_put(adapter->prog);
 
+	if (adapter->rx_ring[0].xdp_buffer)
+		vfree(adapter->rx_ring[0].xdp_buffer);
+
 	unregister_netdev(netdev);
 
 	e1000_phy_hw_reset(hw);
@@ -3372,29 +3384,17 @@ static void e1000_tx_map_rxpage(struct e1000_tx_ring *tx_ring,
 
 static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
 				 u32 len,
+				 struct e1000_adapter *adapter,
 				 struct net_device *netdev,
-				 struct e1000_adapter *adapter)
+				 struct e1000_tx_ring *tx_ring)
 {
-	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
-	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_tx_ring *tx_ring;
+	const struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
 
 	if (len > E1000_MAX_DATA_PER_TXD)
 		return;
 
-	/* e1000 only support a single txq at the moment so the queue is being
-	 * shared with stack. To support this requires locking to ensure the
-	 * stack and XDP are not running at the same time. Devices with
-	 * multiple queues should allocate a separate queue space.
-	 */
-	HARD_TX_LOCK(netdev, txq, smp_processor_id());
-
-	tx_ring = adapter->tx_ring;
-
-	if (E1000_DESC_UNUSED(tx_ring) < 2) {
-		HARD_TX_UNLOCK(netdev, txq);
+	if (E1000_DESC_UNUSED(tx_ring) < 2)
 		return;
-	}
 
 	if (netif_xmit_frozen_or_stopped(txq))
 		return;
@@ -3402,7 +3402,36 @@ static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
 	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
 	netdev_sent_queue(netdev, len);
 	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
+}
 
+static void e1000_xdp_xmit_bundle(struct e1000_rx_buffer_bundle *buffer_info,
+				  struct net_device *netdev,
+				  struct e1000_adapter *adapter)
+{
+	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	struct e1000_hw *hw = &adapter->hw;
+	int i = 0;
+
+	/* e1000 only support a single txq at the moment so the queue is being
+	 * shared with stack. To support this requires locking to ensure the
+	 * stack and XDP are not running at the same time. Devices with
+	 * multiple queues should allocate a separate queue space.
+	 *
+	 * To amortize the locking cost e1000 bundles the xmits and send up to
+	 * E1000_XDP_XMIT_BUNDLE_MAX.
+	 */
+	HARD_TX_LOCK(netdev, txq, smp_processor_id());
+
+	for (; i < E1000_XDP_XMIT_BUNDLE_MAX && buffer_info[i].buffer; i++) {
+		e1000_xmit_raw_frame(buffer_info[i].buffer,
+				     buffer_info[i].length,
+				     adapter, netdev, tx_ring);
+		buffer_info[i].buffer = NULL;
+		buffer_info[i].length = 0;
+	}
+
+	/* kick hardware to send bundle and return control back to the stack */
 	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
 	mmiowb();
 
@@ -4284,9 +4313,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	struct bpf_prog *prog;
 	u32 length;
 	unsigned int i;
-	int cleaned_count = 0;
+	int cleaned_count = 0, xdp_xmit = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+	struct e1000_rx_buffer_bundle *xdp_bundle = rx_ring->xdp_buffer;
 
 	rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
 	prog = READ_ONCE(adapter->prog);
@@ -4341,12 +4371,13 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			case XDP_PASS:
 				break;
 			case XDP_TX:
+				xdp_bundle[xdp_xmit].buffer = buffer_info;
+				xdp_bundle[xdp_xmit].length = length;
 				dma_sync_single_for_device(&pdev->dev,
 							   dma,
 							   length,
 							   DMA_TO_DEVICE);
-				e1000_xmit_raw_frame(buffer_info, length,
-						     netdev, adapter);
+				xdp_xmit++;
 			case XDP_DROP:
 			default:
 				/* re-use mapped page. keep buffer_info->dma
@@ -4488,8 +4519,14 @@ next_desc:
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
+			if (xdp_xmit)
+				e1000_xdp_xmit_bundle(xdp_bundle,
+						      netdev,
+						      adapter);
+
 			adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
 			cleaned_count = 0;
+			xdp_xmit = 0;
 		}
 
 		/* use prefetched values */
@@ -4500,8 +4537,11 @@ next_desc:
 	rx_ring->next_to_clean = i;
 
 	cleaned_count = E1000_DESC_UNUSED(rx_ring);
-	if (cleaned_count)
+	if (cleaned_count) {
+		if (xdp_xmit)
+			e1000_xdp_xmit_bundle(xdp_bundle, netdev, adapter);
 		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
+	}
 
 	adapter->total_rx_packets += total_rx_packets;
 	adapter->total_rx_bytes += total_rx_bytes;
