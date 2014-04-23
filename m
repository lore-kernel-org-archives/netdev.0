From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next] mrf24j40: seperate mrf24j40 h/w init and add checkings
Date: Wed, 23 Apr 2014 19:15:20 +0530
Message-ID: <1398260720-18936-1-git-send-email-varkab@cdac.in>
Cc: alan@signal11.us, linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63502 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166AbaDWNpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:45:50 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so787718pab.27
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 06:45:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for duplication , missed the tag net-next

Hai Alex,

I followed the process that you mailed earlier, thnks for that.

I am expecting the mail from Alan about the changes.

Thank you,
Varka Bhadram.


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/mrf24j40.c |  115 ++++++++++++++++++++++++++++---------
 1 file changed, 89 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 246befa..4a9a1ee 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -609,10 +609,95 @@ out:
 	return IRQ_HANDLED;
 }
 
+static int mrf24j40_hw_init(struct mrf24j40 *devrec)
+{
+	int ret;
+	u8 val;
+
+	/* Initialize the device.
+		From datasheet section 3.2: Initialization. */
+	ret = write_short_reg(devrec, REG_SOFTRST, 0x07);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_PACON2, 0x98);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_TXSTBL, 0x95);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON0, 0x03);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON1, 0x01);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON2, 0x80);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON6, 0x90);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON7, 0x80);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_RFCON8, 0x10);
+	if (ret)
+		goto err_ret;
+
+	ret = write_long_reg(devrec, REG_SLPCON1, 0x21);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_BBREG2, 0x80);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_CCAEDTH, 0x60);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_BBREG6, 0x40);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_RFCTL, 0x04);
+	if (ret)
+		goto err_ret;
+
+	ret = write_short_reg(devrec, REG_RFCTL, 0x0);
+	if (ret)
+		goto err_ret;
+
+	udelay(192);
+
+	/* Set RX Mode. RXMCR<1:0>: 0x0 normal, 0x1 promisc, 0x2 error */
+	ret = read_short_reg(devrec, REG_RXMCR, &val);
+	if (ret)
+		goto err_ret;
+
+	val &= ~0x3; /* Clear RX mode (normal) */
+
+	ret = write_short_reg(devrec, REG_RXMCR, val);
+	if (ret)
+		goto err_ret;
+
+	return 0;
+
+err_ret:
+	return ret;
+}
+
 static int mrf24j40_probe(struct spi_device *spi)
 {
 	int ret = -ENOMEM;
-	u8 val;
 	struct mrf24j40 *devrec;
 
 	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
@@ -649,31 +734,9 @@ static int mrf24j40_probe(struct spi_device *spi)
 	if (ret)
 		goto err_register_device;
 
-	/* Initialize the device.
-		From datasheet section 3.2: Initialization. */
-	write_short_reg(devrec, REG_SOFTRST, 0x07);
-	write_short_reg(devrec, REG_PACON2, 0x98);
-	write_short_reg(devrec, REG_TXSTBL, 0x95);
-	write_long_reg(devrec, REG_RFCON0, 0x03);
-	write_long_reg(devrec, REG_RFCON1, 0x01);
-	write_long_reg(devrec, REG_RFCON2, 0x80);
-	write_long_reg(devrec, REG_RFCON6, 0x90);
-	write_long_reg(devrec, REG_RFCON7, 0x80);
-	write_long_reg(devrec, REG_RFCON8, 0x10);
-	write_long_reg(devrec, REG_SLPCON1, 0x21);
-	write_short_reg(devrec, REG_BBREG2, 0x80);
-	write_short_reg(devrec, REG_CCAEDTH, 0x60);
-	write_short_reg(devrec, REG_BBREG6, 0x40);
-	write_short_reg(devrec, REG_RFCTL, 0x04);
-	write_short_reg(devrec, REG_RFCTL, 0x0);
-	udelay(192);
-
-	/* Set RX Mode. RXMCR<1:0>: 0x0 normal, 0x1 promisc, 0x2 error */
-	ret = read_short_reg(devrec, REG_RXMCR, &val);
+	ret = mrf24j40_hw_init(devrec);
 	if (ret)
-		goto err_read_reg;
-	val &= ~0x3; /* Clear RX mode (normal) */
-	write_short_reg(devrec, REG_RXMCR, val);
+		goto err_hw_init;
 
 	ret = request_threaded_irq(spi->irq,
 				   NULL,
@@ -690,7 +753,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	return 0;
 
 err_irq:
-err_read_reg:
+err_hw_init:
 	ieee802154_unregister_device(devrec->dev);
 err_register_device:
 	ieee802154_free_device(devrec->dev);
-- 
1.7.9.5
