From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 28/39] natsemi: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:42 +0200
Message-ID: <d13055fe45a281c97ec85454ca8e1c2bc9932166.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Tim Hockin <thockin@hockin.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43478 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756006Ab2DFKKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:39 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's useless to check mem_start on a newly allocated device.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Tim Hockin <thockin@hockin.org>
---
 drivers/net/ethernet/natsemi/natsemi.c |   67 ++++++++++++++++++-------------
 1 files changed, 39 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index d38e48d..5b61d12 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -547,6 +547,7 @@ struct netdev_private {
 	struct sk_buff *tx_skbuff[TX_RING_SIZE];
 	dma_addr_t tx_dma[TX_RING_SIZE];
 	struct net_device *dev;
+	void __iomem *ioaddr;
 	struct napi_struct napi;
 	/* Media monitoring timer */
 	struct timer_list timer;
@@ -699,7 +700,9 @@ static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
 
 static inline void __iomem *ns_ioaddr(struct net_device *dev)
 {
-	return (void __iomem *) dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+
+	return np->ioaddr;
 }
 
 static inline void natsemi_irq_enable(struct net_device *dev)
@@ -863,10 +866,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	/* Store MAC Address in perm_addr */
 	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 
-	dev->base_addr = (unsigned long __force) ioaddr;
-	dev->irq = irq;
-
 	np = netdev_priv(dev);
+	np->ioaddr = ioaddr;
+
 	netif_napi_add(dev, &np->napi, natsemi_poll, 64);
 	np->dev = dev;
 
@@ -914,9 +916,6 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	}
 
 	option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
-	if (dev->mem_start)
-		option = dev->mem_start;
-
 	/* The lower four bits are the media type. */
 	if (option) {
 		if (option & 0x200)
@@ -1532,20 +1531,21 @@ static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
+	const int irq = np->pci_dev->irq;
 	int i;
 
 	/* Reset the chip, just in case. */
 	natsemi_reset(dev);
 
-	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i) return i;
 
 	if (netif_msg_ifup(np))
 		printk(KERN_DEBUG "%s: netdev_open() irq %d.\n",
-			dev->name, dev->irq);
+			dev->name, irq);
 	i = alloc_ring(dev);
 	if (i < 0) {
-		free_irq(dev->irq, dev);
+		free_irq(irq, dev);
 		return i;
 	}
 	napi_enable(&np->napi);
