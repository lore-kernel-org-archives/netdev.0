From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 1/5] forcedeth: make NAPI unconditional
Date: Sat, 6 Oct 2007 11:13:37 -0400
Message-ID: <20071006151337.GA17488@havoc.gtf.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39029 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760326AbXJFPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:13:38 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 7bfc023b952e8e12c7333efccd2e78023c546a7c
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 5 20:50:24 2007 -0400

    [netdrvr] forcedeth: make NAPI unconditional
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/Kconfig     |   17 -----
 drivers/net/forcedeth.c |  149 +-----------------------------------------------
 2 files changed, 4 insertions(+), 162 deletions(-)

7bfc023b952e8e12c7333efccd2e78023c546a7c
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9c635a2..59eab61 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1430,23 +1430,6 @@ config FORCEDETH
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called forcedeth.
 
-config FORCEDETH_NAPI
-	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
-	depends on FORCEDETH && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
-	  If in doubt, say N.
-
 config CS89x0
 	tristate "CS89x0 support"
 	depends on NET_PCI && (ISA || MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index dae30b7..49906cc 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -123,12 +123,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#ifdef CONFIG_FORCEDETH_NAPI
-#define DRIVERNAPI "-NAPI"
-#else
-#define DRIVERNAPI
-#endif
-#define FORCEDETH_VERSION		"0.60"
+#define FORCEDETH_VERSION		"1.00"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -1587,7 +1582,6 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 }
 
 /* If rx bufs are exhausted called after 50ms to attempt to refresh */
-#ifdef CONFIG_FORCEDETH_NAPI
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -1596,41 +1590,6 @@ static void nv_do_rx_refill(unsigned long data)
 	/* Just reschedule NAPI rx processing */
 	netif_rx_schedule(dev, &np->napi);
 }
-#else
-static void nv_do_rx_refill(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	int retcode;
-
-	if (!using_multi_irqs(dev)) {
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
-		else
-			disable_irq(dev->irq);
-	} else {
-		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
-	}
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		retcode = nv_alloc_rx(dev);
-	else
-		retcode = nv_alloc_rx_optimized(dev);
-	if (retcode) {
-		spin_lock_irq(&np->lock);
-		if (!np->in_shutdown)
-			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-		spin_unlock_irq(&np->lock);
-	}
-	if (!using_multi_irqs(dev)) {
-		if (np->msi_flags & NV_MSI_X_ENABLED)
-			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
-		else
-			enable_irq(dev->irq);
-	} else {
-		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
-	}
-}
-#endif
 
 static void nv_init_rx(struct net_device *dev)
 {
@@ -2383,11 +2342,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
-#ifdef CONFIG_FORCEDETH_NAPI
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
+
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
@@ -2480,28 +2436,14 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				dev->name, len, skb->protocol);
 
 			if (likely(!np->vlangrp)) {
-#ifdef CONFIG_FORCEDETH_NAPI
 				netif_receive_skb(skb);
-#else
-				netif_rx(skb);
-#endif
 			} else {
 				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-#ifdef CONFIG_FORCEDETH_NAPI
+				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT)
 					vlan_hwaccel_receive_skb(skb, np->vlangrp,
 								 vlanflags & NV_RX3_VLAN_TAG_MASK);
-#else
-					vlan_hwaccel_rx(skb, np->vlangrp,
-							vlanflags & NV_RX3_VLAN_TAG_MASK);
-#endif
-				} else {
-#ifdef CONFIG_FORCEDETH_NAPI
+				else
 					netif_receive_skb(skb);
-#else
-					netif_rx(skb);
-#endif
-				}
 			}
 
 			dev->last_rx = jiffies;
@@ -3001,7 +2943,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
 
@@ -3015,16 +2956,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			spin_unlock(&np->lock);
 		}
-#else
-		if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-#endif
 		if (unlikely(events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -3116,7 +3047,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
 
@@ -3130,16 +3060,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 				writel(np->irqmask, base + NvRegIrqMask);
 			spin_unlock(&np->lock);
 		}
-#else
-		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx_optimized(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-#endif
 		if (unlikely(events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -3248,7 +3168,6 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	return IRQ_RETVAL(i);
 }
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
@@ -3288,9 +3207,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	}
 	return pkts;
 }
-#endif
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3309,54 +3226,6 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	}
 	return IRQ_HANDLED;
 }
-#else
-static irqreturn_t nv_nic_irq_rx(int foo, void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-	int i;
-	unsigned long flags;
-
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx\n", dev->name);
-
-	for (i=0; ; i++) {
-		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
-		dprintk(KERN_DEBUG "%s: rx irq: %08x\n", dev->name, events);
-		if (!(events & np->irqmask))
-			break;
-
-		if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-			if (unlikely(nv_alloc_rx_optimized(dev))) {
-				spin_lock_irqsave(&np->lock, flags);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock_irqrestore(&np->lock, flags);
-			}
-		}
-
-		if (unlikely(i > max_interrupt_work)) {
-			spin_lock_irqsave(&np->lock, flags);
-			/* disable interrupts on the nic */
-			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-			pci_push(base);
-
-			if (!np->in_shutdown) {
-				np->nic_poll_irq |= NVREG_IRQ_RX_ALL;
-				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-			}
-			spin_unlock_irqrestore(&np->lock, flags);
-			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_rx.\n", dev->name, i);
-			break;
-		}
-	}
-	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx completed\n", dev->name);
-
-	return IRQ_RETVAL(i);
-}
-#endif
 
 static irqreturn_t nv_nic_irq_other(int foo, void *data)
 {
@@ -4619,9 +4488,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 			napi_disable(&np->napi);
-#endif
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
@@ -4680,9 +4547,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			nv_start_rx(dev);
 			nv_start_tx(dev);
 			netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 			napi_enable(&np->napi);
-#endif
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -4910,9 +4775,7 @@ static int nv_open(struct net_device *dev)
 	nv_start_rx(dev);
 	nv_start_tx(dev);
 	netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_enable(&np->napi);
-#endif
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -4943,9 +4806,7 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_disable(&np->napi);
-#endif
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
@@ -5159,9 +5020,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-#ifdef CONFIG_FORCEDETH_NAPI
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
-#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
