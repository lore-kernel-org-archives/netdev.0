From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 4/6] forcedeth: unconditionally enable NAPI
Date: Wed, 17 Oct 2007 01:54:20 -0400
Message-ID: <20071017055420.GE20534@havoc.gtf.org>
References: <20071017055251.GA19972@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ingo Molnar <mingo@elte.hu>, Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52504 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbXJQFyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 01:54:23 -0400
Content-Disposition: inline
In-Reply-To: <20071017055251.GA19972@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 8f61debaeb334bce0ccba1a1384d549a377c1e8e
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Oct 16 12:55:08 2007 -0400

    [netdrvr] forcedeth: unconditionally enable NAPI
    
    Remove all !CONFIG_FORCEDETH_NAPI code, and the Kconfig option,
    enabling NAPI unconditionally.
    
    The NIC driver recreates a lot of this functionality manually.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/Kconfig     |   17 -----
 drivers/net/forcedeth.c |  143 ++----------------------------------------------
 2 files changed, 7 insertions(+), 153 deletions(-)

8f61debaeb334bce0ccba1a1384d549a377c1e8e
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 83d52c8..eafdd58 100644
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
index a4baad7..32a8893 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1546,7 +1546,6 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 }
 
 /* If rx bufs are exhausted called after 50ms to attempt to refresh */
-#ifdef CONFIG_FORCEDETH_NAPI
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -1555,41 +1554,6 @@ static void nv_do_rx_refill(unsigned long data)
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
-	if (!nv_optimized(np))
-		retcode = nv_alloc_rx(dev);
-	else
-		retcode = nv_alloc_rx_optimized(dev);
-	if (retcode) {
-		spin_lock_irq(&np->lock);
-		if (netif_running(dev))
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
@@ -2347,11 +2311,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
-#ifdef CONFIG_FORCEDETH_NAPI
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
 		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
@@ -2446,27 +2406,14 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				dev->name, len, skb->protocol);
 
 			if (likely(!np->vlangrp)) {
-#ifdef CONFIG_FORCEDETH_NAPI
 				netif_receive_skb(skb);
-#else
-				netif_rx(skb);
-#endif
 			} else {
 				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-#ifdef CONFIG_FORCEDETH_NAPI
 					vlan_hwaccel_receive_skb(skb, np->vlangrp,
 								 vlanflags & NV_RX3_VLAN_TAG_MASK);
-#else
-					vlan_hwaccel_rx(skb, np->vlangrp,
-							vlanflags & NV_RX3_VLAN_TAG_MASK);
-#endif
 				} else {
-#ifdef CONFIG_FORCEDETH_NAPI
 					netif_receive_skb(skb);
-#else
-					netif_rx(skb);
-#endif
 				}
 			}
 
@@ -2965,7 +2912,6 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 			nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
 			netif_rx_schedule(dev, &np->napi);
 
@@ -2979,27 +2925,7 @@ static irqreturn_t __nv_nic_irq(struct net_device *dev, bool optimized)
 				writel(np->irqmask, base + NvRegIrqMask);
 			spin_unlock(&np->lock);
 		}
-#else
-		if (optimized) {
-			if (nv_rx_process_optimized(dev, RX_WORK_PER_LOOP)) {
-				if (unlikely(nv_alloc_rx_optimized(dev))) {
-					spin_lock(&np->lock);
-					if (netif_running(dev))
-						mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-					spin_unlock(&np->lock);
-				}
-			}
-		} else {
-			if (nv_rx_process(dev, RX_WORK_PER_LOOP)) {
-				if (unlikely(nv_alloc_rx(dev))) {
-					spin_lock(&np->lock);
-					if (netif_running(dev))
-						mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-					spin_unlock(&np->lock);
-				}
-			}
-		}
-#endif
+
 		if (unlikely(events & NVREG_IRQ_LINK)) {
 			spin_lock(&np->lock);
 			nv_link_irq(dev);
@@ -3119,7 +3045,6 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	return IRQ_RETVAL(i);
 }
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
@@ -3159,9 +3084,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	}
 	return pkts;
 }
-#endif
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = data;
@@ -3180,54 +3103,6 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	}
 	return IRQ_HANDLED;
 }
-#else
-static irqreturn_t nv_nic_irq_rx(int foo, void *data)
-{
-	struct net_device *dev = data;
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
-				if (netif_running(dev))
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
-			if (netif_running(dev)) {
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
@@ -4472,9 +4347,9 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
+
 			napi_disable(&np->napi);
-#endif
+
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
@@ -4529,9 +4404,9 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			/* restart rx engine */
 			nv_start_rxtx(dev);
 			netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
+
 			napi_enable(&np->napi);
-#endif
+
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -4756,9 +4631,7 @@ static int nv_open(struct net_device *dev)
 	ret = nv_update_linkspeed(dev);
 	nv_start_rxtx(dev);
 	netif_start_queue(dev);
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_enable(&np->napi);
-#endif
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -4789,9 +4662,7 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	spin_unlock_irq(&np->lock);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 	napi_disable(&np->napi);
-#endif
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
@@ -5003,9 +4874,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-#ifdef CONFIG_FORCEDETH_NAPI
+
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
-#endif
+
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
