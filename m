From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 5/6] tg3: implementation of a non-NAPI mode
Date: Fri, 16 Dec 2011 10:19:48 -0800
Message-ID: <6d55ce25f5f237a4538f6a2fcd2609b877669297.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>,
	Tom Herbert <therbert@google.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:36278 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760363Ab1LPSZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:25:42 -0500
Received: by eekc1 with SMTP id c1so102834eek.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:25:41 -0800 (PST)
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

The tg3 NIC has a hard limit of 511 descriptors for the receive ring.
Under heavy load of small packets, this device receive queue may not
be serviced fast enough to prevent packets drops.  This could be due
to a variety of reasons such as lengthy processing delays of packets
in the stack, softirqs being disabled too long, etc. If the driver is
run in non-NAPI mode, the RX queue is serviced in the device
interrupt, which is much less likely to be deferred for a substantial
period of time.

There are some effects in not using NAPI that need to be considered.
It does increase the chance of live-lock in interrupt handler,
although since the tg3 does interrupt coalescing this is very unlikely
to occur.  Also, more code is being run with interrupts disabled
potentially deferring other hardware interrupts.  The amount of time
spent in the interrupt handler should be minimized by dequeuing
packets of the device queue and queuing them to a host queue as
quickly as possible.

The default mode of operation remains NAPI and its performances are
kept unchanged (code unchanged). Non-NAPI mode is enabled by
commenting-out CONFIG_TIGON3_NAPI Kconfig parameter.



Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/Kconfig |    8 ++
 drivers/net/ethernet/broadcom/tg3.c   |  151 +++++++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h   |    5 +
 3 files changed, 157 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index f15e72e..e808b3d 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -107,6 +107,14 @@ config TIGON3
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.
 
+if TIGON3
+config TIGON3_NAPI
+	bool "Use Rx Polling (NAPI)"
+	default y
+	---help---
+	  Use NAPI for Tigon3 driver. If unsure, say Y.
+endif # TIGON3
+
 config BNX2X
 	tristate "Broadcom NetXtremeII 10Gb support"
 	depends on PCI
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ecd6ea5..e3f221d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5349,7 +5349,11 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		pkts_compl++;
 		bytes_compl += skb->len;
 
+#ifdef CONFIG_TIGON3_NAPI
 		dev_kfree_skb(skb);
+#else
+		dev_kfree_skb_any(skb);
+#endif
 
 		if (unlikely(tx_bug)) {
 			tg3_tx_recover(tp);
@@ -5370,11 +5374,15 @@ static void tg3_tx(struct tg3_napi *tnapi)
 
 	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
+#ifdef CONFIG_TIGON3_NAPI
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_tx_queue_stopped(txq) &&
 		    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
 			netif_tx_wake_queue(txq);
 		__netif_tx_unlock(txq);
+#else
+		netif_tx_wake_queue(txq);
+#endif
 	}
 }
 
@@ -5694,7 +5702,11 @@ static inline int tg3_coal_adaptive_rx(struct tg3 *tp, int received)
  * If both the host and chip were to write into the same ring, cache line
  * eviction could occur since both entities want it in an exclusive state.
  */
+#ifdef CONFIG_TIGON3_NAPI
 static int tg3_rx(struct tg3_napi *tnapi, int budget)
+#else
+static int tg3_rx(struct tg3_napi *tnapi)
+#endif
 {
 	struct tg3 *tp = tnapi->tp;
 	u32 work_mask, rx_std_posted = 0;
@@ -5714,7 +5726,11 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	received = 0;
 	std_prod_idx = tpr->rx_std_prod_idx;
 	jmb_prod_idx = tpr->rx_jmb_prod_idx;
-	while (sw_idx != hw_idx && budget > 0) {
+	while (sw_idx != hw_idx
+#ifdef CONFIG_TIGON3_NAPI
+	       && budget > 0
+#endif
+		) {
 		struct ring_info *ri;
 		struct tg3_rx_buffer_desc *desc = &tnapi->rx_rcb[sw_idx];
 		unsigned int len;
@@ -5819,10 +5835,16 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			__vlan_hwaccel_put_tag(skb,
 					       desc->err_vlan & RXD_VLAN_MASK);
 
+#ifdef CONFIG_TIGON3_NAPI
 		napi_gro_receive(&tnapi->napi, skb);
+#else
+		netif_rx(skb);
+#endif
 
 		received++;
+#ifdef CONFIG_TIGON3_NAPI
 		budget--;
+#endif
 
 next_pkt:
 		(*post_ptr)++;
@@ -5868,7 +5890,10 @@ next_pkt_nopost:
 				     tpr->rx_jmb_prod_idx);
 		}
 		mmiowb();
-	} else if (work_mask) {
+	}
+#ifdef CONFIG_TIGON3_NAPI
+	/* TG3_FLG3_ENABLE_RSS is only set in NAPI mode. */
+	else if (work_mask) {
 		/* rx_std_buffers[] and rx_jmb_buffers[] entries must be
 		 * updated before the producer indices can be updated.
 		 */
@@ -5880,6 +5905,7 @@ next_pkt_nopost:
 		if (tnapi != &tp->napi[1])
 			napi_schedule(&tp->napi[1].napi);
 	}
