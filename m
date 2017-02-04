From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 01/12] 8139too: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:24:51 -0800
Message-ID: <20170204232502.22361-2-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36402 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBDXZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:10 -0500
Received: by mail-pf0-f180.google.com with SMTP id 189so14410639pfu.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:10 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/realtek/8139too.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 5ad59c6d29a46a036a6b1d70e77ae288d9fe..89631753e79962d91456d93b71929af76891 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2135,14 +2135,10 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 	if (likely(RTL_R16(IntrStatus) & RxAckBits))
 		work_done += rtl8139_rx(dev, tp, budget);
 
-	if (work_done < budget) {
+	if (work_done < budget && napi_complete_done(napi, work_done)) {
 		unsigned long flags;
-		/*
-		 * Order is important since data can get interrupted
-		 * again when we think we are done.
-		 */
+
 		spin_lock_irqsave(&tp->lock, flags);
-		__napi_complete(napi);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
-- 
2.11.0.483.g087da7b7c-goog
