From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000: implement jumbo receive with partial
	descriptors
Date: Mon, 06 Jul 2009 13:44:39 -0700
Message-ID: <20090706204439.17533.18584.stgit@localhost.localdomain>
References: <20090706204358.17533.64103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:52894
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753040AbZGFUo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 16:44:56 -0400
In-Reply-To: <20090706204358.17533.64103.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is code extremely similar to what is committed in e1000e
already.

e1000 will no longer request 32kB slab buffers to support jumbo
frames on PCI/PCI-X adapters.  This will significantly reduce the
likelyhood of order:3 allocation failures.

This new code adds support for using pages as receive buffers,
and the driver will chain multiple pages together to build a
jumbo frame for OS consumption.

The hardware takes a power of two buffer size and will
dump as much data as it can receive into 1 or more buffers.

The benefits of applying this are
1) stop akpm's dissing :-) of this lame e1000 behavior [1]
2) more efficient memory allocation (half) when using jumbo
   frames, which will also allow for much better socket utilization
   with jumbos since the socket is charged for the full allocation
   of each receive buffer, regardless of how much is used.
3) this was a feature request by a customer
4) copybreak for small packets < 256 bytes still applies

[1] http://lkml.org/lkml/2008/7/10/68
    http://article.gmane.org/gmane.linux.network/130986

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h      |    4 
 drivers/net/e1000/e1000_main.c |  425 +++++++++++++++++++++++++++++++++++++---
 2 files changed, 391 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index c87f2cb..1a4f89c 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -140,7 +140,7 @@ do {									\
 #define E1000_FC_HIGH_DIFF 0x1638  /* High: 5688 bytes below Rx FIFO size */
 #define E1000_FC_LOW_DIFF 0x1640   /* Low:  5696 bytes below Rx FIFO size */
 
-#define E1000_FC_PAUSE_TIME 0x0680 /* 858 usec */
+#define E1000_FC_PAUSE_TIME 0xFFFF /* pause for the max or until send xon */
 
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define E1000_TX_QUEUE_WAKE	16
@@ -164,6 +164,7 @@ do {									\
 struct e1000_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
+	struct page *page;
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
@@ -205,6 +206,7 @@ struct e1000_rx_ring {
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
+	struct sk_buff *rx_skb_top;
 
 	/* cpu for rx queue */
 	int cpu;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5b8cbdb..f2db9e2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -137,9 +137,15 @@ static int e1000_clean(struct napi_struct *napi, int budget);
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do);
+static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
+				     struct e1000_rx_ring *rx_ring,
+				     int *work_done, int work_to_do);
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
-                                   struct e1000_rx_ring *rx_ring,
+				   struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
+static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
+					 struct e1000_rx_ring *rx_ring,
+					 int cleaned_count);
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
@@ -761,10 +767,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 
 	hw->fc_high_water = fc_high_water_mark;
 	hw->fc_low_water = fc_high_water_mark - 8;
-	if (hw->mac_type == e1000_80003es2lan)
-		hw->fc_pause_time = 0xFFFF;
-	else
-		hw->fc_pause_time = E1000_FC_PAUSE_TIME;
+	hw->fc_pause_time = E1000_FC_PAUSE_TIME;
 	hw->fc_send_xon = 1;
 	hw->fc = hw->original_fc;
 
@@ -1862,6 +1865,7 @@ setup_rx_desc_die:
 
 	rxdr->next_to_clean = 0;
 	rxdr->next_to_use = 0;
+	rxdr->rx_skb_top = NULL;
 
 	return 0;
 }
@@ -1968,10 +1972,17 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
-	rdlen = adapter->rx_ring[0].count *
-		sizeof(struct e1000_rx_desc);
-	adapter->clean_rx = e1000_clean_rx_irq;
-	adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
+	if (adapter->netdev->mtu > ETH_DATA_LEN) {
+		rdlen = adapter->rx_ring[0].count *
+		        sizeof(struct e1000_rx_desc);
+		adapter->clean_rx = e1000_clean_jumbo_rx_irq;
+		adapter->alloc_rx_buf = e1000_alloc_jumbo_rx_buffers;
+	} else {
+		rdlen = adapter->rx_ring[0].count *
+		        sizeof(struct e1000_rx_desc);
+		adapter->clean_rx = e1000_clean_rx_irq;
+		adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
+	}
 
 	/* disable receives while setting up the descriptors */
 	rctl = er32(RCTL);
