From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] split NAPI from network device.
Date: Tue, 20 Feb 2007 21:31:25 -0800 (PST)
Message-ID: <20070220.213125.74747066.davem@davemloft.net>
References: <20061213113537.6baf410f@dxpl.pdx.osdl.net>
	<1166042552.11914.188.camel@localhost.localdomain>
	<20061213154635.1f284bf6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org, ebs@ebshome.net,
	linux-kernel@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030538AbXBUFb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 00:31:29 -0500
In-Reply-To: <20061213154635.1f284bf6@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 13 Dec 2006 15:46:35 -0800

> Split off NAPI part from network device, this patch is build tested
> only! It breaks kernel API for network devices, and only three examples
> are fixed (skge, sky2, and tg3).
> 
> 1. Decomposition allows different NAPI <-> network device
>    Some hardware has N devices for one IRQ, others like MSI-X
>    want multiple receive's for one device.
> 
> 2. Cleanup locking with netpoll
> 
> 3. Change poll callback arguements and semantics
> 
> 4. Make softnet_data static (only in dev.c)
> 
> Old:
> 	dev->poll(dev, &budget)
> 	returns 1 or 0
> 	requeu if returns 1
> 
> New:
> 	napi->poll(napi, quota)
> 	returns # of elements processed
> 	requeue based on status
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I rebuffed this patch against current 2.6.x GIT and fixed all of
the drivers.

I had to undo #4 because NETDMA wants to get at things in the softnet
data, sorry, there was no easy way to workaround that and using functional
interfaces was not a good idea because there are assumptions about
preemption/interrupt enabling that don't get expressed well with the
"__xxx()" function naming conventions in my opinion.

If we are serious about this I would like to ask folks to test this
well.  I've only moderately hit this with tg3, and that's it.  The
only driver conversion I have some doubts about is Tulip, there was
a lot of seemingly dead and useless logic in there that showed up
clearly with the new semantics but I want to make sure I got it right.

I like this patch just for the ->poll() semantics change alone, it's
much cleaner than what is there before.

Actually, Ben did you determine if this scheme works for your device
which has a single interrupt source yet multiple queues?  There is one
driver that, during the conversion, I noticed has a similar issue.
One driver, netxen, has multiple channels, so it just passes in
"bugdet / NUM_CHANNELS" as the quota so that one channel could not
starve the others.

Thanks.

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 6f93a76..46f3ed0 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -516,12 +516,12 @@ static inline unsigned int cp_rx_csum_ok (u32 status)
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
@@ -604,19 +604,16 @@ rx_next:
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
@@ -626,11 +623,9 @@ rx_next:
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
@@ -1930,11 +1925,11 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
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
index 35ad5cf..45a433c 100644
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
@@ -979,8 +979,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
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
@@ -2111,26 +2111,19 @@ static void rtl8139_weird_interrupt (struct net_device *dev,
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
@@ -2143,7 +2136,7 @@ static int rtl8139_poll(struct net_device *dev, int *budget)
 	}
 	spin_unlock(&tp->rx_lock);
 
