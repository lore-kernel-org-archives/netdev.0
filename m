From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Resurrect napi_poll patch.
Date: Fri, 20 Jul 2007 22:31:29 -0700 (PDT)
Message-ID: <20070720.223129.59470764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, rusty@rustcorp.com.au,
	jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753739AbXGUFbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 01:31:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stephen asked me if I could resurrect the last version of
his napi_poll patch that I posted a long time ago, I finally
got to that tonight.

Basically, this disconnects the ->poll() object from the net
device.  This will allow drivers to handle multi RX queues
cleanly without creating fake net_device objects and crap
like that.

Good candidates for taking advantage of multi-napi are:

1) e1000
2) ucc_geth
3) ehea
4) sunvnet

In fact there are probably several others.

I plan to do a sunvnet NAPI'ification so I can test this patch
out further.  I'll post that once I get it working.

[ Rusty this is the stuff I was talking to you about several
  weeks ago, feel free to try and use it for your virt I/O
  layer.  ]

I converted every driver I could find using NAPI under drivers/net
but I wasn't able to build check many of them and certainly don't
have the hardware to test.

I need people's help with build verifications, review, and testing
where at all possible.  It is very appreciated, and I'd like to
merge this in soon because more and more we'll have devices that
need this in one way or another.

One area for discussion is what to do about rtnetlink, it allows
setting the dev->napi.weight, but we need to extend it so it can
do something sane in multi-napi-per-netdev situations.

Thanks!

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

By default the napi_struct embedded in the netdevice is used, so
most traditional NAPI poll implementations will then startoff
with:

	struct net_device *dev = container_of(napi, struct net_device, napi);

Most of the transformations are thus mechanical in nature.

[ Ported to current tree and more drivers converted.  -DaveM ]

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e970e64..7a2d913 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -501,12 +501,12 @@ static inline unsigned int cp_rx_csum_ok (u32 status)
 	return 0;
 }
 
-static int cp_rx_poll (struct net_device *dev, int *budget)
+static int cp_rx_poll (struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct cp_private *cp = netdev_priv(dev);
-	unsigned rx_tail = cp->rx_tail;
-	unsigned rx_work = dev->quota;
-	unsigned rx;
+	unsigned int rx_tail = cp->rx_tail;
+	int rx;
 
 rx_status_loop:
 	rx = 0;
@@ -588,19 +588,16 @@ rx_next:
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
@@ -610,11 +607,9 @@ rx_next:
 		cpw16_f(IntrMask, cp_intr_mask);
 		__netif_rx_complete(dev);
 		local_irq_restore(flags);
-
-		return 0;	/* done */
 	}
 
-	return 1;		/* not done */
+	return rx;
 }
 
 static irqreturn_t cp_interrupt (int irq, void *dev_instance)
@@ -1934,11 +1929,11 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hard_start_xmit = cp_start_xmit;
 	dev->get_stats = cp_get_stats;
 	dev->do_ioctl = cp_ioctl;
-	dev->poll = cp_rx_poll;
+	dev->napi.poll = cp_rx_poll;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = cp_poll_controller;
 #endif
-	dev->weight = 16;	/* arbitrary? from NAPI_HOWTO.txt. */
+	dev->napi.weight = 16;	/* arbitrary? from NAPI_HOWTO.txt. */
 #ifdef BROKEN
 	dev->change_mtu = cp_change_mtu;
 #endif
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 327eaa7..5174a8e 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -625,7 +625,7 @@ static void rtl8139_tx_timeout (struct net_device *dev);
 static void rtl8139_init_ring (struct net_device *dev);
 static int rtl8139_start_xmit (struct sk_buff *skb,
 			       struct net_device *dev);
-static int rtl8139_poll(struct net_device *dev, int *budget);
+static int rtl8139_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void rtl8139_poll_controller(struct net_device *dev);
 #endif
@@ -976,8 +976,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->open = rtl8139_open;
 	dev->hard_start_xmit = rtl8139_start_xmit;
-	dev->poll = rtl8139_poll;
-	dev->weight = 64;
+	dev->napi.poll = rtl8139_poll;
+	dev->napi.weight = 64;
 	dev->stop = rtl8139_close;
 	dev->get_stats = rtl8139_get_stats;
 	dev->set_multicast_list = rtl8139_set_rx_mode;
@@ -2103,26 +2103,19 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
 	}
 }
 
-static int rtl8139_poll(struct net_device *dev, int *budget)
+static int rtl8139_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct rtl8139_private *tp = netdev_priv(dev);
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
@@ -2135,7 +2128,7 @@ static int rtl8139_poll(struct net_device *dev, int *budget)
 	}
 	spin_unlock(&tp->rx_lock);
 
-	return !done;
+	return work_done;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index a61b2f8..0e9f738 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -723,8 +723,9 @@ static int amd8111e_tx(struct net_device *dev)
 
 #ifdef CONFIG_AMD8111E_NAPI
 /* This function handles the driver receive operation in polling mode */
-static int amd8111e_rx_poll(struct net_device *dev, int * budget)
+static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int rx_index = lp->rx_idx & RX_RING_DR_MOD_MASK;
 	void __iomem *mmio = lp->mmio;
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
 	netif_rx_complete(dev);
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
@@ -2031,8 +2025,8 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	dev->tx_timeout = amd8111e_tx_timeout;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
 #ifdef CONFIG_AMD8111E_NAPI
-	dev->poll = amd8111e_rx_poll;
-	dev->weight = 32;
+	dev->napi.poll = amd8111e_rx_poll;
+	dev->napi.weight = 32;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = amd8111e_poll;
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index f6ece1d..1570957 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -190,15 +190,11 @@ static struct net_device_stats *ep93xx_get_stats(struct net_device *dev)
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
@@ -211,10 +207,8 @@ static int ep93xx_rx(struct net_device *dev, int *budget)
 
 		rstat0 = rstat->rstat0;
 		rstat1 = rstat->rstat1;
-		if (!(rstat0 & RSTAT0_RFP) || !(rstat1 & RSTAT1_RFP)) {
-			rx_done = 1;
+		if (!(rstat0 & RSTAT0_RFP) || !(rstat1 & RSTAT1_RFP))
 			break;
-		}
 
 		rstat->rstat0 = 0;
 		rstat->rstat1 = 0;
@@ -275,8 +269,6 @@ static int ep93xx_rx(struct net_device *dev, int *budget)
 err:
 		ep->rx_pointer = (entry + 1) & (RX_QUEUE_ENTRIES - 1);
 		processed++;
-		dev->quota--;
-		(*budget)--;
 	}
 
 	if (processed) {
@@ -284,7 +276,7 @@ err:
 		wrw(ep, REG_RXSTSENQ, processed);
 	}
 
-	return !rx_done;
+	return processed;
 }
 
 static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
@@ -293,36 +285,38 @@ static int ep93xx_have_more_rx(struct ep93xx_priv *ep)
 	return !!((rstat->rstat0 & RSTAT0_RFP) && (rstat->rstat1 & RSTAT1_RFP));
 }
 
-static int ep93xx_poll(struct net_device *dev, int *budget)
+static int ep93xx_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct ep93xx_priv *ep = netdev_priv(dev);
+	int rx;
 
 	/*
 	 * @@@ Have to stop polling if device is downed while we
 	 * are polling.
 	 */
 
+	rx = 0;
 poll_some_more:
-	if (ep93xx_rx(dev, budget))
-		return 1;
+	rx = ep93xx_rx(dev, rx, budget);
 
-	netif_rx_complete(dev);
-
-	spin_lock_irq(&ep->rx_lock);
-	wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
-	if (ep93xx_have_more_rx(ep)) {
-		wrl(ep, REG_INTEN, REG_INTEN_TX);
-		wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
-		spin_unlock_irq(&ep->rx_lock);
+	if (rx < budget) {
+		netif_rx_complete(dev);
 
-		if (netif_rx_reschedule(dev, 0))
-			goto poll_some_more;
+		spin_lock_irq(&ep->rx_lock);
+		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
+		if (ep93xx_have_more_rx(ep)) {
+			wrl(ep, REG_INTEN, REG_INTEN_TX);
+			wrl(ep, REG_INTSTSP, REG_INTSTS_RX);
+			spin_unlock_irq(&ep->rx_lock);
 
-		return 0;
+			if (netif_rx_reschedule(dev, 0))
+				goto poll_some_more;
+		} else
+			spin_unlock_irq(&ep->rx_lock);
 	}
-	spin_unlock_irq(&ep->rx_lock);
 
-	return 0;
+	return rx;
 }
 
 static int ep93xx_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -788,14 +782,14 @@ struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 
 	dev->get_stats = ep93xx_get_stats;
 	dev->ethtool_ops = &ep93xx_ethtool_ops;
