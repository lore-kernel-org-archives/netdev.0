From: Neil Horman <nhorman@tuxdriver.com>
Subject: [net PATCH] atl1e: unmap partially mapped skb on dma error and free skb
Date: Tue, 16 Jul 2013 10:49:41 -0400
Message-ID: <1373986181-15797-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33128 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab3GPOuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 10:50:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings pointed out that my recent update to atl1e:

commit 352900b583b2852152a1e05ea0e8b579292e731e
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Fri Jul 12 10:58:48 2013 -0400

    atl1e: fix dma mapping warnings

Was missing a bit of code.  Specifically it reset the hardware tx ring to its
origional state when we hit a dma error, but didn't unmap any exiting mappings
from the operation.  This patch fixes that up.  It also remembers to free the
skb in the event that an error occurs, so we don't leak.  Untested, as I don't
have hardware.  I think its pretty straightforward, but please review closely.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Jay Cliburn <jcliburn@gmail.com>
CC: Chris Snook <chris.snook@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 6d1a62a..1966444 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1678,6 +1678,7 @@ static int atl1e_tx_map(struct atl1e_adapter *adapter,
 	u16 f;
 	int segment;
 	int ring_start = adapter->tx_ring.next_to_use;
+	int ring_end;
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	segment = (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_MASK;
@@ -1721,6 +1722,15 @@ static int atl1e_tx_map(struct atl1e_adapter *adapter,
 					map_len, PCI_DMA_TODEVICE);
 
 		if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma)) {
+			/* We need to unwind the mappings we've done */
+			ring_end = adapter->tx_ring.next_to_use;
+			adapter->tx_ring.next_to_use = ring_start;
+			while (adapter->tx_ring.next_to_use != ring_end) {
+				tpd = atl1e_get_tpd(adapter);
+				tx_buffer = atl1e_get_tx_buffer(adapter, tpd);
+				pci_unmap_single(adapter->pdev, tx_buffer->dma,
+						 tx_buffer->length, PCI_DMA_TODEVICE);
+			}
 			/* Reset the tx rings next pointer */
 			adapter->tx_ring.next_to_use = ring_start;
 			return -ENOSPC;
@@ -1763,6 +1773,16 @@ static int atl1e_tx_map(struct atl1e_adapter *adapter,
 							  DMA_TO_DEVICE);
 
 			if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma)) {
+				/* We need to unwind the mappings we've done */
+				ring_end = adapter->tx_ring.next_to_use;
+				adapter->tx_ring.next_to_use = ring_start;
+				while (adapter->tx_ring.next_to_use != ring_end) {
+					tpd = atl1e_get_tpd(adapter);
+					tx_buffer = atl1e_get_tx_buffer(adapter, tpd);
+					dma_unmap_page(&adapter->pdev->dev, tx_buffer->dma,
+						       tx_buffer->length, DMA_TO_DEVICE);
+				}
+
 				/* Reset the ring next to use pointer */
 				adapter->tx_ring.next_to_use = ring_start;
 				return -ENOSPC;
@@ -1853,8 +1873,10 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	if (atl1e_tx_map(adapter, skb, tpd))
+	if (atl1e_tx_map(adapter, skb, tpd)) {
+		dev_kfree_skb_any(skb);
 		goto out;
+	}
 
 	atl1e_tx_queue(adapter, tpd_req, tpd);
 
-- 
1.8.1.4