-	return !done;
+	return work_done;
 }
 
 /* The interrupt handler does all of the Rx thread work and cleans up
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 9c399aa..5ee9e92 100644
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
@@ -840,21 +841,14 @@ static int amd8111e_rx_poll(struct net_device *dev, int * budget)
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
@@ -2044,8 +2038,8 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
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
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index aaada57..6d306fd 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -851,10 +851,11 @@ static int b44_rx(struct b44 *bp, int budget)
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
 
@@ -865,22 +866,9 @@ static int b44_poll(struct net_device *netdev, int *budget)
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
@@ -891,15 +879,15 @@ static int b44_poll(struct net_device *netdev, int *budget)
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
@@ -2204,8 +2192,8 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
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
index 5a96d76..fe6c0af 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2041,9 +2041,11 @@ bnx2_has_work(struct bnx2 *bp)
 }
 
 static int
-bnx2_poll(struct net_device *dev, int *budget)
+bnx2_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct bnx2 *bp = netdev_priv(dev);
+	int work_done = 0;
 
 	if ((bp->status_blk->status_attn_bits &
 		STATUS_ATTN_BITS_LINK_STATE) !=
@@ -2065,17 +2067,8 @@ bnx2_poll(struct net_device *dev, int *budget)
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
@@ -2096,10 +2089,9 @@ bnx2_poll(struct net_device *dev, int *budget)
 		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 		       bp->last_status_idx);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 /* Called with rtnl_lock from vlan functions and also netif_tx_lock
@@ -6046,9 +6038,9 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_rx_register = bnx2_vlan_rx_register;
 	dev->vlan_rx_kill_vid = bnx2_vlan_rx_kill_vid;
 #endif
-	dev->poll = bnx2_poll;
+	dev->napi.weight = 64;
+	dev->napi.poll = bnx2_poll;
 	dev->ethtool_ops = &bnx2_ethtool_ops;
-	dev->weight = 64;
 
 	bp = netdev_priv(dev);
 
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 7d0f24f..2ae5671 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1124,8 +1124,8 @@ static int __devinit init_one(struct pci_dev *pdev,
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
index 89a6827..a6269f9 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1621,23 +1621,20 @@ static int process_pure_responses(struct adapter *adapter)
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
index 43583ed..e446b33 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -353,7 +353,7 @@ static int init_dummy_netdevs(struct adapter *adap)
 					goto free_all;
 
 				nd->priv = adap;
-				nd->weight = 64;
+				nd->napi.weight = 64;
 				set_bit(__LINK_STATE_START, &nd->state);
 				adap->dummy_netdev[dummy_idx] = nd;
 			}
@@ -383,15 +383,13 @@ static void quiesce_rx(struct adapter *adap)
 
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
 
@@ -2372,7 +2370,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = cxgb_netpoll;
 #endif
-		netdev->weight = 64;
+		netdev->napi.weight = 64;
 
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3f2cf8a..3b0ed75 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1484,33 +1484,31 @@ static inline void deliver_partial_bundle(struct t3cdev *tdev,
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
@@ -1532,10 +1530,8 @@ static int ofld_poll(struct net_device *dev, int *budget)
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
@@ -1870,36 +1866,36 @@ static inline int is_pure_response(const struct rsp_desc *r)
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
@@ -1907,7 +1903,7 @@ static int napi_rx_handler(struct net_device *dev, int *budget)
  */
 static inline int napi_is_scheduled(struct net_device *dev)
 {
-	return test_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	return test_bit(NAPI_STATE_SCHED, &dev->napi.state);
 }
 
 /**
@@ -2345,7 +2341,7 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
 
 	qs->rspq.holdoff_tmr = max(p->coalesce_usecs * 10, 1U);/* can't be 0 */
 	qs->rspq.polling = p->polling;
