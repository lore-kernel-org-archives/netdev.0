From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Wed, 16 May 2007 23:25:46 -0400
Message-ID: <1179372347.4084.39.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>
	 <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
	 <1179355932.4084.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ptVNJogebjGxL0lU9bQJ"
Cc: David Miller <davem@davemloft.net>, xma@us.ibm.com,
	rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Auke <auke-jan.h.kok@intel.com>, Gagan Arneja <gagan@vmware.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:4416 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576AbXEQDZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 23:25:52 -0400
Received: by wr-out-0506.google.com with SMTP id 76so467181wra
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 20:25:52 -0700 (PDT)
In-Reply-To: <1179355932.4084.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ptVNJogebjGxL0lU9bQJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2007-16-05 at 18:52 -0400, jamal wrote:
> On Wed, 2007-16-05 at 15:12 -0700, Sridhar Samudrala wrote:

> 
> I will have to think a bit about this; i may end up coalescing when
> grabbing the packets but call the nit from the driver using a helper.
> 

Thats what i did. This would hopefully work with GSO now (infact nit
works now with GSO when it didnt before).

This patch now includes two changed drivers (tun and e1000). I have
tested tun with this patch. I tested e1000 earlier and i couldnt find
any issues - although as the tittle says its a WIP.

As before you need net-2.6. You also need the qdisc restart cleanup
patch.

Please comment.

If all is good, I think my next efforts will be to convert pktgen to be
aware of the api so we can have some serious traffic generation.

cheers,
jamal

--=-ptVNJogebjGxL0lU9bQJ
Content-Disposition: attachment; filename=combined-batch-p
Content-Type: text/x-patch; name=combined-batch-p; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 637ae8f..b4c900e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -154,6 +154,8 @@ static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+static int e1000_prep_queue_frame(struct sk_buff *skb, struct net_device *dev);
+static int e1000_xmit_frames(struct sk_buff_head *list, struct net_device *dev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
@@ -932,6 +934,8 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->open = &e1000_open;
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
+	netdev->hard_prep_xmit = &e1000_prep_queue_frame;
+	netdev->hard_batch_xmit = &e1000_xmit_frames;
 	netdev->get_stats = &e1000_get_stats;
 	netdev->set_multicast_list = &e1000_set_multi;
 	netdev->set_mac_address = &e1000_set_mac;
@@ -940,6 +944,7 @@ e1000_probe(struct pci_dev *pdev,
 	e1000_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+	skb_queue_head_init(&netdev->blist);
 #ifdef CONFIG_E1000_NAPI
 	netdev->poll = &e1000_clean;
 	netdev->weight = 64;
@@ -998,6 +1003,7 @@ e1000_probe(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->features |= NETIF_F_LLTX;
+	netdev->features |= NETIF_F_BTX;
 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
@@ -1155,6 +1161,7 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = register_netdev(netdev)))
 		goto err_register;
 
+	netdev->xmit_win = adapter->tx_ring->count>>1;
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
@@ -1449,6 +1456,7 @@ e1000_open(struct net_device *netdev)
 	/* fire a link status change interrupt to start the watchdog */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 
+	printk("%s Batch window is %d\n",netdev->name, netdev->xmit_win);
 	return E1000_SUCCESS;
 
 err_req_irq:
@@ -1503,6 +1511,7 @@ e1000_close(struct net_device *netdev)
 	    e1000_check_mng_mode(&adapter->hw))
 		e1000_release_hw_control(adapter);
 
+	skb_queue_purge(&netdev->blist);
 	return 0;
 }
 
@@ -3098,6 +3107,18 @@ e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 }
 
 static void
