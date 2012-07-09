From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 2/6] drivers/ieee802154/at86rf230: rework irq handler
Date: Mon,  9 Jul 2012 14:22:27 +0400
Message-ID: <1341829351-18485-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab2GIK0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:26:38 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so5787740bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:26:37 -0700 (PDT)
In-Reply-To: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix LOCKDEP bug message for the irq handler spinlock.
Make the irq processing code more explicit and stable.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/ieee802154/at86rf230.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/ieee802154/at86rf230.c b/drivers/ieee802154/at86rf230.c
index 902e38b..17b8320 100644
--- a/drivers/ieee802154/at86rf230.c
+++ b/drivers/ieee802154/at86rf230.c
@@ -652,22 +652,20 @@ static void at86rf230_irqwork(struct work_struct *work)
 		}
 	}
 
-	if (lp->irq_disabled) {
-		lp->irq_disabled = 0;
-		enable_irq(lp->spi->irq);
-	}
+	lp->irq_disabled = 0;
 	spin_unlock_irqrestore(&lp->lock, flags);
+
+	enable_irq(lp->spi->irq);
 }
 
 static irqreturn_t at86rf230_isr(int irq, void *data)
 {
 	struct at86rf230_local *lp = data;
 
+	disable_irq_nosync(irq);
+
 	spin_lock(&lp->lock);
-	if (!lp->irq_disabled) {
-		disable_irq_nosync(irq);
-		lp->irq_disabled = 1;
-	}
+	lp->irq_disabled = 1;
 	spin_unlock(&lp->lock);
 
 	schedule_work(&lp->irqwork);
-- 
1.7.2.3
