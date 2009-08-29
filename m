From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/17] tg3: Convert ISR parameter to tnapi
Date: Fri, 28 Aug 2009 17:01:57 -0700
Message-ID: <1251585289.29696@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2439 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbZH2We5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch migrates the ISR parameter from struct net_device to struct
tg3_napi.  Checkpatch complains about the existence of the preexisting
IRQF_SAMPLE_RANDOM flag.  I've opted to keep this patch conservative and
let it continue to exist until the flag gets officially purged from the
kernel.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   49 +++++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b308c40..bf9a333 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4757,14 +4757,14 @@ static inline void tg3_full_unlock(struct tg3 *tp)
  */
 static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_napi *tnapi = dev_id;
+	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tp->hw_status);
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		napi_schedule(&tp->napi[0].napi);
+		napi_schedule(&tnapi->napi);
 
 	return IRQ_HANDLED;
 }
@@ -4775,8 +4775,8 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
  */
 static irqreturn_t tg3_msi(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_napi *tnapi = dev_id;
+	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tp->hw_status);
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
@@ -4789,15 +4789,15 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		napi_schedule(&tp->napi[0].napi);
+		napi_schedule(&tnapi->napi);
 
 	return IRQ_RETVAL(1);
 }
 
 static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_napi *tnapi = dev_id;
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	unsigned int handled = 1;
 
@@ -4831,7 +4831,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		napi_schedule(&tp->napi[0].napi);
+		napi_schedule(&tnapi->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -4845,8 +4845,8 @@ out:
 
 static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_napi *tnapi = dev_id;
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	unsigned int handled = 1;
 
@@ -4889,7 +4889,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
-	napi_schedule(&tp->napi[0].napi);
+	napi_schedule(&tnapi->napi);
 
 out:
 	return IRQ_RETVAL(handled);
@@ -4898,8 +4898,8 @@ out:
 /* ISR for interrupt test */
 static irqreturn_t tg3_test_isr(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_napi *tnapi = dev_id;
+	struct tg3 *tp = tnapi->tp;
 	struct tg3_hw_status *sblk = tp->hw_status;
 
 	if ((sblk->status & SD_STATUS_UPDATED) ||
@@ -7697,7 +7697,7 @@ static int tg3_request_irq(struct tg3 *tp)
 {
 	irq_handler_t fn;
 	unsigned long flags;
-	struct net_device *dev = tp->dev;
+	char *name = tp->dev->name;
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		fn = tg3_msi;
@@ -7710,11 +7710,12 @@ static int tg3_request_irq(struct tg3 *tp)
 			fn = tg3_interrupt_tagged;
 		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
 	}
-	return (request_irq(tp->pdev->irq, fn, flags, dev->name, dev));
+	return request_irq(tp->pdev->irq, fn, flags, name, &tp->napi[0]);
 }
 
 static int tg3_test_interrupt(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
 	struct net_device *dev = tp->dev;
 	int err, i, intr_ok = 0;
 
@@ -7723,10 +7724,10 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	tg3_disable_ints(tp);
 
-	free_irq(tp->pdev->irq, dev);
+	free_irq(tp->pdev->irq, tnapi);
 
 	err = request_irq(tp->pdev->irq, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
 	if (err)
 		return err;
 
@@ -7754,7 +7755,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	tg3_disable_ints(tp);
 
-	free_irq(tp->pdev->irq, dev);
+	free_irq(tp->pdev->irq, tnapi);
 
 	err = tg3_request_irq(tp);
 
@@ -7772,7 +7773,6 @@ static int tg3_test_interrupt(struct tg3 *tp)
  */
 static int tg3_test_msi(struct tg3 *tp)
 {
-	struct net_device *dev = tp->dev;
 	int err;
 	u16 pci_cmd;
 
@@ -7803,7 +7803,8 @@ static int tg3_test_msi(struct tg3 *tp)
 	       "the PCI maintainer and include system chipset information.\n",
 		       tp->dev->name);
 
-	free_irq(tp->pdev->irq, dev);
+	free_irq(tp->pdev->irq, &tp->napi[0]);
+
 	pci_disable_msi(tp->pdev);
 
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
@@ -7823,7 +7824,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	tg3_full_unlock(tp);
 
 	if (err)
-		free_irq(tp->pdev->irq, dev);
+		free_irq(tp->pdev->irq, &tp->napi[0]);
 
 	return err;
 }
@@ -8002,7 +8003,7 @@ static int tg3_open(struct net_device *dev)
 	return 0;
 
 err_out2:
-	free_irq(tp->pdev->irq, dev);
+	free_irq(tp->pdev->irq, &tp->napi[0]);
 
 err_out1:
 	napi_disable(&tp->napi[0].napi);
@@ -8266,7 +8267,7 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	free_irq(tp->pdev->irq, dev);
+	free_irq(tp->pdev->irq, &tp->napi[0]);
 
 	tg3_ints_fini(tp);
 
-- 
1.6.3.3


