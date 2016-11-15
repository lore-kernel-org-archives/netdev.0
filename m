From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 5/9] alx: prepare interrupt functions for multiple queues
Date: Tue, 15 Nov 2016 12:43:12 +0100
Message-ID: <d11bcc435f5b7d5e96738f99326b9ab5f33ac34f.1479208629.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36358 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753090AbcKOLnh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:37 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so24865678wma.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:36 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the interrupt bringup code and the interrupt handler for msi-x
interrupts in order to handle multiple queues.

We must change the poll function because with multiple queues it is possible
that an alx_napi structure has only a tx or only a rx queue pointer.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 132 +++++++++++++++++++++++++-------
 1 file changed, 105 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index a9fc44611b8a..aeb42120910d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -286,11 +286,13 @@ static int alx_poll(struct napi_struct *napi, int budget)
 	struct alx_priv *alx = np->alx;
 	struct alx_hw *hw = &alx->hw;
 	unsigned long flags;
-	bool tx_complete;
-	int work;
+	bool tx_complete = true;
+	int work = 0;
 
-	tx_complete = alx_clean_tx_irq(np->txq);
-	work = alx_clean_rx_irq(np->rxq, budget);
+	if (np->txq)
+		tx_complete = alx_clean_tx_irq(np->txq);
+	if (np->rxq)
+		work = alx_clean_rx_irq(np->rxq, budget);
 
 	if (!tx_complete || work == budget)
 		return budget;
@@ -299,7 +301,7 @@ static int alx_poll(struct napi_struct *napi, int budget)
 
 	/* enable interrupt */
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
-		alx_mask_msix(hw, 1, false);
+		alx_mask_msix(hw, np->vec_idx, false);
 	} else {
 		spin_lock_irqsave(&alx->irq_lock, flags);
 		alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
@@ -372,9 +374,9 @@ static irqreturn_t alx_intr_msix_ring(int irq, void *data)
 	struct alx_hw *hw = &np->alx->hw;
 
 	/* mask interrupt to ACK chip */
-	alx_mask_msix(hw, 1, true);
+	alx_mask_msix(hw, np->vec_idx, true);
 	/* clear interrupt status */
-	alx_write_mem32(hw, ALX_ISR, (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0));
+	alx_write_mem32(hw, ALX_ISR, np->vec_mask);
 
 	napi_schedule(&np->napi);
 
@@ -678,6 +680,13 @@ static void alx_free_napis(struct alx_priv *alx)
 	alx->qnapi[0] = NULL;
 }
 
+static const u32 tx_vect_mask[] = {ALX_ISR_TX_Q0, ALX_ISR_TX_Q1,
+				   ALX_ISR_TX_Q2, ALX_ISR_TX_Q3};
+static const u32 rx_vect_mask[] = {ALX_ISR_RX_Q0, ALX_ISR_RX_Q1,
+				   ALX_ISR_RX_Q2, ALX_ISR_RX_Q3,
+				   ALX_ISR_RX_Q4, ALX_ISR_RX_Q5,
+				   ALX_ISR_RX_Q6, ALX_ISR_RX_Q7};
+
 static int alx_alloc_napis(struct alx_priv *alx)
 {
 	struct alx_napi *np;
@@ -685,7 +694,6 @@ static int alx_alloc_napis(struct alx_priv *alx)
 	struct alx_tx_queue *txq;
 
 	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
-	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
 
 	/* allocate alx_napi structures */
 	np = kzalloc(sizeof(struct alx_napi), GFP_KERNEL);
@@ -703,9 +711,12 @@ static int alx_alloc_napis(struct alx_priv *alx)
 		goto err_out;
 
 	np->txq = txq;
+	txq->queue_idx = 0;
 	txq->count = alx->tx_ringsz;
 	txq->netdev = alx->dev;
 	txq->dev = &alx->hw.pdev->dev;
+	np->vec_mask |= tx_vect_mask[0];
+	alx->int_mask |= tx_vect_mask[0];
 
 	/* allocate rx queues */
 	np = alx->qnapi[0];
@@ -715,9 +726,12 @@ static int alx_alloc_napis(struct alx_priv *alx)
 
 	np->rxq = rxq;
 	rxq->np = alx->qnapi[0];
+	rxq->queue_idx = 0;
 	rxq->count = alx->rx_ringsz;
 	rxq->netdev = alx->dev;
 	rxq->dev = &alx->hw.pdev->dev;
+	np->vec_mask |= rx_vect_mask[0];
+	alx->int_mask |= rx_vect_mask[0];
 
 	return 0;
 
@@ -727,24 +741,43 @@ static int alx_alloc_napis(struct alx_priv *alx)
 	return -ENOMEM;
 }
 