-	dev->poll = ep93xx_poll;
+	dev->napi.poll = ep93xx_poll;
+	dev->napi.weight = 64;
 	dev->hard_start_xmit = ep93xx_xmit;
 	dev->open = ep93xx_open;
 	dev->stop = ep93xx_close;
 	dev->do_ioctl = ep93xx_ioctl;
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->weight = 64;
 
 	return dev;
 }
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 37f1b6f..f080452 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -848,10 +848,11 @@ static int b44_rx(struct b44 *bp, int budget)
 	return received;
 }
 
-static int b44_poll(struct net_device *netdev, int *budget)
+static int b44_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct b44 *bp = netdev_priv(netdev);
-	int done;
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
+	if (work_done < budget) {
 		netif_rx_complete(netdev);
 		b44_enable_ints(bp);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static irqreturn_t b44_interrupt(int irq, void *dev_id)
@@ -2195,8 +2183,8 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = b44_set_mac_addr;
 	dev->do_ioctl = b44_ioctl;
 	dev->tx_timeout = b44_tx_timeout;
-	dev->poll = b44_poll;
-	dev->weight = 64;
+	dev->napi.poll = b44_poll;
+	dev->napi.weight = 64;
 	dev->watchdog_timeo = B44_TX_TIMEOUT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = b44_poll_controller;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a729da0..5dd6b84 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2632,12 +2632,14 @@ bnx2_has_work(struct bnx2 *bp)
 }
 
 static int
-bnx2_poll(struct net_device *dev, int *budget)
+bnx2_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct bnx2 *bp = netdev_priv(dev);
 	struct status_block *sblk = bp->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
+	int work_done = 0;
 
 	if ((status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (status_attn_bits_ack & STATUS_ATTN_EVENTS)) {
@@ -2655,17 +2657,8 @@ bnx2_poll(struct net_device *dev, int *budget)
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
@@ -6856,9 +6848,9 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef BCM_VLAN
 	dev->vlan_rx_register = bnx2_vlan_rx_register;
 #endif
-	dev->poll = bnx2_poll;
+	dev->napi.weight = 64;
+	dev->napi.poll = bnx2_poll;
 	dev->ethtool_ops = &bnx2_ethtool_ops;
-	dev->weight = 64;
 
 	bp = netdev_priv(dev);
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f6e4030..95f8333 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2607,8 +2607,9 @@ static irqreturn_t cas_interrupt(int irq, void *dev_id)
 
 
 #ifdef USE_NAPI
-static int cas_poll(struct net_device *dev, int *budget)
+static int cas_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct cas *cp = netdev_priv(dev);
 	int i, enable_intr, todo, credits;
 	u32 status = readl(cp->regs + REG_INTR_STATUS);
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
@@ -2676,9 +2672,8 @@ rx_comp:
 	if (enable_intr) {
 		netif_rx_complete(dev);
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
+	dev->napi.poll = cas_poll;
+	dev->napi.weight = 64;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = cas_netpoll;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..976d8d4 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1113,8 +1113,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->poll_controller = t1_netpoll;
 #endif
 #ifdef CONFIG_CHELSIO_T1_NAPI
-		netdev->weight = 64;
-		netdev->poll = t1_poll;
+		netdev->napi.weight = 64;
+		netdev->napi.poll = t1_poll;
 #endif
 
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index e4f874a..987ddad 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1620,23 +1620,20 @@ static int process_pure_responses(struct adapter *adapter)
  * or protection from interrupts as data interrupts are off at this point and
  * other adapter interrupts do not interfere.
  */
-int t1_poll(struct net_device *dev, int *budget)
+int t1_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct adapter *adapter = dev->priv;
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
+		netif_rx_complete(dev);
+		writel(adapter->sge->respQ.cidx,
+		       adapter->regs + A_SG_SLEEPING);
+	}
+	return work_done;
 }
 
 /*
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
index d132a0e..c40b202 100644
--- a/drivers/net/chelsio/sge.h
+++ b/drivers/net/chelsio/sge.h
@@ -77,7 +77,7 @@ int t1_sge_configure(struct sge *, struct sge_params *);
 int t1_sge_set_coalesce_params(struct sge *, struct sge_params *);
 void t1_sge_destroy(struct sge *);
 irqreturn_t t1_interrupt(int irq, void *cookie);
-int t1_poll(struct net_device *, int *);
+int t1_poll(struct napi_struct *, int );
 
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void t1_set_vlan_accel(struct adapter *adapter, int on_off);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd1e52..1515d14 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -363,7 +363,7 @@ static int init_dummy_netdevs(struct adapter *adap)
 					goto free_all;
 
 				nd->priv = adap;
-				nd->weight = 64;
+				nd->napi.weight = 64;
 				set_bit(__LINK_STATE_START, &nd->state);
 				adap->dummy_netdev[dummy_idx] = nd;
 			}
@@ -393,15 +393,13 @@ static void quiesce_rx(struct adapter *adap)
 
 	for_each_port(adap, i) {
 		dev = adap->port[i];
-		while (test_bit(__LINK_STATE_RX_SCHED, &dev->state))
-			msleep(1);
+		napi_disable(&dev->napi);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(adap->dummy_netdev); i++) {
 		dev = adap->dummy_netdev[i];
 		if (dev)
-			while (test_bit(__LINK_STATE_RX_SCHED, &dev->state))
-				msleep(1);
+			napi_disable(&dev->napi);
 	}
 }
 
@@ -2463,7 +2461,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = cxgb_netpoll;
 #endif
-		netdev->weight = 64;
+		netdev->napi.weight = 64;
 
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index a2cfd68..0a9ec9c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1673,33 +1673,31 @@ static inline void deliver_partial_bundle(struct t3cdev *tdev,
  *	receive handler.  Batches need to be of modest size as we do prefetches
  *	on the packets in each.
  */
-static int ofld_poll(struct net_device *dev, int *budget)
+static int ofld_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct adapter *adapter = dev->priv;
 	struct sge_qset *qs = dev2qset(dev);
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
 			__netif_rx_complete(dev);
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
@@ -1721,10 +1719,8 @@ static int ofld_poll(struct net_device *dev, int *budget)
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
@@ -2073,36 +2069,36 @@ static inline int is_pure_response(const struct rsp_desc *r)
  *
  *	Handler for new data events when using NAPI.
  */
-static int napi_rx_handler(struct net_device *dev, int *budget)
+static int napi_rx_handler(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct adapter *adap = dev->priv;
 	struct sge_qset *qs = dev2qset(dev);
-	int effective_budget = min(*budget, dev->quota);
-
+	int effective_budget = budget;
 	int work_done = process_responses(adap, qs, effective_budget);
-	*budget -= work_done;
-	dev->quota -= work_done;
 
-	if (work_done >= effective_budget)
-		return 1;
-
-	netif_rx_complete(dev);
+	if (likely(work_done < effective_budget)) {
+		netif_rx_complete(dev);
 
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
@@ -2110,7 +2106,7 @@ static int napi_rx_handler(struct net_device *dev, int *budget)
  */
 static inline int napi_is_scheduled(struct net_device *dev)
 {
-	return test_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	return test_bit(NAPI_STATE_SCHED, &dev->napi.state);
 }
 
 /**
@@ -2560,7 +2556,7 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
 
 	qs->rspq.holdoff_tmr = max(p->coalesce_usecs * 10, 1U);/* can't be 0 */
 	qs->rspq.polling = p->polling;
-	qs->netdev->poll = p->polling ? napi_rx_handler : ofld_poll;
+	qs->netdev->napi.poll = p->polling ? napi_rx_handler : ofld_poll;
 }
 
 /**
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 6b6401e..2afb6b5 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1982,27 +1982,23 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int e100_poll(struct net_device *netdev, int *budget)
+static int e100_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct nic *nic = netdev_priv(netdev);
-	unsigned int work_to_do = min(netdev->quota, *budget);
-	unsigned int work_done = 0;
+	int work_done = 0;
 	int tx_cleaned;
 
-	e100_rx_clean(nic, &work_done, work_to_do);
+	e100_rx_clean(nic, &work_done, budget);
 	tx_cleaned = e100_tx_clean(nic);
 
 	/* If no Rx and Tx cleanup work was done, exit polling mode. */
 	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
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
@@ -2573,8 +2569,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->tx_timeout = e100_tx_timeout;
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-	netdev->poll = e100_poll;
-	netdev->weight = E100_NAPI_WEIGHT;
+	netdev->napi.poll = e100_poll;
+	netdev->napi.weight = E100_NAPI_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f48b659..7ba8434 100644
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
@@ -932,8 +932,8 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_E1000_NAPI
-	netdev->poll = &e1000_clean;
-	netdev->weight = 64;
+	netdev->napi.poll = &e1000_clean;
+	netdev->napi.weight = 64;
 #endif
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
@@ -1319,8 +1319,8 @@ e1000_sw_init(struct e1000_adapter *adapter)
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		adapter->polling_netdev[i].priv = adapter;
-		adapter->polling_netdev[i].poll = &e1000_clean;
-		adapter->polling_netdev[i].weight = 64;
+		adapter->polling_netdev[i].napi.poll = &e1000_clean;
+		adapter->polling_netdev[i].napi.weight = 64;
 		dev_hold(&adapter->polling_netdev[i]);
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
@@ -3918,10 +3918,10 @@ e1000_intr(int irq, void *data)
  **/
 
 static int
-e1000_clean(struct net_device *poll_dev, int *budget)
+e1000_clean(struct napi_struct *napi, int budget)
 {
+	struct net_device *poll_dev = container_of(napi, struct net_device, napi);
 	struct e1000_adapter *adapter;
-	int work_to_do = min(*budget, poll_dev->quota);
 	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
@@ -3942,23 +3942,19 @@ e1000_clean(struct net_device *poll_dev, int *budget)
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
 		netif_rx_complete(poll_dev);
 		e1000_irq_enable(adapter);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 #endif
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4c70a93..ee8a4ee 100644
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
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct ehea_port_res *pr = dev->priv;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
-	int force_irq, wqe_index;
+	int force_irq, wqe_index, rx;
 
 	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 	cqe_skb = ehea_poll_cq(pr->send_cq);
@@ -580,13 +579,13 @@ static int ehea_poll(struct net_device *dev, int *budget)
 			return 0;
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
@@ -1211,8 +1210,8 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 	if (!pr->d_netdev)
 		goto out_free;
 	pr->d_netdev->priv = pr;
-	pr->d_netdev->weight = 64;
-	pr->d_netdev->poll = ehea_poll;
+	pr->d_netdev->napi.weight = 64;
+	pr->d_netdev->napi.poll = ehea_poll;
 	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
 	strcpy(pr->d_netdev->name, port->netdev->name);
 
@@ -2626,8 +2625,8 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
-	dev->poll = ehea_poll;
-	dev->weight = 64;
+	dev->napi.poll = ehea_poll;
+	dev->napi.weight = 64;
 	dev->stop = ehea_stop;
 	dev->hard_start_xmit = ehea_start_xmit;
 	dev->get_stats = ehea_get_stats;
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1197784..5b0898c 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -294,7 +294,7 @@ static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int epic_rx(struct net_device *dev, int budget);
-static int epic_poll(struct net_device *dev, int *budget);
+static int epic_poll(struct napi_struct *napi, int budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -487,8 +487,8 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
-	dev->poll = epic_poll;
-	dev->weight = 64;
+	dev->napi.poll = epic_poll;
+	dev->napi.weight = 64;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -1257,26 +1257,22 @@ static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
 		outw(RxQueued, ioaddr + COMMAND);
 }
 
-static int epic_poll(struct net_device *dev, int *budget)
+static int epic_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct epic_private *ep = dev->priv;
-	int work_done = 0, orig_budget;
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
 
@@ -1298,7 +1294,7 @@ rx_action:
 			goto rx_action;
 	}
 
-	return (work_done >= orig_budget);
+	return work_done;
 }
 
 static int epic_close(struct net_device *dev)
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index e5502af..54c626f 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -465,7 +465,7 @@ void fec_stop(struct net_device *dev)
 }
 
 /* common receive function */