+e1000_kick_DMA(struct e1000_adapter *adapter,
+               struct e1000_tx_ring *tx_ring, int i)
+{
+	wmb();
+	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
+	/* we need this if more than one processor can write to our tail
+	** at a time, it syncronizes IO on IA64/Altix systems */
+	mmiowb();
+}
+
+
+static void
 e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
                int tx_flags, int count)
 {
@@ -3139,17 +3160,7 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
-	/* Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64). */
-	wmb();
-
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it syncronizes IO on IA64/Altix systems */
-	mmiowb();
 }
 
 /**
@@ -3256,54 +3267,60 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
+struct e1000_tx_cbdata {
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+};
+
+#define E1000_SKB_CB(__skb)       ((struct e1000_tx_cbdata *)&((__skb)->cb[0]))
+#define NETDEV_TX_DROPPED	-5
+
 static int
-e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+e1000_prep_queue_frame(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_tx_ring *tx_ring;
-	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
+	unsigned int f;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
-	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
-	int count = 0;
-	int tso;
-	unsigned int f;
+
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
+	cb->mss = 0;
+	cb->nr_frags = 0;
+	cb->max_per_txd = E1000_MAX_DATA_PER_TXD;
+	cb->count = 0;
+
 	len -= skb->data_len;
 
-	/* This goes back to the question of how to logically map a tx queue
-	 * to a flow.  Right now, performance is impacted slightly negatively
-	 * if using multiple tx queues.  If the stack breaks away from a
-	 * single qdisc implementation, we can look at this again. */
 	tx_ring = adapter->tx_ring;
 
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
-	/* 82571 and newer doesn't need the workaround that limited descriptor
-	 * length to 4kB */
+	/* 82571 and newer doesn't need the workaround that limited 
+	   descriptor length to 4kB */
 	if (adapter->hw.mac_type >= e1000_82571)
-		max_per_txd = 8192;
+		cb->max_per_txd = 8192;
 
