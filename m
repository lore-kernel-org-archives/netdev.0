From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: [PATCH 2/2 v3] at86rf230: change irq handling to prevent lockups with edge type irq
Date: Mon, 15 Apr 2013 10:33:29 +0200
Message-ID: <a9815d3882fd9574776de66a4e08451f9fabc184.1366012862.git.sascha@ps.nvbi.de>
References: <cover.1366012862.git.sascha@ps.nvbi.de>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Sascha Herrmann <sascha@ps.nvbi.de>
To: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:49294 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933045Ab3DOIeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 04:34:01 -0400
In-Reply-To: <cover.1366012862.git.sascha@ps.nvbi.de>
In-Reply-To: <cover.1366012862.git.sascha@ps.nvbi.de>
References: <cover.1366012862.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implemented separate irq handling for edge and level type interrupt
configuration. For edge type interrupts calls to disable_irq_nosync()
and enable_irq() are removed. The at86rf230 resets the irq line only
after the irq status register is read. Disabling the irq can lock the
driver in situations where a irq is set by the radio while the driver
is still reading the frame buffer.

With irq_type configuration set to 0 the original behavior is
preserverd.

Additional the irq filter register is set to filter out all unused
interrupts and the irq status register is read in the probe
function to clear the irq line.

Signed-off-by: Sascha Herrmann <sascha@ps.nvbi.de>

Conflicts:
	drivers/net/ieee802154/at86rf230.c
---
 drivers/net/ieee802154/at86rf230.c |   53 ++++++++++++++++++++++++++----------
 1 file changed, 38 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index cf09888..6f10b49 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -51,7 +51,7 @@ struct at86rf230_local {
 	struct ieee802154_dev *dev;
 
 	spinlock_t lock;
-	bool irq_disabled;
+	bool irq_busy;
 	bool is_tx;
 };
 
@@ -547,7 +547,7 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 	unsigned long flags;
 
 	spin_lock(&lp->lock);
-	if  (lp->irq_disabled) {
+	if  (lp->irq_busy) {
 		spin_unlock(&lp->lock);
 		return -EBUSY;
 	}
@@ -708,8 +708,16 @@ static void at86rf230_irqwork(struct work_struct *work)
 	}
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->irq_disabled = 0;
+	lp->irq_busy = 0;
 	spin_unlock_irqrestore(&lp->lock, flags);
+}
+
+static void at86rf230_irqwork_level(struct work_struct *work)
+{
+	struct at86rf230_local *lp =
+		container_of(work, struct at86rf230_local, irqwork);
+
+	at86rf230_irqwork(work);
 
 	enable_irq(lp->spi->irq);
 }
@@ -718,10 +726,8 @@ static irqreturn_t at86rf230_isr(int irq, void *data)
 {
 	struct at86rf230_local *lp = data;
 
-	disable_irq_nosync(irq);
-
 	spin_lock(&lp->lock);
-	lp->irq_disabled = 1;
+	lp->irq_busy = 1;
 	spin_unlock(&lp->lock);
 
 	schedule_work(&lp->irqwork);
@@ -729,6 +735,13 @@ static irqreturn_t at86rf230_isr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t at86rf230_isr_level(int irq, void *data)
+{
+	disable_irq_nosync(irq);
+
+	return at86rf230_isr(irq, data);
+}
+
 static int at86rf230_irq_polarity(struct at86rf230_local *lp, int pol)
 {
 	return at86rf230_write_subreg(lp, SR_IRQ_POLARITY, pol);
@@ -766,12 +779,7 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	if (rc)
 		return rc;
 
-	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, 0xff); /* IRQ_TRX_UR |
-							     * IRQ_CCA_ED |
-							     * IRQ_TRX_END |
-							     * IRQ_PLL_UNL |
-							     * IRQ_PLL_LOCK
-							     */
+	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, IRQ_TRX_END);
 	if (rc)
 		return rc;
 
@@ -831,7 +839,9 @@ static int at86rf230_probe(struct spi_device *spi)
 	struct at86rf230_platform_data *pdata;
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
-	u8 man_id_0, man_id_1;
+	u8 man_id_0, man_id_1, status;
+	irq_handler_t irq_handler;
+	work_func_t irq_worker;
 	int rc, supported = 0;
 	const char *chip;
 
@@ -861,8 +871,16 @@ static int at86rf230_probe(struct spi_device *spi)
 	dev->phy->channels_supported[0] = 0x7FFF800;
 	dev->flags = IEEE802154_HW_OMIT_CKSUM;
 
+	if (pdata->irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
+		irq_worker = at86rf230_irqwork;
+		irq_handler = at86rf230_isr;
+	} else {
+		irq_worker = at86rf230_irqwork_level;
+		irq_handler = at86rf230_isr_level;
+	}
+
 	mutex_init(&lp->bmux);
-	INIT_WORK(&lp->irqwork, at86rf230_irqwork);
+	INIT_WORK(&lp->irqwork, irq_worker);
 	spin_lock_init(&lp->lock);
 	init_completion(&lp->tx_complete);
 
@@ -943,12 +961,17 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc)
 		goto err_gpio_dir;
 
-	rc = request_irq(spi->irq, at86rf230_isr,
+	rc = request_irq(spi->irq, irq_handler,
 			 IRQF_SHARED | pdata->irq_type,
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