-	qs->netdev->poll = p->polling ? napi_rx_handler : ofld_poll;
+	qs->netdev->napi.poll = p->polling ? napi_rx_handler : ofld_poll;
 }
 
 /**
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 0cefef5..d64f5d4 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1975,27 +1975,23 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
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
@@ -2566,8 +2562,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
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
index a710237..8f2dfb9 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -164,7 +164,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
-static int e1000_clean(struct net_device *poll_dev, int *budget);
+static int e1000_clean(struct napi_struct *napi, int budget);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
                                     struct e1000_rx_ring *rx_ring,
                                     int *work_done, int work_to_do);
@@ -943,8 +943,8 @@ e1000_probe(struct pci_dev *pdev,
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
@@ -1328,8 +1328,8 @@ e1000_sw_init(struct e1000_adapter *adapter)
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
@@ -3919,10 +3919,10 @@ e1000_intr(int irq, void *data)
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
@@ -3943,23 +3943,19 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	}
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, work_to_do);
-
-	*budget -= work_done;
-	poll_dev->quota -= work_done;
+	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((tx_cleaned && (work_done < work_to_do)) ||
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
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 3a6a83d..ed735fe 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -296,7 +296,7 @@ static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int epic_rx(struct net_device *dev, int budget);
-static int epic_poll(struct net_device *dev, int *budget);
+static int epic_poll(struct napi_struct *napi, int budget);
 static irqreturn_t epic_interrupt(int irq, void *dev_instance);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -489,8 +489,8 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
-	dev->poll = epic_poll;
-	dev->weight = 64;
+	dev->napi.poll = epic_poll;
+	dev->napi.weight = 64;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -1262,26 +1262,22 @@ static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
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
 
@@ -1303,7 +1299,7 @@ rx_action:
 			goto rx_action;
 	}
 
-	return (work_done >= orig_budget);
+	return work_done;
 }
 
 static int epic_close(struct net_device *dev)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a363148..3ab8c6e 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3098,17 +3098,18 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
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
+	int pkts;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		pkts = nv_rx_process(dev, limit);
+		pkts = nv_rx_process(dev, budget);
 	else
-		pkts = nv_rx_process_optimized(dev, limit);
+		pkts = nv_rx_process_optimized(dev, budget);
 
 	if (nv_alloc_rx(dev)) {
 		spin_lock_irqsave(&np->lock, flags);
@@ -3117,7 +3118,7 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
 		spin_unlock_irqrestore(&np->lock, flags);
 	}
 
-	if (pkts < limit) {
+	if (pkts < budget) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
@@ -3131,13 +3132,8 @@ static int nv_napi_poll(struct net_device *dev, int *budget)
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
 
@@ -5007,9 +5003,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
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
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0c36828..2b9d2a8 100644
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
@@ -427,8 +427,8 @@ ixgb_probe(struct pci_dev *pdev,
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
@@ -1779,27 +1779,23 @@ ixgb_intr(int irq, void *data)
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
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 030924f..0ce1d13 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1051,7 +1051,7 @@ static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 	}
 }
 
-static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
+static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	unsigned long rx_bytes = 0;
@@ -1060,10 +1060,11 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 
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
@@ -1079,10 +1080,6 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
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
@@ -1096,6 +1093,7 @@ static inline void myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int *limit)
 	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
 
+	return work_done;
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
@@ -1135,26 +1133,21 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
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
@@ -2878,8 +2871,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
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
index ffa0afd..9e63152 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -625,7 +625,7 @@ static void init_registers(struct net_device *dev);
 static int start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
 static void netdev_error(struct net_device *dev, int intr_status);
-static int natsemi_poll(struct net_device *dev, int *budget);
+static int natsemi_poll(struct napi_struct *napi, int budget);
 static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do);
 static void netdev_tx_done(struct net_device *dev);
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
@@ -859,8 +859,8 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->poll = natsemi_poll;
-	dev->weight = 64;
+	dev->napi.poll = natsemi_poll;
+	dev->napi.weight = 64;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &natsemi_poll_controller;
@@ -2122,12 +2122,11 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
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
@@ -2145,14 +2144,11 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		if (np->intr_status &
 		    (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
 		     IntrRxErr | IntrRxOverrun)) {
-			netdev_rx(dev, &work_done, work_to_do);
+			netdev_rx(dev, &work_done, budget);
 		}
 
-		*budget -= work_done;
-		dev->quota -= work_done;
-
-		if (work_done >= work_to_do)
-			return 1;
+		if (work_done >= budget)
+			return work_done;
 
 		np->intr_status = readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
@@ -2166,7 +2162,7 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		natsemi_irq_enable(dev);
 	spin_unlock(&np->lock);
 
-	return 0;
+	return work_done;
 }
 
 /* This routine is logically part of the interrupt handler, but separated
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 7195af3..8a04a6e 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -228,7 +228,7 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    &adapter->ctx_desc_pdev);
 
 	printk("ctx_desc_phys_addr: 0x%llx\n",
-	       (u64) adapter->ctx_desc_phys_addr);
+	       (unsigned long long) adapter->ctx_desc_phys_addr);
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
 		err = -ENOMEM;
@@ -246,7 +246,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 				    sizeof(struct cmd_desc_type0) *
 				    adapter->max_tx_desc_count,
 				    (dma_addr_t *) & hw->cmd_desc_phys_addr);
-	printk("cmd_desc_phys_addr: 0x%llx\n", (u64) hw->cmd_desc_phys_addr);
+	printk("cmd_desc_phys_addr: 0x%llx\n",
+	       (unsigned long long) hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 225ff55..e8ef2fc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -72,7 +72,7 @@ static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
 static int netxen_handle_int(struct netxen_adapter *, struct net_device *);
-static int netxen_nic_poll(struct net_device *dev, int *budget);
+static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
@@ -380,8 +380,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->watchdog_timeo = HZ;
 
 		SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-		netdev->poll = netxen_nic_poll;
-		netdev->weight = NETXEN_NETDEV_WEIGHT;
+		netdev->napi.poll = netxen_nic_poll;
+		netdev->napi.weight = NETXEN_NETDEV_WEIGHT;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = netxen_nic_poll_controller;
 #endif
@@ -1068,15 +1068,14 @@ irqreturn_t netxen_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static int netxen_nic_poll(struct net_device *netdev, int *budget)
+static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *netdev = container_of(napi, struct net_device, napi);
 	struct netxen_port *port = (struct netxen_port *)netdev_priv(netdev);
 	struct netxen_adapter *adapter = port->adapter;
-	int work_to_do = min(*budget, netdev->quota);
 	int done = 1;
 	int ctx;
-	int this_work_done;
-	int work_done = 0;
+	int work_done;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
 	port->stats.polled++;
@@ -1095,16 +1094,11 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
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
@@ -1117,7 +1111,7 @@ static int netxen_nic_poll(struct net_device *netdev, int *budget)
 		netxen_nic_enable_int(adapter);
 	}
 
-	return !done;
+	return work_done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 36f9d98..e9a01b2 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -816,7 +816,7 @@ static int pcnet32_set_ringparam(struct net_device *dev,
 	if ((1 << i) != lp->rx_ring_size)
 		pcnet32_realloc_rx_ring(dev, lp, i);
 
-	dev->weight = lp->rx_ring_size / 2;
+	dev->napi.weight = lp->rx_ring_size / 2;
 
 	if (netif_running(dev)) {
 		pcnet32_netif_start(dev);
@@ -1256,7 +1256,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	return;
 }
 
-static int pcnet32_rx(struct net_device *dev, int quota)
+static int pcnet32_rx(struct net_device *dev, int budget)
 {
 	struct pcnet32_private *lp = dev->priv;
 	int entry = lp->cur_rx & lp->rx_mod_mask;
@@ -1264,7 +1264,7 @@ static int pcnet32_rx(struct net_device *dev, int quota)
 	int npackets = 0;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
+	while (npackets < budget && (short)le16_to_cpu(rxp->status) >= 0) {
 		pcnet32_rx_entry(dev, lp, rxp, entry);
 		npackets += 1;
 		/*
@@ -1380,15 +1380,16 @@ static int pcnet32_tx(struct net_device *dev)
 }
 
 #ifdef CONFIG_PCNET32_NAPI
-static int pcnet32_poll(struct net_device *dev, int *budget)
+static int pcnet32_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct pcnet32_private *lp = dev->priv;
-	int quota = min(dev->quota, *budget);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
+	int work_done;
 	u16 val;
 
-	quota = pcnet32_rx(dev, quota);
+	work_done = pcnet32_rx(dev, budget);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	if (pcnet32_tx(dev)) {
@@ -1400,28 +1401,22 @@ static int pcnet32_poll(struct net_device *dev, int *budget)
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
 
@@ -1961,9 +1956,9 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
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
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a142cdf..b257594 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2004,26 +2004,23 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 	return *tx_cleaned + *rx_cleaned;
 }
 
-static int ql_poll(struct net_device *ndev, int *budget)
+static int ql_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *ndev = container_of(napi, struct net_device, napi);
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	int work_to_do = min(*budget, ndev->quota);
 	int rx_cleaned = 0, tx_cleaned = 0;
 
 	if (!netif_carrier_ok(ndev))
 		goto quit_polling;
 
-	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, work_to_do);
-	*budget -= rx_cleaned;
-	ndev->quota -= rx_cleaned;
+	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, budget);
 
 	if ((!tx_cleaned && !rx_cleaned) || !netif_running(ndev)) {
 quit_polling:
 		netif_rx_complete(ndev);
 		ql_enable_interrupts(qdev);
-		return 0;
 	}
-	return 1;
+	return tx_cleaned + rx_cleaned;
 }
 
 static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
@@ -3657,8 +3654,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->tx_timeout = ql3xxx_tx_timeout;
 	ndev->watchdog_timeo = 5 * HZ;
 
-	ndev->poll = &ql_poll;
-	ndev->weight = 64;
+	ndev->napi.poll = &ql_poll;
+	ndev->napi.weight = 64;
 
 	ndev->irq = pdev->irq;
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5598d86..3e8f9a1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -483,12 +483,12 @@ static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
-				void __iomem *);
+				void __iomem *, u32 budget);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 
 #ifdef CONFIG_R8169_NAPI
-static int rtl8169_poll(struct net_device *dev, int *budget);
+static int rtl8169_poll(struct napi_struct *napi, int budget);
 #endif
 
 static const u16 rtl8169_intr_mask =
@@ -1667,8 +1667,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->change_mtu = rtl8169_change_mtu;
 
 #ifdef CONFIG_R8169_NAPI
-	dev->poll = rtl8169_poll;
-	dev->weight = R8169_NAPI_WEIGHT;
+	dev->napi.poll = rtl8169_poll;
+	dev->napi.weight = R8169_NAPI_WEIGHT;
 #endif
 
 #ifdef CONFIG_R8169_VLAN
@@ -2192,7 +2192,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_wait_for_quiescence(dev);
 
-	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr);
+	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
 	rtl8169_tx_clear(tp);
 
 	if (tp->dirty_rx == tp->cur_rx) {
@@ -2499,7 +2499,7 @@ static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 
 static int
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
-		     void __iomem *ioaddr)
+		     void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int delta, count;
@@ -2510,7 +2510,7 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
-	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
+	rx_left = rtl8169_rx_quota(rx_left, budget);
 
 	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
@@ -2659,7 +2659,7 @@ rtl8169_interrupt(int irq, void *dev_instance)
 #else
 		/* Rx interrupt */
 		if (status & (RxOK | RxOverflow | RxFIFOOver)) {
-			rtl8169_rx_interrupt(dev, tp, ioaddr);
+			rtl8169_rx_interrupt(dev, tp, ioaddr, ~(u32)0);
 		}
 		/* Tx interrupt */
 		if (status & (TxOK | TxErr))
