From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] chelsio: working NAPI
Date: Fri, 8 Dec 2006 11:08:33 -0800
Message-ID: <20061208110833.1988ca8e@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50485 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761164AbWLHTJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 14:09:22 -0500
To: Jeff Garzik <jgarzik@pobox.com>, Felix Marti <felix@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver tries to enable/disable NAPI at runtime, but 
does so in an unsafe manner, and the NAPI interrupt handling is
a mess. Replace it with a compile time selected NAPI implementation.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/Kconfig         |    8 +++
 drivers/net/chelsio/cxgb2.c |   23 ++------
 drivers/net/chelsio/sge.c   |  113 ++++++++++++++++++--------------------------
 drivers/net/chelsio/sge.h   |    4 +
 4 files changed, 66 insertions(+), 82 deletions(-)

--- chelsio.orig/drivers/net/chelsio/sge.c
+++ chelsio/drivers/net/chelsio/sge.c
@@ -1413,16 +1413,20 @@ static int sge_rx(struct sge *sge, struc
 
 	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
 		st->vlan_xtract++;
-		if (adapter->params.sge.polling)
+#ifdef CONFIG_CHELSIO_T1_NAPI
 			vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
 						 ntohs(p->vlan));
-		else
+#else
 			vlan_hwaccel_rx(skb, adapter->vlan_grp,
 					ntohs(p->vlan));
-	} else if (adapter->params.sge.polling)
+#endif
+	} else {
+#ifdef CONFIG_CHELSIO_T1_NAPI
 		netif_receive_skb(skb);
-	else
+#else
 		netif_rx(skb);
+#endif
+	}
 	return 0;
 }
 
@@ -1572,6 +1576,7 @@ static int process_responses(struct adap
 	return budget;
 }
 
+#ifdef CONFIG_CHELSIO_T1_NAPI
 /*
  * A simpler version of process_responses() that handles only pure (i.e.,
  * non data-carrying) responses.  Such respones are too light-weight to justify
@@ -1619,92 +1624,76 @@ static int process_pure_responses(struct
  * or protection from interrupts as data interrupts are off at this point and
  * other adapter interrupts do not interfere.
  */
