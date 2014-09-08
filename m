From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: systemport: check harder for out of memory conditions
Date: Mon,  8 Sep 2014 11:37:51 -0700
Message-ID: <1410201472-3764-2-git-send-email-f.fainelli@gmail.com>
References: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38617 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaIHSiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 14:38:03 -0400
Received: by mail-pd0-f170.google.com with SMTP id r10so21517276pdi.15
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 11:38:02 -0700 (PDT)
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
 drivers/net/ethernet/broadcom/bcmsysport.c | 31 ++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 6f4e18644bd4..d9b9170ed2fc 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -534,6 +534,25 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	while ((processed < to_process) && (processed < budget)) {
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
 		skb = cb->skb;
+
+		processed++;
+		priv->rx_read_ptr++;
+
+		if (priv->rx_read_ptr == priv->num_rx_bds)
+			priv->rx_read_ptr = 0;
+
+		/* We do not have a backing SKB, so we do not a corresponding
+		 * DMA mapping for this incoming packet since
+		 * bcm_sysport_rx_refill always either has both skb and mapping
+		 * or none.
+		 */
+		if (unlikely(!skb)) {
+			netif_err(priv, rx_err, ndev, "out of memory!\n");
+			ndev->stats.rx_dropped++;
+			ndev->stats.rx_errors++;
+			goto refill;
+		}
+
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
 				 RX_BUF_LENGTH, DMA_FROM_DEVICE);
 
@@ -543,23 +562,11 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		status = (rsb->rx_status_len >> DESC_STATUS_SHIFT) &
 			  DESC_STATUS_MASK;
 
-		processed++;
-		priv->rx_read_ptr++;
-		if (priv->rx_read_ptr == priv->num_rx_bds)
-			priv->rx_read_ptr = 0;
-
 		netif_dbg(priv, rx_status, ndev,
 			  "p=%d, c=%d, rd_ptr=%d, len=%d, flag=0x%04x\n",
 			  p_index, priv->rx_c_index, priv->rx_read_ptr,
 			  len, status);
 
-		if (unlikely(!skb)) {
-			netif_err(priv, rx_err, ndev, "out of memory!\n");
-			ndev->stats.rx_dropped++;
-			ndev->stats.rx_errors++;
-			goto refill;
-		}
-
 		if (unlikely(!(status & DESC_EOP) || !(status & DESC_SOP))) {
 			netif_err(priv, rx_status, ndev, "fragmented packet!\n");
 			ndev->stats.rx_dropped++;
-- 
1.9.1
