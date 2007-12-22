From: therbert@google.com (Tom Herbert)
Subject: [PATCH] Reduce locking in TX path of forcedth driver
Date: Fri, 21 Dec 2007 17:41:34 -0800 (PST)
Message-ID: <20071222014134.A28994161A0@localhost>
Cc: netdev@vger.kernel.org, therbert@google.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:30247 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXLVBls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 20:41:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the amount of locking in the TX path.  Instead of using both netif_tx_lock and dev->priv->lock on transmitting, a single private lock (dev->priv->tx_lock) is used.  This method is similar to that of the e1000 driver, including the logic to stop the queue in the start xmit functions, and the logic to wake the queue in the TX done functions.  We see some performance improvement with this patch.

Signed-off-by: Tom Herbert <therbert@google.com>

--- linux-2.6/drivers/net/forcedeth.c.orig	2007-12-21 16:26:15.743639000 -0800
+++ linux-2.6/drivers/net/forcedeth.c	2007-12-21 16:51:19.001325000 -0800
@@ -525,6 +525,12 @@ union ring_type {
 #define RING_MAX_DESC_VER_1	1024
 #define RING_MAX_DESC_VER_2_3	16384
 
+/*
+ * Maxmimum number of fragments that a single packet could need in
+ * transmit.
+ */
+#define	MAX_TX_FRAGS	(MAX_SKB_FRAGS + (65535 >> NV_TX2_TSO_MAX_SHIFT))
+
 /* rx/tx mac addr + type + vlan + align + slack*/
 #define NV_RX_HEADERS		(64)
 /* even more slack. */
@@ -738,9 +744,8 @@ struct nv_skb_map {
  * critical parts:
  * - rx is (pseudo-) lockless: it relies on the single-threading provided
  *	by the arch code for interrupts.
- * - tx setup is lockless: it relies on netif_tx_lock. Actual submission
- *	needs dev->priv->lock :-(
- * - set_multicast_list: preparation lockless, relies on netif_tx_lock.
+ * - tx uses dev->priv->tx_lock and not netif_tx_lock.  TX done processing
+ *   only acquires dev->priv->tx_lock when the queue needs to be awoken.
  */
 
 /* in dev: base, irq */
@@ -806,6 +811,7 @@ struct fe_priv {
 	/*
 	 * tx specific fields.
 	 */
+	spinlock_t tx_lock;
 	union ring_type get_tx, put_tx, first_tx, last_tx;
 	struct nv_skb_map *get_tx_ctx, *put_tx_ctx;
 	struct nv_skb_map *first_tx_ctx, *last_tx_ctx;
@@ -814,7 +820,6 @@ struct fe_priv {
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
-	int tx_stop;
 
 	/* vlan fields */
 	struct vlan_group *vlangrp;
@@ -1775,9 +1780,16 @@ static inline u32 nv_get_empty_tx_slots(
 	return (u32)(np->tx_ring_size - ((np->tx_ring_size + (np->put_tx_ctx - np->get_tx_ctx)) % np->tx_ring_size));
 }
 
+static inline u32 nv_get_used_tx_slots(struct fe_priv *np)
+{
+	return (u32)((np->tx_ring_size + (np->put_tx_ctx - np->get_tx_ctx)) %
+		     np->tx_ring_size);
+}
+
+#define	TX_WAKE_THRESHOLD(np) ((np)->tx_ring_size / 4)
+
 /*
  * nv_start_xmit: dev->hard_start_xmit function
- * Called with netif_tx_lock held.
  */
 static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1790,7 +1802,7 @@ static int nv_start_xmit(struct sk_buff 
 	u32 bcnt;
 	u32 size = skb->len-skb->data_len;
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
-	u32 empty_slots;
+	unsigned long irq_flags;
 	struct ring_desc* put_tx;
 	struct ring_desc* start_tx;
 	struct ring_desc* prev_tx;
@@ -1802,12 +1814,22 @@ static int nv_start_xmit(struct sk_buff 
 			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
-	empty_slots = nv_get_empty_tx_slots(np);
-	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
-		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
+	local_irq_save(irq_flags);
+	if (!spin_trylock(&np->tx_lock)) {
+		/* Collision - tell upper layer to requeue */
+		local_irq_restore(irq_flags);
+		return NETDEV_TX_LOCKED;
+	}
+
+	if (unlikely(nv_get_empty_tx_slots(np) <= entries)) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR "%s: BUG! Tx Ring full when "
+			    "queue awake\n", dev->name);
+		}
+		spin_unlock_irqrestore(&np->tx_lock, irq_flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1858,6 +1880,12 @@ static int nv_start_xmit(struct sk_buff 
 		} while (size);
 	}
 
+	/*
+	 * Make put_tx_ctx visible to nx_tx_done as soon as possible,
+	 * this might avoid an unnecessary queue wakeup.
+	 */
+	smp_mb();
+
 	/* set last fragment flag  */
 	prev_tx->flaglen |= cpu_to_le32(tx_flags_extra);
 
@@ -1870,14 +1898,10 @@ static int nv_start_xmit(struct sk_buff 
 		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
-	spin_lock_irq(&np->lock);
-
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.orig = put_tx;
 
-	spin_unlock_irq(&np->lock);
-
 	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
 		dev->name, entries, tx_flags_extra);
 	{
@@ -1892,6 +1916,14 @@ static int nv_start_xmit(struct sk_buff 
 
 	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+
+	if (unlikely(nv_get_empty_tx_slots(np) <= (MAX_TX_FRAGS + 1))) {
+		netif_stop_queue(dev);
+		if (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np))
+			netif_wake_queue(dev);
+	}
+
+	spin_unlock_irqrestore(&np->tx_lock, irq_flags);
 	return NETDEV_TX_OK;
 }
 
@@ -1902,11 +1934,11 @@ static int nv_start_xmit_optimized(struc
 	u32 tx_flags_extra;
 	unsigned int fragments = skb_shinfo(skb)->nr_frags;
 	unsigned int i;
+	unsigned long irq_flags;
 	u32 offset = 0;
 	u32 bcnt;
 	u32 size = skb->len-skb->data_len;
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
-	u32 empty_slots;
 	struct ring_desc_ex* put_tx;
 	struct ring_desc_ex* start_tx;
 	struct ring_desc_ex* prev_tx;
@@ -1918,12 +1950,22 @@ static int nv_start_xmit_optimized(struc
 			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
-	empty_slots = nv_get_empty_tx_slots(np);
-	if (unlikely(empty_slots <= entries)) {
-		spin_lock_irq(&np->lock);
-		netif_stop_queue(dev);
-		np->tx_stop = 1;
-		spin_unlock_irq(&np->lock);
+	local_irq_save(irq_flags);
+	if (!spin_trylock(&np->tx_lock)) {
+		/* Collision - tell upper layer to requeue */
+		local_irq_restore(irq_flags);
+		return NETDEV_TX_LOCKED;
+	}
+
+	if (unlikely(nv_get_empty_tx_slots(np) <= entries)) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR "%s: BUG! Tx Ring full when "
+			    "queue awake\n", dev->name);
+		}
+		spin_unlock_irqrestore(&np->tx_lock, irq_flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1976,6 +2018,12 @@ static int nv_start_xmit_optimized(struc
 		} while (size);
 	}
 
+	/*
+	 * Make put_tx_ctx visible to nx_tx_done as soon as possible,
+	 * this might avoid an unnecessary queue wakeup.
+	 */
+	smp_mb();
+
 	/* set last fragment flag  */
 	prev_tx->flaglen |= cpu_to_le32(NV_TX2_LASTPACKET);
 
@@ -1998,14 +2046,10 @@ static int nv_start_xmit_optimized(struc
 			start_tx->txvlan = 0;
 	}
 
-	spin_lock_irq(&np->lock);
-
 	/* set tx flags */
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.ex = put_tx;
 
-	spin_unlock_irq(&np->lock);
-
 	dprintk(KERN_DEBUG "%s: nv_start_xmit_optimized: entries %d queued for transmission. tx_flags_extra: %x\n",
 		dev->name, entries, tx_flags_extra);
 	{
@@ -2020,6 +2064,14 @@ static int nv_start_xmit_optimized(struc
 
 	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+
+	if (unlikely(nv_get_empty_tx_slots(np) <= (MAX_TX_FRAGS + 1))) {
+		netif_stop_queue(dev);
+		if (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np))
+			netif_wake_queue(dev);
+	}
+
+	spin_unlock_irqrestore(&np->tx_lock, irq_flags);
 	return NETDEV_TX_OK;
 }
 
@@ -2032,7 +2084,6 @@ static void nv_tx_done(struct net_device
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct ring_desc* orig_get_tx = np->get_tx.orig;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID)) {
@@ -2081,9 +2132,22 @@ static void nv_tx_done(struct net_device
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
-		np->tx_stop = 0;
-		netif_wake_queue(dev);
+
+	/*
+	 * Need to make the get_tx_ctx update visible to nv_start_xmit()
+	 * before checking for netif_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that nv_start_xmit()
+	 * will miss it and cause the queue to be stopped forever.
+	 */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(dev) &&
+		     (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np)))) {
+		spin_lock(&np->tx_lock);
+		if (netif_queue_stopped(dev) &&
+		    (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np)))
+			netif_wake_queue(dev);
+		spin_unlock(&np->tx_lock);
 	}
 }
 
@@ -2091,7 +2155,6 @@ static void nv_tx_done_optimized(struct 
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID) &&
@@ -2116,15 +2179,27 @@ static void nv_tx_done_optimized(struct 
 		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
-		np->tx_stop = 0;
-		netif_wake_queue(dev);
+
+	/*
+	 * Need to make the get_tx_ctx update visible to nv_start_xmit()
+	 * before checking for netif_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that nv_start_xmit()
+	 * will miss it and cause the queue to be stopped forever.
+	 */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(dev) &&
+		     (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np)))) {
+		spin_lock(&np->tx_lock);
+		if (netif_queue_stopped(dev) &&
+		    (nv_get_empty_tx_slots(np) > TX_WAKE_THRESHOLD(np)))
+			netif_wake_queue(dev);
+		spin_unlock(&np->tx_lock);
 	}
 }
 
 /*
  * nv_tx_timeout: dev->tx_timeout function
- * Called with netif_tx_lock held.
  */
 static void nv_tx_timeout(struct net_device *dev)
 {
@@ -2186,6 +2261,7 @@ static void nv_tx_timeout(struct net_dev
 	}
 
 	spin_lock_irq(&np->lock);
+	spin_lock(&np->tx_lock);
 
 	/* 1) stop tx engine */
 	nv_stop_tx(dev);
@@ -2208,6 +2284,7 @@ static void nv_tx_timeout(struct net_dev
 
 	/* 4) restart tx engine */
 	nv_start_tx(dev);
+	spin_unlock(&np->tx_lock);
 	spin_unlock_irq(&np->lock);
 }
 
@@ -2565,8 +2642,8 @@ static int nv_change_mtu(struct net_devi
 		 * Changing the MTU is a rare event, it shouldn't matter.
 		 */
 		nv_disable_irq(dev);
-		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
+		spin_lock(&np->tx_lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
@@ -2592,8 +2669,8 @@ static int nv_change_mtu(struct net_devi
 		/* restart rx engine */
 		nv_start_rx(dev);
 		nv_start_tx(dev);
+		spin_unlock(&np->tx_lock);
 		spin_unlock(&np->lock);
-		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -2628,8 +2705,8 @@ static int nv_set_mac_address(struct net
 	memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
 
 	if (netif_running(dev)) {
-		netif_tx_lock_bh(dev);
 		spin_lock_irq(&np->lock);
+		spin_lock(&np->tx_lock);
 
 		/* stop rx engine */
 		nv_stop_rx(dev);
@@ -2639,8 +2716,8 @@ static int nv_set_mac_address(struct net
 
 		/* restart rx engine */
 		nv_start_rx(dev);
+		spin_unlock(&np->tx_lock);
 		spin_unlock_irq(&np->lock);
-		netif_tx_unlock_bh(dev);
 	} else {
 		nv_copy_mac_to_hw(dev);
 	}
@@ -2649,7 +2726,6 @@ static int nv_set_mac_address(struct net
 
 /*
  * nv_set_multicast: dev->set_multicast function
- * Called with netif_tx_lock held.
  */
 static void nv_set_multicast(struct net_device *dev)
 {
@@ -2698,6 +2774,7 @@ static void nv_set_multicast(struct net_
 	addr[0] |= NVREG_MCASTADDRA_FORCE;
 	pff |= NVREG_PFF_ALWAYS;
 	spin_lock_irq(&np->lock);
+	spin_lock(&np->tx_lock);
 	nv_stop_rx(dev);
 	writel(addr[0], base + NvRegMulticastAddrA);
 	writel(addr[1], base + NvRegMulticastAddrB);
@@ -2707,6 +2784,7 @@ static void nv_set_multicast(struct net_
 	dprintk(KERN_INFO "%s: reconfiguration for multicast lists.\n",
 		dev->name);
 	nv_start_rx(dev);
+	spin_unlock(&np->tx_lock);
 	spin_unlock_irq(&np->lock);
 }
 
@@ -3652,8 +3730,8 @@ static void nv_do_nic_poll(unsigned long
 		np->recover_error = 0;
 		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
 		if (netif_running(dev)) {
-			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
+			spin_lock(&np->tx_lock);
 			/* stop engines */
 			nv_stop_rx(dev);
 			nv_stop_tx(dev);
@@ -3679,8 +3757,8 @@ static void nv_do_nic_poll(unsigned long
 			/* restart rx engine */
 			nv_start_rx(dev);
 			nv_start_tx(dev);
+			spin_unlock(&np->tx_lock);
 			spin_unlock(&np->lock);
-			netif_tx_unlock_bh(dev);
 		}
 	}
 
@@ -3883,13 +3961,13 @@ static int nv_set_settings(struct net_de
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
+		spin_lock(&np->tx_lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
+		spin_unlock(&np->tx_lock);
 		spin_unlock(&np->lock);
-		netif_tx_unlock_bh(dev);
 	}
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
@@ -4034,13 +4112,13 @@ static int nv_nway_reset(struct net_devi
 		netif_carrier_off(dev);
 		if (netif_running(dev)) {
 			nv_disable_irq(dev);
-			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
+			spin_lock(&np->tx_lock);
 			/* stop engines */
 			nv_stop_rx(dev);
 			nv_stop_tx(dev);
+			spin_unlock(&np->tx_lock);
 			spin_unlock(&np->lock);
-			netif_tx_unlock_bh(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
 		}
 
@@ -4147,8 +4225,8 @@ static int nv_set_ringparam(struct net_d
 
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
+		spin_lock(&np->tx_lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
@@ -4197,8 +4275,8 @@ static int nv_set_ringparam(struct net_d
 		/* restart engines */
 		nv_start_rx(dev);
 		nv_start_tx(dev);
+		spin_unlock(&np->tx_lock);
 		spin_unlock(&np->lock);
-		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -4234,13 +4312,13 @@ static int nv_set_pauseparam(struct net_
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
+		spin_lock(&np->tx_lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
+		spin_unlock(&np->tx_lock);
 		spin_unlock(&np->lock);
-		netif_tx_unlock_bh(dev);
 	}
 
 	np->pause_flags &= ~(NV_PAUSEFRAME_RX_REQ|NV_PAUSEFRAME_TX_REQ);
@@ -4629,8 +4707,8 @@ static void nv_self_test(struct net_devi
 #ifdef CONFIG_FORCEDETH_NAPI
 			napi_disable(&np->napi);
 #endif
-			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
+			spin_unlock(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
 			if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 				writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
@@ -4644,8 +4722,8 @@ static void nv_self_test(struct net_devi
 			/* drain rx queue */
 			nv_drain_rx(dev);
 			nv_drain_tx(dev);
+			spin_unlock(&np->tx_lock);
 			spin_unlock_irq(&np->lock);
-			netif_tx_unlock_bh(dev);
 		}
 
 		if (!nv_register_test(dev)) {
@@ -5064,6 +5142,10 @@ static int __devinit nv_probe(struct pci
 	/* copy of driver data */
 	np->driver_data = id->driver_data;
 
+	spin_lock_init(&np->tx_lock);
+
+	dev->features |= NETIF_F_LLTX;
+
 	/* handle different descriptor versions */
 	if (id->driver_data & DEV_HAS_HIGH_DMA) {
 		/* packet format 3: supports 40-bit addressing */
