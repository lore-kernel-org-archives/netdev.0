From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 05/12] pcnet32: use napi_complete_done()
Date: Sat,  4 Feb 2017 15:24:55 -0800
Message-ID: <20170204232502.22361-6-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35084 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdBDXZe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:34 -0500
Received: by mail-pg0-f47.google.com with SMTP id 194so17053868pgd.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:24 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 41e58cca8feed284391d91f7469eaf4b79e5..a8a22c0d688a359fa977ffaf03da06bfc698 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1350,13 +1350,8 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 		pcnet32_restart(dev, CSR0_START);
 		netif_wake_queue(dev);
 	}
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	if (work_done < budget) {
-		spin_lock_irqsave(&lp->lock, flags);
-
-		__napi_complete(napi);
 
+	if (work_done < budget && napi_complete_done(napi, work_done)) {
 		/* clear interrupt masks */
 		val = lp->a->read_csr(ioaddr, CSR3);
 		val &= 0x00ff;
@@ -1364,9 +1359,9 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 
 		/* Set interrupt enable. */
 		lp->a->write_csr(ioaddr, CSR0, CSR0_INTEN);
-
-		spin_unlock_irqrestore(&lp->lock, flags);
 	}
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 	return work_done;
 }
 
-- 
2.11.0.483.g087da7b7c-goog