-	mss = skb_shinfo(skb)->gso_size;
+	cb->mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
-	if (mss) {
+	if (cb->mss) {
 		uint8_t hdr_len;
-		max_per_txd = min(mss << 2, max_per_txd);
-		max_txd_pwr = fls(max_per_txd) - 1;
+		cb->max_per_txd = min(cb->mss << 2, cb->max_per_txd);
+		max_txd_pwr = fls(cb->max_per_txd) - 1;
 
 		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
-		* points to just header, pull a few bytes of payload from
-		* frags into skb->data */
+		 * points to just header, pull a few bytes of payload from
+		 * frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
 			switch (adapter->hw.mac_type) {
@@ -3315,7 +3332,8 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				 * NOTE: this is a TSO only workaround
 				 * if end byte alignment not correct move us
 				 * into the next dword */
-				if ((unsigned long)(skb_tail_pointer(skb) - 1) & 4)
+				if ((unsigned long)(skb_tail_pointer(skb) -
+						    1) & 4)
 					break;
 				/* fall through */
 			case e1000_82571:
@@ -3327,7 +3345,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 					DPRINTK(DRV, ERR,
 						"__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
-					return NETDEV_TX_OK;
+					return NETDEV_TX_DROPPED;
 				}
 				len = skb->len - skb->data_len;
 				break;
@@ -3339,46 +3357,56 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	/* reserve a descriptor for the offload context */
-	if ((mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
-		count++;
-	count++;
+	if ((cb->mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
+		cb->count++;
+	cb->count++;
 
 	/* Controller Erratum workaround */
 	if (!skb->data_len && tx_ring->last_tx_tso && !skb_is_gso(skb))
-		count++;
+		cb->count++;
 
-	count += TXD_USE_COUNT(len, max_txd_pwr);
+	cb->count += TXD_USE_COUNT(len, max_txd_pwr);
 
 	if (adapter->pcix_82544)
-		count++;
+		cb->count++;
 
 	/* work-around for errata 10 and it applies to all controllers
 	 * in PCI-X mode, so add one more descriptor to the count
 	 */
 	if (unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
-			(len > 2015)))
-		count++;
+		     (len > 2015)))
+		cb->count++;
 
-	nr_frags = skb_shinfo(skb)->nr_frags;
-	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
-				       max_txd_pwr);
+	cb->nr_frags = skb_shinfo(skb)->nr_frags;
+	for (f = 0; f < cb->nr_frags; f++)
+		cb->count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+					   max_txd_pwr);
 	if (adapter->pcix_82544)
-		count += nr_frags;
-
+		cb->count += cb->nr_frags;
 
 	if (adapter->hw.tx_pkt_filtering &&
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
+	return NETDEV_TX_OK;
+}
+
+/* invoked under tx_ring->lock */
+static int e1000_queue_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_tx_ring *tx_ring;
+	int tso;
+	unsigned int first;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	unsigned int tx_flags = 0;
+
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
+	tx_ring = adapter->tx_ring;
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, cb->count + 2))) {
+		netif_stop_queue(netdev);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -3386,7 +3414,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
-			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -3401,8 +3428,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = e1000_tso(adapter, tx_ring, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
 	if (likely(tso)) {
@@ -3418,16 +3444,157 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
 	e1000_tx_queue(adapter, tx_ring, tx_flags,
-	               e1000_tx_map(adapter, tx_ring, skb, first,
-	                            max_per_txd, nr_frags, mss));
+		       e1000_tx_map(adapter, tx_ring, skb, first,
+				    cb->max_per_txd, cb->nr_frags, cb->mss));
 
-	netdev->trans_start = jiffies;
+	return NETDEV_TX_OK;
+}
+
+/* called with tx_ring->lock held */
+static int real_e1000_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct e1000_adapter *adapter = netdev_priv(dev);
+	int ret = NETDEV_TX_OK;
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+
+	ret = e1000_queue_frame(skb, dev);
+
+	if (ret == NETDEV_TX_OK) {
+		e1000_kick_DMA(adapter, tx_ring, adapter->tx_ring->next_to_use);
+		dev->trans_start = jiffies;
+	}
+	if (ret == NETDEV_TX_DROPPED)
+		ret = NETDEV_TX_OK;
 
-	/* Make sure there is space in the ring for the next send. */
-	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+	/* XXX: This seems so unnecessary, because if we are 
+	 * NETDEV_TX_BUSY already, we are already 
+	 * netif_queue_stopped(dev)
+	 * but its what the driver does, resolve later */
 
+	if (unlikely(e1000_maybe_stop_tx(dev, tx_ring, MAX_SKB_FRAGS + 2))) {
+		dev->xmit_win = 1;
+		netif_stop_queue(dev);
+		ret = NETDEV_TX_BUSY;
+	} else {
+		int rspace = E1000_DESC_UNUSED(tx_ring) - (MAX_SKB_FRAGS + 2);
+		dev->xmit_win = rspace;
+	}
+
+	if (ret == NETDEV_TX_BUSY)
+		printk("Single: %s stopped with win of %d\n",
+			dev->name,dev->xmit_win);
+	return ret;
+}
+
+/* single frame transmitter */
+static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	int ret = NETDEV_TX_OK;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	unsigned long flags;
+	struct e1000_tx_cbdata *cb; 
+
+	/* hopefully we will never cb data > 48 bytes .. */
+	memset(skb->cb, 0, sizeof(skb->cb));
+	ret = netdev->hard_prep_xmit(skb, netdev);
+	if (ret != NETDEV_TX_OK)
+		return NETDEV_TX_OK;
+
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
+
+	cb = E1000_SKB_CB(skb);
+	/* need: count + 2 desc gap to keep tail from touching
+	 * head, otherwise try next time */
+	/* XXX: This seems so unnecessary, because if we are 
+	 * NETDEV_TX_BUSY already, we are already 
+	 * netif_queue_stopped(dev)
+	 * but its what the driver does, resolve later */
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, cb->count + 2))) {
+		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	ret = real_e1000_xmit_frame(skb, netdev);
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
-	return NETDEV_TX_OK;
+	return ret;
+}
+
+/*
+ * Batch transmit
+*/
+static int
+e1000_xmit_frames(struct sk_buff_head *list, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	int ret = NETDEV_TX_OK;
+	int didq = 0;
+	struct sk_buff *skb = NULL;
+	unsigned long flags;
+
+	/* 
+	 * we should probably wait for this lock!
+	 */
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		memset(skb->cb, 0, sizeof(skb->cb)); /* remove? */
+		ret = netdev->hard_prep_xmit(skb, netdev);
+		if (ret != NETDEV_TX_OK)
+			continue;
+
+		/*XXX: This may be an opportunity to not give nit
+		 * the packet if the dev ix TX BUSY ;-> */
+		dev_do_xmit_nit(skb, netdev);
+		ret = e1000_queue_frame(skb, netdev);
+		if (ret == NETDEV_TX_OK) {
+			didq++;
+		} else {
+			/* should never happen, but murphy is around */
+			if (ret == NETDEV_TX_BUSY) {
+				__skb_queue_head(list, skb);
+				    break;
+			}
+		}
+	}
+
+	/* we tried to send as many as we could .. */
+	if (didq) {
+		e1000_kick_DMA(adapter, tx_ring, adapter->tx_ring->next_to_use);
+		netdev->trans_start = jiffies;
+	}
+
+	if (ret == NETDEV_TX_DROPPED)
+		ret = NETDEV_TX_OK;
+
+	/* XXX: This seems so unnecessary, because if we are 
+	 * NETDEV_TX_BUSY already, we are already 
+	 * netif_queue_stopped(dev)
+	 * but its what the driver does, resolve later */
+	/* need: MAX_SKB_FRAGS + 2 desc gap to keep tail from touching
+	 * head, otherwise try next time */
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2))) {
+		netdev->xmit_win = 1;
+		netif_stop_queue(netdev);
+		ret = NETDEV_TX_BUSY;
+	} else {
+		int rspace = E1000_DESC_UNUSED(tx_ring) - (MAX_SKB_FRAGS + 2);
+		netdev->xmit_win = rspace;
+		printk("batch %s still awake with win of %d\n",
+			netdev->name, netdev->xmit_win);
+	}
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	if (ret == NETDEV_TX_BUSY)
+		printk("Batch: %s stopped with win of %d\n",
+			netdev->name, netdev->xmit_win);
+	return ret;
 }
 
 /**
@@ -4032,7 +4199,10 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		 */
 		smp_mb();
 		if (netif_queue_stopped(netdev)) {
+			netdev->xmit_win = E1000_DESC_UNUSED(tx_ring);
 			netif_wake_queue(netdev);
+			printk(" %s woken with win of %d\n",
+				netdev->name,netdev->xmit_win);
 			++adapter->restart_queue;
 		}
 	}
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a2c6caa..e128ae3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -70,6 +70,7 @@
 static int debug;
 #endif
 
