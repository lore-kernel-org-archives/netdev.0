From: Andrew Victor <andrew@sanpeople.com>
Subject: Re: [PATCH 2.6.18] AT91RM9200 Ethernet update
Date: 19 Oct 2006 18:06:12 +0200
Message-ID: <1161273972.10090.65.camel@fuzzie.sanpeople.com>
References: <1159439988.23157.88.camel@fuzzie.sanpeople.com>
	 <4524EC40.4000401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [196.211.225.226] ([196.211.225.226]:37382 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP
	id S1946179AbWJSQOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 12:14:53 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4524EC40.4000401@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

> ACK, but patch doesn't apply to 2.6.18

The patch failed due to AT91_ID_EMAC being renamed to
AT91RM9200_ID_EMAC.

Updated patch for 2.6.19-rc2 attached.

Regards,
  Andrew Victor


-----

This patch contains a few updates to the AT91RM9200 Ethernet driver.

The changes are:
1. Remove the global 'at91_dev' variable.
2. The global 'check_timer' moved into the private data structure.
3. Rather use dev_alloc_skb() instead of alloc_skb().
4. It is not necessary to adjust skb->len manually.
5. The I/O base-address and IRQ are no longer hard-coded, but are passed
via platform_device resources.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>




diff -urN -x CVS linux-2.6.19-rc2.orig/drivers/net/arm/at91_ether.c linux-2.6.19/drivers/net/arm/at91_ether.c
--- linux-2.6.19-rc2.orig/drivers/net/arm/at91_ether.c	Thu Oct 19 16:31:49 2006
+++ linux-2.6.19/drivers/net/arm/at91_ether.c	Mon Oct 16 14:19:00 2006
@@ -41,9 +41,6 @@
 #define DRV_NAME	"at91_ether"
 #define DRV_VERSION	"1.0"
 
-static struct net_device *at91_dev;
-
-static struct timer_list check_timer;
 #define LINK_POLL_INTERVAL	(HZ)
 
 /* ..................................................................... */
@@ -252,8 +249,8 @@
 		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
 		 * or board does not have it connected.
 		 */
-		check_timer.expires = jiffies + LINK_POLL_INTERVAL;
-		add_timer(&check_timer);
+		lp->check_timer.expires = jiffies + LINK_POLL_INTERVAL;
+		add_timer(&lp->check_timer);
 		return;
 	}
 
@@ -300,7 +297,7 @@
 
 	irq_number = lp->board_data.phy_irq_pin;
 	if (!irq_number) {
-		del_timer_sync(&check_timer);
+		del_timer_sync(&lp->check_timer);
 		return;
 	}
 
@@ -362,13 +359,14 @@
 static void at91ether_check_link(unsigned long dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
+	struct at91_private *lp = (struct at91_private *) dev->priv;
 
 	enable_mdi();
 	update_linkspeed(dev, 1);
 	disable_mdi();
 
-	check_timer.expires = jiffies + LINK_POLL_INTERVAL;
-	add_timer(&check_timer);
+	lp->check_timer.expires = jiffies + LINK_POLL_INTERVAL;
+	add_timer(&lp->check_timer);
 }
 
 /* ......................... ADDRESS MANAGEMENT ........................ */
@@ -857,14 +855,13 @@
 	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
 		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
-		skb = alloc_skb(pktlen + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(pktlen + 2);
 		if (skb != NULL) {
 			skb_reserve(skb, 2);
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
 
 			skb->dev = dev;
 			skb->protocol = eth_type_trans(skb, dev);
-			skb->len = pktlen;
 			dev->last_rx = jiffies;
 			lp->stats.rx_bytes += pktlen;
 			netif_rx(skb);
@@ -937,17 +934,22 @@
 	struct net_device *dev;
 	struct at91_private *lp;
 	unsigned int val;
-	int res;
-
-	if (at91_dev)			/* already initialized */
-		return 0;
+	struct resource *res;
+	int ret;
 
 	dev = alloc_etherdev(sizeof(struct at91_private));
 	if (!dev)
 		return -ENOMEM;
 
-	dev->base_addr = AT91_VA_BASE_EMAC;
-	dev->irq = AT91RM9200_ID_EMAC;
+	/* Get I/O base address and IRQ */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		free_netdev(dev);
+		return -ENODEV;  
+	}
+	dev->base_addr = res->start;
+	dev->irq = platform_get_irq(pdev, 0);
+
 	SET_MODULE_OWNER(dev);
 
 	/* Install the interrupt handler */
@@ -1017,14 +1019,13 @@
 	lp->phy_address = phy_address;	/* MDI address of PHY */
 
 	/* Register the network interface */
-	res = register_netdev(dev);
-	if (res) {
+	ret = register_netdev(dev);
+	if (ret) {
 		free_irq(dev->irq, dev);
 		free_netdev(dev);
 		dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
-		return res;
+		return ret;
 	}
-	at91_dev = dev;
 
 	/* Determine current link speed */
 	spin_lock_irq(&lp->lock);
@@ -1036,9 +1037,9 @@
 
 	/* If board has no PHY IRQ, use a timer to poll the PHY */
 	if (!lp->board_data.phy_irq_pin) {
-		init_timer(&check_timer);
-		check_timer.data = (unsigned long)dev;
-		check_timer.function = at91ether_check_link;
+		init_timer(&lp->check_timer);
+		lp->check_timer.data = (unsigned long)dev;
+		lp->check_timer.function = at91ether_check_link;
 	}
 
 	/* Display ethernet banner */
@@ -1115,15 +1116,16 @@
 
 static int __devexit at91ether_remove(struct platform_device *pdev)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = (struct at91_private *) dev->priv;
 
-	unregister_netdev(at91_dev);
-	free_irq(at91_dev->irq, at91_dev);
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
 	clk_put(lp->ether_clk);
 
-	free_netdev(at91_dev);
-	at91_dev = NULL;
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(dev);
 	return 0;
 }
 
@@ -1131,8 +1133,8 @@
 
 static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = (struct at91_private *) net_dev->priv;
 	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {
@@ -1149,8 +1151,8 @@
 
 static int at91ether_resume(struct platform_device *pdev)
 {
-	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct at91_private *lp = (struct at91_private *) net_dev->priv;
 	int phy_irq = lp->board_data.phy_irq_pin;
 
 	if (netif_running(net_dev)) {
diff -urN -x CVS linux-2.6.19-rc2.orig/drivers/net/arm/at91_ether.h linux-2.6.19/drivers/net/arm/at91_ether.h
--- linux-2.6.19-rc2.orig/drivers/net/arm/at91_ether.h	Thu Oct 19 16:29:18 2006
+++ linux-2.6.19/drivers/net/arm/at91_ether.h	Thu Oct 12 17:07:39 2006
@@ -87,6 +87,7 @@
 	spinlock_t lock;			/* lock for MDI interface */
 	short phy_media;			/* media interface type */
 	unsigned short phy_address;		/* 5-bit MDI address of PHY (0..31) */
+	struct timer_list check_timer;		/* Poll link status */
 
 	/* Transmit */
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */



