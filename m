From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 1/4] alx: refactor msi enablement and disablement
Date: Fri,  9 Sep 2016 12:19:52 +0200
Message-ID: <55aeb7ab060809dc52755df6f028f73899f938e5.1473404400.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, feng.tang@intel.com, jarod@redhat.com,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34176 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753722AbcIIKUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 06:20:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id w12so2048888wmf.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 03:20:13 -0700 (PDT)
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new flag field for the advanced interrupt capatibilities and add
new functions to enable and disable msi interrupts. These functions will be
extended later to cover msi-x interrupts.

We enable msi interrupts earlier in alx_init_intr because with msi-x and multi
queue support the number of queues must be set before we allocate resources for
the rx and tx paths.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/alx.h  |  5 ++++-
 drivers/net/ethernet/atheros/alx/main.c | 30 ++++++++++++++++++++++--------
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 8fc93c5f6abc..16ca3f4fa2cc 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -76,6 +76,9 @@ enum alx_device_quirks {
 	ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG = BIT(0),
 };
 
+#define ALX_FLAG_USING_MSIX	BIT(0)
+#define ALX_FLAG_USING_MSI	BIT(1)
+
 struct alx_priv {
 	struct net_device *dev;
 
@@ -105,7 +108,7 @@ struct alx_priv {
 
 	u16 msg_enable;
 
-	bool msi;
+	int flags;
 
 	/* protects hw.stats */
 	spinlock_t stats_lock;
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index d29a4f3102d6..6dc1539205eb 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -620,6 +620,22 @@ static void alx_config_vector_mapping(struct alx_priv *alx)
 	alx_write_mem32(hw, ALX_MSI_ID_MAP, 0);
 }
 
+static void alx_init_intr(struct alx_priv *alx, bool msix)
+{
+	if (!(alx->flags & ALX_FLAG_USING_MSIX)) {
+		if (!pci_enable_msi(alx->hw.pdev))
+			alx->flags |= ALX_FLAG_USING_MSI;
+	}
+}
+
+static void alx_disable_advanced_intr(struct alx_priv *alx)
+{
+	if (alx->flags & ALX_FLAG_USING_MSI) {
+		pci_disable_msi(alx->hw.pdev);
+		alx->flags &= ~ALX_FLAG_USING_MSI;
+	}
+}
+
 static void alx_irq_enable(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
@@ -650,9 +666,7 @@ static int alx_request_irq(struct alx_priv *alx)
 
 	msi_ctrl = (hw->imt >> 1) << ALX_MSI_RETRANS_TM_SHIFT;
 
-	if (!pci_enable_msi(alx->hw.pdev)) {
-		alx->msi = true;
-
+	if (alx->flags & ALX_FLAG_USING_MSI) {
 		alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER,
 				msi_ctrl | ALX_MSI_MASK_SEL_LINE);
 		err = request_irq(pdev->irq, alx_intr_msi, 0,
@@ -660,6 +674,7 @@ static int alx_request_irq(struct alx_priv *alx)
 		if (!err)
 			goto out;
 		/* fall back to legacy interrupt */
+		alx->flags &= ~ALX_FLAG_USING_MSI;
 		pci_disable_msi(alx->hw.pdev);
 	}
 
@@ -678,10 +693,7 @@ static void alx_free_irq(struct alx_priv *alx)
 
 	free_irq(pdev->irq, alx);
 
-	if (alx->msi) {
-		pci_disable_msi(alx->hw.pdev);
-		alx->msi = false;
-	}
+	alx_disable_advanced_intr(alx);
 }
 
 static int alx_identify_hw(struct alx_priv *alx)
@@ -847,6 +859,8 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 {
 	int err;
 
+	alx_init_intr(alx, false);
+
 	if (!resume)
 		netif_carrier_off(alx->dev);
 
@@ -1236,7 +1250,7 @@ static void alx_poll_controller(struct net_device *netdev)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 
-	if (alx->msi)
+	if (alx->flags & ALX_FLAG_USING_MSI)
 		alx_intr_msi(0, alx);
 	else
 		alx_intr_legacy(0, alx);
-- 
2.7.4
