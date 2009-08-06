From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/5] tc35815: Improve BLEx / FDAEx handling
Date: Thu,  6 Aug 2009 23:41:46 +0900
Message-ID: <1249569709-21403-2-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56605 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753744AbZHFPbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear Int_BLEx / Int_FDAEx after (not before) processing Rx interrupt.
This will reduce number of unnecessary interrupts.
Also print rx error messages only if netif_msg_rx_err() enabled.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   60 +++++++++++++++++++++---------------------------
 1 files changed, 26 insertions(+), 34 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index c903a68..801d201 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1541,8 +1541,6 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 #endif
 {
 	struct tc35815_local *lp = netdev_priv(dev);
-	struct tc35815_regs __iomem *tr =
-		(struct tc35815_regs __iomem *)dev->base_addr;
 	int ret = -1;
 
 	/* Fatal errors... */
@@ -1552,27 +1550,26 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 	}
 	/* recoverable errors */
 	if (status & Int_IntFDAEx) {
-		/* disable FDAEx int. (until we make rooms...) */
-		tc_writel(tc_readl(&tr->Int_En) & ~Int_FDAExEn, &tr->Int_En);
-		printk(KERN_WARNING
-		       "%s: Free Descriptor Area Exhausted (%#x).\n",
-		       dev->name, status);
+		if (netif_msg_rx_err(lp))
+			dev_warn(&dev->dev,
+				 "Free Descriptor Area Exhausted (%#x).\n",
+				 status);
 		dev->stats.rx_dropped++;
 		ret = 0;
 	}
 	if (status & Int_IntBLEx) {
-		/* disable BLEx int. (until we make rooms...) */
-		tc_writel(tc_readl(&tr->Int_En) & ~Int_BLExEn, &tr->Int_En);
-		printk(KERN_WARNING
-		       "%s: Buffer List Exhausted (%#x).\n",
-		       dev->name, status);
+		if (netif_msg_rx_err(lp))
+			dev_warn(&dev->dev,
+				 "Buffer List Exhausted (%#x).\n",
+				 status);
 		dev->stats.rx_dropped++;
 		ret = 0;
 	}
 	if (status & Int_IntExBD) {
-		printk(KERN_WARNING
-		       "%s: Excessive Buffer Descriptiors (%#x).\n",
-		       dev->name, status);
+		if (netif_msg_rx_err(lp))
+			dev_warn(&dev->dev,
+				 "Excessive Buffer Descriptiors (%#x).\n",
+				 status);
 		dev->stats.rx_length_errors++;
 		ret = 0;
 	}
@@ -1631,8 +1628,12 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 
 	spin_lock(&lp->lock);
 	status = tc_readl(&tr->Int_Src);
-	tc_writel(status, &tr->Int_Src);	/* write to clear */
+	/* BLEx, FDAEx will be cleared later */
+	tc_writel(status & ~(Int_BLEx | Int_FDAEx),
+		  &tr->Int_Src);	/* write to clear */
 	handled = tc35815_do_interrupt(dev, status);
+	if (status & (Int_BLEx | Int_FDAEx))
+		tc_writel(status & (Int_BLEx | Int_FDAEx), &tr->Int_Src);
 	(void)tc_readl(&tr->Int_Src);	/* flush */
 	spin_unlock(&lp->lock);
 	return IRQ_RETVAL(handled >= 0);
@@ -1660,8 +1661,6 @@ tc35815_rx(struct net_device *dev)
 	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned int fdctl;
 	int i;
-	int buf_free_count = 0;
-	int fd_free_count = 0;
 #ifdef TC35815_NAPI
 	int received = 0;
 #endif
@@ -1770,8 +1769,9 @@ tc35815_rx(struct net_device *dev)
 			dev->stats.rx_bytes += pkt_len;
 		} else {
 			dev->stats.rx_errors++;
-			printk(KERN_DEBUG "%s: Rx error (status %x)\n",
-			       dev->name, status & Rx_Stat_Mask);
+			if (netif_msg_rx_err(lp))
+				dev_info(&dev->dev, "Rx error (status %x)\n",
+					 status & Rx_Stat_Mask);
 			/* WORKAROUND: LongErr and CRCErr means Overflow. */
 			if ((status & Rx_LongErr) && (status & Rx_CRCErr)) {
 				status &= ~(Rx_LongErr|Rx_CRCErr);
@@ -1849,7 +1849,6 @@ tc35815_rx(struct net_device *dev)
 #else
 				lp->fbl_count++;
 #endif
-				buf_free_count++;
 			}
 		}
 
@@ -1871,7 +1870,6 @@ tc35815_rx(struct net_device *dev)
 #endif
 			lp->rfd_cur->fd.FDCtl = cpu_to_le32(FD_CownsFD);
 			lp->rfd_cur++;
-			fd_free_count++;
 		}
 		if (lp->rfd_cur > lp->rfd_limit)
 			lp->rfd_cur = lp->rfd_base;
@@ -1882,17 +1880,6 @@ tc35815_rx(struct net_device *dev)
 #endif
 	}
 
-	/* re-enable BL/FDA Exhaust interrupts. */
-	if (fd_free_count) {
-		struct tc35815_regs __iomem *tr =
-			(struct tc35815_regs __iomem *)dev->base_addr;
-		u32 en, en_old = tc_readl(&tr->Int_En);
-		en = en_old | Int_FDAExEn;
-		if (buf_free_count)
-			en |= Int_BLExEn;
-		if (en != en_old)
-			tc_writel(en, &tr->Int_En);
-	}
 #ifdef TC35815_NAPI
 	return received;
 #endif
@@ -1911,9 +1898,14 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	spin_lock(&lp->lock);
 	status = tc_readl(&tr->Int_Src);
 	do {
-		tc_writel(status, &tr->Int_Src);	/* write to clear */
+		/* BLEx, FDAEx will be cleared later */
+		tc_writel(status & ~(Int_BLEx | Int_FDAEx),
+			  &tr->Int_Src);	/* write to clear */
 
 		handled = tc35815_do_interrupt(dev, status, budget - received);
+		if (status & (Int_BLEx | Int_FDAEx))
+			tc_writel(status & (Int_BLEx | Int_FDAEx),
+				  &tr->Int_Src);
 		if (handled >= 0) {
 			received += handled;
 			if (received >= budget)
-- 
1.5.6.5

