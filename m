From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net] net: bcmgenet: fix accounting of packet drops vs errors
Date: Thu, 09 Jul 2015 01:55:02 +0000
Message-ID: <089e0122a88432eb63051a678bba@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed; delsp=yes
Cc: f.fainelli@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:33164 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbbGIBzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 21:55:04 -0400
Received: by oizz3 with SMTP id z3so95615oiz.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 18:55:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet driver needs to separate packet drops from packet errors.

When the driver has to drop a *good* packet, due to lack of buffers or
replacement skbs, increment only dev->stats.[rx|tx]_dropped.

When the driver encounters a bad Rx packet or Tx error, increment only
dev->stats.[rx|tx]_errors + relevant detailed error counter.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ----
  1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c  
b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index b43b2cb..64c1e9d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1230,7 +1230,6 @@ static struct sk_buff *bcmgenet_put_tx_csum(struct  
net_device *dev,
  		new_skb = skb_realloc_headroom(skb, sizeof(*status));
  		dev_kfree_skb(skb);
  		if (!new_skb) {
-			dev->stats.tx_errors++;
  			dev->stats.tx_dropped++;
  			return NULL;
  		}
@@ -1465,7 +1464,6 @@ static unsigned int bcmgenet_desc_rx(struct  
bcmgenet_rx_ring *ring,

  		if (unlikely(!skb)) {
  			dev->stats.rx_dropped++;
-			dev->stats.rx_errors++;
  			goto next;
  		}

@@ -1493,7 +1491,6 @@ static unsigned int bcmgenet_desc_rx(struct  
bcmgenet_rx_ring *ring,
  		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
  			netif_err(priv, rx_status, dev,
  				  "dropping fragmented packet!\n");
-			dev->stats.rx_dropped++;
  			dev->stats.rx_errors++;
  			dev_kfree_skb_any(skb);
  			goto next;
@@ -1515,7 +1512,6 @@ static unsigned int bcmgenet_desc_rx(struct  
bcmgenet_rx_ring *ring,
  				dev->stats.rx_frame_errors++;
  			if (dma_flag & DMA_RX_LG)
  				dev->stats.rx_length_errors++;
-			dev->stats.rx_dropped++;
  			dev->stats.rx_errors++;
  			dev_kfree_skb_any(skb);
  			goto next;
-- 
2.4.3.573.g4eafbef