-static int fec_enet_rx_common(struct net_device *dev, int *budget)
+static int fec_enet_rx_common(struct net_device *dev, int budget)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	fec_t *fecp = fep->fecp;
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
+		if (fpi->use_napi && received >= budget)
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
+			netif_rx_complete(dev);
 
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
@@ -955,8 +946,9 @@ static struct net_device_stats *fec_enet_get_stats(struct net_device *dev)
 	return &fep->stats;
 }
 
-static int fec_enet_poll(struct net_device *dev, int *budget)
+static int fec_enet_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	return fec_enet_rx_common(dev, budget);
 }
 
@@ -1173,8 +1165,8 @@ int fec_8xx_init_one(const struct fec_platform_info *fpi,
 	dev->set_multicast_list = fec_set_multicast_list;
 	dev->set_mac_address = fec_set_mac_address;
 	if (fpi->use_napi) {
-		dev->poll = fec_enet_poll;
-		dev->weight = fpi->napi_weight;
+		dev->napi.poll = fec_enet_poll;
+		dev->napi.weight = fpi->napi_weight;
 	}
 	dev->ethtool_ops = &fec_ethtool_ops;
 	dev->do_ioctl = fec_ioctl;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 6d1d50a..d1cdf32 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3244,19 +3244,19 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 }
 
 #ifdef CONFIG_FORCEDETH_NAPI
-static int nv_napi_poll(struct net_device *dev, int *budget)
+static int nv_napi_poll(struct napi_struct *napi, int budget)
 {
-	int pkts, limit = min(*budget, dev->quota);
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct fe_priv *np = netdev_priv(dev);
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
 
@@ -3267,7 +3267,7 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
-	if (pkts < limit) {
+	if (pkts < budget) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
@@ -3281,13 +3281,8 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
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
 
@@ -5155,9 +5150,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = nv_poll_controller;
 #endif
-	dev->weight = RX_WORK_PER_LOOP;
+	dev->napi.weight = RX_WORK_PER_LOOP;
 #ifdef CONFIG_FORCEDETH_NAPI
-	dev->poll = nv_napi_poll;
+	dev->napi.poll = nv_napi_poll;
 #endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a4a2a0e..864e00d 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -70,8 +70,9 @@ static void fs_set_multicast_list(struct net_device *dev)
 }
 
 /* NAPI receive function */
-static int fs_enet_rx_napi(struct net_device *dev, int *budget)
+static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct fs_enet_private *fep = netdev_priv(dev);
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t *bdp;
@@ -79,9 +80,6 @@ static int fs_enet_rx_napi(struct net_device *dev, int *budget)
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
+		netif_rx_complete(dev);
+		(*fep->ops->napi_enable_rx)(dev);
+	}
+	return received;
 }
 
 /* non NAPI receive function */
@@ -1048,8 +1037,8 @@ static struct net_device *fs_init_instance(struct device *dev,
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
 	if (fpi->use_napi) {
-		ndev->poll = fs_enet_rx_napi;
-		ndev->weight = fpi->napi_weight;
+		ndev->napi.poll = fs_enet_rx_napi;
+		ndev->napi.weight = fpi->napi_weight;
 	}
 	ndev->ethtool_ops = &fs_ethtool_ops;
 	ndev->do_ioctl = fs_ioctl;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f926905..fdf8c6b 100644
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
@@ -262,8 +262,8 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->tx_timeout = gfar_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_GFAR_NAPI
-	dev->poll = gfar_poll;
-	dev->weight = GFAR_DEV_WEIGHT;
+	dev->napi.poll = gfar_poll;
+	dev->napi.weight = GFAR_DEV_WEIGHT;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = gfar_netpoll;
@@ -1569,22 +1569,15 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 }
 
 #ifdef CONFIG_GFAR_NAPI
-static int gfar_poll(struct net_device *dev, int *budget)
+static int gfar_poll(struct napi_struct *napi, int budget)
 {
-	int howmany;
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct gfar_private *priv = netdev_priv(dev);
-	int rx_work_limit = *budget;
-
-	if (rx_work_limit > dev->quota)
-		rx_work_limit = dev->quota;
-
-	howmany = gfar_clean_rx_ring(dev, rx_work_limit);
+	int howmany;
 
-	dev->quota -= howmany;
-	rx_work_limit -= howmany;
-	*budget -= howmany;
+	howmany = gfar_clean_rx_ring(dev, budget);
 
-	if (rx_work_limit > 0) {
+	if (howmany < budget) {
 		netif_rx_complete(dev);
 
 		/* Clear the halt bit in RSTAT */
@@ -1601,8 +1594,7 @@ static int gfar_poll(struct net_device *dev, int *budget)
 			gfar_write(&priv->regs->rxic, 0);
 	}
 
-	/* Return 1 if there's more work to do */
-	return (rx_work_limit > 0) ? 0 : 1;
+	return howmany;
 }
 #endif
 
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index d96eb72..41b26e4 100644
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
@@ -767,80 +767,70 @@ out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	return 0;
 }
 
-static int ibmveth_poll(struct net_device *netdev, int *budget)
+static int ibmveth_poll(struct napi_struct *napi, int *budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct ibmveth_adapter *adapter = netdev->priv;
-	int max_frames_to_process = netdev->quota;
 	int frames_processed = 0;
 	int more_work = 1;
 	unsigned long lpar_rc;
 
- restart_poll:
+restart_poll:
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
+	if (frames_processed < budget) {
+		/* We think we are done - reenable interrupts,
+		 * then check once more to make sure we are done.
+		 */
+		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
+				       VIO_IRQ_ENABLE);
 
-	ibmveth_assert(lpar_rc == H_SUCCESS);
+		ibmveth_assert(lpar_rc == H_SUCCESS);
 
-	netif_rx_complete(netdev);
+		netif_rx_complete(netdev);
 
-	if(ibmveth_rxq_pending_buffer(adapter) && netif_rx_reschedule(netdev, frames_processed))
-	{
-		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
-		ibmveth_assert(lpar_rc == H_SUCCESS);
-		more_work = 1;
-		goto restart_poll;
+		if (ibmveth_rxq_pending_buffer(adapter) &&
+		    netif_rx_reschedule(netdev, frames_processed)) {
+			lpar_rc = h_vio_signal(adapter->vdev->unit_address,
+					       VIO_IRQ_DISABLE);
+			ibmveth_assert(lpar_rc == H_SUCCESS);
+			goto restart_poll;
+		}
 	}
 
-	netdev->quota -= frames_processed;
-	*budget -= frames_processed;
-
-	/* we really are done */
-	return 0;
+	return frames_processed;
 }
 
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
@@ -1021,8 +1011,8 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 
 	netdev->irq = dev->irq;
 	netdev->open               = ibmveth_open;
