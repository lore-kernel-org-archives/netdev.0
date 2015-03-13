From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: bcmgenet: use skb_put_padto()
Date: Fri, 13 Mar 2015 15:58:31 -0700
Message-ID: <1426287512-10742-2-git-send-email-f.fainelli@gmail.com>
References: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35940 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757262AbbCMW7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:59:42 -0400
Received: by pdbnh10 with SMTP id nh10so32298535pdb.3
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:59:41 -0700 (PDT)
In-Reply-To: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use skb_pad() to pad small packets, and then we need to enforce again
in bcmgenet_xmit() a check on ETH_ZLEN. Use skb_put_padto() which pads
up to the specified length and also increases skb->len accordingly. Note
that we still need to use skb_headlen() since we might transmitting the
first part out of a train of fragments.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index e74ae628bbb9..cee86c24b35f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1108,8 +1108,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 
 	tx_cb_ptr->skb = skb;
 
-	skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);
-
+	skb_len = skb_headlen(skb);
 	mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
@@ -1272,7 +1271,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	if (skb_padto(skb, ETH_ZLEN)) {
+	if (skb_put_padto(skb, ETH_ZLEN)) {
 		ret = NETDEV_TX_OK;
 		goto out;
 	}
-- 
2.1.0
