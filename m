From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH] mrf24j40: add managed API's provided by device layer
Date: Thu, 29 May 2014 09:47:51 +0530
Message-ID: <1401337071-4071-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	alex.aing@gmail.com, Varka Bhadram <varkab@cdac.in>
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the managed APIs to the deriver code. By using this we need
not to worry about freeing the memory and irq numbers.

Thanks and Regards,
Varka Bhadram

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/mrf24j40.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 78a6552..729ec0f 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -618,10 +618,11 @@ static int mrf24j40_probe(struct spi_device *spi)
 
 	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
 
-	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
+	devrec = devm_kzalloc(spi->dev,
+			sizeof(struct mrf24j40), GFP_KERNEL);
 	if (!devrec)
 		goto err_devrec;
-	devrec->buf = kzalloc(3, GFP_KERNEL);
+	devrec->buf = devm_kzalloc(spi->dev, 3, GFP_KERNEL);
 	if (!devrec->buf)
 		goto err_buf;
 
@@ -676,12 +677,13 @@ static int mrf24j40_probe(struct spi_device *spi)
 	val &= ~0x3; /* Clear RX mode (normal) */
 	write_short_reg(devrec, REG_RXMCR, val);
 
-	ret = request_threaded_irq(spi->irq,
-				   NULL,
-				   mrf24j40_isr,
-				   IRQF_TRIGGER_LOW|IRQF_ONESHOT,
-				   dev_name(&spi->dev),
-				   devrec);
+	ret = devm_request_threaded_irq(spi->dev,
+					spi->irq,
+					NULL,
+					mrf24j40_isr,
+					IRQF_TRIGGER_LOW|IRQF_ONESHOT,
+					dev_name(&spi->dev),
+					devrec);
 
 	if (ret) {
 		dev_err(printdev(devrec), "Unable to get IRQ");
@@ -709,15 +711,11 @@ static int mrf24j40_remove(struct spi_device *spi)
 
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
