From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH v1 2/3] mrf24j40: Use threaded IRQ
	handler
Date: Sat,  5 Oct 2013 23:52:23 -0400
Message-ID: <1381031544-2960-3-git-send-email-alan@signal11.us>
References: <1369188080-8904-1-git-send-email-alan@signal11.us>
	<1381031544-2960-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1381031544-2960-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Eliminate all the workqueue and interrupt enable/disable.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 drivers/net/ieee802154/mrf24j40.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 66bb4ce..c1bc688 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -82,7 +82,6 @@ struct mrf24j40 {
 
 	struct mutex buffer_mutex; /* only used to protect buf */
 	struct completion tx_complete;
-	struct work_struct irqwork;
 	u8 *buf; /* 3 bytes. Used for SPI single-register transfers. */
 };
 
@@ -590,17 +589,6 @@ static struct ieee802154_ops mrf24j40_ops = {
 static irqreturn_t mrf24j40_isr(int irq, void *data)
 {
 	struct mrf24j40 *devrec = data;
-
-	disable_irq_nosync(irq);
-
-	schedule_work(&devrec->irqwork);
-
-	return IRQ_HANDLED;
-}
-
-static void mrf24j40_isrwork(struct work_struct *work)
-{
-	struct mrf24j40 *devrec = container_of(work, struct mrf24j40, irqwork);
 	u8 intstat;
 	int ret;
 
@@ -618,7 +606,7 @@ static void mrf24j40_isrwork(struct work_struct *work)
 		mrf24j40_handle_rx(devrec);
 
 out:
-	enable_irq(devrec->spi->irq);
+	return IRQ_HANDLED;
 }
 
 static int mrf24j40_probe(struct spi_device *spi)
@@ -642,7 +630,6 @@ static int mrf24j40_probe(struct spi_device *spi)
 
 	mutex_init(&devrec->buffer_mutex);
 	init_completion(&devrec->tx_complete);
-	INIT_WORK(&devrec->irqwork, mrf24j40_isrwork);
 	devrec->spi = spi;
 	spi_set_drvdata(spi, devrec);
 
@@ -688,11 +675,12 @@ static int mrf24j40_probe(struct spi_device *spi)
 	val &= ~0x3; /* Clear RX mode (normal) */
 	write_short_reg(devrec, REG_RXMCR, val);
 
-	ret = request_irq(spi->irq,
-			  mrf24j40_isr,
-			  IRQF_TRIGGER_FALLING,
-			  dev_name(&spi->dev),
-			  devrec);
+	ret = request_threaded_irq(spi->irq,
+				   NULL,
+				   mrf24j40_isr,
+				   IRQF_TRIGGER_FALLING|IRQF_ONESHOT,
+				   dev_name(&spi->dev),
+				   devrec);
 
 	if (ret) {
 		dev_err(printdev(devrec), "Unable to get IRQ");
@@ -721,7 +709,6 @@ static int mrf24j40_remove(struct spi_device *spi)
 	dev_dbg(printdev(devrec), "remove\n");
 
 	free_irq(spi->irq, devrec);
-	flush_work(&devrec->irqwork); /* TODO: Is this the right call? */
 	ieee802154_unregister_device(devrec->dev);
 	ieee802154_free_device(devrec->dev);
 	/* TODO: Will ieee802154_free_device() wait until ->xmit() is
-- 
1.8.1.2


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60134791&iu=/4140/ostg.clktrk
