From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] b44: netpoll locking fix
Date: Tue, 29 May 2007 14:27:34 -0700
Message-ID: <20070529142734.3de0ef4f@freepuppy>
References: <20070529211458.GA31200@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:42095 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbXE2Vgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 17:36:42 -0400
In-Reply-To: <20070529211458.GA31200@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 23:14:58 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> The irq handling thread (b44_interrupt) uses the same lock as the NAPI
> thread. This change should prevent a deadlock if something interrupts
> the b44 NAPI thread and tries to printk through netconsole.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>


Better to just get rid of using the lock as a transmit lock and
use netif_tx_lock instead.
--- a/drivers/net/b44.c	2007-05-29 09:51:43.000000000 -0700
+++ b/drivers/net/b44.c	2007-05-29 14:26:03.000000000 -0700
@@ -607,6 +607,7 @@ static void b44_tx(struct b44 *bp)
 {
 	u32 cur, cons;
 
+	netif_tx_lock(bp->dev);
 	cur  = br32(bp, B44_DMATX_STAT) & DMATX_STAT_CDMASK;
 	cur /= sizeof(struct dma_desc);
 
@@ -622,7 +623,7 @@ static void b44_tx(struct b44 *bp)
 				 skb->len,
 				 PCI_DMA_TODEVICE);
 		rp->skb = NULL;
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb_any(skb);
 	}
 
 	bp->tx_cons = cons;
@@ -631,6 +632,7 @@ static void b44_tx(struct b44 *bp)
 		netif_wake_queue(bp->dev);
 
 	bw32(bp, B44_GPTIMER, 0);
+	netif_tx_unlock(bp->dev);
 }
 
 /* Works like this.  This chip writes a 'struct rx_header" 30 bytes
@@ -855,14 +857,8 @@ static int b44_poll(struct net_device *n
 	struct b44 *bp = netdev_priv(netdev);
 	int done;
 
-	spin_lock_irq(&bp->lock);
-
-	if (bp->istat & (ISTAT_TX | ISTAT_TO)) {
-		/* spin_lock(&bp->tx_lock); */
+	if (bp->istat & (ISTAT_TX | ISTAT_TO))
 		b44_tx(bp);
-		/* spin_unlock(&bp->tx_lock); */
-	}
-	spin_unlock_irq(&bp->lock);
 
 	done = 1;
 	if (bp->istat & ISTAT_RX) {
@@ -970,21 +966,19 @@ static int b44_start_xmit(struct sk_buff
 {
 	struct b44 *bp = netdev_priv(dev);
 	struct sk_buff *bounce_skb;
-	int rc = NETDEV_TX_OK;
 	dma_addr_t mapping;
 	u32 len, entry, ctrl;
 
-	len = skb->len;
-	spin_lock_irq(&bp->lock);
-
-	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(bp) < 1)) {
-		netif_stop_queue(dev);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
-		goto err_out;
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
+			       dev->name);
+		}
+		return NETDEV_TX_BUSY;
 	}
 
+	len = skb->len;
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
@@ -1044,16 +1038,14 @@ static int b44_start_xmit(struct sk_buff
 	if (TX_BUFFS_AVAIL(bp) < 1)
 		netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
-
-out_unlock:
-	spin_unlock_irq(&bp->lock);
+	mmiowb();
 
-	return rc;
+	dev->trans_start = jiffies;
 
+	return NETDEV_TX_OK;
 err_out:
-	rc = NETDEV_TX_BUSY;
-	goto out_unlock;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 static int b44_change_mtu(struct net_device *dev, int new_mtu)