@@ -2682,19 +2682,17 @@ out:
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
@@ -2707,7 +2705,7 @@ static int rtl8169_poll(struct net_device *dev, int *budget)
 		RTL_W16(IntrMask, rtl8169_intr_mask);
 	}
 
-	return (work_done >= work_to_do);
+	return work_done;
 }
 #endif
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e8e0d94..77eca82 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2482,7 +2482,7 @@ static void free_rx_buffers(struct s2io_nic *sp)
 
 /**
  * s2io_poll - Rx interrupt handler for NAPI support
- * @dev : pointer to the device structure.
+ * @napi : pointer to the napi structure.
  * @budget : The number of packets that were budgeted to be processed
  * during  one pass through the 'Poll" function.
  * Description:
@@ -2493,8 +2493,9 @@ static void free_rx_buffers(struct s2io_nic *sp)
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-static int s2io_poll(struct net_device *dev, int *budget)
+static int s2io_poll(struct napi_struct *napi, int budget)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct s2io_nic *nic = dev->priv;
 	int pkt_cnt = 0, org_pkts_to_process;
 	struct mac_info *mac_control;
@@ -2506,9 +2507,7 @@ static int s2io_poll(struct net_device *dev, int *budget)
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	nic->pkts_to_process = *budget;
-	if (nic->pkts_to_process > dev->quota)
-		nic->pkts_to_process = dev->quota;
+	nic->pkts_to_process = budget;
 	org_pkts_to_process = nic->pkts_to_process;
 
 	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
@@ -2522,11 +2521,7 @@ static int s2io_poll(struct net_device *dev, int *budget)
 			goto no_rx;
 		}
 	}
-	if (!pkt_cnt)
-		pkt_cnt = 1;
 
-	dev->quota -= pkt_cnt;
-	*budget -= pkt_cnt;
 	netif_rx_complete(dev);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
@@ -2540,12 +2535,9 @@ static int s2io_poll(struct net_device *dev, int *budget)
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
 			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
@@ -2554,7 +2546,7 @@ no_rx:
 		}
 	}
 	atomic_dec(&nic->isr_cnt);
-	return 1;
+	return pkt_cnt;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -6933,8 +6925,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
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
index 0de0c65..21f1041 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -987,7 +987,7 @@ static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
 static void s2io_reset(struct s2io_nic * sp);
-static int s2io_poll(struct net_device *dev, int *budget);
+static int s2io_poll(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index e482e7f..4da9ea8 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2981,14 +2981,14 @@ static void skge_tx_done(struct net_device *dev)
 	netif_tx_unlock(dev);
 }
 
-static int skge_poll(struct net_device *dev, int *budget)
+static int skge_poll(struct napi_struct *napi, int to_do)
 {
+	struct net_device *dev = container_of(napi, struct net_device, napi);
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	struct skge_ring *ring = &skge->rx_ring;
 	struct skge_element *e;
 	unsigned long flags;
-	int to_do = min(dev->quota, *budget);
 	int work_done = 0;
 
 	skge_tx_done(dev);
@@ -3018,21 +3018,17 @@ static int skge_poll(struct net_device *dev, int *budget)
 	/* restart receiver */
 	wmb();
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_START);
+	
+	if (work_done < to_do) {
+		spin_lock_irq(&hw->hw_lock);
+		__netif_rx_complete(dev);
+		hw->intr_mask |= irqmask[skge->port];
+		skge_write32(hw, B0_IMSK, hw->intr_mask);
+		skge_read32(hw, B0_IMSK);
+		spin_unlock_irq(&hw->hw_lock);
+	}
 
