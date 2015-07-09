From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/4] gianfar: Fix and cleanup rxbd status handling
Date: Thu, 9 Jul 2015 19:24:42 +0300
Message-ID: <1436459084-14103-3-git-send-email-claudiu.manoil@freescale.com>
References: <1436459084-14103-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0116.outbound.protection.outlook.com ([65.55.169.116]:13920
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751125AbbGIQ0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 12:26:36 -0400
In-Reply-To: <1436459084-14103-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several (long standing) problems about how the status
field of the rx buffer descriptor (rxbd) is currently handled on
the error path:
- too many unnecessary 16bit reads of the two halves of the rxbd
status field (32bit), also resulting in overuse of endianness
convesion macros;
- "bdp->status = RXBD_LARGE" makes no sense, since the "large"
flag is read only (only eTSEC can write it), and trying to clear
the other status bits is also error prone in this context
(most of the rx status bits are read only anyway).

This is fixed with a single 32bit read of the "status" field,
and then the appropriate 16bit shifting is applied to access
the various status bits or the rx frame length. Also corrected
the use of the RXBD_LARGE flag.

Additional fix:
"rx_over_errors" stat is incremented instead of "rx_crc_errors"
in case of RXBD_OVERRUN occurrence.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 34 +++++++++++++++++---------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index b35bf3d..b25cccd 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2756,14 +2756,14 @@ static void gfar_alloc_rx_buffs(struct gfar_priv_rx_q *rx_queue,
 	rx_queue->next_to_use = i;
 }
 
-static inline void count_errors(unsigned short status, struct net_device *dev)
+static void count_errors(unsigned long lstatus, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
 	/* If the packet was truncated, none of the other errors matter */
-	if (status & RXBD_TRUNCATED) {
+	if (lstatus & BD_LFLAG(RXBD_TRUNCATED)) {
 		stats->rx_length_errors++;
 
 		atomic64_inc(&estats->rx_trunc);
@@ -2771,25 +2771,25 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 		return;
 	}
 	/* Count the errors, if there were any */
-	if (status & (RXBD_LARGE | RXBD_SHORT)) {
+	if (lstatus & BD_LFLAG(RXBD_LARGE | RXBD_SHORT)) {
 		stats->rx_length_errors++;
 
-		if (status & RXBD_LARGE)
+		if (lstatus & BD_LFLAG(RXBD_LARGE))
 			atomic64_inc(&estats->rx_large);
 		else
 			atomic64_inc(&estats->rx_short);
 	}
-	if (status & RXBD_NONOCTET) {
+	if (lstatus & BD_LFLAG(RXBD_NONOCTET)) {
 		stats->rx_frame_errors++;
 		atomic64_inc(&estats->rx_nonoctet);
 	}
-	if (status & RXBD_CRCERR) {
+	if (lstatus & BD_LFLAG(RXBD_CRCERR)) {
 		atomic64_inc(&estats->rx_crcerr);
 		stats->rx_crc_errors++;
 	}
-	if (status & RXBD_OVERRUN) {
+	if (lstatus & BD_LFLAG(RXBD_OVERRUN)) {
 		atomic64_inc(&estats->rx_overrun);
-		stats->rx_crc_errors++;
+		stats->rx_over_errors++;
 	}
 }
 
@@ -2921,6 +2921,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	i = rx_queue->next_to_clean;
 
 	while (rx_work_limit--) {
+		unsigned long lstatus;
 
 		if (cleaned_cnt >= GFAR_RX_BUFF_ALLOC) {
 			gfar_alloc_rx_buffs(rx_queue, cleaned_cnt);
@@ -2928,7 +2929,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		}
 
 		bdp = &rx_queue->rx_bd_base[i];
-		if (be16_to_cpu(bdp->status) & RXBD_EMPTY)
+		lstatus = be32_to_cpu(bdp->lstatus);
+		if (lstatus & BD_LFLAG(RXBD_EMPTY))
 			break;
 
 		/* order rx buffer descriptor reads */
@@ -2940,13 +2942,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		dma_unmap_single(priv->dev, be32_to_cpu(bdp->bufPtr),
 				 priv->rx_buffer_size, DMA_FROM_DEVICE);
 
-		if (unlikely(!(be16_to_cpu(bdp->status) & RXBD_ERR) &&
-			     be16_to_cpu(bdp->length) > priv->rx_buffer_size))
-			bdp->status = cpu_to_be16(RXBD_LARGE);
+		if (unlikely(!(lstatus & BD_LFLAG(RXBD_ERR)) &&
+			     (lstatus & BD_LENGTH_MASK) > priv->rx_buffer_size))
+			lstatus |= BD_LFLAG(RXBD_LARGE);
 
-		if (unlikely(!(be16_to_cpu(bdp->status) & RXBD_LAST) ||
-			     be16_to_cpu(bdp->status) & RXBD_ERR)) {
-			count_errors(be16_to_cpu(bdp->status), dev);
+		if (unlikely(!(lstatus & BD_LFLAG(RXBD_LAST)) ||
+			     (lstatus & BD_LFLAG(RXBD_ERR)))) {
+			count_errors(lstatus, dev);
 
 			/* discard faulty buffer */
 			dev_kfree_skb(skb);
@@ -2957,7 +2959,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			howmany++;
 
 			if (likely(skb)) {
-				int pkt_len = be16_to_cpu(bdp->length) -
+				int pkt_len = (lstatus & BD_LENGTH_MASK) -
 					  ETH_FCS_LEN;
 				/* Remove the FCS from the packet length */
 				skb_put(skb, pkt_len);
-- 
1.7.11.7
