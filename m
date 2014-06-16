From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] mrf24j40: separate h/w init
	and add checkings
Date: Mon, 16 Jun 2014 09:12:31 +0530
Message-ID: <1402890152-2803-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

separate the mrf24j40 hardware initialisation from probe()
and adds the sanity checkings.

These checkings are required if somebody hasn't a right spi configuration
the probe function should fail. So we have to return from there.

Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
---
 drivers/net/ieee802154/mrf24j40.c |  115 ++++++++++++++++++++++++++++---------
 1 file changed, 89 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 4048062..9e6a124 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -610,10 +610,95 @@ out:
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
@@ -650,31 +735,9 @@ static int mrf24j40_probe(struct spi_device *spi)
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
 
 	ret = devm_request_threaded_irq(&spi->dev,
 					spi->irq,
@@ -692,7 +755,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	return 0;
 
 err_irq:
-err_read_reg:
+err_hw_init:
 	ieee802154_unregister_device(devrec->dev);
 err_register_device:
 	ieee802154_free_device(devrec->dev);
-- 
1.7.9.5


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