-	*budget -= work_done;
-	dev->quota -= work_done;
-
-	if (work_done >=  to_do)
-		return 1; /* not done */
-
-	spin_lock_irqsave(&hw->hw_lock, flags);
-	__netif_rx_complete(dev);
-	hw->intr_mask |= irqmask[skge->port];
-  	skge_write32(hw, B0_IMSK, hw->intr_mask);
-	skge_read32(hw, B0_IMSK);
-	spin_unlock_irqrestore(&hw->hw_lock, flags);
-
-	return 0;
+	return work_done;
 }
 
 /* Parity errors seem to happen when Genesis is connected to a switch
@@ -3497,8 +3493,8 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
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
index 52edbd7..556221a 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2357,19 +2357,16 @@ static inline void sky2_idle_start(struct sky2_hw *hw)
 static void sky2_idle(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
-	struct net_device *dev = hw->dev[0];
-
-	if (__netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	
+	napi_schedule(&hw->napi);
 
 	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
 
 
-static int sky2_poll(struct net_device *dev0, int *budget)
+static int sky2_poll(struct napi_struct *napi, int work_limit)
 {
-	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
-	int work_limit = min(dev0->quota, *budget);
+	struct sky2_hw *hw = container_of(napi, struct sky2_hw, napi);
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
@@ -2402,21 +2399,16 @@ static int sky2_poll(struct net_device *dev0, int *budget)
 
 	work_done = sky2_status_intr(hw, work_limit);
 	if (work_done < work_limit) {
-		netif_rx_complete(dev0);
+		napi_complete(napi);
 
 		sky2_read32(hw, B0_Y2_SP_LISR);
-		return 0;
-	} else {
-		*budget -= work_done;
-		dev0->quota -= work_done;
-		return 1;
 	}
+	return work_done;
 }
 
 static irqreturn_t sky2_intr(int irq, void *dev_id)
 {
 	struct sky2_hw *hw = dev_id;
-	struct net_device *dev0 = hw->dev[0];
 	u32 status;
 
 	/* Reading this mask interrupts as side effect */
