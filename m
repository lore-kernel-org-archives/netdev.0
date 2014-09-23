From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 1/4] net: fec: Add Ftype to BD to distiguish three tx queues for AVB
Date: Tue, 23 Sep 2014 15:40:55 +0800
Message-ID: <1411458058-18934-2-git-send-email-b38611@freescale.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0114.outbound.protection.outlook.com ([157.56.111.114]:44193
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753073AbaIWIXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:23:20 -0400
In-Reply-To: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current driver loss Ftype field init for BD, which cause tx
queue #1 and #2 cannot work well.

Add Ftype field to BD to distiguish three queues for AVB:
0 -> Best Effort
1 -> ClassA
2 -> ClassB

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    1 +
 drivers/net/ethernet/freescale/fec_main.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 26fb1de..354a309 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -308,6 +308,7 @@ struct bufdesc_ex {
 #define RCMR_CMP_2		(RCMR_CMP_CFG(4, 0) | RCMR_CMP_CFG(5, 1) | \
 				RCMR_CMP_CFG(6, 2) | RCMR_CMP_CFG(7, 3))
 #define RCMR_CMP(X)		((X == 1) ? RCMR_CMP_1 : RCMR_CMP_2)
+#define FEC_TX_BD_FTYPE(X)	((X & 0xF) << 20)
 
 /* The number of Tx and Rx buffers.  These are allocated from the page
  * pool.  The code may assume these are power of two, so it it best
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3a4ec0f..a0f21ce 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -426,6 +426,8 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 		}
 
 		if (fep->bufdesc_ex) {
+			if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+				estatus |= FEC_TX_BD_FTYPE(queue);
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 			ebdp->cbd_bdu = 0;
@@ -555,6 +557,9 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 			fep->hwts_tx_en))
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
+		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+			estatus |= FEC_TX_BD_FTYPE(queue);
+
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 
@@ -599,6 +604,7 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
+	unsigned short queue = skb_get_queue_mapping(skb);
 	unsigned short status;
 	unsigned int estatus = 0;
 	dma_addr_t addr;
@@ -629,6 +635,8 @@ fec_enet_txq_put_data_tso(struct fec_enet_priv_tx_q *txq, struct sk_buff *skb,
 	bdp->cbd_bufaddr = addr;
 
 	if (fep->bufdesc_ex) {
+		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+			estatus |= FEC_TX_BD_FTYPE(queue);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
@@ -659,6 +667,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 				platform_get_device_id(fep->pdev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
+	unsigned short queue = skb_get_queue_mapping(skb);
 	void *bufaddr;
 	unsigned long dmabuf;
 	unsigned short status;
@@ -692,6 +701,8 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	bdp->cbd_datlen = hdr_len;
 
 	if (fep->bufdesc_ex) {
+		if (id_entry->driver_data & FEC_QUIRK_HAS_AVB)
+			estatus |= FEC_TX_BD_FTYPE(queue);
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			estatus |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		ebdp->cbd_bdu = 0;
-- 
1.7.8
