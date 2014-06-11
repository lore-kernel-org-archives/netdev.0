From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [net-next PATCH] mrf24j40: add device managed APIs
Date: Wed, 11 Jun 2014 10:04:44 +0530
Message-ID: <1402461284-8435-1-git-send-email-varkab@cdac.in>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adds the device managed APIs so that no need worry about
freeing the resources.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/mrf24j40.c |   33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 78a6552..4048062 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -618,12 +618,12 @@ static int mrf24j40_probe(struct spi_device *spi)
 
 	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
 
-	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
+	devrec = devm_kzalloc(&spi->dev, sizeof(struct mrf24j40), GFP_KERNEL);
 	if (!devrec)
-		goto err_devrec;
-	devrec->buf = kzalloc(3, GFP_KERNEL);
+		goto err_ret;
+	devrec->buf = devm_kzalloc(&spi->dev, 3, GFP_KERNEL);
 	if (!devrec->buf)
-		goto err_buf;
+		goto err_ret;
 
 	spi->mode = SPI_MODE_0; /* TODO: Is this appropriate for right here? */
 	if (spi->max_speed_hz > MAX_SPI_SPEED_HZ)
@@ -638,7 +638,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 
 	devrec->dev = ieee802154_alloc_device(0, &mrf24j40_ops);
 	if (!devrec->dev)
-		goto err_alloc_dev;
+		goto err_ret;
 
 	devrec->dev->priv = devrec;
 	devrec->dev->parent = &devrec->spi->dev;
@@ -676,12 +676,13 @@ static int mrf24j40_probe(struct spi_device *spi)
 	val &= ~0x3; /* Clear RX mode (normal) */
 	write_short_reg(devrec, REG_RXMCR, val);
 
-	ret = request_threaded_irq(spi->irq,
-				   NULL,
-				   mrf24j40_isr,
-				   IRQF_TRIGGER_LOW|IRQF_ONESHOT,
-				   dev_name(&spi->dev),
-				   devrec);
+	ret = devm_request_threaded_irq(&spi->dev,
+					spi->irq,
+					NULL,
+					mrf24j40_isr,
+					IRQF_TRIGGER_LOW|IRQF_ONESHOT,
+					dev_name(&spi->dev),
+					devrec);
 
 	if (ret) {
 		dev_err(printdev(devrec), "Unable to get IRQ");
@@ -695,11 +696,7 @@ err_read_reg:
 	ieee802154_unregister_device(devrec->dev);
 err_register_device:
 	ieee802154_free_device(devrec->dev);
-err_alloc_dev:
-	kfree(devrec->buf);
-err_buf:
-	kfree(devrec);
-err_devrec:
+err_ret:
 	return ret;
 }
 
@@ -709,15 +706,11 @@ static int mrf24j40_remove(struct spi_device *spi)
 
 	dev_dbg(printdev(devrec), "remove\n");
 
-	free_irq(spi->irq, devrec);
 	ieee802154_unregister_device(devrec->dev);
 	ieee802154_free_device(devrec->dev);
 	/* TODO: Will ieee802154_free_device() wait until ->xmit() is
 	 * complete? */
 
-	/* Clean up the SPI stuff. */
-	kfree(devrec->buf);
-	kfree(devrec);
 	return 0;
 }
 
-- 
1.7.9.5
