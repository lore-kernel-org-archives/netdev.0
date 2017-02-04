From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 8/9] ks8695net: add GRO support
Date: Sat,  4 Feb 2017 10:20:37 -0800
Message-ID: <20170204182038.3752-9-edumazet@google.com>
References: <20170204182038.3752-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34117 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdBDSVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 13:21:33 -0500
Received: by mail-pg0-f50.google.com with SMTP id 14so15912021pgg.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 10:21:33 -0800 (PST)
In-Reply-To: <20170204182038.3752-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.

Note that rx_lock seems to be useless, NAPI logic should
not need this extra care.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/micrel/ks8695net.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 20cb85bc0c5f8660a259dfb8dfd7213df713..f155e21240120061831fecb3537059cf4641 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -519,7 +519,7 @@ static int ks8695_rx(struct ks8695_priv *ksp, int budget)
 			/* Relinquish the SKB to the network layer */
 			skb_put(skb, pktlen);
 			skb->protocol = eth_type_trans(skb, ndev);
-			netif_receive_skb(skb);
+			napi_gro_receive(&ksp->napi, skb);
 
 			/* Record stats */
 			ndev->stats.rx_packets++;
@@ -561,18 +561,17 @@ static int ks8695_rx(struct ks8695_priv *ksp, int budget)
 static int ks8695_poll(struct napi_struct *napi, int budget)
 {
 	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
-	unsigned long  work_done;
-
 	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
 	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);
+	int work_done;
 
 	work_done = ks8695_rx(ksp, budget);
 
-	if (work_done < budget) {
+	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
 		unsigned long flags;
+
 		spin_lock_irqsave(&ksp->rx_lock, flags);
-		__napi_complete(napi);
-		/*enable rx interrupt*/
+		/* enable rx interrupt */
 		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
 		spin_unlock_irqrestore(&ksp->rx_lock, flags);
 	}
-- 
2.11.0.483.g087da7b7c-goog