@@ -2185,26 +2196,39 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->dma) {
-			pci_unmap_single(pdev,
-					 buffer_info->dma,
-					 buffer_info->length,
-					 PCI_DMA_FROMDEVICE);
+		if (buffer_info->dma &&
+		    adapter->clean_rx == e1000_clean_rx_irq) {
+			pci_unmap_single(pdev, buffer_info->dma,
+			                 buffer_info->length,
+			                 PCI_DMA_FROMDEVICE);
+		} else if (buffer_info->dma &&
+		           adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
+			pci_unmap_page(pdev, buffer_info->dma,
+			               buffer_info->length,
+			               PCI_DMA_FROMDEVICE);
 		}
 
 		buffer_info->dma = 0;
-
+		if (buffer_info->page) {
+			put_page(buffer_info->page);
+			buffer_info->page = NULL;
+		}
 		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
 	}
 
+	/* there also may be some cached data from a chained receive */
+	if (rx_ring->rx_skb_top) {
+		dev_kfree_skb(rx_ring->rx_skb_top);
+		rx_ring->rx_skb_top = NULL;
+	}
+
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
-
 	memset(rx_ring->desc, 0, rx_ring->size);
 
 	rx_ring->next_to_clean = 0;
@@ -3489,8 +3513,10 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
-	 * larger slab size
-	 * i.e. RXBUFFER_2048 --> size-4096 slab */
+	 * larger slab size.
+	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 *  however with the new *_jumbo_rx* routines, jumbo receives will use
+	 *  fragmented skbs */
 
 	if (max_frame <= E1000_RXBUFFER_256)
 		adapter->rx_buffer_len = E1000_RXBUFFER_256;
@@ -3500,12 +3526,12 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = E1000_RXBUFFER_1024;
 	else if (max_frame <= E1000_RXBUFFER_2048)
 		adapter->rx_buffer_len = E1000_RXBUFFER_2048;
-	else if (max_frame <= E1000_RXBUFFER_4096)
-		adapter->rx_buffer_len = E1000_RXBUFFER_4096;
-	else if (max_frame <= E1000_RXBUFFER_8192)
-		adapter->rx_buffer_len = E1000_RXBUFFER_8192;
-	else if (max_frame <= E1000_RXBUFFER_16384)
+	else
+#if (PAGE_SIZE >= E1000_RXBUFFER_16384)
 		adapter->rx_buffer_len = E1000_RXBUFFER_16384;
