From: David Miller <davem@davemloft.net>
Subject: [PATCH RFX]: napi_struct V3
Date: Mon, 23 Jul 2007 21:07:48 -0700 (PDT)
Message-ID: <20070723.210748.63127793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, rusty@rustcorp.com.au,
	jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750774AbXGXEHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 00:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok I converted everything with Rusty's suggestion to move napi_struct
out of net_device, this was mostly mechanical but some devices took
some unanticipated amount of work.

In particular, cxgb3 required a lot of hacking.  It is even totally
broken in current 2.6.23-rc1 because it:

1) relies upon netdev_priv() and netdev->priv being seperate.
   So it hangs a second private pointer in netdev->priv and
   expects netdev_priv() to return the other pointer.

   Yuck!

2) It hangs device private bits in netdev->atalk_priv, breaking
   Appletalk.

   DOUBLE YUCK!

Anyways, I reworked everything in cxgb3 to use per queue-set
napi_struct's and added the appropriate ->netdev back pointers
where needed to make it all work out.

Most drivers now look something like this:

static int foo_poll(struct napi_struct *napi, int budget)
{
	struct foo *fp = container_of(napi, struct foo, napi);
	struct net_device *dev = tp->dev;
	int rx;

	rx = do_rx_work(fp, dev);
	do_tx_work(fp, dev);

	if (rx < budget) {
		netif_rx_complete(dev, napi);
		foo_restart_ints(fp);
	}

	return rx;
}

With the caveat that foo_restart_ints() _MUST_ trigger an interrupt
somehow if it sees any interrupt conditions pending after turning IRQs
back on.  This is absolutely required in order to not lose events.

Another area of consternation are drivers that were using
netif_rx_reschedule(), as that interface was removed because it
doesn't fit well with the caller managing the dev->quota et al.  I
left race conditions in the drivers that were using that interface,
but they should still basically work nonetheless.

I tried to jam a lot of drivers through the compiler by forcing them
to be enable'able in Kconfig on my sparc64 machine, so I think I have
added few, if any, build regressions from these changes.  But if you
have one of these weird platform devices, please check things out.

I also didn't play with turning off NAPI in kconfig where drivers
allow that, can we just get rid of that crap already? :-/

I know I promised to convert sunvnet.c as a multi-queue NAPI driver,
but this de-napi_struct'ification of net_device took longer than
anticipated and I wanted to publish this so people could play with it
and provide comments.

As before, netpoll is busted and needs a rewrite, any suggestions
appreciated.

[NET]: Make NAPI polling independant of struct net_device objects.

Several devices have multiple independant RX queues per net
device, and some have a single interrupt doorbell for several
queues.

In either case, it's easier to support layouts like that if the
structure representing the poll is independant from the net
device itself.

The signature of the ->poll() call back goes from:

	int foo_poll(struct net_device *dev, int *budget)

to

	int foo_poll(struct napi_struct *napi, int budget)

The caller is returned the number of RX packets processed (or
the number of "NAPI credits" consumed if you want to get
abstract).  The callee no longer messes around bumping
dev->quota, *budget, etc. because that is all handled in the
caller upon return.

The napi_struct is to be embedded in the device driver private data
structures.

[ Ported to current tree and more drivers converted.  -DaveM ]

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e970e64..dfe9d3b 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -334,6 +334,8 @@ struct cp_private {
 	spinlock_t		lock;
 	u32			msg_enable;
 
+	struct napi_struct	napi;
+
 	struct pci_dev		*pdev;
 	u32			rx_config;
 	u16			cpcmd;
@@ -501,12 +503,12 @@ static inline unsigned int cp_rx_csum_ok (u32 status)
 	return 0;
 }
 
-static int cp_rx_poll (struct net_device *dev, int *budget)
+static int cp_rx_poll(struct napi_struct *napi, int budget)
 {
-	struct cp_private *cp = netdev_priv(dev);
-	unsigned rx_tail = cp->rx_tail;
-	unsigned rx_work = dev->quota;
-	unsigned rx;
+	struct cp_private *cp = container_of(napi, struct cp_private, napi);
+	struct net_device *dev = cp->dev;
+	unsigned int rx_tail = cp->rx_tail;
+	int rx;
 
 rx_status_loop:
 	rx = 0;
@@ -588,19 +590,16 @@ rx_next:
 			desc->opts1 = cpu_to_le32(DescOwn | cp->rx_buf_sz);
 		rx_tail = NEXT_RX(rx_tail);
 
-		if (!rx_work--)
+		if (rx >= budget)
 			break;
 	}
 
 	cp->rx_tail = rx_tail;
 
-	dev->quota -= rx;
-	*budget -= rx;
-
 	/* if we did not reach work limit, then we're done with
 	 * this round of polling
 	 */
-	if (rx_work) {
+	if (rx < budget) {
 		unsigned long flags;
 
 		if (cpr16(IntrStatus) & cp_rx_intr_mask)
@@ -608,13 +607,11 @@ rx_next:
 
 		local_irq_save(flags);
 		cpw16_f(IntrMask, cp_intr_mask);
-		__netif_rx_complete(dev);
+		__netif_rx_complete(dev, napi);
 		local_irq_restore(flags);
-
-		return 0;	/* done */
 	}
 
-	return 1;		/* not done */
+	return rx;
 }
 
 static irqreturn_t cp_interrupt (int irq, void *dev_instance)
@@ -647,9 +644,9 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	}
 
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &cp->napi)) {
 			cpw16_f(IntrMask, cp_norx_intr_mask);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &cp->napi);
 		}
 
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
@@ -1198,6 +1195,8 @@ static int cp_close (struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 
+	napi_disable(&cp->napi);
+
 	if (netif_msg_ifdown(cp))
 		printk(KERN_DEBUG "%s: disabling interface\n", dev->name);
 
@@ -1934,11 +1933,11 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hard_start_xmit = cp_start_xmit;
 	dev->get_stats = cp_get_stats;
 	dev->do_ioctl = cp_ioctl;
-	dev->poll = cp_rx_poll;
+	cp->napi.poll = cp_rx_poll;
+	cp->napi.weight = 16;	/* arbitrary? from NAPI_HOWTO.txt. */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = cp_poll_controller;
 #endif
-	dev->weight = 16;	/* arbitrary? from NAPI_HOWTO.txt. */
 #ifdef BROKEN
 	dev->change_mtu = cp_change_mtu;
 #endif
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 327eaa7..8fcfe16 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -573,6 +573,8 @@ struct rtl8139_private {
 	int drv_flags;
 	struct pci_dev *pci_dev;
 	u32 msg_enable;
+	struct napi_struct napi;
+	struct net_device *dev;
 	struct net_device_stats stats;
 	unsigned char *rx_ring;
 	unsigned int cur_rx;	/* Index into the Rx buffer of next Rx pkt. */
@@ -625,7 +627,7 @@ static void rtl8139_tx_timeout (struct net_device *dev);
 static void rtl8139_init_ring (struct net_device *dev);
 static int rtl8139_start_xmit (struct sk_buff *skb,
 			       struct net_device *dev);
-static int rtl8139_poll(struct net_device *dev, int *budget);
+static int rtl8139_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rtl8139_poll_controller(struct net_device *dev);
 #endif
@@ -963,6 +965,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 
 	assert (dev != NULL);
 	tp = netdev_priv(dev);
+	tp->dev = dev;
 
 	ioaddr = tp->mmio_addr;
 	assert (ioaddr != NULL);
@@ -976,8 +979,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
-	dev->poll = rtl8139_poll;
-	dev->weight = 64;
+	tp->napi.poll = rtl8139_poll;
+	tp->napi.weight = 64;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -2103,26 +2106,19 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	}
 }
 
-static int rtl8139_poll(struct net_device *dev, int *budget)
+static int rtl8139_poll(struct napi_struct *napi, int budget)
 {
-	struct rtl8139_private *tp = netdev_priv(dev);
+	struct rtl8139_private *tp = container_of(napi, struct rtl8139_private, napi);
+	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->mmio_addr;
-	int orig_budget = min(*budget, dev->quota);
-	int done = 1;
+	int work_done;
 
 	spin_lock(&tp->rx_lock);
-	if (likely(RTL_R16(IntrStatus) & RxAckBits)) {
-		int work_done;
-
-		work_done = rtl8139_rx(dev, tp, orig_budget);
-		if (likely(work_done > 0)) {
-			*budget -= work_done;
-			dev->quota -= work_done;
-			done = (work_done < orig_budget);
-		}
-	}
+	work_done = 0;
+	if (likely(RTL_R16(IntrStatus) & RxAckBits))
+		work_done += rtl8139_rx(dev, tp, budget);
 
-	if (done) {
+	if (work_done < budget) {
 		unsigned long flags;
 		/*
 		 * Order is important since data can get interrupted
@@ -2130,12 +2126,12 @@ static int rtl8139_poll(struct net_device *dev, int *budget)
 		 */
 		local_irq_save(flags);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
-		__netif_rx_complete(dev);
+		__netif_rx_complete(dev, napi);
 		local_irq_restore(flags);
 	}
 	spin_unlock(&tp->rx_lock);
 
-	return !done;
+	return work_done;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
@@ -2180,9 +2176,9 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
 	if (status & RxAckBits){
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &tp->napi)) {
 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
-			__netif_rx_schedule (dev);
+			__netif_rx_schedule(dev, &tp->napi);
 		}
 	}
 
@@ -2223,7 +2219,8 @@ static int rtl8139_close (struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
+	napi_disable(&tp->napi);
 
 	if (netif_msg_ifdown(tp))
 		printk(KERN_DEBUG "%s: Shutting down ethercard, status was 0x%4.4x.\n",
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index a61b2f8..ce349c5 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -723,9 +723,10 @@ static int amd8111e_tx(struct net_device *dev)
 
 #ifdef CONFIG_AMD8111E_NAPI
 /* This function handles the driver receive operation in polling mode */
-static int amd8111e_rx_poll(struct net_device *dev, int * budget)
+static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 {
-	struct amd8111e_priv *lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = container_of(napi, struct amd8111e_priv, napi);
+	struct net_device *dev = lp->amd8111e_net_dev;
 	int rx_index = lp->rx_idx & RX_RING_DR_MOD_MASK;
 	void __iomem *mmio = lp->mmio;
 	struct sk_buff *skb,*new_skb;
@@ -737,7 +738,7 @@ static int amd8111e_rx_poll(struct net_device *dev, int * budget)
 #if AMD8111E_VLAN_TAG_USED
 	short vtag;
 #endif
-	int rx_pkt_limit = dev->quota;
+	int rx_pkt_limit = budget;
 	unsigned long flags;
 
 	do{
@@ -838,21 +839,14 @@ static int amd8111e_rx_poll(struct net_device *dev, int * budget)
 	} while(intr0 & RINT0);
 
 	/* Receive descriptor is empty now */
-	dev->quota -= num_rx_pkt;
-	*budget -= num_rx_pkt;
-
 	spin_lock_irqsave(&lp->lock, flags);
-	netif_rx_complete(dev);
+	netif_rx_complete(dev, napi);
 	writel(VAL0|RINTEN0, mmio + INTEN0);
 	writel(VAL2 | RDMD0, mmio + CMD0);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
 
 rx_not_empty:
-	/* Do not call a netif_rx_complete */
-	dev->quota -= num_rx_pkt;
-	*budget -= num_rx_pkt;
-	return 1;
+	return num_rx_pkt;
 }
 
 #else
@@ -1287,11 +1281,11 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 	/* Check if Receive Interrupt has occurred. */
 #ifdef CONFIG_AMD8111E_NAPI
 	if(intr0 & RINT0){
-		if(netif_rx_schedule_prep(dev)){
+		if(netif_rx_schedule_prep(dev, &lp->napi)){
 			/* Disable receive interupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &lp->napi);
 		}
 		else if (intren0 & RINTEN0) {
 			printk("************Driver bug! \
@@ -1345,6 +1339,8 @@ static int amd8111e_close(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
+	napi_disable(&lp->napi);
+
 	spin_lock_irq(&lp->lock);
 
 	amd8111e_disable_interrupt(lp);
@@ -2031,8 +2027,8 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	dev->tx_timeout = amd8111e_tx_timeout;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
 #ifdef CONFIG_AMD8111E_NAPI
-	dev->poll = amd8111e_rx_poll;
-	dev->weight = 32;
+	lp->napi.poll = amd8111e_rx_poll;
+	lp->napi.weight = 32;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = amd8111e_poll;
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index e65080a..612e653 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -763,6 +763,8 @@ struct amd8111e_priv{
 	/* Reg memory mapped address */
 	void __iomem *mmio;
 
+	struct napi_struct napi;
+
 	spinlock_t lock;	/* Guard lock */
 	unsigned long rx_idx, tx_idx;	/* The next free ring entry */
 	unsigned long tx_complete_idx;
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index f6ece1d..8e862d4 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -169,6 +169,9 @@ struct ep93xx_priv
 	spinlock_t		tx_pending_lock;
 	unsigned int		tx_pending;
 
+	struct net_device	*dev;
+	struct napi_struct	napi;
+
 	struct net_device_stats	stats;
 
 	struct mii_if_info	mii;
@@ -190,15 +193,11 @@ static struct net_device_stats *ep93xx_get_stats(struct net_device *dev)
 	return &(ep->stats);
 }
 
-static int ep93xx_rx(struct net_device *dev, int *budget)
+static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	int rx_done;
-	int processed;
 
-	rx_done = 0;
-	processed = 0;
-	while (*budget > 0) {
+	while (processed < budget) {
 		int entry;
 		struct ep93xx_rstat *rstat;
 		u32 rstat0;
@@ -211,10 +210,8 @@ static int ep93xx_rx(struct net_device *dev, int *budget)
 
 		rstat0 = rstat->rstat0;
 		rstat1 = rstat->rstat1;
-		if (!(rstat0 & RSTAT0_RFP) || !(rstat1 & RSTAT1_RFP)) {
-			rx_done = 1;
+		if (!(rstat0 & RSTAT0_RFP) || !(rstat1 & RSTAT1_RFP))
 			break;
-		}
 
 		rstat->rstat0 = 0;
 		rstat->rstat1 = 0;
@@ -275,8 +272,6 @@ static int ep93xx_rx(struct net_device *dev, int *budget)
 err:
 		ep->rx_pointer = (entry + 1) & (RX_QUEUE_ENTRIES - 1);
 		processed++;
-		dev->quota--;
-		(*budget)--;
 	}
 
 	if (processed) {
@@ -284,7 +279,7 @@ err:
 		wrw(ep, REG_RXSTSENQ, processed);
 	}
 
-	return !rx_done;
+	return processed;
 }
 
 static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
@@ -293,36 +288,32 @@ static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
 	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
 }
 
-static int ep93xx_poll(struct net_device *dev, int *budget)
+static int ep93xx_poll(struct napi_struct *napi, int budget)
 {
-	struct ep93xx_priv *ep = netdev_priv(dev);
+	struct ep93xx_priv *ep = container_of(napi, struct ep93xx_priv, napi);
+	struct net_device *dev = ep->dev;
+	int rx;
 
 	/*
 	 * @@@ Have to stop polling if device is downed while we
 	 * are polling.
 	 */
 
-poll_some_more:
-	if (ep93xx_rx(dev, budget))
-		return 1;
-
-	netif_rx_complete(dev);
-
-	spin_lock_irq(&ep->rx_lock);
-	wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
-	if (ep93xx_have_more_rx(ep)) {
-		wrl(ep, REG_INTEN, REG_INTEN_TX);
-		wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
-		spin_unlock_irq(&ep->rx_lock);
-
-		if (netif_rx_reschedule(dev, 0))
-			goto poll_some_more;
-
-		return 0;
+	rx = ep93xx_rx(dev, 0, budget);
+	if (rx < budget) {
+		spin_lock_irq(&ep->rx_lock);
+		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
+		if (ep93xx_have_more_rx(ep)) {
+			wrl(ep, REG_INTEN, REG_INTEN_TX);
+			wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
+			spin_unlock_irq(&ep->rx_lock);
+		} else {
+			netif_rx_complete(dev, napi);
+			spin_unlock_irq(&ep->rx_lock);
+		}
 	}
-	spin_unlock_irq(&ep->rx_lock);
 
-	return 0;
+	return rx;
 }
 
 static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -426,9 +417,9 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id)
 
 	if (status & REG_INTSTS_RX) {
 		spin_lock(&ep->rx_lock);
-		if (likely(__netif_rx_schedule_prep(dev))) {
+		if (likely(__netif_rx_schedule_prep(dev, &ep->napi))) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &ep->napi);
 		}
 		spin_unlock(&ep->rx_lock);
 	}
@@ -788,14 +779,12 @@ struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 
 	dev->get_stats = ep93xx_get_stats;
 	dev->ethtool_ops = &ep93xx_ethtool_ops;
-	dev->poll = ep93xx_poll;
 	dev->hard_start_xmit = ep93xx_xmit;
 	dev->open = ep93xx_open;
 	dev->stop = ep93xx_close;
 	dev->do_ioctl = ep93xx_ioctl;
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->weight = 64;
 
 	return dev;
 }
@@ -847,6 +836,9 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 		goto err_out;
 	}
 	ep = netdev_priv(dev);
+	ep->dev = dev;
+	ep->napi.poll = ep93xx_poll;
+	ep->napi.weight = 64;
 
 	platform_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 37f1b6f..b8d13b8 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -848,10 +848,11 @@ static int b44_rx(struct b44 *bp, int budget)
 	return received;
 }
 
-static int b44_poll(struct net_device *netdev, int *budget)
+static int b44_poll(struct napi_struct *napi, int budget)
 {
-	struct b44 *bp = netdev_priv(netdev);
-	int done;
+	struct b44 *bp = container_of(napi, struct b44, napi);
+	struct net_device *netdev = bp->dev;
+	int work_done;
 
 	spin_lock_irq(&bp->lock);
 
@@ -862,22 +863,9 @@ static int b44_poll(struct net_device *netdev, int *budget)
 	}
 	spin_unlock_irq(&bp->lock);
 
-	done = 1;
-	if (bp->istat & ISTAT_RX) {
-		int orig_budget = *budget;
-		int work_done;
-
-		if (orig_budget > netdev->quota)
-			orig_budget = netdev->quota;
-
-		work_done = b44_rx(bp, orig_budget);
-
-		*budget -= work_done;
-		netdev->quota -= work_done;
-
-		if (work_done >= orig_budget)
-			done = 0;
-	}
+	work_done = 0;
+	if (bp->istat & ISTAT_RX)
+		work_done += b44_rx(bp, budget);
 
 	if (bp->istat & ISTAT_ERRORS) {
 		unsigned long flags;
@@ -888,15 +876,15 @@ static int b44_poll(struct net_device *netdev, int *budget)
 		b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
 		netif_wake_queue(bp->dev);
 		spin_unlock_irqrestore(&bp->lock, flags);
-		done = 1;
+		work_done = 0;
 	}
 
-	if (done) {
-		netif_rx_complete(netdev);
+	if (work_done < budget) {
+		netif_rx_complete(netdev, napi);
 		b44_enable_ints(bp);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static irqreturn_t b44_interrupt(int irq, void *dev_id)
@@ -924,13 +912,13 @@ static irqreturn_t b44_interrupt(int irq, void *dev_id)
 			goto irq_ack;
 		}
 
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &bp->napi)) {
 			/* NOTE: These writes are posted by the readback of
 			 *       the ISTAT register below.
 			 */
 			bp->istat = istat;
 			__b44_disable_ints(bp);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &bp->napi);
 		} else {
 			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
 			       dev->name);
@@ -1609,7 +1597,7 @@ static int b44_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	netif_poll_disable(dev);
+	napi_disable(&bp->napi);
 
 	del_timer_sync(&bp->timer);
 
@@ -1626,7 +1614,7 @@ static int b44_close(struct net_device *dev)
 
 	free_irq(dev->irq, dev);
 
-	netif_poll_enable(dev);
+	napi_enable(&bp->napi);
 
 	if (bp->flags & B44_FLAG_WOL_ENABLE) {
 		b44_init_hw(bp, B44_PARTIAL_RESET);
@@ -2195,8 +2183,8 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = b44_set_mac_addr;
 	dev->do_ioctl = b44_ioctl;
 	dev->tx_timeout = b44_tx_timeout;
-	dev->poll = b44_poll;
-	dev->weight = 64;
+	bp->napi.poll = b44_poll;
+	bp->napi.weight = 64;
 	dev->watchdog_timeo = B44_TX_TIMEOUT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = b44_poll_controller;
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index e537e63..63c55a4 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -423,6 +423,8 @@ struct b44 {
 	struct ring_info	*rx_buffers;
 	struct ring_info	*tx_buffers;
 
+	struct napi_struct	napi;
+
 	u32			dma_offset;
 	u32			flags;
 #define B44_FLAG_B0_ANDLATER	0x00000001
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a729da0..fa2ca57 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -428,7 +428,7 @@ bnx2_netif_stop(struct bnx2 *bp)
 {
 	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
-		netif_poll_disable(bp->dev);
+		napi_disable(&bp->napi);
 		netif_tx_disable(bp->dev);
 		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
 	}
@@ -440,7 +440,7 @@ bnx2_netif_start(struct bnx2 *bp)
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
 			netif_wake_queue(bp->dev);
-			netif_poll_enable(bp->dev);
+			napi_enable(&bp->napi);
 			bnx2_enable_int(bp);
 		}
 	}
@@ -2551,7 +2551,7 @@ bnx2_msi(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &bp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2568,7 +2568,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &bp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2604,9 +2604,9 @@ bnx2_interrupt(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &bp->napi)) {
 		bp->last_status_idx = sblk->status_idx;
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &bp->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2632,12 +2632,14 @@ bnx2_has_work(struct bnx2 *bp)
 }
 
 static int
