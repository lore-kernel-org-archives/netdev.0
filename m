From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 05/11] fec_mpc52xx: enable transmit and receive time stamping.
Date: Sun, 19 Jun 2011 19:56:58 +0200
Message-ID: <2d0623bf2ee51df919b7a4ae7844fad516c4149d.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Grant Likely <grant.likely@secretlab.ca>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49063 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab1FSR5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 13:57:15 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so1751766bwz.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 10:57:15 -0700 (PDT)
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308499701.git.richard.cochran@omicron.at>
References: <cover.1308499701.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) time stamping. Software
time stamping using the SO_TIMESTAMPING API was tested and found to be
working on the LITE5200B board.

Cc: Grant Likely <grant.likely@secretlab.ca>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/fec_mpc52xx.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 9f81b1a..a4dd6a4 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -335,6 +335,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bd->skb_pa = dma_map_single(dev->dev.parent, skb->data, skb->len,
 				    DMA_TO_DEVICE);
 
+	skb_tx_timestamp(skb);
 	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -434,7 +435,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 		length = status & BCOM_FEC_RX_BD_LEN_MASK;
 		skb_put(rskb, length - 4);	/* length without CRC32 */
 		rskb->protocol = eth_type_trans(rskb, dev);
-		netif_rx(rskb);
+		if (!skb_defer_rx_timestamp(skb))
+			netif_rx(rskb);
 
 		spin_lock(&priv->lock);
 	}
-- 
1.7.0.4

