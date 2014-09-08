From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: bcmgenet: check harder for out of memory conditions
Date: Mon,  8 Sep 2014 11:37:52 -0700
Message-ID: <1410201472-3764-3-git-send-email-f.fainelli@gmail.com>
References: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34114 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbaIHSiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 14:38:03 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so1745792pad.9
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 11:38:03 -0700 (PDT)
In-Reply-To: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a potential case where we might be failing to refill a
control block, leaving it with both a NULL skb pointer *and* a NULL
dma_unmap_addr.

The way we process incoming packets, by first calling
dma_unmap_single(), and then only checking for a potential NULL skb can
lead to situations where do pass a NULL dma_unmap_addr() to
dma_unmap_single(), resulting in an oops.

Fix this my moving the NULL skb check earlier, since no backing skb
also means no corresponding DMA mapping for this packet.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++++++++++++-----------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 3f9d4de8173c..cdef86a03862 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1274,12 +1274,29 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 	while ((rxpktprocessed < rxpkttoprocess) &&
 	       (rxpktprocessed < budget)) {
+		cb = &priv->rx_cbs[priv->rx_read_ptr];
+		skb = cb->skb;
+
+		rxpktprocessed++;
+
+		priv->rx_read_ptr++;
+		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
+
+		/* We do not have a backing SKB, so we do not have a
+		 * corresponding DMA mapping for this incoming packet since
+		 * bcmgenet_rx_refill always either has both skb and mapping or
+		 * none.
+		 */
+		if (unlikely(!skb)) {
+			dev->stats.rx_dropped++;
+			dev->stats.rx_errors++;
+			goto refill;
+		}
+
 		/* Unmap the packet contents such that we can use the
 		 * RSV from the 64 bytes descriptor when enabled and save
 		 * a 32-bits register read
 		 */
-		cb = &priv->rx_cbs[priv->rx_read_ptr];
-		skb = cb->skb;
 		dma_unmap_single(&dev->dev, dma_unmap_addr(cb, dma_addr),
 				 priv->rx_buf_len, DMA_FROM_DEVICE);
 
@@ -1307,18 +1324,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 			  __func__, p_index, priv->rx_c_index,
 			  priv->rx_read_ptr, dma_length_status);
 
-		rxpktprocessed++;
-
-		priv->rx_read_ptr++;
-		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
-
-		/* out of memory, just drop packets at the hardware level */
-		if (unlikely(!skb)) {
-			dev->stats.rx_dropped++;
-			dev->stats.rx_errors++;
-			goto refill;
-		}
-
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
 				  "dropping fragmented packet!\n");
-- 
1.9.1
