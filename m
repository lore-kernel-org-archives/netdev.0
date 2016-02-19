From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/3] gianfar: Use skb_frag_t pointers inside xmit()
Date: Fri, 19 Feb 2016 12:47:33 +0200
Message-ID: <1455878854-28290-3-git-send-email-claudiu.manoil@freescale.com>
References: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0147.outbound.protection.outlook.com ([65.55.169.147]:55314
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1426794AbcBSLJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 06:09:50 -0500
In-Reply-To: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 43fbded..090f4f0 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2322,6 +2322,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct txfcb *fcb = NULL;
 	struct txbd8 *txbdp, *txbdp_start, *base, *txbdp_tstamp = NULL;
 	u32 lstatus;
+	skb_frag_t *frag;
 	int i, rq = 0;
 	int do_tstamp, do_csum, do_vlan;
 	u32 bufaddr;
@@ -2448,25 +2449,24 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		u32 lstatus_start = lstatus;
 
 		/* Place the fragment addresses and lengths into the TxBDs */
-		for (i = 0; i < nr_frags; i++) {
-			unsigned int frag_len;
+		frag = &skb_shinfo(skb)->frags[0];
+		for (i = 0; i < nr_frags; i++, frag++) {
+			unsigned int size;
+
 			/* Point at the next BD, wrapping as needed */
 			txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 
-			frag_len = skb_shinfo(skb)->frags[i].size;
+			size = skb_frag_size(frag);
 
-			lstatus = be32_to_cpu(txbdp->lstatus) | frag_len |
+			lstatus = be32_to_cpu(txbdp->lstatus) | size |
 				  BD_LFLAG(TXBD_READY);
 
 			/* Handle the last BD specially */
 			if (i == nr_frags - 1)
 				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
-			bufaddr = skb_frag_dma_map(priv->dev,
-						   &skb_shinfo(skb)->frags[i],
-						   0,
-						   frag_len,
-						   DMA_TO_DEVICE);
+			bufaddr = skb_frag_dma_map(priv->dev, frag, 0,
+						   size, DMA_TO_DEVICE);
 			if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
 				goto dma_map_err;
 
-- 
1.7.11.7
