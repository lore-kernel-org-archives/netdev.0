From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 3/4] alx: add msi-x support
Date: Fri,  9 Sep 2016 12:19:54 +0200
Message-ID: <ef83b037ea6f0775204cb35f98098d195c500073.1473404401.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, feng.tang@intel.com, jarod@redhat.com,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36304 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbcIIKUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 06:20:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id l65so2041151wmf.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 03:20:20 -0700 (PDT)
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add msi-x support to the alx driver. This is in preparation for multi queue
support.

msi-x interrupts are disabled by default because without multi queue support
there is no advantage over msi interrupts. The performance numbers observed
with iperf stay the same.

Based on information of the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/alx.h  |   5 +
 drivers/net/ethernet/atheros/alx/hw.c   |  14 +++
 drivers/net/ethernet/atheros/alx/hw.h   |   1 +
 drivers/net/ethernet/atheros/alx/main.c | 172 ++++++++++++++++++++++++++++++--
 4 files changed, 184 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 16ca3f4fa2cc..6cac919272ea 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -84,6 +84,11 @@ struct alx_priv {
 
 	struct alx_hw hw;
 
+	/* msi-x vectors */
+	int num_vec;
+	struct msix_entry *msix_entries;
+	char irq_lbl[IFNAMSIZ + 8];
+
 	/* all descriptor memory */
 	struct {
 		dma_addr_t dma;
diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index 1fe35e453d43..6ac40b0003a3 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -1031,6 +1031,20 @@ void alx_configure_basic(struct alx_hw *hw)
 	alx_write_mem32(hw, ALX_WRR, val);
 }
 
+void alx_mask_msix(struct alx_hw *hw, int index, bool mask)
+{
+	u32 reg, val;
+
+	reg = ALX_MSIX_ENTRY_BASE + index * PCI_MSIX_ENTRY_SIZE +
+		PCI_MSIX_ENTRY_VECTOR_CTRL;
+
+	val = mask ? PCI_MSIX_ENTRY_CTRL_MASKBIT : 0;
+
+	alx_write_mem32(hw, reg, val);
+	alx_post_write(hw);
+}
+
+
 bool alx_get_phy_info(struct alx_hw *hw)
 {
 	u16  devs1, devs2;
diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index f289c05f5cb4..0191477ace51 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -562,6 +562,7 @@ int alx_reset_mac(struct alx_hw *hw);
 void alx_set_macaddr(struct alx_hw *hw, const u8 *addr);
 bool alx_phy_configured(struct alx_hw *hw);
 void alx_configure_basic(struct alx_hw *hw);
+void alx_mask_msix(struct alx_hw *hw, int index, bool mask);
 void alx_disable_rss(struct alx_hw *hw);
 bool alx_get_phy_info(struct alx_hw *hw);
 void alx_update_hw_stats(struct alx_hw *hw);
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index b34f7b693cec..a4f74d4a976c 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -292,10 +292,14 @@ static int alx_poll(struct napi_struct *napi, int budget)
 	napi_complete(&alx->napi);
 
 	/* enable interrupt */
-	spin_lock_irqsave(&alx->irq_lock, flags);
-	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
-	alx_write_mem32(hw, ALX_IMR, alx->int_mask);
-	spin_unlock_irqrestore(&alx->irq_lock, flags);
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		alx_mask_msix(hw, 1, false);
+	} else {
+		spin_lock_irqsave(&alx->irq_lock, flags);
+		alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
+		alx_write_mem32(hw, ALX_IMR, alx->int_mask);
+		spin_unlock_irqrestore(&alx->irq_lock, flags);
+	}
 
 	alx_post_write(hw);
 
@@ -356,6 +360,46 @@ static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t alx_intr_msix_ring(int irq, void *data)
+{
+	struct alx_priv *alx = data;
+	struct alx_hw *hw = &alx->hw;
+
+	/* mask interrupt to ACK chip */
+	alx_mask_msix(hw, 1, true);
+	/* clear interrupt status */
+	alx_write_mem32(hw, ALX_ISR, (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0));
+
+	napi_schedule(&alx->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t alx_intr_msix_misc(int irq, void *data)
+{
+	struct alx_priv *alx = data;
+	struct alx_hw *hw = &alx->hw;
+	u32 intr;
+
+	/* mask interrupt to ACK chip */
+	alx_mask_msix(hw, 0, true);
+
+	/* read interrupt status */
+	intr = alx_read_mem32(hw, ALX_ISR);
+	intr &= (alx->int_mask & ~ALX_ISR_ALL_QUEUES);
+
+	if (alx_intr_handle_misc(alx, intr))
+		return IRQ_HANDLED;
+
+	/* clear interrupt status */
+	alx_write_mem32(hw, ALX_ISR, intr);
+
+	/* enable interrupt again */
+	alx_mask_msix(hw, 0, false);
+
+	return IRQ_HANDLED;
+}
+
 static irqreturn_t alx_intr_msi(int irq, void *data)
 {
 	struct alx_priv *alx = data;
@@ -620,15 +664,84 @@ static void alx_free_rings(struct alx_priv *alx)
 static void alx_config_vector_mapping(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
+	u32 tbl = 0;
+
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		tbl |= 1 << ALX_MSI_MAP_TBL1_TXQ0_SHIFT;
+		tbl |= 1 << ALX_MSI_MAP_TBL1_RXQ0_SHIFT;
+	}
 
-	alx_write_mem32(hw, ALX_MSI_MAP_TBL1, 0);
+	alx_write_mem32(hw, ALX_MSI_MAP_TBL1, tbl);
 	alx_write_mem32(hw, ALX_MSI_MAP_TBL2, 0);
 	alx_write_mem32(hw, ALX_MSI_ID_MAP, 0);
 }
 
+static bool alx_enable_msix(struct alx_priv *alx)
+{
+	int i, err, num_vec = 2;
+
+	alx->msix_entries = kcalloc(num_vec, sizeof(struct msix_entry),
+				    GFP_KERNEL);
+	if (!alx->msix_entries) {
+		netdev_warn(alx->dev, "Allocation of msix entries failed!\n");
+		return false;
+	}
+
+	for (i = 0; i < num_vec; i++)
+		alx->msix_entries[i].entry = i;
+
+	err = pci_enable_msix(alx->hw.pdev, alx->msix_entries, num_vec);
+	if (err) {
+		kfree(alx->msix_entries);
+		netdev_warn(alx->dev, "Enabling MSI-X interrupts failed!\n");
+		return false;
+	}
+
+	alx->num_vec = num_vec;
+	return true;
+}
+
+static int alx_request_msix(struct alx_priv *alx)
+{
+	struct net_device *netdev = alx->dev;
+	int i, err, vector = 0, free_vector = 0;
+
+	err = request_irq(alx->msix_entries[0].vector, alx_intr_msix_misc,
+			  0, netdev->name, alx);
+	if (err)
+		goto out_err;
+
+	vector++;
+	sprintf(alx->irq_lbl, "%s-TxRx-0", netdev->name);
+
+	err = request_irq(alx->msix_entries[vector].vector,
+			  alx_intr_msix_ring, 0, alx->irq_lbl, alx);
+		if (err)
+			goto out_free;
+
+	return 0;
+
+out_free:
+	free_irq(alx->msix_entries[free_vector++].vector, alx);
+
+	vector--;
+	for (i = 0; i < vector; i++)
+		free_irq(alx->msix_entries[free_vector++].vector, alx);
+
+out_err:
+	return err;
+}
+
 static void alx_init_intr(struct alx_priv *alx, bool msix)
 {
+	if (msix) {
+		if (alx_enable_msix(alx))
+			alx->flags |= ALX_FLAG_USING_MSIX;
+	}
+
 	if (!(alx->flags & ALX_FLAG_USING_MSIX)) {
+		alx->num_vec = 1;
+
 		if (!pci_enable_msi(alx->hw.pdev))
 			alx->flags |= ALX_FLAG_USING_MSI;
 	}
@@ -636,6 +749,12 @@ static void alx_init_intr(struct alx_priv *alx, bool msix)
 
 static void alx_disable_advanced_intr(struct alx_priv *alx)
 {
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		kfree(alx->msix_entries);
+		pci_disable_msix(alx->hw.pdev);
+		alx->flags &= ~ALX_FLAG_USING_MSIX;
+	}
+
 	if (alx->flags & ALX_FLAG_USING_MSI) {
 		pci_disable_msi(alx->hw.pdev);
 		alx->flags &= ~ALX_FLAG_USING_MSI;
@@ -645,22 +764,36 @@ static void alx_disable_advanced_intr(struct alx_priv *alx)
 static void alx_irq_enable(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
+	int i;
 
 	/* level-1 interrupt switch */
 	alx_write_mem32(hw, ALX_ISR, 0);
 	alx_write_mem32(hw, ALX_IMR, alx->int_mask);
 	alx_post_write(hw);
+
+	if (alx->flags & ALX_FLAG_USING_MSIX)
+		/* enable all msix irqs */
+		for (i = 0; i < alx->num_vec; i++)
+			alx_mask_msix(hw, i, false);
 }
 
 static void alx_irq_disable(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
+	int i;
 
 	alx_write_mem32(hw, ALX_ISR, ALX_ISR_DIS);
 	alx_write_mem32(hw, ALX_IMR, 0);
 	alx_post_write(hw);
 
-	synchronize_irq(alx->hw.pdev->irq);
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		for (i = 0; i < alx->num_vec; i++) {
+			alx_mask_msix(hw, i, true);
+			synchronize_irq(alx->msix_entries[i].vector);
+		}
+	} else {
+		synchronize_irq(alx->hw.pdev->irq);
+	}
 }
 
 static int alx_request_irq(struct alx_priv *alx)
@@ -672,6 +805,17 @@ static int alx_request_irq(struct alx_priv *alx)
 
 	msi_ctrl = (hw->imt >> 1) << ALX_MSI_RETRANS_TM_SHIFT;
 
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER, msi_ctrl);
+		err = alx_request_msix(alx);
+		if (!err)
+			goto out;
+
+		/* msix request failed, realloc resources */
+		alx_disable_advanced_intr(alx);
+		alx_init_intr(alx, false);
+	}
+
 	if (alx->flags & ALX_FLAG_USING_MSI) {
 		alx_write_mem32(hw, ALX_MSI_RETRANS_TIMER,
 				msi_ctrl | ALX_MSI_MASK_SEL_LINE);
@@ -690,14 +834,23 @@ static int alx_request_irq(struct alx_priv *alx)
 out:
 	if (!err)
 		alx_config_vector_mapping(alx);
+	else
+		netdev_err(alx->dev, "IRQ registration failed!\n");
 	return err;
 }
 
 static void alx_free_irq(struct alx_priv *alx)
 {
 	struct pci_dev *pdev = alx->hw.pdev;
+	int i;
 
-	free_irq(pdev->irq, alx);
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		/* we have only 2 vectors without multi queue support */
+		for (i = 0; i < 2; i++)
+			free_irq(alx->msix_entries[i].vector, alx);
+	} else {
+		free_irq(pdev->irq, alx);
+	}
 
 	alx_disable_advanced_intr(alx);
 }
@@ -1256,7 +1409,10 @@ static void alx_poll_controller(struct net_device *netdev)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 
-	if (alx->flags & ALX_FLAG_USING_MSI)
+	if (alx->flags & ALX_FLAG_USING_MSIX) {
+		alx_intr_msix_misc(0, alx);
+		alx_intr_msix_ring(0, alx);
+	} else if (alx->flags & ALX_FLAG_USING_MSI)
 		alx_intr_msi(0, alx);
 	else
 		alx_intr_legacy(0, alx);
-- 
2.7.4
