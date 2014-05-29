From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v3] mrf24j40: added device managed APIs
Date: Thu, 29 May 2014 15:57:38 +0530
Message-ID: <1401359258-7247-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	alex.aing@gmail.com, Varka Bhadram <varkab@cdac.in>
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

changes since v2:
1. removed unwanted label implementation. 

When we use devm_* APIs ,probe() failed also the memory
will be freed automatically. Thanks to Alex

-Varka Bhadram


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/mrf24j40.c |   30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 78a6552..f2b1345 100644
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
@@ -696,10 +697,7 @@ err_read_reg:
 err_register_device:
 	ieee802154_free_device(devrec->dev);
 err_alloc_dev:
-	kfree(devrec->buf);
-err_buf:
-	kfree(devrec);
-err_devrec:
+err_ret:
 	return ret;
 }
 
@@ -709,15 +707,11 @@ static int mrf24j40_remove(struct spi_device *spi)
 
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
