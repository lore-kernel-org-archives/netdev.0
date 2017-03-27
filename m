From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/5] net: alx: switch to pci_alloc_irq_vectors
Date: Mon, 27 Mar 2017 10:29:34 +0200
Message-ID: <20170327082936.6830-4-hch@lst.de>
References: <20170327082936.6830-1-hch@lst.de>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170327082936.6830-1-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the deprecated pci_enable_msix API in favour of it's successor,
and make sure to handle errors during IRQ setup properly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/atheros/alx/alx.h  |   6 --
 drivers/net/ethernet/atheros/alx/main.c | 128 ++++++++++++++------------------
 2 files changed, 54 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index d4a409139ea2..78c5de467426 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -102,9 +102,6 @@ struct alx_napi {
 
 #define ALX_MAX_NAPIS 8
 
-#define ALX_FLAG_USING_MSIX	BIT(0)
-#define ALX_FLAG_USING_MSI	BIT(1)
-
 struct alx_priv {
 	struct net_device *dev;
 
@@ -112,7 +109,6 @@ struct alx_priv {
 
 	/* msi-x vectors */
 	int num_vec;
-	struct msix_entry *msix_entries;
 
 	/* all descriptor memory */
 	struct {
@@ -139,8 +135,6 @@ struct alx_priv {
 
 	u16 msg_enable;
 
-	int flags;
-
 	/* protects hw.stats */
 	spinlock_t stats_lock;
 };
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 6a27c2662675..a8c2db881b75 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -314,7 +314,7 @@ static int alx_poll(struct napi_struct *napi, int budget)
 	napi_complete_done(&np->napi, work);
 
 	/* enable interrupt */
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
+	if (alx->hw.pdev->msix_enabled) {
 		alx_mask_msix(hw, np->vec_idx, false);
 	} else {
 		spin_lock_irqsave(&alx->irq_lock, flags);
@@ -811,7 +811,7 @@ static void alx_config_vector_mapping(struct alx_priv *alx)
 	u32 tbl[2] = {0, 0};
 	int i, vector, idx, shift;
 
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
+	if (alx->hw.pdev->msix_enabled) {
 		/* tx mappings */
 		for (i = 0, vector = 1; i < alx->num_txq; i++, vector++) {
 			idx = txq_vec_mapping_shift[i * 2];
@@ -828,29 +828,19 @@ static void alx_config_vector_mapping(struct alx_priv *alx)
 	alx_write_mem32(hw, ALX_MSI_ID_MAP, 0);
 }
 
-static bool alx_enable_msix(struct alx_priv *alx)
+static int alx_enable_msix(struct alx_priv *alx)
 {
-	int i, err, num_vec, num_txq, num_rxq;
+	int err, num_vec, num_txq, num_rxq;
 
 	num_txq = min_t(int, num_online_cpus(), ALX_MAX_TX_QUEUES);
 	num_rxq = 1;
 	num_vec = max_t(int, num_txq, num_rxq) + 1;
 
-	alx->msix_entries = kcalloc(num_vec, sizeof(struct msix_entry),
-				    GFP_KERNEL);
-	if (!alx->msix_entries) {
-		netdev_warn(alx->dev, "Allocation of msix entries failed!\n");
-		return false;
-	}
-
-	for (i = 0; i < num_vec; i++)
-		alx->msix_entries[i].entry = i;
-
-	err = pci_enable_msix(alx->hw.pdev, alx->msix_entries, num_vec);
+	err = pci_alloc_irq_vectors(alx->hw.pdev, num_vec, num_vec,
+			PCI_IRQ_MSIX);
 	if (err) {
-		kfree(alx->msix_entries);
 		netdev_warn(alx->dev, "Enabling MSI-X interrupts failed!\n");
-		return false;
+		return err;
 	}
 
 	alx->num_vec = num_vec;
@@ -858,7 +848,7 @@ static bool alx_enable_msix(struct alx_priv *alx)
 	alx->num_txq = num_txq;
 	alx->num_rxq = num_rxq;
 
-	return true;
+	return err;
 }
 
 static int alx_request_msix(struct alx_priv *alx)
@@ -866,7 +856,7 @@ static int alx_request_msix(struct alx_priv *alx)
 	struct net_device *netdev = alx->dev;
 	int i, err, vector = 0, free_vector = 0;
 
-	err = request_irq(alx->msix_entries[0].vector, alx_intr_msix_misc,
+	err = request_irq(pci_irq_vector(alx->hw.pdev, 0), alx_intr_msix_misc,
 			  0, netdev->name, alx);
 	if (err)
 		goto out_err;
@@ -889,7 +879,7 @@ static int alx_request_msix(struct alx_priv *alx)
 			sprintf(np->irq_lbl, "%s-unused", netdev->name);
 
 		np->vec_idx = vector;
-		err = request_irq(alx->msix_entries[vector].vector,
+		err = request_irq(pci_irq_vector(alx->hw.pdev, vector),
 				  alx_intr_msix_ring, 0, np->irq_lbl, np);
 		if (err)
 			goto out_free;
@@ -897,47 +887,31 @@ static int alx_request_msix(struct alx_priv *alx)
 	return 0;
 
 out_free:
-	free_irq(alx->msix_entries[free_vector++].vector, alx);
+	free_irq(pci_irq_vector(alx->hw.pdev, free_vector++), alx);
 
 	vector--;
 	for (i = 0; i < vector; i++)
-		free_irq(alx->msix_entries[free_vector++].vector,
+		free_irq(pci_irq_vector(alx->hw.pdev,free_vector++),
 			 alx->qnapi[i]);
 
 out_err:
 	return err;
 }
 
-static void alx_init_intr(struct alx_priv *alx, bool msix)
+static int alx_init_intr(struct alx_priv *alx)
 {
-	if (msix) {
-		if (alx_enable_msix(alx))
-			alx->flags |= ALX_FLAG_USING_MSIX;
-	}
+	int ret;
 
-	if (!(alx->flags & ALX_FLAG_USING_MSIX)) {
-		alx->num_vec = 1;
-		alx->num_napi = 1;
-		alx->num_txq = 1;
-		alx->num_rxq = 1;
-
-		if (!pci_enable_msi(alx->hw.pdev))
-			alx->flags |= ALX_FLAG_USING_MSI;
-	}
-}
-
-static void alx_disable_advanced_intr(struct alx_priv *alx)
-{
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
-		kfree(alx->msix_entries);
-		pci_disable_msix(alx->hw.pdev);
-		alx->flags &= ~ALX_FLAG_USING_MSIX;
-	}
+	ret = pci_alloc_irq_vectors(alx->hw.pdev, 1, 1,
+			PCI_IRQ_MSI | PCI_IRQ_LEGACY);
+	if (ret)
+		return ret;
 
-	if (alx->flags & ALX_FLAG_USING_MSI) {
-		pci_disable_msi(alx->hw.pdev);
-		alx->flags &= ~ALX_FLAG_USING_MSI;
-	}
+	alx->num_vec = 1;
+	alx->num_napi = 1;
+	alx->num_txq = 1;
+	alx->num_rxq = 1;
+	return 0;
 }
 
 static void alx_irq_enable(struct alx_priv *alx)
@@ -950,10 +924,11 @@ static void alx_irq_enable(struct alx_priv *alx)
 	alx_write_mem32(hw, ALX_IMR, alx->int_mask);
 	alx_post_write(hw);
 
-	if (alx->flags & ALX_FLAG_USING_MSIX)
+	if (alx->hw.pdev->msix_enabled) {
 		/* enable all msix irqs */
 		for (i = 0; i < alx->num_vec; i++)
 			alx_mask_msix(hw, i, false);
+	}
 }
 
 static void alx_irq_disable(struct alx_priv *alx)
@@ -965,13 +940,13 @@ static void alx_irq_disable(struct alx_priv *alx)
 	alx_write_mem32(hw, ALX_IMR, 0);
 	alx_post_write(hw);
 
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
+	if (alx->hw.pdev->msix_enabled) {
 		for (i = 0; i < alx->num_vec; i++) {
 			alx_mask_msix(hw, i, true);
-			synchronize_irq(alx->msix_entries[i].vector);
+			synchronize_irq(pci_irq_vector(alx->hw.pdev, i));
 		}
 	} else {
-		synchronize_irq(alx->hw.pdev->irq);
+		synchronize_irq(pci_irq_vector(alx->hw.pdev, 0));
 	}
 }
 
@@ -981,8 +956,11 @@ static int alx_realloc_resources(struct alx_priv *alx)
 
 	alx_free_rings(alx);
 	alx_free_napis(alx);
-	alx_disable_advanced_intr(alx);
-	alx_init_intr(alx, false);
+	pci_free_irq_vectors(alx->hw.pdev);
+
+	err = alx_init_intr(alx);
+	if (err)
+		return err;
 
 	err = alx_alloc_napis(alx);
 	if (err)
@@ -1004,7 +982,7 @@ static int alx_request_irq(struct alx_priv *alx)
 
 	msi_ctrl = (hw->imt >> 1) << ALX_MSI_RETRANS_TM_SHIFT;
 
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
+	if (alx->hw.pdev->msix_enabled) {
 		alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER, msi_ctrl);
 		err = alx_request_msix(alx);
 		if (!err)
@@ -1016,20 +994,20 @@ static int alx_request_irq(struct alx_priv *alx)
 			goto out;
 	}
 
-	if (alx->flags & ALX_FLAG_USING_MSI) {
+	if (alx->hw.pdev->msi_enabled) {
 		alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER,
 				msi_ctrl | ALX_MSI_MASK_SEL_LINE);
-		err = request_irq(pdev->irq, alx_intr_msi, 0,
+		err = request_irq(pci_irq_vector(pdev, 0), alx_intr_msi, 0,
 				  alx->dev->name, alx);
 		if (!err)
 			goto out;
+
 		/* fall back to legacy interrupt */
-		alx->flags &= ~ALX_FLAG_USING_MSI;
-		pci_disable_msi(alx->hw.pdev);
+		pci_free_irq_vectors(alx->hw.pdev);
 	}
 
 	alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER, 0);
-	err = request_irq(pdev->irq, alx_intr_legacy, IRQF_SHARED,
+	err = request_irq(pci_irq_vector(pdev, 0), alx_intr_legacy, IRQF_SHARED,
 			  alx->dev->name, alx);
 out:
 	if (!err)
@@ -1042,18 +1020,15 @@ static int alx_request_irq(struct alx_priv *alx)
 static void alx_free_irq(struct alx_priv *alx)
 {
 	struct pci_dev *pdev = alx->hw.pdev;
-	int i, vector = 0;
+	int i;
 
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
-		free_irq(alx->msix_entries[vector++].vector, alx);
+	free_irq(pci_irq_vector(pdev, 0), alx);
+	if (alx->hw.pdev->msix_enabled) {
 		for (i = 0; i < alx->num_napi; i++)
-			free_irq(alx->msix_entries[vector++].vector,
-				 alx->qnapi[i]);
-	} else {
-		free_irq(pdev->irq, alx);
+			free_irq(pci_irq_vector(pdev, i + 1), alx->qnapi[i]);
 	}
 
-	alx_disable_advanced_intr(alx);
+	pci_free_irq_vectors(pdev);
 }
 
 static int alx_identify_hw(struct alx_priv *alx)
@@ -1221,7 +1196,12 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 {
 	int err;
 
-	alx_init_intr(alx, true);
+	err = alx_enable_msix(alx);
+	if (err < 0) {
+		err = alx_init_intr(alx);
+		if (err)
+			return err;
+	}
 
 	if (!resume)
 		netif_carrier_off(alx->dev);
@@ -1264,7 +1244,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 	alx_free_rings(alx);
 	alx_free_napis(alx);
 out_disable_adv_intr:
-	alx_disable_advanced_intr(alx);
+	pci_free_irq_vectors(alx->hw.pdev);
 	return err;
 }
 
@@ -1637,11 +1617,11 @@ static void alx_poll_controller(struct net_device *netdev)
 	struct alx_priv *alx = netdev_priv(netdev);
 	int i;
 
-	if (alx->flags & ALX_FLAG_USING_MSIX) {
+	if (alx->hw.pdev->msix_enabled) {
 		alx_intr_msix_misc(0, alx);
 		for (i = 0; i < alx->num_txq; i++)
 			alx_intr_msix_ring(0, alx->qnapi[i]);
-	} else if (alx->flags & ALX_FLAG_USING_MSI)
+	} else if (alx->hw.pdev->msi_enabled)
 		alx_intr_msi(0, alx);
 	else
 		alx_intr_legacy(0, alx);
@@ -1783,7 +1763,7 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->netdev_ops = &alx_netdev_ops;
 	netdev->ethtool_ops = &alx_ethtool_ops;
-	netdev->irq = pdev->irq;
+	netdev->irq = pci_irq_vector(pdev, 0);
 	netdev->watchdog_timeo = ALX_WATCHDOG_TIME;
 
 	if (ent->driver_data & ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG)
-- 
2.11.0
