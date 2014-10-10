From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 1/3] net: bcmgenet: fix off-by-one in incrementing read pointer
Date: Fri, 10 Oct 2014 10:51:52 -0700
Message-ID: <1412963514-7718-2-git-send-email-f.fainelli@gmail.com>
References: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40510 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaJJRwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:52:08 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2169365pab.2
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 10:52:08 -0700 (PDT)
In-Reply-To: <1412963514-7718-1-git-send-email-f.fainelli@gmail.com>
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
Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- moved the rxpktprocessed and rx_read_ptr increment after refiling the control
  block

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fff2634b6f34..fdc9ec09e453 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1285,11 +1285,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 		cb = &priv->rx_cbs[priv->rx_read_ptr];
 		skb = cb->skb;
 
-		rxpktprocessed++;
-
-		priv->rx_read_ptr++;
-		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
-
 		/* We do not have a backing SKB, so we do not have a
 		 * corresponding DMA mapping for this incoming packet since
 		 * bcmgenet_rx_refill always either has both skb and mapping or
@@ -1404,6 +1399,10 @@ refill:
 		err = bcmgenet_rx_refill(priv, cb);
 		if (err)
 			netif_err(priv, rx_err, dev, "Rx refill failed\n");
+
+		rxpktprocessed++;
+		priv->rx_read_ptr++;
+		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
 	}
 
 	return rxpktprocessed;
-- 
1.9.1
