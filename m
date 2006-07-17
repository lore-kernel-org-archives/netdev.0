From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] NAPI support for forcedeth
Date: Mon, 17 Jul 2006 17:18:47 -0400
Message-ID: <20060717171847.30d08dfb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9878 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751197AbWGQVS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 17:18:57 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Experimental version of NAPI for forcedeth.
Untested, but others may want to help with comments and testing.



---

 drivers/net/Kconfig     |   16 +++++++++
 drivers/net/forcedeth.c |   85 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 86 insertions(+), 15 deletions(-)

318a6a7531f8becf89c42b54b73b1268ff88253f
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3918990..9507013 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1411,6 +1411,22 @@ config FORCEDETH
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called forcedeth.
 
+config FORCEDETH_NAPI
+	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	depends on FORCEDETH && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card. It is
+	  still somewhat experimental and thus not yet enabled by default.
+
+	  If your estimated Rx load is 10kpps or more, or if the card will be
+	  deployed on potentially unfriendly networks (e.g. in a firewall),
+	  then say Y here.
+
+	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
+	  information.
+
+	  If in doubt, say N.
 
 config CS89x0
 	tristate "CS89x0 support"
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 11b8f1b..bd25e84 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1740,13 +1740,14 @@ static int nv_getlen(struct net_device *
 	}
 }
 
-static void nv_rx_process(struct net_device *dev)
+static int nv_rx_process(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 Flags;
 	u32 vlanflags = 0;
+	int count;
 
-	for (;;) {
+	for (count = 0; count < limit; ++count) {
 		struct sk_buff *skb;
 		int len;
 		int i;
@@ -1880,17 +1881,27 @@ static void nv_rx_process(struct net_dev
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: packet %d with %d bytes, proto %d accepted.\n",
 					dev->name, np->cur_rx, len, skb->protocol);
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT)) {
-			vlan_hwaccel_rx(skb, np->vlangrp, vlanflags & NV_RX3_VLAN_TAG_MASK);
-		} else {
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_receive_skb(skb, np->vlangrp, 
+						 vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
+			netif_receive_skb(skb);
+#else
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_rx(skb, np->vlangrp,
+					vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
 			netif_rx(skb);
-		}
+#endif
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
 next_pkt:
 		np->cur_rx++;
 	}
+
+	return count;
 }
 
 static void set_bufsize(struct net_device *dev)
@@ -2376,13 +2387,6 @@ static irqreturn_t nv_nic_irq(int foo, v
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
 
-		nv_rx_process(dev);
-		if (nv_alloc_rx(dev)) {
-			spin_lock(&np->lock);
-			if (!np->in_shutdown)
-				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock(&np->lock);
-		}
 
 		if (events & NVREG_IRQ_LINK) {
 			spin_lock(&np->lock);
@@ -2403,6 +2407,24 @@ static irqreturn_t nv_nic_irq(int foo, v
 			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
 						dev->name, events);
 		}
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (events & NVREG_IRQ_RX_ALL) {
+			spin_lock(&np->lock);
+			netif_rx_schedule(dev);
+			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+			pci_push(base);
+			spin_unlock(&np->lock);
+			break;
+		}
+#else		
+		nv_rx_process(dev, dev->weight);
+		if (nv_alloc_rx(dev)) {
+			spin_lock(&np->lock);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+			spin_unlock(&np->lock);
+		}
+#endif
 		if (i > max_interrupt_work) {
 			spin_lock(&np->lock);
 			/* disable interrupts on the nic */
@@ -2474,6 +2496,28 @@ static irqreturn_t nv_nic_irq_tx(int foo
 	return IRQ_RETVAL(i);
 }
 
+#ifdef CONFIG_FORCEDETH_NAPI
+static int nv_napi_poll(struct net_device *dev, int *budget)
+{
+	int pkts, limit = min(*budget, dev->quota);
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	pkts = nv_rx_process(dev, limit);
+	if (pkts < limit) {
+		netif_rx_complete(dev);
+		spin_lock_irq(np->lock);
+		writel(np->irqmask, base + NvRegIrqMask);
+		spin_unlock_irq(np->lock);
+		return 0;
+	}
+
+	dev->quota -= pkts;
+	*budget -= pkts;
+	return 1;
+}
+#endif
+
 static irqreturn_t nv_nic_irq_rx(int foo, void *data, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -2492,7 +2536,14 @@ static irqreturn_t nv_nic_irq_rx(int foo
 		if (!(events & np->irqmask))
 			break;
 
-		nv_rx_process(dev);
+#ifdef CONFIG_FORCEDETH_NAPI
+		netif_rx_schedule(dev);
+		/* disable interrupts on the nic */
+		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+		pci_push(base);
+		break;
+#else
+		nv_rx_process(dev, dev->weight);
 		if (nv_alloc_rx(dev)) {
 			spin_lock_irq(&np->lock);
 			if (!np->in_shutdown)
@@ -2514,7 +2565,7 @@ static irqreturn_t nv_nic_irq_rx(int foo
 			spin_unlock_irq(&np->lock);
 			break;
 		}
-
+#endif
 	}
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx completed\n", dev->name);
 
@@ -4270,6 +4321,10 @@ static int __devinit nv_probe(struct pci
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
+	dev->weight = 64;
+#ifdef CONFIG_FORCEDETH_NAPI
+	dev->poll = nv_napi_poll;
+#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
-- 
1.1.3