+#elif (PAGE_SIZE >= E1000_RXBUFFER_4096)
+		adapter->rx_buffer_len = PAGE_SIZE;
+#endif
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if (!hw->tbi_compatibility_on &&
@@ -3987,9 +4013,227 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 }
 
 /**
+ * e1000_consume_page - helper function
+ **/
+static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
+                               u16 length)
+{
+	bi->page = NULL;
+	skb->len += length;
+	skb->data_len += length;
+	skb->truesize += length;
+}
+
+/**
+ * e1000_receive_skb - helper function to handle rx indications
+ * @adapter: board private structure
+ * @status: descriptor status field as written by hardware
+ * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
+ * @skb: pointer to sk_buff to be indicated to stack
+ */
+static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
+			      __le16 vlan, struct sk_buff *skb)
+{
+	if (unlikely(adapter->vlgrp && (status & E1000_RXD_STAT_VP))) {
+		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
+		                         le16_to_cpu(vlan) &
+		                         E1000_RXD_SPC_VLAN_MASK);
+	} else {
+		netif_receive_skb(skb);
+	}
+}
+
+/**
+ * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
+ * @adapter: board private structure
+ * @rx_ring: ring to clean
+ * @work_done: amount of napi work completed this call
+ * @work_to_do: max amount of work allowed for this call to do
+ *
+ * the return value indicates whether actual cleaning was done, there
+ * is no guarantee that everything was cleaned
+ */
+static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
+				     struct e1000_rx_ring *rx_ring,
+				     int *work_done, int work_to_do)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_rx_desc *rx_desc, *next_rxd;
+	struct e1000_buffer *buffer_info, *next_buffer;
+	unsigned long irq_flags;
+	u32 length;
+	unsigned int i;
+	int cleaned_count = 0;
+	bool cleaned = false;
+	unsigned int total_rx_bytes=0, total_rx_packets=0;
+
+	i = rx_ring->next_to_clean;
+	rx_desc = E1000_RX_DESC(*rx_ring, i);
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (rx_desc->status & E1000_RXD_STAT_DD) {
+		struct sk_buff *skb;
+		u8 status;
+
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+
+		status = rx_desc->status;
+		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
+
+		if (++i == rx_ring->count) i = 0;
+		next_rxd = E1000_RX_DESC(*rx_ring, i);
+		prefetch(next_rxd);
+
+		next_buffer = &rx_ring->buffer_info[i];
+
+		cleaned = true;
+		cleaned_count++;
+		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
+		               PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
+
+		length = le16_to_cpu(rx_desc->length);
+
+		/* errors is only valid for DD + EOP descriptors */
+		if (unlikely((status & E1000_RXD_STAT_EOP) &&
+		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
+			u8 last_byte = *(skb->data + length - 1);
+			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
+				       last_byte)) {
+				spin_lock_irqsave(&adapter->stats_lock,
+				                  irq_flags);
+				e1000_tbi_adjust_stats(hw, &adapter->stats,
+				                       length, skb->data);
+				spin_unlock_irqrestore(&adapter->stats_lock,
+				                       irq_flags);
+				length--;
+			} else {
+				/* recycle both page and skb */
+				buffer_info->skb = skb;
+				/* an error means any chain goes out the window
+				 * too */
+				if (rx_ring->rx_skb_top)
+					dev_kfree_skb(rx_ring->rx_skb_top);
+				rx_ring->rx_skb_top = NULL;
+				goto next_desc;
+			}
+		}
+
+#define rxtop rx_ring->rx_skb_top
+		if (!(status & E1000_RXD_STAT_EOP)) {
+			/* this descriptor is only the beginning (or middle) */
+			if (!rxtop) {
+				/* this is the beginning of a chain */
+				rxtop = skb;
+				skb_fill_page_desc(rxtop, 0, buffer_info->page,
+				                   0, length);
+			} else {
+				/* this is the middle of a chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the skb, only consumed the page */
+				buffer_info->skb = skb;
+			}
+			e1000_consume_page(buffer_info, rxtop, length);
+			goto next_desc;
+		} else {
+			if (rxtop) {
+				/* end of the chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the current skb, we only consumed the
+				 * page */
+				buffer_info->skb = skb;
+				skb = rxtop;
+				rxtop = NULL;
+				e1000_consume_page(buffer_info, skb, length);
+			} else {
+				/* no chain, got EOP, this buf is the packet
+				 * copybreak to save the put_page/alloc_page */
+				if (length <= copybreak &&
+				    skb_tailroom(skb) >= length) {
+					u8 *vaddr;
+					vaddr = kmap_atomic(buffer_info->page,
+					                    KM_SKB_DATA_SOFTIRQ);
+					memcpy(skb_tail_pointer(skb), vaddr, length);
+					kunmap_atomic(vaddr,
+					              KM_SKB_DATA_SOFTIRQ);
+					/* re-use the page, so don't erase
+					 * buffer_info->page */
+					skb_put(skb, length);
+				} else {
+					skb_fill_page_desc(skb, 0,
+					                   buffer_info->page, 0,
+				                           length);
+					e1000_consume_page(buffer_info, skb,
+					                   length);
+				}
+			}
+		}
+
+		/* Receive Checksum Offload XXX recompute due to CRC strip? */
+		e1000_rx_checksum(adapter,
+		                  (u32)(status) |
+		                  ((u32)(rx_desc->errors) << 24),
+		                  le16_to_cpu(rx_desc->csum), skb);
+
+		pskb_trim(skb, skb->len - 4);
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
+		/* eth type trans needs skb->data to point to something */
+		if (!pskb_may_pull(skb, ETH_HLEN)) {
+			DPRINTK(DRV, ERR, "pskb_may_pull failed.\n");
+			dev_kfree_skb(skb);
+			goto next_desc;
+		}
+
+		skb->protocol = eth_type_trans(skb, netdev);
+
+		e1000_receive_skb(adapter, status, rx_desc->special, skb);
+
+next_desc:
+		rx_desc->status = 0;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
+			adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		/* use prefetched values */
+		rx_desc = next_rxd;
+		buffer_info = next_buffer;
+	}
+	rx_ring->next_to_clean = i;
+
+	cleaned_count = E1000_DESC_UNUSED(rx_ring);
+	if (cleaned_count)
+		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
+
+	adapter->total_rx_packets += total_rx_packets;
+	adapter->total_rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+	return cleaned;
+}
+
+/**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
- **/
+ * @rx_ring: ring to clean
+ * @work_done: amount of napi work completed this call
+ * @work_to_do: max amount of work allowed for this call to do
+ */
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do)
@@ -4001,7 +4245,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info, *next_buffer;
 	unsigned long flags;
 	u32 length;
-	u8 last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
 	bool cleaned = false;
@@ -4033,9 +4276,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		cleaned = true;
 		cleaned_count++;