+#define NETDEV_LTT 4 /* the low threshold to open up the tx path */
 /* Network device part of the driver */
 
 static LIST_HEAD(tun_dev_list);
@@ -86,9 +87,56 @@ static int tun_net_open(struct net_device *dev)
 static int tun_net_close(struct net_device *dev)
 {
 	netif_stop_queue(dev);
+	skb_queue_purge(&dev->blist);
 	return 0;
 }
 
+/* Batch Net device start xmit
+ * combine with non-batching version
+ * */
+static int tun_net_bxmit(struct sk_buff_head *skbs, struct net_device *dev)
+{
+	struct sk_buff *skb;
+	int didq = 0;
+	struct tun_struct *tun = netdev_priv(dev);
+	u32 qlen = skb_queue_len(&tun->readq);
+
+	/* Drop packet if interface is not attached */
+	if (!tun->attached) {
+		tun->stats.tx_dropped+=skb_queue_len(&dev->blist);
+		skb_queue_purge(&dev->blist);
+		return NETDEV_TX_OK;
+	}
+
+	while (skb_queue_len(&dev->blist)) {
+		skb = __skb_dequeue(skbs);
+		if (!skb)
+			break;
+		dev_do_xmit_nit(skb, dev);
+		skb_queue_tail(&tun->readq, skb);
+		didq++;
+	}
+
+	qlen = skb_queue_len(&tun->readq);
+	if (qlen >= dev->tx_queue_len) {
+		netif_stop_queue(dev);
+		tun->stats.tx_fifo_errors++;
+		dev->xmit_win = 1;
+	} else {
+		dev->xmit_win = dev->tx_queue_len - qlen;
+	}
+
+	if (didq)
+		dev->trans_start = jiffies;
+
+	/* Notify and wake up reader process */
+	if (tun->flags & TUN_FASYNC)
+		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
+	wake_up_interruptible(&tun->read_wait);
+
+	return NETDEV_TX_OK;
+}
+
 /* Net device start xmit */
 static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -207,6 +255,7 @@ static void tun_net_init(struct net_device *dev)
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
+	dev->xmit_win = dev->tx_queue_len>>1; /* handwave, handwave */
 }
 
 /* Character device part */
@@ -382,7 +431,13 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 			schedule();
 			continue;
 		}
