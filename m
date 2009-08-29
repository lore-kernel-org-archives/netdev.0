From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/17] tg3: Cleanup interrupt setup / teardown
Date: Fri, 28 Aug 2009 17:01:15 -0700
Message-ID: <1251585287.29690@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2867 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbZH2Weu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later patches will be adding MSIX support, which will complicate
interrupt initialization.  This patch prepares for the integration by
breaking out the interrupt setup and teardown code into separate
functions and cleaning up the error return paths.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   94 ++++++++++++++++++++++++++---------------------------
 1 files changed, 46 insertions(+), 48 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3725ac8..37a4629 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7865,6 +7865,33 @@ static int tg3_request_firmware(struct tg3 *tp)
 	return 0;
 }
 
+static void tg3_ints_init(struct tg3 *tp)
+{
+	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) {
+		/* All MSI supporting chips should support tagged
+		 * status.  Assert that this is the case.
+		 */
+		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
+			       "Not using MSI.\n", tp->dev->name);
+		} else if (pci_enable_msi(tp->pdev) == 0) {
+			u32 msi_mode;
+
+			msi_mode = tr32(MSGINT_MODE);
+			tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
+			tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
+		}
+	}
+}
+
+static void tg3_ints_fini(struct tg3 *tp)
+{
+		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
+			pci_disable_msi(tp->pdev);
+			tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
+		}
+}
+
 static int tg3_open(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -7906,33 +7933,14 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		return err;
 
-	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) {
-		/* All MSI supporting chips should support tagged
-		 * status.  Assert that this is the case.
-		 */
-		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
-			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
-			       "Not using MSI.\n", tp->dev->name);
-		} else if (pci_enable_msi(tp->pdev) == 0) {
-			u32 msi_mode;
+	tg3_ints_init(tp);
 
-			msi_mode = tr32(MSGINT_MODE);
-			tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
-			tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
-		}
-	}
-	err = tg3_request_irq(tp);
+	napi_enable(&tp->napi);
 
-	if (err) {
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-			pci_disable_msi(tp->pdev);
-			tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
-		}
-		tg3_free_consistent(tp);
-		return err;
-	}
+	err = tg3_request_irq(tp);
 
-	napi_enable(&tp->napi);
+	if (err)
+		goto err_out1;
 
 	tg3_full_lock(tp, 0);
 
@@ -7960,36 +7968,19 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	if (err) {
-		napi_disable(&tp->napi);
-		free_irq(tp->pdev->irq, dev);
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-			pci_disable_msi(tp->pdev);
-			tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
-		}
-		tg3_free_consistent(tp);
-		return err;
-	}
+	if (err)
+		goto err_out2;
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		err = tg3_test_msi(tp);
 
 		if (err) {
 			tg3_full_lock(tp, 0);
-
-			if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-				pci_disable_msi(tp->pdev);
-				tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
-			}
 			tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 			tg3_free_rings(tp);
-			tg3_free_consistent(tp);
-
 			tg3_full_unlock(tp);
 
-			napi_disable(&tp->napi);
-
-			return err;
+			goto err_out1;
 		}
 
 		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
@@ -8015,6 +8006,15 @@ static int tg3_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	return 0;
+
+err_out2:
+	free_irq(tp->pdev->irq, dev);
+
+err_out1:
+	napi_disable(&tp->napi);
+	tg3_ints_fini(tp);
+	tg3_free_consistent(tp);
+	return err;
 }
 
 #if 0
@@ -8273,10 +8273,8 @@ static int tg3_close(struct net_device *dev)
 	tg3_full_unlock(tp);
 
 	free_irq(tp->pdev->irq, dev);
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-		pci_disable_msi(tp->pdev);
-		tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
-	}
+
+	tg3_ints_fini(tp);
 
 	memcpy(&tp->net_stats_prev, tg3_get_stats(tp->dev),
 	       sizeof(tp->net_stats_prev));
-- 
1.6.3.3