-bnx2_poll(struct net_device *dev, int *budget)
+bnx2_poll(struct napi_struct *napi, int budget)
 {
-	struct bnx2 *bp = netdev_priv(dev);
+	struct bnx2 *bp = container_of(napi, struct bnx2, napi);
+	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bp->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
+	int work_done = 0;
 
 	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
@@ -2655,23 +2657,14 @@ bnx2_poll(struct net_device *dev, int *budget)
 	if (bp->status_blk->status_tx_quick_consumer_index0 != bp->hw_tx_cons)
 		bnx2_tx_int(bp);
 
-	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons) {
-		int orig_budget = *budget;
-		int work_done;
-
-		if (orig_budget > dev->quota)
-			orig_budget = dev->quota;
-
-		work_done = bnx2_rx_int(bp, orig_budget);
-		*budget -= work_done;
-		dev->quota -= work_done;
-	}
+	if (bp->status_blk->status_rx_quick_consumer_index0 != bp->hw_rx_cons)
+		work_done = bnx2_rx_int(bp, budget);
 
 	bp->last_status_idx = bp->status_blk->status_idx;
 	rmb();
 
 	if (!bnx2_has_work(bp)) {
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		if (likely(bp->flags & USING_MSI_FLAG)) {
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
@@ -2686,10 +2679,9 @@ bnx2_poll(struct net_device *dev, int *budget)
 		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 		       bp->last_status_idx);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 /* Called with rtnl_lock from vlan functions and also netif_tx_lock
@@ -5292,6 +5284,8 @@ bnx2_close(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 reset_code;
 
+	napi_disable(&bp->napi);
+
 	/* Calling flush_scheduled_work() may deadlock because
 	 * linkwatch_event() may be on the workqueue and it will try to get
 	 * the rtnl_lock which we are holding.
@@ -6856,11 +6850,11 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef BCM_VLAN
 	dev->vlan_rx_register = bnx2_vlan_rx_register;
 #endif
-	dev->poll = bnx2_poll;
 	dev->ethtool_ops = &bnx2_ethtool_ops;
-	dev->weight = 64;
 
 	bp = netdev_priv(dev);
+	bp->napi.weight = 64;
+	bp->napi.poll = bnx2_poll;
 
 #if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
 	dev->poll_controller = poll_bnx2;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 102adfe..fbae439 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6473,6 +6473,8 @@ struct bnx2 {
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
 
+	struct napi_struct	napi;
+
 	atomic_t		intr_sem;
 
 	struct status_block	*status_blk;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f6e4030..37a19d5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2485,7 +2485,7 @@ static irqreturn_t cas_interruptN(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev);
+		netif_rx_schedule(dev, &cp->napi);
 #else
 		cas_rx_ringN(cp, ring, 0);
 #endif
@@ -2536,7 +2536,7 @@ static irqreturn_t cas_interrupt1(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev);
+		netif_rx_schedule(dev, &cp->napi);
 #else
 		cas_rx_ringN(cp, 1, 0);
 #endif
@@ -2592,7 +2592,7 @@ static irqreturn_t cas_interrupt(int irq, void *dev_id)
 	if (status & INTR_RX_DONE) {
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev);
+		netif_rx_schedule(dev, &cp->napi);
 #else
 		cas_rx_ringN(cp, 0, 0);
 #endif
@@ -2607,9 +2607,10 @@ static irqreturn_t cas_interrupt(int irq, void *dev_id)
 
 
 #ifdef USE_NAPI
-static int cas_poll(struct net_device *dev, int *budget)
+static int cas_poll(struct napi_struct *napi, int budget)
 {
-	struct cas *cp = netdev_priv(dev);
+	struct cas *cp = container_of(napi, struct cas, napi);
+	struct net_device *dev = cp->dev;
 	int i, enable_intr, todo, credits;
 	u32 status = readl(cp->regs + REG_INTR_STATUS);
 	unsigned long flags;
@@ -2620,20 +2621,18 @@ static int cas_poll(struct net_device *dev, int *budget)
 
 	/* NAPI rx packets. we spread the credits across all of the
 	 * rxc rings
-	 */
-	todo = min(*budget, dev->quota);
-
-	/* to make sure we're fair with the work we loop through each
+	 *
+	 * to make sure we're fair with the work we loop through each
 	 * ring N_RX_COMP_RING times with a request of
-	 * todo / N_RX_COMP_RINGS
+	 * budget / N_RX_COMP_RINGS
 	 */
 	enable_intr = 1;
 	credits = 0;
 	for (i = 0; i < N_RX_COMP_RINGS; i++) {
 		int j;
 		for (j = 0; j < N_RX_COMP_RINGS; j++) {
-			credits += cas_rx_ringN(cp, j, todo / N_RX_COMP_RINGS);
-			if (credits >= todo) {
+			credits += cas_rx_ringN(cp, j, budget / N_RX_COMP_RINGS);
+			if (credits >= budget) {
 				enable_intr = 0;
 				goto rx_comp;
 			}
@@ -2641,9 +2640,6 @@ static int cas_poll(struct net_device *dev, int *budget)
 	}
 
 rx_comp:
-	*budget    -= credits;
-	dev->quota -= credits;
-
 	/* final rx completion */
 	spin_lock_irqsave(&cp->lock, flags);
 	if (status)
@@ -2674,11 +2670,10 @@ rx_comp:
 #endif
 	spin_unlock_irqrestore(&cp->lock, flags);
 	if (enable_intr) {
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		cas_unmask_intr(cp);
-		return 0;
 	}
-	return 1;
+	return credits;
 }
 #endif
 
@@ -5062,8 +5057,8 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	dev->watchdog_timeo = CAS_TX_TIMEOUT;
 	dev->change_mtu = cas_change_mtu;
 #ifdef USE_NAPI
-	dev->poll = cas_poll;
-	dev->weight = 64;
+	cp->napi.poll = cas_poll;
+	cp->napi.weight = 64;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = cas_netpoll;
diff --git a/drivers/net/cassini.h b/drivers/net/cassini.h
index a970804..2f93f83 100644
--- a/drivers/net/cassini.h
+++ b/drivers/net/cassini.h
@@ -4280,6 +4280,8 @@ struct cas {
 	int rx_cur[N_RX_COMP_RINGS], rx_new[N_RX_COMP_RINGS];
 	int rx_last[N_RX_DESC_RINGS];
 
+	struct napi_struct napi;
+
 	/* Set when chip is actually in operational state
 	 * (ie. not power managed) */
 	int hw_running;
diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index 8ba702c..b5de445 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -278,6 +278,7 @@ struct adapter {
 	struct peespi *espi;
 	struct petp   *tp;
 
+	struct napi_struct napi;
 	struct port_info port[MAX_NPORTS];
 	struct delayed_work stats_update_task;
 	struct timer_list stats_update_timer;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..fd3beb6 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -274,6 +274,7 @@ static int cxgb_close(struct net_device *dev)
 	struct cmac *mac = p->mac;
 
 	netif_stop_queue(dev);
+	napi_disable(&adapter->napi);
 	mac->ops->disable(mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
 	netif_carrier_off(dev);
 
@@ -1113,8 +1114,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->poll_controller = t1_netpoll;
 #endif
 #ifdef CONFIG_CHELSIO_T1_NAPI
-		netdev->weight = 64;
-		netdev->poll = t1_poll;
+		adapter->napi.weight = 64;
+		adapter->napi.poll = t1_poll;
 #endif
 
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index e4f874a..0e5504d 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1620,23 +1620,20 @@ static int process_pure_responses(struct adapter *adapter)
  * or protection from interrupts as data interrupts are off at this point and
  * other adapter interrupts do not interfere.
  */
-int t1_poll(struct net_device *dev, int *budget)
+int t1_poll(struct napi_struct *napi, int budget)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = container_of(napi, struct adapter, napi); 
+	struct net_device *dev = adapter->port[0].dev;
 	int work_done;
 
-	work_done = process_responses(adapter, min(*budget, dev->quota));
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (unlikely(responses_pending(adapter)))
-		return 1;
-
-	netif_rx_complete(dev);
-	writel(adapter->sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-
-	return 0;
+	work_done = process_responses(adapter, budget);
 
+	if (likely(!responses_pending(adapter))) {
+		netif_rx_complete(dev, napi);
+		writel(adapter->sge->respQ.cidx,
+		       adapter->regs + A_SG_SLEEPING);
+	}
+	return work_done;
 }
 
 /*
@@ -1653,13 +1650,13 @@ irqreturn_t t1_interrupt(int irq, void *data)
 
 		writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
 
-		if (__netif_rx_schedule_prep(dev)) {
+		if (napi_schedule_prep(&adapter->napi)) {
 			if (process_pure_responses(adapter))
-				__netif_rx_schedule(dev);
+				__netif_rx_schedule(dev, &adapter->napi);
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-				netif_poll_enable(dev);	/* undo schedule_prep */
+				napi_enable(&adapter->napi);	/* undo schedule_prep */
 			}
 		}
 		return IRQ_HANDLED;
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
index d132a0e..713d9c5 100644
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -77,7 +77,7 @@ int t1_sge_configure(struct sge *, struct sge_params *);
 int t1_sge_set_coalesce_params(struct sge *, struct sge_params *);
 void t1_sge_destroy(struct sge *);
 irqreturn_t t1_interrupt(int irq, void *cookie);
-int t1_poll(struct net_device *, int *);
+int t1_poll(struct napi_struct *, int);
 
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void t1_set_vlan_accel(struct adapter *adapter, int on_off);
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index ab72563..e723e7b 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -50,7 +50,9 @@ typedef irqreturn_t(*intr_handler_t) (int, void *);
 
 struct vlan_group;
 
+struct adapter;
 struct port_info {
+	struct adapter *adapter;
 	struct vlan_group *vlan_grp;
 	const struct port_type_info *port_type;
 	u8 port_id;
@@ -170,11 +172,13 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_MAX		/* must be last */
 };
 
+struct adapter_napi;
 struct sge_qset {		/* an SGE queue set */
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
-	struct net_device *netdev;	/* associated net device */
+	struct adapter_napi *anapi;
+	struct net_device *netdev;
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
 	unsigned long port_stats[SGE_PSTAT_MAX];
@@ -185,6 +189,13 @@ struct sge {
 	spinlock_t reg_lock;	/* guards non-atomic SGE registers (eg context) */
 };
 
+struct adapter_napi {
+	struct napi_struct napi;
+	struct adapter *adapter;
+	int port;
+	int qset;
+};
+
 struct adapter {
 	struct t3cdev tdev;
 	struct list_head adapter_list;
@@ -219,11 +230,7 @@ struct adapter {
 	struct delayed_work adap_check_task;
 	struct work_struct ext_intr_handler_task;
 
-	/*
-	 * Dummy netdevices are needed when using multiple receive queues with
-	 * NAPI as each netdevice can service only one queue.
-	 */
-	struct net_device *dummy_netdev[SGE_QSETS - 1];
+	struct adapter_napi napi[SGE_QSETS];
 
 	struct dentry *debugfs_root;
 
@@ -251,12 +258,6 @@ static inline struct port_info *adap2pinfo(struct adapter *adap, int idx)
 	return netdev_priv(adap->port[idx]);
 }
 
-/*
- * We use the spare atalk_ptr to map a net device to its SGE queue set.
- * This is a macro so it can be used as l-value.
- */
-#define dev2qset(netdev) ((netdev)->atalk_ptr)
-
 #define OFFLOAD_DEVMAP_BIT 15
 
 #define tdev2adap(d) container_of(d, struct adapter, tdev)
@@ -282,7 +283,8 @@ int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct net_device *netdev);
+		      int ntxq, struct adapter_napi *anapi,
+		      struct net_device *dev);
 int t3_get_desc(const struct sge_qset *qs, unsigned int qnum, unsigned int idx,
 		unsigned char *data);
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd1e52..0b71604 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -339,46 +339,23 @@ static void setup_rss(struct adapter *adap)
 		      V_RRCPLCPUSIZE(6), cpus, rspq_map);
 }
 
-/*
- * If we have multiple receive queues per port serviced by NAPI we need one
- * netdevice per queue as NAPI operates on netdevices.  We already have one
- * netdevice, namely the one associated with the interface, so we use dummy
- * ones for any additional queues.  Note that these netdevices exist purely
- * so that NAPI has something to work with, they do not represent network
- * ports and are not registered.
- */
-static int init_dummy_netdevs(struct adapter *adap)
+static int init_napi(struct adapter *adap)
 {
-	int i, j, dummy_idx = 0;
-	struct net_device *nd;
+	int i, j, napi_idx = 0;
 
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
 		const struct port_info *pi = netdev_priv(dev);
 
 		for (j = 0; j < pi->nqsets - 1; j++) {
-			if (!adap->dummy_netdev[dummy_idx]) {
-				nd = alloc_netdev(0, "", ether_setup);
-				if (!nd)
-					goto free_all;
-
-				nd->priv = adap;
-				nd->weight = 64;
-				set_bit(__LINK_STATE_START, &nd->state);
-				adap->dummy_netdev[dummy_idx] = nd;
-			}
-			strcpy(adap->dummy_netdev[dummy_idx]->name, dev->name);
-			dummy_idx++;
+			adap->napi[napi_idx].napi.weight = 64;
+			adap->napi[napi_idx].adapter = adap;
+			adap->napi[napi_idx].port = i;
+			adap->napi[napi_idx].qset = j;
+			napi_idx++;
 		}
 	}
 	return 0;
-
-free_all:
-	while (--dummy_idx >= 0) {
-		free_netdev(adap->dummy_netdev[dummy_idx]);
-		adap->dummy_netdev[dummy_idx] = NULL;
-	}
-	return -ENOMEM;
 }
 
 /*
@@ -389,19 +366,10 @@ free_all:
 static void quiesce_rx(struct adapter *adap)
 {
 	int i;
-	struct net_device *dev;
 
-	for_each_port(adap, i) {
-		dev = adap->port[i];
-		while (test_bit(__LINK_STATE_RX_SCHED, &dev->state))
-			msleep(1);
-	}
-
-	for (i = 0; i < ARRAY_SIZE(adap->dummy_netdev); i++) {
-		dev = adap->dummy_netdev[i];
-		if (dev)
-			while (test_bit(__LINK_STATE_RX_SCHED, &dev->state))
-				msleep(1);
+	for (i = 0; i < ARRAY_SIZE(adap->napi); i++) {
+		struct adapter_napi *anapi = &adap->napi[i];
+		napi_disable(&anapi->napi);
 	}
 }
 
@@ -415,7 +383,7 @@ static void quiesce_rx(struct adapter *adap)
  */
 static int setup_sge_qsets(struct adapter *adap)
 {
-	int i, j, err, irq_idx = 0, qset_idx = 0, dummy_dev_idx = 0;
+	int i, j, err, irq_idx = 0, qset_idx = 0, anapi_idx = 0;
 	unsigned int ntxq = SGE_TXQ_PER_SET;
 
 	if (adap->params.rev > 0 && !(adap->flags & USING_MSI))
@@ -426,12 +394,15 @@ static int setup_sge_qsets(struct adapter *adap)
 		const struct port_info *pi = netdev_priv(dev);
 
 		for (j = 0; j < pi->nqsets; ++j, ++qset_idx) {
+			struct adapter_napi *anapi;
+
+			anapi = &adap->napi[anapi_idx++];
+
 			err = t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
 							     irq_idx,
 				&adap->params.sge.qset[qset_idx], ntxq,
-				j == 0 ? dev :
-					 adap-> dummy_netdev[dummy_dev_idx++]);
+				anapi, dev);
 			if (err) {
 				t3_free_sge_resources(adap);
 				return err;
@@ -482,7 +453,8 @@ static ssize_t attr_store(struct device *d, struct device_attribute *attr,
 #define CXGB3_SHOW(name, val_expr) \
 static ssize_t format_##name(struct net_device *dev, char *buf) \
 { \
-	struct adapter *adap = dev->priv; \
+	struct port_info *pi = netdev_priv(dev); \
+	struct adapter *adap = pi->adapter; \
 	return sprintf(buf, "%u\n", val_expr); \
 } \
 static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
@@ -493,7 +465,8 @@ static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
 
 static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
 {
-	struct adapter *adap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
 	int min_tids = is_offload(adap) ? MC5_MIN_TIDS : 0;
 
 	if (adap->flags & FULL_INIT_DONE)
@@ -515,7 +488,8 @@ static ssize_t store_nfilters(struct device *d, struct device_attribute *attr,
 
 static ssize_t set_nservers(struct net_device *dev, unsigned int val)
 {
-	struct adapter *adap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
 
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
@@ -556,9 +530,10 @@ static struct attribute_group cxgb3_attr_group = {.attrs = cxgb3_attrs };
 static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
 			    char *buf, int sched)
 {
-	ssize_t len;
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+	struct adapter *adap = pi->adapter;
 	unsigned int v, addr, bpt, cpt;
-	struct adapter *adap = to_net_dev(d)->priv;
+	ssize_t len;
 
 	addr = A_TP_TX_MOD_Q1_Q0_RATE_LIMIT - sched / 2;
 	rtnl_lock();
@@ -581,10 +556,11 @@ static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
 static ssize_t tm_attr_store(struct device *d, struct device_attribute *attr,
 			     const char *buf, size_t len, int sched)
 {
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+	struct adapter *adap = pi->adapter;
+	unsigned int val;
 	char *endp;
 	ssize_t ret;
-	unsigned int val;
-	struct adapter *adap = to_net_dev(d)->priv;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -763,7 +739,7 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
-		err = init_dummy_netdevs(adap);
+		err = init_napi(adap);
 		if (err)
 			goto out;
 
@@ -858,7 +834,8 @@ static void schedule_chk_task(struct adapter *adap)
 
 static int offload_open(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct t3cdev *tdev = T3CDEV(dev);
 	int adap_up = adapter->open_device_map & PORT_MASK;
 	int err = 0;
@@ -924,10 +901,10 @@ static int offload_close(struct t3cdev *tdev)
 
 static int cxgb_open(struct net_device *dev)
 {
-	int err;
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int other_ports = adapter->open_device_map & PORT_MASK;
+	int err;
 
 	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
 		return err;
@@ -951,17 +928,17 @@ static int cxgb_open(struct net_device *dev)
 
 static int cxgb_close(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct port_info *p = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
-	t3_port_intr_disable(adapter, p->port_id);
+	t3_port_intr_disable(adapter, pi->port_id);
 	netif_stop_queue(dev);
-	p->phy.ops->power_down(&p->phy, 1);
+	pi->phy.ops->power_down(&pi->phy, 1);
 	netif_carrier_off(dev);
-	t3_mac_disable(&p->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
+	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
 
 	spin_lock(&adapter->work_lock);	/* sync with update task */
-	clear_bit(p->port_id, &adapter->open_device_map);
+	clear_bit(pi->port_id, &adapter->open_device_map);
 	spin_unlock(&adapter->work_lock);
 
 	if (!(adapter->open_device_map & PORT_MASK))
@@ -976,13 +953,13 @@ static int cxgb_close(struct net_device *dev)
 
 static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct port_info *p = netdev_priv(dev);
-	struct net_device_stats *ns = &p->netstats;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	struct net_device_stats *ns = &pi->netstats;
 	const struct mac_stats *pstats;
 
 	spin_lock(&adapter->stats_lock);
-	pstats = t3_mac_update_stats(&p->mac);
+	pstats = t3_mac_update_stats(&pi->mac);
 	spin_unlock(&adapter->stats_lock);
 
 	ns->tx_bytes = pstats->tx_octets;
@@ -1015,14 +992,16 @@ static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 
 static u32 get_msglevel(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	return adapter->msg_enable;
 }
 
 static void set_msglevel(struct net_device *dev, u32 val)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	adapter->msg_enable = val;
 }
@@ -1096,8 +1075,9 @@ static int get_eeprom_len(struct net_device *dev)
 
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	u32 fw_vers = 0;
-	struct adapter *adapter = dev->priv;
 
 	t3_get_fw_version(adapter, &fw_vers);
 
@@ -1136,8 +1116,8 @@ static unsigned long collect_sge_port_stats(struct adapter *adapter,
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct mac_stats *s;
 
 	spin_lock(&adapter->stats_lock);
@@ -1205,7 +1185,8 @@ static inline void reg_block_dump(struct adapter *ap, void *buf,
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		     void *buf)
 {
-	struct adapter *ap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *ap = pi->adapter;
 
 	/*
 	 * Version scheme:
@@ -1246,8 +1227,9 @@ static int restart_autoneg(struct net_device *dev)
 
 static int cxgb3_phys_id(struct net_device *dev, u32 data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i;
-	struct adapter *adapter = dev->priv;
 
 	if (data == 0)
 		data = 2;
@@ -1408,8 +1390,8 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	const struct adapter *adapter = dev->priv;
-	const struct port_info *pi = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
@@ -1425,10 +1407,10 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	int i;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *q;
-	struct adapter *adapter = dev->priv;
-	const struct port_info *pi = netdev_priv(dev);
+	int i;
 
 	if (e->rx_pending > MAX_RX_BUFFERS ||
 	    e->rx_jumbo_pending > MAX_RX_JUMBO_BUFFERS ||
@@ -1457,7 +1439,8 @@ static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *qsp = &adapter->params.sge.qset[0];
 	struct sge_qset *qs = &adapter->sge.qs[0];
 
@@ -1471,7 +1454,8 @@ static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 
 static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *q = adapter->params.sge.qset;
 
 	c->rx_coalesce_usecs = q->coalesce_usecs;
@@ -1481,8 +1465,9 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 		      u8 * data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i, err = 0;
-	struct adapter *adapter = dev->priv;
 
 	u8 *buf = kmalloc(EEPROMSIZE, GFP_KERNEL);
 	if (!buf)
@@ -1501,10 +1486,11 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		      u8 * data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	u32 aligned_offset, aligned_len, *p;
 	u8 *buf;
 	int err = 0;
-	u32 aligned_offset, aligned_len, *p;
-	struct adapter *adapter = dev->priv;
 
 	if (eeprom->magic != EEPROM_MAGIC)
 		return -EINVAL;
@@ -1593,9 +1579,10 @@ static int in_range(int val, int lo, int hi)
 
 static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 {
-	int ret;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	u32 cmd;
-	struct adapter *adapter = dev->priv;
+	int ret;
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
@@ -1924,10 +1911,10 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 
 static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	int ret, mmd;
-	struct adapter *adapter = dev->priv;
-	struct port_info *pi = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(req);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	int ret, mmd;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -1995,9 +1982,9 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int ret;
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	int ret;
 
 	if (new_mtu < 81)	/* accommodate SACK */
 		return -EINVAL;
@@ -2014,8 +2001,8 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -2051,8 +2038,8 @@ static void t3_synchronize_rx(struct adapter *adap, const struct port_info *p)
 
 static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	pi->vlan_grp = grp;
 	if (adapter->params.rev > 0)
@@ -2071,8 +2058,8 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cxgb_netpoll(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int qidx;
 
 	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
@@ -2434,6 +2421,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		adapter->port[i] = netdev;
 		pi = netdev_priv(netdev);
+		pi->adapter = adapter;
 		pi->rx_csum_offload = 1;
 		pi->nqsets = 1;
 		pi->first_qset = i;
@@ -2443,7 +2431,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->irq = pdev->irq;
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
-		netdev->priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 		netdev->features |= NETIF_F_LLTX;
 		if (pci_using_dac)
@@ -2463,12 +2450,11 @@ static int __devinit init_one(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = cxgb_netpoll;
 #endif
-		netdev->weight = 64;
 
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
 
-	pci_set_drvdata(pdev, adapter->port[0]);
+	pci_set_drvdata(pdev, adapter);
 	if (t3_prep_adapter(adapter, ai, 1) < 0) {
 		err = -ENODEV;
 		goto out_free_dev;
@@ -2548,11 +2534,10 @@ out_release_regions:
 
 static void __devexit remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct adapter *adapter = pci_get_drvdata(pdev);
 
-	if (dev) {
+	if (adapter) {
 		int i;
-		struct adapter *adapter = dev->priv;
 
 		t3_sge_stop(adapter);
 		sysfs_remove_group(&adapter->port[0]->dev.kobj,
@@ -2572,12 +2557,6 @@ static void __devexit remove_one(struct pci_dev *pdev)
 		t3_free_sge_resources(adapter);
 		cxgb_disable_msi(adapter);
 
-		for (i = 0; i < ARRAY_SIZE(adapter->dummy_netdev); i++)
-			if (adapter->dummy_netdev[i]) {
-				free_netdev(adapter->dummy_netdev[i]);
-				adapter->dummy_netdev[i] = NULL;
-			}
-
 		for_each_port(adapter, i)
 			if (adapter->port[i])
 				free_netdev(adapter->port[i]);
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index a2cfd68..09f231c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -591,9 +591,6 @@ void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 				  q->rspq.desc, q->rspq.phys_addr);
 	}
 
-	if (q->netdev)
-		q->netdev->atalk_ptr = NULL;
-
 	memset(q, 0, sizeof(*q));
 }
 
@@ -1073,8 +1070,8 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int ndesc, pidx, credits, gen, compl;
 	const struct port_info *pi = netdev_priv(dev);
-	struct adapter *adap = dev->priv;
-	struct sge_qset *qs = dev2qset(dev);
+	struct adapter *adap = pi->adapter;
+	struct sge_qset *qs = &adap->sge.qs[pi->first_qset];
 	struct sge_txq *q = &qs->txq[TXQ_ETH];
 
 	/*
@@ -1326,7 +1323,7 @@ static void restart_ctrlq(unsigned long data)
 	struct sk_buff *skb;
 	struct sge_qset *qs = (struct sge_qset *)data;
 	struct sge_txq *q = &qs->txq[TXQ_CTRL];
-	struct adapter *adap = qs->netdev->priv;
+	struct adapter *adap = qs->anapi->adapter;
 
 	spin_lock(&q->lock);
       again:reclaim_completed_tx_imm(q);
@@ -1531,7 +1528,7 @@ static void restart_offloadq(unsigned long data)
 	struct sk_buff *skb;
 	struct sge_qset *qs = (struct sge_qset *)data;
 	struct sge_txq *q = &qs->txq[TXQ_OFLD];
-	struct adapter *adap = qs->netdev->priv;
+	struct adapter *adap = qs->anapi->adapter;
 
 	spin_lock(&q->lock);
       again:reclaim_completed_tx(adap, q);
@@ -1636,8 +1633,8 @@ static inline void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
 	else {
 		struct sge_qset *qs = rspq_to_qset(q);
 
-		if (__netif_rx_schedule_prep(qs->netdev))
-			__netif_rx_schedule(qs->netdev);
+		if (napi_schedule_prep(&qs->anapi->napi))
+			__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
 		q->rx_head = skb;
 	}
 	q->rx_tail = skb;
@@ -1673,33 +1670,32 @@ static inline void deliver_partial_bundle(struct t3cdev *tdev,
  *	receive handler.  Batches need to be of modest size as we do prefetches
  *	on the packets in each.
  */
-static int ofld_poll(struct net_device *dev, int *budget)
+static int ofld_poll(struct napi_struct *napi, int budget)
 {
-	struct adapter *adapter = dev->priv;
-	struct sge_qset *qs = dev2qset(dev);
+	struct adapter_napi *anapi = container_of(napi, struct adapter_napi, napi);
+	struct adapter *adapter = anapi->adapter;
+	struct net_device *dev = adapter->port[anapi->port];
+	struct sge_qset *qs = &adapter->sge.qs[anapi->qset];
 	struct sge_rspq *q = &qs->rspq;
-	int work_done, limit = min(*budget, dev->quota), avail = limit;
+	int work_done = 0;
 
-	while (avail) {
+	while (work_done < budget) {
 		struct sk_buff *head, *tail, *skbs[RX_BUNDLE_SIZE];
 		int ngathered;
 
 		spin_lock_irq(&q->lock);
 		head = q->rx_head;
 		if (!head) {
-			work_done = limit - avail;
-			*budget -= work_done;
-			dev->quota -= work_done;
-			__netif_rx_complete(dev);
+			__netif_rx_complete(dev, napi);
 			spin_unlock_irq(&q->lock);
-			return 0;
+			return work_done;
 		}
 
 		tail = q->rx_tail;
 		q->rx_head = q->rx_tail = NULL;
 		spin_unlock_irq(&q->lock);
 
-		for (ngathered = 0; avail && head; avail--) {
+		for (ngathered = 0; work_done < budget && head; work_done++) {
 			prefetch(head->data);
 			skbs[ngathered] = head;
 			head = head->next;
@@ -1721,10 +1717,8 @@ static int ofld_poll(struct net_device *dev, int *budget)
 		}
 		deliver_partial_bundle(&adapter->tdev, q, skbs, ngathered);
 	}
-	work_done = limit - avail;
-	*budget -= work_done;
-	dev->quota -= work_done;
-	return 1;
+
+	return work_done;
 }
 
 /**
@@ -2073,44 +2067,45 @@ static inline int is_pure_response(const struct rsp_desc *r)
  *
  *	Handler for new data events when using NAPI.
  */
-static int napi_rx_handler(struct net_device *dev, int *budget)
+static int napi_rx_handler(struct napi_struct *napi, int budget)
 {
-	struct adapter *adap = dev->priv;
-	struct sge_qset *qs = dev2qset(dev);
-	int effective_budget = min(*budget, dev->quota);
-
+	struct adapter_napi *anapi = container_of(napi, struct adapter_napi, napi);
+	struct adapter *adap = anapi->adapter;
+	struct net_device *dev = adap->port[anapi->port];
+	struct sge_qset *qs = &adap->sge.qs[anapi->qset];
+	int effective_budget = budget;
 	int work_done = process_responses(adap, qs, effective_budget);
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done >= effective_budget)
-		return 1;
 
-	netif_rx_complete(dev);
+	if (likely(work_done < effective_budget)) {
+		netif_rx_complete(dev, napi);
 
-	/*
-	 * Because we don't atomically flush the following write it is
-	 * possible that in very rare cases it can reach the device in a way
-	 * that races with a new response being written plus an error interrupt
-	 * causing the NAPI interrupt handler below to return unhandled status
-	 * to the OS.  To protect against this would require flushing the write
-	 * and doing both the write and the flush with interrupts off.  Way too
-	 * expensive and unjustifiable given the rarity of the race.
-	 *
-	 * The race cannot happen at all with MSI-X.
-	 */
-	t3_write_reg(adap, A_SG_GTS, V_RSPQ(qs->rspq.cntxt_id) |
-		     V_NEWTIMER(qs->rspq.next_holdoff) |
-		     V_NEWINDEX(qs->rspq.cidx));
-	return 0;
+		/*
+		 * Because we don't atomically flush the following
+		 * write it is possible that in very rare cases it can
+		 * reach the device in a way that races with a new
+		 * response being written plus an error interrupt
+		 * causing the NAPI interrupt handler below to return
+		 * unhandled status to the OS.  To protect against
+		 * this would require flushing the write and doing
+		 * both the write and the flush with interrupts off.
+		 * Way too expensive and unjustifiable given the
+		 * rarity of the race.
+		 *
+		 * The race cannot happen at all with MSI-X.
+		 */
+		t3_write_reg(adap, A_SG_GTS, V_RSPQ(qs->rspq.cntxt_id) |
+			     V_NEWTIMER(qs->rspq.next_holdoff) |
+			     V_NEWINDEX(qs->rspq.cidx));
+	}
+	return work_done;
 }
 
 /*
  * Returns true if the device is already scheduled for polling.
  */
-static inline int napi_is_scheduled(struct net_device *dev)
+static inline int napi_is_scheduled(struct napi_struct *napi)
 {
-	return test_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	return test_bit(NAPI_STATE_SCHED, &napi->state);
 }
 
 /**
@@ -2193,8 +2188,8 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 			     V_NEWTIMER(q->holdoff_tmr) | V_NEWINDEX(q->cidx));
 		return 0;
 	}
-	if (likely(__netif_rx_schedule_prep(qs->netdev)))
-		__netif_rx_schedule(qs->netdev);
+	if (likely(napi_schedule_prep(&qs->anapi->napi)))
+		__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
 	return 1;
 }
 
@@ -2205,7 +2200,7 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->netdev->priv;
+	struct adapter *adap = qs->anapi->adapter;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
@@ -2224,7 +2219,7 @@ irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->netdev->priv;
+	struct adapter *adap = qs->anapi->adapter;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
@@ -2272,11 +2267,14 @@ static irqreturn_t t3_intr_msi(int irq, void *cookie)
 	return IRQ_HANDLED;
 }
 
-static int rspq_check_napi(struct net_device *dev, struct sge_rspq *q)
+static int rspq_check_napi(struct sge_qset *qs)
 {
-	if (!napi_is_scheduled(dev) && is_new_response(&q->desc[q->cidx], q)) {
-		if (likely(__netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
+	struct sge_rspq *q = &qs->rspq;
+
+	if (!napi_is_scheduled(&qs->anapi->napi) &&
+	    is_new_response(&q->desc[q->cidx], q)) {
+		if (likely(napi_schedule_prep(&qs->anapi->napi)))
+			__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
 		return 1;
 	}
 	return 0;
@@ -2297,10 +2295,9 @@ irqreturn_t t3_intr_msi_napi(int irq, void *cookie)
 
 	spin_lock(&q->lock);
 
-	new_packets = rspq_check_napi(adap->sge.qs[0].netdev, q);
+	new_packets = rspq_check_napi(&adap->sge.qs[0]);
 	if (adap->params.nports == 2)
-		new_packets += rspq_check_napi(adap->sge.qs[1].netdev,
-					       &adap->sge.qs[1].rspq);
+		new_packets += rspq_check_napi(&adap->sge.qs[1]);
 	if (!new_packets && t3_slow_intr_handler(adap) == 0)
 		q->unhandled_irqs++;
 
@@ -2405,7 +2402,8 @@ static irqreturn_t t3b_intr_napi(int irq, void *cookie)
 	u32 map;
 	struct net_device *dev;
 	struct adapter *adap = cookie;
-	struct sge_rspq *q0 = &adap->sge.qs[0].rspq;
+	struct sge_qset *qs0 = &adap->sge.qs[0];
+	struct sge_rspq *q0 = &qs0->rspq;
 
 	t3_write_reg(adap, A_PL_CLI, 0);
 	map = t3_read_reg(adap, A_SG_DATA_INTR);
@@ -2419,16 +2417,17 @@ static irqreturn_t t3b_intr_napi(int irq, void *cookie)
 		t3_slow_intr_handler(adap);
 
 	if (likely(map & 1)) {
-		dev = adap->sge.qs[0].netdev;
+		dev = qs0->netdev;
 
-		if (likely(__netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
+		if (likely(napi_schedule_prep(&qs0->anapi->napi)))
+			__netif_rx_schedule(dev, &qs0->anapi->napi);
 	}
 	if (map & 2) {
-		dev = adap->sge.qs[1].netdev;
+		struct sge_qset *qs1 = &adap->sge.qs[1];
 
-		if (likely(__netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
+		dev = qs1->netdev;
+		if (likely(napi_schedule_prep(&qs1->anapi->napi)))
+			__netif_rx_schedule(dev, &qs1->anapi->napi);
 	}
 
 	spin_unlock(&q0->lock);
@@ -2508,7 +2507,7 @@ static void sge_timer_cb(unsigned long data)
 {
 	spinlock_t *lock;
 	struct sge_qset *qs = (struct sge_qset *)data;
-	struct adapter *adap = qs->netdev->priv;
+	struct adapter *adap = qs->anapi->adapter;
 
 	if (spin_trylock(&qs->txq[TXQ_ETH].lock)) {
 		reclaim_completed_tx(adap, &qs->txq[TXQ_ETH]);
@@ -2521,7 +2520,7 @@ static void sge_timer_cb(unsigned long data)
 	lock = (adap->flags & USING_MSIX) ? &qs->rspq.lock :
 	    &adap->sge.qs[0].rspq.lock;
 	if (spin_trylock_irq(lock)) {
-		if (!napi_is_scheduled(qs->netdev)) {
+		if (!napi_is_scheduled(&qs->anapi->napi)) {
 			u32 status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
 
 			if (qs->fl[0].credits < qs->fl[0].size)
@@ -2555,12 +2554,9 @@ static void sge_timer_cb(unsigned long data)
  */
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
 {
-	if (!qs->netdev)
-		return;
-
 	qs->rspq.holdoff_tmr = max(p->coalesce_usecs * 10, 1U);/* can't be 0 */
 	qs->rspq.polling = p->polling;
-	qs->netdev->poll = p->polling ? napi_rx_handler : ofld_poll;
+	qs->anapi->napi.poll = p->polling ? napi_rx_handler : ofld_poll;
 }
 
 /**
@@ -2580,7 +2576,8 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
  */
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct net_device *netdev)
+		      int ntxq, struct adapter_napi *anapi,
+		      struct net_device *dev)
 {
 	int i, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
@@ -2701,17 +2698,10 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	}
 
 	spin_unlock(&adapter->sge.reg_lock);
-	q->netdev = netdev;
+	q->anapi = anapi;
+	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
 
-	/*
-	 * We use atalk_ptr as a backpointer to a qset.  In case a device is
-	 * associated with multiple queue sets only the first one sets
-	 * atalk_ptr.
-	 */
-	if (netdev->atalk_ptr == NULL)
-		netdev->atalk_ptr = q;
-
 	refill_fl(adapter, &q->fl[0], q->fl[0].size, GFP_KERNEL);
 	refill_fl(adapter, &q->fl[1], q->fl[1].size, GFP_KERNEL);
 	refill_rspq(adapter, &q->rspq, q->rspq.size - 1);
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 6b6401e..8ca2e4d 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -539,6 +539,7 @@ struct nic {
 	struct csr __iomem *csr;
 	enum scb_cmd_lo cuc_cmd;
 	unsigned int cbs_avail;
+	struct napi_struct napi;
 	struct cb *cbs;
 	struct cb *cb_to_use;
 	struct cb *cb_to_send;
@@ -1974,35 +1975,31 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	if(stat_ack & stat_ack_rnr)
 		nic->ru_running = RU_SUSPENDED;
 
-	if(likely(netif_rx_schedule_prep(netdev))) {
+	if(likely(netif_rx_schedule_prep(netdev, &nic->napi))) {
 		e100_disable_irq(nic);
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &nic->napi);
 	}
 
 	return IRQ_HANDLED;
 }
 
-static int e100_poll(struct net_device *netdev, int *budget)
+static int e100_poll(struct napi_struct *napi, int budget)
 {
-	struct nic *nic = netdev_priv(netdev);
-	unsigned int work_to_do = min(netdev->quota, *budget);
-	unsigned int work_done = 0;
+	struct nic *nic = container_of(napi, struct nic, napi);
+	struct net_device *netdev = nic->netdev;
+	int work_done = 0;
 	int tx_cleaned;
 
-	e100_rx_clean(nic, &work_done, work_to_do);
+	e100_rx_clean(nic, &work_done, budget);
 	tx_cleaned = e100_tx_clean(nic);
 
 	/* If no Rx and Tx cleanup work was done, exit polling mode. */
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
-		netif_rx_complete(netdev);
+		netif_rx_complete(netdev, napi);
 		e100_enable_irq(nic);
-		return 0;
 	}
 
-	*budget -= work_done;
-	netdev->quota -= work_done;
-
-	return 1;
+	return work_done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2071,7 +2068,7 @@ static int e100_up(struct nic *nic)
 		nic->netdev->name, nic->netdev)))
 		goto err_no_irq;
 	netif_wake_queue(nic->netdev);
-	netif_poll_enable(nic->netdev);
+	napi_enable(&nic->napi);
 	/* enable ints _after_ enabling poll, preventing a race between
 	 * disable ints+schedule */
 	e100_enable_irq(nic);
@@ -2089,7 +2086,7 @@ err_rx_clean_list:
 static void e100_down(struct nic *nic)
 {
 	/* wait here for poll to complete */
-	netif_poll_disable(nic->netdev);
+	napi_disable(&nic->napi);
 	netif_stop_queue(nic->netdev);
 	e100_hw_reset(nic);
 	free_irq(nic->pdev->irq, nic->netdev);
@@ -2573,14 +2570,14 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->tx_timeout = e100_tx_timeout;
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-	netdev->poll = e100_poll;
-	netdev->weight = E100_NAPI_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	nic = netdev_priv(netdev);
+	nic->napi.poll = e100_poll;
+	nic->napi.weight = E100_NAPI_WEIGHT;
 	nic->netdev = netdev;
 	nic->pdev = pdev;
 	nic->msg_enable = (1 << debug) - 1;
@@ -2734,7 +2731,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct nic *nic = netdev_priv(netdev);
 
 	if (netif_running(netdev))
-		netif_poll_disable(nic->netdev);
+		napi_disable(&nic->napi);
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 	netif_device_detach(netdev);
@@ -2780,7 +2777,7 @@ static void e100_shutdown(struct pci_dev *pdev)
 	struct nic *nic = netdev_priv(netdev);
 
 	if (netif_running(netdev))
-		netif_poll_disable(nic->netdev);
+		napi_disable(&nic->napi);
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 
@@ -2805,12 +2802,13 @@ static void e100_shutdown(struct pci_dev *pdev)
 static pci_ers_result_t e100_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
 
 	/* Similar to calling e100_down(), but avoids adpater I/O. */
 	netdev->stop(netdev);
 
 	/* Detach; put netif into state similar to hotplug unplug. */
-	netif_poll_enable(netdev);
+	napi_enable(&nic->napi);
 	netif_device_detach(netdev);
 	pci_disable_device(pdev);
 
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 16a6edf..781ed99 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -300,6 +300,7 @@ struct e1000_adapter {
 				int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
 #ifdef CONFIG_E1000_NAPI
+	struct napi_struct napi;
 	struct net_device *polling_netdev;  /* One per active queue */
 #endif
 	int num_tx_queues;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f48b659..9234657 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -162,7 +162,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
-static int e1000_clean(struct net_device *poll_dev, int *budget);
+static int e1000_clean(struct napi_struct *napi, int budget);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
                                     struct e1000_rx_ring *rx_ring,
                                     int *work_done, int work_to_do);
@@ -541,7 +541,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(adapter->netdev);
+	napi_enable(&adapter->napi);
 #endif
 	e1000_irq_enable(adapter);
 
@@ -630,7 +630,7 @@ e1000_down(struct e1000_adapter *adapter)
 	set_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 #endif
 	e1000_irq_disable(adapter);
 
@@ -932,8 +932,8 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_E1000_NAPI
-	netdev->poll = &e1000_clean;
-	netdev->weight = 64;
+	adapter->napi.poll = &e1000_clean;
+	adapter->napi.weight = 64;
 #endif
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
@@ -1146,7 +1146,7 @@ e1000_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 #endif
 
 	strcpy(netdev->name, "eth%d");
@@ -1319,8 +1319,6 @@ e1000_sw_init(struct e1000_adapter *adapter)
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		adapter->polling_netdev[i].priv = adapter;
-		adapter->polling_netdev[i].poll = &e1000_clean;
-		adapter->polling_netdev[i].weight = 64;
 		dev_hold(&adapter->polling_netdev[i]);
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
@@ -1437,7 +1435,7 @@ e1000_open(struct net_device *netdev)
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 #endif
 
 	e1000_irq_enable(adapter);
@@ -1476,6 +1474,10 @@ e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_E1000_NAPI
+	napi_disable(&adapter->napi);
+#endif
+
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
 	e1000_power_down_phy(adapter);
@@ -3780,12 +3782,12 @@ e1000_intr_msi(int irq, void *data)
 	}
 
 #ifdef CONFIG_E1000_NAPI
-	if (likely(netif_rx_schedule_prep(netdev))) {
+	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
 #else
@@ -3865,12 +3867,12 @@ e1000_intr(int irq, void *data)
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
-	if (likely(netif_rx_schedule_prep(netdev))) {
+	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
@@ -3918,10 +3920,10 @@ e1000_intr(int irq, void *data)
  **/
 
 static int
-e1000_clean(struct net_device *poll_dev, int *budget)
+e1000_clean(struct napi_struct *napi, int budget)
 {
-	struct e1000_adapter *adapter;
-	int work_to_do = min(*budget, poll_dev->quota);
+	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
+	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
@@ -3942,23 +3944,19 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	}
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, work_to_do);
-
-	*budget -= work_done;
-	poll_dev->quota -= work_done;
+	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev);
+		netif_rx_complete(poll_dev, napi);
 		e1000_irq_enable(adapter);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 #endif
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 489c8b2..5b5b0b8 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -351,6 +351,7 @@ struct ehea_q_skb_arr {
  * Port resources
  */
 struct ehea_port_res {
+	struct napi_struct napi;
 	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
@@ -362,7 +363,6 @@ struct ehea_port_res {
 	struct ehea_cq *send_cq;
 	struct ehea_cq *recv_cq;
 	struct ehea_eq *eq;
-	struct net_device *d_netdev;
 	struct ehea_q_skb_arr rq1_skba;
 	struct ehea_q_skb_arr rq2_skba;
 	struct ehea_q_skb_arr rq3_skba;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4c70a93..8a516f9 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -389,9 +389,9 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	return 0;
 }
 
-static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
-					struct ehea_port_res *pr,
-					int *budget)
+static int ehea_proc_rwqes(struct net_device *dev,
+			   struct ehea_port_res *pr,
+			   int budget)
 {
 	struct ehea_port *port = pr->port;
 	struct ehea_qp *qp = pr->qp;
@@ -404,18 +404,16 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 	int skb_arr_rq2_len = pr->rq2_skba.len;
 	int skb_arr_rq3_len = pr->rq3_skba.len;
 	int processed, processed_rq1, processed_rq2, processed_rq3;
-	int wqe_index, last_wqe_index, rq, my_quota, port_reset;
+	int wqe_index, last_wqe_index, rq, port_reset;
 
 	processed = processed_rq1 = processed_rq2 = processed_rq3 = 0;
 	last_wqe_index = 0;
-	my_quota = min(*budget, dev->quota);
 
 	cqe = ehea_poll_rq1(qp, &wqe_index);
-	while ((my_quota > 0) && cqe) {
+	while ((processed < budget) && cqe) {
 		ehea_inc_rq1(qp);
 		processed_rq1++;
 		processed++;
-		my_quota--;
 		if (netif_msg_rx_status(port))
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 
@@ -430,14 +428,14 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 					if (netif_msg_rx_err(port))
 						ehea_error("LL rq1: skb=NULL");
 
-					skb = netdev_alloc_skb(port->netdev,
+					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
 					if (!skb)
 						break;
 				}
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
@@ -446,7 +444,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 						ehea_error("rq2: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 				processed_rq2++;
 			} else {  /* RQ3 */
 				skb = get_skb_by_index(skb_arr_rq3,
@@ -456,7 +454,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 						ehea_error("rq3: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 				processed_rq3++;
 			}
 
@@ -480,14 +478,14 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 	}
 
 	pr->rx_packets += processed;
-	*budget -= processed;
 
 	ehea_refill_rq1(pr, last_wqe_index, processed_rq1);
 	ehea_refill_rq2(pr, processed_rq2);
 	ehea_refill_rq3(pr, processed_rq3);
 
-	cqe = ehea_poll_rq1(qp, &wqe_index);
-	return cqe;
+	(void) ehea_poll_rq1(qp, &wqe_index);
+
+	return processed;
 }
 
 static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
@@ -551,12 +549,13 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 
 #define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
 
-static int ehea_poll(struct net_device *dev, int *budget)
+static int ehea_poll(struct napi_struct *napi, int budget)
 {
-	struct ehea_port_res *pr = dev->priv;
+	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res, napi);
+	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
-	int force_irq, wqe_index;
+	int force_irq, wqe_index, rx;
 
 	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 	cqe_skb = ehea_poll_cq(pr->send_cq);
@@ -565,7 +564,6 @@ static int ehea_poll(struct net_device *dev, int *budget)
 
 	if ((!cqe && !cqe_skb) || force_irq) {
 		pr->poll_counter = 0;
-		netif_rx_complete(dev);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
@@ -573,27 +571,26 @@ static int ehea_poll(struct net_device *dev, int *budget)
 		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 		cqe_skb = ehea_poll_cq(pr->send_cq);
 
-		if (!cqe && !cqe_skb)
-			return 0;
-
-		if (!netif_rx_reschedule(dev, dev->quota))
+		if (!cqe && !cqe_skb) {
+			netif_rx_complete(dev, napi);
 			return 0;
+		}
 	}
 
-	cqe = ehea_proc_rwqes(dev, pr, budget);
+	rx = ehea_proc_rwqes(dev, pr, budget);
 	cqe_skb = ehea_proc_cqes(pr, 300);
 
-	if (cqe || cqe_skb)
+	if (rx || cqe_skb)
 		pr->poll_counter++;
 
-	return 1;
+	return rx;
 }
 
 static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
 
-	netif_rx_schedule(pr->d_netdev);
+	netif_rx_schedule(pr->port->netdev, &pr->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1207,14 +1204,8 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 
 	kfree(init_attr);
 
-	pr->d_netdev = alloc_netdev(0, "", ether_setup);
-	if (!pr->d_netdev)
-		goto out_free;
-	pr->d_netdev->priv = pr;
-	pr->d_netdev->weight = 64;
-	pr->d_netdev->poll = ehea_poll;
-	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
-	strcpy(pr->d_netdev->name, port->netdev->name);
+	pr->napi.weight = 64;
+	pr->napi.poll = ehea_poll;
 
 	ret = 0;
 	goto out;
@@ -1237,8 +1228,6 @@ static int ehea_clean_portres(struct ehea_port *port, struct ehea_port_res *pr)
 {
 	int ret, i;
 
-	free_netdev(pr->d_netdev);
-
 	ret = ehea_destroy_qp(pr->qp);
 
 	if (!ret) {
@@ -2261,9 +2250,7 @@ static int ehea_down(struct net_device *dev)
 	ehea_free_interrupts(dev);
 
 	for (i = 0; i < port->num_def_qps; i++)
-		while (test_bit(__LINK_STATE_RX_SCHED,
-				&port->port_res[i].d_netdev->state))
-			msleep(1);
+		napi_disable(&port->port_res[i].napi);
 
 	port->state = EHEA_PORT_DOWN;
 
@@ -2626,8 +2613,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
-	dev->poll = ehea_poll;
-	dev->weight = 64;
 	dev->stop = ehea_stop;
 	dev->hard_start_xmit = ehea_start_xmit;
 	dev->get_stats = ehea_get_stats;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1197784..51fa494 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -262,6 +262,7 @@ struct epic_private {
 	/* Ring pointers. */
 	spinlock_t lock;				/* Group with Tx control cache line. */
 	spinlock_t napi_lock;
+	struct napi_struct napi;
 	unsigned int reschedule_in_poll;
 	unsigned int cur_tx, dirty_tx;
 
@@ -294,7 +295,7 @@ static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int epic_rx(struct net_device *dev, int budget);
-static int epic_poll(struct net_device *dev, int *budget);
+static int epic_poll(struct napi_struct *napi, int budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -487,8 +488,8 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
-	dev->poll = epic_poll;
-	dev->weight = 64;
+	ep->napi.poll = epic_poll;
+	ep->napi.weight = 64;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -1103,9 +1104,9 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
 		spin_lock(&ep->napi_lock);
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &ep->napi)) {
 			epic_napi_irq_off(dev, ep);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &ep->napi);
 		} else
 			ep->reschedule_in_poll++;
 		spin_unlock(&ep->napi_lock);
@@ -1257,26 +1258,22 @@ static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
 		outw(RxQueued, ioaddr + COMMAND);
 }
 
-static int epic_poll(struct net_device *dev, int *budget)
+static int epic_poll(struct napi_struct *napi, int budget)
 {
-	struct epic_private *ep = dev->priv;
-	int work_done = 0, orig_budget;
+	struct epic_private *ep = container_of(napi, struct epic_private, napi);
+	struct net_device *dev = ep->mii.dev;
+	int work_done = 0;
 	long ioaddr = dev->base_addr;
 
-	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
-
 rx_action:
 
 	epic_tx(dev, ep);
 
-	work_done += epic_rx(dev, *budget);
+	work_done += epic_rx(dev, budget);
 
 	epic_rx_err(dev, ep);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (netif_running(dev) && (work_done < orig_budget)) {
+	if (netif_running(dev) && (work_done < budget)) {
 		unsigned long flags;
 		int more;
 
@@ -1286,7 +1283,7 @@ rx_action:
 
 		more = ep->reschedule_in_poll;
 		if (!more) {
-			__netif_rx_complete(dev);
+			__netif_rx_complete(dev, napi);
 			outl(EpicNapiEvent, ioaddr + INTSTAT);
 			epic_napi_irq_on(dev, ep);
 		} else
@@ -1298,7 +1295,7 @@ rx_action:
 			goto rx_action;
 	}
 
-	return (work_done >= orig_budget);
+	return work_done;
 }
 
 static int epic_close(struct net_device *dev)
@@ -1309,6 +1306,7 @@ static int epic_close(struct net_device *dev)
 	int i;
 
 	netif_stop_queue(dev);
+	napi_disable(&ep->napi);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
diff --git a/drivers/net/fec_8xx/fec_8xx.h b/drivers/net/fec_8xx/fec_8xx.h
index 5af60b0..f3b1c6f 100644
--- a/drivers/net/fec_8xx/fec_8xx.h
+++ b/drivers/net/fec_8xx/fec_8xx.h
@@ -105,6 +105,8 @@ struct fec;
 struct fec_enet_private {
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fec_start_xmit and fec_tx         */
+	struct net_device *dev;
+	struct napi_struct napi;
 	int fecno;
 	struct fec *fecp;
 	const struct fec_platform_info *fpi;
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index e5502af..1af588d 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -465,9 +465,9 @@ void fec_stop(struct net_device *dev)
 }
 
 /* common receive function */
-static int fec_enet_rx_common(struct net_device *dev, int *budget)
+static int fec_enet_rx_common(struct fec_enet_private *ep,
+			      struct net_device *dev, int budget)
 {
-	struct fec_enet_private *fep = netdev_priv(dev);
 	fec_t *fecp = fep->fecp;
 	const struct fec_platform_info *fpi = fep->fpi;
 	cbd_t *bdp;
@@ -475,11 +475,8 @@ static int fec_enet_rx_common(struct net_device *dev, int *budget)
 	int received = 0;
 	__u16 pkt_len, sc;
 	int curidx;
-	int rx_work_limit;
 
 	if (fpi->use_napi) {
-		rx_work_limit = min(dev->quota, *budget);
-
 		if (!netif_running(dev))
 			return 0;
 	}
@@ -530,11 +527,6 @@ static int fec_enet_rx_common(struct net_device *dev, int *budget)
 			BUG_ON(skbn == NULL);
 
 		} else {
-
-			/* napi, got packet but no quota */
-			if (fpi->use_napi && --rx_work_limit < 0)
-				break;
-
 			skb = fep->rx_skbuff[curidx];
 			BUG_ON(skb == NULL);
 
@@ -599,25 +591,24 @@ static int fec_enet_rx_common(struct net_device *dev, int *budget)
 		 * able to keep up at the expense of system resources.
 		 */
 		FW(fecp, r_des_active, 0x01000000);
+
+		if (received >= budget)
+			break;
+
 	}
 
 	fep->cur_rx = bdp;
 
 	if (fpi->use_napi) {
-		dev->quota -= received;
-		*budget -= received;
-
-		if (rx_work_limit < 0)
-			return 1;	/* not done */
-
-		/* done */
-		netif_rx_complete(dev);
+		if (received < budget) {
+			netif_rx_complete(dev, &fep->napi);
 
-		/* enable RX interrupt bits */
-		FS(fecp, imask, FEC_ENET_RXF | FEC_ENET_RXB);
+			/* enable RX interrupt bits */
+			FS(fecp, imask, FEC_ENET_RXF | FEC_ENET_RXB);
+		}
 	}
 
-	return 0;
+	return received;
 }
 
 static void fec_enet_tx(struct net_device *dev)
@@ -743,12 +734,12 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 		if ((int_events & FEC_ENET_RXF) != 0) {
 			if (!fpi->use_napi)
-				fec_enet_rx_common(dev, NULL);
+				fec_enet_rx_common(fep, dev, ~0);
 			else {
-				if (netif_rx_schedule_prep(dev)) {
+				if (netif_rx_schedule_prep(dev, &fep->napi)) {
 					/* disable rx interrupts */
 					FC(fecp, imask, FEC_ENET_RXF | FEC_ENET_RXB);
-					__netif_rx_schedule(dev);
+					__netif_rx_schedule(dev, &fep->napi);
 				} else {
 					printk(KERN_ERR DRV_MODULE_NAME
 					       ": %s driver bug! interrupt while in poll!\n",
@@ -932,6 +923,7 @@ static int fec_enet_close(struct net_device *dev)
 	unsigned long flags;
 
 	netif_stop_queue(dev);
+	napi_disable(&fep->napi);
 	netif_carrier_off(dev);
 
 	if (fpi->use_mdio)
@@ -955,9 +947,12 @@ static struct net_device_stats *fec_enet_get_stats(struct net_device *dev)
 	return &fep->stats;
 }
 
-static int fec_enet_poll(struct net_device *dev, int *budget)
+static int fec_enet_poll(struct napi_struct *napi, int budget)
 {
-	return fec_enet_rx_common(dev, budget);
+	struct fec_enet_private *fep = container_of(napi, struct fec_enet_private, napi);
+	struct net_device *dev = fep->dev;
+
+	return fec_enet_rx_common(fep, dev, budget);
 }
 
 /*************************************************************************/
@@ -1107,6 +1102,7 @@ int fec_8xx_init_one(const struct fec_platform_info *fpi,
 	SET_MODULE_OWNER(dev);
 
 	fep = netdev_priv(dev);
+	fep->dev = dev;
 
 	/* partial reset of FEC */
 	fec_whack_reset(fecp);
@@ -1173,8 +1169,8 @@ int fec_8xx_init_one(const struct fec_platform_info *fpi,
 	dev->set_multicast_list = fec_set_multicast_list;
 	dev->set_mac_address = fec_set_mac_address;
 	if (fpi->use_napi) {
-		dev->poll = fec_enet_poll;
-		dev->weight = fpi->napi_weight;
+		fec->napi.poll = fec_enet_poll;
+		fec->napi.weight = fpi->napi_weight;
 	}
 	dev->ethtool_ops = &fec_ethtool_ops;
 	dev->do_ioctl = fec_ioctl;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6d1d50a..7b731e6 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -744,6 +744,9 @@ struct nv_skb_map {
 struct fe_priv {
 	spinlock_t lock;
 
+	struct net_device *dev;
+	struct napi_struct napi;
+
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
 	struct net_device_stats stats;
@@ -1585,9 +1588,10 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 static void nv_do_rx_refill(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
+	struct fe_priv *np = netdev_priv(dev);
 
 	/* Just reschedule NAPI rx processing */
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &np->napi);
 }
 #else
 static void nv_do_rx_refill(unsigned long data)
@@ -2996,7 +3000,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3113,7 +3117,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3244,19 +3248,19 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 }
 
 #ifdef CONFIG_FORCEDETH_NAPI
-static int nv_napi_poll(struct net_device *dev, int *budget)
+static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
-	int pkts, limit = min(*budget, dev->quota);
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
+	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
-	int retcode;
+	int pkts, retcode;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		pkts = nv_rx_process(dev, limit);
+		pkts = nv_rx_process(dev, budget);
 		retcode = nv_alloc_rx(dev);
 	} else {
-		pkts = nv_rx_process_optimized(dev, limit);
+		pkts = nv_rx_process_optimized(dev, budget);
 		retcode = nv_alloc_rx_optimized(dev);
 	}
 
@@ -3267,9 +3271,9 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
-	if (pkts < limit) {
+	if (pkts < budget) {
 		/* all done, no more packets present */
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 
 		/* re-enable receive interrupts */
 		spin_lock_irqsave(&np->lock, flags);
@@ -3281,13 +3285,8 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
 			writel(np->irqmask, base + NvRegIrqMask);
 
 		spin_unlock_irqrestore(&np->lock, flags);
-		return 0;
-	} else {
-		/* used up our quantum, so reschedule */
-		dev->quota -= pkts;
-		*budget -= pkts;
-		return 1;
 	}
+	return pkts;
 }
 #endif
 
@@ -3295,6 +3294,7 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 
@@ -3302,7 +3302,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 
 	if (events) {
-		netif_rx_schedule(dev);
+		netif_rx_schedule(dev, &np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
@@ -4619,7 +4619,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-			netif_poll_disable(dev);
+			napi_disable(&np->napi);
 			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
@@ -4678,7 +4678,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			nv_start_rx(dev);
 			nv_start_tx(dev);
 			netif_start_queue(dev);
-			netif_poll_enable(dev);
+			napi_enable(&np->napi);
 			nv_enable_hw_interrupts(dev, np->irqmask);
 		}
 	}
@@ -4911,7 +4911,7 @@ static int nv_open(struct net_device *dev)
 	nv_start_rx(dev);
 	nv_start_tx(dev);
 	netif_start_queue(dev);
-	netif_poll_enable(dev);
+	napi_enable(&np->napi);
 
 	if (ret) {
 		netif_carrier_on(dev);
@@ -4942,7 +4942,7 @@ static int nv_close(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
-	netif_poll_disable(dev);
+	napi_disable(&np->napi);
 	synchronize_irq(dev->irq);
 
 	del_timer_sync(&np->oom_kick);
@@ -4994,6 +4994,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out;
 
 	np = netdev_priv(dev);
+	np->dev = dev;
 	np->pci_dev = pci_dev;
 	spin_lock_init(&np->lock);
 	SET_MODULE_OWNER(dev);
@@ -5155,9 +5156,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-	dev->weight = RX_WORK_PER_LOOP;
+	np->napi.weight = RX_WORK_PER_LOOP;
 #ifdef CONFIG_FORCEDETH_NAPI
-	dev->poll = nv_napi_poll;
+	np->napi.poll = nv_napi_poll;
 #endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a4a2a0e..3436070 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -70,18 +70,16 @@ static void fs_set_multicast_list(struct net_device *dev)
 }
 
 /* NAPI receive function */
-static int fs_enet_rx_napi(struct net_device *dev, int *budget)
+static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
-	struct fs_enet_private *fep = netdev_priv(dev);
+	struct fs_enet_private *fep = container_of(napi, struct fec_enet_private, napi);
+	struct net_device *dev = fep->dev;
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
 	int received = 0;
 	u16 pkt_len, sc;
 	int curidx;
-	int rx_work_limit = 0;	/* pacify gcc */
-
-	rx_work_limit = min(dev->quota, *budget);
 
 	if (!netif_running(dev))
 		return 0;
@@ -96,7 +94,6 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
 	(*fep->ops->napi_clear_rx_event)(dev);
 
 	while (((sc = CBDR_SC(bdp)) & BD_ENET_RX_EMPTY) == 0) {
-
 		curidx = bdp - fep->rx_bd_base;
 
 		/*
@@ -136,11 +133,6 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
 			skbn = skb;
 
 		} else {
-
-			/* napi, got packet but no quota */
-			if (--rx_work_limit < 0)
-				break;
-
 			skb = fep->rx_skbuff[curidx];
 
 			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
@@ -199,22 +191,19 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
 			bdp = fep->rx_bd_base;
 
 		(*fep->ops->rx_bd_done)(dev);
+
+		if (received >= budget)
+			break;
 	}
 
 	fep->cur_rx = bdp;
 
-	dev->quota -= received;
-	*budget -= received;
-
-	if (rx_work_limit < 0)
-		return 1;	/* not done */
-
-	/* done */
-	netif_rx_complete(dev);
-
-	(*fep->ops->napi_enable_rx)(dev);
-
-	return 0;
+	if (received >= budget) {
+		/* done */
+		netif_rx_complete(dev, napi);
+		(*fep->ops->napi_enable_rx)(dev);
+	}
+	return received;
 }
 
 /* non NAPI receive function */
@@ -470,7 +459,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 			if (!fpi->use_napi)
 				fs_enet_rx_non_napi(dev);
 			else {
-				napi_ok = netif_rx_schedule_prep(dev);
+				napi_ok = napi_schedule_prep(&fep->napi);
 
 				(*fep->ops->napi_disable_rx)(dev);
 				(*fep->ops->clear_int_events)(dev, fep->ev_napi_rx);
@@ -478,7 +467,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 				/* NOTE: it is possible for FCCs in NAPI mode    */
 				/* to submit a spurious interrupt while in poll  */
 				if (napi_ok)
-					__netif_rx_schedule(dev);
+					__netif_rx_schedule(dev, &fep->napi);
 			}
 		}
 
@@ -823,6 +812,7 @@ static int fs_enet_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
+	napi_disable(&fep->napi);
 	phy_stop(fep->phydev);
 
 	spin_lock_irqsave(&fep->lock, flags);
@@ -1048,8 +1038,8 @@ static struct net_device *fs_init_instance(struct device *dev,
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
 	if (fpi->use_napi) {
-		ndev->poll = fs_enet_rx_napi;
-		ndev->weight = fpi->napi_weight;
+		fep->napi.poll = fs_enet_rx_napi;
+		fep->napi.weight = fpi->napi_weight;
 	}
 	ndev->ethtool_ops = &fs_ethtool_ops;
 	ndev->do_ioctl = fs_ioctl;
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 569be22..46d0606 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -121,6 +121,7 @@ struct fs_enet_mii_bus {
 };
 
 struct fs_enet_private {
+	struct napi_struct napi;
 	struct device *dev;	/* pointer back to the device (must be initialized first) */
 	spinlock_t lock;	/* during all ops except TX pckt processing */
 	spinlock_t tx_lock;	/* during fs_start_xmit and fs_tx         */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f926905..7bb78e9 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -134,7 +134,7 @@ static void gfar_configure_serdes(struct net_device *dev);
 extern int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id, int regnum, u16 value);
 extern int gfar_local_mdio_read(struct gfar_mii *regs, int mii_id, int regnum);
 #ifdef CONFIG_GFAR_NAPI
-static int gfar_poll(struct net_device *dev, int *budget);
+static int gfar_poll(struct napi_struct *napi, int budget);
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gfar_netpoll(struct net_device *dev);
@@ -188,6 +188,7 @@ static int gfar_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	priv = netdev_priv(dev);
+	priv->dev = dev;
 
 	/* Set the info in the priv to the current info */
 	priv->einfo = einfo;
@@ -262,8 +263,8 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_GFAR_NAPI
-	dev->poll = gfar_poll;
-	dev->weight = GFAR_DEV_WEIGHT;
+	priv->napi.poll = gfar_poll;
+	priv->napi.weight = GFAR_DEV_WEIGHT;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = gfar_netpoll;
@@ -1102,6 +1103,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int gfar_close(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+
+	napi_disable(&priv->napi);
+
 	stop_gfar(dev);
 
 	/* Disconnect from the PHY */
@@ -1318,7 +1322,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 		return NULL;
 
 	alignamount = RXBUF_ALIGNMENT -
-		(((unsigned) skb->data) & (RXBUF_ALIGNMENT - 1));
+		(((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1));
 
 	/* We need the data buffer to be aligned properly.  We will reserve
 	 * as many bytes as needed to align the data properly
@@ -1390,12 +1394,12 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 
 	/* support NAPI */
 #ifdef CONFIG_GFAR_NAPI
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &priv->napi)) {
 		tempval = gfar_read(&priv->regs->imask);
 		tempval &= IMASK_RX_DISABLED;
 		gfar_write(&priv->regs->imask, tempval);
 
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &priv->napi);
 	} else {
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: receive called twice (%x)[%x]\n",
@@ -1569,23 +1573,16 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 }
 
 #ifdef CONFIG_GFAR_NAPI
-static int gfar_poll(struct net_device *dev, int *budget)
+static int gfar_poll(struct napi_struct *napi, int budget)
 {
+	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
+	struct net_device *dev = priv->dev;
 	int howmany;
-	struct gfar_private *priv = netdev_priv(dev);
-	int rx_work_limit = *budget;
 
-	if (rx_work_limit > dev->quota)
-		rx_work_limit = dev->quota;
+	howmany = gfar_clean_rx_ring(dev, budget);
 
-	howmany = gfar_clean_rx_ring(dev, rx_work_limit);
-
-	dev->quota -= howmany;
-	rx_work_limit -= howmany;
-	*budget -= howmany;
-
-	if (rx_work_limit > 0) {
-		netif_rx_complete(dev);
+	if (howmany < budget) {
+		netif_rx_complete(dev, napi);
 
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
@@ -1601,8 +1598,7 @@ static int gfar_poll(struct net_device *dev, int *budget)
 			gfar_write(&priv->regs->rxic, 0);
 	}
 
-	/* Return 1 if there's more work to do */
-	return (rx_work_limit > 0) ? 0 : 1;
+	return howmany;
 }
 #endif
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index d8e779c..b8714e0 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -691,6 +691,9 @@ struct gfar_private {
 	/* RX Locked fields */
 	spinlock_t rxlock;
 
+	struct net_device *dev;
+	struct napi_struct napi;
+
 	/* skb array and index */
 	struct sk_buff ** rx_skbuff;
 	u16 skb_currx;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index d96eb72..76d9f98 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -83,7 +83,7 @@
 static int ibmveth_open(struct net_device *dev);
 static int ibmveth_close(struct net_device *dev);
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static int ibmveth_poll(struct net_device *dev, int *budget);
+static int ibmveth_poll(struct napi_struct *napi, int budget);
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static struct net_device_stats *ibmveth_get_stats(struct net_device *dev);
 static void ibmveth_set_multicast_list(struct net_device *dev);
@@ -587,6 +587,8 @@ static int ibmveth_close(struct net_device *netdev)
 
 	ibmveth_debug_printk("close starting\n");
 
+	napi_disable(&adapter->napi);
+
 	if (!adapter->pool_config)
 		netif_stop_queue(netdev);
 
@@ -767,80 +769,61 @@ out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	return 0;
 }
 
-static int ibmveth_poll(struct net_device *netdev, int *budget)
+static int ibmveth_poll(struct napi_struct *napi, int budget)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
-	int max_frames_to_process = netdev->quota;
+	struct ibmveth_adapter *adapter = container_of(napi, struct ibmveth_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
 	int frames_processed = 0;
-	int more_work = 1;
 	unsigned long lpar_rc;
 
- restart_poll:
 	do {
-		struct net_device *netdev = adapter->netdev;
-
-		if(ibmveth_rxq_pending_buffer(adapter)) {
-			struct sk_buff *skb;
+		struct sk_buff *skb;
 
-			rmb();
+		if (!ibmveth_rxq_pending_buffer(adapter))
+			break;
 
-			if(!ibmveth_rxq_buffer_valid(adapter)) {
-				wmb(); /* suggested by larson1 */
-				adapter->rx_invalid_buffer++;
-				ibmveth_debug_printk("recycling invalid buffer\n");
-				ibmveth_rxq_recycle_buffer(adapter);
-			} else {
-				int length = ibmveth_rxq_frame_length(adapter);
-				int offset = ibmveth_rxq_frame_offset(adapter);
-				skb = ibmveth_rxq_get_buffer(adapter);
+		rmb();
+		if (!ibmveth_rxq_buffer_valid(adapter)) {
+			wmb(); /* suggested by larson1 */
+			adapter->rx_invalid_buffer++;
+			ibmveth_debug_printk("recycling invalid buffer\n");
+			ibmveth_rxq_recycle_buffer(adapter);
+		} else {
+			int length = ibmveth_rxq_frame_length(adapter);
+			int offset = ibmveth_rxq_frame_offset(adapter);
+			skb = ibmveth_rxq_get_buffer(adapter);
 
-				ibmveth_rxq_harvest_buffer(adapter);
+			ibmveth_rxq_harvest_buffer(adapter);
 
-				skb_reserve(skb, offset);
-				skb_put(skb, length);
-				skb->protocol = eth_type_trans(skb, netdev);
+			skb_reserve(skb, offset);
+			skb_put(skb, length);
+			skb->protocol = eth_type_trans(skb, netdev);
 
-				netif_receive_skb(skb);	/* send it up */
+			netif_receive_skb(skb);	/* send it up */
 
-				adapter->stats.rx_packets++;
-				adapter->stats.rx_bytes += length;
-				frames_processed++;
-				netdev->last_rx = jiffies;
-			}
-		} else {
-			more_work = 0;
+			adapter->stats.rx_packets++;
+			adapter->stats.rx_bytes += length;
+			frames_processed++;
+			netdev->last_rx = jiffies;
 		}
-	} while(more_work && (frames_processed < max_frames_to_process));
+	} while (frames_processed < budget);
 
 	ibmveth_replenish_task(adapter);
 
-	if(more_work) {
-		/* more work to do - return that we are not done yet */
-		netdev->quota -= frames_processed;
-		*budget -= frames_processed;
-		return 1;
-	}
-
-	/* we think we are done - reenable interrupts, then check once more to make sure we are done */
-	lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_ENABLE);
-
-	ibmveth_assert(lpar_rc == H_SUCCESS);
-
-	netif_rx_complete(netdev);
+	if (frames_processed < budget) {
+		/* We think we are done - reenable interrupts,
+		 * then check once more to make sure we are done.
+		 */
+		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
+				       VIO_IRQ_ENABLE);
 
-	if(ibmveth_rxq_pending_buffer(adapter) && netif_rx_reschedule(netdev, frames_processed))
-	{
-		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
 		ibmveth_assert(lpar_rc == H_SUCCESS);
-		more_work = 1;
-		goto restart_poll;
-	}
 
-	netdev->quota -= frames_processed;
-	*budget -= frames_processed;
+		if (!ibmveth_rxq_pending_buffer(adapter))
+			netif_rx_complete(netdev, napi);
+	}
 
-	/* we really are done */
-	return 0;
+	return frames_processed;
 }
 
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
@@ -849,10 +832,10 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 	struct ibmveth_adapter *adapter = netdev->priv;
 	unsigned long lpar_rc;
 
-	if(netif_rx_schedule_prep(netdev)) {
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
 		ibmveth_assert(lpar_rc == H_SUCCESS);
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -1005,6 +988,9 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	adapter->mcastFilterSize= *mcastFilterSize_p;
 	adapter->pool_config = 0;
 
+	adapter->napi.poll = ibmveth_poll;
+	adapter->napi.weight = 16;
+
 	/* 	Some older boxes running PHYP non-natively have an OF that
 		returns a 8-byte local-mac-address field (and the first
 		2 bytes have to be ignored) while newer boxes' OF return
@@ -1021,8 +1007,6 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 
 	netdev->irq = dev->irq;
 	netdev->open               = ibmveth_open;
-	netdev->poll               = ibmveth_poll;
-	netdev->weight             = 16;
 	netdev->stop               = ibmveth_close;
 	netdev->hard_start_xmit    = ibmveth_start_xmit;
 	netdev->get_stats          = ibmveth_get_stats;
diff --git a/drivers/net/ibmveth.h b/drivers/net/ibmveth.h
index bb69cca..bb2e5e1 100644
--- a/drivers/net/ibmveth.h
+++ b/drivers/net/ibmveth.h
@@ -115,6 +115,7 @@ struct ibmveth_rx_q {
 struct ibmveth_adapter {
     struct vio_dev *vdev;
     struct net_device *netdev;
+    struct napi_struct napi;
     struct net_device_stats stats;
     unsigned int mcastFilterSize;
     unsigned long mac_addr;
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3569d5b..1eee889 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -184,6 +184,7 @@ struct ixgb_adapter {
 	boolean_t rx_csum;
 
 	/* OS defined structs */
+	struct napi_struct napi;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 991c883..b6e5a7b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -97,7 +97,7 @@ static irqreturn_t ixgb_intr(int irq, void *data);
 static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_IXGB_NAPI
-static int ixgb_clean(struct net_device *netdev, int *budget);
+static int ixgb_clean(struct napi_struct *napi, int budget);
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
 				   int *work_done, int work_to_do);
 #else
@@ -288,7 +288,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
 #ifdef CONFIG_IXGB_NAPI
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 #endif
 	ixgb_irq_enable(adapter);
 
@@ -309,7 +309,7 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 #ifdef CONFIG_IXGB_NAPI
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 #endif
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -421,8 +421,8 @@ ixgb_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_IXGB_NAPI
-	netdev->poll = &ixgb_clean;
-	netdev->weight = 64;
+	adapter->napi.poll = &ixgb_clean;
+	adapter->napi.weight = 64;
 #endif
 	netdev->vlan_rx_register = ixgb_vlan_rx_register;
 	netdev->vlan_rx_add_vid = ixgb_vlan_rx_add_vid;
@@ -1746,7 +1746,7 @@ ixgb_intr(int irq, void *data)
 	}
 
 #ifdef CONFIG_IXGB_NAPI
-	if(netif_rx_schedule_prep(netdev)) {
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 
 		/* Disable interrupts and register for poll. The flush 
 		  of the posted write is intentionally left out.
@@ -1754,7 +1754,7 @@ ixgb_intr(int irq, void *data)
 
 		atomic_inc(&adapter->irq_sem);
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	}
 #else
 	/* yes, that is actually a & and it is meant to make sure that
@@ -1776,27 +1776,23 @@ ixgb_intr(int irq, void *data)
  **/
 
 static int
-ixgb_clean(struct net_device *netdev, int *budget)
+ixgb_clean(struct napi_struct *napi, int budget)
 {
-	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
+	struct ixgb_adapter *adapter = container_of(napi, struct ixgb_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
 	int tx_cleaned;
 	int work_done = 0;
 
 	tx_cleaned = ixgb_clean_tx_irq(adapter);
-	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
-
-	*budget -= work_done;
-	netdev->quota -= work_done;
+	ixgb_clean_rx_irq(adapter, &work_done, budget);
 
 	/* if no Tx and not enough Rx work done, exit the polling mode */
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
-		netif_rx_complete(netdev);
+		netif_rx_complete(netdev, napi);
 		ixgb_irq_enable(adapter);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 #endif
 
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index d9ce1ae..a3beb71 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -74,9 +74,9 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-static int ixpdev_rx(struct net_device *dev, int *budget)
+static int ixpdev_rx(struct net_device *dev, int processed, int budget)
 {
-	while (*budget > 0) {
+	while (processed < budget) {
 		struct ixpdev_rx_desc *desc;
 		struct sk_buff *skb;
 		void *buf;
@@ -122,29 +122,34 @@ static int ixpdev_rx(struct net_device *dev, int *budget)
 
 err:
 		ixp2000_reg_write(RING_RX_PENDING, _desc);
-		dev->quota--;
-		(*budget)--;
+		processed++;
 	}
 
-	return 1;
+	return processed;
 }
 
 /* dev always points to nds[0].  */
-static int ixpdev_poll(struct net_device *dev, int *budget)
+static int ixpdev_poll(struct napi_struct *napi, int budget)
 {
+	struct ixpdev_priv *ip = container_of(napi, struct ixpdev_priv, napi);
+	struct net_device *dev = ip->dev;
+	int rx;
+
 	/* @@@ Have to stop polling when nds[0] is administratively
 	 * downed while we are polling.  */
+	rx = 0;
 	do {
 		ixp2000_reg_write(IXP2000_IRQ_THD_RAW_STATUS_A_0, 0x00ff);
 
-		if (ixpdev_rx(dev, budget))
-			return 1;
+		rx = ixpdev_rx(dev, rx, budget);
+		if (rx >= budget)
+			break;
 	} while (ixp2000_reg_read(IXP2000_IRQ_THD_RAW_STATUS_A_0) & 0x00ff);
 
-	netif_rx_complete(dev);
+	netif_rx_complete(dev, napi);
 	ixp2000_reg_write(IXP2000_IRQ_THD_ENABLE_SET_A_0, 0x00ff);
 
-	return 0;
+	return rx;
 }
 
 static void ixpdev_tx_complete(void)
@@ -199,9 +204,12 @@ static irqreturn_t ixpdev_interrupt(int irq, void *dev_id)
 	 * Any of the eight receive units signaled RX?
 	 */
 	if (status & 0x00ff) {
+		struct net_device *dev = nds[0];
+		struct ixpdev_priv *ip = netdev_priv(dev);
+
 		ixp2000_reg_wrb(IXP2000_IRQ_THD_ENABLE_CLEAR_A_0, 0x00ff);
-		if (likely(__netif_rx_schedule_prep(nds[0]))) {
-			__netif_rx_schedule(nds[0]);
+		if (likely(napi_schedule_prep(&ip->napi))) {
+			__netif_rx_schedule(dev, &ip->napi);
 		} else {
 			printk(KERN_CRIT "ixp2000: irq while polling!!\n");
 		}
@@ -254,6 +262,7 @@ static int ixpdev_close(struct net_device *dev)
 	struct ixpdev_priv *ip = netdev_priv(dev);
 
 	netif_stop_queue(dev);
+	napi_disable(&ip->napi);
 	set_port_admin_status(ip->channel, 0);
 
 	if (!--nds_open) {
@@ -274,7 +283,6 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 		return NULL;
 
 	dev->hard_start_xmit = ixpdev_xmit;
-	dev->poll = ixpdev_poll;
 	dev->open = ixpdev_open;
 	dev->stop = ixpdev_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -282,9 +290,11 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 #endif
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->weight = 64;
 
 	ip = netdev_priv(dev);
+	ip->dev = dev;
+	ip->napi.poll = ixpdev_poll;
+	ip->napi.weight = 64;
 	ip->channel = channel;
 	ip->tx_queue_entries = 0;
 
diff --git a/drivers/net/ixp2000/ixpdev.h b/drivers/net/ixp2000/ixpdev.h
index bd686cb..391ece6 100644
--- a/drivers/net/ixp2000/ixpdev.h
+++ b/drivers/net/ixp2000/ixpdev.h
@@ -14,6 +14,8 @@
 
 struct ixpdev_priv
 {
+	struct net_device *dev;
+	struct napi_struct napi;
 	int	channel;
 	int	tx_queue_entries;
 };
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a4bb026..ff58b92 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -470,22 +470,24 @@ static int macb_rx(struct macb *bp, int budget)
 	return received;
 }
 
-static int macb_poll(struct net_device *dev, int *budget)
+static int macb_poll(struct napi_struct *napi, int budget)
 {
-	struct macb *bp = netdev_priv(dev);
-	int orig_budget, work_done, retval = 0;
+	struct macb *bp = container_of(napi, struct macb, napi);
+	struct net_device *dev = bp->dev;
+	int work_done;
 	u32 status;
 
 	status = macb_readl(bp, RSR);
 	macb_writel(bp, RSR, status);
 
+	work_done = 0;
 	if (!status) {
 		/*
 		 * This may happen if an interrupt was pending before
 		 * this function was called last time, and no packets
 		 * have been received since.
 		 */
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		goto out;
 	}
 
@@ -496,21 +498,13 @@ static int macb_poll(struct net_device *dev, int *budget)
 		dev_warn(&bp->pdev->dev,
 			 "No RX buffers complete, status = %02lx\n",
 			 (unsigned long)status);
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		goto out;
 	}
 
-	orig_budget = *budget;
-	if (orig_budget > dev->quota)
-		orig_budget = dev->quota;
-
-	work_done = macb_rx(bp, orig_budget);
-	if (work_done < orig_budget) {
-		netif_rx_complete(dev);
-		retval = 0;
-	} else {
-		retval = 1;
-	}
+	work_done = macb_rx(bp, budget);
+	if (work_done < orig_budget)
+		netif_rx_complete(dev, napi);
 
 	/*
 	 * We've done what we can to clean the buffers. Make sure we
@@ -521,7 +515,7 @@ out:
 
 	/* TODO: Handle errors */
 
-	return retval;
+	return work_done;
 }
 
 static irqreturn_t macb_interrupt(int irq, void *dev_id)
@@ -545,7 +539,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (status & MACB_RX_INT_FLAGS) {
-			if (netif_rx_schedule_prep(dev)) {
+			if (netif_rx_schedule_prep(dev, &bp->napi)) {
 				/*
 				 * There's no point taking any more interrupts
 				 * until we have processed the buffers
@@ -553,7 +547,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
-				__netif_rx_schedule(dev);
+				__netif_rx_schedule(dev, &bp->napi);
 			}
 		}
 
@@ -954,6 +948,7 @@ static int macb_close(struct net_device *dev)
 	unsigned long flags;
 
 	netif_stop_queue(dev);
+	napi_disable(&bp->napi);
 
 	if (bp->phy_dev)
 		phy_stop(bp->phy_dev);
@@ -1146,8 +1141,8 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	dev->get_stats = macb_get_stats;
 	dev->set_multicast_list = macb_set_rx_mode;
 	dev->do_ioctl = macb_ioctl;
-	dev->poll = macb_poll;
-	dev->weight = 64;
+	bp->napi.poll = macb_poll;
+	bp->napi.weight = 64;
 	dev->ethtool_ops = &macb_ethtool_ops;
 
 	dev->base_addr = regs->start;
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index 4e3283e..57b85ac 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -374,6 +374,7 @@ struct macb {
 	struct clk		*pclk;
 	struct clk		*hclk;
 	struct net_device	*dev;
+	struct napi_struct	napi;
 	struct net_device_stats	stats;
 	struct macb_stats	hw_stats;
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..3ab0399 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -66,7 +66,7 @@ static int mv643xx_eth_change_mtu(struct net_device *, int);
 static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *);
 static void eth_port_init_mac_tables(unsigned int eth_port_num);
 #ifdef MV643XX_NAPI
-static int mv643xx_poll(struct net_device *dev, int *budget);
+static int mv643xx_poll(struct net_device *dev, int budget);
 #endif
 static int ethernet_phy_get(unsigned int eth_port_num);
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
@@ -562,7 +562,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 		/* wait for previous write to complete */
 		mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
 
-		netif_rx_schedule(dev);
+		netif_rx_schedule(dev, &bp->napi);
 	}
 #else
 	if (eth_int_cause & ETH_INT_CAUSE_RX)
@@ -982,7 +982,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
 
 #ifdef MV643XX_NAPI
-	netif_poll_disable(dev);
+	napi_disable(&mp->napi);
 #endif
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
@@ -992,10 +992,6 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
 
-#ifdef MV643XX_NAPI
-	netif_poll_enable(dev);
-#endif
-
 	free_irq(dev->irq, dev);
 
 	return 0;
@@ -1007,11 +1003,12 @@ static int mv643xx_eth_stop(struct net_device *dev)
  *
  * This function is used in case of NAPI
  */
-static int mv643xx_poll(struct net_device *dev, int *budget)
+static int mv643xx_poll(struct napi_struct *napi, int budget)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int done = 1, orig_budget, work_done;
+	struct mv643xx_private *mp = container_of(napi, struct mv643xx_private, napi);
+	struct net_device *dev = mp->dev;
 	unsigned int port_num = mp->port_num;
+	int work_done;
 
 #ifdef MV643XX_TX_FAST_REFILL
 	if (++mp->tx_clean_threshold > 5) {
@@ -1020,27 +1017,20 @@ static int mv643xx_poll(struct net_device *dev, int *budget)
 	}
 #endif
 
+	work_done = 0;
 	if ((mv_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
-						!= (u32) mp->rx_used_desc_q) {
-		orig_budget = *budget;
-		if (orig_budget > dev->quota)
-			orig_budget = dev->quota;
-		work_done = mv643xx_eth_receive_queue(dev, orig_budget);
-		*budget -= work_done;
-		dev->quota -= work_done;
-		if (work_done >= orig_budget)
-			done = 0;
-	}
+	    != (u32) mp->rx_used_desc_q)
+		work_done = mv643xx_eth_receive_queue(dev, budget);
 
-	if (done) {
-		netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 						ETH_INT_UNMASK_ALL);
 	}
 
-	return done ? 0 : 1;
+	return work_done;
 }
 #endif
 
@@ -1333,6 +1323,11 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, dev);
 
 	mp = netdev_priv(dev);
+	mp->dev = dev;
+#ifdef MV643XX_NAPI
+	mp->napi.poll = mv643xx_poll;
+	mp->napi.weight = 64;
+#endif
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
@@ -1347,10 +1342,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	/* No need to Tx Timeout */
 	dev->tx_timeout = mv643xx_eth_tx_timeout;
-#ifdef MV643XX_NAPI
-	dev->poll = mv643xx_poll;
-	dev->weight = 64;
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = mv643xx_netpoll;
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
index 82f8c0c..6f2aaa6 100644
--- a/drivers/net/mv643xx_eth.h
+++ b/drivers/net/mv643xx_eth.h
@@ -318,6 +318,8 @@ struct mv643xx_private {
 
 	struct work_struct tx_timeout_task;
 
+	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 	struct mv643xx_mib_counters mib_counters;
 	spinlock_t lock;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index deca653..09413e8 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -163,6 +163,7 @@ struct myri10ge_priv {
 	int small_bytes;
 	int big_bytes;
 	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 	u8 __iomem *sram;
 	int sram_size;
@@ -1099,7 +1100,7 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 	}
 }
 
-static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
+static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	unsigned long rx_bytes = 0;
@@ -1108,10 +1109,11 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 
 	int idx = rx_done->idx;
 	int cnt = rx_done->cnt;
+	int work_done = 0;
 	u16 length;
 	__wsum checksum;
 
-	while (rx_done->entry[idx].length != 0 && *limit != 0) {
+	while (rx_done->entry[idx].length != 0 && work_done++ < budget) {
 		length = ntohs(rx_done->entry[idx].length);
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
@@ -1127,10 +1129,6 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
 		idx = cnt & (myri10ge_max_intr_slots - 1);
-
-		/* limit potential for livelock by only handling a
-		 * limited number of frames. */
-		(*limit)--;
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
@@ -1144,6 +1142,7 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
 
+	return work_done;
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
@@ -1188,26 +1187,21 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 	}
 }
 
-static int myri10ge_poll(struct net_device *netdev, int *budget)
+static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	struct myri10ge_priv *mgp = container_of(napi, struct myri10ge_priv, napi);
+	struct net_device *netdev = mgp->dev;
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
-	int limit, orig_limit, work_done;
+	int work_done;
 
 	/* process as many rx events as NAPI will allow */
-	limit = min(*budget, netdev->quota);
-	orig_limit = limit;
-	myri10ge_clean_rx_done(mgp, &limit);
-	work_done = orig_limit - limit;
-	*budget -= work_done;
-	netdev->quota -= work_done;
+	work_done = myri10ge_clean_rx_done(mgp, budget);
 
 	if (rx_done->entry[rx_done->idx].length == 0 || !netif_running(netdev)) {
-		netif_rx_complete(netdev);
+		netif_rx_complete(netdev, napi);
 		put_be32(htonl(3), mgp->irq_claim);
-		return 0;
 	}
-	return 1;
+	return work_done;
 }
 
 static irqreturn_t myri10ge_intr(int irq, void *arg)
@@ -1225,7 +1219,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(mgp->dev);
+		netif_rx_schedule(mgp->dev, &mgp->napi);
 
 	if (!mgp->msi_enabled) {
 		put_be32(0, mgp->irq_deassert);
@@ -1852,7 +1846,7 @@ static int myri10ge_open(struct net_device *dev)
 	mgp->link_state = htonl(~0U);
 	mgp->rdma_tags_available = 15;
 
-	netif_poll_enable(mgp->dev);	/* must happen prior to any irq */
+	napi_enable(&mgp->napi);	/* must happen prior to any irq */
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);
 	if (status) {
@@ -1896,7 +1890,7 @@ static int myri10ge_close(struct net_device *dev)
 
 	del_timer_sync(&mgp->watchdog_timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
-	netif_poll_disable(mgp->dev);
+	napi_disable(&mgp->napi);
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 	old_down_cnt = mgp->down_cnt;
@@ -2854,6 +2848,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mgp = netdev_priv(netdev);
 	memset(mgp, 0, sizeof(*mgp));
 	mgp->dev = netdev;
+	mgp->napi.poll = myri10ge_poll;
+	mgp->napi.weight = myri10ge_napi_weight;
 	mgp->pdev = pdev;
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
@@ -2990,8 +2986,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
-	netdev->poll = myri10ge_poll;
-	netdev->weight = myri10ge_napi_weight;
 
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 6bb48ba..4b2a727 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -560,6 +560,8 @@ struct netdev_private {
 	/* address of a sent-in-place packet/buffer, for later free() */
 	struct sk_buff *tx_skbuff[TX_RING_SIZE];
 	dma_addr_t tx_dma[TX_RING_SIZE];
+	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 	/* Media monitoring timer */
 	struct timer_list timer;
@@ -636,7 +638,7 @@ static void init_registers(struct net_device *dev);
 static int start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void netdev_error(struct net_device *dev, int intr_status);
-static int natsemi_poll(struct net_device *dev, int *budget);
+static int natsemi_poll(struct napi_struct *napi, int budget);
 static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do);
 static void netdev_tx_done(struct net_device *dev);
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
@@ -861,6 +863,8 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev->irq = irq;
 
 	np = netdev_priv(dev);
+	np->napi.poll = natsemi_poll;
+	np->napi.weight = 64;
 
 	np->pci_dev = pdev;
 	pci_set_drvdata(pdev, dev);
@@ -931,8 +935,6 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->poll = natsemi_poll;
-	dev->weight = 64;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &natsemi_poll_controller;
@@ -2200,10 +2202,10 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
 
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &np->napi)) {
 		/* Disable interrupts and register for poll */
 		natsemi_irq_disable(dev);
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &np->napi);
 	} else
 		printk(KERN_WARNING
 	       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
@@ -2216,12 +2218,11 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 /* This is the NAPI poll routine.  As well as the standard RX handling
  * it also handles all other interrupts that the chip might raise.
  */
-static int natsemi_poll(struct net_device *dev, int *budget)
+static int natsemi_poll(struct napi_struct *napi, int budget)
 {
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = container_of(napi, struct netdev_private, napi);
+	struct net_device *dev = np->dev;
 	void __iomem * ioaddr = ns_ioaddr(dev);
-
-	int work_to_do = min(*budget, dev->quota);
 	int work_done = 0;
 
 	do {
@@ -2236,7 +2237,7 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		if (np->intr_status &
 		    (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
 		     IntrRxErr | IntrRxOverrun)) {
-			netdev_rx(dev, &work_done, work_to_do);
+			netdev_rx(dev, &work_done, budget);
 		}
 
 		if (np->intr_status &
@@ -2250,16 +2251,13 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		if (np->intr_status & IntrAbnormalSummary)
 			netdev_error(dev, np->intr_status);
 
-		*budget -= work_done;
-		dev->quota -= work_done;
-
-		if (work_done >= work_to_do)
-			return 1;
+		if (work_done >= budget)
+			return work_done;
 
 		np->intr_status = readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
 
-	netif_rx_complete(dev);
+	netif_rx_complete(dev, napi);
 
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
@@ -2268,7 +2266,7 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		natsemi_irq_enable(dev);
 	spin_unlock(&np->lock);
 
-	return 0;
+	return work_done;
 }
 
 /* This routine is logically part of the interrupt handler, but separated
@@ -3155,6 +3153,8 @@ static int netdev_close(struct net_device *dev)
 			dev->name, np->cur_tx, np->dirty_tx,
 			np->cur_rx, np->dirty_rx);
 
+	napi_disable(&np->napi);
+
 	/*
 	 * FIXME: what if someone tries to close a device
 	 * that is suspended?
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 325269d..f650e94 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -880,6 +880,7 @@ struct netxen_adapter {
 	struct netxen_adapter *master;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
+	struct napi_struct napi;
 	struct net_device_stats net_stats;
 	unsigned char mac_addr[ETH_ALEN];
 	int mtu;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b703ccf..a065373 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -68,7 +68,7 @@ static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
 static int netxen_handle_int(struct netxen_adapter *, struct net_device *);
-static int netxen_nic_poll(struct net_device *dev, int *budget);
+static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
@@ -403,6 +403,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
 
+	adapter->napi.poll = netxen_nic_poll;
+	adapter->napi.weight = NETXEN_NETDEV_WEIGHT;
+
 	/* this will be read from FW later */
 	adapter->intr_scheme = -1;
 
@@ -423,8 +426,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-	netdev->poll = netxen_nic_poll;
-	netdev->weight = NETXEN_NETDEV_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = netxen_nic_poll_controller;
 #endif
@@ -929,6 +930,7 @@ static int netxen_nic_close(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+	napi_disable(&adapter->napi);
 
 	cmd_buff = adapter->cmd_buf_arr;
 	for (i = 0; i < adapter->max_tx_desc_count; i++) {
@@ -1266,11 +1268,11 @@ netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 	}
 
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
-		if (netif_rx_schedule_prep(netdev)) {
+		if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 			/*
 			 * Interrupts are already disabled.
 			 */
-			__netif_rx_schedule(netdev);
+			__netif_rx_schedule(netdev, &adapter->napi);
 		} else {
 			static unsigned int intcount = 0;
 			if ((++intcount & 0xfff) == 0xfff)
@@ -1312,14 +1314,13 @@ irqreturn_t netxen_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static int netxen_nic_poll(struct net_device *netdev, int *budget)
+static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
-	struct netxen_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
+	struct netxen_adapter *adapter = container_of(napi, struct netxen_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
 	int done = 1;
 	int ctx;
-	int this_work_done;
-	int work_done = 0;
+	int work_done;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
 
@@ -1337,16 +1338,11 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
 		 * packets are on one context, it gets only half of the quota,
 		 * and ends up not processing it.
 		 */
-		this_work_done = netxen_process_rcv_ring(adapter, ctx,
-							 work_to_do /
-							 MAX_RCV_CTX);
-		work_done += this_work_done;
+		work_done += netxen_process_rcv_ring(adapter, ctx,
+						     budget / MAX_RCV_CTX);
 	}
 
-	netdev->quota -= work_done;
-	*budget -= work_done;
-
-	if (work_done >= work_to_do && netxen_nic_rx_has_work(adapter) != 0)
+	if (work_done >= budget && netxen_nic_rx_has_work(adapter) != 0)
 		done = 0;
 
 	if (netxen_process_cmd_ring((unsigned long)adapter) == 0)
@@ -1355,11 +1351,11 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
 	DPRINTK(INFO, "new work_done: %d work_to_do: %d\n",
 		work_done, work_to_do);
 	if (done) {
-		netif_rx_complete(netdev);
+		netif_rx_complete(netdev, napi);
 		netxen_nic_enable_int(adapter);
 	}
 
-	return !done;
+	return work_done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 0b3066a..9552415 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -584,7 +584,7 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 	if (*mac->rx_status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
-	netif_rx_schedule(dev);
+	netif_rx_schedule(dev, &mac->napi);
 
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
@@ -808,7 +808,7 @@ static int pasemi_mac_open(struct net_device *dev)
 		dev_warn(&mac->pdev->dev, "phy init failed: %d\n", ret);
 
 	netif_start_queue(dev);
-	netif_poll_enable(dev);
+	napi_enable(&mac->napi);
 
 	/* Interrupts are a bit different for our DMA controller: While
 	 * it's got one a regular PCI device header, the interrupt there
@@ -869,6 +869,7 @@ static int pasemi_mac_close(struct net_device *dev)
 	}
 
 	netif_stop_queue(dev);
+	napi_disable(&mac->napi);
 
 	/* Clean out any pending buffers */
 	pasemi_mac_clean_tx(mac);
@@ -1047,26 +1048,20 @@ static void pasemi_mac_set_rx_mode(struct net_device *dev)
 }
 
 
-static int pasemi_mac_poll(struct net_device *dev, int *budget)
+static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 {
-	int pkts, limit = min(*budget, dev->quota);
-	struct pasemi_mac *mac = netdev_priv(dev);
-
-	pkts = pasemi_mac_clean_rx(mac, limit);
-
-	dev->quota -= pkts;
-	*budget -= pkts;
+	struct pasemi_mac *mac = container_of(napi, struct pasemi_mac, napi);
+	struct net_device *dev = mac->netdev;
+	int pkts;
 
-	if (pkts < limit) {
+	pkts = pasemi_mac_clean_rx(mac, budget);
+	if (pkts < budget) {
 		/* all done, no more packets present */
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 
 		pasemi_mac_restart_rx_intr(mac);
-		return 0;
-	} else {
-		/* used up our quantum, so reschedule */
-		return 1;
 	}
+	return pkts;
 }
 
 static int __devinit
@@ -1099,6 +1094,9 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mac->netdev = dev;
 	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
 
+	mac->napi.poll = pasemi_mac_poll;
+	mac->napi.features = NETIF_F_HW_CSUM;
+
 	if (!mac->dma_pdev) {
 		dev_err(&pdev->dev, "Can't find DMA Controller\n");
 		err = -ENODEV;
@@ -1151,8 +1149,6 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->get_stats = pasemi_mac_get_stats;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->weight = 64;
-	dev->poll = pasemi_mac_poll;
-	dev->features = NETIF_F_HW_CSUM;
 
 	/* The dma status structure is located in the I/O bridge, and
 	 * is cache coherent.
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index c29ee15..85d3b78 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -56,6 +56,7 @@ struct pasemi_mac {
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
 	struct phy_device *phydev;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 
 	/* Pointer to the cacheable per-channel status registers */
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 465485a..44d9181 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -280,6 +280,8 @@ struct pcnet32_private {
 	unsigned int		dirty_rx,	/* ring entries to be freed. */
 				dirty_tx;
 
+	struct net_device	*dev;
+	struct napi_struct	napi;
 	struct net_device_stats	stats;
 	char			tx_full;
 	char			phycount;	/* number of phys found */
@@ -440,15 +442,17 @@ static struct pcnet32_access pcnet32_dwio = {
 
 static void pcnet32_netif_stop(struct net_device *dev)
 {
+	struct pcnet32_private *lp = netdev_priv(dev);
 	dev->trans_start = jiffies;
-	netif_poll_disable(dev);
+	napi_disable(&lp->napi);
 	netif_tx_disable(dev);
 }
 
 static void pcnet32_netif_start(struct net_device *dev)
 {
+	struct pcnet32_private *lp = netdev_priv(dev);
 	netif_wake_queue(dev);
-	netif_poll_enable(dev);
+	napi_enable(&lp->napi);
 }
 
 /*
@@ -816,7 +820,7 @@ static int pcnet32_set_ringparam(struct net_device *dev,
 	if ((1 << i) != lp->rx_ring_size)
 		pcnet32_realloc_rx_ring(dev, lp, i);
 
-	dev->weight = lp->rx_ring_size / 2;
+	lp->napi.weight = lp->rx_ring_size / 2;
 
 	if (netif_running(dev)) {
 		pcnet32_netif_start(dev);
@@ -1255,7 +1259,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	return;
 }
 
-static int pcnet32_rx(struct net_device *dev, int quota)
+static int pcnet32_rx(struct net_device *dev, int budget)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & lp->rx_mod_mask;
@@ -1263,7 +1267,7 @@ static int pcnet32_rx(struct net_device *dev, int quota)
 	int npackets = 0;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+	while (npackets < budget && (short)le16_to_cpu(rxp->status) >= 0) {
 		pcnet32_rx_entry(dev, lp, rxp, entry);
 		npackets += 1;
 		/*
@@ -1379,15 +1383,16 @@ static int pcnet32_tx(struct net_device *dev)
 }
 
 #ifdef CONFIG_PCNET32_NAPI
-static int pcnet32_poll(struct net_device *dev, int *budget)
+static int pcnet32_poll(struct napi_struct *napi, int budget)
 {
-	struct pcnet32_private *lp = netdev_priv(dev);
-	int quota = min(dev->quota, *budget);
+	struct pcnet32_private *lp = container_of(napi, struct pcnet32_private, napi);
+	struct net_device *dev = lp->dev;
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
+	int work_done;
 	u16 val;
 
-	quota = pcnet32_rx(dev, quota);
+	work_done = pcnet32_rx(dev, budget);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	if (pcnet32_tx(dev)) {
@@ -1399,28 +1404,22 @@ static int pcnet32_poll(struct net_device *dev, int *budget)
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	*budget -= quota;
-	dev->quota -= quota;
-
-	if (dev->quota == 0) {
-		return 1;
-	}
-
-	netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 
-	spin_lock_irqsave(&lp->lock, flags);
-
-	/* clear interrupt masks */
-	val = lp->a.read_csr(ioaddr, CSR3);
-	val &= 0x00ff;
-	lp->a.write_csr(ioaddr, CSR3, val);
+		spin_lock_irqsave(&lp->lock, flags);
 
-	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
-	mmiowb();
-	spin_unlock_irqrestore(&lp->lock, flags);
+		/* clear interrupt masks */
+		val = lp->a.read_csr(ioaddr, CSR3);
+		val &= 0x00ff;
+		lp->a.write_csr(ioaddr, CSR3, val);
 
-	return 0;
+		/* Set interrupt enable. */
+		lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
+		mmiowb();
+		spin_unlock_irqrestore(&lp->lock, flags);
+	}
+	return work_done;
 }
 #endif
 
@@ -1816,6 +1815,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	}
 	lp->pci_dev = pdev;
 
+	lp->dev = dev;
+
 	spin_lock_init(&lp->lock);
 
 	SET_MODULE_OWNER(dev);
@@ -1844,6 +1845,11 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	lp->mii_if.mdio_read = mdio_read;
 	lp->mii_if.mdio_write = mdio_write;
 
+	lp->napi.weight = lp->rx_ring_size / 2;
+#ifdef CONFIG_PCNET32_NAPI
+	lp->napi.poll = pcnet32_poll;
+#endif
+
 	if (fdx && !(lp->options & PCNET32_PORT_ASEL) &&
 	    ((cards_found >= MAX_UNITS) || full_duplex[cards_found]))
 		lp->options |= PCNET32_PORT_FD;
@@ -1954,10 +1960,6 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
-	dev->weight = lp->rx_ring_size / 2;
-#ifdef CONFIG_PCNET32_NAPI
-	dev->poll = pcnet32_poll;
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = pcnet32_poll_controller;
@@ -2600,18 +2602,18 @@ pcnet32_interrupt(int irq, void *dev_id)
 			/* unlike for the lance, there is no restart needed */
 		}
 #ifdef CONFIG_PCNET32_NAPI
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
 			val = lp->a.read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
 			mmiowb();
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &lp->napi);
 			break;
 		}
 #else
-		pcnet32_rx(dev, dev->weight);
+		pcnet32_rx(dev, dev->napi.weight);
 		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
@@ -2646,6 +2648,7 @@ static int pcnet32_close(struct net_device *dev)
 	del_timer_sync(&lp->watchdog_timer);
 
 	netif_stop_queue(dev);
+	napi_disable(&lp->napi);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 08d2506..a974d32 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -552,7 +552,7 @@ static int gelic_net_stop(struct net_device *netdev)
 {
 	struct gelic_net_card *card = netdev_priv(netdev);
 
-	netif_poll_disable(netdev);
+	napi_disable(&card->napi);
 	netif_stop_queue(netdev);
 
 	/* turn off DMA, force end */
@@ -941,32 +941,24 @@ refill:
  * if the quota is exceeded, but the driver has still packets.
  *
  */
-static int gelic_net_poll(struct net_device *netdev, int *budget)
+static int gelic_net_poll(struct napi_struct *napi, int budget)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-	int packets_to_do, packets_done = 0;
-	int no_more_packets = 0;
-
-	packets_to_do = min(*budget, netdev->quota);
+	struct gelic_net_card *card = container_of(napi, struct gelic_net_card, napi);
+	struct net_device *netdev = card->netdev;
+	int packets_done = 0;
 
-	while (packets_to_do) {
-		if (gelic_net_decode_one_descr(card)) {
-			packets_done++;
-			packets_to_do--;
-		} else {
-			/* no more packets for the stack */
-			no_more_packets = 1;
+	while (packets_done < budget) {
+		if (!gelic_net_decode_one_descr(card))
 			break;
-		}
+
+		packets_done++;
 	}
-	netdev->quota -= packets_done;
-	*budget -= packets_done;
-	if (no_more_packets) {
-		netif_rx_complete(netdev);
+
+	if (packets_done < budget) {
+		netif_rx_complete(netdev, napi);
 		gelic_net_rx_irq_on(card);
-		return 0;
-	} else
-		return 1;
+	}
+	return packets_done;
 }
 
 /**
@@ -1018,7 +1010,7 @@ static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
 
 	if (status & GELIC_NET_RXINT) {
 		gelic_net_rx_irq_off(card);
-		netif_rx_schedule(netdev);
+		netif_rx_schedule(netdev, &card->napi);
 	}
 
 	if (status & GELIC_NET_TXINT) {
@@ -1129,7 +1121,7 @@ static int gelic_net_open(struct net_device *netdev)
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
+	napi_enable(&card->napi);
 
 	return 0;
 
@@ -1326,9 +1318,6 @@ static void gelic_net_setup_netdev_ops(struct net_device *netdev)
 	/* tx watchdog */
 	netdev->tx_timeout = &gelic_net_tx_timeout;
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
-	/* NAPI */
-	netdev->poll = &gelic_net_poll;
-	netdev->weight = GELIC_NET_NAPI_WEIGHT;
 #ifdef GELIC_NET_ETHTOOL
 	netdev->ethtool_ops = &gelic_net_ethtool_ops;
 #endif
@@ -1358,6 +1347,10 @@ static int gelic_net_setup_netdev(struct gelic_net_card *card)
 
 	gelic_net_setup_netdev_ops(netdev);
 
+	/* NAPI */
+	card->napi.poll = &gelic_net_poll;
+	card->napi.weight = GELIC_NET_NAPI_WEIGHT;
+
 	netdev->features = NETIF_F_IP_CSUM;
 
 	status = lv1_net_control(bus_id(card), dev_id(card),
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
index 5e1c286..9d0316f 100644
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -202,6 +202,7 @@ struct gelic_net_descr_chain {
 
 struct gelic_net_card {
 	struct net_device *netdev;
+	struct napi_struct napi;
 	/*
 	 * hypervisor requires irq_status should be
 	 * 8 bytes aligned, but u64 member is
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 8be8be4..062c7c5 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2304,10 +2304,10 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 	return work_done;
 }
 
-static int ql_poll(struct net_device *ndev, int *budget)
+static int ql_poll(struct napi_struct *napi, int budget)
 {
-	struct ql3_adapter *qdev = netdev_priv(ndev);
-	int work_to_do = min(*budget, ndev->quota);
+	struct ql3_adapter *qdev = container_of(napi, struct ql3_adapter, napi);
+	struct net_device *ndev = qdev->ndev;
 	int rx_cleaned = 0, tx_cleaned = 0;
 	unsigned long hw_flags;
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
@@ -2315,14 +2315,12 @@ static int ql_poll(struct net_device *ndev, int *budget)
 	if (!netif_carrier_ok(ndev))
 		goto quit_polling;
 
-	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, work_to_do);
-	*budget -= rx_cleaned;
-	ndev->quota -= rx_cleaned;
+	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, budget);
 
-	if( tx_cleaned + rx_cleaned != work_to_do ||
+	if (tx_cleaned + rx_cleaned != budget ||
 	    !netif_running(ndev)) {
 quit_polling:
-		netif_rx_complete(ndev);
+		netif_rx_complete(ndev, napi);
 
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		ql_update_small_bufq_prod_index(qdev);
@@ -2332,9 +2330,8 @@ quit_polling:
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
 		ql_enable_interrupts(qdev);
-		return 0;
 	}
-	return 1;
+	return tx_cleaned + rx_cleaned;
 }
 
 static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
@@ -2384,8 +2381,8 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(ndev))) {
-			__netif_rx_schedule(ndev);
+		if (likely(netif_rx_schedule_prep(ndev, &qdev->napi))) {
+			__netif_rx_schedule(ndev, &qdev->napi);
 		}
 	} else {
 		return IRQ_NONE;
@@ -3611,7 +3608,7 @@ static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
 
 	del_timer_sync(&qdev->adapter_timer);
 
-	netif_poll_disable(ndev);
+	napi_disable(&qdev->napi);
 
 	if (do_reset) {
 		int soft_reset;
@@ -3699,7 +3696,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 
 	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 
-	netif_poll_enable(ndev);
+	napi_enable(&qdev->napi);
 	ql_enable_interrupts(qdev);
 	return 0;
 
@@ -4055,8 +4052,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->tx_timeout = ql3xxx_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
 
-	ndev->poll = &ql_poll;
-	ndev->weight = 64;
+	qdev->napi.poll = &ql_poll;
+	qdev->napi.weight = 64;
 
 	ndev->irq = pdev->irq;
 
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 4a832c4..aa2216f 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1175,6 +1175,8 @@ struct ql3_adapter {
 	struct pci_dev *pdev;
 	struct net_device *ndev;	/* Parent NET device */
 
+	struct napi_struct napi;
+
 	/* Hardware information */
 	u8 chip_rev_id;
 	u8 pci_slot;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bb6896a..2fb45df 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -384,6 +384,7 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
@@ -443,13 +444,13 @@ static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
-				void __iomem *);
+				void __iomem *, u32 budget);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 
 #ifdef CONFIG_R8169_NAPI
-static int rtl8169_poll(struct net_device *dev, int *budget);
+static int rtl8169_poll(struct napi_struct *napi, int budget);
 #endif
 
 static const unsigned int rtl8169_rx_config =
@@ -1648,8 +1649,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->set_mac_address = rtl_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
-	dev->poll = rtl8169_poll;
-	dev->weight = R8169_NAPI_WEIGHT;
+	tp->napi.poll = rtl8169_poll;
+	tp->napi.weight = R8169_NAPI_WEIGHT;
 #endif
 
 #ifdef CONFIG_R8169_VLAN
@@ -2064,7 +2065,7 @@ static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 	if (ret < 0)
 		goto out;
 
-	netif_poll_enable(dev);
+	napi_enable(&tp->napi);
 
 	rtl_hw_start(dev);
 
@@ -2256,11 +2257,11 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-	netif_poll_disable(dev);
+	napi_disable(&tp->napi);
 
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	netif_poll_enable(dev);
+	napi_enable(&tp->napi);
 }
 
 static void rtl8169_reinit_task(struct work_struct *work)
@@ -2304,7 +2305,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_wait_for_quiescence(dev);
 
-	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr);
+	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
 	rtl8169_tx_clear(tp);
 
 	if (tp->dirty_rx == tp->cur_rx) {
@@ -2609,14 +2610,14 @@ out:
 
 static int rtl8169_rx_interrupt(struct net_device *dev,
 				struct rtl8169_private *tp,
-				void __iomem *ioaddr)
+				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int delta, count;
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
+	rx_left = rtl8169_rx_quota(rx_left, budget);
 
 	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
@@ -2764,8 +2765,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 		tp->intr_mask = ~tp->napi_event;
 
-		if (likely(netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
+		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
+			__netif_rx_schedule(dev, &tp->napi);
 		else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
 			       dev->name, status);
@@ -2774,7 +2775,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 #else
 		/* Rx interrupt */
 		if (status & (RxOK | RxOverflow | RxFIFOOver))
-			rtl8169_rx_interrupt(dev, tp, ioaddr);
+			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
 
 		/* Tx interrupt */
 		if (status & (TxOK | TxErr))
@@ -2797,20 +2798,18 @@ out:
 }
 
 #ifdef CONFIG_R8169_NAPI
-static int rtl8169_poll(struct net_device *dev, int *budget)
+static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
-	unsigned int work_done, work_to_do = min(*budget, dev->quota);
-	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
+	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->mmio_addr;
+	int work_done;
 
-	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
+	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done < work_to_do) {
-		netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 		tp->intr_mask = 0xffff;
 		/*
 		 * 20040426: the barrier is not strictly required but the
@@ -2822,7 +2821,7 @@ static int rtl8169_poll(struct net_device *dev, int *budget)
 		RTL_W16(IntrMask, tp->intr_event);
 	}
 
-	return (work_done >= work_to_do);
+	return work_done;
 }
 #endif
 
@@ -2851,7 +2850,7 @@ core_down:
 	synchronize_irq(dev->irq);
 
 	if (!poll_locked) {
-		netif_poll_disable(dev);
+		napi_disable(&tp->napi);
 		poll_locked++;
 	}
 
@@ -2889,7 +2888,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(dev->irq, dev);
 
-	netif_poll_enable(dev);
+	napi_disable(&tp->napi);
 
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index afef6c0..8ff32b3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2604,7 +2604,7 @@ static void free_rx_buffers(struct s2io_nic *sp)
 
 /**
  * s2io_poll - Rx interrupt handler for NAPI support
- * @dev : pointer to the device structure.
+ * @napi : pointer to the napi structure.
  * @budget : The number of packets that were budgeted to be processed
  * during  one pass through the 'Poll" function.
  * Description:
@@ -2615,9 +2615,10 @@ static void free_rx_buffers(struct s2io_nic *sp)
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-static int s2io_poll(struct net_device *dev, int *budget)
+static int s2io_poll(struct napi_struct *napi, int budget)
 {
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
+	struct net_device *dev = nic->dev;
 	int pkt_cnt = 0, org_pkts_to_process;
 	struct mac_info *mac_control;
 	struct config_param *config;
@@ -2628,9 +2629,7 @@ static int s2io_poll(struct net_device *dev, int *budget)
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	nic->pkts_to_process = *budget;
-	if (nic->pkts_to_process > dev->quota)
-		nic->pkts_to_process = dev->quota;
+	nic->pkts_to_process = budget;
 	org_pkts_to_process = nic->pkts_to_process;
 
 	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
@@ -2644,12 +2643,8 @@ static int s2io_poll(struct net_device *dev, int *budget)
 			goto no_rx;
 		}
 	}
-	if (!pkt_cnt)
-		pkt_cnt = 1;
 
-	dev->quota -= pkt_cnt;
-	*budget -= pkt_cnt;
-	netif_rx_complete(dev);
+	netif_rx_complete(dev, napi);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
@@ -2662,12 +2657,9 @@ static int s2io_poll(struct net_device *dev, int *budget)
 	writeq(0x0, &bar0->rx_traffic_mask);
 	readl(&bar0->rx_traffic_mask);
 	atomic_dec(&nic->isr_cnt);
-	return 0;
+	return pkt_cnt;
 
 no_rx:
-	dev->quota -= pkt_cnt;
-	*budget -= pkt_cnt;
-
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(nic, i) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
@@ -2676,7 +2668,7 @@ no_rx:
 		}
 	}
 	atomic_dec(&nic->isr_cnt);
-	return 1;
+	return pkt_cnt;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3969,6 +3961,7 @@ static int s2io_close(struct net_device *dev)
 	struct s2io_nic *sp = dev->priv;
 
 	netif_stop_queue(dev);
+	napi_disable(&sp->napi);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
@@ -4358,8 +4351,8 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 
 	if (napi) {
 		if (reason & GEN_INTR_RXTRAFFIC) {
-			if ( likely ( netif_rx_schedule_prep(dev)) ) {
-				__netif_rx_schedule(dev);
+			if (likely (netif_rx_schedule_prep(dev, &sp->napi))) {
+				__netif_rx_schedule(dev, &sp->napi);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
 			}
 			else
@@ -7415,8 +7408,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-	dev->poll = s2io_poll;
-	dev->weight = 32;
+	sp->napi.poll = s2io_poll;
+	sp->napi.weight = 32;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = s2io_netpoll;
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 3887fe6..201286b 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -782,6 +782,7 @@ struct s2io_nic {
 	 */
 	int pkts_to_process;
 	struct net_device *dev;
+	struct napi_struct napi;
 	struct mac_info mac_control;
 	struct config_param config;
 	struct pci_dev *pdev;
@@ -1016,7 +1017,7 @@ static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
 static void s2io_reset(struct s2io_nic * sp);
-static int s2io_poll(struct net_device *dev, int *budget);
+static int s2io_poll(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index e7fdcf1..b544515 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -238,6 +238,7 @@ struct sbmac_softc {
 	 */
 
 	struct net_device *sbm_dev;		/* pointer to linux device */
+	struct napi_struct napi;
 	spinlock_t sbm_lock;		/* spin lock */
 	struct timer_list sbm_timer;     	/* for monitoring MII */
 	struct net_device_stats sbm_stats;
@@ -320,7 +321,7 @@ static struct net_device_stats *sbmac_get_stats(struct net_device *dev);
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
-static int sbmac_poll(struct net_device *poll_dev, int *budget);
+static int sbmac_poll(struct napi_struct *napi, int budget);
 
 static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
 static int sbmac_mii_probe(struct net_device *dev);
@@ -2165,9 +2166,9 @@ static irqreturn_t sbmac_intr(int irq,void *dev_instance)
 	}
 
 	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-		if (netif_rx_schedule_prep(dev)) {
+		if (netif_rx_schedule_prep(dev, &sc->napi)) {
 			__raw_writeq(0, sc->sbm_imr);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &sc->napi);
 			/* Depend on the exit from poll to reenable intr */
 		}
 		else {
@@ -2470,8 +2471,8 @@ static int sbmac_init(struct net_device *dev, int idx)
 	dev->do_ioctl           = sbmac_mii_ioctl;
 	dev->tx_timeout         = sbmac_tx_timeout;
 	dev->watchdog_timeo     = TX_TIMEOUT;
-	dev->poll               = sbmac_poll;
-	dev->weight             = 16;
+	sc->napi.poll           = sbmac_poll;
+	sc->napi.weight         = 16;
 
 	dev->change_mtu         = sb1250_change_mtu;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2850,6 +2851,8 @@ static int sbmac_close(struct net_device *dev)
 	unsigned long flags;
 	int irq;
 
+	napi_disable(&sc->napi);
+
 	sbmac_set_channel_state(sc,sbmac_state_off);
 
 	del_timer_sync(&sc->sbm_timer);
@@ -2874,26 +2877,17 @@ static int sbmac_close(struct net_device *dev)
 	return 0;
 }
 
-static int sbmac_poll(struct net_device *dev, int *budget)
+static int sbmac_poll(struct napi_struct *napi, int budget)
 {
-	int work_to_do;
+	struct sbmac_softc *sc = container_of(napi, struct sbmac_softc, napi);
+	struct net_device *dev = sc->sbm_dev;
 	int work_done;
-	struct sbmac_softc *sc = netdev_priv(dev);
-
-	work_to_do = min(*budget, dev->quota);
-	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), work_to_do, 1);
-
-	if (work_done > work_to_do)
-		printk(KERN_ERR "%s exceeded work_to_do budget=%d quota=%d work-done=%d\n",
-		       sc->sbm_dev->name, *budget, dev->quota, work_done);
 
+	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), budget, 1);
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done < work_to_do) {
-		netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 
 #ifdef CONFIG_SBMAC_COALESCE
 		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
@@ -2905,7 +2899,7 @@ static int sbmac_poll(struct net_device *dev, int *budget)
 #endif
 	}
 
-	return (work_done >= work_to_do);
+	return work_done;
 }
 
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 7766929..563258b 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2529,7 +2529,7 @@ static int skge_up(struct net_device *dev)
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	spin_unlock_irq(&hw->hw_lock);
 
-	netif_poll_enable(dev);
+	napi_enable(&skge->napi);
 	return 0;
 
  free_rx_ring:
@@ -2559,7 +2559,7 @@ static int skge_down(struct net_device *dev)
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		del_timer_sync(&skge->link_timer);
 
-	netif_poll_disable(dev);
+	napi_disable(&skge->napi);
 	netif_carrier_off(dev);
 
 	spin_lock_irq(&hw->hw_lock);
@@ -3045,14 +3045,13 @@ static void skge_tx_done(struct net_device *dev)
 	}
 }
 
-static int skge_poll(struct net_device *dev, int *budget)
+static int skge_poll(struct napi_struct *napi, int to_do)
 {
-	struct skge_port *skge = netdev_priv(dev);
+	struct skge_port *skge = container_of(napi, struct skge_port, napi);
+	struct net_device *dev = skge->netdev;
 	struct skge_hw *hw = skge->hw;
 	struct skge_ring *ring = &skge->rx_ring;
 	struct skge_element *e;
-	unsigned long flags;
-	int to_do = min(dev->quota, *budget);
 	int work_done = 0;
 
 	skge_tx_done(dev);
@@ -3083,20 +3082,16 @@ static int skge_poll(struct net_device *dev, int *budget)
 	wmb();
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_START);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done >=  to_do)
-		return 1; /* not done */
-
-	spin_lock_irqsave(&hw->hw_lock, flags);
-	__netif_rx_complete(dev);
-	hw->intr_mask |= napimask[skge->port];
-  	skge_write32(hw, B0_IMSK, hw->intr_mask);
-	skge_read32(hw, B0_IMSK);
-	spin_unlock_irqrestore(&hw->hw_lock, flags);
+	if (work_done < to_do) {
+		spin_lock_irq(&hw->hw_lock);
+		__netif_rx_complete(dev, napi);
+		hw->intr_mask |= napimask[skge->port];
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
+		skge_read32(hw, B0_IMSK);
+		spin_unlock_irq(&hw->hw_lock);
+	}
 
-	return 0;
+	return work_done;
 }
 
 /* Parity errors seem to happen when Genesis is connected to a switch
@@ -3253,8 +3248,9 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 	}
 
 	if (status & (IS_XA1_F|IS_R1_F)) {
+		struct skge_port *skge = netdev_priv(hw->dev[0]);
 		hw->intr_mask &= ~(IS_XA1_F|IS_R1_F);
-		netif_rx_schedule(hw->dev[0]);
+		netif_rx_schedule(hw->dev[0], &skge->napi);
 	}
 
 	if (status & IS_PA_TO_TX1)
@@ -3272,13 +3268,14 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 		skge_mac_intr(hw, 0);
 
 	if (hw->dev[1]) {
+		struct skge_port *skge = netdev_priv(hw->dev[1]);
+
 		if (status & (IS_XA2_F|IS_R2_F)) {
 			hw->intr_mask &= ~(IS_XA2_F|IS_R2_F);
-			netif_rx_schedule(hw->dev[1]);
+			netif_rx_schedule(hw->dev[1], &skge->napi);
 		}
 
 		if (status & IS_PA_TO_RX2) {
-			struct skge_port *skge = netdev_priv(hw->dev[1]);
 			++skge->net_stats.rx_over_errors;
 			skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_RX2);
 		}
@@ -3570,8 +3567,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	SET_ETHTOOL_OPS(dev, &skge_ethtool_ops);
 	dev->tx_timeout = skge_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
-	dev->poll = skge_poll;
-	dev->weight = NAPI_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = skge_netpoll;
 #endif
@@ -3581,6 +3576,8 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 		dev->features |= NETIF_F_HIGHDMA;
 
 	skge = netdev_priv(dev);
+	skge->napi.poll = skge_poll;
+	skge->napi.weight = NAPI_WEIGHT;
 	skge->netdev = dev;
 	skge->hw = hw;
 	skge->msg_enable = netif_msg_init(debug, default_msg);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index edd7146..dd0fd45 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -2448,6 +2448,7 @@ enum pause_status {
 struct skge_port {
 	struct skge_hw	     *hw;
 	struct net_device    *netdev;
+	struct napi_struct   napi;
 	int		     port;
 	u32		     msg_enable;
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 13f08a3..78a3e55 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1078,7 +1078,7 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 	u16 port = sky2->port;
 
 	netif_tx_lock_bh(dev);
-	netif_poll_disable(sky2->hw->dev[0]);
+	napi_disable(&hw->napi);
 
 	sky2->vlgrp = grp;
 	if (grp) {
@@ -1093,7 +1093,7 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 			     TX_VLAN_TAG_OFF);
 	}
 
-	netif_poll_enable(sky2->hw->dev[0]);
+	napi_enable(&hw->napi);
 	netif_tx_unlock_bh(dev);
 }
 #endif
@@ -1622,6 +1622,8 @@ static int sky2_down(struct net_device *dev)
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
+	napi_disable(&hw->napi);
+
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
@@ -1956,7 +1958,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	dev->trans_start = jiffies;	/* prevent tx timeout */
 	netif_stop_queue(dev);
-	netif_poll_disable(hw->dev[0]);
+	napi_disable(&hw->napi);
 
 	synchronize_irq(hw->pdev->irq);
 
@@ -1988,7 +1990,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	else {
 		gma_write16(hw, port, GM_GP_CTRL, ctl);
 
-		netif_poll_enable(hw->dev[0]);
+		napi_enable(&hw->napi);
 		netif_wake_queue(dev);
 	}
 
@@ -2434,10 +2436,8 @@ static inline void sky2_idle_start(struct sky2_hw *hw)
 static void sky2_idle(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
-	struct net_device *dev = hw->dev[0];
 
-	if (__netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	napi_schedule(&hw->napi);
 
 	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
@@ -2470,11 +2470,11 @@ static void sky2_err_intr(struct sky2_hw *hw, u32 status)
 		sky2_le_error(hw, 1, Q_XA2, TX_RING_SIZE);
 }
 
-static int sky2_poll(struct net_device *dev0, int *budget)
+static int sky2_poll(struct napi_struct *napi, int work_limit)
 {
-	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_done;
+	struct sky2_hw *hw = container_of(napi, struct sky2_hw, napi);
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
+	int work_done;
 
 	if (unlikely(status & Y2_IS_ERROR))
 		sky2_err_intr(hw, status);
@@ -2485,31 +2485,27 @@ static int sky2_poll(struct net_device *dev0, int *budget)
 	if (status & Y2_IS_IRQ_PHY2)
 		sky2_phy_intr(hw, 1);
 
-	work_done = sky2_status_intr(hw, min(dev0->quota, *budget));
-	*budget -= work_done;
-	dev0->quota -= work_done;
+	work_done = sky2_status_intr(hw, work_limit);
 
 	/* More work? */
- 	if (hw->st_idx != sky2_read16(hw, STAT_PUT_IDX))
-		return 1;
+ 	if (hw->st_idx == sky2_read16(hw, STAT_PUT_IDX)) {
+		/* Bug/Errata workaround?
+		 * Need to kick the TX irq moderation timer.
+		 */
+		if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
+			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
+			sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
+		}
 
-	/* Bug/Errata workaround?
-	 * Need to kick the TX irq moderation timer.
-	 */
-	if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
+		napi_complete(napi);
+		sky2_read32(hw, B0_Y2_SP_LISR);
 	}
-	netif_rx_complete(dev0);
-
-	sky2_read32(hw, B0_Y2_SP_LISR);
-	return 0;
+	return work_done;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)
 {
 	struct sky2_hw *hw = dev_id;
-	struct net_device *dev0 = hw->dev[0];
 	u32 status;
 
 	/* Reading this mask interrupts as side effect */
@@ -2518,8 +2514,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	prefetch(&hw->st_le[hw->st_idx]);
-	if (likely(__netif_rx_schedule_prep(dev0)))
-		__netif_rx_schedule(dev0);
+	
+	napi_schedule(&hw->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2528,10 +2524,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 static void sky2_netpoll(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct net_device *dev0 = sky2->hw->dev[0];
 
-	if (netif_running(dev) && __netif_rx_schedule_prep(dev0))
-		__netif_rx_schedule(dev0);
+	napi_schedule(&sky2->hw->napi);
 }
 #endif
 
@@ -2733,7 +2727,7 @@ static void sky2_restart(struct work_struct *work)
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
 
-	netif_poll_disable(hw->dev[0]);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -2743,7 +2737,7 @@ static void sky2_restart(struct work_struct *work)
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
-	netif_poll_enable(hw->dev[0]);
+	napi_enable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
@@ -3572,7 +3566,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 		   sky2_read32(hw, B0_IMSK),
 		   sky2_read32(hw, B0_Y2_SP_ICR));
 
-	netif_poll_disable(hw->dev[0]);
+	napi_disable(&hw->napi);
 	last = sky2_read16(hw, STAT_PUT_IDX);
 
 	if (hw->st_idx == last)
@@ -3642,7 +3636,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
 		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
 
-	netif_poll_enable(hw->dev[0]);
+	napi_enable(&hw->napi);
 	return 0;
 }
 
@@ -3767,16 +3761,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
 	dev->tx_timeout = sky2_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
-	if (port == 0)
-		dev->poll = sky2_poll;
-	dev->weight = NAPI_WEIGHT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	/* Network console (only works on port 0)
-	 * because netpoll makes assumptions about NAPI
-	 */
-	if (port == 0)
-		dev->poll_controller = sky2_netpoll;
-#endif
 
 	sky2 = netdev_priv(dev);
 	sky2->netdev = dev;
@@ -3945,6 +3929,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
+	hw->napi.poll = sky2_poll;
+	hw->napi.weight = NAPI_WEIGHT;
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -4110,7 +4096,7 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 		return 0;
 
 	del_timer_sync(&hw->idle_timer);
-	netif_poll_disable(hw->dev[0]);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
@@ -4174,7 +4160,7 @@ static int sky2_resume(struct pci_dev *pdev)
 		}
 	}
 
-	netif_poll_enable(hw->dev[0]);
+	napi_enable(&hw->napi);
 	sky2_idle_start(hw);
 	return 0;
 out:
@@ -4193,7 +4179,7 @@ static void sky2_shutdown(struct pci_dev *pdev)
 		return;
 
 	del_timer_sync(&hw->idle_timer);
-	netif_poll_disable(hw->dev[0]);
+	napi_disable(&hw->napi);
 
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index dce4d27..8d6a260 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2039,6 +2039,7 @@ struct sky2_port {
 struct sky2_hw {
 	void __iomem  	     *regs;
 	struct pci_dev	     *pdev;
+	struct napi_struct   napi;
 	struct net_device    *dev[2];
 
 	u8	     	     chip_id;
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 590b12c..0a43316 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1278,34 +1278,26 @@ bad_desc:
  * (using netif_receive_skb). If all/enough packets are up, the driver
  * reenables interrupts and returns 0. If not, 1 is returned.
  */
-static int
-spider_net_poll(struct net_device *netdev, int *budget)
+static int spider_net_poll(struct napi_struct *napi, int budget)
 {
-	struct spider_net_card *card = netdev_priv(netdev);
-	int packets_to_do, packets_done = 0;
-	int no_more_packets = 0;
-
-	packets_to_do = min(*budget, netdev->quota);
-
-	while (packets_to_do) {
-		if (spider_net_decode_one_descr(card)) {
-			packets_done++;
-			packets_to_do--;
-		} else {
-			/* no more packets for the stack */
-			no_more_packets = 1;
+	struct spider_net_card *card = container_of(napi, struct spider_net_card, napi);
+	struct net_device *netdev = card->netdev;
+	int packets_done = 0;
+
+	while (packets_done < budget) {
+		if (!spider_net_decode_one_descr(card))
 			break;
-		}
+
+		packets_done++;
 	}
 
 	if ((packets_done == 0) && (card->num_rx_ints != 0)) {
-		no_more_packets = spider_net_resync_tail_ptr(card);
+		if (!spider_net_resync_tail_ptr(card))
+			packets_done = budget;
 		spider_net_resync_head_ptr(card);
 	}
 	card->num_rx_ints = 0;
 
-	netdev->quota -= packets_done;
-	*budget -= packets_done;
 	spider_net_refill_rx_chain(card);
 	spider_net_enable_rxdmac(card);
 
@@ -1313,14 +1305,13 @@ spider_net_poll(struct net_device *netdev, int *budget)
 
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
-	if (no_more_packets) {
-		netif_rx_complete(netdev);
+	if (packets_done < budget) {
+		netif_rx_complete(netdev, napi);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull = 0;
-		return 0;
 	}
 
-	return 1;
+	return packets_done;
 }
 
 /**
@@ -1563,7 +1554,8 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 			spider_net_refill_rx_chain(card);
 			spider_net_enable_rxdmac(card);
 			card->num_rx_ints ++;
-			netif_rx_schedule(card->netdev);
+			netif_rx_schedule(card->netdev,
+					  &card->napi);
 		}
 		show_error = 0;
 		break;
@@ -1583,7 +1575,8 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev);
+		netif_rx_schedule(card->netdev,
+				  &card->napi);
 		show_error = 0;
 		break;
 
@@ -1597,7 +1590,8 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev);
+		netif_rx_schedule(card->netdev,
+				  &card->napi);
 		show_error = 0;
 		break;
 
@@ -1690,11 +1684,11 @@ spider_net_interrupt(int irq, void *ptr)
 
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
-		netif_rx_schedule(netdev);
+		netif_rx_schedule(netdev, &card->napi);
 		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
-		netif_rx_schedule(netdev);
+		netif_rx_schedule(netdev, &card->napi);
 
 	if (status_reg & SPIDER_NET_LINKINT)
 		spider_net_link_reset(netdev);
@@ -2038,7 +2032,7 @@ spider_net_open(struct net_device *netdev)
 
 	netif_start_queue(netdev);
 	netif_carrier_on(netdev);
-	netif_poll_enable(netdev);
+	napi_enable(&card->napi);
 
 	spider_net_enable_interrupts(card);
 
@@ -2208,7 +2202,7 @@ spider_net_stop(struct net_device *netdev)
 {
 	struct spider_net_card *card = netdev_priv(netdev);
 
-	netif_poll_disable(netdev);
+	napi_disable(&card->napi);
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 	del_timer_sync(&card->tx_timer);
@@ -2308,9 +2302,6 @@ spider_net_setup_netdev_ops(struct net_device *netdev)
 	/* tx watchdog */
 	netdev->tx_timeout = &spider_net_tx_timeout;
 	netdev->watchdog_timeo = SPIDER_NET_WATCHDOG_TIMEOUT;
-	/* NAPI */
-	netdev->poll = &spider_net_poll;
-	netdev->weight = SPIDER_NET_NAPI_WEIGHT;
 	/* HW VLAN */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* poll controller */
@@ -2355,6 +2346,10 @@ spider_net_setup_netdev(struct spider_net_card *card)
 
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
+	/* NAPI */
+	card->napi.poll = &spider_net_poll;
+	card->napi.weight = SPIDER_NET_NAPI_WEIGHT;
+
 	spider_net_setup_netdev_ops(netdev);
 
 	netdev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX;
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index dbbdb8c..a2fcdeb 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -466,6 +466,8 @@ struct spider_net_card {
 	struct pci_dev *pdev;
 	struct mii_phy phy;
 
+	struct napi_struct napi;
+
 	int medium;
 
 	void __iomem *regs;
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 8b64786..9df5928 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -178,16 +178,16 @@ static int full_duplex[MAX_UNITS] = {0, };
 #define skb_num_frags(skb) (skb_shinfo(skb)->nr_frags + 1)
 
 #ifdef HAVE_NETDEV_POLL
-#define init_poll(dev) \
+#define init_poll(np) \
 do { \
-	dev->poll = &netdev_poll; \
-	dev->weight = max_interrupt_work; \
+	np->napi.poll = &netdev_poll; \
+	np->napi.weight = max_interrupt_work; \
 } while (0)
-#define netdev_rx(dev, ioaddr) \
+#define netdev_rx(dev, np, ioaddr) \
 do { \
 	u32 intr_enable; \
-	if (netif_rx_schedule_prep(dev)) { \
-		__netif_rx_schedule(dev); \
+	if (netif_rx_schedule_prep(dev, &np->napi)) { \
+		__netif_rx_schedule(dev, &np->napi); \
 		intr_enable = readl(ioaddr + IntrEnable); \
 		intr_enable &= ~(IntrRxDone | IntrRxEmpty); \
 		writel(intr_enable, ioaddr + IntrEnable); \
@@ -204,12 +204,12 @@ do { \
 } while (0)
 #define netdev_receive_skb(skb) netif_receive_skb(skb)
 #define vlan_netdev_receive_skb(skb, vlgrp, vlid) vlan_hwaccel_receive_skb(skb, vlgrp, vlid)
-static int	netdev_poll(struct net_device *dev, int *budget);
+static int	netdev_poll(struct napi_struct *napi, int budget);
 #else  /* not HAVE_NETDEV_POLL */
-#define init_poll(dev)
+#define init_poll(np)
 #define netdev_receive_skb(skb) netif_rx(skb)
 #define vlan_netdev_receive_skb(skb, vlgrp, vlid) vlan_hwaccel_rx(skb, vlgrp, vlid)
-#define netdev_rx(dev, ioaddr) \
+#define netdev_rx(dev, np, ioaddr) \
 do { \
 	int quota = np->dirty_rx + RX_RING_SIZE - np->cur_rx; \
 	__netdev_rx(dev, &quota);\
@@ -599,6 +599,8 @@ struct netdev_private {
 	struct tx_done_desc *tx_done_q;
 	dma_addr_t tx_done_q_dma;
 	unsigned int tx_done;
+	struct napi_struct napi;
+	struct net_device *dev;
 	struct net_device_stats stats;
 	struct pci_dev *pci_dev;
 #ifdef VLAN_SUPPORT
@@ -791,6 +793,7 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	dev->irq = irq;
 
 	np = netdev_priv(dev);
+	np->dev = dev;
 	np->base = base;
 	spin_lock_init(&np->lock);
 	pci_set_drvdata(pdev, dev);
@@ -851,7 +854,7 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	dev->hard_start_xmit = &start_tx;
 	dev->tx_timeout = tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	init_poll(dev);
+	init_poll(np);
 	dev->stop = &netdev_close;
 	dev->get_stats = &get_stats;
 	dev->set_multicast_list = &set_rx_mode;
@@ -1330,7 +1333,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 		handled = 1;
 
 		if (intr_status & (IntrRxDone | IntrRxEmpty))
-			netdev_rx(dev, ioaddr);
+			netdev_rx(dev, np, ioaddr);
 
 		/* Scavenge the skbuff list based on the Tx-done queue.
 		   There are redundant checks here that may be cleaned up
@@ -1531,36 +1534,35 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 
 
 #ifdef HAVE_NETDEV_POLL
-static int netdev_poll(struct net_device *dev, int *budget)
+static int netdev_poll(struct napi_struct *napi, int budget)
 {
+	struct netdev_private *np = container_of(napi, struct netdev_private, napi);
+	struct net_device *dev = np->dev;
 	u32 intr_status;
-	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
-	int retcode = 0, quota = dev->quota;
+	int quota = budget;
 
 	do {
 		writel(IntrRxDone | IntrRxEmpty, ioaddr + IntrClear);
 
-		retcode = __netdev_rx(dev, &quota);
-		*budget -= (dev->quota - quota);
-		dev->quota = quota;
-		if (retcode)
+		if (__netdev_rx(dev, &quota))
 			goto out;
 
 		intr_status = readl(ioaddr + IntrStatus);
 	} while (intr_status & (IntrRxDone | IntrRxEmpty));
 
-	netif_rx_complete(dev);
+	netif_rx_complete(dev, napi);
 	intr_status = readl(ioaddr + IntrEnable);
 	intr_status |= IntrRxDone | IntrRxEmpty;
 	writel(intr_status, ioaddr + IntrEnable);
 
  out:
 	if (debug > 5)
-		printk(KERN_DEBUG "  exiting netdev_poll(): %d.\n", retcode);
+		printk(KERN_DEBUG "  exiting netdev_poll(): %d.\n",
+		       budget - quota);
 
 	/* Restart Rx engine if stopped. */
-	return retcode;
+	return budget - quota;
 }
 #endif /* HAVE_NETDEV_POLL */
 
@@ -1904,6 +1906,7 @@ static int netdev_close(struct net_device *dev)
 	int i;
 
 	netif_stop_queue(dev);
+	napi_disable(&np->napi);
 
 	if (debug > 1) {
 		printk(KERN_DEBUG "%s: Shutting down ethercard, Intr status %#8.8x.\n",
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4328038..8ab6828 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -19,7 +19,7 @@
  *
  *    gem_change_mtu() and gem_set_multicast() are called with a read_lock()
  *    help by net/core/dev.c, thus they can't schedule. That means they can't
- *    call netif_poll_disable() neither, thus force gem_poll() to keep a spinlock
+ *    call napi_disable() neither, thus force gem_poll() to keep a spinlock
  *    where it could have been dropped. change_mtu especially would love also to
  *    be able to msleep instead of horrid locked delays when resetting the HW,
  *    but that read_lock() makes it impossible, unless I defer it's action to
@@ -878,19 +878,20 @@ static int gem_rx(struct gem *gp, int work_to_do)
 	return work_done;
 }
 
-static int gem_poll(struct net_device *dev, int *budget)
+static int gem_poll(struct napi_struct *napi, int budget)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = container_of(napi, struct gem, napi);
+	struct net_device *dev = gp->dev;
 	unsigned long flags;
+	int work_done;
 
 	/*
 	 * NAPI locking nightmare: See comment at head of driver
 	 */
 	spin_lock_irqsave(&gp->lock, flags);
 
+	work_done = 0;
 	do {
-		int work_to_do, work_done;
-
 		/* Handle anomalies */
 		if (gp->status & GREG_STAT_ABNORMAL) {
 			if (gem_abnormal_irq(dev, gp, gp->status))
@@ -906,29 +907,25 @@ static int gem_poll(struct net_device *dev, int *budget)
 
 		/* Run RX thread. We don't use any locking here,
 		 * code willing to do bad things - like cleaning the
-		 * rx ring - must call netif_poll_disable(), which
+		 * rx ring - must call napi_disable(), which
 		 * schedule_timeout()'s if polling is already disabled.
 		 */
-		work_to_do = min(*budget, dev->quota);
-
-		work_done = gem_rx(gp, work_to_do);
-
-		*budget -= work_done;
-		dev->quota -= work_done;
+		work_done += gem_rx(gp, budget);
 
-		if (work_done >= work_to_do)
-			return 1;
+		if (work_done >= budget)
+			return work_done;
 
 		spin_lock_irqsave(&gp->lock, flags);
 
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
 
-	__netif_rx_complete(dev);
+	__netif_rx_complete(dev, napi);
 	gem_enable_ints(gp);
 
 	spin_unlock_irqrestore(&gp->lock, flags);
-	return 0;
+
+	return work_done;
 }
 
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
@@ -946,17 +943,17 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 
 	spin_lock_irqsave(&gp->lock, flags);
 
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &gp->napi)) {
 		u32 gem_status = readl(gp->regs + GREG_STAT);
 
 		if (gem_status == 0) {
-			netif_poll_enable(dev);
+			napi_enable(&gp->napi);
 			spin_unlock_irqrestore(&gp->lock, flags);
 			return IRQ_NONE;
 		}
 		gp->status = gem_status;
 		gem_disable_ints(gp);
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &gp->napi);
 	}
 
 	spin_unlock_irqrestore(&gp->lock, flags);
@@ -2284,7 +2281,7 @@ static void gem_reset_task(struct work_struct *work)
 
 	mutex_lock(&gp->pm_mutex);
 
-	netif_poll_disable(gp->dev);
+	napi_disable(&gp->napi);
 
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
@@ -2307,7 +2304,7 @@ static void gem_reset_task(struct work_struct *work)
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irq(&gp->lock);
 
-	netif_poll_enable(gp->dev);
+	napi_enable(&gp->napi);
 
 	mutex_unlock(&gp->pm_mutex);
 }
@@ -2334,9 +2331,7 @@ static int gem_close(struct net_device *dev)
 {
 	struct gem *gp = dev->priv;
 
-	/* Note: we don't need to call netif_poll_disable() here because
-	 * our caller (dev_close) already did it for us
-	 */
+	napi_disable(&gp->napi);
 
 	mutex_lock(&gp->pm_mutex);
 
@@ -2358,7 +2353,7 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	mutex_lock(&gp->pm_mutex);
 
-	netif_poll_disable(dev);
+	napi_disable(&gp->napi);
 
 	printk(KERN_INFO "%s: suspending, WakeOnLan %s\n",
 	       dev->name,
@@ -2482,7 +2477,7 @@ static int gem_resume(struct pci_dev *pdev)
 	spin_unlock(&gp->tx_lock);
 	spin_unlock_irqrestore(&gp->lock, flags);
 
-	netif_poll_enable(dev);
+	napi_enable(&gp->napi);
 
 	mutex_unlock(&gp->pm_mutex);
 
@@ -3121,8 +3116,8 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	dev->get_stats = gem_get_stats;
 	dev->set_multicast_list = gem_set_multicast;
 	dev->do_ioctl = gem_ioctl;
-	dev->poll = gem_poll;
-	dev->weight = 64;
+	gp->napi.poll = gem_poll;
+	gp->napi.weight = 64;
 	dev->ethtool_ops = &gem_ethtool_ops;
 	dev->tx_timeout = gem_tx_timeout;
 	dev->watchdog_timeo = 5 * HZ;
diff --git a/drivers/net/sungem.h b/drivers/net/sungem.h
index 58cf87c..76d760a 100644
--- a/drivers/net/sungem.h
+++ b/drivers/net/sungem.h
@@ -993,6 +993,7 @@ struct gem {
 	u32			msg_enable;
 	u32			status;
 
+	struct napi_struct	napi;
 	struct net_device_stats net_stats;
 
 	int			tx_fifo_sz;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 7f94ca9..75d7afe 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -414,6 +414,9 @@ enum tc35815_timer_state {
 struct tc35815_local {
 	struct pci_dev *pci_dev;
 
+	struct net_device *dev;
+	struct napi_struct napi;
+
 	/* statistics */
 	struct net_device_stats stats;
 	struct {
@@ -566,7 +569,7 @@ static int	tc35815_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t	tc35815_interrupt(int irq, void *dev_id);
 #ifdef TC35815_NAPI
 static int	tc35815_rx(struct net_device *dev, int limit);
-static int	tc35815_poll(struct net_device *dev, int *budget);
+static int	tc35815_poll(struct napi_struct *napi, int budget);
 #else
 static void	tc35815_rx(struct net_device *dev);
 #endif
@@ -685,6 +688,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = dev->priv;
+	lp->dev = dev;
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device (pdev);
@@ -738,8 +742,8 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	dev->tx_timeout = tc35815_tx_timeout;
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
 #ifdef TC35815_NAPI
-	dev->poll = tc35815_poll;
-	dev->weight = NAPI_WEIGHT;
+	lp->napi.poll = tc35815_poll;
+	lp->napi.weight = NAPI_WEIGHT;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tc35815_poll_controller;
@@ -748,8 +752,6 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 
-	/* dev->priv/lp zeroed and aligned in alloc_etherdev */
-	lp = dev->priv;
 	spin_lock_init(&lp->lock);
 	lp->pci_dev = pdev;
 	lp->boardtype = ent->driver_data;
@@ -1436,6 +1438,7 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 #ifdef TC35815_NAPI
@@ -1444,8 +1447,8 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	if (!(dmactl & DMA_IntMask)) {
 		/* disable interrupts */
 		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
-		if (netif_rx_schedule_prep(dev))
-			__netif_rx_schedule(dev);
+		if (netif_rx_schedule_prep(dev, &lp->napi))
+			__netif_rx_schedule(dev, &lp->napi);
 		else {
 			printk(KERN_ERR "%s: interrupt taken in poll\n",
 			       dev->name);
@@ -1726,13 +1729,12 @@ tc35815_rx(struct net_device *dev)
 }
 
 #ifdef TC35815_NAPI
-static int
-tc35815_poll(struct net_device *dev, int *budget)
+static int tc35815_poll(struct napi_struct *napi, int budget)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = container_of(napi, struct tc35815_local, napi);
+	struct net_device *dev = lp->dev;
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-	int limit = min(*budget, dev->quota);
 	int received = 0, handled;
 	u32 status;
 
@@ -1744,23 +1746,19 @@ tc35815_poll(struct net_device *dev, int *budget)
 		handled = tc35815_do_interrupt(dev, status, limit);
 		if (handled >= 0) {
 			received += handled;
-			limit -= handled;
-			if (limit <= 0)
+			if (received >= budget)
 				break;
 		}
 		status = tc_readl(&tr->Int_Src);
 	} while (status);
 	spin_unlock(&lp->lock);
 
-	dev->quota -= received;
-	*budget -= received;
-	if (limit <= 0)
-		return 1;
-
-	netif_rx_complete(dev);
-	/* enable interrupts */
-	tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
-	return 0;
+	if (received < budget) {
+		netif_rx_complete(dev, napi);
+		/* enable interrupts */
+		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
+	}
+	return received;
 }
 #endif
 
@@ -1949,7 +1947,9 @@ static int
 tc35815_close(struct net_device *dev)
 {
 	struct tc35815_local *lp = dev->priv;
+
 	netif_stop_queue(dev);
+	napi_disable(&lp->napi);
 
 	/* Flush the Tx and disable Rx here. */
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 887b9a5..a210931 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -574,7 +574,7 @@ static void tg3_restart_ints(struct tg3 *tp)
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_poll_disable(tp->dev);
+	napi_disable(&tp->napi);
 	netif_tx_disable(tp->dev);
 }
 
@@ -585,7 +585,7 @@ static inline void tg3_netif_start(struct tg3 *tp)
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
 	 */
-	netif_poll_enable(tp->dev);
+	napi_enable(&tp->napi);
 	tp->hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
@@ -3471,11 +3471,12 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll(struct net_device *netdev, int *budget)
+static int tg3_poll(struct napi_struct *napi, int budget)
 {
-	struct tg3 *tp = netdev_priv(netdev);
+	struct tg3 *tp = container_of(napi, struct tg3, napi);
+	struct net_device *netdev = tp->dev;
 	struct tg3_hw_status *sblk = tp->hw_status;
-	int done;
+	int work_done = 0;
 
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
@@ -3494,7 +3495,7 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
 		tg3_tx(tp);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING)) {
-			netif_rx_complete(netdev);
+			netif_rx_complete(netdev, napi);
 			schedule_work(&tp->reset_task);
 			return 0;
 		}
@@ -3502,20 +3503,10 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
-	 * code synchronizes with dev->poll()
+	 * code synchronizes with tg3->napi.poll()
 	 */
-	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
-		int orig_budget = *budget;
-		int work_done;
-
-		if (orig_budget > netdev->quota)
-			orig_budget = netdev->quota;
-
-		work_done = tg3_rx(tp, orig_budget);
-
-		*budget -= work_done;
-		netdev->quota -= work_done;
-	}
+	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
+		work_done = tg3_rx(tp, budget);
 
 	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
 		tp->last_tag = sblk->status_tag;
@@ -3524,13 +3515,12 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 		sblk->status &= ~SD_STATUS_UPDATED;
 
 	/* if no more work, tell net stack and NIC we're done */
-	done = !tg3_has_work(tp);
-	if (done) {
-		netif_rx_complete(netdev);
+	if (!tg3_has_work(tp)) {
+		netif_rx_complete(netdev, napi);
 		tg3_restart_ints(tp);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)
@@ -3577,7 +3567,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3602,7 +3592,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 
 	return IRQ_RETVAL(1);
 }
@@ -3644,7 +3634,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		netif_rx_schedule(dev);		/* schedule NAPI poll */
+		netif_rx_schedule(dev, &tp->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -3690,7 +3680,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &tp->napi)) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		/* Update last_tag to mark that this status has been
 		 * seen. Because interrupt may be shared, we may be
@@ -3698,7 +3688,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 		 * if tg3_poll() is not scheduled.
 		 */
 		tp->last_tag = sblk->status_tag;
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &tp->napi);
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -3737,7 +3727,7 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
 		tp->irq_sync = 0;
-		netif_poll_enable(tp->dev);
+		napi_enable(&tp->napi);
 		dev_close(tp->dev);
 		tg3_full_lock(tp, 0);
 	}
@@ -3932,7 +3922,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 
 	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
+	 * and TX reclaim runs via tp->napi.poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
@@ -4087,7 +4077,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 
 	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
+	 * and TX reclaim runs via tp->napi.poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
@@ -7456,6 +7446,7 @@ static int tg3_close(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	napi_disable(&tp->napi);
 	cancel_work_sync(&tp->reset_task);
 
 	netif_stop_queue(dev);
@@ -11897,9 +11888,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = tg3_set_mac_addr;
 	dev->do_ioctl = tg3_ioctl;
 	dev->tx_timeout = tg3_tx_timeout;
-	dev->poll = tg3_poll;
+	tp->napi.weight = 64;
+	tp->napi.poll = tg3_poll;
 	dev->ethtool_ops = &tg3_ethtool_ops;
-	dev->weight = 64;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5c21f49..a6a23bb 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2176,6 +2176,7 @@ struct tg3 {
 	dma_addr_t			tx_desc_mapping;
 
 	/* begin "rx thread" cacheline section */
+	struct napi_struct		napi;
 	void				(*write32_rx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				rx_rcb_ptr;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 1aabc91..c000f6a 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -79,6 +79,9 @@ struct tsi108_prv_data {
 	void  __iomem *regs;	/* Base of normal regs */
 	void  __iomem *phyregs;	/* Base of register bank used for PHY access */
 
+	struct net_device *dev;
+	struct napi_struct napi;
+
 	unsigned int phy;		/* Index of PHY for this interface */
 	unsigned int irq_num;
 	unsigned int id;
@@ -837,13 +840,13 @@ static int tsi108_refill_rx(struct net_device *dev, int budget)
 	return done;
 }
 
-static int tsi108_poll(struct net_device *dev, int *budget)
+static int tsi108_poll(struct napi_struct *napi, int budget)
 {
-	struct tsi108_prv_data *data = netdev_priv(dev);
+	struct tsi108_prv_data *data = container_of(napi, struct tsi108_prv_data, napi);
+	struct net_device *dev = data->dev;
 	u32 estat = TSI_READ(TSI108_EC_RXESTAT);
 	u32 intstat = TSI_READ(TSI108_EC_INTSTAT);
-	int total_budget = min(*budget, dev->quota);
-	int num_received = 0, num_filled = 0, budget_used;
+	int num_received = 0, num_filled = 0;
 
 	intstat &= TSI108_INT_RXQUEUE0 | TSI108_INT_RXTHRESH |
 	    TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR | TSI108_INT_RXWAIT;
@@ -852,7 +855,7 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 	TSI_WRITE(TSI108_EC_INTSTAT, intstat);
 
 	if (data->rxpending || (estat & TSI108_EC_RXESTAT_Q0_DESCINT))
-		num_received = tsi108_complete_rx(dev, total_budget);
+		num_received = tsi108_complete_rx(dev, budget);
 
 	/* This should normally fill no more slots than the number of
 	 * packets received in tsi108_complete_rx().  The exception
@@ -867,7 +870,7 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 	 */
 
 	if (data->rxfree < TSI108_RXRING_LEN)
-		num_filled = tsi108_refill_rx(dev, total_budget * 2);
+		num_filled = tsi108_refill_rx(dev, budget * 2);
 
 	if (intstat & TSI108_INT_RXERROR) {
 		u32 err = TSI_READ(TSI108_EC_RXERR);
@@ -890,14 +893,9 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 		spin_unlock_irq(&data->misclock);
 	}
 
-	budget_used = max(num_received, num_filled / 2);
-
-	*budget -= budget_used;
-	dev->quota -= budget_used;
-
-	if (budget_used != total_budget) {
+	if (num_received < budget) {
 		data->rxpending = 0;
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 
 		TSI_WRITE(TSI108_EC_INTMASK,
 				     TSI_READ(TSI108_EC_INTMASK)
@@ -906,14 +904,11 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 					 TSI108_INT_RXOVERRUN |
 					 TSI108_INT_RXERROR |
 					 TSI108_INT_RXWAIT));
-
-		/* IRQs are level-triggered, so no need to re-check */
-		return 0;
 	} else {
 		data->rxpending = 1;
 	}
 
-	return 1;
+	return num_received;
 }
 
 static void tsi108_rx_int(struct net_device *dev)
@@ -931,7 +926,7 @@ static void tsi108_rx_int(struct net_device *dev)
 	 * from tsi108_check_rxring().
 	 */
 
-	if (netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &data->napi)) {
 		/* Mask, rather than ack, the receive interrupts.  The ack
 		 * will happen in tsi108_poll().
 		 */
@@ -942,7 +937,7 @@ static void tsi108_rx_int(struct net_device *dev)
 				     | TSI108_INT_RXTHRESH |
 				     TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR |
 				     TSI108_INT_RXWAIT);
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &data->napi);
 	} else {
 		if (!netif_running(dev)) {
 			/* This can happen if an interrupt occurs while the
@@ -1425,6 +1420,7 @@ static int tsi108_close(struct net_device *dev)
 	struct tsi108_prv_data *data = netdev_priv(dev);
 
 	netif_stop_queue(dev);
+	napi_disable(&data->napi);
 
 	del_timer_sync(&data->timer);
 
@@ -1562,6 +1558,7 @@ tsi108_init_one(struct platform_device *pdev)
 
 	printk("tsi108_eth%d: probe...\n", pdev->id);
 	data = netdev_priv(dev);
+	data->dev = dev;
 
 	pr_debug("tsi108_eth%d:regs:phyresgs:phy:irq_num=0x%x:0x%x:0x%x:0x%x\n",
 			pdev->id, einfo->regs, einfo->phyregs,
@@ -1597,9 +1594,9 @@ tsi108_init_one(struct platform_device *pdev)
 	dev->set_mac_address = tsi108_set_mac;
 	dev->set_multicast_list = tsi108_set_rx_mode;
 	dev->get_stats = tsi108_get_stats;
-	dev->poll = tsi108_poll;
+	data->napi.poll = tsi108_poll;
+	data->napi.weight = 64;  /* 64 is more suitable for GigE interface - klai */
 	dev->do_ioctl = tsi108_do_ioctl;
-	dev->weight = 64;  /* 64 is more suitable for GigE interface - klai */
 
 	/* Apparently, the Linux networking code won't use scatter-gather
 	 * if the hardware doesn't do checksums.  However, it's faster
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 53efd66..3653314 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -103,28 +103,29 @@ int tulip_refill_rx(struct net_device *dev)
 void oom_timer(unsigned long data)
 {
         struct net_device *dev = (struct net_device *)data;
-	netif_rx_schedule(dev);
+	struct tulip_private *tp = netdev_priv(dev);
+	netif_rx_schedule(dev, &tp->napi);
 }
 
-int tulip_poll(struct net_device *dev, int *budget)
+int tulip_poll(struct napi_struct *napi, int budget)
 {
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = container_of(napi, struct tulip_private, napi);
+	struct net_device *dev = tp->dev;
 	int entry = tp->cur_rx % RX_RING_SIZE;
-	int rx_work_limit = *budget;
+	int work_done = 0;
+#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 	int received = 0;
+#endif
 
 	if (!netif_running(dev))
 		goto done;
 
-	if (rx_work_limit > dev->quota)
-		rx_work_limit = dev->quota;
-
 #ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 
 /* that one buffer is needed for mit activation; or might be a
    bug in the ring buffer code; check later -- JHS*/
 
-        if (rx_work_limit >=RX_RING_SIZE) rx_work_limit--;
+        if (budget >=RX_RING_SIZE) budget--;
 #endif
 
 	if (tulip_debug > 4)
@@ -144,14 +145,13 @@ int tulip_poll(struct net_device *dev, int *budget)
                while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
                        s32 status = le32_to_cpu(tp->rx_ring[entry].status);
 
-
                        if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
                                break;
 
                        if (tulip_debug > 5)
                                printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
                                       dev->name, entry, status);
-                       if (--rx_work_limit < 0)
+		       if (work_done++ >= budget)
                                goto not_done;
 
                        if ((status & 0x38008300) != 0x0300) {
@@ -238,7 +238,9 @@ int tulip_poll(struct net_device *dev, int *budget)
                                tp->stats.rx_packets++;
                                tp->stats.rx_bytes += pkt_len;
                        }
-                       received++;
+#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
+		       received++;
+#endif
 
                        entry = (++tp->cur_rx) % RX_RING_SIZE;
                        if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
@@ -296,17 +298,15 @@ done:
 
 #endif /* CONFIG_TULIP_NAPI_HW_MITIGATION */
 
-         dev->quota -= received;
-         *budget -= received;
-
          tulip_refill_rx(dev);
 
          /* If RX ring is not full we are out of memory. */
-         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
+         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+		 goto oom;
 
          /* Remove us from polling list and enable RX intr. */
 
-         netif_rx_complete(dev);
+         netif_rx_complete(dev, napi);
          iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+CSR7);
 
          /* The last op happens after poll completion. Which means the following:
@@ -320,28 +320,20 @@ done:
           * processed irqs. But it must not result in losing events.
           */
 
-         return 0;
+         return work_done;
 
  not_done:
-         if (!received) {
-
-                 received = dev->quota; /* Not to happen */
-         }
-         dev->quota -= received;
-         *budget -= received;
-
          if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/2 ||
              tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
                  tulip_refill_rx(dev);
 
-         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
-
-         return 1;
+         if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+		 goto oom;
 
+         return work_done;
 
  oom:    /* Executed with RX ints disabled */
 
-
          /* Start timer, stop polling, but do not enable rx interrupts. */
          mod_timer(&tp->oom_timer, jiffies+1);
 
@@ -350,9 +342,9 @@ done:
           * before we did netif_rx_complete(). See? We would lose it. */
 
          /* remove ourselves from the polling list */
-         netif_rx_complete(dev);
+         netif_rx_complete(dev, napi);
 
-         return 0;
+         return work_done;
 }
 
 #else /* CONFIG_TULIP_NAPI */
@@ -534,7 +526,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 			rxd++;
 			/* Mask RX intrs and add the device to poll list. */
 			iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + CSR7);
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &tp->napi);
 
 			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
                                break;
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 16f26a8..5a4d727 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -353,6 +353,7 @@ struct tulip_private {
 	int chip_id;
 	int revision;
 	int flags;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 	struct timer_list timer;	/* Media selection timer. */
 	struct timer_list oom_timer;    /* Out of memory timer. */
@@ -429,7 +430,7 @@ extern int tulip_rx_copybreak;
 irqreturn_t tulip_interrupt(int irq, void *dev_instance);
 int tulip_refill_rx(struct net_device *dev);
 #ifdef CONFIG_TULIP_NAPI
-int tulip_poll(struct net_device *dev, int *budget);
+int tulip_poll(struct napi_struct *napi, int budget);
 #endif
 
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f87d769..13d52fc 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -497,6 +497,7 @@ media_picked:
 static int
 tulip_open(struct net_device *dev)
 {
+	struct tulip_private *tp = netdev_priv(dev);
 	int retval;
 
 	if ((retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev)))
@@ -769,6 +770,7 @@ static int tulip_close (struct net_device *dev)
 	int i;
 
 	netif_stop_queue (dev);
+	napi_disable(&tp->napi);
 
 	tulip_down (dev);
 
@@ -1614,8 +1616,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	dev->tx_timeout = tulip_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_TULIP_NAPI
-	dev->poll = tulip_poll;
-	dev->weight = 16;
+	tp->napi.poll = tulip_poll;
+	tp->napi.weight = 16;
 #endif
 	dev->stop = tulip_close;
 	dev->get_stats = tulip_get_stats;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0358720..194f5bd 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -284,6 +284,7 @@ struct typhoon {
 	struct basic_ring	rxLoRing;
 	struct pci_dev *	pdev;
 	struct net_device *	dev;
+	struct napi_struct	napi;
 	spinlock_t		state_lock;
 	struct vlan_group *	vlgrp;
 	struct basic_ring	rxHiRing;
@@ -1759,12 +1760,12 @@ typhoon_fill_free_ring(struct typhoon *tp)
 }
 
 static int
-typhoon_poll(struct net_device *dev, int *total_budget)
+typhoon_poll(struct napi_struct *napi, int budget)
 {
-	struct typhoon *tp = netdev_priv(dev);
+	struct typhoon *tp = container_of(napi, struct typhoon, napi);
+	struct net_device *dev = tp->dev;
 	struct typhoon_indexes *indexes = tp->indexes;
-	int orig_budget = *total_budget;
-	int budget, work_done, done;
+	int work_done;
 
 	rmb();
 	if(!tp->awaiting_resp && indexes->respReady != indexes->respCleared)
@@ -1773,30 +1774,16 @@ typhoon_poll(struct net_device *dev, int *total_budget)
 	if(le32_to_cpu(indexes->txLoCleared) != tp->txLoRing.lastRead)
 		typhoon_tx_complete(tp, &tp->txLoRing, &indexes->txLoCleared);
 
-	if(orig_budget > dev->quota)
-		orig_budget = dev->quota;
-
-	budget = orig_budget;
 	work_done = 0;
-	done = 1;
 
 	if(indexes->rxHiCleared != indexes->rxHiReady) {
-		work_done = typhoon_rx(tp, &tp->rxHiRing, &indexes->rxHiReady,
+		work_done += typhoon_rx(tp, &tp->rxHiRing, &indexes->rxHiReady,
 			   		&indexes->rxHiCleared, budget);
-		budget -= work_done;
 	}
 
 	if(indexes->rxLoCleared != indexes->rxLoReady) {
 		work_done += typhoon_rx(tp, &tp->rxLoRing, &indexes->rxLoReady,
-			   		&indexes->rxLoCleared, budget);
-	}
-
-	if(work_done) {
-		*total_budget -= work_done;
-		dev->quota -= work_done;
-
-		if(work_done >= orig_budget)
-			done = 0;
+			   		&indexes->rxLoCleared, budget - work_done);
 	}
 
 	if(le32_to_cpu(indexes->rxBuffCleared) == tp->rxBuffRing.lastWrite) {
@@ -1804,14 +1791,14 @@ typhoon_poll(struct net_device *dev, int *total_budget)
 		typhoon_fill_free_ring(tp);
 	}
 
-	if(done) {
-		netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static irqreturn_t
@@ -1828,10 +1815,10 @@ typhoon_interrupt(int irq, void *dev_instance)
 
 	iowrite32(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
 
-	if(netif_rx_schedule_prep(dev)) {
+	if (netif_rx_schedule_prep(dev, &tp->napi)) {
 		iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(ioaddr);
-		__netif_rx_schedule(dev);
+		__netif_rx_schedule(dev, &tp->napi);
 	} else {
 		printk(KERN_ERR "%s: Error, poll already scheduled\n",
                        dev->name);
@@ -2150,6 +2137,7 @@ typhoon_close(struct net_device *dev)
 	struct typhoon *tp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
+	napi_disable(&tp->napi);
 
 	if(typhoon_stop_runtime(tp, WaitSleep) < 0)
 		printk(KERN_ERR "%s: unable to stop runtime\n", dev->name);
@@ -2521,8 +2509,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->stop		= typhoon_close;
 	dev->set_multicast_list	= typhoon_set_rx_mode;
 	dev->tx_timeout		= typhoon_tx_timeout;
-	dev->poll		= typhoon_poll;
-	dev->weight		= 16;
+	tp->napi.poll		= typhoon_poll;
+	tp->napi.weight		= 16;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	dev->get_stats		= typhoon_get_stats;
 	dev->set_mac_address	= typhoon_set_mac_address;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e4736a3..c90c753 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3527,41 +3527,31 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 }
 
 #ifdef CONFIG_UGETH_NAPI
-static int ucc_geth_poll(struct net_device *dev, int *budget)
+static int ucc_geth_poll(struct napi_struct *napi, int budget)
 {
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct ucc_geth_private *ugeth = container_of(napi, struct ucc_geth_private, napi);
+	struct net_device *dev = ugeth->dev;
 	struct ucc_geth_info *ug_info;
-	struct ucc_fast_private *uccf;
-	int howmany;
-	u8 i;
-	int rx_work_limit;
-	register u32 uccm;
+	int howmany, i;
 
 	ug_info = ugeth->ug_info;
 
-	rx_work_limit = *budget;
-	if (rx_work_limit > dev->quota)
-		rx_work_limit = dev->quota;
-
 	howmany = 0;
+	for (i = 0; i < ug_info->numQueuesRx; i++)
+		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
 
-	for (i = 0; i < ug_info->numQueuesRx; i++) {
-		howmany += ucc_geth_rx(ugeth, i, rx_work_limit);
-	}
-
-	dev->quota -= howmany;
-	rx_work_limit -= howmany;
-	*budget -= howmany;
+	if (howmany < budget) {
+		struct ucc_fast_private *uccf;
+		u32 uccm;
 
-	if (rx_work_limit > 0) {
-		netif_rx_complete(dev);
+		netif_rx_complete(dev, napi);
 		uccf = ugeth->uccf;
 		uccm = in_be32(uccf->p_uccm);
 		uccm |= UCCE_RX_EVENTS;
 		out_be32(uccf->p_uccm, uccm);
 	}
 
-	return (rx_work_limit > 0) ? 0 : 1;
+	return howmany;
 }
 #endif				/* CONFIG_UGETH_NAPI */
 
@@ -3596,10 +3586,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
 #ifdef CONFIG_UGETH_NAPI
-		if (netif_rx_schedule_prep(dev)) {
-		uccm &= ~UCCE_RX_EVENTS;
+		if (netif_rx_schedule_prep(dev, &ugeth->napi)) {
+			uccm &= ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
-			__netif_rx_schedule(dev);
+			__netif_rx_schedule(dev, &ugeth->napi);
 		}
 #else
 		rx_mask = UCCE_RXBF_SINGLE_MASK;
@@ -3722,6 +3712,8 @@ static int ucc_geth_close(struct net_device *dev)
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
+	napi_disable(&ugeth->napi);
+
 	ucc_geth_stop(ugeth);
 
 	phy_disconnect(ugeth->phydev);
@@ -3901,8 +3893,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->tx_timeout = ucc_geth_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_UGETH_NAPI
-	dev->poll = ucc_geth_poll;
-	dev->weight = UCC_GETH_DEV_WEIGHT;
+	ugeth->napi.poll = ucc_geth_poll;
+	ugeth->napi.weight = UCC_GETH_DEV_WEIGHT;
 #endif				/* CONFIG_UGETH_NAPI */
 	dev->stop = ucc_geth_close;
 	dev->get_stats = ucc_geth_get_stats;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index a29e1c3..a4cb4bb 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1178,6 +1178,7 @@ struct ucc_geth_private {
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;	/* linux network statistics */
 	struct ucc_geth *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index f51c2c1..0e63a16 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -383,6 +383,8 @@ struct rhine_private {
 
 	struct pci_dev *pdev;
 	long pioaddr;
+	struct net_device *dev;
+	struct napi_struct napi;
 	struct net_device_stats stats;
 	spinlock_t lock;
 
@@ -576,28 +578,25 @@ static void rhine_poll(struct net_device *dev)
 #endif
 
 #ifdef CONFIG_VIA_RHINE_NAPI
-static int rhine_napipoll(struct net_device *dev, int *budget)
+static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
-	struct rhine_private *rp = netdev_priv(dev);
+	struct rhine_private *rp = container_of(napi, struct rhine_private, napi);
+	struct net_device *dev = rp->dev;
 	void __iomem *ioaddr = rp->base;
-	int done, limit = min(dev->quota, *budget);
+	int work_done;
 
-	done = rhine_rx(dev, limit);
-	*budget -= done;
-	dev->quota -= done;
+	work_done = rhine_rx(dev, budget);
 
-	if (done < limit) {
-		netif_rx_complete(dev);
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
 
 		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
 			  IntrTxDone | IntrTxError | IntrTxUnderrun |
 			  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 			  ioaddr + IntrEnable);
-		return 0;
 	}
-	else
-		return 1;
+	return work_done;
 }
 #endif
 
@@ -701,6 +700,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	rp = netdev_priv(dev);
+	rp->dev = dev;
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
@@ -779,8 +779,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->poll_controller = rhine_poll;
 #endif
 #ifdef CONFIG_VIA_RHINE_NAPI
-	dev->poll = rhine_napipoll;
-	dev->weight = 64;
+	rp->napi.poll = rhine_napipoll;
+	rp->napi.weight = 64;
 #endif
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
@@ -1055,7 +1055,7 @@ static void init_registers(struct net_device *dev)
 
 	rhine_set_rx_mode(dev);
 
-	netif_poll_enable(dev);
+	napi_enable(&rp->napi);
 
 	/* Enable interrupts by setting the interrupt mask. */
 	iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
@@ -1318,7 +1318,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
 
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &rp->napi);
 #else
 			rhine_rx(dev, RX_RING_SIZE);
 #endif
@@ -1832,7 +1832,7 @@ static int rhine_close(struct net_device *dev)
 	spin_lock_irq(&rp->lock);
 
 	netif_stop_queue(dev);
-	netif_poll_disable(dev);
+	napi_disable(&rp->napi);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 489f69c..a3de80c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -72,6 +72,7 @@ struct netfront_info {
 	struct list_head list;
 	struct net_device *netdev;
 
+	struct napi_struct napi;
 	struct net_device_stats stats;
 
 	struct xen_netif_tx_front_ring tx;
@@ -185,7 +186,8 @@ static int xennet_can_sg(struct net_device *dev)
 static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	netif_rx_schedule(dev);
+	struct netfront_info *np = netdev_priv(dev);
+	netif_rx_schedule(dev, &np->napi);
 }
 
 static int netfront_tx_slot_available(struct netfront_info *np)
@@ -347,7 +349,7 @@ static int xennet_open(struct net_device *dev)
 		xennet_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &np->napi);
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -588,6 +590,7 @@ static int xennet_close(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
 	netif_stop_queue(np->netdev);
+	napi_disable(&np->napi);
 	return 0;
 }
 
@@ -871,15 +874,16 @@ static int handle_incoming_queue(struct net_device *dev,
 	return packets_dropped;
 }
 
-static int xennet_poll(struct net_device *dev, int *pbudget)
+static int xennet_poll(struct napi_struct *napi, int budget)
 {
-	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_info *np = container_of(napi, struct netfront_info, napi);
+	struct net_device *dev = np->netdev;
 	struct sk_buff *skb;
 	struct netfront_rx_info rinfo;
 	struct xen_netif_rx_response *rx = &rinfo.rx;
 	struct xen_netif_extra_info *extras = rinfo.extras;
 	RING_IDX i, rp;
-	int work_done, budget, more_to_do = 1;
+	int work_done, budget;
 	struct sk_buff_head rxq;
 	struct sk_buff_head errq;
 	struct sk_buff_head tmpq;
@@ -898,9 +902,6 @@ static int xennet_poll(struct net_device *dev, int *pbudget)
 	skb_queue_head_init(&errq);
 	skb_queue_head_init(&tmpq);
 
-	budget = *pbudget;
-	if (budget > dev->quota)
-		budget = dev->quota;
 	rp = np->rx.sring->rsp_prod;
 	rmb(); /* Ensure we see queued responses up to 'rp'. */
 
@@ -1005,22 +1006,21 @@ err:
 
 	xennet_alloc_rx_buffers(dev);
 
-	*pbudget   -= work_done;
-	dev->quota -= work_done;
-
 	if (work_done < budget) {
+		int more_to_do = 0;
+
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
 		if (!more_to_do)
-			__netif_rx_complete(dev);
+			__netif_rx_complete(dev, napi);
 
 		local_irq_restore(flags);
 	}
 
 	spin_unlock(&np->rx_lock);
 
-	return more_to_do;
+	return work_done;
 }
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
@@ -1200,10 +1200,10 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	netdev->hard_start_xmit = xennet_start_xmit;
 	netdev->stop            = xennet_close;
 	netdev->get_stats       = xennet_get_stats;
-	netdev->poll            = xennet_poll;
+	np->napi.poll		= xennet_poll;
+	np->napi.weight		= 64;
 	netdev->uninit          = xennet_uninit;
 	netdev->change_mtu	= xennet_change_mtu;
-	netdev->weight          = 64;
 	netdev->features        = NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
@@ -1348,7 +1348,7 @@ static irqreturn_t xennet_interrupt(int irq, void *dev_id)
 		xennet_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev);
+			netif_rx_schedule(dev, &np->napi);
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..aae2083 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -31,6 +31,7 @@
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
+#include <linux/delay.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
@@ -258,7 +259,6 @@ enum netdev_state_t
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
@@ -278,6 +278,73 @@ struct netdev_boot_setup {
 extern int __init netdev_boot_setup(char *str);
 
 /*
+ * Structure for NAPI scheduling similar to tasklet but with weighting
+ */
+struct napi_struct {
+	struct list_head	poll_list;
+	unsigned long		state;
+	int			weight;
+	int			quota;
+	int			(*poll)(struct napi_struct *, int);
+};
+
+enum
+{
+	NAPI_STATE_SCHED,	/* Poll is scheduled */
+	NAPI_STATE_RUN,		/* Poll function is running (only NETPOLL)*/
+};
+
+/* If using netpoll it may "steal" entries that are already scheduled */
+#ifdef CONFIG_NETPOLL
+static inline int napi_trylock(struct napi_struct *n)
+{
+	return !test_and_set_bit(NAPI_STATE_RUN, &n->state);
+}
+
+static inline void napi_unlock(struct napi_struct *n)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_RUN, &n->state);
+}
+#else
+#define napi_trylock(t)	1
+#define napi_unlock(t) do { } while (0)
+#endif
+
+extern void FASTCALL(__napi_schedule(struct napi_struct *n));
+
+static inline int napi_schedule_prep(struct napi_struct *n)
+{
+	return !test_and_set_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+static inline void napi_schedule(struct napi_struct *n)
+{
+	if (napi_schedule_prep(n))
+		__napi_schedule(n);
+}
+
+static inline void napi_complete(struct napi_struct *n)
+{
+	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+static inline void napi_disable(struct napi_struct *n)
+{
+	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
+		msleep_interruptible(1);
+}
+
+static inline void napi_enable(struct napi_struct *n)
+{
+	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	smp_mb__before_clear_bit();
+	clear_bit(NAPI_STATE_SCHED, &n->state);
+}
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -430,12 +497,6 @@ struct net_device
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
  */
-	struct list_head	poll_list ____cacheline_aligned_in_smp;
-					/* Link to poll list	*/
-
-	int			(*poll) (struct net_device *dev, int *quota);
-	int			quota;
-	int			weight;
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
@@ -678,7 +739,6 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-
 struct softnet_data
 {
 	struct net_device	*output_queue;
@@ -686,7 +746,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct net_device	backlog_dev;	/* Sorry. 8) */
+	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
@@ -796,20 +856,7 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
  */
-static inline void dev_kfree_skb_irq(struct sk_buff *skb)
-{
-	if (atomic_dec_and_test(&skb->users)) {
-		struct softnet_data *sd;
-		unsigned long flags;
-
-		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
-		skb->next = sd->completion_queue;
-		sd->completion_queue = skb;
-		raise_softirq_irqoff(NET_TX_SOFTIRQ);
-		local_irq_restore(flags);
-	}
-}
+extern void dev_kfree_skb_irq(struct sk_buff *skb);
 
 /* Use this variant in places where it could be invoked
  * either from interrupt or non-interrupt context.
@@ -955,60 +1002,41 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
 
-/* Test if receive needs to be scheduled */
-static inline int __netif_rx_schedule_prep(struct net_device *dev)
-{
-	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
 
 /* Test if receive needs to be scheduled but only if up */
-static inline int netif_rx_schedule_prep(struct net_device *dev)
+static inline int netif_rx_schedule_prep(struct net_device *dev,
+					 struct napi_struct *napi)
 {
-	return netif_running(dev) && __netif_rx_schedule_prep(dev);
+	return netif_running(dev) && napi_schedule_prep(napi);
 }
 
 /* Add interface to tail of rx poll list. This assumes that _prep has
  * already been called and returned 1.
  */
-
-extern void __netif_rx_schedule(struct net_device *dev);
-
-/* Try to reschedule poll. Called by irq handler. */
-
-static inline void netif_rx_schedule(struct net_device *dev)
+static inline void __netif_rx_schedule(struct net_device *dev,
+				       struct napi_struct *napi)
 {
-	if (netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	dev_hold(dev);
+	__napi_schedule(napi);
 }
 
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
- * Do not inline this?
- */
-static inline int netif_rx_reschedule(struct net_device *dev, int undo)
-{
-	if (netif_rx_schedule_prep(dev)) {
-		unsigned long flags;
-
-		dev->quota += undo;
+/* Try to reschedule poll. Called by irq handler. */
 
-		local_irq_save(flags);
-		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-		local_irq_restore(flags);
-		return 1;
-	}
-	return 0;
+static inline void netif_rx_schedule(struct net_device *dev,
+				     struct napi_struct *napi)
+{
+	if (netif_rx_schedule_prep(dev, napi))
+		__netif_rx_schedule(dev, napi);
 }
 
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
-static inline void __netif_rx_complete(struct net_device *dev)
+static inline void __netif_rx_complete(struct net_device *dev,
+				       struct napi_struct *napi)
 {
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	napi_complete(napi);
+	dev_put(dev);
 }
 
 /* Remove interface from poll list: it must be in the poll list
@@ -1016,28 +1044,16 @@ static inline void __netif_rx_complete(struct net_device *dev)
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev)
+static inline void netif_rx_complete(struct net_device *dev,
+				     struct napi_struct *napi)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	__netif_rx_complete(dev);
+	__netif_rx_complete(dev, napi);
 	local_irq_restore(flags);
 }
 
-static inline void netif_poll_disable(struct net_device *dev)
-{
-	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state))
-		/* No hurry. */
-		schedule_timeout_interruptible(1);
-}
-
-static inline void netif_poll_enable(struct net_device *dev)
-{
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
-}
-
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	spin_lock(&dev->_xmit_lock);
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 29930b7..bbd31f7 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -25,8 +25,6 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
-	spinlock_t poll_lock;
-	int poll_owner;
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
@@ -44,52 +42,4 @@ void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
 
-
-#ifdef CONFIG_NETPOLL
-static inline int netpoll_rx(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo = skb->dev->npinfo;
-	unsigned long flags;
-	int ret = 0;
-
-	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
-		return 0;
-
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb))
-		ret = 1;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
-	return ret;
-}
-
-static inline void *netpoll_poll_lock(struct net_device *dev)
-{
-	rcu_read_lock(); /* deal with race on ->npinfo */
-	if (dev->npinfo) {
-		spin_lock(&dev->npinfo->poll_lock);
-		dev->npinfo->poll_owner = smp_processor_id();
-		return dev->npinfo;
-	}
-	return NULL;
-}
-
-static inline void netpoll_poll_unlock(void *have)
-{
-	struct netpoll_info *npi = have;
-
-	if (npi) {
-		npi->poll_owner = -1;
-		spin_unlock(&npi->poll_lock);
-	}
-	rcu_read_unlock();
-}
-
-#else
-#define netpoll_rx(a) 0
-#define netpoll_poll_lock(a) NULL
-#define netpoll_poll_unlock(a)
-#endif
-
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index ee40355..ec00c5f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+
+DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -996,16 +997,12 @@ int dev_close(struct net_device *dev)
 	clear_bit(__LINK_STATE_START, &dev->state);
 
 	/* Synchronize to scheduled poll. We cannot touch poll list,
-	 * it can be even on different cpu. So just clear netif_running(),
-	 * and wait when poll really will happen. Actually, the best place
-	 * for this is inside dev->stop() after device stopped its irq
-	 * engine, but this requires more changes in devices. */
-
+	 * it can be even on different cpu. So just clear netif_running().
+	 *
+	 * dev->stop() will invoke napi_disable() on all of it's
+	 * napi_struct instances on this device.
+	 */
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		msleep(1);
-	}
 
 	/*
 	 *	Call the device specific close. This cannot fail.
@@ -1188,21 +1185,21 @@ void __netif_schedule(struct net_device *dev)
 }
 EXPORT_SYMBOL(__netif_schedule);
 
-void __netif_rx_schedule(struct net_device *dev)
+void dev_kfree_skb_irq(struct sk_buff *skb)
 {
-	unsigned long flags;
+	if (atomic_dec_and_test(&skb->users)) {
+		struct softnet_data *sd;
+		unsigned long flags;
 
-	local_irq_save(flags);
-	dev_hold(dev);
-	list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-	if (dev->quota < 0)
-		dev->quota += dev->weight;
-	else
-		dev->quota = dev->weight;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	local_irq_restore(flags);
+		local_irq_save(flags);
+		sd = &__get_cpu_var(softnet_data);
+		skb->next = sd->completion_queue;
+		sd->completion_queue = skb;
+		raise_softirq_irqoff(NET_TX_SOFTIRQ);
+		local_irq_restore(flags);
+	}
 }
-EXPORT_SYMBOL(__netif_rx_schedule);
+EXPORT_SYMBOL(dev_kfree_skb_irq);
 
 void dev_kfree_skb_any(struct sk_buff *skb)
 {
@@ -1638,6 +1635,28 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 
+#ifdef CONFIG_NETPOLL
+static inline int netpoll_rx(struct sk_buff *skb)
+{
+	struct netpoll_info *npinfo = skb->dev->npinfo;
+	unsigned long flags;
+	int ret = 0;
+
+	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
+		return 0;
+
+	spin_lock_irqsave(&npinfo->rx_lock, flags);
+	/* check rx_flags again with the lock held */
+	if (npinfo->rx_flags && __netpoll_rx(skb))
+		ret = 1;
+	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+
+	return ret;
+}
+#else 
+#define netpoll_rx(skb)	(0)
+#endif
+
 /**
  *	netif_rx	-	post buffer to the network code
  *	@skb: buffer to post
@@ -1685,7 +1704,7 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
 
-		netif_rx_schedule(&queue->backlog_dev);
+		napi_schedule(&queue->backlog);
 		goto enqueue;
 	}
 
@@ -1726,6 +1745,38 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
 	return dev;
 }
 
+
+#ifdef CONFIG_NETPOLL
+/* Netpoll is out of skb's, try and do a quick reclaim on the ones pending
+ * to be cleaned up by softirq.
+ */
+void netpoll_zap_completion_queue(void)
+{
+	struct softnet_data *sd = &get_cpu_var(softnet_data);
+	unsigned long flags;
+
+	if (sd->completion_queue) {
+		struct sk_buff *clist;
+
+		local_irq_save(flags);
+		clist = sd->completion_queue;
+		sd->completion_queue = NULL;
+		local_irq_restore(flags);
+
+		while (clist != NULL) {
+			struct sk_buff *skb = clist;
+			clist = clist->next;
+			if (skb->destructor)
+				dev_kfree_skb_any(skb); /* put this one back */
+			else
+				__kfree_skb(skb);
+		}
+	}
+
+	put_cpu_var(softnet_data);
+}
+#endif
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -1882,7 +1933,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	__be16 type;
 
 	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
+	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
 	if (!skb->tstamp.tv64)
@@ -1972,90 +2023,101 @@ out:
 	return ret;
 }
 
-static int process_backlog(struct net_device *backlog_dev, int *budget)
+static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
-	int quota = min(backlog_dev->quota, *budget);
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
 
-	backlog_dev->weight = weight_p;
-	for (;;) {
+	napi->weight = weight_p;
+	do {
 		struct sk_buff *skb;
 		struct net_device *dev;
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
-		if (!skb)
-			goto job_done;
 		local_irq_enable();
-
+		if (!skb) {
+			napi_complete(napi);
+			break;
+		}
+	
 		dev = skb->dev;
 
 		netif_receive_skb(skb);
 
 		dev_put(dev);
+	} while (++work < quota && jiffies == start_time);
 
-		work++;
-
-		if (work >= quota || jiffies - start_time > 1)
-			break;
-
-	}
-
-	backlog_dev->quota -= work;
-	*budget -= work;
-	return -1;
+	return work;
+}
 
-job_done:
-	backlog_dev->quota -= work;
-	*budget -= work;
+/**
+ * __napi_schedule - schedule for receive
+ * @napi: entry to schedule
+ *
+ * The entry's receive function will be scheduled to run
+ */
+void fastcall __napi_schedule(struct napi_struct *n)
+{
+	unsigned long flags;
 
-	list_del(&backlog_dev->poll_list);
-	smp_mb__before_clear_bit();
-	netif_poll_enable(backlog_dev);
+	if (n->quota < 0)
+		n->quota += n->weight;
+	else
+		n->quota = n->weight;
 
-	local_irq_enable();
-	return 0;
+	local_irq_save(flags);
+	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	local_irq_restore(flags);
 }
+EXPORT_SYMBOL(__napi_schedule);
+
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct list_head list;
 	unsigned long start_time = jiffies;
 	int budget = netdev_budget;
-	void *have;
 
 	local_irq_disable();
+	list_replace_init(&__get_cpu_var(softnet_data).poll_list, &list);
+	local_irq_enable();
 
-	while (!list_empty(&queue->poll_list)) {
-		struct net_device *dev;
+	while (!list_empty(&list)) {
+		struct napi_struct *n;
 
-		if (budget <= 0 || jiffies - start_time > 1)
-			goto softnet_break;
+		/* if softirq window is exhuasted then punt */
+		if (unlikely(budget <= 0 || jiffies != start_time)) {
+			local_irq_disable();
+			list_splice(&list, &__get_cpu_var(softnet_data).poll_list);
+			__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+			local_irq_enable();
+			break;
+		}
 
-		local_irq_enable();
+		n = list_entry(list.next, struct napi_struct, poll_list);
 
-		dev = list_entry(queue->poll_list.next,
-				 struct net_device, poll_list);
-		have = netpoll_poll_lock(dev);
+		/* if not racing with netpoll */
+		if (likely(napi_trylock(n))) {
+			list_del(&n->poll_list);
 
-		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
-			netpoll_poll_unlock(have);
-			local_irq_disable();
-			list_move_tail(&dev->poll_list, &queue->poll_list);
-			if (dev->quota < 0)
-				dev->quota += dev->weight;
-			else
-				dev->quota = dev->weight;
-		} else {
-			netpoll_poll_unlock(have);
-			dev_put(dev);
-			local_irq_disable();
-		}
+			/* if quota not exhausted process work */
+			if (likely(n->quota > 0)) {
+				int work = n->poll(n, min(budget, n->quota));
+
+				budget -= work;
+				n->quota -= work;
+			}
+
+			/* if napi_complete not called, reschedule */
+			if (test_bit(NAPI_STATE_SCHED, &n->state))
+				__napi_schedule(n);
+
+			napi_unlock(n);
+		} 
 	}
-out:
-	local_irq_enable();
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -2070,12 +2132,6 @@ out:
 		}
 	}
 #endif
-	return;
-
-softnet_break:
-	__get_cpu_var(netdev_rx_stat).time_squeeze++;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	goto out;
 }
 
 static gifconf_func_t * gifconf_list [NPROTO];
@@ -3980,10 +4036,9 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
-		set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
-		queue->backlog_dev.weight = weight_p;
-		queue->backlog_dev.poll = process_backlog;
-		atomic_set(&queue->backlog_dev.refcnt, 1);
+
+		queue->backlog.weight = weight_p;
+		queue->backlog.poll = process_backlog;
 	}
 
 	netdev_dma_register();
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5c19b06..79159db 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -216,20 +216,6 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
-NETDEVICE_SHOW(weight, fmt_dec);
-
-static int change_weight(struct net_device *net, unsigned long new_weight)
-{
-	net->weight = new_weight;
-	return 0;
-}
-
-static ssize_t store_weight(struct device *dev, struct device_attribute *attr,
-			    const char *buf, size_t len)
-{
-	return netdev_store(dev, attr, buf, len, change_weight);
-}
-
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -246,7 +232,6 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
-	__ATTR(weight, S_IRUGO | S_IWUSR, show_weight, store_weight),
 	{}
 };
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index de1b26a..549ffd5 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -46,7 +46,6 @@ static atomic_t trapped;
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
-static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
 static void queue_process(struct work_struct *work)
@@ -114,24 +113,26 @@ static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
  * In cases where there is bi-directional communications, reading only
  * one message at a time can lead to packets being dropped by the
  * network adapter, forcing superfluous retries and possibly timeouts.
- * Thus, we set our budget to greater than 1.
  */
 static void poll_napi(struct netpoll *np)
 {
-	struct netpoll_info *npinfo = np->dev->npinfo;
-	int budget = 16;
+	struct net_device *dev = np->dev;
+	struct netpoll_info *npinfo = dev->npinfo;
+	struct napi_struct *napi = &dev->napi;
 
-	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    npinfo->poll_owner != smp_processor_id() &&
-	    spin_trylock(&npinfo->poll_lock)) {
+	if (napi->poll && test_bit(NAPI_STATE_SCHED, &napi->state) && napi_trylock(napi)) {
 		npinfo->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
-		np->dev->poll(np->dev, &budget);
+		list_del(&napi->poll_list);
+
+		napi->poll(napi, napi->quota);
+		if (test_bit(NAPI_STATE_SCHED, &napi->state))
+			__napi_schedule(napi);
 
 		atomic_dec(&trapped);
 		npinfo->rx_flags &= ~NETPOLL_RX_DROP;
-		spin_unlock(&npinfo->poll_lock);
+		napi_unlock(napi);
 	}
 }
 
@@ -150,6 +151,9 @@ static void service_arp_queue(struct netpoll_info *npi)
 	}
 }
 
+extern void netpoll_zap_completion_queue(void);
+
+
 void netpoll_poll(struct netpoll *np)
 {
 	if (!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
@@ -157,12 +161,11 @@ void netpoll_poll(struct netpoll *np)
 
 	/* Process pending work on NIC */
 	np->dev->poll_controller(np->dev);
-	if (np->dev->poll)
-		poll_napi(np);
+	poll_napi(np);
 
 	service_arp_queue(np->dev->npinfo);
 
-	zap_completion_queue();
+	netpoll_zap_completion_queue();
 }
 
 static void refill_skbs(void)
@@ -181,38 +184,12 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
-static void zap_completion_queue(void)
-{
-	unsigned long flags;
-	struct softnet_data *sd = &get_cpu_var(softnet_data);
-
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
-
-		local_irq_save(flags);
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
-		local_irq_restore(flags);
-
-		while (clist != NULL) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
-			if (skb->destructor)
-				dev_kfree_skb_any(skb); /* put this one back */
-			else
-				__kfree_skb(skb);
-		}
-	}
-
-	put_cpu_var(softnet_data);
-}
-
 static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
 	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
+	netpoll_zap_completion_queue();
 	refill_skbs();
 repeat:
 
@@ -246,8 +223,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	}
 
 	/* don't get messages out of order, and no recursion */
-	if (skb_queue_len(&npinfo->txq) == 0 &&
-		    npinfo->poll_owner != smp_processor_id()) {
+	if (skb_queue_len(&npinfo->txq) == 0) {
 		unsigned long flags;
 
 		local_irq_save(flags);
@@ -652,8 +628,6 @@ int netpoll_setup(struct netpoll *np)
 
 		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
-		spin_lock_init(&npinfo->poll_lock);
-		npinfo->poll_owner = -1;
 
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 06eccca..b6b3618 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -634,7 +634,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
 	NLA_PUT_U8(skb, IFLA_OPERSTATE,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
@@ -834,9 +833,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
-	if (tb[IFLA_WEIGHT])
-		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
-
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
@@ -1072,8 +1068,6 @@ replay:
 			       nla_len(tb[IFLA_BROADCAST]));
 		if (tb[IFLA_TXQLEN])
 			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
-		if (tb[IFLA_WEIGHT])
-			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
 		if (tb[IFLA_OPERSTATE])
 			set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 		if (tb[IFLA_LINKMODE])