@@ -2425,8 +2417,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	prefetch(&hw->st_le[hw->st_idx]);
-	if (likely(__netif_rx_schedule_prep(dev0)))
-		__netif_rx_schedule(dev0);
+	
+	napi_schedule(&hw->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2435,10 +2427,8 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
 static void sky2_netpoll(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct net_device *dev0 = sky2->hw->dev[0];
 
-	if (netif_running(dev) && __netif_rx_schedule_prep(dev0))
-		__netif_rx_schedule(dev0);
+	napi_schedule(&sky2->hw->napi);
 }
 #endif
 
@@ -3370,16 +3360,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
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
@@ -3553,6 +3533,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
+	hw->napi.poll = sky2_poll;
+	hw->napi.weight = NAPI_WEIGHT;
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index ac24bdc..b2968ff 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1921,6 +1921,7 @@ struct sky2_port {
 struct sky2_hw {
 	void __iomem  	     *regs;
 	struct pci_dev	     *pdev;
+	struct napi_struct   napi;
 	struct net_device    *dev[2];
 
 	u8	     	     chip_id;
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index bf873ea..6749e58 100644
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
@@ -1533,20 +1533,18 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 
 
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
@@ -1559,10 +1557,11 @@ static int netdev_poll(struct net_device *dev, int *budget)
 
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
index 616be8d..10e3568 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -881,19 +881,20 @@ static int gem_rx(struct gem *gp, int work_to_do)
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
@@ -912,15 +913,10 @@ static int gem_poll(struct net_device *dev, int *budget)
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
 
@@ -931,7 +927,8 @@ static int gem_poll(struct net_device *dev, int *budget)
 	gem_enable_ints(gp);
 
 	spin_unlock_irqrestore(&gp->lock, flags);
-	return 0;
+
+	return work_done;
 }
 
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
@@ -3114,8 +3111,8 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
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
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 81a1c2e..0d1e385 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3420,11 +3420,12 @@ next_pkt_nopost:
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
@@ -3453,18 +3454,8 @@ static int tg3_poll(struct net_device *netdev, int *budget)
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with dev->poll()
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
@@ -3473,13 +3464,12 @@ static int tg3_poll(struct net_device *netdev, int *budget)
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
@@ -11799,9 +11789,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
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
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index e3488d7..ad81eb0 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -106,25 +106,23 @@ void oom_timer(unsigned long data)
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
 	int received = 0;
 
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
@@ -144,14 +142,13 @@ int tulip_poll(struct net_device *dev, int *budget)
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
@@ -239,7 +236,6 @@ int tulip_poll(struct net_device *dev, int *budget)
                                tp->stats.rx_packets++;
                                tp->stats.rx_bytes += pkt_len;
                        }
-                       received++;
 
                        entry = (++tp->cur_rx) % RX_RING_SIZE;
                        if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
@@ -297,13 +293,11 @@ done:
 
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
 
@@ -321,28 +315,20 @@ done:
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
 
@@ -353,7 +339,7 @@ done:
          /* remove ourselves from the polling list */
          netif_rx_complete(dev);
 
-         return 0;
+         return work_done;
 }
 
 #else /* CONFIG_TULIP_NAPI */
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 25f25da..7396f2c 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -428,7 +428,7 @@ extern int tulip_rx_copybreak;
 irqreturn_t tulip_interrupt(int irq, void *dev_instance);
 int tulip_refill_rx(struct net_device *dev);
 #ifdef CONFIG_TULIP_NAPI
