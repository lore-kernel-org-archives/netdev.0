From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 14/17] tg3: Move general int members to a per-int struct
Date: Fri, 28 Aug 2009 17:02:40 -0700
Message-ID: <1251585291.29702@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2861 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbZH2Wez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the last_tag, last_tag_irq, and hw_status device
members to a per-interrupt structure.  It also adds a new interrupt
mailbox member (int_mbox) and converts the code to use it rather than a
direct preprocessor constant.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |  134 +++++++++++++++++++++++++++++------------------------
 drivers/net/tg3.h |   12 +++--
 2 files changed, 80 insertions(+), 66 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 27ebe3b..5b8d6e0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -615,13 +615,13 @@ static void tg3_disable_ints(struct tg3 *tp)
 {
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	tw32_mailbox_f(tp->napi[0].int_mbox, 0x00000001);
 }
 
 static inline void tg3_cond_int(struct tg3 *tp)
 {
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
-	    (tp->hw_status->status & SD_STATUS_UPDATED))
+	    (tp->napi[0].hw_status->status & SD_STATUS_UPDATED))
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
 	else
 		tw32(HOSTCC_MODE, tp->coalesce_mode |
@@ -630,23 +630,22 @@ static inline void tg3_cond_int(struct tg3 *tp)
 
 static void tg3_enable_ints(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
 	tp->irq_sync = 0;
 	wmb();
 
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-		       (tp->last_tag << 24));
+	tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 	if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
-		tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			       (tp->last_tag << 24));
+		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 	tg3_cond_int(tp);
 }
 
 static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 {
 	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 	unsigned int work_exists = 0;
 
 	/* check for phy events */
@@ -673,8 +672,7 @@ static void tg3_int_reenable(struct tg3_napi *tnapi)
 {
 	struct tg3 *tp = tnapi->tp;
 
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-		     tp->last_tag << 24);
+	tw32_mailbox(tnapi->int_mbox, tnapi->last_tag << 24);
 	mmiowb();
 
 	/* When doing tagged status, this work check is unnecessary.
@@ -696,13 +694,14 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 
 static inline void tg3_netif_start(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
 	netif_wake_queue(tp->dev);
 	/* NOTE: unconditional netif_wake_queue is only appropriate
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
 	 */
-	napi_enable(&tp->napi[0].napi);
-	tp->hw_status->status |= SD_STATUS_UPDATED;
+	napi_enable(&tnapi->napi);
+	tnapi->hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
 
@@ -3902,9 +3901,9 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	else
 		current_link_up = tg3_setup_fiber_by_hand(tp, mac_status);
 
-	tp->hw_status->status =
+	tp->napi[0].hw_status->status =
 		(SD_STATUS_UPDATED |
-		 (tp->hw_status->status & ~SD_STATUS_LINK_CHG));
+		 (tp->napi[0].hw_status->status & ~SD_STATUS_LINK_CHG));
 
 	for (i = 0; i < 100; i++) {
 		tw32_f(MAC_STATUS, (MAC_STATUS_SYNC_CHANGED |
@@ -4284,7 +4283,7 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
 static void tg3_tx(struct tg3_napi *tnapi)
 {
 	struct tg3 *tp = tnapi->tp;
-	u32 hw_idx = tp->hw_status->idx[0].tx_consumer;
+	u32 hw_idx = tnapi->hw_status->idx[0].tx_consumer;
 	u32 sw_idx = tp->tx_cons;
 
 	while (sw_idx != hw_idx) {
@@ -4486,7 +4485,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	int received;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
-	hw_idx = tp->hw_status->idx[0].rx_producer;
+	hw_idx = tnapi->hw_status->idx[0].rx_producer;
 	/*
 	 * We need to order the read of hw_idx and the read of
 	 * the opaque cookie.
@@ -4617,7 +4616,7 @@ next_pkt_nopost:
 
 		/* Refresh hw_idx to see if there is new work */
 		if (sw_idx == hw_idx) {
-			hw_idx = tp->hw_status->idx[0].rx_producer;
+			hw_idx = tnapi->hw_status->idx[0].rx_producer;
 			rmb();
 		}
 	}
@@ -4645,7 +4644,7 @@ next_pkt_nopost:
 static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 {
 	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
@@ -4690,7 +4689,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 	struct tg3_napi *tnapi = container_of(napi, struct tg3_napi, napi);
 	struct tg3 *tp = tnapi->tp;
 	int work_done = 0;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 
 	while (1) {
 		work_done = tg3_poll_work(tnapi, work_done, budget);
@@ -4706,8 +4705,8 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			 * to tell the hw how much work has been processed,
 			 * so we must read it before checking for more work.
 			 */
-			tp->last_tag = sblk->status_tag;
-			tp->last_irq_tag = tp->last_tag;
+			tnapi->last_tag = sblk->status_tag;
+			tnapi->last_irq_tag = tnapi->last_tag;
 			rmb();
 		} else
 			sblk->status &= ~SD_STATUS_UPDATED;
@@ -4768,7 +4767,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	struct tg3_napi *tnapi = dev_id;
 	struct tg3 *tp = tnapi->tp;
 
-	prefetch(tp->hw_status);
+	prefetch(tnapi->hw_status);
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
@@ -4786,7 +4785,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	struct tg3_napi *tnapi = dev_id;
 	struct tg3 *tp = tnapi->tp;
 
-	prefetch(tp->hw_status);
+	prefetch(tnapi->hw_status);
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 	/*
 	 * Writing any value to intr-mbox-0 clears PCI INTA# and
@@ -4806,7 +4805,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 {
 	struct tg3_napi *tnapi = dev_id;
 	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 	unsigned int handled = 1;
 
 	/* In INTx mode, it is possible for the interrupt to arrive at
@@ -4855,7 +4854,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 {
 	struct tg3_napi *tnapi = dev_id;
 	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 	unsigned int handled = 1;
 
 	/* In INTx mode, it is possible for the interrupt to arrive at
@@ -4863,7 +4862,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * Reading the PCI State register will confirm whether the
 	 * interrupt is ours and will flush the status block.
 	 */
-	if (unlikely(sblk->status_tag == tp->last_irq_tag)) {
+	if (unlikely(sblk->status_tag == tnapi->last_irq_tag)) {
 		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
 		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 			handled = 0;
@@ -4890,7 +4889,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * so that the above check can report that the screaming interrupts
 	 * are unhandled.  Eventually they will be silenced.
 	 */
-	tp->last_irq_tag = sblk->status_tag;
+	tnapi->last_irq_tag = sblk->status_tag;
 
 	if (tg3_irq_sync(tp))
 		goto out;
@@ -4908,7 +4907,7 @@ static irqreturn_t tg3_test_isr(int irq, void *dev_id)
 {
 	struct tg3_napi *tnapi = dev_id;
 	struct tg3 *tp = tnapi->tp;
-	struct tg3_hw_status *sblk = tp->hw_status;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
 
 	if ((sblk->status & SD_STATUS_UPDATED) ||
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
@@ -5762,6 +5761,8 @@ static int tg3_init_rings(struct tg3 *tp)
  */
 static void tg3_free_consistent(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
+
 	kfree(tp->tx_buffers);
 	tp->tx_buffers = NULL;
 	if (tp->rx_rcb) {
@@ -5774,10 +5775,11 @@ static void tg3_free_consistent(struct tg3 *tp)
 			tp->tx_ring, tp->tx_desc_mapping);
 		tp->tx_ring = NULL;
 	}
-	if (tp->hw_status) {
+	if (tnapi->hw_status) {
 		pci_free_consistent(tp->pdev, TG3_HW_STATUS_SIZE,
-				    tp->hw_status, tp->status_mapping);
-		tp->hw_status = NULL;
+				    tnapi->hw_status,
+				    tnapi->status_mapping);
+		tnapi->hw_status = NULL;
 	}
 	if (tp->hw_stats) {
 		pci_free_consistent(tp->pdev, sizeof(struct tg3_hw_stats),
@@ -5793,6 +5795,8 @@ static void tg3_free_consistent(struct tg3 *tp)
  */
 static int tg3_alloc_consistent(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
+
 	if (tg3_rx_prodring_init(tp, &tp->prodring[0]))
 		return -ENOMEM;
 
@@ -5811,19 +5815,20 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 	if (!tp->tx_ring)
 		goto err_out;
 
-	tp->hw_status = pci_alloc_consistent(tp->pdev,
-					     TG3_HW_STATUS_SIZE,
-					     &tp->status_mapping);
-	if (!tp->hw_status)
+	tnapi->hw_status = pci_alloc_consistent(tp->pdev,
+						TG3_HW_STATUS_SIZE,
+						&tnapi->status_mapping);
+	if (!tnapi->hw_status)
 		goto err_out;
 
+	memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+
 	tp->hw_stats = pci_alloc_consistent(tp->pdev,
 					    sizeof(struct tg3_hw_stats),
 					    &tp->stats_mapping);
 	if (!tp->hw_stats)
 		goto err_out;
 
-	memset(tp->hw_status, 0, TG3_HW_STATUS_SIZE);
 	memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
 	return 0;
@@ -5885,6 +5890,7 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int
 static int tg3_abort_hw(struct tg3 *tp, int silent)
 {
 	int i, err;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	tg3_disable_ints(tp);
 
@@ -5936,8 +5942,8 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 	err |= tg3_stop_block(tp, BUFMGR_MODE, BUFMGR_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, MEMARB_MODE, MEMARB_MODE_ENABLE, silent);
 
-	if (tp->hw_status)
-		memset(tp->hw_status, 0, TG3_HW_STATUS_SIZE);
+	if (tnapi->hw_status)
+		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 	if (tp->hw_stats)
 		memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
@@ -6264,12 +6270,12 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 * sharing or irqpoll.
 	 */
 	tp->tg3_flags |= TG3_FLAG_CHIP_RESETTING;
-	if (tp->hw_status) {
-		tp->hw_status->status = 0;
-		tp->hw_status->status_tag = 0;
+	if (tp->napi[0].hw_status) {
+		tp->napi[0].hw_status->status = 0;
+		tp->napi[0].hw_status->status_tag = 0;
 	}
-	tp->last_tag = 0;
-	tp->last_irq_tag = 0;
+	tp->napi[0].last_tag = 0;
+	tp->napi[0].last_irq_tag = 0;
 	smp_mb();
 	synchronize_irq(tp->pdev->irq);
 
@@ -7210,9 +7216,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
-	     ((u64) tp->status_mapping >> 32));
+	     ((u64) tp->napi[0].status_mapping >> 32));
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
-	     ((u64) tp->status_mapping & 0xffffffff));
+	     ((u64) tp->napi[0].status_mapping & 0xffffffff));
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		/* Status/statistics block address.  See tg3_timer,
@@ -7241,7 +7247,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tg3_write_mem(tp, i, 0);
 		udelay(40);
 	}
-	memset(tp->hw_status, 0, TG3_HW_STATUS_SIZE);
+	memset(tp->napi[0].hw_status, 0, TG3_HW_STATUS_SIZE);
 
 	if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
 		tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
@@ -7294,7 +7300,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
-	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0);
+	tw32_mailbox_f(tp->napi[0].int_mbox, 0);
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
@@ -7596,7 +7602,7 @@ static void tg3_timer(unsigned long __opaque)
 		 * IRQ status the mailbox/status_block protocol the chip
 		 * uses with the cpu is race prone.
 		 */
-		if (tp->hw_status->status & SD_STATUS_UPDATED) {
+		if (tp->napi[0].hw_status->status & SD_STATUS_UPDATED) {
 			tw32(GRC_LOCAL_CTRL,
 			     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
 		} else {
@@ -7740,7 +7746,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	if (err)
 		return err;
 
-	tp->hw_status->status &= ~SD_STATUS_UPDATED;
+	tnapi->hw_status->status &= ~SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 
 	tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
@@ -7749,8 +7755,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	for (i = 0; i < 5; i++) {
 		u32 int_mbox, misc_host_ctrl;
 
-		int_mbox = tr32_mailbox(MAILBOX_INTERRUPT_0 +
-					TG3_64BIT_REG_LOW);
+		int_mbox = tr32_mailbox(tnapi->int_mbox);
 		misc_host_ctrl = tr32(TG3PCI_MISC_HOST_CTRL);
 
 		if ((int_mbox != 0) ||
@@ -8027,6 +8032,7 @@ err_out1:
 	u32 val32, val32_2, val32_3, val32_4, val32_5;
 	u16 val16;
 	int i;
+	struct tg3_hw_status *sblk = tp->napi[0]->hw_status;
 
 	pci_read_config_word(tp->pdev, PCI_STATUS, &val16);
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE, &val32);
@@ -8179,14 +8185,15 @@ err_out1:
 	       val32, val32_2, val32_3, val32_4, val32_5);
 
 	/* SW status block */
-	printk("DEBUG: Host status block [%08x:%08x:(%04x:%04x:%04x):(%04x:%04x)]\n",
-	       tp->hw_status->status,
-	       tp->hw_status->status_tag,
-	       tp->hw_status->rx_jumbo_consumer,
-	       tp->hw_status->rx_consumer,
-	       tp->hw_status->rx_mini_consumer,
-	       tp->hw_status->idx[0].rx_producer,
-	       tp->hw_status->idx[0].tx_consumer);
+	printk(KERN_DEBUG
+	 "Host status block [%08x:%08x:(%04x:%04x:%04x):(%04x:%04x)]\n",
+	       sblk->status,
+	       sblk->status_tag,
+	       sblk->rx_jumbo_consumer,
+	       sblk->rx_consumer,
+	       sblk->rx_mini_consumer,
+	       sblk->idx[0].rx_producer,
+	       sblk->idx[0].tx_consumer);
 
 	/* SW statistics block */
 	printk("DEBUG: Host statistics block [%08x:%08x:%08x:%08x]\n",
@@ -9824,8 +9831,12 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	dma_addr_t map;
 	int num_pkts, tx_len, rx_len, i, err;
 	struct tg3_rx_buffer_desc *desc;
+	struct tg3_napi *tnapi, *rnapi;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
+	tnapi = &tp->napi[0];
+	rnapi = &tp->napi[0];
+
 	if (loopback_mode == TG3_MAC_LOOPBACK) {
 		/* HW errata - mac loopback fails in some cases on 5780.
 		 * Normal traffic and PHY loopback are not affected by
@@ -9907,7 +9918,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	udelay(10);
 
-	rx_start_idx = tp->hw_status->idx[0].rx_producer;
+	rx_start_idx = rnapi->hw_status->idx[0].rx_producer;
 
 	num_pkts = 0;
 
@@ -9929,8 +9940,8 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 		udelay(10);
 
-		tx_idx = tp->hw_status->idx[0].tx_consumer;
-		rx_idx = tp->hw_status->idx[0].rx_producer;
+		tx_idx = tnapi->hw_status->idx[0].tx_consumer;
+		rx_idx = rnapi->hw_status->idx[0].rx_producer;
 		if ((tx_idx == tp->tx_prod) &&
 		    (rx_idx == (rx_start_idx + num_pkts)))
 			break;
@@ -13401,6 +13412,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
 	tp->napi[0].tp = tp;
+	tp->napi[0].int_mbox = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
 	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index aff3f04..f46e619 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2492,6 +2492,13 @@ struct tg3_rx_prodring_set {
 struct tg3_napi {
 	struct napi_struct		napi	____cacheline_aligned;
 	struct tg3			*tp;
+	struct tg3_hw_status		*hw_status;
+
+	u32				last_tag;
+	u32				last_irq_tag;
+	u32				int_mbox;
+
+	dma_addr_t			status_mapping;
 };
 
 struct tg3 {
@@ -2546,11 +2553,6 @@ struct tg3 {
 	struct net_device		*dev;
 	struct pci_dev			*pdev;
 
-	struct tg3_hw_status		*hw_status;
-	dma_addr_t			status_mapping;
-	u32				last_tag;
-	u32				last_irq_tag;
-
 	u32				msg_enable;
 
 	/* begin "tx thread" cacheline section */
-- 
1.6.3.3


