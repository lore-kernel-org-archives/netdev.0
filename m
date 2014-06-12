From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next] mrf24j40: separate h/w init and add checkings
Date: Thu, 12 Jun 2014 14:40:48 +0530
Message-ID: <1402564248-20606-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

separate the mrf24j40 hardware initialisation from probe()
and adds the sanity checkings.

These checkings are required if somebody hasn't a right spi configuration 
the probe function should fail. So we have to return from there.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ieee802154/mrf24j40.c |  114 +++++++++++++++++++++++++++++--------
 1 file changed, 89 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 4048062..9574d10 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -610,6 +610,92 @@ out:
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
@@ -650,31 +736,9 @@ static int mrf24j40_probe(struct spi_device *spi)
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
+		return err_hw_init;
 
 	ret = devm_request_threaded_irq(&spi->dev,
 					spi->irq,
@@ -692,7 +756,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	return 0;
 
 err_irq:
-err_read_reg:
+err_hw_init:
 	ieee802154_unregister_device(devrec->dev);
 err_register_device:
 	ieee802154_free_device(devrec->dev);
-- 
1.7.9.5