-	netdev->poll               = ibmveth_poll;
-	netdev->weight             = 16;
+	netdev->napi.poll          = ibmveth_poll;
+	netdev->napi.weight        = 16;
 	netdev->stop               = ibmveth_close;
 	netdev->hard_start_xmit    = ibmveth_start_xmit;
 	netdev->get_stats          = ibmveth_get_stats;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 991c883..80482b3 100644
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
@@ -421,8 +421,8 @@ ixgb_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_IXGB_NAPI
-	netdev->poll = &ixgb_clean;
-	netdev->weight = 64;
+	netdev->napi.poll = &ixgb_clean;
+	netdev->napi.weight = 64;
 #endif
 	netdev->vlan_rx_register = ixgb_vlan_rx_register;
 	netdev->vlan_rx_add_vid = ixgb_vlan_rx_add_vid;
@@ -1776,27 +1776,23 @@ ixgb_intr(int irq, void *data)
  **/
 
 static int
-ixgb_clean(struct net_device *netdev, int *budget)
+ixgb_clean(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
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
 		netif_rx_complete(netdev);
 		ixgb_irq_enable(adapter);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 #endif
 
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index d9ce1ae..46415f4 100644
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
@@ -122,29 +122,33 @@ static int ixpdev_rx(struct net_device *dev, int *budget)
 
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
+	struct net_device *dev = container_of(napi, struct net_device, napi);
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
 
 	netif_rx_complete(dev);
 	ixp2000_reg_write(IXP2000_IRQ_THD_ENABLE_SET_A_0, 0x00ff);
 
-	return 0;
+	return rx;
 }
 
 static void ixpdev_tx_complete(void)
@@ -274,7 +278,8 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 		return NULL;
 
 	dev->hard_start_xmit = ixpdev_xmit;
-	dev->poll = ixpdev_poll;
+	dev->napi.poll = ixpdev_poll;
+	dev->napi.weight = 64;
 	dev->open = ixpdev_open;
 	dev->stop = ixpdev_close;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -282,7 +287,6 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 #endif
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->weight = 64;
 
 	ip = netdev_priv(dev);
 	ip->channel = channel;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index a4bb026..3e45934 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -470,15 +470,17 @@ static int macb_rx(struct macb *bp, int budget)
 	return received;
 }
 
-static int macb_poll(struct net_device *dev, int *budget)
+static int macb_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct macb *bp = netdev_priv(dev);
-	int orig_budget, work_done, retval = 0;
+	int work_done;
 	u32 status;
 
 	status = macb_readl(bp, RSR);
 	macb_writel(bp, RSR, status);
 
+	work_done = 0;
 	if (!status) {
 		/*
 		 * This may happen if an interrupt was pending before
@@ -500,17 +502,9 @@ static int macb_poll(struct net_device *dev, int *budget)
 		goto out;
 	}
 
-	orig_budget = *budget;
-	if (orig_budget > dev->quota)
-		orig_budget = dev->quota;
-
-	work_done = macb_rx(bp, orig_budget);
-	if (work_done < orig_budget) {
+	work_done = macb_rx(bp, budget);
+	if (work_done < orig_budget)
 		netif_rx_complete(dev);
-		retval = 0;
-	} else {
-		retval = 1;
-	}
 
 	/*
 	 * We've done what we can to clean the buffers. Make sure we
@@ -521,7 +515,7 @@ out:
 
 	/* TODO: Handle errors */
 
-	return retval;
+	return work_done;
 }
 
 static irqreturn_t macb_interrupt(int irq, void *dev_id)
@@ -1146,8 +1140,8 @@ static int __devinit macb_probe(struct platform_device *pdev)
 	dev->get_stats = macb_get_stats;
 	dev->set_multicast_list = macb_set_rx_mode;
 	dev->do_ioctl = macb_ioctl;
-	dev->poll = macb_poll;
-	dev->weight = 64;
+	dev->napi.poll = macb_poll;
+	dev->napi.weight = 64;
 	dev->ethtool_ops = &macb_ethtool_ops;
 
 	dev->base_addr = regs->start;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..6219459 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1007,11 +1007,12 @@ static int mv643xx_eth_stop(struct net_device *dev)
  *
  * This function is used in case of NAPI
  */
-static int mv643xx_poll(struct net_device *dev, int *budget)
+static int mv643xx_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct mv643xx_private *mp = netdev_priv(dev);
-	int done = 1, orig_budget, work_done;
 	unsigned int port_num = mp->port_num;
+	int work_done;
 
 #ifdef MV643XX_TX_FAST_REFILL
 	if (++mp->tx_clean_threshold > 5) {
@@ -1020,19 +1021,12 @@ static int mv643xx_poll(struct net_device *dev, int *budget)
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
+	if (work_done < budget) {
 		netif_rx_complete(dev);
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
 		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
@@ -1040,7 +1034,7 @@ static int mv643xx_poll(struct net_device *dev, int *budget)
 						ETH_INT_UNMASK_ALL);
 	}
 
-	return done ? 0 : 1;
+	return work_done;
 }
 #endif
 
@@ -1348,8 +1342,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	/* No need to Tx Timeout */
 	dev->tx_timeout = mv643xx_eth_tx_timeout;
 #ifdef MV643XX_NAPI
-	dev->poll = mv643xx_poll;
-	dev->weight = 64;
+	dev->napi.poll = mv643xx_poll;
+	dev->napi.weight = 64;
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index deca653..7672077 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1099,7 +1099,7 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 	}
 }
 
-static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
+static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	unsigned long rx_bytes = 0;
@@ -1108,10 +1108,11 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 
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
@@ -1127,10 +1128,6 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
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
@@ -1144,6 +1141,7 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
 
+	return work_done;
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
@@ -1188,26 +1186,21 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 	}
 }
 
-static int myri10ge_poll(struct net_device *netdev, int *budget)
+static int myri10ge_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
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
 		netif_rx_complete(netdev);
 		put_be32(htonl(3), mgp->irq_claim);
-		return 0;
 	}
-	return 1;
+	return work_done;
 }
 
 static irqreturn_t myri10ge_intr(int irq, void *arg)
@@ -2990,8 +2983,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
-	netdev->poll = myri10ge_poll;
-	netdev->weight = myri10ge_napi_weight;
+	netdev->napi.poll = myri10ge_poll;
+	netdev->napi.weight = myri10ge_napi_weight;
 
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 6bb48ba..5041121 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -636,7 +636,7 @@ static void init_registers(struct net_device *dev);
 static int start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void netdev_error(struct net_device *dev, int intr_status);
-static int natsemi_poll(struct net_device *dev, int *budget);
+static int natsemi_poll(struct napi_struct *napi, int budget);
 static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do);
 static void netdev_tx_done(struct net_device *dev);
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
@@ -931,8 +931,8 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->poll = natsemi_poll;
-	dev->weight = 64;
+	dev->napi.poll = natsemi_poll;
+	dev->napi.weight = 64;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &natsemi_poll_controller;
@@ -2216,12 +2216,11 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 /* This is the NAPI poll routine.  As well as the standard RX handling
  * it also handles all other interrupts that the chip might raise.
  */
-static int natsemi_poll(struct net_device *dev, int *budget)
+static int natsemi_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
-
-	int work_to_do = min(*budget, dev->quota);
 	int work_done = 0;
 
 	do {
@@ -2236,7 +2235,7 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		if (np->intr_status &
 		    (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
 		     IntrRxErr | IntrRxOverrun)) {
-			netdev_rx(dev, &work_done, work_to_do);
+			netdev_rx(dev, &work_done, budget);
 		}
 
 		if (np->intr_status &
@@ -2250,11 +2249,8 @@ static int natsemi_poll(struct net_device *dev, int *budget)
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
@@ -2268,7 +2264,7 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		natsemi_irq_enable(dev);
 	spin_unlock(&np->lock);
 
-	return 0;
+	return work_done;
 }
 
 /* This routine is logically part of the interrupt handler, but separated
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b703ccf..5e32257 100644
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
@@ -423,8 +423,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-	netdev->poll = netxen_nic_poll;
-	netdev->weight = NETXEN_NETDEV_WEIGHT;
+	netdev->napi.poll = netxen_nic_poll;
+	netdev->napi.weight = NETXEN_NETDEV_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = netxen_nic_poll_controller;
 #endif
@@ -1312,14 +1312,13 @@ irqreturn_t netxen_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static int netxen_nic_poll(struct net_device *netdev, int *budget)
+static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
 	int done = 1;
 	int ctx;
-	int this_work_done;
-	int work_done = 0;
+	int work_done;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
 
@@ -1337,16 +1336,11 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
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
@@ -1359,7 +1353,7 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
 		netxen_nic_enable_int(adapter);
 	}
 
-	return !done;
+	return work_done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 0b3066a..11743da 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1047,26 +1047,20 @@ static void pasemi_mac_set_rx_mode(struct net_device *dev)
 }
 
 
-static int pasemi_mac_poll(struct net_device *dev, int *budget)
+static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 {
-	int pkts, limit = min(*budget, dev->quota);
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct pasemi_mac *mac = netdev_priv(dev);
+	int pkts;
 
-	pkts = pasemi_mac_clean_rx(mac, limit);
-
-	dev->quota -= pkts;
-	*budget -= pkts;
-
-	if (pkts < limit) {
+	pkts = pasemi_mac_clean_rx(mac, budget);
+	if (pkts < budget) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
 		pasemi_mac_restart_rx_intr(mac);
-		return 0;
-	} else {
-		/* used up our quantum, so reschedule */
-		return 1;
 	}
