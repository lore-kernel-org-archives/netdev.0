From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2 v2] net: bcmgenet: fix TX reclaim accounting for fragments
Date: Mon, 22 Sep 2014 11:54:42 -0700
Message-ID: <1411412083-9370-2-git-send-email-f.fainelli@gmail.com>
References: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55833 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbaIVSzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:55:04 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so5068151pab.33
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 11:55:03 -0700 (PDT)
In-Reply-To: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GENET driver supports SKB fragments, and succeeds in transmitting
them properly, but when reclaiming these transmitted fragments, we will
only update the count of free buffer descriptors by 1, even for SKBs
with fragments. This leads to the networking stack thinking it has more
room than the hardware has when pushing new SKBs, and backing off
consequently because we return NETDEV_TX_BUSY.

Fix this by accounting for the SKB nr_frags plus one (itself) and update
ring->free_bds accordingly with that value for each iteration loop in
__bcmgenet_tx_reclaim().

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cdef86a03862..11a96437862d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -875,6 +875,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	int last_tx_cn, last_c_index, num_tx_bds;
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
+	unsigned int bds_compl;
 	unsigned int c_index;
 
 	/* Compute how many buffers are transmitted since last xmit call */
@@ -899,7 +900,9 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	/* Reclaim transmitted buffers */
 	while (last_tx_cn-- > 0) {
 		tx_cb_ptr = ring->cbs + last_c_index;
+		bds_compl = 0;
 		if (tx_cb_ptr->skb) {
+			bds_compl = skb_shinfo(tx_cb_ptr->skb)->nr_frags + 1;
 			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
 			dma_unmap_single(&dev->dev,
 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
@@ -916,7 +919,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 			dma_unmap_addr_set(tx_cb_ptr, dma_addr, 0);
 		}
 		dev->stats.tx_packets++;
-		ring->free_bds += 1;
+		ring->free_bds += bds_compl;
 
 		last_c_index++;
 		last_c_index &= (num_tx_bds - 1);
-- 
1.9.1
