From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 10/12] ibm/emac: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:25:00 -0800
Message-ID: <20170204232502.22361-11-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36412 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdBDXZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:29 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so14411370pfu.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:28 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete()

We plan to remove __napi_complete() to reduce NAPI complexity.
---
 drivers/net/ethernet/ibm/emac/mal.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index aaf6fec566b5175a834c74cee494ebcf13e1..cd3227b088b73f51b68951401eefc7e2d1e1 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -421,20 +421,20 @@ static int mal_poll(struct napi_struct *napi, int budget)
 		int n;
 		if (unlikely(test_bit(MAL_COMMAC_POLL_DISABLED, &mc->flags)))
 			continue;
-		n = mc->ops->poll_rx(mc->dev, budget);
+		n = mc->ops->poll_rx(mc->dev, budget - received);
 		if (n) {
 			received += n;
-			budget -= n;
-			if (budget <= 0)
-				goto more_work; // XXX What if this is the last one ?
+			if (received >= budget)
+				return budget;
 		}
 	}
 
-	/* We need to disable IRQs to protect from RXDE IRQ here */
-	spin_lock_irqsave(&mal->lock, flags);
-	__napi_complete(napi);
-	mal_enable_eob_irq(mal);
-	spin_unlock_irqrestore(&mal->lock, flags);
+	if (napi_complete_done(napi, received)) {
+		/* We need to disable IRQs to protect from RXDE IRQ here */
+		spin_lock_irqsave(&mal->lock, flags);
+		mal_enable_eob_irq(mal);
+		spin_unlock_irqrestore(&mal->lock, flags);
+	}
 
 	/* Check for "rotting" packet(s) */
 	list_for_each(l, &mal->poll_list) {
-- 
2.11.0.483.g087da7b7c-goog
