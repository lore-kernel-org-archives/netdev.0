From: Jeff Garzik <jeff@garzik.org>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 08:44:25 -0400
Message-ID: <470B77A9.600@garzik.org>
References: <20071009.040255.71088090.davem@davemloft.net>	<OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010606050503040206080604"
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.042441.30182968.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010606050503040206080604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Tue, 9 Oct 2007 16:51:14 +0530
> 
>> David Miller <davem@davemloft.net> wrote on 10/09/2007 04:32:55 PM:
>>
>>> Ignore LLTX, it sucks, it was a big mistake, and we will get rid of
>>> it.
>> Great, this will make life easy. Any idea how long that would take?
>> It seems simple enough to do.
> 
> I'd say we can probably try to get rid of it in 2.6.25, this is
> assuming we get driver authors to cooperate and do the conversions
> or alternatively some other motivated person.
> 
> I can just threaten to do them all and that should get the driver
> maintainers going :-)

What, like this?  :)

	Jeff




--------------010606050503040206080604
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"


 drivers/net/atl1/atl1_main.c   |   16 +++++-----------
 drivers/net/chelsio/cxgb2.c    |    1 -
 drivers/net/chelsio/sge.c      |   20 +++++++++-----------
 drivers/net/e1000/e1000_main.c |    6 +-----
 drivers/net/ixgb/ixgb_main.c   |   24 ------------------------
 drivers/net/pasemi_mac.c       |    2 +-
 drivers/net/rionet.c           |   19 +++++++------------
 drivers/net/spider_net.c       |    2 +-
 drivers/net/sungem.c           |   17 ++++++-----------
 drivers/net/tehuti.c           |   12 +-----------
 drivers/net/tehuti.h           |    3 +--
 11 files changed, 32 insertions(+), 90 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 4c728f1..03e94fe 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1665,10 +1665,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	len -= skb->data_len;
 
-	if (unlikely(skb->len == 0)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
+	WARN_ON(skb->len == 0);
 
 	param.data = 0;
 	param.tso.tsopu = 0;
@@ -1703,11 +1700,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
-		/* Can't get lock - tell upper layer to requeue */
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&adapter->lock, flags);
 
 	if (atl1_tpd_avail(&adapter->tpd_ring) < count) {
 		/* not enough descriptors */
@@ -1749,8 +1742,11 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	atl1_tx_map(adapter, skb, 1 == val);
 	atl1_tx_queue(adapter, count, &param);
 	netdev->trans_start = jiffies;
+
 	spin_unlock_irqrestore(&adapter->lock, flags);
+
 	atl1_update_mailbox(adapter);
+
 	return NETDEV_TX_OK;
 }
 
@@ -2301,8 +2297,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	 */
 	/* netdev->features |= NETIF_F_TSO; */
 
-	netdev->features |= NETIF_F_LLTX;
-
 	/*
 	 * patch for some L1 of old version,
 	 * the final version of L1 may not need these
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 2dbf8dc..0aba7e7 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1084,7 +1084,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-		netdev->features |= NETIF_F_LLTX;
 
 		adapter->flags |= RX_CSUM_ENABLED | TCP_CSUM_CAPABLE;
 		if (pci_using_dac)
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index ffa7e64..84f5869 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1739,8 +1739,7 @@ static int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
 	struct cmdQ *q = &sge->cmdQ[qid];
 	unsigned int credits, pidx, genbit, count, use_sched_skb = 0;
 
-	if (!spin_trylock(&q->lock))
-		return NETDEV_TX_LOCKED;
+	spin_lock(&q->lock);
 
 	reclaim_completed_tx(sge, q);
 
@@ -1817,12 +1816,12 @@ use_sched:
 	}
 
 	if (use_sched_skb) {
-		if (spin_trylock(&q->lock)) {
-			credits = q->size - q->in_use;
-			skb = NULL;
-			goto use_sched;
-		}
+		spin_lock(&q->lock);
+		credits = q->size - q->in_use;
+		skb = NULL;
+		goto use_sched;
 	}
+
 	return NETDEV_TX_OK;
 }
 
@@ -1977,13 +1976,12 @@ static void sge_tx_reclaim_cb(unsigned long data)
 	for (i = 0; i < SGE_CMDQ_N; ++i) {
 		struct cmdQ *q = &sge->cmdQ[i];
 
-		if (!spin_trylock(&q->lock))
-			continue;
+		spin_lock(&q->lock);
 
 		reclaim_completed_tx(sge, q);
-		if (i == 0 && q->in_use) {    /* flush pending credits */
+		if (i == 0 && q->in_use)	/* flush pending credits */
 			writel(F_CMDQ0_ENABLE, sge->adapter->regs + A_SG_DOORBELL);
