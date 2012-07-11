From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 2/7] drivers/ieee802154/at86rf230: rework irq handler
Date: Wed, 11 Jul 2012 11:22:43 +0400
Message-ID: <1341991368-11800-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55363 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab2GKH0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:26:55 -0400
Received: by wibhm11 with SMTP id hm11so5385691wib.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:26:54 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix LOCKDEP bug message for the irq handler spinlock.
Make the irq processing code more explicit and stable.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/ieee802154/at86rf230.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/ieee802154/at86rf230.c b/drivers/ieee802154/at86rf230.c
index 902e38b..5d30940 100644
--- a/drivers/ieee802154/at86rf230.c
+++ b/drivers/ieee802154/at86rf230.c
@@ -543,6 +543,13 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	int rc;
 	unsigned long flags;
 
+	spin_lock(&lp->lock);
+	if  (lp->irq_disabled) {
+		spin_unlock(&lp->lock);
+		return -EBUSY;
+	}
+	spin_unlock(&lp->lock);
+
 	might_sleep();
 
 	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
@@ -592,12 +599,8 @@ static int at86rf230_rx(struct at86rf230_local *lp)
 	if (!skb)
 		return -ENOMEM;
 
-	if (at86rf230_write_subreg(lp, SR_RX_PDT_DIS, 1) ||
-	    at86rf230_read_fbuf(lp, skb_put(skb, len), &len, &lqi) ||
-	    at86rf230_write_subreg(lp, SR_RX_SAFE_MODE, 1) ||
-	    at86rf230_write_subreg(lp, SR_RX_PDT_DIS, 0)) {
+	if (at86rf230_read_fbuf(lp, skb_put(skb, len), &len, &lqi))
 		goto err;
-	}
 
 	if (len < 2)
 		goto err;
@@ -633,7 +636,6 @@ static void at86rf230_irqwork(struct work_struct *work)
 	int rc;
 	unsigned long flags;
 
-	spin_lock_irqsave(&lp->lock, flags);
 	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &val);
 	status |= val;
 
@@ -643,31 +645,33 @@ static void at86rf230_irqwork(struct work_struct *work)
 	status &= ~IRQ_TRX_UR; /* FIXME: possibly handle ???*/
 
 	if (status & IRQ_TRX_END) {
+		spin_lock_irqsave(&lp->lock, flags);
 		status &= ~IRQ_TRX_END;
 		if (lp->is_tx) {
 			lp->is_tx = 0;
+			spin_unlock_irqrestore(&lp->lock, flags);
 			complete(&lp->tx_complete);
 		} else {
+			spin_unlock_irqrestore(&lp->lock, flags);
 			at86rf230_rx(lp);
 		}
 	}
 
-	if (lp->irq_disabled) {
-		lp->irq_disabled = 0;
-		enable_irq(lp->spi->irq);
-	}
+	spin_lock_irqsave(&lp->lock, flags);
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
