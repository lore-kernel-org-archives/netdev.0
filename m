From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/3] starfire: delete non NAPI code from the driver.
Date: Sun, 6 Jul 2008 23:42:55 +0200
Message-ID: <20080706214255.GA19387@electric-eye.fr.zoreil.com>
References: <20080704125446.GA30300@havoc.gtf.org> <20080705.211029.199316974.davem@davemloft.net> <20080705.212051.82650078.davem@davemloft.net> <20080706214109.GA13120@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Ion Badulescu <ionut@badula.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59599 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358AbYGFVnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 17:43:12 -0400
Content-Disposition: inline
In-Reply-To: <20080706214109.GA13120@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ion Badulescu <ionut@badula.org>
---
 arch/mips/configs/mtx1_defconfig |    1 -
 drivers/net/Kconfig              |   14 -----
 drivers/net/starfire.c           |  111 +++++++++++++++----------------------
 3 files changed, 45 insertions(+), 81 deletions(-)

diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index de523b3..6449635 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -1263,7 +1263,6 @@ CONFIG_PCNET32=m
 CONFIG_AMD8111_ETH=m
 # CONFIG_AMD8111E_NAPI is not set
 CONFIG_ADAPTEC_STARFIRE=m
-# CONFIG_ADAPTEC_STARFIRE_NAPI is not set
 CONFIG_B44=m
 CONFIG_FORCEDETH=m
 # CONFIG_FORCEDETH_NAPI is not set
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e34a3e7..9255895 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1314,20 +1314,6 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
-config ADAPTEC_STARFIRE_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on ADAPTEC_STARFIRE && EXPERIMENTAL
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
 config AC3200
 	tristate "Ansel Communications EISA 3200 support (EXPERIMENTAL)"
 	depends on NET_PCI && (ISA || EISA) && EXPERIMENTAL
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7b7b171..d7fce55 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -27,8 +27,8 @@
 */
 
 #define DRV_NAME	"starfire"
-#define DRV_VERSION	"2.0"
-#define DRV_RELDATE	"June 27, 2006"
+#define DRV_VERSION	"2.1"
+#define DRV_RELDATE	"July  6, 2008"
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -69,10 +69,6 @@
 #define VLAN_SUPPORT
 #endif
 
-#ifndef CONFIG_ADAPTEC_STARFIRE_NAPI
-#undef HAVE_NETDEV_POLL
-#endif
-
 /* The user-configurable values.
    These may be modified when a driver module is loaded.*/
 
@@ -177,44 +173,6 @@ static int full_duplex[MAX_UNITS] = {0, };
 #define skb_first_frag_len(skb)	skb_headlen(skb)
 #define skb_num_frags(skb) (skb_shinfo(skb)->nr_frags + 1)
 
-#ifdef HAVE_NETDEV_POLL
-#define init_poll(dev, np) \
-	netif_napi_add(dev, &np->napi, netdev_poll, max_interrupt_work)
-#define netdev_rx(dev, np, ioaddr) \
-do { \
-	u32 intr_enable; \
-	if (netif_rx_schedule_prep(dev, &np->napi)) { \
-		__netif_rx_schedule(dev, &np->napi); \
-		intr_enable = readl(ioaddr + IntrEnable); \
-		intr_enable &= ~(IntrRxDone | IntrRxEmpty); \
-		writel(intr_enable, ioaddr + IntrEnable); \
-		readl(ioaddr + IntrEnable); /* flush PCI posting buffers */ \
-	} else { \
-		/* Paranoia check */ \
-		intr_enable = readl(ioaddr + IntrEnable); \
-		if (intr_enable & (IntrRxDone | IntrRxEmpty)) { \
-			printk(KERN_INFO "%s: interrupt while in polling mode!\n", dev->name); \
-			intr_enable &= ~(IntrRxDone | IntrRxEmpty); \
-			writel(intr_enable, ioaddr + IntrEnable); \
-		} \
-	} \
-} while (0)
-#define netdev_receive_skb(skb) netif_receive_skb(skb)
-#define vlan_netdev_receive_skb(skb, vlgrp, vlid) vlan_hwaccel_receive_skb(skb, vlgrp, vlid)
-static int	netdev_poll(struct napi_struct *napi, int budget);
-#else  /* not HAVE_NETDEV_POLL */
-#define init_poll(dev, np)
-#define netdev_receive_skb(skb) netif_rx(skb)
-#define vlan_netdev_receive_skb(skb, vlgrp, vlid) vlan_hwaccel_rx(skb, vlgrp, vlid)
-#define netdev_rx(dev, np, ioaddr) \
-do { \
-	int quota = np->dirty_rx + RX_RING_SIZE - np->cur_rx; \
-	__netdev_rx(dev, &quota);\
-} while (0)
-#endif /* not HAVE_NETDEV_POLL */
-/* end of compatibility code */
-
-
 /* These identify the driver base version and may not be removed. */
 static char version[] =
 KERN_INFO "starfire.c:v1.03 7/26/2000  Written by Donald Becker <becker@scyld.com>\n"
@@ -635,6 +593,7 @@ static int	start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void	netdev_error(struct net_device *dev, int intr_status);
 static int	__netdev_rx(struct net_device *dev, int *quota);