+	return pkts;
 }
 
 static int __devinit
@@ -1151,8 +1145,8 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->get_stats = pasemi_mac_get_stats;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->weight = 64;
-	dev->poll = pasemi_mac_poll;
-	dev->features = NETIF_F_HW_CSUM;
+	dev->napi.poll = pasemi_mac_poll;
+	dev->napi.features = NETIF_F_HW_CSUM;
 
 	/* The dma status structure is located in the I/O bridge, and
 	 * is cache coherent.
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 465485a..3a8566f 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -816,7 +816,7 @@ static int pcnet32_set_ringparam(struct net_device *dev,
 	if ((1 << i) != lp->rx_ring_size)
 		pcnet32_realloc_rx_ring(dev, lp, i);
 
-	dev->weight = lp->rx_ring_size / 2;
+	dev->napi.weight = lp->rx_ring_size / 2;
 
 	if (netif_running(dev)) {
 		pcnet32_netif_start(dev);
@@ -1255,7 +1255,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	return;
 }
 
-static int pcnet32_rx(struct net_device *dev, int quota)
+static int pcnet32_rx(struct net_device *dev, int budget)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & lp->rx_mod_mask;
@@ -1263,7 +1263,7 @@ static int pcnet32_rx(struct net_device *dev, int quota)
 	int npackets = 0;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+	while (npackets < budget && (short)le16_to_cpu(rxp->status) >= 0) {
 		pcnet32_rx_entry(dev, lp, rxp, entry);
 		npackets += 1;
 		/*
@@ -1379,15 +1379,16 @@ static int pcnet32_tx(struct net_device *dev)
 }
 
 #ifdef CONFIG_PCNET32_NAPI
-static int pcnet32_poll(struct net_device *dev, int *budget)
+static int pcnet32_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct pcnet32_private *lp = netdev_priv(dev);
-	int quota = min(dev->quota, *budget);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
+	int work_done;
 	u16 val;
 
-	quota = pcnet32_rx(dev, quota);
+	work_done = pcnet32_rx(dev, budget);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	if (pcnet32_tx(dev)) {
@@ -1399,28 +1400,22 @@ static int pcnet32_poll(struct net_device *dev, int *budget)
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	*budget -= quota;
-	dev->quota -= quota;
+	if (work_done < budget) {
+		netif_rx_complete(dev);
 
-	if (dev->quota == 0) {
-		return 1;
-	}
-
-	netif_rx_complete(dev);
-
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
 
@@ -1954,9 +1949,9 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	dev->ethtool_ops = &pcnet32_ethtool_ops;
 	dev->tx_timeout = pcnet32_tx_timeout;
 	dev->watchdog_timeo = (5 * HZ);
-	dev->weight = lp->rx_ring_size / 2;
+	dev->napi.weight = lp->rx_ring_size / 2;
 #ifdef CONFIG_PCNET32_NAPI
-	dev->poll = pcnet32_poll;
+	dev->napi.poll = pcnet32_poll;
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2611,7 +2606,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 			break;
 		}
 #else
-		pcnet32_rx(dev, dev->weight);
+		pcnet32_rx(dev, dev->napi.weight);
 		if (pcnet32_tx(dev)) {
 			/* reset the chip to clear the error condition, then restart */
 			lp->a.reset(ioaddr);
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 08d2506..0acdb0e 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -941,32 +941,24 @@ refill:
  * if the quota is exceeded, but the driver has still packets.
  *
  */
-static int gelic_net_poll(struct net_device *netdev, int *budget)
+static int gelic_net_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct gelic_net_card *card = netdev_priv(netdev);
-	int packets_to_do, packets_done = 0;
-	int no_more_packets = 0;
+	int packets_done = 0;
 
-	packets_to_do = min(*budget, netdev->quota);
-
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
+
+	if (packets_done < budget) {
 		netif_rx_complete(netdev);
 		gelic_net_rx_irq_on(card);
-		return 0;
-	} else
-		return 1;
+	}
+	return packets_done;
 }
 
 /**
@@ -1327,8 +1319,8 @@ static void gelic_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->tx_timeout = &gelic_net_tx_timeout;
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
-	netdev->poll = &gelic_net_poll;
-	netdev->weight = GELIC_NET_NAPI_WEIGHT;
+	netdev->napi.poll = &gelic_net_poll;
+	netdev->napi.weight = GELIC_NET_NAPI_WEIGHT;
 #ifdef GELIC_NET_ETHTOOL
 	netdev->ethtool_ops = &gelic_net_ethtool_ops;
 #endif
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 8be8be4..719481e 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2304,10 +2304,10 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 	return work_done;
 }
 
-static int ql_poll(struct net_device *ndev, int *budget)
+static int ql_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *ndev = container_of(napi, struct net_device, napi);
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	int work_to_do = min(*budget, ndev->quota);
 	int rx_cleaned = 0, tx_cleaned = 0;
 	unsigned long hw_flags;
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
@@ -2315,11 +2315,9 @@ static int ql_poll(struct net_device *ndev, int *budget)
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
 		netif_rx_complete(ndev);
@@ -2332,9 +2330,8 @@ quit_polling:
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
 		ql_enable_interrupts(qdev);
-		return 0;
 	}
-	return 1;
+	return tx_cleaned + rx_cleaned;
 }
 
 static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
@@ -4055,8 +4052,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->tx_timeout = ql3xxx_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
 
-	ndev->poll = &ql_poll;
-	ndev->weight = 64;
+	ndev->napi.poll = &ql_poll;
+	ndev->napi.weight = 64;
 
 	ndev->irq = pdev->irq;
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bb6896a..346f814 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -443,13 +443,13 @@ static void rtl_set_rx_mode(struct net_device *dev);
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
@@ -1648,8 +1648,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->set_mac_address = rtl_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
-	dev->poll = rtl8169_poll;
-	dev->weight = R8169_NAPI_WEIGHT;
+	dev->napi.poll = rtl8169_poll;
+	dev->napi.weight = R8169_NAPI_WEIGHT;
 #endif
 
 #ifdef CONFIG_R8169_VLAN
@@ -2304,7 +2304,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_wait_for_quiescence(dev);
 
-	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr);
+	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
 	rtl8169_tx_clear(tp);
 
 	if (tp->dirty_rx == tp->cur_rx) {
@@ -2609,14 +2609,14 @@ out:
 
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
@@ -2774,7 +2774,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 #else
 		/* Rx interrupt */
 		if (status & (RxOK | RxOverflow | RxFIFOOver))
-			rtl8169_rx_interrupt(dev, tp, ioaddr);
+			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
 
 		/* Tx interrupt */
 		if (status & (TxOK | TxErr))
@@ -2797,19 +2797,17 @@ out:
 }
 
 #ifdef CONFIG_R8169_NAPI
-static int rtl8169_poll(struct net_device *dev, int *budget)
+static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
-	unsigned int work_done, work_to_do = min(*budget, dev->quota);
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	int work_done;
 