+static const int txq_vec_mapping_shift[] = {
+	0, ALX_MSI_MAP_TBL1_TXQ0_SHIFT,
+	0, ALX_MSI_MAP_TBL1_TXQ1_SHIFT,
+	1, ALX_MSI_MAP_TBL2_TXQ2_SHIFT,
+	1, ALX_MSI_MAP_TBL2_TXQ3_SHIFT,
+};
+
 static void alx_config_vector_mapping(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
-	u32 tbl = 0;
+	u32 tbl[2] = {0, 0};
+	int i, vector, idx, shift;
 
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
-		tbl |= 1 << ALX_MSI_MAP_TBL1_TXQ0_SHIFT;
-		tbl |= 1 << ALX_MSI_MAP_TBL1_RXQ0_SHIFT;
+		/* tx mappings */
+		for (i = 0, vector = 1; i < alx->num_txq; i++, vector++) {
+			idx = txq_vec_mapping_shift[i * 2];
+			shift = txq_vec_mapping_shift[i * 2 + 1];
+			tbl[idx] |= vector << shift;
+		}
+
+		/* rx mapping */
+		tbl[0] |= 1 << ALX_MSI_MAP_TBL1_RXQ0_SHIFT;
 	}
 
-	alx_write_mem32(hw, ALX_MSI_MAP_TBL1, tbl);
-	alx_write_mem32(hw, ALX_MSI_MAP_TBL2, 0);
+	alx_write_mem32(hw, ALX_MSI_MAP_TBL1, tbl[0]);
+	alx_write_mem32(hw, ALX_MSI_MAP_TBL2, tbl[1]);
 	alx_write_mem32(hw, ALX_MSI_ID_MAP, 0);
 }
 
 static bool alx_enable_msix(struct alx_priv *alx)
 {
-	int i, err, num_vec = 2;
+	int i, err, num_vec, num_txq, num_rxq;
+
+	num_txq = 1;
+	num_rxq = 1;
+	num_vec = max_t(int, num_txq, num_rxq) + 1;
 
 	alx->msix_entries = kcalloc(num_vec, sizeof(struct msix_entry),
 				    GFP_KERNEL);
@@ -764,6 +797,10 @@ static bool alx_enable_msix(struct alx_priv *alx)
 	}
 
 	alx->num_vec = num_vec;
+	alx->num_napi = num_vec - 1;
+	alx->num_txq = num_txq;
+	alx->num_rxq = num_rxq;
+
 	return true;
 }
 
