From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 20/25] ixgb: rx cleanup performance improvements
Date: Tue, 08 Jul 2008 15:52:43 -0700
Message-ID: <20080708225243.6925.82121.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6794 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbYGHWwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:44 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

rx cleanup should look more like our other drivers that have evolved
to nicer performance levels over time.  Changes consist of refilling
tx buffers to hardware more often, some minor assignment cleanups.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c1dde79..365212b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -98,7 +98,7 @@ static bool ixgb_clean_rx_irq(struct ixgb_adapter *, int *, int);
 #else
 static bool ixgb_clean_rx_irq(struct ixgb_adapter *);
 #endif
-static void ixgb_alloc_rx_buffers(struct ixgb_adapter *);
+static void ixgb_alloc_rx_buffers(struct ixgb_adapter *, int);
 
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
@@ -225,7 +225,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	ixgb_configure_tx(adapter);
 	ixgb_setup_rctl(adapter);
 	ixgb_configure_rx(adapter);
-	ixgb_alloc_rx_buffers(adapter);
+	ixgb_alloc_rx_buffers(adapter, IXGB_DESC_UNUSED(&adapter->rx_ring));
 
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
@@ -1906,6 +1906,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
 	u32 length;
 	unsigned int i, j;
+	int cleaned_count = 0;
 	bool cleaned = false;
 
 	i = rx_ring->next_to_clean;
@@ -1913,7 +1914,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
-		struct sk_buff *skb, *next_skb;
+		struct sk_buff *skb;
 		u8 status;
 
 #ifdef CONFIG_IXGB_NAPI
@@ -1926,7 +1927,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
 
-		prefetch(skb->data);
+		prefetch(skb->data - NET_IP_ALIGN);
 
 		if (++i == rx_ring->count) i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
@@ -1937,17 +1938,18 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		prefetch(next2_buffer);
 
 		next_buffer = &rx_ring->buffer_info[i];
-		next_skb = next_buffer->skb;
-		prefetch(next_skb);
 
 		cleaned = true;
+		cleaned_count++;
 
 		pci_unmap_single(pdev,
 				 buffer_info->dma,
 				 buffer_info->length,
 				 PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
+		rx_desc->length = 0;
 
 		if (unlikely(!(status & IXGB_RX_DESC_STATUS_EOP))) {
 
@@ -2016,6 +2018,12 @@ rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
 		rx_desc->status = 0;
 
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >= IXGB_RX_BUFFER_WRITE)) {
+			ixgb_alloc_rx_buffers(adapter, cleaned_count);
+			cleaned_count = 0;
+		}
+
 		/* use prefetched values */
 		rx_desc = next_rxd;
 		buffer_info = next_buffer;
@@ -2023,7 +2031,9 @@ rxdesc_done:
 
 	rx_ring->next_to_clean = i;
 
-	ixgb_alloc_rx_buffers(adapter);
+	cleaned_count = IXGB_DESC_UNUSED(rx_ring);
+	if (cleaned_count)
+		ixgb_alloc_rx_buffers(adapter, cleaned_count);
 
 	return cleaned;
 }
@@ -2034,7 +2044,7 @@ rxdesc_done:
  **/
 
 static void
-ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
+ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter, int cleaned_count)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -2051,7 +2061,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 
 
 	/* leave three descriptors unused */
-	while (--cleancount > 2) {
+	while (--cleancount > 2 && cleaned_count--) {
 		/* recycle! its good for you */
 		skb = buffer_info->skb;
 		if (skb) {

