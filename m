From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: remove memory copy for rx path
Date: Wed, 24 Sep 2014 14:05:30 +0800
Message-ID: <1411538730-31480-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <b38611@freescale.com>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0115.outbound.protection.outlook.com ([157.56.111.115]:10555
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751122AbaIXGdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 02:33:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-allocate skb instead of memory copy skb data in rx path to improve
enet rx performance.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   90 +++++++++++++++--------------
 1 files changed, 47 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 2b16ead..1fc8e52 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1322,6 +1322,28 @@ fec_enet_tx(struct net_device *ndev)
 	return;
 }
 
+static int
+fec_enet_new_rxbdp(struct net_device *ndev, struct bufdesc *bdp, struct sk_buff *skb)
+{
+	struct  fec_enet_private *fep = netdev_priv(ndev);
+	int off;
+
+	off = ((unsigned long)skb->data) & fep->rx_align;
+	if (off)
+		skb_reserve(skb, fep->rx_align + 1 - off);
+
+	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
+					  FEC_ENET_RX_FRSIZE - fep->rx_align,
+					  DMA_FROM_DEVICE);
+	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
+		if (net_ratelimit())
+			netdev_err(ndev, "Rx DMA memory map failed\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
 /* During a receive, the cur_rx points to the current incoming buffer.
  * When we update through the ring, if the next incoming buffer has
  * not been given to the system, we just set the empty indicator,
@@ -1336,7 +1358,8 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *bdp;
 	unsigned short status;
-	struct	sk_buff	*skb;
+	struct  sk_buff *skb_new = NULL;
+	struct  sk_buff *skb_cur;
 	ushort	pkt_len;
 	__u8 *data;
 	int	pkt_received = 0;
@@ -1402,9 +1425,10 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 
 		index = fec_enet_get_bd_index(rxq->rx_bd_base, bdp, fep);
 		data = rxq->rx_skbuff[index]->data;
-		dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
-					FEC_ENET_RX_FRSIZE - fep->rx_align,
-					DMA_FROM_DEVICE);
+		skb_cur = rxq->rx_skbuff[index];
+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+				 FEC_ENET_RX_FRSIZE - fep->rx_align,
+				 DMA_FROM_DEVICE);
 
 		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
 			swap_buffer(data, pkt_len);
@@ -1427,57 +1451,50 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 			vlan_packet_rcvd = true;
 		}
 
-		/* This does 16 byte alignment, exactly what we need.
-		 * The packet length includes FCS, but we don't want to
-		 * include that when passing upstream as it messes up
-		 * bridging applications.
-		 */
-		skb = netdev_alloc_skb(ndev, pkt_len - 4 + NET_IP_ALIGN);
+		skb_new = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 
-		if (unlikely(!skb)) {
+		if (unlikely(!skb_new)) {
 			ndev->stats.rx_dropped++;
 		} else {
-			int payload_offset = (2 * ETH_ALEN);
-			skb_reserve(skb, NET_IP_ALIGN);
-			skb_put(skb, pkt_len - 4);	/* Make room */
+			skb_put(skb_cur, pkt_len - 4);	/* Make room */
 
 			/* Extract the frame data without the VLAN header. */
-			skb_copy_to_linear_data(skb, data, (2 * ETH_ALEN));
-			if (vlan_packet_rcvd)
-				payload_offset = (2 * ETH_ALEN) + VLAN_HLEN;
-			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
-						       data + payload_offset,
-						       pkt_len - 4 - (2 * ETH_ALEN));
+			if (vlan_packet_rcvd) {
+				skb_copy_to_linear_data_offset(skb_cur, VLAN_HLEN,
+							       data, (2 * ETH_ALEN));
+				skb_pull(skb_cur, VLAN_HLEN);
+			}
 
-			skb->protocol = eth_type_trans(skb, ndev);
+			skb_cur->protocol = eth_type_trans(skb_cur, ndev);
 
 			/* Get receive timestamp from the skb */
 			if (fep->hwts_rx_en && fep->bufdesc_ex)
 				fec_enet_hwtstamp(fep, ebdp->ts,
-						  skb_hwtstamps(skb));
+						  skb_hwtstamps(skb_cur));
 
 			if (fep->bufdesc_ex &&
 			    (fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
 				if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ERROR)) {
 					/* don't check it */
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
+					skb_cur->ip_summed = CHECKSUM_UNNECESSARY;
 				} else {
-					skb_checksum_none_assert(skb);
+					skb_checksum_none_assert(skb_cur);
 				}
 			}
 
 			/* Handle received VLAN packets */
 			if (vlan_packet_rcvd)
-				__vlan_hwaccel_put_tag(skb,
+				__vlan_hwaccel_put_tag(skb_cur,
 						       htons(ETH_P_8021Q),
 						       vlan_tag);
 
-			napi_gro_receive(&fep->napi, skb);
+			napi_gro_receive(&fep->napi, skb_cur);
 		}
 
-		dma_sync_single_for_device(&fep->pdev->dev, bdp->cbd_bufaddr,
-					   FEC_ENET_RX_FRSIZE - fep->rx_align,
-					   DMA_FROM_DEVICE);
+		/* set the new skb */
+		rxq->rx_skbuff[index] = skb_new;
+		fec_enet_new_rxbdp(ndev, bdp, skb_new);
+
 rx_processing_done:
 		/* Clear the status flags for this buffer */
 		status &= ~BD_ENET_RX_STATS;
@@ -2553,33 +2570,20 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
 	struct fec_enet_priv_rx_q *rxq;
-	unsigned int off;
 
 	rxq = fep->rx_queue[queue];
 	bdp = rxq->rx_bd_base;
 	for (i = 0; i < rxq->rx_ring_size; i++) {
-		dma_addr_t addr;
-
 		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 		if (!skb)
 			goto err_alloc;
 
-		off = ((unsigned long)skb->data) & fep->rx_align;
-		if (off)
-			skb_reserve(skb, fep->rx_align + 1 - off);
-
-		addr = dma_map_single(&fep->pdev->dev, skb->data,
-				FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE);
-
-		if (dma_mapping_error(&fep->pdev->dev, addr)) {
+		if (fec_enet_new_rxbdp(ndev, bdp, skb)) {
 			dev_kfree_skb(skb);
-			if (net_ratelimit())
-				netdev_err(ndev, "Rx DMA memory map failed\n");
 			goto err_alloc;
 		}
 
 		rxq->rx_skbuff[i] = skb;
-		bdp->cbd_bufaddr = addr;
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 
 		if (fep->bufdesc_ex) {
-- 
1.7.8
