From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] e1000: add initial XDP support
Date: Sat, 27 Aug 2016 00:11:46 -0700
Message-ID: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, xiyou.wangcong@gmail.com
To: bblanco@plumgrid.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34372 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754793AbcH0HMI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 03:12:08 -0400
Received: by mail-pa0-f66.google.com with SMTP id hh10so5812347pac.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 00:12:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>

This patch adds initial support for XDP on e1000 driver. Note e1000
driver does not support page recycling in general which could be
added as a further improvement. However for XDP_DROP and XDP_XMIT
the xdp code paths will recycle pages.

This patch includes the rcu_read_lock/rcu_read_unlock pair noted by
Brenden Blanco in another pending patch.

  net/mlx4_en: protect ring->xdp_prog with rcu_read_lock

CC: William Tu <u9012063@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |    1 
 drivers/net/ethernet/intel/e1000/e1000_main.c |  168 ++++++++++++++++++++++++-
 2 files changed, 165 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index d7bdea7..62e33fa 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -279,6 +279,7 @@ struct e1000_adapter {
 			     struct e1000_rx_ring *rx_ring,
 			     int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
+	struct bpf_prog *prog;
 	struct napi_struct napi;
 
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index f42129d..396b0e0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -32,6 +32,7 @@
 #include <linux/prefetch.h>
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
+#include <linux/bpf.h>
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -842,6 +843,44 @@ static int e1000_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int e1000_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct bpf_prog *old_prog;
+
+	old_prog = xchg(&adapter->prog, prog);
+	if (old_prog) {
+		synchronize_net();
+		bpf_prog_put(old_prog);
+	}
+
+	if (netif_running(netdev))
+		e1000_reinit_locked(adapter);
+	else
+		e1000_reset(adapter);
+	return 0;
+}
+
+static bool e1000_xdp_attached(struct net_device *dev)
+{
+	struct e1000_adapter *priv = netdev_priv(dev);
+
+	return !!priv->prog;
+}
+
+static int e1000_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return e1000_xdp_set(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = e1000_xdp_attached(dev);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops e1000_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
@@ -860,6 +899,7 @@ static const struct net_device_ops e1000_netdev_ops = {
 #endif
 	.ndo_fix_features	= e1000_fix_features,
 	.ndo_set_features	= e1000_set_features,
+	.ndo_xdp		= e1000_xdp,
 };
 
 /**
@@ -1276,6 +1316,9 @@ static void e1000_remove(struct pci_dev *pdev)
 	e1000_down_and_stop(adapter);
 	e1000_release_manageability(adapter);
 
+	if (adapter->prog)
+		bpf_prog_put(adapter->prog);
+
 	unregister_netdev(netdev);
 
 	e1000_phy_hw_reset(hw);
@@ -1859,7 +1902,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rdlen, rctl, rxcsum;
 
-	if (adapter->netdev->mtu > ETH_DATA_LEN) {
+	if (adapter->netdev->mtu > ETH_DATA_LEN || adapter->prog) {
 		rdlen = adapter->rx_ring[0].count *
 			sizeof(struct e1000_rx_desc);
 		adapter->clean_rx = e1000_clean_jumbo_rx_irq;
@@ -3298,6 +3341,61 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static void e1000_tx_map_rxpage(struct e1000_tx_ring *tx_ring,
+				struct e1000_rx_buffer *rx_buffer_info,
+				unsigned int len)
+{
+	struct e1000_tx_buffer *buffer_info;
+	unsigned int i = tx_ring->next_to_use;
+
+	buffer_info = &tx_ring->buffer_info[i];
+
+	buffer_info->length = len;
+	buffer_info->time_stamp = jiffies;
+	buffer_info->mapped_as_page = false;
+	buffer_info->dma = rx_buffer_info->dma;
+	buffer_info->next_to_watch = i;
+
+	tx_ring->buffer_info[i].skb = NULL;
+	tx_ring->buffer_info[i].segs = 1;
+	tx_ring->buffer_info[i].bytecount = len;
+	tx_ring->buffer_info[i].next_to_watch = i;
+}
+
+static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
+				 unsigned int len,
+				 struct net_device *netdev,
+				 struct e1000_adapter *adapter)
+{
+	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
+	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_tx_ring *tx_ring;
+
+	if (len > E1000_MAX_DATA_PER_TXD)
+		return;
+
+	/* e1000 only support a single txq at the moment so the queue is being
+	 * shared with stack. To support this requires locking to ensure the
+	 * stack and XPD are not running at the same time. Devices would
+	 * multiple queues should allocate a separate queue space.
+	 */
+	HARD_TX_LOCK(netdev, txq, smp_processor_id());
+
+	tx_ring = adapter->tx_ring;
+
+	if (E1000_DESC_UNUSED(tx_ring) < 2)
+		return;
+
+	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
+
+	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
+
+	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
+	mmiowb();
+
+	HARD_TX_UNLOCK(netdev, txq);
+}
+
 #define NUM_REGS 38 /* 1 based count */
 static void e1000_regdump(struct e1000_adapter *adapter)
 {
@@ -4142,6 +4240,22 @@ static struct sk_buff *e1000_alloc_rx_skb(struct e1000_adapter *adapter,
 	return skb;
 }
 
+static inline int e1000_call_bpf(struct bpf_prog *prog, void *data,
+				 unsigned int length)
+{
+	struct xdp_buff xdp;
+	int ret;
+
+	xdp.data = data;
+	xdp.data_end = data + length;
+
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(prog, (void *)&xdp);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 /**
  * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -4160,12 +4274,15 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_rx_buffer *buffer_info, *next_buffer;
+	struct bpf_prog *prog;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
+	rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
+	prog = READ_ONCE(adapter->prog);
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
 	buffer_info = &rx_ring->buffer_info[i];
@@ -4188,15 +4305,57 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		prefetch(next_rxd);
 
 		next_buffer = &rx_ring->buffer_info[i];
-
 		cleaned = true;
 		cleaned_count++;
+		length = le16_to_cpu(rx_desc->length);
+
+		if (prog) {
+			struct page *p = buffer_info->rxbuf.page;
+			dma_addr_t dma = buffer_info->dma;
+			int act;
+
+			if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
+				/* attached bpf disallows larger than page
+				 * packets, so this is hw error or corruption
+				 */
+				pr_info_once("%s buggy !eop\n", netdev->name);
+				break;
+			}
+			if (unlikely(rx_ring->rx_skb_top)) {
+				pr_info_once("%s ring resizing bug\n",
+					     netdev->name);
+				break;
+			}
+			dma_sync_single_for_cpu(&pdev->dev, dma,
+						length, DMA_FROM_DEVICE);
+			act = e1000_call_bpf(prog, page_address(p), length);
+			switch (act) {
+			case XDP_PASS:
+				break;
+			case XDP_TX:
+				dma_sync_single_for_device(&pdev->dev,
+							   dma,
+							   length,
+							   DMA_TO_DEVICE);
+				e1000_xmit_raw_frame(buffer_info, length,
+						     netdev, adapter);
+			/* Fallthrough to re-use mappedg page after xmit */
+			case XDP_DROP:
+			default:
+				/* re-use mapped page. keep buffer_info->dma
+				 * as-is, so that e1000_alloc_jumbo_rx_buffers
+				 * only needs to put it back into rx ring
+				 */
+				total_rx_bytes += length;
+				total_rx_packets++;
+				goto next_desc;
+			}
+		}
+
 		dma_unmap_page(&pdev->dev, buffer_info->dma,
 			       adapter->rx_buffer_len, DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
-		length = le16_to_cpu(rx_desc->length);
-
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
 		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
@@ -4330,6 +4489,7 @@ next_desc:
 		rx_desc = next_rxd;
 		buffer_info = next_buffer;
 	}
+	rcu_read_unlock();
 	rx_ring->next_to_clean = i;
 
 	cleaned_count = E1000_DESC_UNUSED(rx_ring);
