From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] fec: use interrupt for MDIO completion indication
Date: Mon, 12 Jul 2010 10:12:51 +0300
Message-ID: <006416d38a8e51ba8dd8631613a991528dc7976a.1278918594.git.baruch@tkos.co.il>
Cc: linux-arm-kernel@lists.infradead.org,
	Sascha Hauer <kernel@pengutronix.de>,
	Bryan Wu <bryan.wu@canonical.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:34722 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab0GLHNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 03:13:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the move to phylib (commit e6b043d) I was seeing sporadic "MDIO write
timeout" messages. Measure of the actual time spent showed latency times of
more than 1600us.

This patch uses the MII event indication of the FEC hardware to detect
completion of MDIO transactions.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/fec.c |   55 ++++++++++++++++++++++++----------------------------
 1 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index edfff92..89f3393 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -187,6 +187,7 @@ struct fec_enet_private {
 	int	index;
 	int	link;
 	int	full_duplex;
+	struct	completion mdio_done;
 };
 
 static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
@@ -205,7 +206,7 @@ static void fec_stop(struct net_device *dev);
 #define FEC_MMFR_TA		(2 << 16)
 #define FEC_MMFR_DATA(v)	(v & 0xffff)
 
-#define FEC_MII_TIMEOUT		10000
+#define FEC_MII_TIMEOUT		1000 /* us */
 
 /* Transmitter timeout */
 #define TX_TIMEOUT (2 * HZ)
@@ -334,6 +335,11 @@ fec_enet_interrupt(int irq, void * dev_id)
 			ret = IRQ_HANDLED;
 			fec_enet_tx(dev);
 		}
+
+		if (int_events & FEC_ENET_MII) {
+			ret = IRQ_HANDLED;
+			complete(&fep->mdio_done);
+		}
 	} while (int_events);
 
 	return ret;
@@ -608,18 +614,13 @@ spin_unlock:
 		phy_print_status(phy_dev);
 }
 
-/*
- * NOTE: a MII transaction is during around 25 us, so polling it...
- */
 static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct fec_enet_private *fep = bus->priv;
-	int timeout = FEC_MII_TIMEOUT;
+	unsigned long time_left;
 
 	fep->mii_timeout = 0;
-
-	/* clear MII end of transfer bit*/
-	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
+	init_completion(&fep->mdio_done);
 
 	/* start a read op */
 	writel(FEC_MMFR_ST | FEC_MMFR_OP_READ |
@@ -627,13 +628,12 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 		FEC_MMFR_TA, fep->hwp + FEC_MII_DATA);
 
 	/* wait for end of transfer */
-	while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) {
-		cpu_relax();
-		if (timeout-- < 0) {
-			fep->mii_timeout = 1;
-			printk(KERN_ERR "FEC: MDIO read timeout\n");
-			return -ETIMEDOUT;
-		}
+	time_left = wait_for_completion_timeout(&fep->mdio_done,
+			usecs_to_jiffies(FEC_MII_TIMEOUT));
+	if (time_left == 0) {
+		fep->mii_timeout = 1;
+		printk(KERN_ERR "FEC: MDIO read timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	/* return value */
@@ -644,12 +644,10 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 			   u16 value)
 {
 	struct fec_enet_private *fep = bus->priv;
-	int timeout = FEC_MII_TIMEOUT;
+	unsigned long time_left;
 
 	fep->mii_timeout = 0;
-
-	/* clear MII end of transfer bit*/
-	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
+	init_completion(&fep->mdio_done);
 
 	/* start a read op */
 	writel(FEC_MMFR_ST | FEC_MMFR_OP_READ |
@@ -658,13 +656,12 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 		fep->hwp + FEC_MII_DATA);
 
 	/* wait for end of transfer */
-	while (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_MII)) {
-		cpu_relax();
-		if (timeout-- < 0) {
-			fep->mii_timeout = 1;
-			printk(KERN_ERR "FEC: MDIO write timeout\n");
-			return -ETIMEDOUT;
-		}
+	time_left = wait_for_completion_timeout(&fep->mdio_done,
+			usecs_to_jiffies(FEC_MII_TIMEOUT));
+	if (time_left == 0) {
+		fep->mii_timeout = 1;
+		printk(KERN_ERR "FEC: MDIO write timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	return 0;
@@ -1222,7 +1219,8 @@ fec_restart(struct net_device *dev, int duplex)
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
 	/* Enable interrupts we wish to service */
-	writel(FEC_ENET_TXF | FEC_ENET_RXF, fep->hwp + FEC_IMASK);
+	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
+			fep->hwp + FEC_IMASK);
 }
 
 static void
@@ -1242,9 +1240,6 @@ fec_stop(struct net_device *dev)
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
-	/* Clear outstanding MII command interrupts. */
-	writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
-
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 }
 
-- 
1.7.1