-		netif_wake_queue(tun->dev);
+		{
+			u32 t = skb_queue_len(&tun->readq);
+			if (netif_queue_stopped(tun->dev) && t < NETDEV_LTT) {
+				tun->dev->xmit_win = tun->dev->tx_queue_len;
+				netif_wake_queue(tun->dev);
+			}
+		}
 
 		/** Decide whether to accept this packet. This code is designed to
 		 * behave identically to an Ethernet interface. Accept the packet if
@@ -429,6 +484,7 @@ static void tun_setup(struct net_device *dev)
 	struct tun_struct *tun = netdev_priv(dev);
 
 	skb_queue_head_init(&tun->readq);
+	skb_queue_head_init(&dev->blist);
 	init_waitqueue_head(&tun->read_wait);
 
 	tun->owner = -1;
@@ -436,6 +492,8 @@ static void tun_setup(struct net_device *dev)
 	SET_MODULE_OWNER(dev);
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
+	dev->hard_prep_xmit = NULL;
+	dev->hard_batch_xmit = tun_net_bxmit;
 	dev->stop = tun_net_close;
 	dev->get_stats = tun_net_stats;
 	dev->ethtool_ops = &tun_ethtool_ops;
@@ -458,7 +516,7 @@ static struct tun_struct *tun_get_by_name(const char *name)
 static int tun_set_iff(struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	int err;
 
 	tun = tun_get_by_name(ifr->ifr_name);
@@ -528,12 +586,15 @@ static int tun_set_iff(struct file *file, struct ifreq *ifr)
 	}
 
 	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
+	dev->features |= NETIF_F_BTX;
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
 
-	if (ifr->ifr_flags & IFF_ONE_QUEUE)
+	if (ifr->ifr_flags & IFF_ONE_QUEUE) {
 		tun->flags |= TUN_ONE_QUEUE;
+		dev->features &= ~NETIF_F_BTX;
+	}
 
 	file->private_data = tun;
 	tun->attached = 1;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f671cd2..85a1baf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -325,6 +325,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_BTX		8192	/* Capable of batch tx */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -450,6 +451,11 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	int			(*hard_batch_xmit) (struct sk_buff_head *list,
+						    struct net_device *dev);
+	int			(*hard_prep_xmit) (struct sk_buff *skb,
+						    struct net_device *dev);
+	int			xmit_win;
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -466,6 +472,10 @@ struct net_device
 	struct list_head	todo_list;
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
+	/*XXX: Fix eventually to not allocate if device not
+	 *batch capable
+	*/
+	struct sk_buff_head	blist;
 
 	struct net_device	*link_watch_next;
 
@@ -742,7 +752,12 @@ extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
-
+extern int		do_gso_skb(struct sk_buff *skb,
+			           struct sk_buff_head *skbs);
+extern int		do_possible_gso_skb(struct sk_buff *skb,
+					    struct net_device *dev);
+extern void 		dev_do_xmit_nit(struct sk_buff *skb, 
+					struct net_device *dev);
 extern void		dev_init(void);
 
 extern int		netdev_budget;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8301e2a..0d728cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1372,6 +1372,47 @@ out_kfree_skb:
 	return 0;
 }
 
+int do_gso_skb(struct sk_buff *skb, struct sk_buff_head *skbs)
+{
+	int tdq = 0;
+	do {
+		struct sk_buff *nskb = skb->next;
+
+		skb->next = nskb->next;
+		nskb->next = NULL;
+		tdq++;
+		__skb_queue_head(skbs, skb);
+	} while (skb->next);
+	skb->destructor = DEV_GSO_CB(skb)->destructor;
+
+	return tdq;
+}
+
+int do_possible_gso_skb(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff_head *skbs = &dev->blist;
+
+	if (netif_needs_gso(dev, skb)) {
+		if (unlikely(dev_gso_segment(skb))) {
+			kfree_skb(skb);
+			return 0;
+		}
+		if (skb->next)
+			return do_gso_skb(skb, skbs);
+	}
+
+	__skb_queue_head(skbs, skb);
+	return 1;
+}
+
+/* invoked by driver when batching once figured skb is sane*/
+void  dev_do_xmit_nit(struct sk_buff *skb, struct net_device *dev)
+{
+	if (!list_empty(&ptype_all))
+		dev_queue_xmit_nit(skb, dev);
+}
+
+
 #define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		netif_tx_lock(dev);			\
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 9cd3a1c..530de14 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3217,9 +3217,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			pkt_dev->next_tx_us++;
 			pkt_dev->next_tx_ns -= 1000;
 		}