+static int	netdev_poll(struct napi_struct *napi, int budget);
 static void	refill_rx_ring(struct net_device *dev);
 static void	netdev_error(struct net_device *dev, int intr_status);
 static void	set_rx_mode(struct net_device *dev);
@@ -851,7 +810,7 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	dev->hard_start_xmit = &start_tx;
 	dev->tx_timeout = tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	init_poll(dev, np);
+	netif_napi_add(dev, &np->napi, netdev_poll, max_interrupt_work);
 	dev->stop = &netdev_close;
 	dev->get_stats = &get_stats;
 	dev->set_multicast_list = &set_rx_mode;
@@ -1054,9 +1013,8 @@ static int netdev_open(struct net_device *dev)
 
 	writel(np->intr_timer_ctrl, ioaddr + IntrTimerCtrl);
 
-#ifdef HAVE_NETDEV_POLL
 	napi_enable(&np->napi);
-#endif
+
 	netif_start_queue(dev);
 
 	if (debug > 1)
@@ -1330,8 +1288,28 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 		handled = 1;
 
-		if (intr_status & (IntrRxDone | IntrRxEmpty))
-			netdev_rx(dev, np, ioaddr);
+		if (intr_status & (IntrRxDone | IntrRxEmpty)) {
+			u32 enable;
+
+			if (likely(netif_rx_schedule_prep(dev, &np->napi))) {
+				__netif_rx_schedule(dev, &np->napi);
+				enable = readl(ioaddr + IntrEnable);
+				enable &= ~(IntrRxDone | IntrRxEmpty);
+				writel(enable, ioaddr + IntrEnable);
+				/* flush PCI posting buffers */
+				readl(ioaddr + IntrEnable);
+			} else {
+				/* Paranoia check */
+				enable = readl(ioaddr + IntrEnable);
+				if (enable & (IntrRxDone | IntrRxEmpty)) {
+					printk(KERN_INFO
+					       "%s: interrupt while in poll!\n",
+					       dev->name);
+					enable &= ~(IntrRxDone | IntrRxEmpty);
+					writel(enable, ioaddr + IntrEnable);
+				}
+			}
+		}
 
 		/* Scavenge the skbuff list based on the Tx-done queue.
 		   There are redundant checks here that may be cleaned up
@@ -1411,8 +1389,10 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 }
 
 
-/* This routine is logically part of the interrupt/poll handler, but separated
-   for clarity, code sharing between NAPI/non-NAPI, and better register allocation. */
+/*
+ * This routine is logically part of the interrupt/poll handler, but separated
+ * for clarity and better register allocation.
+ */
 static int __netdev_rx(struct net_device *dev, int *quota)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -1507,13 +1487,20 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		}
 #ifdef VLAN_SUPPORT
 		if (np->vlgrp && le16_to_cpu(desc->status2) & 0x0200) {
-			if (debug > 4)
-				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n", le16_to_cpu(desc->vlanid));
-			/* vlan_netdev_receive_skb() expects a packet with the VLAN tag stripped out */
-			vlan_netdev_receive_skb(skb, np->vlgrp, le16_to_cpu(desc->vlanid) & VLAN_VID_MASK);
+			u16 vlid = le16_to_cpu(desc->vlanid) & VLAN_VID_MASK;
+
+			if (debug > 4) {
+				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n",
+				       vlid);
+			}
+			/*
+			 * vlan_hwaccel_rx expects a packet with the VLAN tag
+			 * stripped out.
+			 */
+			vlan_hwaccel_rx(skb, np->vlgrp, vlid);
 		} else
 #endif /* VLAN_SUPPORT */
-			netdev_receive_skb(skb);
+			netif_receive_skb(skb);
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 
@@ -1532,8 +1519,6 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 	return retcode;
 }
 
-
-#ifdef HAVE_NETDEV_POLL
 static int netdev_poll(struct napi_struct *napi, int budget)
 {
 	struct netdev_private *np = container_of(napi, struct netdev_private, napi);
@@ -1564,8 +1549,6 @@ static int netdev_poll(struct napi_struct *napi, int budget)
 	/* Restart Rx engine if stopped. */
 	return budget - quota;
 }
-#endif /* HAVE_NETDEV_POLL */
-
 
 static void refill_rx_ring(struct net_device *dev)
 {
@@ -1906,9 +1889,8 @@ static int netdev_close(struct net_device *dev)
 	int i;
 
 	netif_stop_queue(dev);
-#ifdef HAVE_NETDEV_POLL
+
 	napi_disable(&np->napi);
-#endif
 
 	if (debug > 1) {
 		printk(KERN_DEBUG "%s: Shutting down ethercard, Intr status %#8.8x.\n",
@@ -2044,11 +2026,8 @@ static int __init starfire_init (void)
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
 	printk(version);
-#ifdef HAVE_NETDEV_POLL
+
 	printk(KERN_INFO DRV_NAME ": polling (NAPI) enabled\n");
-#else
-	printk(KERN_INFO DRV_NAME ": polling (NAPI) disabled\n");
-#endif
 #endif
 
 	/* we can do this test only at run-time... sigh */
-- 
1.5.3.3

