From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 6/6] [netdrvr] interrupt handling overhaul
Date: Wed, 17 Oct 2007 01:55:03 -0400
Message-ID: <20071017055503.GG20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47984 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765993AbXJQFzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:55:05 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 4f97856cd73ad3ccee06f1856c60cb1ed8f44ceb
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 19:48:15 2007 -0400

    [netdrvr] interrupt handling overhaul
    
    * eliminate the work loops in the interrupt handlers.  they are no
      longer needed, now that NAPI and other asynchronous tasks handle our
      work (and can be independently controlled by means other than
      disable_irq or spin_lock_irqsave).
    
    * make ->poll_controller call interrupt handler directly
    
    * now that nv_do_nic_poll()'s only users are those that request
      recovery, we can rename it to nv_reset_task(), and convert it from a
      timer-context function to a workqueue.
    
    * ->tx_timeout TX reset is replaced by requesting recovery
    
    * in the main irq handler (INTx or MSI), the spinlock is always
      taken in the common case: TX-or-RX work available.  take the lock once
      for any work, near the beginning of the irq handler (after status is
      read and cleared).
    
      This accomplishes the goal of getting a np->irqmask access inside the
      lock, simplifies the code, and enables better control over irq
      masking.
    
    * no need to take lock, simply to schedule timer
    
    * MSI-X RX/TX irq handling micro-optimization
    
    * use IRQ_NONE/IRQ_HANDLED in nv_nic_irq_test(), rather than the less
      readable versions of the same values.
    
    * in nv_close(), make sure to cancel the workqueue tasks first thing,
      to ensure they (mainly the reset task) will not race with interface
      shutdown.
    
    * move now-pointless tests of np->recover_error and netif_running()
      in nv_reset_task(), resulting in a large de-indent of existing code.
    
    * eliminate now-useless max_interrupt_work module option.  though we
      might want to consider permitting tuning of NAPI weights via ethtool,
      in the future.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/forcedeth.c |  385 +++++++++++++++++++-----------------------------
 1 file changed, 158 insertions(+), 227 deletions(-)

4f97856cd73ad3ccee06f1856c60cb1ed8f44ceb
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 81fe016..8af9a96 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -58,6 +58,7 @@
 #include <linux/init.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -676,7 +677,6 @@ struct fe_priv {
 	unsigned int phy_model;
 	u16 gigabit;
 	int intr_test;
-	int recover_error;
 
 	/* General data: RO fields */
 	dma_addr_t ring_addr;
@@ -701,14 +701,14 @@ struct fe_priv {
 	struct nv_skb_map *first_rx_ctx, *last_rx_ctx;
 	struct nv_skb_map *rx_skb;
 
-	union ring_type rx_ring;
-	unsigned int rx_buf_sz;
-	unsigned int pkt_limit;
-	struct timer_list oom_kick;
-	struct timer_list nic_poll;
-	struct delayed_work stats_task;
-	u32 nic_poll_irq;
-	int rx_ring_size;
+	union ring_type		rx_ring;
+	unsigned int		rx_buf_sz;
+	unsigned int		pkt_limit;
+	struct timer_list	oom_kick;
+	struct work_struct	reset_task;
+	struct delayed_work	stats_task;
+	u32			nic_poll_irq;
+	int			rx_ring_size;
 
 	/* media detection workaround.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
@@ -739,12 +739,6 @@ struct fe_priv {
 };
 
 /*
- * Maximum number of loops until we assume that a bit in the irq mask
- * is stuck. Overridable with module param.
- */
-static int max_interrupt_work = 5;
-
-/*
  * Optimization can be either throuput mode or cpu mode
  *
  * Throughput Mode: Every tx and rx packet will generate an interrupt.
@@ -2116,27 +2110,9 @@ static void nv_tx_timeout(struct net_device *dev)
 
 	spin_lock_irq(&np->lock);
 
-	/* 1) stop tx engine */
-	nv_stop_tx(dev);
-
-	/* 2) check that the packets were not sent already: */
-	if (!nv_optimized(np))
-		nv_tx_done(dev, np->tx_ring_size);
-	else
-		nv_tx_done_optimized(dev, np->tx_ring_size);
-
-	/* 3) if there are dead entries: clear everything */
-	if (np->get_tx_ctx != np->put_tx_ctx) {
-		printk(KERN_DEBUG "%s: tx_timeout: dead entries!\n", dev->name);
-		nv_drain_tx(dev);
-		nv_init_tx(dev);
-		setup_hw_rings(dev, NV_SETUP_TX_RING);
-	}
-
-	netif_wake_queue(dev);
+	np->nic_poll_irq = np->irqmask;
+	schedule_work(&np->reset_task);
 
-	/* 4) restart tx engine */
-	nv_start_tx(dev);
 	spin_unlock_irq(&np->lock);
 }
 