-	}
-
-	else {			/* Retry it next time */
+	} else { /* netif_queue_stopped -- Retry it next time */
 		pkt_dev->last_ok = 0;
 		pkt_dev->next_tx_us = getCurUs();	/* TODO */
 		pkt_dev->next_tx_ns = 0;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ed80054..4fe5a9b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -85,10 +85,12 @@ static inline int
 do_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
 {
 
-	if (unlikely(skb->next))
-		dev->gso_skb = skb;
-	else
-		q->ops->requeue(skb, q);
+	if (skb) {
+		if (unlikely(skb->next))
+			dev->gso_skb = skb;
+		else
+			q->ops->requeue(skb, q);
+	}
 	/* XXX: Could netif_schedule fail? Or is that fact we are
 	 * requeueing imply the hardware path is closed
 	 * and even if we fail, some interupt will wake us
@@ -116,7 +118,10 @@ tx_islocked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
 	int ret = handle_dev_cpu_collision(dev);
 
 	if (ret == SCHED_TX_DROP) {
-		kfree_skb(skb);
+		if (skb) /* we are not batching */
+			kfree_skb(skb);
+		else if (!skb_queue_empty(&dev->blist))
+			skb_queue_purge(&dev->blist);
 		return qdisc_qlen(q);
 	}
 
@@ -195,10 +200,104 @@ static inline int qdisc_restart(struct net_device *dev)
 	return do_dev_requeue(skb, dev, q);
 }
 
+static int try_get_tx_pkts(struct net_device *dev, struct Qdisc *q, int count)
+{
+	struct sk_buff *skb;
+	struct sk_buff_head *skbs = &dev->blist;
+	int tdq = 0;
+
+	/* 
+	 * very unlikely, but who knows ..
+	 * If this happens we dont try to grab more pkts
+	 */
+	if (!skb_queue_empty(&dev->blist))
+		return skb_queue_len(&dev->blist);
+
+	if (unlikely(dev->gso_skb)) {
+		skb = dev->gso_skb;
+		dev->gso_skb = NULL;
+		tdq = do_gso_skb(skb, skbs);
+	}
+
+	if (tdq > count)
+		return tdq; /*we will stop here */
+
+	count -= tdq;
+	while (count > 0) {
+		skb = q->dequeue(q);
+		if (!skb)
+			break;
+		
+		tdq += do_possible_gso_skb(skb, dev);
+		count -= tdq;
+	}
+
+	return tdq;
+}
+
+static inline int try_tx_pkts(struct net_device *dev)
+{
+
+	return dev->hard_batch_xmit(&dev->blist, dev);
+
+}
+
+/* same comments as in qdisc_restart apply;
+ * at some point use shared code with qdisc_restart*/
+int batch_qdisc_restart(struct net_device *dev)
+{
+	struct Qdisc *q = dev->qdisc;
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
+	int count = dev->xmit_win;
+	int ret = 0;
+
+	ret = try_get_tx_pkts(dev, q, count);
+
+	if (ret == 0)
+		return qdisc_qlen(q);
+
+	/* we have packets to send! */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return tx_islocked(NULL, dev, q);
+	}
+
+	/* all clear .. */
+	spin_unlock(&dev->queue_lock);
+
+	ret = NETDEV_TX_BUSY;
+	if (!netif_queue_stopped(dev))
+		ret = try_tx_pkts(dev);
+
+	if (!lockless)
+		netif_tx_unlock(dev);
+
+	spin_lock(&dev->queue_lock);
+
+	q = dev->qdisc;
+
+	/* most likely result, packet went ok */
+	if (ret == NETDEV_TX_OK)
+		return qdisc_qlen(q);
+	/* only for lockless drivers .. */
+	if (ret == NETDEV_TX_LOCKED && lockless)
+		return tx_islocked(NULL, dev, q);
+
+	if (unlikely(ret != NETDEV_TX_BUSY && net_ratelimit()))
+		printk(KERN_WARNING " BUG %s code %d qlen %d\n",
+		       dev->name, ret, q->q.qlen);
+
+	return do_dev_requeue(NULL, dev, q);
+}
+
 void __qdisc_run(struct net_device *dev)
 {
+	unsigned batching = (dev->features & NETIF_F_BTX);
+
 	do {
-		if (!qdisc_restart(dev))
+		if (!batching && !qdisc_restart(dev))
+			break;
+		else if (!batch_qdisc_restart(dev))
 			break;
 	} while (!netif_queue_stopped(dev));
 

--=-ptVNJogebjGxL0lU9bQJ--

