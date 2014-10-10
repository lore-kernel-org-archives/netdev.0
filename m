From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: bcmgenet: fix off-by-one in incrementing read pointer
Date: Thu,  9 Oct 2014 18:06:35 -0700
Message-ID: <1412903197-19193-2-git-send-email-f.fainelli@gmail.com>
References: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57567 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaJJBGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:06:55 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so696947pab.4
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:06:54 -0700 (PDT)
In-Reply-To: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b629be5c8399d7c423b92135eb43a86c924d1cbc ("net: bcmgenet: check
harder for out of memory conditions") moved the increment of the local
read pointer *before* reading from the hardware descriptor using
dmadesc_get_length_status(), which creates an off-by-one situation.

Fix this by moving again the read_ptr increment after we have read the
hardware descriptor to get both the control block and the read pointer
back in sync.

Fixes: b629be5c8399 ("net: bcmgenet: check harder for out of memory conditions")
Reported-by: Jaedon Shin <jaedon.shin@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fff2634b6f34..f1bcebcbba80 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1287,9 +1287,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 		rxpktprocessed++;
 
-		priv->rx_read_ptr++;
-		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
-
 		/* We do not have a backing SKB, so we do not have a
 		 * corresponding DMA mapping for this incoming packet since
 		 * bcmgenet_rx_refill always either has both skb and mapping or
@@ -1332,6 +1329,9 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 			  __func__, p_index, priv->rx_c_index,
 			  priv->rx_read_ptr, dma_length_status);
 
+		priv->rx_read_ptr++;
+		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
+
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
 				  "dropping fragmented packet!\n");
-- 
1.9.1