-int tulip_poll(struct net_device *dev, int *budget);
+int tulip_poll(struct napi_struct *napi, int budget);
 #endif
 
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 5a35354..03e6c93 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1623,8 +1623,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
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
index 9781b16..a231088 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1770,12 +1770,12 @@ typhoon_fill_free_ring(struct typhoon *tp)
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
@@ -1784,30 +1784,16 @@ typhoon_poll(struct net_device *dev, int *total_budget)
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
@@ -1815,14 +1801,14 @@ typhoon_poll(struct net_device *dev, int *total_budget)
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
@@ -2538,8 +2524,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index ebbda1d..7aa46b0 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -575,17 +575,16 @@ static void rhine_poll(struct net_device *dev)
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
@@ -593,10 +592,8 @@ static int rhine_napipoll(struct net_device *dev, int *budget)
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
 
@@ -781,8 +778,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
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
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1a52854..c90771c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -31,6 +31,7 @@
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
+#include <linux/delay.h>
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
@@ -242,7 +243,6 @@ enum netdev_state_t
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
-	__LINK_STATE_RX_SCHED,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
 	__LINK_STATE_QDISC_RUNNING,
@@ -262,6 +262,73 @@ struct netdev_boot_setup {
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
@@ -402,12 +469,7 @@ struct net_device
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
@@ -613,7 +675,6 @@ static inline int unregister_gifconf(unsigned int family)
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
  */
-
 struct softnet_data
 {
 	struct net_device	*output_queue;
@@ -621,7 +682,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct net_device	backlog_dev;	/* Sorry. 8) */
+	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
@@ -677,20 +738,7 @@ static inline int netif_running(const struct net_device *dev)
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
@@ -836,10 +884,11 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
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
@@ -851,8 +900,11 @@ static inline int netif_rx_schedule_prep(struct net_device *dev)
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
 
@@ -862,64 +914,34 @@ static inline void netif_rx_schedule(struct net_device *dev)
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
 /* Remove interface from poll list: it must be in the poll list
  * on current cpu. This primitive is called by dev->poll(), when
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
+static inline void __netif_rx_complete(struct net_device *dev)
+{
+	napi_complete(&dev->napi);
+	dev_put(dev);
+}
+
 static inline void netif_rx_complete(struct net_device *dev)
 {
 	unsigned long flags;
 
 	local_irq_save(flags);
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
-	smp_mb__before_clear_bit();
-	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	__netif_rx_complete(dev);
 	local_irq_restore(flags);
 }
 
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
-}
-
-/* same as netif_rx_complete, except that local_irq_save(flags)
- * has already been issued
- */
-static inline void __netif_rx_complete(struct net_device *dev)
-{
-	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
-	list_del(&dev->poll_list);
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
index cf71614..7355860 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -206,7 +206,8 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
  *	Device drivers call our routines to queue packets here. We empty the
  *	queue in the local softnet handler.
  */
-DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL };
+
+DEFINE_PER_CPU(struct softnet_data, softnet_data) = { NULL, };
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
@@ -919,10 +920,7 @@ int dev_close(struct net_device *dev)
 	 * engine, but this requires more changes in devices. */
 
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		msleep(1);
-	}
+	netif_poll_disable(dev);
 
 	/*
 	 *	Call the device specific close. This cannot fail.
@@ -1116,21 +1114,21 @@ void __netif_schedule(struct net_device *dev)
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
@@ -1553,6 +1551,28 @@ int weight_p = 64;            /* old backlog weight */
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
@@ -1600,7 +1620,7 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
 
-		netif_rx_schedule(&queue->backlog_dev);
+		napi_schedule(&queue->backlog);
 		goto enqueue;
 	}
 
