From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/6] forcedeth: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 00:32:41 +0200
Message-ID: <20080710223241.GD31019@electric-eye.fr.zoreil.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Tobias Diedrich <ranma+kernel@tdiedrich.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40822 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753935AbYGJWdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:33:04 -0400
Content-Disposition: inline
In-Reply-To: <20080708.015548.127198943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Kconfig     |   14 -----
 drivers/net/forcedeth.c |  145 ++---------------------------------------------
 2 files changed, 5 insertions(+), 154 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 33b8899..f74461b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1378,20 +1378,6 @@ config FORCEDETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
 
-config FORCEDETH_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
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
-	  If in doubt, say N.
-
 config CS89x0
 	tristate "CS89x0 support"
 	depends on NET_PCI && (ISA || MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 786d668..3af5e0f 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1676,7 +1676,6 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 }
 
 /* If rx bufs are exhausted called after 50ms to attempt to refresh */
-#ifdef CONFIG_FORCEDETH_NAPI
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -1685,41 +1684,6 @@ static void nv_do_rx_refill(unsigned long data)
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
-			disable_irq(np->pci_dev->irq);
-	} else {
-		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
-	}
-	if (!nv_optimized(np))
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
-			enable_irq(np->pci_dev->irq);
-	} else {
-		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
-	}
-}
-#endif
 
 static void nv_init_rx(struct net_device *dev)
 {
@@ -2653,11 +2617,9 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
-#ifdef CONFIG_FORCEDETH_NAPI
+
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
+
 		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
@@ -2746,29 +2708,15 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: %d bytes, proto %d accepted.\n",
 				dev->name, len, skb->protocol);
 
-			if (likely(!np->vlangrp)) {
-#ifdef CONFIG_FORCEDETH_NAPI
+			if (likely(!np->vlangrp))
 				netif_receive_skb(skb);
-#else
-				netif_rx(skb);
-#endif
-			} else {
+			else {
 				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-#ifdef CONFIG_FORCEDETH_NAPI
 					vlan_hwaccel_receive_skb(skb, np->vlangrp,
 								 vlanflags & NV_RX3_VLAN_TAG_MASK);
-#else
-					vlan_hwaccel_rx(skb, np->vlangrp,
-							vlanflags & NV_RX3_VLAN_TAG_MASK);
-#endif
-				} else {
-#ifdef CONFIG_FORCEDETH_NAPI
+				} else
 					netif_receive_skb(skb);
-#else
-					netif_rx(skb);
-#endif
-				}
 			}
 
 			dev->last_rx = jiffies;
@@ -3319,7 +3267,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
 
@@ -3333,16 +3280,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
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
@@ -3436,7 +3373,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
 
@@ -3450,16 +3386,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
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
@@ -3568,7 +3494,6 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	return IRQ_RETVAL(i);
 }
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
@@ -3608,9 +3533,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	}
 	return pkts;
 }
-#endif
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3629,54 +3552,6 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
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
@@ -4942,9 +4817,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 			napi_disable(&np->napi);
-#endif
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
@@ -5000,9 +4873,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			/* restart rx engine */
 			nv_start_rxtx(dev);
 			netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 			napi_enable(&np->napi);
-#endif
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -5242,9 +5113,7 @@ static int nv_open(struct net_device *dev)
 	ret = nv_update_linkspeed(dev);
 	nv_start_rxtx(dev);
 	netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_enable(&np->napi);
-#endif
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -5276,9 +5145,7 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_disable(&np->napi);
-#endif
 	synchronize_irq(np->pci_dev->irq);
 
 	del_timer_sync(&np->oom_kick);
@@ -5496,9 +5363,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-#ifdef CONFIG_FORCEDETH_NAPI
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
-#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
-- 
1.5.3.3