-		}
+
 		spin_unlock(&q->lock);
 	}
 	mod_timer(&sge->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 10505de..b64b03b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -992,8 +992,6 @@ e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_LLTX;
-
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
@@ -3368,9 +3366,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
+	spin_lock_irqsave(&tx_ring->tx_lock, flags);
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d444de5..c04b59b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -449,9 +449,6 @@ ixgb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |= NETIF_F_TSO;
-#ifdef NETIF_F_LLTX
-	netdev->features |= NETIF_F_LLTX;
-#endif
 
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -1455,16 +1452,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return 0;
 	}
 
-#ifdef NETIF_F_LLTX
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->tx_lock)) {
-		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-#else
 	spin_lock_irqsave(&adapter->tx_lock, flags);
-#endif
 
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
                      DESC_NEEDED))) {
@@ -1473,9 +1461,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-#ifndef NETIF_F_LLTX
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
 
 	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
@@ -1487,9 +1473,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-#ifdef NETIF_F_LLTX
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
 		return NETDEV_TX_OK;
 	}
 
@@ -1503,13 +1486,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	netdev->trans_start = jiffies;
 
-#ifdef NETIF_F_LLTX
-	/* Make sure there is space in the ring for the next send. */
-	ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
-
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-
-#endif
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 9f9a421..78f939b 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1352,7 +1352,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_SG;
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index e7fd08a..cd2d25c 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -180,11 +180,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	u16 destid;
 	unsigned long flags;
 
-	local_irq_save(flags);
-	if (!spin_trylock(&rnet->tx_lock)) {
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&rnet->tx_lock, flags);
 
 	if ((rnet->tx_cnt + 1) > RIONET_TX_RING_SIZE) {
 		netif_stop_queue(ndev);
@@ -259,7 +255,7 @@ static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbo
 	struct net_device *ndev = dev_id;
 	struct rionet_private *rnet = ndev->priv;
 
-	spin_lock(&rnet->lock);
+	spin_lock(&rnet->tx_lock);
 
 	if (netif_msg_intr(rnet))
 		printk(KERN_INFO
@@ -278,7 +274,7 @@ static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbo
 	if (rnet->tx_cnt < RIONET_TX_RING_SIZE)
 		netif_wake_queue(ndev);
 
-	spin_unlock(&rnet->lock);
+	spin_unlock(&rnet->tx_lock);
 }
 
 static int rionet_open(struct net_device *ndev)
@@ -420,10 +416,10 @@ static void rionet_set_msglevel(struct net_device *ndev, u32 value)
 }
 
 static const struct ethtool_ops rionet_ethtool_ops = {
-	.get_drvinfo = rionet_get_drvinfo,
-	.get_msglevel = rionet_get_msglevel,
-	.set_msglevel = rionet_set_msglevel,
-	.get_link = ethtool_op_get_link,
+	.get_drvinfo	= rionet_get_drvinfo,
+	.get_msglevel	= rionet_get_msglevel,
+	.set_msglevel	= rionet_set_msglevel,
+	.get_link	= ethtool_op_get_link,
 };
 
 static int rionet_setup_netdev(struct rio_mport *mport)
@@ -461,7 +457,6 @@ static int rionet_setup_netdev(struct rio_mport *mport)
 	ndev->hard_start_xmit = &rionet_start_xmit;
 	ndev->stop = &rionet_close;
 	ndev->mtu = RIO_MAX_MSG_SIZE - 14;
