From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: GRO support
Date: Mon, 03 May 2010 23:33:46 -0700 (PDT)
Message-ID: <20100503.233346.168009545.davem@davemloft.net>
References: <alpine.DEB.1.00.1005032203520.11991@pokey.mtv.corp.google.com>
	<20100503.232714.43422983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752695Ab0EDGdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:33:43 -0400
In-Reply-To: <20100503.232714.43422983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 03 May 2010 23:27:14 -0700 (PDT)

> In fact, I'm just going to kill it right now in net-next-2.6

--------------------
forcedeth: Kill NAPI config options.

All distributions enable it, therefore no significant body of users
are even testing the driver with it disabled.  And making NAPI
configurable is heavily discouraged anyways.

I left the MSI-X interrupt enabling thing in an "#if 0" block
so hopefully someone can debug that and it can get re-enabled.
Probably it was just one of the NVIDIA chipset MSI erratas that
we work handle these days in the PCI quirks (see drivers/pci/quirks.c
and stuff like nvenet_msi_disable()).

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig     |   14 ----
 drivers/net/forcedeth.c |  194 +----------------------------------------------
 2 files changed, 1 insertions(+), 207 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dbd26f9..b9e7618 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1453,20 +1453,6 @@ config FORCEDETH
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
 	depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 4a24cc7..f9e1dd4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1104,20 +1104,16 @@ static void nv_disable_hw_interrupts(struct net_device *dev, u32 mask)
 
 static void nv_napi_enable(struct net_device *dev)
 {
-#ifdef CONFIG_FORCEDETH_NAPI
 	struct fe_priv *np = get_nvpriv(dev);
 
 	napi_enable(&np->napi);
-#endif
 }
 
 static void nv_napi_disable(struct net_device *dev)
 {
-#ifdef CONFIG_FORCEDETH_NAPI
 	struct fe_priv *np = get_nvpriv(dev);
 
 	napi_disable(&np->napi);
-#endif
 }
 
 #define MII_READ	(-1)
@@ -1810,7 +1806,6 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 }
 
 /* If rx bufs are exhausted called after 50ms to attempt to refresh */
-#ifdef CONFIG_FORCEDETH_NAPI
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -1819,41 +1814,6 @@ static void nv_do_rx_refill(unsigned long data)
 	/* Just reschedule NAPI rx processing */
 	napi_schedule(&np->napi);
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
@@ -2816,11 +2776,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
-#ifdef CONFIG_FORCEDETH_NAPI
 		napi_gro_receive(&np->napi, skb);
-#else
-		netif_rx(skb);
-#endif
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += len;
 next_pkt:
@@ -2909,27 +2865,14 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				dev->name, len, skb->protocol);
 
 			if (likely(!np->vlangrp)) {
-#ifdef CONFIG_FORCEDETH_NAPI
 				napi_gro_receive(&np->napi, skb);
-#else
-				netif_rx(skb);
-#endif
 			} else {
 				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-#ifdef CONFIG_FORCEDETH_NAPI
 					vlan_gro_receive(&np->napi, np->vlangrp,
 							 vlanflags & NV_RX3_VLAN_TAG_MASK, skb);
-#else
-					vlan_hwaccel_rx(skb, np->vlangrp,
-							vlanflags & NV_RX3_VLAN_TAG_MASK);
-#endif
 				} else {
-#ifdef CONFIG_FORCEDETH_NAPI
 					napi_gro_receive(&np->napi, skb);
-#else
-					netif_rx(skb);
-#endif
 				}
 			}
 
@@ -3496,10 +3439,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-#ifndef CONFIG_FORCEDETH_NAPI
-	int total_work = 0;
-	int loop_count = 0;
-#endif
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq\n", dev->name);
 