-static int t1_poll(struct net_device *dev, int *budget)
+int t1_poll(struct net_device *dev, int *budget)
 {
 	struct adapter *adapter = dev->priv;
 	int effective_budget = min(*budget, dev->quota);
-
 	int work_done = process_responses(adapter, effective_budget);
+
 	*budget -= work_done;
 	dev->quota -= work_done;
 
 	if (work_done >= effective_budget)
 		return 1;
 
+ 	spin_lock_irq(&adapter->async_lock);
 	__netif_rx_complete(dev);
-
-	/*
-	 * Because we don't atomically flush the following write it is
-	 * possible that in very rare cases it can reach the device in a way
-	 * that races with a new response being written plus an error interrupt
-	 * causing the NAPI interrupt handler below to return unhandled status
-	 * to the OS.  To protect against this would require flushing the write
-	 * and doing both the write and the flush with interrupts off.  Way too
-	 * expensive and unjustifiable given the rarity of the race.
-	 */
 	writel(adapter->sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-	return 0;
-}
+	writel(adapter->slow_intr_mask | F_PL_INTR_SGE_DATA,
+	       adapter->regs + A_PL_ENABLE);
+ 	spin_unlock_irq(&adapter->async_lock);
 
-/*
- * Returns true if the device is already scheduled for polling.
- */
-static inline int napi_is_scheduled(struct net_device *dev)
-{
-	return test_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	return 0;
 }
 
 /*
  * NAPI version of the main interrupt handler.
  */
-static irqreturn_t t1_interrupt_napi(int irq, void *data)
+irqreturn_t t1_interrupt(int irq, void *data)
 {
-	int handled;
 	struct adapter *adapter = data;
+ 	struct net_device *dev = adapter->sge->netdev;
 	struct sge *sge = adapter->sge;
-	struct respQ *q = &adapter->sge->respQ;
+ 	u32 cause;
+	int handled = 0;
 
-	/*
-	 * Clear the SGE_DATA interrupt first thing.  Normally the NAPI
-	 * handler has control of the response queue and the interrupt handler
-	 * can look at the queue reliably only once it knows NAPI is off.
-	 * We can't wait that long to clear the SGE_DATA interrupt because we
-	 * could race with t1_poll rearming the SGE interrupt, so we need to
-	 * clear the interrupt speculatively and really early on.
-	 */
-	writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
+	cause = readl(adapter->regs + A_PL_CAUSE);
+	if (cause == 0 || cause == ~0)
+		return IRQ_NONE;
 
 	spin_lock(&adapter->async_lock);
-	if (!napi_is_scheduled(sge->netdev)) {
+ 	if (cause & F_PL_INTR_SGE_DATA) {
+		struct respQ *q = &adapter->sge->respQ;
 		struct respQ_e *e = &q->entries[q->cidx];
 
-		if (e->GenerationBit == q->genbit) {
-			if (e->DataValid ||
-			    process_pure_responses(adapter, e)) {
-				if (likely(__netif_rx_schedule_prep(sge->netdev)))
-					__netif_rx_schedule(sge->netdev);
-				else if (net_ratelimit())
-					printk(KERN_INFO
-					       "NAPI schedule failure!\n");
-			} else
-				writel(q->cidx, adapter->regs + A_SG_SLEEPING);
+ 		handled = 1;
+ 		writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
+
+		if (e->GenerationBit == q->genbit &&
+		    __netif_rx_schedule_prep(dev)) {
+			if (e->DataValid || process_pure_responses(adapter, e)) {
+				/* mask off data IRQ */
+				writel(adapter->slow_intr_mask,
+				       adapter->regs + A_PL_ENABLE);
+				__netif_rx_schedule(sge->netdev);
+				goto unlock;
+			}
+			/* no data, no NAPI needed */
+			netif_poll_enable(dev);
+
+		}
+		writel(q->cidx, adapter->regs + A_SG_SLEEPING);
+	} else
+		handled = t1_slow_intr_handler(adapter);
 
-			handled = 1;
-			goto unlock;
-		} else
-			writel(q->cidx, adapter->regs + A_SG_SLEEPING);
-	}  else if (readl(adapter->regs + A_PL_CAUSE) & F_PL_INTR_SGE_DATA) {
-	        printk(KERN_ERR "data interrupt while NAPI running\n");
-	}
-	
-	handled = t1_slow_intr_handler(adapter);
 	if (!handled)
 		sge->stats.unhandled_irqs++;
- unlock:
+unlock:
 	spin_unlock(&adapter->async_lock);
 	return IRQ_RETVAL(handled != 0);
 }
 
+#else
 /*
  * Main interrupt handler, optimized assuming that we took a 'DATA'
  * interrupt.
@@ -1720,7 +1709,7 @@ static irqreturn_t t1_interrupt_napi(int
  * 5. If we took an interrupt, but no valid respQ descriptors was found we
  *      let the slow_intr_handler run and do error handling.
  */
-static irqreturn_t t1_interrupt(int irq, void *cookie)
+irqreturn_t t1_interrupt(int irq, void *cookie)
 {
 	int work_done;
 	struct respQ_e *e;
@@ -1752,11 +1741,7 @@ static irqreturn_t t1_interrupt(int irq,
 	spin_unlock(&adapter->async_lock);
 	return IRQ_RETVAL(work_done != 0);
 }
-
-irq_handler_t t1_select_intr_handler(adapter_t *adapter)
-{
-	return adapter->params.sge.polling ? t1_interrupt_napi : t1_interrupt;
-}
+#endif
 
 /*
  * Enqueues the sk_buff onto the cmdQ[qid] and has hardware fetch it.
@@ -2033,7 +2018,6 @@ static void sge_tx_reclaim_cb(unsigned l
  */
 int t1_sge_set_coalesce_params(struct sge *sge, struct sge_params *p)
 {
-	sge->netdev->poll = t1_poll;
 	sge->fixed_intrtimer = p->rx_coalesce_usecs *
 		core_ticks_per_usec(sge->adapter);
 	writel(sge->fixed_intrtimer, sge->adapter->regs + A_SG_INTRTIMER);
@@ -2234,7 +2218,6 @@ struct sge * __devinit t1_sge_create(str
 
 	p->coalesce_enable = 0;
 	p->sample_interval_usecs = 0;
-	p->polling = 0;
 
 	return sge;
 nomem_port:
--- chelsio.orig/drivers/net/Kconfig
+++ chelsio/drivers/net/Kconfig
@@ -2384,6 +2384,14 @@ config CHELSIO_T1_1G
           Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
           are using only 10G cards say 'N' here.
 
+config CHELSIO_T1_NAPI
+	bool "Use Rx Polling (NAPI)"
+	depends on CHELSIO_T1
+	default y
+	help
+	  NAPI is a driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card.
+
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS
--- chelsio.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio/drivers/net/chelsio/cxgb2.c
@@ -220,9 +220,8 @@ static int cxgb_up(struct adapter *adapt
 
 	t1_interrupts_clear(adapter);
 
-	adapter->params.has_msi = !disable_msi && pci_enable_msi(adapter->pdev) == 0;
-	err = request_irq(adapter->pdev->irq,
-			  t1_select_intr_handler(adapter),
+	adapter->params.has_msi = !disable_msi && !pci_enable_msi(adapter->pdev);
+	err = request_irq(adapter->pdev->irq, t1_interrupt,
 			  adapter->params.has_msi ? 0 : IRQF_SHARED,
 			  adapter->name, adapter);
 	if (err) {
@@ -764,18 +763,7 @@ static int set_coalesce(struct net_devic
 {
 	struct adapter *adapter = dev->priv;
 
-	/*
-	 * If RX coalescing is requested we use NAPI, otherwise interrupts.
-	 * This choice can be made only when all ports and the TOE are off.
-	 */
-	if (adapter->open_device_map == 0)
-		adapter->params.sge.polling = c->use_adaptive_rx_coalesce;
-
-	if (adapter->params.sge.polling) {
-		adapter->params.sge.rx_coalesce_usecs = 0;
-	} else {
-		adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
-	}
+	adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
  	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
 	adapter->params.sge.sample_interval_usecs = c->rate_sample_interval;
 	t1_sge_set_coalesce_params(adapter->sge, &adapter->params.sge);
@@ -944,7 +932,7 @@ static void t1_netpoll(struct net_device
 	struct adapter *adapter = dev->priv;
 
 	local_irq_save(flags);
-	t1_select_intr_handler(adapter)(adapter->pdev->irq, adapter);
+	t1_interrupt(adapter->pdev->irq, adapter);
 	local_irq_restore(flags);
 }
 #endif
@@ -1165,7 +1153,10 @@ static int __devinit init_one(struct pci
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = t1_netpoll;
 #endif
+#ifdef CONFIG_CHELSIO_T1_NAPI
 		netdev->weight = 64;
+		netdev->poll = t1_poll;
+#endif
 
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
--- chelsio.orig/drivers/net/chelsio/sge.h
+++ chelsio/drivers/net/chelsio/sge.h
@@ -76,7 +76,9 @@ struct sge *t1_sge_create(struct adapter
 int t1_sge_configure(struct sge *, struct sge_params *);
 int t1_sge_set_coalesce_params(struct sge *, struct sge_params *);
 void t1_sge_destroy(struct sge *);
-irq_handler_t t1_select_intr_handler(adapter_t *adapter);
+irqreturn_t t1_interrupt(int irq, void *cookie);
+int t1_poll(struct net_device *, int *);
+
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void t1_set_vlan_accel(struct adapter *adapter, int on_off);
 void t1_sge_start(struct sge *);
