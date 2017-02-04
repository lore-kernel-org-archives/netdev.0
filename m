From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/9] ep93xx_eth: add GRO support
Date: Sat,  4 Feb 2017 10:20:35 -0800
Message-ID: <20170204182038.3752-7-edumazet@google.com>
References: <20170204182038.3752-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34113 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdBDSV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 13:21:27 -0500
Received: by mail-pg0-f46.google.com with SMTP id 14so15911700pgg.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 10:21:27 -0800 (PST)
In-Reply-To: <20170204182038.3752-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.
4) get rid of baroque code and ease maintenance.

In particular, this driver used napi_reschedule() in
a way that would defeat NAPI poll budget control and
would lead to potential infinite loop.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c | 24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 396c88678eabfec556536ca4a81f86224563..bb34a3d0ea446256bd025b006b201581c257 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -294,7 +294,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 			skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, dev);
 
-			netif_receive_skb(skb);
+			napi_gro_receive(&ep->napi, skb);
 
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += length;
@@ -310,35 +310,17 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 	return processed;
 }
 
-static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
-{
-	struct ep93xx_rstat *rstat = ep->descs->rstat + ep->rx_pointer;
-	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
-}
-
 static int ep93xx_poll(struct napi_struct *napi, int budget)
 {
 	struct ep93xx_priv *ep = container_of(napi, struct ep93xx_priv, napi);
 	struct net_device *dev = ep->dev;
-	int rx = 0;
+	int rx;
 
-poll_some_more:
 	rx = ep93xx_rx(dev, rx, budget);
-	if (rx < budget) {
-		int more = 0;
-
+	if ((rx < budget) && napi_complete_done(napi, rx)) {
 		spin_lock_irq(&ep->rx_lock);
-		__napi_complete(napi);
 		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
-		if (ep93xx_have_more_rx(ep)) {
-			wrl(ep, REG_INTEN, REG_INTEN_TX);
-			wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
-			more = 1;
-		}
 		spin_unlock_irq(&ep->rx_lock);
-
-		if (more && napi_reschedule(napi))
-			goto poll_some_more;
 	}
 
 	if (rx) {
-- 
2.11.0.483.g087da7b7c-goog
