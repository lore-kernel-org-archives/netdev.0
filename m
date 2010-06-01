From: sonic zhang <sonic.adi@gmail.com>
Subject: [PATCH] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Tue, 1 Jun 2010 17:19:34 +0800
Message-ID: <1275383974.1010.5.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:45606 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab0FAJKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 05:10:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKBs hold onto resources that can't be held indefinitely, such as TCP
socket references and netfilter conntrack state.  So if a packet is left
in TX ring for a long time, there might be a TCP socket that cannot be
closed and freed up.

Current blackfin EMAC driver always reclaim and free used tx skbs in future
transfers. The problem is that future transfer may not come as soon as
possible. This patch start a timer after transfer to reclaim and free skb.
There is nearly no performance drop with this patch.

TX interrupt is not enabled for 2 reasons:

1) If Blackfin EMAC TX transfer control is turned on, endless TX 
interrupts are triggered no matter if TX DMA is enabled. Since DMA walks
down the ring automatically, TX transfer control can't be turned off in the
middle. The only way is to disable TX interrupt completely.

2) skb can not be freed from interrupt context. A work queue or tasklet
has to be created, which introduce more overhead than timer only solution.



Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/bfin_mac.c |  111 +++++++++++++++++++++++++++++------------------
 drivers/net/bfin_mac.h |    5 ++
 2 files changed, 73 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 368f333..f2eebed 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -922,61 +922,68 @@ static void bfin_mac_hwtstamp_init(struct net_device *netdev)
 # define bfin_tx_hwtstamp(dev, skb)
 #endif
 
-static void adjust_tx_list(void)
+static inline void _tx_reclaim_skb(void)
+{
+	do {
+		tx_list_head->desc_a.config &= ~DMAEN;
+		tx_list_head->status.status_word = 0;
+		if (tx_list_head->skb) {
+			dev_kfree_skb(tx_list_head->skb);
+			tx_list_head->skb = NULL;
+		}
+		tx_list_head = tx_list_head->next;
+
+	} while (tx_list_head->status.status_word != 0);
+}
+
+static void tx_reclaim_skb(struct bfin_mac_local *lp)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
 
-	if (tx_list_head->status.status_word != 0 &&
-	    current_tx_ptr != tx_list_head) {
-		goto adjust_head;	/* released something, just return; */
-	}
+	if (tx_list_head->status.status_word != 0)
+		_tx_reclaim_skb();
 
-	/*
-	 * if nothing released, check wait condition
-	 * current's next can not be the head,
-	 * otherwise the dma will not stop as we want
-	 */
-	if (current_tx_ptr->next->next == tx_list_head) {
+	if (current_tx_ptr->next == tx_list_head) {
 		while (tx_list_head->status.status_word == 0) {
+			/* slow down polling to avoid too many queue stop. */
 			udelay(10);
-			if (tx_list_head->status.status_word != 0 ||
-			    !(bfin_read_DMA2_IRQ_STATUS() & DMA_RUN)) {
-				goto adjust_head;
-			}
-			if (timeout_cnt-- < 0) {
-				printk(KERN_ERR DRV_NAME
-				": wait for adjust tx list head timeout\n");
+			/* reclaim skb if DMA is not running. */
+			if (!(bfin_read_DMA2_IRQ_STATUS() & DMA_RUN))
+				break;
+			if (timeout_cnt-- < 0)
 				break;
-			}
-		}
-		if (tx_list_head->status.status_word != 0) {
-			goto adjust_head;
 		}
+
+		if (timeout_cnt >= 0)
+			_tx_reclaim_skb();
+		else
+			netif_stop_queue(lp->ndev);
 	}
 
-	return;
+	if (current_tx_ptr->next != tx_list_head &&
+		netif_queue_stopped(lp->ndev))
+		netif_wake_queue(lp->ndev);
 
-adjust_head:
-	do {
-		tx_list_head->desc_a.config &= ~DMAEN;
-		tx_list_head->status.status_word = 0;
-		if (tx_list_head->skb) {
-			dev_kfree_skb(tx_list_head->skb);
-			tx_list_head->skb = NULL;
-		} else {
-			printk(KERN_ERR DRV_NAME
-			       ": no sk_buff in a transmitted frame!\n");
-		}
-		tx_list_head = tx_list_head->next;
-	} while (tx_list_head->status.status_word != 0 &&
-		 current_tx_ptr != tx_list_head);
-	return;
+	if (tx_list_head != current_tx_ptr) {
+		/* shorten the timer interval if tx queue is stopped */
+		if (netif_queue_stopped(lp->ndev))
+			lp->tx_reclaim_timer.expires =
+				jiffies + (TX_RECLAIM_JIFFIES >> 4);
+		else
+			lp->tx_reclaim_timer.expires =
+				jiffies + TX_RECLAIM_JIFFIES;
+
+		mod_timer(&lp->tx_reclaim_timer,
+			lp->tx_reclaim_timer.expires);
+	}
 
+	return;
 }
 
 static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
