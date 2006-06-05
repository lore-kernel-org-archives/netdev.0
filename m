From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 1/3] tg3: Remove unnecessary tx_lock
Date: Mon, 05 Jun 2006 12:47:23 -0700
Message-ID: <1149536843.13155.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:44303 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1750904AbWFEV1w
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 17:27:52 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove tx_lock where it is unnecessary. tg3 runs lockless and so it
requires interrupts to be disabled and sync'ed, netif_queue and NAPI
poll to be stopped before the device can be reconfigured. After
stopping everything, it is no longer necessary to get the tx_lock.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f2382aa..4cda2af 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2984,9 +2984,7 @@ static void tg3_tx_recover(struct tg3 *t
 	       "and include system chipset information.\n", tp->dev->name);
 
 	spin_lock(&tp->lock);
-	spin_lock(&tp->tx_lock);
 	tp->tg3_flags |= TG3_FLAG_TX_RECOVERY_PENDING;
-	spin_unlock(&tp->tx_lock);
 	spin_unlock(&tp->lock);
 }
 
@@ -3429,12 +3427,10 @@ static inline void tg3_full_lock(struct 
 	if (irq_sync)
 		tg3_irq_quiesce(tp);
 	spin_lock_bh(&tp->lock);
-	spin_lock(&tp->tx_lock);
 }
 
 static inline void tg3_full_unlock(struct tg3 *tp)
 {
-	spin_unlock(&tp->tx_lock);
 	spin_unlock_bh(&tp->lock);
 }
 


