From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/18] tg3: Add MSI-X support
Date: Tue, 1 Sep 2009 15:55:46 -0700
Message-ID: <1251867303.5926@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3486 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124AbZIBEzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds MSI-X support.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  108 +++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/tg3.h |    6 +++
 2 files changed, 87 insertions(+), 27 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7717eae..12ead83 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -160,6 +160,7 @@ MODULE_FIRMWARE(FIRMWARE_TG3);
 MODULE_FIRMWARE(FIRMWARE_TG3TSO);
 MODULE_FIRMWARE(FIRMWARE_TG3TSO5);
 
+#define TG3_RSS_MIN_NUM_MSIX_VECS	2
 
 static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
 module_param(tg3_debug, int, 0);
@@ -7767,7 +7768,7 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		name[IFNAMSIZ-1] = 0;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			fn = tg3_msi_1shot;
@@ -7928,34 +7929,81 @@ static int tg3_request_firmware(struct tg3 *tp)
 	return 0;
 }
 
+static bool tg3_enable_msix(struct tg3 *tp)
+{
+	int i, rc, cpus = num_online_cpus();
+	struct msix_entry msix_ent[tp->irq_max];
+
+	if (cpus == 1)
+		/* Just fallback to the simpler MSI mode. */
+		return false;
+
+	/*
+	 * We want as many rx rings enabled as there are cpus.
+	 * The first MSIX vector only deals with link interrupts, etc,
+	 * so we add one to the number of vectors we are requesting.
+	 */
+	tp->irq_cnt = min_t(unsigned, cpus + 1, tp->irq_max);
+
+	for (i = 0; i < tp->irq_max; i++) {
+		msix_ent[i].entry  = i;
+		msix_ent[i].vector = 0;
+	}
+
+	rc = pci_enable_msix(tp->pdev, msix_ent, tp->irq_cnt);
+	if (rc != 0) {
+		if (rc < TG3_RSS_MIN_NUM_MSIX_VECS)
+			return false;
+		if (pci_enable_msix(tp->pdev, msix_ent, rc))
+			return false;
+		printk(KERN_NOTICE
+		       "%s: Requested %d MSI-X vectors, received %d\n",
+		       tp->dev->name, tp->irq_cnt, rc);
+		tp->irq_cnt = rc;
+	}
+
+	for (i = 0; i < tp->irq_max; i++)
+		tp->napi[i].irq_vec = msix_ent[i].vector;
+
+	return true;
+}
+
 static void tg3_ints_init(struct tg3 *tp)
 {
-	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) {
+	if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSI_OR_MSIX) &&
+	    !(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
 		/* All MSI supporting chips should support tagged
 		 * status.  Assert that this is the case.
 		 */
-		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
-			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
-			       "Not using MSI.\n", tp->dev->name);
-		} else if (pci_enable_msi(tp->pdev) == 0) {
-			u32 msi_mode;
-
-			msi_mode = tr32(MSGINT_MODE);
-			tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
-			tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
-		}
+		printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
+		       "Not using MSI.\n", tp->dev->name);
+		goto defcfg;
 	}
 
-	tp->irq_cnt = 1;
-	tp->napi[0].irq_vec = tp->pdev->irq;
+	if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX) && tg3_enable_msix(tp))
+		tp->tg3_flags2 |= TG3_FLG2_USING_MSIX;
+	else if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) &&
+		 pci_enable_msi(tp->pdev) == 0)
+		tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
+
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
+		u32 msi_mode = tr32(MSGINT_MODE);
+		tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
+	}
+defcfg:
+	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
+		tp->irq_cnt = 1;
+		tp->napi[0].irq_vec = tp->pdev->irq;
+	}
 }
 
 static void tg3_ints_fini(struct tg3 *tp)
 {
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-			pci_disable_msi(tp->pdev);
-			tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
-		}
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+		pci_disable_msix(tp->pdev);
+	else if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
+		pci_disable_msi(tp->pdev);
+	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI_OR_MSIX;
 }
 
 static int tg3_open(struct net_device *dev)
@@ -7992,14 +8040,18 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
+	/*
+	 * Setup interrupts first so we know how
+	 * many NAPI resources to allocate
+	 */
+	tg3_ints_init(tp);
+
 	/* The placement of this call is tied
 	 * to the setup and use of Host TX descriptors.
 	 */
 	err = tg3_alloc_consistent(tp);
 	if (err)
-		return err;
-
-	tg3_ints_init(tp);
+		goto err_out1;
 
 	napi_enable(&tp->napi[0].napi);
 
@@ -8014,7 +8066,7 @@ static int tg3_open(struct net_device *dev)
 	}
 
 	if (err)
-		goto err_out1;
+		goto err_out2;
 
 	tg3_full_lock(tp, 0);
 
@@ -8043,7 +8095,7 @@ static int tg3_open(struct net_device *dev)
 	tg3_full_unlock(tp);
 
 	if (err)
-		goto err_out2;
+		goto err_out3;
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		err = tg3_test_msi(tp);
@@ -8054,7 +8106,7 @@ static int tg3_open(struct net_device *dev)
 			tg3_free_rings(tp);
 			tg3_full_unlock(tp);
 
-			goto err_out1;
+			goto err_out2;
 		}
 
 		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
@@ -8081,16 +8133,18 @@ static int tg3_open(struct net_device *dev)
 
 	return 0;
 
-err_out2:
+err_out3:
 	for (i = tp->irq_cnt - 1; i >= 0; i--) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		free_irq(tnapi->irq_vec, tnapi);
 	}
 
-err_out1:
+err_out2:
 	napi_disable(&tp->napi[0].napi);
-	tg3_ints_fini(tp);
 	tg3_free_consistent(tp);
+
+err_out1:
+	tg3_ints_fini(tp);
 	return err;
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a78a0db..65bbd77 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2621,6 +2621,9 @@ struct tg3 {
 #define TG3_FLAG_NVRAM			0x00002000
 #define TG3_FLAG_NVRAM_BUFFERED		0x00004000
 #define TG3_FLAG_SUPPORT_MSI		0x00008000
+#define TG3_FLAG_SUPPORT_MSIX		0x00010000
+#define TG3_FLAG_SUPPORT_MSI_OR_MSIX	(TG3_FLAG_SUPPORT_MSI | \
+					 TG3_FLAG_SUPPORT_MSIX)
 #define TG3_FLAG_PCIX_MODE		0x00020000
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000
@@ -2659,6 +2662,9 @@ struct tg3 {
 #define TG3_FLG2_5750_PLUS		0x00080000
 #define TG3_FLG2_PROTECTED_NVRAM	0x00100000
 #define TG3_FLG2_USING_MSI		0x00200000
+#define TG3_FLG2_USING_MSIX		0x00400000
+#define TG3_FLG2_USING_MSI_OR_MSIX	(TG3_FLG2_USING_MSI | \
+					TG3_FLG2_USING_MSIX)
 #define TG3_FLG2_MII_SERDES		0x00800000
 #define TG3_FLG2_ANY_SERDES		(TG3_FLG2_PHY_SERDES |	\
 					TG3_FLG2_MII_SERDES)
-- 
1.6.3.3


