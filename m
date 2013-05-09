From: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/2] mrf24j40: Avoid transmission while
	receiving a frame
Date: Thu,  9 May 2013 17:19:46 +0200
Message-ID: <1368112788-25701-1-git-send-email-david@hauweele.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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

The transceiver may fail under heavy traffic when a frame is transmitted
while receiving another frame.

This patch uses a mutex to separate the transmission and reception of
frames along with a secondary working queue to avoid a deadlock while
waiting for the transmission interrupt.

Signed-off-by: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/ieee802154/mrf24j40.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index ede3ce4..1e3ddf3 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -82,8 +82,10 @@ struct mrf24j40 {
 	struct ieee802154_dev *dev;
 
 	struct mutex buffer_mutex; /* only used to protect buf */
+	struct mutex txrx_mutex; /* avoid transmission while receiving a frame */
 	struct completion tx_complete;
 	struct work_struct irqwork;
+	struct work_struct rxwork;
 	u8 *buf; /* 3 bytes. Used for SPI single-register transfers. */
 };
 
@@ -353,6 +355,8 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 	/* Set TXNACKREQ if the ACK bit is set in the packet. */
 	if (skb->data[0] & IEEE802154_FC_ACK_REQ)
 		val |= 0x4;
+
+	mutex_lock(&devrec->txrx_mutex);
 	write_short_reg(devrec, REG_TXNCON, val);
 
 	INIT_COMPLETION(devrec->tx_complete);
@@ -361,6 +365,9 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 	ret = wait_for_completion_interruptible_timeout(
 						&devrec->tx_complete,
 						5 * HZ);
+
+	mutex_unlock(&devrec->txrx_mutex);
+
 	if (ret == -ERESTARTSYS)
 		goto err;
 	if (ret == 0) {
@@ -535,6 +542,8 @@ static int mrf24j40_handle_rx(struct mrf24j40 *devrec)
 	int ret = 0;
 	struct sk_buff *skb;
 
+	mutex_lock(&devrec->txrx_mutex);
+
 	/* Turn off reception of packets off the air. This prevents the
 	 * device from overwriting the buffer while we're reading it. */
 	ret = read_short_reg(devrec, REG_BBREG1, &val);
@@ -575,6 +584,8 @@ out:
 	val &= ~0x4; /* Clear RXDECINV */
 	write_short_reg(devrec, REG_BBREG1, val);
 
+	mutex_unlock(&devrec->txrx_mutex);
+
 	return ret;
 }
 
@@ -616,12 +627,19 @@ static void mrf24j40_isrwork(struct work_struct *work)
 
 	/* Check for Rx */
 	if (intstat & 0x8)
-		mrf24j40_handle_rx(devrec);
+		schedule_work(&devrec->rxwork);
 
 out:
 	enable_irq(devrec->spi->irq);
 }
 
+static void mrf24j40_rxwork(struct work_struct *work)
+{
+	struct mrf24j40 *devrec = container_of(work, struct mrf24j40, rxwork);
+
+	mrf24j40_handle_rx(devrec);
+}
+
 static int mrf24j40_probe(struct spi_device *spi)
 {
 	int ret = -ENOMEM;
@@ -648,8 +666,10 @@ static int mrf24j40_probe(struct spi_device *spi)
 		spi->max_speed_hz = MAX_SPI_SPEED_HZ;
 
 	mutex_init(&devrec->buffer_mutex);
+	mutex_init(&devrec->txrx_mutex);
 	init_completion(&devrec->tx_complete);
 	INIT_WORK(&devrec->irqwork, mrf24j40_isrwork);
+	INIT_WORK(&devrec->rxwork, mrf24j40_rxwork);
 	devrec->spi = spi;
 	spi_set_drvdata(spi, devrec);
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and 
their applications. This 200-page book is written by three acclaimed 
leaders in the field. The early access version is available now. 
Download your free book today! http://p.sf.net/sfu/neotech_d2d_may