-	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
+	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done < work_to_do) {
+	if (work_done < budget) {
 		netif_rx_complete(dev);
 		tp->intr_mask = 0xffff;
 		/*
@@ -2822,7 +2820,7 @@ static int rtl8169_poll(struct net_device *dev, int *budget)
 		RTL_W16(IntrMask, tp->intr_event);
 	}
 
-	return (work_done >= work_to_do);
+	return work_done;
 }
 #endif
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index afef6c0..99a24bf 100644
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
@@ -2615,8 +2615,9 @@ static void free_rx_buffers(struct s2io_nic *sp)
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-static int s2io_poll(struct net_device *dev, int *budget)
+static int s2io_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct s2io_nic *nic = dev->priv;
 	int pkt_cnt = 0, org_pkts_to_process;
 	struct mac_info *mac_control;
@@ -2628,9 +2629,7 @@ static int s2io_poll(struct net_device *dev, int *budget)
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	nic->pkts_to_process = *budget;
-	if (nic->pkts_to_process > dev->quota)
-		nic->pkts_to_process = dev->quota;
+	nic->pkts_to_process = budget;
 	org_pkts_to_process = nic->pkts_to_process;
 
 	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
@@ -2644,11 +2643,7 @@ static int s2io_poll(struct net_device *dev, int *budget)
 			goto no_rx;
 		}
 	}
-	if (!pkt_cnt)
-		pkt_cnt = 1;
 
-	dev->quota -= pkt_cnt;
-	*budget -= pkt_cnt;
 	netif_rx_complete(dev);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
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
@@ -7415,8 +7407,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-	dev->poll = s2io_poll;
-	dev->weight = 32;
+	dev->napi.poll = s2io_poll;
+	dev->napi.weight = 32;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = s2io_netpoll;
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 3887fe6..b052a2a 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -1016,7 +1016,7 @@ static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
 static void s2io_reset(struct s2io_nic * sp);
-static int s2io_poll(struct net_device *dev, int *budget);
+static int s2io_poll(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index e7fdcf1..8c79c67 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -320,7 +320,7 @@ static struct net_device_stats *sbmac_get_stats(struct net_device *dev);
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
-static int sbmac_poll(struct net_device *poll_dev, int *budget);
+static int sbmac_poll(struct napi_struct *napi, int *budget);
 
 static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
 static int sbmac_mii_probe(struct net_device *dev);
@@ -2470,8 +2470,8 @@ static int sbmac_init(struct net_device *dev, int idx)
 	dev->do_ioctl           = sbmac_mii_ioctl;
 	dev->tx_timeout         = sbmac_tx_timeout;
 	dev->watchdog_timeo     = TX_TIMEOUT;
-	dev->poll               = sbmac_poll;
-	dev->weight             = 16;
+	dev->napi.poll          = sbmac_poll;
+	dev->napi.weight        = 16;
 
 	dev->change_mtu         = sb1250_change_mtu;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2874,25 +2874,16 @@ static int sbmac_close(struct net_device *dev)
 	return 0;
 }
 
-static int sbmac_poll(struct net_device *dev, int *budget)
+static int sbmac_poll(struct napi_struct *napi, int budget)
 {
-	int work_to_do;
-	int work_done;
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct sbmac_softc *sc = netdev_priv(dev);
+	int work_done;
 
-	work_to_do = min(*budget, dev->quota);
-	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), work_to_do, 1);
-
-	if (work_done > work_to_do)
-		printk(KERN_ERR "%s exceeded work_to_do budget=%d quota=%d work-done=%d\n",
-		       sc->sbm_dev->name, *budget, dev->quota, work_done);
-
+	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), budget, 1);
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done < work_to_do) {
+	if (work_done < budget) {
 		netif_rx_complete(dev);
 
 #ifdef CONFIG_SBMAC_COALESCE
@@ -2905,7 +2896,7 @@ static int sbmac_poll(struct net_device *dev, int *budget)
 #endif
 	}
 
-	return (work_done >= work_to_do);
+	return work_done;
 }
 
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 7766929..f3c3dab 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3045,14 +3045,13 @@ static void skge_tx_done(struct net_device *dev)
 	}
 }
 
-static int skge_poll(struct net_device *dev, int *budget)
+static int skge_poll(struct napi_struct *napi, int to_do)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct skge_port *skge = netdev_priv(dev);
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
+		__netif_rx_complete(dev);
+		hw->intr_mask |= napimask[skge->port];
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
+		skge_read32(hw, B0_IMSK);
+		spin_unlock_irq(&hw->hw_lock);
+	}
 
-	return 0;
+	return work_done;
 }
 
 /* Parity errors seem to happen when Genesis is connected to a switch
@@ -3570,8 +3565,8 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	SET_ETHTOOL_OPS(dev, &skge_ethtool_ops);
 	dev->tx_timeout = skge_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
-	dev->poll = skge_poll;
-	dev->weight = NAPI_WEIGHT;
+	dev->napi.poll = skge_poll;
+	dev->napi.weight = NAPI_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = skge_netpoll;
 #endif
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 13f08a3..4d07791 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2434,10 +2434,8 @@ static inline void sky2_idle_start(struct sky2_hw *hw)
 static void sky2_idle(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
-	struct net_device *dev = hw->dev[0];
 
-	if (__netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	napi_schedule(&hw->napi);
 
 	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
@@ -2470,11 +2468,11 @@ static void sky2_err_intr(struct sky2_hw *hw, u32 status)
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
@@ -2485,31 +2483,27 @@ static int sky2_poll(struct net_device *dev0, int *budget)
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
@@ -2518,8 +2512,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	prefetch(&hw->st_le[hw->st_idx]);
-	if (likely(__netif_rx_schedule_prep(dev0)))
-		__netif_rx_schedule(dev0);
+	
+	napi_schedule(&hw->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2528,10 +2522,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 static void sky2_netpoll(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct net_device *dev0 = sky2->hw->dev[0];
 
-	if (netif_running(dev) && __netif_rx_schedule_prep(dev0))
-		__netif_rx_schedule(dev0);
+	napi_schedule(&sky2->hw->napi);
 }
 #endif
 
@@ -3767,16 +3759,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
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
@@ -3945,6 +3927,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
+	hw->napi.poll = sky2_poll;
+	hw->napi.weight = NAPI_WEIGHT;
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
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
index 590b12c..4aefeb2 100644
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
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct spider_net_card *card = netdev_priv(netdev);
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
+	if (packets_done < budget) {
 		netif_rx_complete(netdev);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull = 0;
-		return 0;
 	}
 
-	return 1;
+	return packets_done;
 }
 
 /**
@@ -2309,8 +2300,8 @@ spider_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->tx_timeout = &spider_net_tx_timeout;
 	netdev->watchdog_timeo = SPIDER_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
-	netdev->poll = &spider_net_poll;
-	netdev->weight = SPIDER_NET_NAPI_WEIGHT;
+	netdev->napi.poll = &spider_net_poll;
+	netdev->napi.weight = SPIDER_NET_NAPI_WEIGHT;
 	/* HW VLAN */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* poll controller */
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 8b64786..a6cbb30 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -180,8 +180,8 @@ static int full_duplex[MAX_UNITS] = {0, };
 #ifdef HAVE_NETDEV_POLL
 #define init_poll(dev) \
 do { \
-	dev->poll = &netdev_poll; \
-	dev->weight = max_interrupt_work; \
+	dev->napi.poll = &netdev_poll; \
+	dev->napi.weight = max_interrupt_work; \
 } while (0)
 #define netdev_rx(dev, ioaddr) \
 do { \
@@ -204,7 +204,7 @@ do { \
 } while (0)
 #define netdev_receive_skb(skb) netif_receive_skb(skb)
 #define vlan_netdev_receive_skb(skb, vlgrp, vlid) vlan_hwaccel_receive_skb(skb, vlgrp, vlid)
-static int	netdev_poll(struct net_device *dev, int *budget);
+static int	netdev_poll(struct napi_struct *napi, int budget);
 #else  /* not HAVE_NETDEV_POLL */
 #define init_poll(dev)
 #define netdev_receive_skb(skb) netif_rx(skb)
@@ -1531,20 +1531,18 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 
 
 #ifdef HAVE_NETDEV_POLL
-static int netdev_poll(struct net_device *dev, int *budget)
+static int netdev_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	u32 intr_status;
 	struct netdev_private *np = netdev_priv(dev);
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
@@ -1557,10 +1555,11 @@ static int netdev_poll(struct net_device *dev, int *budget)
 
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
 
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4328038..7571cc5 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -878,19 +878,20 @@ static int gem_rx(struct gem *gp, int work_to_do)
 	return work_done;
 }
 
-static int gem_poll(struct net_device *dev, int *budget)
+static int gem_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct gem *gp = dev->priv;
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
@@ -909,15 +910,10 @@ static int gem_poll(struct net_device *dev, int *budget)
 		 * rx ring - must call netif_poll_disable(), which
 		 * schedule_timeout()'s if polling is already disabled.
 		 */
-		work_to_do = min(*budget, dev->quota);
-
-		work_done = gem_rx(gp, work_to_do);
+		work_done += gem_rx(gp, budget);
 
-		*budget -= work_done;
-		dev->quota -= work_done;
-
-		if (work_done >= work_to_do)
-			return 1;
+		if (work_done >= budget)
+			return work_done;
 
 		spin_lock_irqsave(&gp->lock, flags);
 
@@ -928,7 +924,8 @@ static int gem_poll(struct net_device *dev, int *budget)
 	gem_enable_ints(gp);
 
 	spin_unlock_irqrestore(&gp->lock, flags);
-	return 0;
+
+	return work_done;
 }
 
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
@@ -3121,8 +3118,8 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	dev->get_stats = gem_get_stats;
 	dev->set_multicast_list = gem_set_multicast;
 	dev->do_ioctl = gem_ioctl;
-	dev->poll = gem_poll;
-	dev->weight = 64;
+	dev->napi.poll = gem_poll;
+	dev->napi.weight = 64;
 	dev->ethtool_ops = &gem_ethtool_ops;
 	dev->tx_timeout = gem_tx_timeout;
 	dev->watchdog_timeo = 5 * HZ;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 7f94ca9..ba44629 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -566,7 +566,7 @@ static int	tc35815_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t	tc35815_interrupt(int irq, void *dev_id);
 #ifdef TC35815_NAPI
 static int	tc35815_rx(struct net_device *dev, int limit);
-static int	tc35815_poll(struct net_device *dev, int *budget);
+static int	tc35815_poll(struct napi_struct *napi, int budget);
 #else
 static void	tc35815_rx(struct net_device *dev);
 #endif
@@ -738,8 +738,8 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	dev->tx_timeout = tc35815_tx_timeout;
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
 #ifdef TC35815_NAPI
-	dev->poll = tc35815_poll;
-	dev->weight = NAPI_WEIGHT;
+	dev->napi.poll = tc35815_poll;
+	dev->napi.weight = NAPI_WEIGHT;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tc35815_poll_controller;
@@ -1726,13 +1726,12 @@ tc35815_rx(struct net_device *dev)
 }
 
 #ifdef TC35815_NAPI