@@ -2890,101 +2866,82 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = np->base;
 	u32 events, updmask = 0;
-	int i;
+	bool msix = np->msi_flags & NV_MSI_X_ENABLED;
 
 	dprintk(KERN_DEBUG "%s: __nv_nic_irq\n", dev->name);
 
-	for (i=0; ; i++) {
-		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
-			events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
-			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-		} else {
-			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
-			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-		}
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
+	if (!msix) {
+		events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+	} else {
+		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+	}
 
-		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
-			updmask |= NVREG_IRQ_RX_ALL;
-		}
+	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 
-		if (events & NVREG_IRQ_TX_ALL) {
-			netif_rx_schedule(dev, &np->tx_napi);
-			updmask |= NVREG_IRQ_TX_ALL;
-		}
+	if (!events)
+		return IRQ_NONE;
 
-		if (updmask) {
-			spin_lock(&np->lock);
-			np->irqmask &= ~updmask;
+	spin_lock(&np->lock);
 
-			if (np->msi_flags & NV_MSI_X_ENABLED)
-				writel(updmask, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			spin_unlock(&np->lock);
-		}
+	if (!(events & np->irqmask))
+		goto out;
 
-		if (unlikely(events & NVREG_IRQ_LINK)) {
-			spin_lock(&np->lock);
-			nv_link_irq(dev);
-			spin_unlock(&np->lock);
-		}
-		if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
-			spin_lock(&np->lock);
-			nv_linkchange(dev);
-			spin_unlock(&np->lock);
-			np->link_timeout = jiffies + LINK_TIMEOUT;
-		}
-		if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
-			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
-						dev->name, events);
-		}
-		if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
-		}
-		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	if (events & NVREG_IRQ_RX_ALL) {
+		netif_rx_schedule(dev, &np->napi);
+		updmask |= NVREG_IRQ_RX_ALL;
+	}
 
-			if (netif_running(dev)) {
-				np->nic_poll_irq = np->irqmask;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			break;
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock(&np->lock);
-			/* disable interrupts on the nic */
-			if (!(np->msi_flags & NV_MSI_X_ENABLED))
-				writel(0, base + NvRegIrqMask);
-			else
-				writel(np->irqmask, base + NvRegIrqMask);
-			pci_push(base);
+	if (events & NVREG_IRQ_TX_ALL) {
+		netif_rx_schedule(dev, &np->tx_napi);
+		updmask |= NVREG_IRQ_TX_ALL;
+	}
 
-			if (netif_running(dev)) {
-				np->nic_poll_irq = np->irqmask;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock(&np->lock);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
-			break;
-		}
+	if (updmask) {
+		np->irqmask &= ~updmask;
+
+		if (!msix)
+			writel(updmask, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+	}
+
+	if (unlikely(events & NVREG_IRQ_LINK))
+		nv_link_irq(dev);
+
+	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
+		nv_linkchange(dev);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
+	if (unlikely(events & (NVREG_IRQ_TX_ERR))) {
+		dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
+					dev->name, events);
+	}
+	if (unlikely(events & (NVREG_IRQ_UNKNOWN))) {
+		printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
+					dev->name, events);
+	}
+	if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+		/* disable interrupts on the nic */
+		if (!msix)
+			writel(0, base + NvRegIrqMask);
+		else
+			writel(np->irqmask, base + NvRegIrqMask);
+		pci_push(base);
 
+		if (netif_running(dev)) {
+			np->nic_poll_irq = np->irqmask;
+			schedule_work(&np->reset_task);
+		}
 	}
+
+out:
+	spin_unlock(&np->lock);
+
 	dprintk(KERN_DEBUG "%s: __nv_nic_irq completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
+	return IRQ_HANDLED;
 }
 
 static irqreturn_t nv_nic_irq(int foo, void *data)
@@ -3015,12 +2972,8 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 		retcode = nv_alloc_rx_optimized(dev);
 	}
 
