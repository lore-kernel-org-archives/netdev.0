From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH net-next 6/6] net: mvneta: implement rx_copybreak
Date: Sun, 12 Jan 2014 12:24:08 +0100
Message-ID: <1389525848-1814-7-git-send-email-w@1wt.eu>
References: <1389525848-1814-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55248 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbaALLYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 06:24:38 -0500
In-Reply-To: <1389525848-1814-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

calling dma_map_single()/dma_unmap_single() is quite expensive compared
to copying a small packet. So let's copy short frames and keep the buffers
mapped. We set the limit to 256 bytes which seems to give good results both
on the XP-GP board and on the AX3/4.

The Rx small packet rate increased by 16.4% doing this, from 486kpps to
573kpps. It is worth noting that even the call to the function
dma_sync_single_range_for_cpu() is expensive (300 ns) although less
than dma_unmap_single(). Without it, the packet rate raises to 711kpps
(+24% more). Thus on systems where coherency from device to CPU is
guaranteed by a snoop control unit, this patch should provide even more
gains, and probably rx_copybreak could be increased.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 44 ++++++++++++++++++++++++++++++-----
 1 file changed, 38 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 726a8d2..f5fc7a2 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -444,6 +444,8 @@ static int txq_number = 8;
 
 static int rxq_def;
 
+static int rx_copybreak __read_mostly = 256;
+
 #define MVNETA_DRIVER_NAME "mvneta"
 #define MVNETA_DRIVER_VERSION "1.0"
 
@@ -1463,22 +1465,51 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		rx_done++;
 		rx_filled++;
 		rx_status = rx_desc->status;
+		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		data = (unsigned char *)rx_desc->buf_cookie;
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
-		    (rx_status & MVNETA_RXD_ERR_SUMMARY) ||
-		    !(skb = build_skb(data, pp->frag_size > PAGE_SIZE ? 0 : pp->frag_size))) {
+		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
+		err_drop_frame:
 			dev->stats.rx_errors++;
 			mvneta_rx_error(pp, rx_desc);
 			/* leave the descriptor untouched */
 			continue;
 		}
 
-		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
+		if (rx_bytes <= rx_copybreak) {
+			/* better copy a small frame and not unmap the DMA region */
+			skb = netdev_alloc_skb_ip_align(dev, rx_bytes);
+			if (unlikely(!skb))
+				goto err_drop_frame;
+
+			dma_sync_single_range_for_cpu(dev->dev.parent,
+			                              rx_desc->buf_phys_addr,
+			                              MVNETA_MH_SIZE + NET_SKB_PAD,
+			                              rx_bytes,
+			                              DMA_FROM_DEVICE);
+			memcpy(skb_put(skb, rx_bytes),
+			       data + MVNETA_MH_SIZE + NET_SKB_PAD,
+			       rx_bytes);
+
+			skb->protocol = eth_type_trans(skb, dev);
+			mvneta_rx_csum(pp, rx_status, skb);
+			napi_gro_receive(&pp->napi, skb);
+
+			rcvd_pkts++;
+			rcvd_bytes += rx_bytes;
+
+			/* leave the descriptor and buffer untouched */
+			continue;
+		}
+
+		skb = build_skb(data, pp->frag_size > PAGE_SIZE ? 0 : pp->frag_size);
+		if (!skb)
+			goto err_drop_frame;
+
+		dma_unmap_single(dev->dev.parent, rx_desc->buf_phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 
-		rx_bytes = rx_desc->data_size -
-			(ETH_FCS_LEN + MVNETA_MH_SIZE);
 		rcvd_pkts++;
 		rcvd_bytes += rx_bytes;
 
@@ -1495,7 +1526,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		/* Refill processing */
 		err = mvneta_rx_refill(pp, rx_desc);
 		if (err) {
-			netdev_err(pp->dev, "Linux processing - Can't refill\n");
+			netdev_err(dev, "Linux processing - Can't refill\n");
 			rxq->missed++;
 			rx_filled--;
 		}
@@ -2945,3 +2976,4 @@ module_param(rxq_number, int, S_IRUGO);
 module_param(txq_number, int, S_IRUGO);
 
 module_param(rxq_def, int, S_IRUGO);
+module_param(rx_copybreak, int, S_IRUGO | S_IWUSR);
-- 
1.7.12.2.21.g234cd45.dirty
