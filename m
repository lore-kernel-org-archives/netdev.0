From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH 2.6.25] pcnet32:  delete non NAPI code from driver.
Date: Mon, 21 Apr 2008 10:41:35 -0700
Message-ID: <1208799695.3619.1.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:52149 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbYDUSFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 14:05:13 -0400
Received: from [192.168.1.3] ([72.90.101.98])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JZO0082NSVYIIS0@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Mon, 21 Apr 2008 13:04:47 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete the non-napi code from the driver and Kconfig.
Tested x86_64.  Apply at next open opportunity.

Signed-off-by: Don Fry <pcnet32@verizon.net>
--- linux-2.6.25/drivers/net/orig.pcnet32.c	2008-04-16
19:49:44.000000000 -0700
+++ linux-2.6.25/drivers/net/pcnet32.c	2008-04-21 08:24:55.000000000
-0700
@@ -22,12 +22,8 @@

*************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#ifdef CONFIG_PCNET32_NAPI
-#define DRV_VERSION	"1.34-NAPI"
-#else
-#define DRV_VERSION	"1.34"
-#endif
-#define DRV_RELDATE	"14.Aug.2007"
+#define DRV_VERSION	"1.35"
+#define DRV_RELDATE	"21.Apr.2008"
 #define PFX		DRV_NAME ": "
 
 static const char *const version =
@@ -445,30 +441,24 @@ static struct pcnet32_access pcnet32_dwi
 
 static void pcnet32_netif_stop(struct net_device *dev)
 {
-#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
-#endif
+
 	dev->trans_start = jiffies;
-#ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
-#endif
 	netif_tx_disable(dev);
 }
 
 static void pcnet32_netif_start(struct net_device *dev)
 {
-#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
 	ulong ioaddr = dev->base_addr;
 	u16 val;
-#endif
+
 	netif_wake_queue(dev);
-#ifdef CONFIG_PCNET32_NAPI
 	val = lp->a.read_csr(ioaddr, CSR3);
 	val &= 0x00ff;
 	lp->a.write_csr(ioaddr, CSR3, val);
 	napi_enable(&lp->napi);
-#endif
 }
 
 /*
@@ -911,11 +901,7 @@ static int pcnet32_loopback_test(struct 
 	rc = 1;			/* default to fail */
 
 	if (netif_running(dev))
-#ifdef CONFIG_PCNET32_NAPI
 		pcnet32_netif_stop(dev);
-#else
-		pcnet32_close(dev);
-#endif
 
 	spin_lock_irqsave(&lp->lock, flags);
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
@@ -1046,7 +1032,6 @@ static int pcnet32_loopback_test(struct 
 	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
 	a->write_bcr(ioaddr, 32, (x & ~0x0002));
 
-#ifdef CONFIG_PCNET32_NAPI
 	if (netif_running(dev)) {
 		pcnet32_netif_start(dev);
 		pcnet32_restart(dev, CSR0_NORMAL);
@@ -1055,16 +1040,6 @@ static int pcnet32_loopback_test(struct 
 		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-#else
-	if (netif_running(dev)) {
-		spin_unlock_irqrestore(&lp->lock, flags);
-		pcnet32_open(dev);
-	} else {
-		pcnet32_purge_rx_ring(dev);
-		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
-		spin_unlock_irqrestore(&lp->lock, flags);
-	}
-#endif
 
 	return (rc);
 }				/* end pcnet32_loopback_test  */
@@ -1270,11 +1245,7 @@ static void pcnet32_rx_entry(struct net_
 	}
 	dev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_PCNET32_NAPI
 	netif_receive_skb(skb);
-#else
-	netif_rx(skb);
-#endif
 	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	return;
@@ -1403,7 +1374,6 @@ static int pcnet32_tx(struct net_device 
 	return must_restart;
 }
 
-#ifdef CONFIG_PCNET32_NAPI
 static int pcnet32_poll(struct napi_struct *napi, int budget)
 {
 	struct pcnet32_private *lp = container_of(napi, struct
pcnet32_private, napi);
@@ -1442,7 +1412,6 @@ static int pcnet32_poll(struct napi_stru
 	}
 	return work_done;
 }
-#endif
 
 #define PCNET32_REGS_PER_PHY	32
 #define PCNET32_MAX_PHYS	32
@@ -1864,9 +1833,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	/* napi.weight is used in both the napi and non-napi cases */
 	lp->napi.weight = lp->rx_ring_size / 2;
 
-#ifdef CONFIG_PCNET32_NAPI
 	netif_napi_add(dev, &lp->napi, pcnet32_poll, lp->rx_ring_size / 2);
-#endif
 
 	if (fdx && !(lp->options & PCNET32_PORT_ASEL) &&
 	    ((cards_found >= MAX_UNITS) || full_duplex[cards_found]))
@@ -2297,9 +2264,7 @@ static int pcnet32_open(struct net_devic
 		goto err_free_ring;
 	}
 
-#ifdef CONFIG_PCNET32_NAPI
 	napi_enable(&lp->napi);
-#endif
 
 	/* Re-initialize the PCNET32, and start it when done. */
 	lp->a.write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
@@ -2623,7 +2588,6 @@ pcnet32_interrupt(int irq, void *dev_id)
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-#ifdef CONFIG_PCNET32_NAPI
 		if (netif_rx_schedule_prep(dev, &lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
@@ -2634,24 +2598,9 @@ pcnet32_interrupt(int irq, void *dev_id)
 			__netif_rx_schedule(dev, &lp->napi);
 			break;
 		}
-#else
-		pcnet32_rx(dev, lp->napi.weight);
-		if (pcnet32_tx(dev)) {
-			/* reset the chip to clear the error condition, then restart */
-			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, CSR4, 0x0915); /* auto tx pad */
-			pcnet32_restart(dev, CSR0_START);
-			netif_wake_queue(dev);
-		}
-#endif
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
-#ifndef CONFIG_PCNET32_NAPI
-	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
-#endif
-
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
@@ -2670,9 +2619,7 @@ static int pcnet32_close(struct net_devi
 	del_timer_sync(&lp->watchdog_timer);
 
 	netif_stop_queue(dev);
-#ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
-#endif
 
 	spin_lock_irqsave(&lp->lock, flags);
 
--- linux-2.6.25/drivers/net/orig.Kconfig	2008-04-16 19:49:44.000000000
-0700
+++ linux-2.6.25/drivers/net/Kconfig	2008-04-21 08:27:19.000000000 -0700
@@ -1266,20 +1266,6 @@ config PCNET32
 	  To compile this driver as a module, choose M here. The module
 	  will be called pcnet32.
 
-config PCNET32_NAPI
-	bool "Use RX polling (NAPI)"
-	depends on PCNET32
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
 config AMD8111_ETH
 	tristate "AMD 8111 (new PCI lance) support"
 	depends on NET_PCI && PCI