-	if (retcode) {
-		spin_lock_irqsave(&np->lock, flags);
-		if (netif_running(dev))
-			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		spin_unlock_irqrestore(&np->lock, flags);
-	}
+	if (retcode && netif_running(dev))
+		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
 	if (pkts < budget) {
 		/* re-enable receive interrupts */
@@ -3047,14 +3000,16 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	u32 events;
 
 	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 
-	if (events) {
+	if (likely(events)) {
+		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
+
 		netif_rx_schedule(dev, &np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
 	}
+
 	return IRQ_HANDLED;
 }
 
@@ -3066,14 +3021,16 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	u32 events;
 
 	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
-	writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
 
-	if (events) {
+	if (likely(events)) {
+		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
+
 		netif_rx_schedule(dev, &np->tx_napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
 		pci_push(base);
 	}
+
 	return IRQ_HANDLED;
 }
 
@@ -3115,71 +3072,46 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
-	int i;
-	unsigned long flags;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_other\n", dev->name);
 
-	for (i=0; ; i++) {
-		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
-		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
+	spin_lock(&np->lock);
 
-		/* check tx in case we reached max loop limit in tx isr */
-		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock_irqrestore(&np->lock, flags);
+	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
+	writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
 
-		if (events & NVREG_IRQ_LINK) {
-			spin_lock_irqsave(&np->lock, flags);
-			nv_link_irq(dev);
-			spin_unlock_irqrestore(&np->lock, flags);
-		}
-		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
-			spin_lock_irqsave(&np->lock, flags);
-			nv_linkchange(dev);
-			spin_unlock_irqrestore(&np->lock, flags);
-			np->link_timeout = jiffies + LINK_TIMEOUT;
-		}
-		if (events & NVREG_IRQ_RECOVER_ERROR) {
-			spin_lock_irq(&np->lock);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
-			pci_push(base);
+	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
+	if (!(events & np->irqmask))
+		goto out;
 
-			if (netif_running(dev)) {
-				np->nic_poll_irq |= NVREG_IRQ_OTHER;
-				np->recover_error = 1;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irq(&np->lock);
-			break;
-		}
-		if (events & (NVREG_IRQ_UNKNOWN)) {
-			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
-						dev->name, events);
-		}
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock_irqsave(&np->lock, flags);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
-			pci_push(base);
+	if (events & NVREG_IRQ_LINK)
+		nv_link_irq(dev);
 
-			if (netif_running(dev)) {
-				np->nic_poll_irq |= NVREG_IRQ_OTHER;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_other.\n", dev->name, i);
-			break;
-		}
+	if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
+		nv_linkchange(dev);
+		np->link_timeout = jiffies + LINK_TIMEOUT;
+	}
+	if (events & NVREG_IRQ_RECOVER_ERROR) {
+		/* disable interrupts on the nic */
+		writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
+		pci_push(base);
 
+		if (netif_running(dev)) {
+			np->nic_poll_irq |= NVREG_IRQ_OTHER;
+			schedule_work(&np->reset_task);
+		}
+	}
+	if (events & (NVREG_IRQ_UNKNOWN)) {
+		printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
+					dev->name, events);
 	}
+
+out:
+	spin_unlock(&np->lock);
+
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_other completed\n", dev->name);
 
-	return IRQ_RETVAL(i);
+	return IRQ_HANDLED;
 }
 
 static irqreturn_t nv_nic_irq_test(int foo, void *data)
@@ -3201,7 +3133,7 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	pci_push(base);
 	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
 	if (!(events & NVREG_IRQ_TIMER))
-		return IRQ_RETVAL(0);
+		return IRQ_NONE;
 
 	spin_lock(&np->lock);
 	np->intr_test = 1;
@@ -3209,7 +3141,7 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_test completed\n", dev->name);
 
-	return IRQ_RETVAL(1);
+	return IRQ_HANDLED;
 }
 
 static void set_msix_vector_map(struct net_device *dev, u32 vector, u32 irqmask)
@@ -3356,11 +3288,11 @@ static void nv_free_irq(struct net_device *dev)
 	}
 }
 