-static int
-tc35815_poll(struct net_device *dev, int *budget)
+static int tc35815_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct tc35815_local *lp = dev->priv;
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-	int limit = min(*budget, dev->quota);
 	int received = 0, handled;
 	u32 status;
 
@@ -1744,23 +1743,19 @@ tc35815_poll(struct net_device *dev, int *budget)
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
+		netif_rx_complete(dev);
+		/* enable interrupts */
+		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
+	}
+	return received;
 }
 #endif
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 887b9a5..7210da2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3471,11 +3471,12 @@ next_pkt_nopost:
 	return received;
 }
 
-static int tg3_poll(struct net_device *netdev, int *budget)
+static int tg3_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct tg3 *tp = netdev_priv(netdev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	int done;
+	int work_done = 0;
 
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
@@ -3502,20 +3503,10 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 
 	/* run RX thread, within the bounds set by NAPI.
 	 * All RX "locking" is done by ensuring outside
-	 * code synchronizes with dev->poll()
+	 * code synchronizes with dev->napi.poll()
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
+	if (!tg3_has_work(tp)) {
 		netif_rx_complete(netdev);
 		tg3_restart_ints(tp);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static void tg3_irq_quiesce(struct tg3 *tp)
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
@@ -11897,9 +11887,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->set_mac_address = tg3_set_mac_addr;
 	dev->do_ioctl = tg3_ioctl;
 	dev->tx_timeout = tg3_tx_timeout;
-	dev->poll = tg3_poll;
+	dev->napi.weight = 64;
+	dev->napi.poll = tg3_poll;
 	dev->ethtool_ops = &tg3_ethtool_ops;
-	dev->weight = 64;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 1aabc91..ed107bb 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -837,13 +837,13 @@ static int tsi108_refill_rx(struct net_device *dev, int budget)
 	return done;
 }
 
-static int tsi108_poll(struct net_device *dev, int *budget)
+static int tsi108_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct tsi108_prv_data *data = netdev_priv(dev);
 	u32 estat = TSI_READ(TSI108_EC_RXESTAT);
 	u32 intstat = TSI_READ(TSI108_EC_INTSTAT);
-	int total_budget = min(*budget, dev->quota);
-	int num_received = 0, num_filled = 0, budget_used;
+	int num_received = 0, num_filled = 0;
 
 	intstat &= TSI108_INT_RXQUEUE0 | TSI108_INT_RXTHRESH |
 	    TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR | TSI108_INT_RXWAIT;
@@ -852,7 +852,7 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 	TSI_WRITE(TSI108_EC_INTSTAT, intstat);
 
 	if (data->rxpending || (estat & TSI108_EC_RXESTAT_Q0_DESCINT))
-		num_received = tsi108_complete_rx(dev, total_budget);
+		num_received = tsi108_complete_rx(dev, budget);
 
 	/* This should normally fill no more slots than the number of
 	 * packets received in tsi108_complete_rx().  The exception
@@ -867,7 +867,7 @@ static int tsi108_poll(struct net_device *dev, int *budget)
 	 */
 
 	if (data->rxfree < TSI108_RXRING_LEN)
-		num_filled = tsi108_refill_rx(dev, total_budget * 2);
+		num_filled = tsi108_refill_rx(dev, budget * 2);
 
 	if (intstat & TSI108_INT_RXERROR) {
 		u32 err = TSI_READ(TSI108_EC_RXERR);
@@ -890,12 +890,7 @@ static int tsi108_poll(struct net_device *dev, int *budget)
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
 		netif_rx_complete(dev);
 
@@ -906,14 +901,11 @@ static int tsi108_poll(struct net_device *dev, int *budget)
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
@@ -1597,9 +1589,9 @@ tsi108_init_one(struct platform_device *pdev)
 	dev->set_mac_address = tsi108_set_mac;
 	dev->set_multicast_list = tsi108_set_rx_mode;
 	dev->get_stats = tsi108_get_stats;
-	dev->poll = tsi108_poll;
+	dev->napi.poll = tsi108_poll;
+	dev->napi.weight = 64;  /* 64 is more suitable for GigE interface - klai */
 	dev->do_ioctl = tsi108_do_ioctl;
-	dev->weight = 64;  /* 64 is more suitable for GigE interface - klai */
 
 	/* Apparently, the Linux networking code won't use scatter-gather
 	 * if the hardware doesn't do checksums.  However, it's faster
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 53efd66..47c1f5c 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -106,25 +106,25 @@ void oom_timer(unsigned long data)
 	netif_rx_schedule(dev);
 }
 
-int tulip_poll(struct net_device *dev, int *budget)
+int tulip_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct tulip_private *tp = netdev_priv(dev);
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
@@ -144,14 +144,13 @@ int tulip_poll(struct net_device *dev, int *budget)
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
@@ -238,7 +237,9 @@ int tulip_poll(struct net_device *dev, int *budget)
                                tp->stats.rx_packets++;
                                tp->stats.rx_bytes += pkt_len;
                        }
-                       received++;
+#ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
+		       received++;
+#endif
 
                        entry = (++tp->cur_rx) % RX_RING_SIZE;
                        if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
@@ -296,13 +297,11 @@ done:
 
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
 
@@ -320,28 +319,20 @@ done:
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
 
@@ -352,7 +343,7 @@ done:
          /* remove ourselves from the polling list */
          netif_rx_complete(dev);
 
-         return 0;
+         return work_done;
 }
 
 #else /* CONFIG_TULIP_NAPI */
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 16f26a8..d90e08c 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -429,7 +429,7 @@ extern int tulip_rx_copybreak;
 irqreturn_t tulip_interrupt(int irq, void *dev_instance);
 int tulip_refill_rx(struct net_device *dev);
 #ifdef CONFIG_TULIP_NAPI
-int tulip_poll(struct net_device *dev, int *budget);
+int tulip_poll(struct napi_struct *napi, int budget);
 #endif
 
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f87d769..4eff408 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1614,8 +1614,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	dev->tx_timeout = tulip_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_TULIP_NAPI
-	dev->poll = tulip_poll;
-	dev->weight = 16;
+	dev->napi.poll = tulip_poll;
+	dev->napi.weight = 16;
 #endif
 	dev->stop = tulip_close;
 	dev->get_stats = tulip_get_stats;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0358720..66f3c93 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1759,12 +1759,12 @@ typhoon_fill_free_ring(struct typhoon *tp)
 }
 
 static int
-typhoon_poll(struct net_device *dev, int *total_budget)
+typhoon_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct typhoon *tp = netdev_priv(dev);
 	struct typhoon_indexes *indexes = tp->indexes;
-	int orig_budget = *total_budget;
-	int budget, work_done, done;
+	int work_done;
 
 	rmb();
 	if(!tp->awaiting_resp && indexes->respReady != indexes->respCleared)
@@ -1773,30 +1773,16 @@ typhoon_poll(struct net_device *dev, int *total_budget)
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
@@ -1804,14 +1790,14 @@ typhoon_poll(struct net_device *dev, int *total_budget)
 		typhoon_fill_free_ring(tp);
 	}
 
-	if(done) {
+	if (work_done < budget) {
 		netif_rx_complete(dev);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
 	}
 
-	return (done ? 0 : 1);
+	return work_done;
 }
 
 static irqreturn_t
@@ -2521,8 +2507,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->stop		= typhoon_close;
 	dev->set_multicast_list	= typhoon_set_rx_mode;
 	dev->tx_timeout		= typhoon_tx_timeout;
-	dev->poll		= typhoon_poll;
-	dev->weight		= 16;
+	dev->napi.poll		= typhoon_poll;
+	dev->napi.weight	= 16;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	dev->get_stats		= typhoon_get_stats;
 	dev->set_mac_address	= typhoon_set_mac_address;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e4736a3..a480795 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3527,33 +3527,23 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 }
 
 #ifdef CONFIG_UGETH_NAPI