@@ -3516,7 +3455,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 
 	nv_msi_workaround(np);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 	if (napi_schedule_prep(&np->napi)) {
 		/*
 		 * Disable further irq's (msix not enabled with napi)
@@ -3525,65 +3463,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		__napi_schedule(&np->napi);
 	}
 
-#else
-	do
-	{
-		int work = 0;
-		if ((work = nv_rx_process(dev, RX_WORK_PER_LOOP))) {
-			if (unlikely(nv_alloc_rx(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-
-		spin_lock(&np->lock);
-		work += nv_tx_done(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
-
-		if (!work)
-			break;
-
-		total_work += work;
-
-		loop_count++;
-	}
-	while (loop_count < max_interrupt_work);
-
-	if (nv_change_interrupt_mode(dev, total_work)) {
-		/* setup new irq mask */
-		writel(np->irqmask, base + NvRegIrqMask);
-	}
-
-	if (unlikely(np->events & NVREG_IRQ_LINK)) {
-		spin_lock(&np->lock);
-		nv_link_irq(dev);
-		spin_unlock(&np->lock);
-	}
-	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
-		spin_lock(&np->lock);
-		nv_linkchange(dev);
-		spin_unlock(&np->lock);
-		np->link_timeout = jiffies + LINK_TIMEOUT;
-	}
-	if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
-		spin_lock(&np->lock);
-		/* disable interrupts on the nic */
-		if (!(np->msi_flags & NV_MSI_X_ENABLED))
-			writel(0, base + NvRegIrqMask);
-		else
-			writel(np->irqmask, base + NvRegIrqMask);
-		pci_push(base);
-
-		if (!np->in_shutdown) {
-			np->nic_poll_irq = np->irqmask;
-			np->recover_error = 1;
-			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-		}
-		spin_unlock(&np->lock);
-	}
-#endif
 	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
 
 	return IRQ_HANDLED;
@@ -3599,10 +3478,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-#ifndef CONFIG_FORCEDETH_NAPI
-	int total_work = 0;
-	int loop_count = 0;
-#endif
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
 
@@ -3619,7 +3494,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 
 	nv_msi_workaround(np);
 
-#ifdef CONFIG_FORCEDETH_NAPI
 	if (napi_schedule_prep(&np->napi)) {
 		/*
 		 * Disable further irq's (msix not enabled with napi)
@@ -3627,66 +3501,6 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		writel(0, base + NvRegIrqMask);
 		__napi_schedule(&np->napi);
 	}
-#else
-	do
-	{
-		int work = 0;
-		if ((work = nv_rx_process_optimized(dev, RX_WORK_PER_LOOP))) {
-			if (unlikely(nv_alloc_rx_optimized(dev))) {
-				spin_lock(&np->lock);
-				if (!np->in_shutdown)
-					mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-				spin_unlock(&np->lock);
-			}
-		}
-
-		spin_lock(&np->lock);
-		work += nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
-		spin_unlock(&np->lock);
-
-		if (!work)
-			break;
-
-		total_work += work;
-
-		loop_count++;
-	}
-	while (loop_count < max_interrupt_work);
-
-	if (nv_change_interrupt_mode(dev, total_work)) {
-		/* setup new irq mask */
-		writel(np->irqmask, base + NvRegIrqMask);
-	}
-
-	if (unlikely(np->events & NVREG_IRQ_LINK)) {
-		spin_lock(&np->lock);
-		nv_link_irq(dev);
-		spin_unlock(&np->lock);
-	}
-	if (unlikely(np->need_linktimer && time_after(jiffies, np->link_timeout))) {
-		spin_lock(&np->lock);
-		nv_linkchange(dev);
-		spin_unlock(&np->lock);
-		np->link_timeout = jiffies + LINK_TIMEOUT;
-	}
-	if (unlikely(np->events & NVREG_IRQ_RECOVER_ERROR)) {
-		spin_lock(&np->lock);
-		/* disable interrupts on the nic */
-		if (!(np->msi_flags & NV_MSI_X_ENABLED))
-			writel(0, base + NvRegIrqMask);
-		else
-			writel(np->irqmask, base + NvRegIrqMask);
-		pci_push(base);
-
-		if (!np->in_shutdown) {
-			np->nic_poll_irq = np->irqmask;
-			np->recover_error = 1;
-			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
-		}
-		spin_unlock(&np->lock);
-	}
-
-#endif
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
 
 	return IRQ_HANDLED;
@@ -3735,7 +3549,6 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 	return IRQ_RETVAL(i);
 }
 
-#ifdef CONFIG_FORCEDETH_NAPI
 static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
@@ -3805,7 +3618,6 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	}
 	return rx_work;
 }
-#endif
 
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
@@ -5711,9 +5523,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		dev->features |= NETIF_F_TSO;
-#ifdef CONFIG_FORCEDETH_NAPI
 		dev->features |= NETIF_F_GRO;
-#endif
 	}
 
 	np->vlanctl_bits = 0;
@@ -5766,9 +5576,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	else
 		dev->netdev_ops = &nv_netdev_ops_optimized;
 
-#ifdef CONFIG_FORCEDETH_NAPI
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
-#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
 
@@ -5871,7 +5679,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		/* msix has had reported issues when modifying irqmask
 		   as in the case of napi, therefore, disable for now
 		*/
-#ifndef CONFIG_FORCEDETH_NAPI
+#if 0
 		np->msi_flags |= NV_MSI_X_CAPABLE;
 #endif
 	}
-- 
1.7.0.4

