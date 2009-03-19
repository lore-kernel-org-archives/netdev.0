From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgb: refactor tx path to use skb_dma_map/unmap
Date: Thu, 19 Mar 2009 04:15:21 -0700
Message-ID: <20090319111521.11723.60786.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:43999 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052AbZCSLPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This code updates ixgb so that it can use the skb_dma_map/unmap functions
to map the buffers.  In addition it also updates the tx hang logic to use
time_stamp instead of dma to determine if it has detected a tx hang.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   70 +++++++++++++++++++++++-------------------
 1 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e2ef16b..4b0ea66 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -887,19 +887,13 @@ static void
 ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
                                 struct ixgb_buffer *buffer_info)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	if (buffer_info->dma)
-		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
-		               PCI_DMA_TODEVICE);
-
-	/* okay to call kfree_skb here instead of kfree_skb_any because
-	 * this is never called in interrupt context */
-	if (buffer_info->skb)
-		dev_kfree_skb(buffer_info->skb);
-
-	buffer_info->skb = NULL;
 	buffer_info->dma = 0;
+	if (buffer_info->skb) {
+		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
+		              DMA_TO_DEVICE);
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
 	buffer_info->time_stamp = 0;
 	/* these fields must always be initialized in tx
 	 * buffer_info->length = 0;
@@ -1275,17 +1269,23 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_buffer *buffer_info;
-	int len = skb->len;
+	int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
-
-	len -= skb->data_len;
+	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
+	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
+		return 0;
+	}
+
+	map = skb_shinfo(skb)->dma_maps;
+
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_DATA_PER_TXD);
@@ -1297,7 +1297,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma =
+		buffer_info->dma = map[0] + offset;
 			pci_map_single(adapter->pdev,
 				skb->data + offset,
 				size,
@@ -1307,7 +1307,11 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		len -= size;
 		offset += size;
 		count++;
-		if (++i == tx_ring->count) i = 0;
+		if (len) {
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+		}
 	}
 
 	for (f = 0; f < nr_frags; f++) {
@@ -1318,6 +1322,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		offset = 0;
 
 		while (len) {
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_DATA_PER_TXD);
 
@@ -1329,21 +1337,14 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma =
-				pci_map_page(adapter->pdev,
-					frag->page,
-					frag->page_offset + offset,
-					size,
-					PCI_DMA_TODEVICE);
+			buffer_info->dma = map[f + 1] + offset;
 			buffer_info->next_to_watch = 0;
 
 			len -= size;
 			offset += size;
 			count++;
-			if (++i == tx_ring->count) i = 0;
 		}
 	}
-	i = (i == 0) ? tx_ring->count - 1 : i - 1;
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
@@ -1445,6 +1446,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	int vlan_id = 0;
+	int count = 0;
 	int tso;
 
 	if (test_bit(__IXGB_DOWN, &adapter->flags)) {
@@ -1479,13 +1481,19 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	else if (ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;
 
-	ixgb_tx_queue(adapter, ixgb_tx_map(adapter, skb, first), vlan_id,
-			tx_flags);
+	count = ixgb_tx_map(adapter, skb, first);
 
-	netdev->trans_start = jiffies;
+	if (count) {
+		ixgb_tx_queue(adapter, count, vlan_id, tx_flags);
+		netdev->trans_start = jiffies;
+		/* Make sure there is space in the ring for the next send. */
+		ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
 
-	/* Make sure there is space in the ring for the next send. */
-	ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
+	} else {
+		dev_kfree_skb_any(skb);
+		adapter->tx_ring.buffer_info[first].time_stamp = 0;
+		adapter->tx_ring.next_to_use = first;
+	}
 
 	return NETDEV_TX_OK;
 }
@@ -1818,7 +1826,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 		/* detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
-		if (tx_ring->buffer_info[eop].dma &&
+		if (tx_ring->buffer_info[eop].time_stamp &&
 		   time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
 		        IXGB_STATUS_TXOFF)) {