-static int ucc_geth_poll(struct net_device *dev, int *budget)
+static int ucc_geth_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
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
 		netif_rx_complete(dev);
 		uccf = ugeth->uccf;
 		uccm = in_be32(uccf->p_uccm);
@@ -3561,7 +3551,7 @@ static int ucc_geth_poll(struct net_device *dev, int *budget)
 		out_be32(uccf->p_uccm, uccm);
 	}
 
-	return (rx_work_limit > 0) ? 0 : 1;
+	return howmany;
 }
 #endif				/* CONFIG_UGETH_NAPI */
 
@@ -3901,8 +3891,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->tx_timeout = ucc_geth_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_UGETH_NAPI
-	dev->poll = ucc_geth_poll;
-	dev->weight = UCC_GETH_DEV_WEIGHT;
+	dev->napi.poll = ucc_geth_poll;
+	dev->napi.weight = UCC_GETH_DEV_WEIGHT;
 #endif				/* CONFIG_UGETH_NAPI */
 	dev->stop = ucc_geth_close;
 	dev->get_stats = ucc_geth_get_stats;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index f51c2c1..06ec782 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -576,17 +576,16 @@ static void rhine_poll(struct net_device *dev)
 #endif
 
 #ifdef CONFIG_VIA_RHINE_NAPI
-static int rhine_napipoll(struct net_device *dev, int *budget)
+static int rhine_napipoll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
-	int done, limit = min(dev->quota, *budget);
+	int work_done;
 
-	done = rhine_rx(dev, limit);
-	*budget -= done;
-	dev->quota -= done;
+	work_done = rhine_rx(dev, budget);
 
-	if (done < limit) {
+	if (work_done < budget) {
 		netif_rx_complete(dev);
 
 		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
@@ -594,10 +593,8 @@ static int rhine_napipoll(struct net_device *dev, int *budget)
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
 
@@ -779,8 +776,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->poll_controller = rhine_poll;
 #endif
 #ifdef CONFIG_VIA_RHINE_NAPI
-	dev->poll = rhine_napipoll;
-	dev->weight = 64;
+	dev->napi.poll = rhine_napipoll;
+	dev->napi.weight = 64;
 #endif
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 489f69c..336f6e8 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -871,15 +871,16 @@ static int handle_incoming_queue(struct net_device *dev,
 	return packets_dropped;
 }
 
-static int xennet_poll(struct net_device *dev, int *pbudget)
+static int xennet_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct netfront_info *np = netdev_priv(dev);
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
@@ -898,9 +899,6 @@ static int xennet_poll(struct net_device *dev, int *pbudget)
 	skb_queue_head_init(&errq);
 	skb_queue_head_init(&tmpq);
 
-	budget = *pbudget;
-	if (budget > dev->quota)
-		budget = dev->quota;
 	rp = np->rx.sring->rsp_prod;
 	rmb(); /* Ensure we see queued responses up to 'rp'. */
 
@@ -1005,10 +1003,9 @@ err:
 
 	xennet_alloc_rx_buffers(dev);
 
-	*pbudget   -= work_done;
-	dev->quota -= work_done;
-
 	if (work_done < budget) {
+		int more_to_do = 0;
+
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
@@ -1020,7 +1017,7 @@ err:
 
 	spin_unlock(&np->rx_lock);
 
-	return more_to_do;
+	return work_done;
 }
 
 static int xennet_change_mtu(struct net_device *dev, int mtu)
@@ -1200,10 +1197,10 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	netdev->hard_start_xmit = xennet_start_xmit;
 	netdev->stop            = xennet_close;
 	netdev->get_stats       = xennet_get_stats;
-	netdev->poll            = xennet_poll;
+	netdev->napi.poll       = xennet_poll;
+	netdev->napi.weight     = 64;
 	netdev->uninit          = xennet_uninit;
 	netdev->change_mtu	= xennet_change_mtu;
-	netdev->weight          = 64;
 	netdev->features        = NETIF_F_IP_CSUM;
 
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a616d7..3cb7ab0 100644
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
@@ -430,12 +497,7 @@ struct net_device
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
  */
-	struct list_head	poll_list ____cacheline_aligned_in_smp;
-					/* Link to poll list	*/
-
-	int			(*poll) (struct net_device *dev, int *quota);
-	int			quota;
-	int			weight;
+	struct napi_struct	napi ____cacheline_aligned_in_smp;
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
@@ -678,7 +740,6 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-
 struct softnet_data
 {
 	struct net_device	*output_queue;
@@ -686,7 +747,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct net_device	backlog_dev;	/* Sorry. 8) */
+	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
@@ -796,20 +857,7 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
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
@@ -955,10 +1003,11 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
 
+
 /* Test if receive needs to be scheduled */
 static inline int __netif_rx_schedule_prep(struct net_device *dev)
 {
-	return !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	return napi_schedule_prep(&dev->napi);
 }
 
 /* Test if receive needs to be scheduled but only if up */
@@ -970,8 +1019,11 @@ static inline int netif_rx_schedule_prep(struct net_device *dev)
 /* Add interface to tail of rx poll list. This assumes that _prep has
  * already been called and returned 1.
  */
-
-extern void __netif_rx_schedule(struct net_device *dev);
+static inline void __netif_rx_schedule(struct net_device *dev)
+{
+	dev_hold(dev);
+	__napi_schedule(&dev->napi);
+}
 
 /* Try to reschedule poll. Called by irq handler. */
 
@@ -981,34 +1033,13 @@ static inline void netif_rx_schedule(struct net_device *dev)
 		__netif_rx_schedule(dev);
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
-
-		local_irq_save(flags);
-		list_add_tail(&dev->poll_list, &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-		local_irq_restore(flags);
-		return 1;
-	}
-	return 0;
-}
-
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
 static inline void __netif_rx_complete(struct net_device *dev)
 {
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	napi_complete(&dev->napi);
+	dev_put(dev);
 }
 
 /* Remove interface from poll list: it must be in the poll list
@@ -1027,15 +1058,12 @@ static inline void netif_rx_complete(struct net_device *dev)
 
 static inline void netif_poll_disable(struct net_device *dev)
 {
-	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state))
-		/* No hurry. */
-		schedule_timeout_interruptible(1);
+	napi_disable(&dev->napi);
 }
 
 static inline void netif_poll_enable(struct net_device *dev)
 {
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	napi_enable(&dev->napi);
 }
 
 static inline void netif_tx_lock(struct net_device *dev)
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
index ee40355..cf5fbb8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -220,7 +220,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+
+DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL, };
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -1002,10 +1003,7 @@ int dev_close(struct net_device *dev)
 	 * engine, but this requires more changes in devices. */
 
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		msleep(1);
-	}
+	netif_poll_disable(dev);
 
 	/*
 	 *	Call the device specific close. This cannot fail.
@@ -1188,21 +1186,21 @@ void __netif_schedule(struct net_device *dev)
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
@@ -1638,6 +1636,28 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
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
@@ -1685,7 +1705,7 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
 
-		netif_rx_schedule(&queue->backlog_dev);
+		napi_schedule(&queue->backlog);
 		goto enqueue;
 	}
 
@@ -1726,6 +1746,38 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
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
@@ -1882,7 +1934,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	__be16 type;
 
 	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
+	if (skb->dev->napi.poll && netpoll_rx(skb))
 		return NET_RX_DROP;
 
 	if (!skb->tstamp.tv64)
@@ -1972,90 +2024,101 @@ out:
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
@@ -2070,12 +2133,6 @@ out:
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
@@ -3980,10 +4037,9 @@ static int __init net_dev_init(void)
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
index 5c19b06..4439607 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -216,11 +216,19 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
-NETDEVICE_SHOW(weight, fmt_dec);
+static ssize_t format_weight(const struct net_device *net, char *buf)
+{
+	return sprintf(buf, fmt_dec, net->napi.weight);
+}
+
+static ssize_t show_weight(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return netdev_show(dev, attr, buf, format_weight);
+}
 
 static int change_weight(struct net_device *net, unsigned long new_weight)
 {
-	net->weight = new_weight;
+	net->napi.weight = new_weight;
 	return 0;
 }
 
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
index 06eccca..e188d80 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -634,7 +634,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
+	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->napi.weight);
 	NLA_PUT_U8(skb, IFLA_OPERSTATE,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
@@ -835,7 +835,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
 	if (tb[IFLA_WEIGHT])
-		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
+		dev->napi.weight = nla_get_u32(tb[IFLA_WEIGHT]);
 
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
@@ -1073,7 +1073,7 @@ replay:
 		if (tb[IFLA_TXQLEN])
 			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 		if (tb[IFLA_WEIGHT])
-			dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
+			dev->napi.weight = nla_get_u32(tb[IFLA_WEIGHT]);
 		if (tb[IFLA_OPERSTATE])
 			set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 		if (tb[IFLA_LINKMODE])
