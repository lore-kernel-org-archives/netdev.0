From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/6] gianfar: delete non NAPI code from the driver.
Date: Fri, 11 Jul 2008 00:33:52 +0200
Message-ID: <20080710223352.GE31019@electric-eye.fr.zoreil.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40831 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751795AbYGJWeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:34:13 -0400
Content-Disposition: inline
In-Reply-To: <20080708.015548.127198943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Kconfig   |    4 --
 drivers/net/gianfar.c |   76 ++++---------------------------------------------
 drivers/net/gianfar.h |   11 -------
 3 files changed, 6 insertions(+), 85 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f74461b..c4841c0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2234,10 +2234,6 @@ config GIANFAR
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
 	  and MPC86xx family of chips, and the FEC on the 8540.
 
-config GFAR_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on GIANFAR
-
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 393a0f1..fa78d68 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -44,8 +44,7 @@
  *  happen immediately, but will wait until either a set number
  *  of frames or amount of time have passed).  In NAPI, the
  *  interrupt handler will signal there is work to be done, and
- *  exit.  Without NAPI, the packet(s) will be handled
- *  immediately.  Both methods will start at the last known empty
+ *  exit. This method will start at the last known empty
  *  descriptor, and process every subsequent descriptor until there
  *  are none left with data (NAPI will stop after a set number of
  *  packets to give time to other tasks, but will eventually
@@ -101,12 +100,6 @@
 #undef BRIEF_GFAR_ERRORS
 #undef VERBOSE_GFAR_ERRORS
 
-#ifdef CONFIG_GFAR_NAPI
-#define RECEIVE(x) netif_receive_skb(x)
-#else
-#define RECEIVE(x) netif_rx(x)
-#endif
-
 const char gfar_driver_name[] = "Gianfar Ethernet";
 const char gfar_driver_version[] = "1.3";
 
@@ -131,9 +124,7 @@ static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gfar_netpoll(struct net_device *dev);
 #endif
@@ -260,9 +251,7 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->hard_start_xmit = gfar_start_xmit;
 	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_GFAR_NAPI
 	netif_napi_add(dev, &priv->napi, gfar_poll, GFAR_DEV_WEIGHT);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = gfar_netpoll;
 #endif
@@ -363,11 +352,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
-#ifdef CONFIG_GFAR_NAPI
 	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
-#else
-	printk(KERN_INFO "%s: Running with NAPI disabled\n", dev->name);
-#endif
 	printk(KERN_INFO "%s: %d/%d RX/TX BD ring size\n",
 	       dev->name, priv->rx_ring_size, priv->tx_ring_size);
 
@@ -945,14 +930,10 @@ tx_skb_fail:
 /* Returns 0 for success. */
 static int gfar_enet_open(struct net_device *dev)
 {
-#ifdef CONFIG_GFAR_NAPI
 	struct gfar_private *priv = netdev_priv(dev);
-#endif
 	int err;
 
-#ifdef CONFIG_GFAR_NAPI
 	napi_enable(&priv->napi);
-#endif
 
 	/* Initialize a bunch of registers */
 	init_registers(dev);
@@ -962,17 +943,13 @@ static int gfar_enet_open(struct net_device *dev)
 	err = init_phy(dev);
 
 	if(err) {
-#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
-#endif
 		return err;
 	}
 
 	err = startup_gfar(dev);
 	if (err) {
-#ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
-#endif
 		return err;
 	}
 
@@ -1128,9 +1105,7 @@ static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-#ifdef CONFIG_GFAR_NAPI
 	napi_disable(&priv->napi);
-#endif
 
 	stop_gfar(dev);
 
@@ -1427,14 +1402,9 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct gfar_private *priv = netdev_priv(dev);
-#ifdef CONFIG_GFAR_NAPI
 	u32 tempval;
-#else
-	unsigned long flags;
-#endif
 
 	/* support NAPI */
-#ifdef CONFIG_GFAR_NAPI
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived */
 	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
@@ -1451,38 +1421,10 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 				dev->name, gfar_read(&priv->regs->ievent),
 				gfar_read(&priv->regs->imask));
 	}
-#else
-	/* Clear IEVENT, so rx interrupt isn't called again
-	 * because of this interrupt */
-	gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
-
-	spin_lock_irqsave(&priv->rxlock, flags);
-	gfar_clean_rx_ring(dev, priv->rx_ring_size);
-
-	/* If we are coalescing interrupts, update the timer */
-	/* Otherwise, clear it */
-	if (likely(priv->rxcoalescing)) {
-		gfar_write(&priv->regs->rxic, 0);
-		gfar_write(&priv->regs->rxic,
-			   mk_ic_value(priv->rxcount, priv->rxtime));
-	}
-
-	spin_unlock_irqrestore(&priv->rxlock, flags);
-#endif
 
 	return IRQ_HANDLED;
 }
 
-static inline int gfar_rx_vlan(struct sk_buff *skb,
-		struct vlan_group *vlgrp, unsigned short vlctl)
-{
-#ifdef CONFIG_GFAR_NAPI
-	return vlan_hwaccel_receive_skb(skb, vlgrp, vlctl);
-#else
-	return vlan_hwaccel_rx(skb, vlgrp, vlctl);
-#endif
-}
-
 static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 {
 	/* If valid headers were found, and valid sums
@@ -1539,10 +1481,11 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 		skb->protocol = eth_type_trans(skb, dev);
 
 		/* Send the packet up the stack */
-		if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN)))
-			ret = gfar_rx_vlan(skb, priv->vlgrp, fcb->vlctl);
-		else
-			ret = RECEIVE(skb);
+		if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN))) {
+			ret = vlan_hwaccel_receive_skb(skb, priv->vlgrp,
+						       fcb->vlctl);
+		} else
+			ret = netif_receive_skb(skb);
 
 		if (NET_RX_DROP == ret)
 			priv->extra_stats.kernel_dropped++;
@@ -1629,7 +1572,6 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 	return howmany;
 }
 
-#ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
@@ -1664,7 +1606,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 	return howmany;
 }
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
@@ -2003,11 +1944,6 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 
 		gfar_receive(irq, dev_id);
 
-#ifndef CONFIG_GFAR_NAPI
-		/* Clear the halt bit in RSTAT */
-		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
-#endif
-
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: busy error (rstat: %x)\n",
 			       dev->name, gfar_read(&priv->regs->rstat));
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 27f37c8..bead71c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -77,13 +77,8 @@ extern const char gfar_driver_name[];
 extern const char gfar_driver_version[];
 
 /* These need to be powers of 2 for this driver */
-#ifdef CONFIG_GFAR_NAPI
 #define DEFAULT_TX_RING_SIZE	256
 #define DEFAULT_RX_RING_SIZE	256
-#else
-#define DEFAULT_TX_RING_SIZE    64
-#define DEFAULT_RX_RING_SIZE    64
-#endif
 
 #define GFAR_RX_MAX_RING_SIZE   256
 #define GFAR_TX_MAX_RING_SIZE   256
@@ -128,14 +123,8 @@ extern const char gfar_driver_version[];
 
 #define DEFAULT_RXTIME	21
 
-/* Non NAPI Case */
-#ifndef CONFIG_GFAR_NAPI
-#define DEFAULT_RX_COALESCE 1
-#define DEFAULT_RXCOUNT	16
-#else
 #define DEFAULT_RX_COALESCE 0
 #define DEFAULT_RXCOUNT	0
-#endif /* CONFIG_GFAR_NAPI */
 
 #define MIIMCFG_INIT_VALUE	0x00000007
 #define MIIMCFG_RESET           0x80000000
-- 
1.5.3.3

