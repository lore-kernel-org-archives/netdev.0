From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v1] mrf24j40: add managed
	API's provided by device layer
Date: Thu, 29 May 2014 10:10:21 +0530
Message-ID: <1401338421-15394-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, alex.aing-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org
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

Hi,
	Previous patch having bug in using managed API's. I fixed that.

Regards,
Varka Bhadram.

Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
---
 drivers/net/ieee802154/mrf24j40.c |   21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 78a6552..f701cdb 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -618,10 +618,10 @@ static int mrf24j40_probe(struct spi_device *spi)
 
 	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
 
-	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
+	devrec = devm_kzalloc(&spi->dev, sizeof(struct mrf24j40), GFP_KERNEL);
 	if (!devrec)
 		goto err_devrec;
-	devrec->buf = kzalloc(3, GFP_KERNEL);
+	devrec->buf = kzalloc(&spi->dev, 3, GFP_KERNEL);
 	if (!devrec->buf)
 		goto err_buf;
 
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
@@ -709,15 +710,11 @@ static int mrf24j40_remove(struct spi_device *spi)
 
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


------------------------------------------------------------------------------
Time is money. Stop wasting it! Get your web API in 5 minutes.
www.restlet.com/download
http://p.sf.net/sfu/restlet
