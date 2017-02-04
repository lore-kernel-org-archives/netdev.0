From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 02/12] 8139cp: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:24:52 -0800
Message-ID: <20170204232502.22361-3-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35079 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdBDXZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:13 -0500
Received: by mail-pg0-f48.google.com with SMTP id 194so17053393pgd.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:12 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.
4) Eventually get rid of napi_gro_flush() in the future.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/realtek/8139cp.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 0b3cd58093d5ecf00abef6eda1386f13ac5e..672f6b696069ad8b47989ecb1dd03d3a81fd 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -465,10 +465,8 @@ static int cp_rx_poll(struct napi_struct *napi, int budget)
 	struct cp_private *cp = container_of(napi, struct cp_private, napi);
 	struct net_device *dev = cp->dev;
 	unsigned int rx_tail = cp->rx_tail;
-	int rx;
+	int rx = 0;
 
-	rx = 0;
-rx_status_loop:
 	cpw16(IntrStatus, cp_rx_intr_mask);
 
 	while (rx < budget) {
@@ -556,15 +554,10 @@ static int cp_rx_poll(struct napi_struct *napi, int budget)
 	/* if we did not reach work limit, then we're done with
 	 * this round of polling
 	 */
-	if (rx < budget) {
+	if (rx < budget && napi_complete_done(napi, rx)) {
 		unsigned long flags;
 
-		if (cpr16(IntrStatus) & cp_rx_intr_mask)
-			goto rx_status_loop;
-
-		napi_gro_flush(napi, false);
 		spin_lock_irqsave(&cp->lock, flags);
-		__napi_complete(napi);
 		cpw16_f(IntrMask, cp_intr_mask);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
-- 
2.11.0.483.g087da7b7c-goog
