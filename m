From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bcmgenet: add support for xmit_more
Date: Mon,  9 Mar 2015 14:52:17 -0700
Message-ID: <1425937937-26955-3-git-send-email-f.fainelli@gmail.com>
References: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35727 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbbCIVww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:52:52 -0400
Received: by pdbfp1 with SMTP id fp1so46858166pdb.2
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:52:51 -0700 (PDT)
In-Reply-To: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delay the update of the TDMA producer index unless this is the last SKB in a
batch, or the queue is already stopped.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9b3b8a3db59b..8419826da6a7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1316,8 +1316,10 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod_index += nr_frags + 1;
 	ring->prod_index &= DMA_P_INDEX_MASK;
 
-	bcmgenet_tdma_ring_writel(priv, ring->index,
-				  ring->prod_index, TDMA_PROD_INDEX);
+	if (!skb->xmit_more || netif_xmit_stopped(txq))
+		/* Packets are ready, update producer index */
+		bcmgenet_tdma_ring_writel(priv, ring->index,
+					  ring->prod_index, TDMA_PROD_INDEX);
 
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
 		netif_tx_stop_queue(txq);
-- 
2.1.0