-	ndev->features = NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(ndev, &rionet_ethtool_ops);
 
 	spin_lock_init(&rnet->lock);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index fab055f..22193a9 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2329,7 +2329,7 @@ spider_net_setup_netdev(struct spider_net_card *card)
 
 	spider_net_setup_netdev_ops(netdev);
 
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX;
+	netdev->features = NETIF_F_IP_CSUM;
 	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 	 *		NETIF_F_HW_VLAN_FILTER */
 
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 53b8344..6aaf56d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -932,7 +932,6 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct gem *gp = dev->priv;
-	unsigned long flags;
 
 	/* Swallow interrupts when shutting the chip down, though
 	 * that shouldn't happen, we should have done free_irq() at
@@ -941,14 +940,14 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 	if (!gp->running)
 		return IRQ_HANDLED;
 
-	spin_lock_irqsave(&gp->lock, flags);
+	spin_lock(&gp->lock);
 
 	if (netif_rx_schedule_prep(dev, &gp->napi)) {
 		u32 gem_status = readl(gp->regs + GREG_STAT);
 
 		if (gem_status == 0) {
 			napi_enable(&gp->napi);
-			spin_unlock_irqrestore(&gp->lock, flags);
+			spin_unlock(&gp->lock);
 			return IRQ_NONE;
 		}
 		gp->status = gem_status;
@@ -956,7 +955,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 		__netif_rx_schedule(dev, &gp->napi);
 	}
 
-	spin_unlock_irqrestore(&gp->lock, flags);
+	spin_unlock(&gp->lock);
 
 	/* If polling was disabled at the time we received that
 	 * interrupt, we may return IRQ_HANDLED here while we
@@ -1031,12 +1030,8 @@ static int gem_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			(csum_stuff_off << 21));
 	}
 
-	local_irq_save(flags);
-	if (!spin_trylock(&gp->tx_lock)) {
-		/* Tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&gp->tx_lock, flags);
+
 	/* We raced with gem_do_stop() */
 	if (!gp->running) {
 		spin_unlock_irqrestore(&gp->tx_lock, flags);
@@ -3160,7 +3155,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
 	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 2483431..e0da1e0 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1606,7 +1606,6 @@ static inline int bdx_tx_space(struct bdx_priv *priv)
  * o NETDEV_TX_BUSY Cannot transmit packet, try later
  *   Usually a bug, means queue start/stop flow control is broken in
  *   the driver. Note: the driver must NOT put the skb in its DMA ring.
- * o NETDEV_TX_LOCKED Locking failed, please retry quickly.
  */
 static int bdx_tx_transmit(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -1624,13 +1623,7 @@ static int bdx_tx_transmit(struct sk_buff *skb, struct net_device *ndev)
 	unsigned long flags;
 
 	ENTER;
-	local_irq_save(flags);
-	if (!spin_trylock(&priv->tx_lock)) {
-		local_irq_restore(flags);
-		DBG("%s[%s]: TX locked, returning NETDEV_TX_LOCKED\n",
-		    BDX_DRV_NAME, ndev->name);
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&priv->tx_lock, flags);
 
 	/* build tx descriptor */
 	BDX_ASSERT(f->m.wptr >= f->m.memsz);	/* started with valid wptr */
@@ -2048,9 +2041,6 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 * between transmit and TX irq cleanup.  In addition
 		 * set multicast list callback has to use priv->tx_lock.
 		 */
-#ifdef BDX_LLTX
-		ndev->features |= NETIF_F_LLTX;
-#endif
 		spin_lock_init(&priv->tx_lock);
 
 		/*bdx_hw_reset(priv); */
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efd170f..c55f69a 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -35,7 +35,6 @@
 /* Compile Time Switches */
 /* start */
 #define BDX_TSO
-#define BDX_LLTX
 #define BDX_DELAY_WPTR
 /* #define BDX_MSI */
 /* end */
@@ -270,7 +269,7 @@ struct bdx_priv {
 	int tx_update_mark;
 	int tx_noupd;
 #endif
-	spinlock_t tx_lock;	/* NETIF_F_LLTX mode */
+	spinlock_t tx_lock;
 
 	/* rarely used */
 	u8 port;

--------------010606050503040206080604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------010606050503040206080604--