@@ -771,21 +808,35 @@ static int alx_request_msix(struct alx_priv *alx)
 {
 	struct net_device *netdev = alx->dev;
 	int i, err, vector = 0, free_vector = 0;
-	struct alx_napi *np = alx->qnapi[0];
 
 	err = request_irq(alx->msix_entries[0].vector, alx_intr_msix_misc,
 			  0, netdev->name, alx);
 	if (err)
 		goto out_err;
 
-	vector++;
-	sprintf(np->irq_lbl, "%s-TxRx-0", netdev->name);
-
-	err = request_irq(alx->msix_entries[vector].vector,
-			  alx_intr_msix_ring, 0, np->irq_lbl, np);
+	for (i = 0; i < alx->num_napi; i++) {
+		struct alx_napi *np = alx->qnapi[i];
+
+		vector++;
+
+		if (np->txq && np->rxq)
+			sprintf(np->irq_lbl, "%s-TxRx-%u", netdev->name,
+				np->txq->queue_idx);
+		else if (np->txq)
+			sprintf(np->irq_lbl, "%s-tx-%u", netdev->name,
+				np->txq->queue_idx);
+		else if (np->rxq)
+			sprintf(np->irq_lbl, "%s-rx-%u", netdev->name,
+				np->rxq->queue_idx);
+		else
+			sprintf(np->irq_lbl, "%s-unused", netdev->name);
+
+		np->vec_idx = vector;
+		err = request_irq(alx->msix_entries[vector].vector,
+				  alx_intr_msix_ring, 0, np->irq_lbl, np);
 		if (err)
 			goto out_free;
-
+	}
 	return 0;
 
 out_free:
@@ -793,7 +844,8 @@ static int alx_request_msix(struct alx_priv *alx)
 
 	vector--;
 	for (i = 0; i < vector; i++)
-		free_irq(alx->msix_entries[free_vector++].vector, alx->qnapi[0]);
+		free_irq(alx->msix_entries[free_vector++].vector,
+			 alx->qnapi[i]);
 
 out_err:
 	return err;
@@ -808,6 +860,9 @@ static void alx_init_intr(struct alx_priv *alx, bool msix)
 
 	if (!(alx->flags & ALX_FLAG_USING_MSIX)) {
 		alx->num_vec = 1;
+		alx->num_napi = 1;
+		alx->num_txq = 1;
+		alx->num_rxq = 1;
 
 		if (!pci_enable_msi(alx->hw.pdev))
 			alx->flags |= ALX_FLAG_USING_MSI;
@@ -863,6 +918,25 @@ static void alx_irq_disable(struct alx_priv *alx)
 	}
 }
 
+static int alx_realloc_resources(struct alx_priv *alx)
+{
+	int err;
+
+	alx_free_rings(alx);
+	alx_free_napis(alx);
+	alx_disable_advanced_intr(alx);
+
+	err = alx_alloc_napis(alx);
+	if (err)
+		return err;
+
+	err = alx_alloc_rings(alx);
+	if (err)
+		return err;
+
+	return 0;
+}
+
 static int alx_request_irq(struct alx_priv *alx)
 {
 	struct pci_dev *pdev = alx->hw.pdev;
@@ -879,8 +953,9 @@ static int alx_request_irq(struct alx_priv *alx)
 			goto out;
 
 		/* msix request failed, realloc resources */
-		alx_disable_advanced_intr(alx);
-		alx_init_intr(alx, false);
+		err = alx_realloc_resources(alx);
+		if (err)
+			goto out;
 	}
 
 	if (alx->flags & ALX_FLAG_USING_MSI) {
@@ -912,9 +987,10 @@ static void alx_free_irq(struct alx_priv *alx)
 	int i, vector = 0;
 
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
-		/* we have only 2 vectors without multi queue support */
 		free_irq(alx->msix_entries[vector++].vector, alx);
-		free_irq(alx->msix_entries[vector++].vector, alx->qnapi[0]);
+		for (i = 0; i < alx->num_napi; i++)
+			free_irq(alx->msix_entries[vector++].vector,
+				 alx->qnapi[i]);
 	} else {
 		free_irq(pdev->irq, alx);
 	}
@@ -1478,10 +1554,12 @@ static int alx_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 static void alx_poll_controller(struct net_device *netdev)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
+	int i;
 
 	if (alx->flags & ALX_FLAG_USING_MSIX) {
 		alx_intr_msix_misc(0, alx);
-		alx_intr_msix_ring(0, alx->qnapi[0]);
+		for (i = 0; i < alx->num_txq; i++)
+			alx_intr_msix_ring(0, alx->qnapi[i]);
 	} else if (alx->flags & ALX_FLAG_USING_MSI)
 		alx_intr_msi(0, alx);
 	else
-- 
2.7.4