@@ -1641,6 +1661,38 @@ static inline struct net_device *skb_bond(struct sk_buff *skb)
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
@@ -1769,7 +1821,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	__be16 type;
 
 	/* if we've gotten here through NAPI, check netpoll */
-	if (skb->dev->poll && netpoll_rx(skb))
+	if (skb->dev->napi.poll && netpoll_rx(skb))
 		return NET_RX_DROP;
 
 	if (!skb->tstamp.off_sec)
@@ -1854,89 +1906,103 @@ out:
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
+
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
 	}
-out:
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -1950,13 +2016,6 @@ out:
 		rcu_read_unlock();
 	}
 #endif
-	local_irq_enable();
-	return;
-
-softnet_break:
-	__get_cpu_var(netdev_rx_stat).time_squeeze++;
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	goto out;
 }
 
 static gifconf_func_t * gifconf_list [NPROTO];
@@ -3503,10 +3562,9 @@ static int __init net_dev_init(void)
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
index 4cbb129..ebfab9b 100644
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
index da10194..a2efb99 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -47,7 +47,6 @@ static atomic_t trapped;
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
@@ -638,8 +614,6 @@ int netpoll_setup(struct netpoll *np)
 
 		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
-		spin_lock_init(&npinfo->poll_lock);
-		npinfo->poll_owner = -1;
 
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6055074..14be1c6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -331,7 +331,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 
 	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
 	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
-	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
+	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->napi.weight);
 	NLA_PUT_U8(skb, IFLA_OPERSTATE,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
@@ -560,7 +560,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
 	if (tb[IFLA_WEIGHT])
-		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
+		dev->napi.weight = nla_get_u32(tb[IFLA_WEIGHT]);
 
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