@@ -1794,6 +1794,7 @@ static void netdev_timer(unsigned long data)
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 	int next_tick = NATSEMI_TIMER_FREQ;
+	const int irq = np->pci_dev->irq;
 
 	if (netif_msg_timer(np)) {
 		/* DO NOT read the IntrStatus register,
@@ -1817,14 +1818,14 @@ static void netdev_timer(unsigned long data)
 				if (netif_msg_drv(np))
 					printk(KERN_NOTICE "%s: possible phy reset: "
 						"re-initializing\n", dev->name);
-				disable_irq(dev->irq);
+				disable_irq(irq);
 				spin_lock_irq(&np->lock);
 				natsemi_stop_rxtx(dev);
 				dump_ring(dev);
 				reinit_ring(dev);
 				init_registers(dev);
 				spin_unlock_irq(&np->lock);
-				enable_irq(dev->irq);
+				enable_irq(irq);
 			} else {
 				/* hurry back */
 				next_tick = HZ;
@@ -1841,10 +1842,10 @@ static void netdev_timer(unsigned long data)
 		spin_unlock_irq(&np->lock);
 	}
 	if (np->oom) {
-		disable_irq(dev->irq);
+		disable_irq(irq);
 		np->oom = 0;
 		refill_rx(dev);
-		enable_irq(dev->irq);
+		enable_irq(irq);
 		if (!np->oom) {
 			writel(RxOn, ioaddr + ChipCmd);
 		} else {
@@ -1885,8 +1886,9 @@ static void ns_tx_timeout(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
+	const int irq = np->pci_dev->irq;
 
-	disable_irq(dev->irq);
+	disable_irq(irq);
 	spin_lock_irq(&np->lock);
 	if (!np->hands_off) {
 		if (netif_msg_tx_err(np))
@@ -1905,7 +1907,7 @@ static void ns_tx_timeout(struct net_device *dev)
 			dev->name);
 	}
 	spin_unlock_irq(&np->lock);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
@@ -2470,9 +2472,12 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void natsemi_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	intr_handler(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct netdev_private *np = netdev_priv(dev);
+	const int irq = np->pci_dev->irq;
+
+	disable_irq(irq);
+	intr_handler(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -2523,8 +2528,9 @@ static int natsemi_change_mtu(struct net_device *dev, int new_mtu)
 	if (netif_running(dev)) {
 		struct netdev_private *np = netdev_priv(dev);
 		void __iomem * ioaddr = ns_ioaddr(dev);
+		const int irq = np->pci_dev->irq;
 
-		disable_irq(dev->irq);
+		disable_irq(irq);
 		spin_lock(&np->lock);
 		/* stop engines */
 		natsemi_stop_rxtx(dev);
@@ -2537,7 +2543,7 @@ static int natsemi_change_mtu(struct net_device *dev, int new_mtu)
 		/* restart engines */
 		writel(RxOn | TxOn, ioaddr + ChipCmd);
 		spin_unlock(&np->lock);
-		enable_irq(dev->irq);
+		enable_irq(irq);
 	}
 	return 0;
 }
@@ -3135,6 +3141,7 @@ static int netdev_close(struct net_device *dev)
 {
 	void __iomem * ioaddr = ns_ioaddr(dev);
 	struct netdev_private *np = netdev_priv(dev);
+	const int irq = np->pci_dev->irq;
 
 	if (netif_msg_ifdown(np))
 		printk(KERN_DEBUG
@@ -3156,14 +3163,14 @@ static int netdev_close(struct net_device *dev)
 	 */
 
 	del_timer_sync(&np->timer);
-	disable_irq(dev->irq);
+	disable_irq(irq);
 	spin_lock_irq(&np->lock);
 	natsemi_irq_disable(dev);
 	np->hands_off = 1;
 	spin_unlock_irq(&np->lock);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 
-	free_irq(dev->irq, dev);
+	free_irq(irq, dev);
 
 	/* Interrupt disabled, interrupt handler released,
 	 * queue stopped, timer deleted, rtnl_lock held
@@ -3256,9 +3263,11 @@ static int natsemi_suspend (struct pci_dev *pdev, pm_message_t state)
 
 	rtnl_lock();
 	if (netif_running (dev)) {
+		const int irq = np->pci_dev->irq;
+
 		del_timer_sync(&np->timer);
 
-		disable_irq(dev->irq);
+		disable_irq(irq);
 		spin_lock_irq(&np->lock);
 
 		natsemi_irq_disable(dev);
@@ -3267,7 +3276,7 @@ static int natsemi_suspend (struct pci_dev *pdev, pm_message_t state)
 		netif_stop_queue(dev);
 
 		spin_unlock_irq(&np->lock);
-		enable_irq(dev->irq);
+		enable_irq(irq);
 
 		napi_disable(&np->napi);
 
@@ -3307,6 +3316,8 @@ static int natsemi_resume (struct pci_dev *pdev)
 	if (netif_device_present(dev))
 		goto out;
 	if (netif_running(dev)) {
+		const int irq = np->pci_dev->irq;
+
 		BUG_ON(!np->hands_off);
 		ret = pci_enable_device(pdev);
 		if (ret < 0) {
@@ -3320,13 +3331,13 @@ static int natsemi_resume (struct pci_dev *pdev)
 
 		natsemi_reset(dev);
 		init_ring(dev);
-		disable_irq(dev->irq);
+		disable_irq(irq);
 		spin_lock_irq(&np->lock);
 		np->hands_off = 0;
 		init_registers(dev);
 		netif_device_attach(dev);
 		spin_unlock_irq(&np->lock);
-		enable_irq(dev->irq);
+		enable_irq(irq);
 
 		mod_timer(&np->timer, round_jiffies(jiffies + 1*HZ));
 	}
-- 
1.7.7.6
