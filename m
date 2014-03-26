From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 4/6] at86rf230: use
	devm_request_irq
Date: Wed, 26 Mar 2014 15:11:55 +0100
Message-ID: <1395843117-16494-5-git-send-email-alex.aring@gmail.com>
References: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1395843117-16494-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch replace request_irq with devm_request_irq. With
devm_request_irq we don't need to care about freeing the irq.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index e034376..a3f9d91 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1199,24 +1199,22 @@ static int at86rf230_probe(struct spi_device *spi)
 	if (rc)
 		goto err_hw_init;
 
-	rc = request_irq(spi->irq, irq_handler, IRQF_SHARED,
-			 dev_name(&spi->dev), lp);
+	rc = devm_request_irq(&spi->dev, spi->irq, irq_handler, IRQF_SHARED,
+			      dev_name(&spi->dev), lp);
 	if (rc)
 		goto err_hw_init;
 
 	/* Read irq status register to reset irq line */
 	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &status);
 	if (rc)
-		goto err_irq;
+		goto err_hw_init;
 
 	rc = ieee802154_register_device(lp->dev);
 	if (rc)
-		goto err_irq;
+		goto err_hw_init;
 
 	return rc;
 
-err_irq:
-	free_irq(spi->irq, lp);
 err_hw_init:
 	flush_work(&lp->irqwork);
 	spi_set_drvdata(spi, NULL);
@@ -1239,7 +1237,6 @@ static int at86rf230_remove(struct spi_device *spi)
 
 	ieee802154_unregister_device(lp->dev);
 
-	free_irq(spi->irq, lp);
 	flush_work(&lp->irqwork);
 
 	if (gpio_is_valid(pdata->slp_tr))
-- 
1.9.1


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