-		pci_unmap_single(pdev,
-		                 buffer_info->dma,
-		                 buffer_info->length,
+		pci_unmap_single(pdev, buffer_info->dma, buffer_info->length,
 		                 PCI_DMA_FROMDEVICE);
 		buffer_info->dma = 0;
 
@@ -4052,7 +4293,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
-			last_byte = *(skb->data + length - 1);
+			u8 last_byte = *(skb->data + length - 1);
 			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
 				       last_byte)) {
 				spin_lock_irqsave(&adapter->stats_lock, flags);
@@ -4107,13 +4348,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		skb->protocol = eth_type_trans(skb, netdev);
 
-		if (unlikely(adapter->vlgrp &&
-			    (status & E1000_RXD_STAT_VP))) {
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->special));
-		} else {
-			netif_receive_skb(skb);
-		}
+		e1000_receive_skb(adapter, status, rx_desc->special, skb);
 
 next_desc:
 		rx_desc->status = 0;
@@ -4142,6 +4377,114 @@ next_desc:
 }
 
 /**
+ * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
+ * @adapter: address of board private structure
+ * @rx_ring: pointer to receive ring structure
+ * @cleaned_count: number of buffers to allocate this pass
+ **/
+
+static void
+e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
+                             struct e1000_rx_ring *rx_ring, int cleaned_count)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_rx_desc *rx_desc;
+	struct e1000_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int bufsz = 256 -
+	                     16 /*for skb_reserve */ -
+	                     NET_IP_ALIGN;
+
+	i = rx_ring->next_to_use;
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (cleaned_count--) {
+		skb = buffer_info->skb;
+		if (skb) {
+			skb_trim(skb, 0);
+			goto check_page;
+		}
+
+		skb = netdev_alloc_skb(netdev, bufsz);
+		if (unlikely(!skb)) {
+			/* Better luck next round */
+			adapter->alloc_rx_buff_failed++;
+			break;
+		}
+
+		/* Fix for errata 23, can't cross 64kB boundary */
+		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+			struct sk_buff *oldskb = skb;
+			DPRINTK(PROBE, ERR, "skb align check failed: %u bytes "
+					     "at %p\n", bufsz, skb->data);
+			/* Try again, without freeing the previous */
+			skb = netdev_alloc_skb(netdev, bufsz);
+			/* Failed allocation, critical failure */
+			if (!skb) {
+				dev_kfree_skb(oldskb);
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+
+			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+				/* give up */
+				dev_kfree_skb(skb);
+				dev_kfree_skb(oldskb);
+				break; /* while (cleaned_count--) */
+			}
+
+			/* Use new allocation */
+			dev_kfree_skb(oldskb);
+		}
+		/* Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		buffer_info->skb = skb;
+		buffer_info->length = adapter->rx_buffer_len;
+check_page:
+		/* allocate a new page if necessary */
+		if (!buffer_info->page) {
+			buffer_info->page = alloc_page(GFP_ATOMIC);
+			if (unlikely(!buffer_info->page)) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+		}
+
+		if (!buffer_info->dma)
+			buffer_info->dma = pci_map_page(pdev,
+			                                buffer_info->page, 0,
+			                                buffer_info->length,
+			                                PCI_DMA_FROMDEVICE);
+
+		rx_desc = E1000_RX_DESC(*rx_ring, i);
+		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
+
+		if (unlikely(++i == rx_ring->count))
+			i = 0;
+		buffer_info = &rx_ring->buffer_info[i];
+	}
+
+	if (likely(rx_ring->next_to_use != i)) {
+		rx_ring->next_to_use = i;
+		if (unlikely(i-- == 0))
+			i = (rx_ring->count - 1);
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64). */
+		wmb();
+		writel(i, adapter->hw.hw_addr + rx_ring->rdt);
+	}
+}
+
+/**
  * e1000_alloc_rx_buffers - Replace used receive buffers; legacy & extended
  * @adapter: address of board private structure
  **/
@@ -4186,6 +4529,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			/* Failed allocation, critical failure */
 			if (!skb) {
 				dev_kfree_skb(oldskb);
+				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
@@ -4193,6 +4537,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 				/* give up */
 				dev_kfree_skb(skb);
 				dev_kfree_skb(oldskb);
+				adapter->alloc_rx_buff_failed++;
 				break; /* while !buffer_info->skb */
 			}
 
@@ -4210,9 +4555,14 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 map_skb:
 		buffer_info->dma = pci_map_single(pdev,
 						  skb->data,
-						  adapter->rx_buffer_len,
+						  buffer_info->length,
 						  PCI_DMA_FROMDEVICE);
 
+		/*
+		 * XXX if it was allocated cleanly it will never map to a
+		 * boundary crossing
+		 */
+
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter,
 					(void *)(unsigned long)buffer_info->dma,
@@ -4229,6 +4579,7 @@ map_skb:
 					 PCI_DMA_FROMDEVICE);
 			buffer_info->dma = 0;
 
+			adapter->alloc_rx_buff_failed++;
 			break; /* while !buffer_info->skb */
 		}
 		rx_desc = E1000_RX_DESC(*rx_ring, i);