-static void nv_do_nic_poll(unsigned long data)
+static void nv_reset_task(struct work_struct *work)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
+	struct fe_priv *np = container_of(work, struct fe_priv, reset_task);
+	struct net_device *dev = np->dev;
+	u8 __iomem *base = np->base;
 	u32 mask = 0;
 
 	/*
@@ -3389,39 +3321,38 @@ static void nv_do_nic_poll(unsigned long data)
 			mask |= NVREG_IRQ_OTHER;
 		}
 	}
+
+	dev_printk(KERN_INFO, &np->pci_dev->dev, "resetting MAC "
+		   "(pimask %x, mask %x)\n",
+		   np->nic_poll_irq, mask);
+
 	np->nic_poll_irq = 0;
 
-	if (np->recover_error) {
-		np->recover_error = 0;
-		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
-		if (netif_running(dev)) {
-			netif_tx_lock_bh(dev);
-			spin_lock(&np->lock);
-			/* stop engines */
-			nv_stop_rxtx(dev);
-			nv_txrx_reset(dev);
-			/* drain rx queue */
-			nv_drain_rxtx(dev);
-			/* reinit driver view of the rx queue */
-			set_bufsize(dev);
-			if (nv_init_ring(dev))
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+	netif_tx_lock_bh(dev);
+	spin_lock(&np->lock);
+	/* stop engines */
+	nv_stop_rxtx(dev);
+	nv_txrx_reset(dev);
+	/* drain rx queue */
+	nv_drain_rxtx(dev);
+	/* reinit driver view of the rx queue */
+	set_bufsize(dev);
+	if (nv_init_ring(dev))
+		mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
 
-			/* reinit nic view of the rx queue */
-			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
-			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-			writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
-				base + NvRegRingSizes);
-			pci_push(base);
-			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-			pci_push(base);
+	/* reinit nic view of the rx queue */
+	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
+	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
+	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+		base + NvRegRingSizes);
+	pci_push(base);
+	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+	pci_push(base);
 
-			/* restart rx engine */
-			nv_start_rxtx(dev);
-			spin_unlock(&np->lock);
-			netif_tx_unlock_bh(dev);
-		}
-	}
+	/* restart rx engine */
+	nv_start_rxtx(dev);
+	spin_unlock(&np->lock);
+	netif_tx_unlock_bh(dev);
 
 	/* FIXME: Do we need synchronize_irq(dev->irq) here? */
 
@@ -3456,7 +3387,13 @@ static void nv_do_nic_poll(unsigned long data)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void nv_poll_controller(struct net_device *dev)
 {
-	nv_do_nic_poll((unsigned long) dev);
+	struct fe_priv *np = netdev_priv(dev);
+	bool optimized = nv_optimized(np);
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__nv_nic_irq(dev, optimized);
+	local_irq_restore(flags);
 }
 #endif
 
@@ -4667,18 +4604,16 @@ static int nv_close(struct net_device *dev)
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base;
 
-	spin_lock_irq(&np->lock);
-	spin_unlock_irq(&np->lock);
+	cancel_work_sync(&np->reset_task);
+	cancel_delayed_work_sync(&np->stats_task);
 
 	napi_disable(&np->tx_napi);
 	napi_disable(&np->napi);
-	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
-	del_timer_sync(&np->nic_poll);
-	cancel_delayed_work_sync(&np->stats_task);
 
-	netif_stop_queue(dev);
+	netif_tx_disable(dev);
+
 	spin_lock_irq(&np->lock);
 	nv_stop_rxtx(dev);
 	nv_txrx_reset(dev);
@@ -4736,9 +4671,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	init_timer(&np->oom_kick);
 	np->oom_kick.data = (unsigned long) dev;
 	np->oom_kick.function = &nv_do_rx_refill;	/* timer handler */
-	init_timer(&np->nic_poll);
-	np->nic_poll.data = (unsigned long) dev;
-	np->nic_poll.function = &nv_do_nic_poll;	/* timer handler */
+	INIT_WORK(&np->reset_task, nv_reset_task);
 	INIT_DELAYED_WORK(&np->stats_task, nv_stats_task);
 
 	err = pci_enable_device(pci_dev);
@@ -5337,8 +5270,6 @@ static void __exit exit_nic(void)
 	pci_unregister_driver(&driver);
 }
 
-module_param(max_interrupt_work, int, 0);
-MODULE_PARM_DESC(max_interrupt_work, "forcedeth maximum events handled per interrupt");
 module_param(optimization_mode, int, 0);
 MODULE_PARM_DESC(optimization_mode, "In throughput mode (0), every tx & rx packet will generate an interrupt. In CPU mode (1), interrupts are controlled by a timer.");
 module_param(poll_interval, int, 0);