+	struct bfin_mac_local *lp = netdev_priv(dev);
 	u16 *data;
 	u32 data_align = (unsigned long)(skb->data) & 0x3;
 	union skb_shared_tx *shtx = skb_tx(skb);
@@ -1009,8 +1016,6 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 			skb->len);
 		current_tx_ptr->desc_a.start_addr =
 			(u32)current_tx_ptr->packet;
-		if (current_tx_ptr->status.status_word != 0)
-			current_tx_ptr->status.status_word = 0;
 		blackfin_dcache_flush_range(
 			(u32)current_tx_ptr->packet,
 			(u32)(current_tx_ptr->packet + skb->len + 2));
@@ -1022,6 +1027,9 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	 */
 	SSYNC();
 
+	/* always clear status buffer before start tx dma */
+	current_tx_ptr->status.status_word = 0;
+
 	/* enable this packet's dma */
 	current_tx_ptr->desc_a.config |= DMAEN;
 
@@ -1037,13 +1045,14 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
 
 out:
-	adjust_tx_list();
-
 	bfin_tx_hwtstamp(dev, skb);
 
 	current_tx_ptr = current_tx_ptr->next;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += (skb->len);
+
+	tx_reclaim_skb(lp);
+
 	return NETDEV_TX_OK;
 }
 
@@ -1167,8 +1176,11 @@ real_rx:
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void bfin_mac_poll(struct net_device *dev)
 {
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
 	disable_irq(IRQ_MAC_RX);
 	bfin_mac_interrupt(IRQ_MAC_RX, dev);
+	tx_reclaim_skb(lp);
 	enable_irq(IRQ_MAC_RX);
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
@@ -1232,12 +1244,20 @@ static int bfin_mac_enable(void)
 /* Our watchdog timed out. Called by the networking layer */
 static void bfin_mac_timeout(struct net_device *dev)
 {
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
 	pr_debug("%s: %s\n", dev->name, __func__);
 
 	bfin_mac_disable();
 
+	if (timer_pending(&lp->tx_reclaim_timer))
+		del_timer(&(lp->tx_reclaim_timer));
+
 	/* reset tx queue */
-	tx_list_tail = tx_list_head->next;
+	current_tx_ptr = tx_list_head;
+
+	if (netif_queue_stopped(lp->ndev))
+		netif_wake_queue(lp->ndev);
 
 	bfin_mac_enable();
 
@@ -1430,6 +1450,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	platform_set_drvdata(pdev, ndev);
 	lp = netdev_priv(ndev);
+	lp->ndev = ndev;
 
 	/* Grab the MAC address in the MAC */
 	*(__le32 *) (&(ndev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
@@ -1485,6 +1506,10 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	ndev->netdev_ops = &bfin_mac_netdev_ops;
 	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
+	init_timer(&lp->tx_reclaim_timer);
+	lp->tx_reclaim_timer.data = (unsigned long)(lp);
+	lp->tx_reclaim_timer.function = (void *)tx_reclaim_skb;
+
 	spin_lock_init(&lp->lock);
 
 	/* now, enable interrupts */
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 1ae7b82..04e4050 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -13,9 +13,12 @@
 #include <linux/net_tstamp.h>
 #include <linux/clocksource.h>
 #include <linux/timecompare.h>
+#include <linux/timer.h>
 
 #define BFIN_MAC_CSUM_OFFLOAD
 
+#define TX_RECLAIM_JIFFIES (HZ / 5)
+
 struct dma_descriptor {
 	struct dma_descriptor *next_dma_desc;
 	unsigned long start_addr;
@@ -68,6 +71,8 @@ struct bfin_mac_local {
 
 	int wol;		/* Wake On Lan */
 	int irq_wake_requested;
+	struct timer_list tx_reclaim_timer;
+	struct net_device *ndev;
 
 	/* MII and PHY stuffs */
 	int old_link;          /* used by bf537_adjust_link */
-- 
1.6.0



