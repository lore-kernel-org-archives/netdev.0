From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 36/45] bna: Data Path and API Changes
Date: Mon, 18 Jul 2011 01:22:56 -0700
Message-ID: <1310977385-5268-26-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48263 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754714Ab1GRIY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:58 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Data path change:
   Accumulate the acks in the driver upto ~32K or 15 bits (+ 64, at the max),
   if poosible and then ack, otherwise ack and enable interrupts when no more
   packets are there to be processed.
 - Currently, mailbox MSIX vector is part of bna resources. Due to this, the
   MSIX vectors need to be allocated before bna_init(). Bfa_ioc_pci_init()
   called from bna_ioceth_init() called from bna_init() has MSIX vector setup.
   However, bfa_ioc_pci_init() needs to be called before enabling msix &
   allocating MSIX vector. Due to this, bna_init() needs to be called before
   enabling & allocating MSIX vectors. Hence, removing mailbox MSIX vector as
   a resource requirement for bna. Mailbox MSIX vector need not be explicitly
   passed for bna_init(), since mbox MSIX vector is always going to be 0.
 - Bnad_mbox_irq_alloc/free() function changes - removal of bna_intr_info
 - Bnad_res_alloc/free() function changes - removal of calling
   bnad_mbox_irq_alloc/free()
 - Calling bnad_enable_msix(), bnad_mbox_irq_alloc() after bna_init()
 - Calling bnad_mbox_irq_free() just before bnad_disable_msix()
 - IOC timer : use iocpf_timer to ioc_timer.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   46 +++++++++++-------
 drivers/net/bna/bfi.h     |    2 +-
 drivers/net/bna/bnad.c    |  115 +++++++++++++++++----------------------------
 drivers/net/bna/bnad.h    |    1 +
 drivers/net/bna/cna.h     |    4 +-
 5 files changed, 75 insertions(+), 93 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 940c94a..d35b91b 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -85,6 +85,7 @@ static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
 			 u32 boot_param);
 static u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
+static u32 bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr);
 static void bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc,
 						char *serial_num);
 static void bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc,
@@ -754,7 +755,7 @@ bfa_iocpf_sm_mismatch_entry(struct bfa_iocpf *iocpf)
 		bfa_ioc_pf_fwmismatch(iocpf->ioc);
 
 	iocpf->fw_mismatch_notified = true;
-	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+	mod_timer(&iocpf->ioc->ioc_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
 }
 
@@ -772,13 +773,13 @@ bfa_iocpf_sm_mismatch(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	case IOCPF_E_DISABLE:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
 		bfa_ioc_pf_disabled(ioc);
 		break;
 
 	case IOCPF_E_STOP:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_reset);
 		break;
 
@@ -859,7 +860,7 @@ bfa_iocpf_sm_hwinit(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	case IOCPF_E_DISABLE:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_ioc_sync_leave(ioc);
 		bfa_nw_ioc_hw_sem_release(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabled);
@@ -873,7 +874,7 @@ bfa_iocpf_sm_hwinit(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_enabling_entry(struct bfa_iocpf *iocpf)
 {
-	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+	mod_timer(&iocpf->ioc->ioc_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
 	/**
 	 * Enable Interrupts before sending fw IOC ENABLE cmd.
@@ -893,13 +894,13 @@ bfa_iocpf_sm_enabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_FWRSP_ENABLE:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_nw_ioc_hw_sem_release(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_ready);
 		break;
 
 	case IOCPF_E_INITFAIL:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		/*
 		 * !!! fall through !!!
 		 */
@@ -911,7 +912,7 @@ bfa_iocpf_sm_enabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 		break;
 
 	case IOCPF_E_DISABLE:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_nw_ioc_hw_sem_release(ioc);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling);
 		break;
@@ -951,7 +952,7 @@ bfa_iocpf_sm_ready(struct bfa_iocpf *iocpf, enum iocpf_event event)
 static void
 bfa_iocpf_sm_disabling_entry(struct bfa_iocpf *iocpf)
 {
-	mod_timer(&(iocpf->ioc)->iocpf_timer, jiffies +
+	mod_timer(&iocpf->ioc->ioc_timer, jiffies +
 		msecs_to_jiffies(BFA_IOC_TOV));
 	bfa_ioc_send_disable(iocpf->ioc);
 }
@@ -966,12 +967,12 @@ bfa_iocpf_sm_disabling(struct bfa_iocpf *iocpf, enum iocpf_event event)
 
 	switch (event) {
 	case IOCPF_E_FWRSP_DISABLE:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		bfa_fsm_set_state(iocpf, bfa_iocpf_sm_disabling_sync);
 		break;
 
 	case IOCPF_E_FAIL:
-		del_timer(&ioc->iocpf_timer);
+		del_timer(&ioc->ioc_timer);
 		/*
 		 * !!! fall through !!!
 		 */
@@ -1245,13 +1246,13 @@ bfa_nw_ioc_sem_get(void __iomem *sem_reg)
 
 	r32 = readl(sem_reg);
 
-	while (r32 && (cnt < BFA_SEM_SPINCNT)) {
+	while ((r32 & 1) && (cnt < BFA_SEM_SPINCNT)) {
 		cnt++;
 		udelay(2);
 		r32 = readl(sem_reg);
 	}
 
-	if (r32 == 0)
+	if (!(r32 & 1))
 		return true;
 
 	BUG_ON(!(cnt < BFA_SEM_SPINCNT));
@@ -1396,12 +1397,13 @@ bfa_ioc_lpu_stop(struct bfa_ioc *ioc)
 void
 bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 {
-	u32	pgnum;
+	u32	pgnum, pgoff;
 	u32	loff = 0;
 	int		i;
 	u32	*fwsig = (u32 *) fwhdr;
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
 
 	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr) / sizeof(u32));
@@ -1479,11 +1481,12 @@ bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 
 	ioc_fwstate = readl(ioc->ioc_regs.ioc_fwstate);
 
-	boot_env = BFI_FWBOOT_ENV_OS;
-
 	if (force)
 		ioc_fwstate = BFI_IOC_UNINIT;
 
+	boot_env = BFI_FWBOOT_ENV_OS;
+
+
 	/**
 	 * check if firmware is valid
 	 */
@@ -1636,7 +1639,7 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 		    u32 boot_env)
 {
 	u32 *fwimg;
-	u32 pgnum;
+	u32 pgnum, pgoff;
 	u32 loff = 0;
 	u32 chunkno = 0;
 	u32 i;
@@ -1650,6 +1653,7 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	fwimg = bfa_cb_image_get_chunk(bfa_ioc_asic_gen(ioc), chunkno);
 
 	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
+	pgoff = bfa_ioc_smem_pgoff(ioc, loff);
 
 	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
 
@@ -1685,7 +1689,7 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 	/*
 	 * Set boot type, env and device mode at the end.
 	*/
-	asicmode = BFI_FWBOOT_ASICMODE(ioc->asic_gen, ioc->asic_mode,
+	asicmode = BFI_FWBOOT_DEVMODE(ioc->asic_gen, ioc->asic_mode,
 					ioc->port0_mode, ioc->port1_mode);
 	writel(asicmode, ((ioc->ioc_regs.smem_page_start)
 			+ BFI_FWBOOT_DEVMODE_OFF));
@@ -2086,6 +2090,12 @@ bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr)
 	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
 }
 
+static u32
+bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr)
+{
+	return PSS_SMEM_PGOFF(fmaddr);
+}
+
 /**
  * Register mailbox message handler function, to be called by common modules
  */
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 8d238a7..d422857 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -307,7 +307,7 @@ struct bfi_ioc_image_hdr {
 #define BFI_FWBOOT_DEVMODE_OFF		4
 #define BFI_FWBOOT_TYPE_OFF		8
 #define BFI_FWBOOT_ENV_OFF		12
-#define BFI_FWBOOT_ASICMODE(__asic_gen, __asic_mode, __p0_mode, __p1_mode) \
+#define BFI_FWBOOT_DEVMODE(__asic_gen, __asic_mode, __p0_mode, __p1_mode) \
 	(((u32)(__asic_gen)) << 24 |	\
 	 ((u32)(__asic_mode)) << 16 |	\
 	 ((u32)(__p0_mode)) << 8 |	\
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 3f9ddbf..f6b7401 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -554,8 +554,8 @@ next:
 
 	BNA_QE_INDX_ADD(ccb->producer_index, wis, ccb->q_depth);
 
-	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-		bna_ib_ack(ccb->i_dbell, packets);
+	rx_ctrl->pkts_to_ack += packets;
+
 	bnad_refill_rxq(bnad, ccb->rcb[0]);
 	if (ccb->rcb[1])
 		bnad_refill_rxq(bnad, ccb->rcb[1]);
@@ -1056,6 +1056,8 @@ bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 		if (!ccb)
 			continue;
 
+		rx_ctrl->pkts_to_ack += 0;
+
 		bnad_cq_cmpl_init(bnad, ccb);
 
 		for (j = 0; j < BNAD_MAX_RXQ_PER_RXP; j++) {
@@ -1195,23 +1197,17 @@ err_return:
 
 /* Free IRQ for Mailbox */
 static void
-bnad_mbox_irq_free(struct bnad *bnad,
-		   struct bna_intr_info *intr_info)
+bnad_mbox_irq_free(struct bnad *bnad)
 {
 	int irq;
 	unsigned long flags;
 
-	if (intr_info->idl == NULL)
-		return;
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bnad_disable_mbox_irq(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	irq = BNAD_GET_MBOX_IRQ(bnad);
 	free_irq(irq, bnad);
-
-	kfree(intr_info->idl);
 }
 
 /*
@@ -1220,32 +1216,22 @@ bnad_mbox_irq_free(struct bnad *bnad,
  * from bna
  */
 static int
-bnad_mbox_irq_alloc(struct bnad *bnad,
-		    struct bna_intr_info *intr_info)
+bnad_mbox_irq_alloc(struct bnad *bnad)
 {
 	int		err = 0;
 	unsigned long	irq_flags, flags;
 	u32	irq;
 	irq_handler_t	irq_handler;
 
-	/* Mbox should use only 1 vector */
-
-	intr_info->idl = kzalloc(sizeof(*(intr_info->idl)), GFP_KERNEL);
-	if (!intr_info->idl)
-		return -ENOMEM;
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (bnad->cfg_flags & BNAD_CF_MSIX) {
 		irq_handler = (irq_handler_t)bnad_msix_mbox_handler;
 		irq = bnad->msix_table[BNAD_MAILBOX_MSIX_INDEX].vector;
 		irq_flags = 0;
-		intr_info->intr_type = BNA_INTR_T_MSIX;
-		intr_info->idl[0].vector = BNAD_MAILBOX_MSIX_INDEX;
 	} else {
 		irq_handler = (irq_handler_t)bnad_isr;
 		irq = bnad->pcidev->irq;
 		irq_flags = IRQF_SHARED;
-		intr_info->intr_type = BNA_INTR_T_INTX;
 	}
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -1262,11 +1248,6 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 	err = request_irq(irq, irq_handler, irq_flags,
 			  bnad->mbox_irq_name, bnad);
 
-	if (err) {
-		kfree(intr_info->idl);
-		intr_info->idl = NULL;
-	}
-
 	return err;
 }
 
@@ -1723,6 +1704,21 @@ poll_exit:
 	return rcvd;
 }
 
+#define BNAD_NAPI_POLL_QUOTA		64
+static void
+bnad_napi_init(struct bnad *bnad, u32 rx_id)
+{
+	struct bnad_rx_ctrl *rx_ctrl;
+	int i;
+
+	/* Initialize & enable NAPI */
+	for (i = 0; i <	bnad->num_rxp_per_rx; i++) {
+		rx_ctrl = &bnad->rx_info[rx_id].rx_ctrl[i];
+		netif_napi_add(bnad->netdev, &rx_ctrl->napi,
+			       bnad_napi_poll_rx, BNAD_NAPI_POLL_QUOTA);
+	}
+}
+
 static void
 bnad_napi_enable(struct bnad *bnad, u32 rx_id)
 {
@@ -1786,29 +1782,6 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 	bnad_tx_res_free(bnad, res_info);
 }
 
-/*
- * Sets up bnad->num_tx depending on the current value (already
- * adjusted based on MSIX vectors available and ETS support in
- * the chip
- */
-static void
-bnad_num_txq_set(struct bnad *bnad)
-{
-	struct bna *bna	= &bnad->bna;
-	struct bna_attr	attr;
-	unsigned long		flags;
-
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-	attr = bna->ioceth.attr;
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-
-	if (attr.max_ets_groups < BFI_TX_MAX_PRIO)
-		bnad->num_txq_per_tx = 1;
-	else
-		bnad->num_txq_per_tx = min((u32)attr.max_ets_groups,
-					(u32)bnad->num_txq_per_tx);
-}
-
 /* Should be held with conf_lock held */
 int
 bnad_setup_tx(struct bnad *bnad, u32 tx_id)
@@ -1825,8 +1798,6 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 
 	tx_info->tx_id = tx_id;
 
-	bnad_num_txq_set(bnad);
-
 	/* Initialize the Tx object configuration */
 	tx_config->num_txq = bnad->num_txq_per_tx;
 	tx_config->txq_depth = bnad->txq_depth;
@@ -2026,8 +1997,11 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 		goto err_return;
 	rx_info->rx = rx;
 
-	/* Enable NAPI */
-	bnad_napi_enable(bnad, rx_id);
+	/*
+	 * Init NAPI, so that state is set to NAPI_STATE_SCHED,
+	 * so that IRQ handler cannot schedule NAPI at this point.
+	 */
+	bnad_napi_init(bnad, rx_id);
 
 	/* Register ISR for the Rx object */
 	if (intr_info->intr_type == BNA_INTR_T_MSIX) {
@@ -2053,6 +2027,9 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	bna_rx_enable(rx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
+	/* Enable scheduling of NAPI */
+	bnad_napi_enable(bnad, rx_id);
+
 	return 0;
 
 err_return:
@@ -2397,12 +2374,8 @@ bnad_res_free(struct bnad *bnad, struct bna_res_info *res_info,
 {
 	int i;
 
-	for (i = 0; i < res_val_max; i++) {
-		if (res_info[i].res_type == BNA_RES_T_MEM)
-			bnad_mem_free(bnad, &res_info[i].res_u.mem_info);
-		else
-			bnad_mbox_irq_free(bnad, &res_info[i].res_u.intr_info);
-	}
+	for (i = 0; i < res_val_max; i++)
+		bnad_mem_free(bnad, &res_info[i].res_u.mem_info);
 }
 
 /* Allocates memory and interrupt resources for BNA */
@@ -2413,11 +2386,7 @@ bnad_res_alloc(struct bnad *bnad, struct bna_res_info *res_info,
 	int i, err;
 
 	for (i = 0; i < res_val_max; i++) {
-		if (res_info[i].res_type == BNA_RES_T_MEM)
-			err = bnad_mem_alloc(bnad, &res_info[i].res_u.mem_info);
-		else
-			err = bnad_mbox_irq_alloc(bnad,
-						  &res_info[i].res_u.intr_info);
+		err = bnad_mem_alloc(bnad, &res_info[i].res_u.mem_info);
 		if (err)
 			goto err_return;
 	}
@@ -2637,11 +2606,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	tcb = bnad->tx_info[0].tcb[txq_id];
 
-	if (unlikely(!tcb)) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
 	unmap_q = tcb->unmap_q;
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
@@ -3351,8 +3315,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/* Set link to down state */
 	netif_carrier_off(netdev);
 
-	bnad_enable_msix(bnad);
-
 	/* Get resource requirement form bna */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_res_req(&bnad->res_info[0]);
@@ -3377,6 +3339,12 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	bnad->stats.bna_stats = &bna->stats;
 
+	bnad_enable_msix(bnad);
+	err = bnad_mbox_irq_alloc(bnad);
+	if (err)
+		goto res_free;
+
+
 	/* Set up timers */
 	setup_timer(&bnad->bna.ioceth.ioc.ioc_timer, bnad_ioc_timeout,
 				((unsigned long)bnad));
@@ -3388,7 +3356,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 				((unsigned long)bnad));
 
 	/* Now start the timer before calling IOC */
-	mod_timer(&bnad->bna.ioceth.ioc.iocpf_timer,
+	mod_timer(&bnad->bna.ioceth.ioc.ioc_timer,
 		  jiffies + msecs_to_jiffies(BNA_IOC_TIMER_FREQ));
 
 	/*
@@ -3455,9 +3423,11 @@ disable_ioceth:
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	bnad_mbox_irq_free(bnad);
+	bnad_disable_msix(bnad);
+res_free:
 	bnad_res_free(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
 drv_uninit:
-	bnad_disable_msix(bnad);
 	bnad_uninit(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
@@ -3497,6 +3467,7 @@ bnad_pci_remove(struct pci_dev *pdev)
 
 	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
 	bnad_res_free(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
+	bnad_mbox_irq_free(bnad);
 	bnad_disable_msix(bnad);
 	bnad_pci_uninit(pdev);
 	mutex_unlock(&bnad->conf_mutex);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 4f9da1c..7f0648d 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -54,6 +54,7 @@ struct bnad_rx_ctrl {
 	struct bnad *bnad;
 	unsigned long  flags;
 	struct napi_struct	napi;
+	u16			pkts_to_ack;
 };
 
 #define BNAD_RXMODE_PROMISC_DEFAULT	BNA_RXMODE_PROMISC
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index 50fce15..94005d6 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -34,8 +34,8 @@
 #include <linux/list.h>
 
 #define bfa_sm_fault(__event)    do {                            \
-	pr_err("SM Assertion failure: %s: %d: event = %d", __FILE__, __LINE__, \
-		__event); \
+	pr_err("SM Assertion failure: %s: %d: event = %d\n",	\
+		 __FILE__, __LINE__, __event);			\
 } while (0)
 
 extern char bfa_version[];
-- 
1.7.1