+#endif
 
 	return received;
 }
@@ -5893,7 +5919,12 @@ static void tg3_poll_link(struct tg3 *tp)
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
 				       (sblk->status & ~SD_STATUS_LINK_CHG);
+
+#ifdef CONFIG_TIGON3_NAPI
 			spin_lock(&tp->lock);
+#else
+			spin_lock_bh(&tp->lock);
+#endif
 			if (tg3_flag(tp, USE_PHYLIB)) {
 				tw32_f(MAC_STATUS,
 				     (MAC_STATUS_SYNC_CHANGED |
@@ -5903,11 +5934,16 @@ static void tg3_poll_link(struct tg3 *tp)
 				udelay(40);
 			} else
 				tg3_setup_phy(tp, 0);
+#ifdef CONFIG_TIGON3_NAPI
 			spin_unlock(&tp->lock);
+#else
+			spin_unlock_bh(&tp->lock);
+#endif
 		}
 	}
 }
 
+#ifdef CONFIG_TIGON3_NAPI
 static int tg3_rx_prodring_xfer(struct tg3 *tp,
 				struct tg3_rx_prodring_set *dpr,
 				struct tg3_rx_prodring_set *spr)
@@ -6207,6 +6243,58 @@ tx_recovery:
 	return work_done;
 }
 
+#else /* !CONFIG_TIGON3_NAPI */
+
+static void tg3_poll_link_task(struct work_struct *work)
+{
+	struct tg3 *tp = container_of(work, struct tg3, poll_link_task);
+	tg3_poll_link(tp);
+}
+
+static void tg3_int_work(struct tg3_napi *tnapi)
+{
+	struct tg3 *tp = tnapi->tp;
+	struct tg3_hw_status *sblk = tnapi->hw_status;
+
+	if (tg3_flag(tp, TAGGED_STATUS)) {
+		tnapi->last_irq_tag = sblk->status_tag;
+		tnapi->last_tag = tnapi->last_irq_tag;
+	}
+
+	if (!(tg3_flag(tp, USE_LINKCHG_REG) || tg3_flag(tp, POLL_SERDES))) {
+		if (sblk->status & SD_STATUS_LINK_CHG)
+			schedule_work(&tp->poll_link_task);
+	}
+
+	/* run TX completion thread */
+	if (tnapi->hw_status->idx[0].tx_consumer != tnapi->tx_cons) {
+		tg3_tx(tnapi);
+		if (unlikely(tg3_flag(tp, TX_RECOVERY_PENDING)))
+			goto tx_recovery;
+	}
+
+	/* run RX thread */
+	if (*(tnapi->rx_rcb_prod_idx) != tnapi->rx_rcb_ptr)
+		tg3_rx(tnapi);
+
+	if (unlikely(tg3_flag(tp, TX_RECOVERY_PENDING)))
+		goto tx_recovery;
+
+	if (!(tg3_flag(tp, TAGGED_STATUS)))
+		sblk->status &= ~SD_STATUS_UPDATED;
+
+	/* Reenable interrupts */
+	tg3_int_reenable(tnapi);
+
+	return;
+
+tx_recovery:
+	schedule_work(&tp->reset_task);
+}
+
+#endif /* CONFIG_TIGON3_NAPI */
+
+#ifdef CONFIG_TIGON3_NAPI
 static void tg3_napi_disable(struct tg3 *tp)
 {
 	int i;
@@ -6239,11 +6327,14 @@ static void tg3_napi_fini(struct tg3 *tp)
 	for (i = 0; i < tp->irq_cnt; i++)
 		netif_napi_del(&tp->napi[i].napi);
 }
+#endif
 
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_disable(tp);
+#endif
 	netif_tx_disable(tp->dev);
 }
 
@@ -6255,7 +6346,9 @@ static inline void tg3_netif_start(struct tg3 *tp)
 	 */
 	netif_tx_wake_all_queues(tp->dev);
 
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_enable(tp);
+#endif
 	tp->napi[0].hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
@@ -6303,7 +6396,11 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 		prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
+#ifdef CONFIG_TIGON3_NAPI
 		napi_schedule(&tnapi->napi);
+#else
+		tg3_int_work(tnapi);
+#endif
 
 	return IRQ_HANDLED;
 }
@@ -6329,7 +6426,11 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(tnapi->int_mbox, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
+#ifdef CONFIG_TIGON3_NAPI
 		napi_schedule(&tnapi->napi);
+#else
+		tg3_int_work(tnapi);
+#endif
 
 	return IRQ_RETVAL(1);
 }
