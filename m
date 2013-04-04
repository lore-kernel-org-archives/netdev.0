From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: [PATCH 2/2] at86rf230:  change irq handling to prevent lockups with edge type irq
Date: Thu,  4 Apr 2013 23:02:01 +0200
Message-ID: <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Sascha Herrmann <sascha@ps.nvbi.de>
To: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:59955 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762746Ab3DDVCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:02:41 -0400
In-Reply-To: <cover.1365107512.git.sascha@ps.nvbi.de>
In-Reply-To: <cover.1365107512.git.sascha@ps.nvbi.de>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hard code the interrupt type of the at86rf230 to rising edge type and
remove the calls to disable_irq_nosync() and enable_irq() from the
isr and the irqwork function. The at86rf230 resets the irq line only
after the irq status register is read. Disabling the irq can lock the
driver in situations where a irq is set by the radio while the driver
is still reading the frame buffer. Additional the irq filter register
is set to filter out all unused interrupts and the irq status register
is read in the probe function to clear the irq line.

Signed-off-by: Sascha Herrmann <sascha@ps.nvbi.de>
---
 drivers/net/ieee802154/at86rf230.c |   29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index fc315dd..eb5359f 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -51,7 +51,7 @@ struct at86rf230_local {
 	struct ieee802154_dev *dev;
 
 	spinlock_t lock;
-	bool irq_disabled;
+	bool irq_busy;
 	bool is_tx;
 };
 
@@ -544,7 +544,7 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	unsigned long flags;
 
 	spin_lock(&lp->lock);
-	if  (lp->irq_disabled) {
+	if  (lp->irq_busy) {
 		spin_unlock(&lp->lock);
 		return -EBUSY;
 	}
@@ -705,20 +705,16 @@ static void at86rf230_irqwork(struct work_struct *work)
 	}
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->irq_disabled = 0;
+	lp->irq_busy = 0;
 	spin_unlock_irqrestore(&lp->lock, flags);
-
-	enable_irq(lp->spi->irq);
 }
 
 static irqreturn_t at86rf230_isr(int irq, void *data)
 {
 	struct at86rf230_local *lp = data;
 
-	disable_irq_nosync(irq);
-
 	spin_lock(&lp->lock);
-	lp->irq_disabled = 1;
+	lp->irq_busy = 1;
 	spin_unlock(&lp->lock);
 
 	schedule_work(&lp->irqwork);
@@ -748,12 +744,7 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		dev_info(&lp->spi->dev, "Status: %02x\n", status);
 	}
 
-	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, 0xff); /* IRQ_TRX_UR |
-							     * IRQ_CCA_ED |
-							     * IRQ_TRX_END |
-							     * IRQ_PLL_UNL |
-							     * IRQ_PLL_LOCK
-							     */
+	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, IRQ_TRX_END);
 	if (rc)
 		return rc;
 
@@ -819,7 +810,7 @@ static int at86rf230_probe(struct spi_device *spi)
 {
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
-	u8 man_id_0, man_id_1;
+	u8 man_id_0, man_id_1, status;
 	int rc;
 	const char *chip;
 	int supported = 0;
@@ -928,11 +919,17 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc)
 		goto err_gpio_dir;
 
-	rc = request_irq(spi->irq, at86rf230_isr, IRQF_SHARED,
+	rc = request_irq(spi->irq, at86rf230_isr,
+			 IRQF_SHARED | IRQF_TRIGGER_RISING,
 			 dev_name(&spi->dev), lp);
 	if (rc)
 		goto err_gpio_dir;
 
+	/* Read irq status register to reset irq line */
+	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &status);
+	if (rc)
+		goto err_irq;
+
 	rc = ieee802154_register_device(lp->dev);
 	if (rc)
 		goto err_irq;
-- 
1.7.10.4