@@ -6371,7 +6472,11 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tnapi))) {
 		prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
+#ifdef CONFIG_TIGON3_NAPI
 		napi_schedule(&tnapi->napi);
+#else
+		tg3_int_work(tnapi);
+#endif
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -6429,7 +6534,11 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 
 	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 
+#ifdef CONFIG_TIGON3_NAPI
 	napi_schedule(&tnapi->napi);
+#else
+	tg3_int_work(tnapi);
+#endif
 
 out:
 	return IRQ_RETVAL(handled);
@@ -6470,7 +6579,9 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
 		tp->irq_sync = 0;
+#ifdef CONFIG_TIGON3_NAPI
 		tg3_napi_enable(tp);
+#endif
 		dev_close(tp->dev);
 		tg3_full_lock(tp, 0);
 	}
@@ -6804,10 +6915,15 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	budget = tg3_tx_avail(tnapi);
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	/* When in NAPI mode, we are running in BH disabled context
+	 * with netif_tx_lock and TX reclaim runs via tp->napi.poll
+	 * inside of a software interrupt.  Furthermore, IRQ
+	 * processing runs lockless so we have no IRQ context
+	 * deadlocks to worry about either.  Rejoice!
+	 *
+	 * When in non-NAPI mode, we are running in BH disabled
+	 * context with netif_tx_lock and TX reclaim runs lockless in
+	 * interrupt context.
 	 */
 	if (unlikely(budget <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_tx_queue_stopped(txq)) {
@@ -9847,9 +9963,10 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		goto err_out1;
 
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_init(tp);
-
 	tg3_napi_enable(tp);
+#endif
 
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
@@ -9942,8 +10059,10 @@ err_out3:
 	}
 
 err_out2:
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_disable(tp);
 	tg3_napi_fini(tp);
+#endif
 	tg3_free_consistent(tp);
 
 err_out1:
@@ -9958,7 +10077,9 @@ static int tg3_close(struct net_device *dev)
 	int i;
 	struct tg3 *tp = netdev_priv(dev);
 
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_disable(tp);
+#endif
 	tg3_reset_task_cancel(tp);
 
 	netif_tx_stop_all_queues(dev);
@@ -9988,7 +10109,9 @@ static int tg3_close(struct net_device *dev)
 	memset(&tp->net_stats_prev, 0, sizeof(tp->net_stats_prev));
 	memset(&tp->estats_prev, 0, sizeof(tp->estats_prev));
 
+#ifdef CONFIG_TIGON3_NAPI
 	tg3_napi_fini(tp);
+#endif
 
 	tg3_free_consistent(tp);
 
@@ -14223,10 +14346,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tg3_flag_set(tp, 1SHOT_MSI);
 		}
 
+#ifdef CONFIG_TIGON3_NAPI
+		/* Do not enable MSIX in non-NAPI mode. */
 		if (tg3_flag(tp, 57765_PLUS)) {
 			tg3_flag_set(tp, SUPPORT_MSIX);
 			tp->irq_max = TG3_IRQ_MAX_VECS;
 		}
+#endif
 	}
 
 	if (tg3_flag(tp, 5755_PLUS))
@@ -15601,6 +15727,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
+#ifndef CONFIG_TIGON3_NAPI
+	INIT_WORK(&tp->poll_link_task, tg3_poll_link_task);
+#endif
 
 	tp->regs = pci_ioremap_bar(pdev, BAR_0);
 	if (!tp->regs) {
@@ -15821,6 +15950,14 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
+#ifdef CONFIG_TIGON3_NAPI
+	netdev_info(dev, "Tigon3 driver %s loaded in NAPI mode.\n",
+		    DRV_MODULE_VERSION);
+#else
+	netdev_info(dev, "Tigon3 driver %s loaded in non-NAPI mode.\n",
+		    DRV_MODULE_VERSION);
+#endif
+
 	netdev_info(dev, "Tigon3 [partno(%s) rev %04x] (%s) MAC address %pM\n",
 		    tp->board_part_number,
 		    tp->pci_chip_rev_id,
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 695cf14..b023e96 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2832,7 +2832,9 @@ struct tg3_rx_prodring_set {
 #define TG3_IRQ_MAX_VECS		TG3_IRQ_MAX_VECS_RSS
 
 struct tg3_napi {
+#ifdef CONFIG_TIGON3_NAPI
 	struct napi_struct		napi	____cacheline_aligned;
+#endif
 	struct tg3			*tp;
 	struct tg3_hw_status		*hw_status;
 
@@ -3167,6 +3169,9 @@ struct tg3 {
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
 	struct work_struct		reset_task;
+#ifndef CONFIG_TIGON3_NAPI
+	struct work_struct              poll_link_task;
+#endif
 
 	int				nvram_lock_cnt;
 	u32				nvram_size;
-- 
1.7.3.1
