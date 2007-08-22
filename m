From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 10/10 Rev4] [E1000] Implement batching
Date: Wed, 22 Aug 2007 14:01:48 +0530
Message-ID: <20070822083148.11964.50427.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:36538 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbXHVIaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:30:20 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8UKfx016163
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:30:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8UJ1B528236
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:30:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8UG4q028810
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:30:19 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

E1000: Implement batching capability (ported thanks to changes taken from
	Jamal). Not all changes are made in this as in IPoIB, eg, handling
	out of order skbs (see XXX in the first mail).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 e1000_main.c |  150 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 121 insertions(+), 29 deletions(-)

diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
--- org/drivers/net/e1000/e1000_main.c	2007-08-20 14:26:29.000000000 +0530
+++ new/drivers/net/e1000/e1000_main.c	2007-08-22 08:33:51.000000000 +0530
@@ -157,6 +157,7 @@ static void e1000_update_phy_info(unsign
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+static int e1000_xmit_frames(struct net_device *dev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
@@ -990,7 +991,7 @@ e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_LLTX;
+	netdev->features |= NETIF_F_LLTX | NETIF_F_BATCH_SKBS;
 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
@@ -3098,6 +3099,18 @@ e1000_tx_map(struct e1000_adapter *adapt
 	return count;
 }
 
+static void e1000_kick_DMA(struct e1000_adapter *adapter,
+			   struct e1000_tx_ring *tx_ring, int i)
+{
+	wmb();
+
+	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
+	/* we need this if more than one processor can write to our tail
+	 * at a time, it syncronizes IO on IA64/Altix systems */
+	mmiowb();
+}
+
+
 static void
 e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
                int tx_flags, int count)
@@ -3144,13 +3157,7 @@ e1000_tx_queue(struct e1000_adapter *ada
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
 	 * such as IA-64). */
-	wmb();
-
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it syncronizes IO on IA64/Altix systems */
-	mmiowb();
 }
 
 /**
@@ -3257,21 +3264,31 @@ static int e1000_maybe_stop_tx(struct ne
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
+
+struct e1000_tx_cbdata {
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+};
+
+#define E1000_SKB_CB(__skb)	((struct e1000_tx_cbdata *)&((__skb)->cb[0]))
+#define NETDEV_TX_DROPPED	-5
+
 static int
-e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+e1000_prep_queue_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_tx_ring *tx_ring;
-	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
+	unsigned int max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
-	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
-	int tso;
 	unsigned int f;
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
+
 	len -= skb->data_len;
 
 	/* This goes back to the question of how to logically map a tx queue
@@ -3282,7 +3299,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
 	/* 82571 and newer doesn't need the workaround that limited descriptor
@@ -3328,7 +3345,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 					DPRINTK(DRV, ERR,
 						"__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
-					return NETDEV_TX_OK;
+					return NETDEV_TX_DROPPED;
 				}
 				len = skb->len - skb->data_len;
 				break;
@@ -3372,22 +3389,32 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
+	cb->count = count;
+	cb->max_per_txd = max_per_txd;
+	cb->nr_frags = nr_frags;
+	cb->mss = mss;
+
+	return NETDEV_TX_OK;
+}
+
+static int e1000_queue_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	int tso;
+	unsigned int first;
+	unsigned int tx_flags = 0;
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, cb->count + 2)))
 		return NETDEV_TX_BUSY;
-	}
 
 	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
-			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -3402,8 +3429,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	tso = e1000_tso(adapter, tx_ring, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
 	if (likely(tso)) {
@@ -3420,12 +3446,78 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	e1000_tx_queue(adapter, tx_ring, tx_flags,
 	               e1000_tx_map(adapter, tx_ring, skb, first,
-	                            max_per_txd, nr_frags, mss));
+	                            cb->max_per_txd, cb->nr_frags, cb->mss));
+
+	return NETDEV_TX_OK;
+}
 
-	netdev->trans_start = jiffies;
+static inline int e1000_xmit_frames(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	int ret = NETDEV_TX_OK;
+	int skbs_done = 0;
+	struct sk_buff *skb;
+	unsigned long flags;
+
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
 
-	/* Make sure there is space in the ring for the next send. */
-	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+	while ((skb = __skb_dequeue(netdev->skb_blist)) != NULL) {
+		if ((ret = e1000_prep_queue_frame(skb, netdev)) != NETDEV_TX_OK)
+			continue;
+
+		ret = e1000_queue_frame(skb, netdev);
+		if (ret == NETDEV_TX_OK) {
+			skbs_done++;
+		} else {
+			if (ret == NETDEV_TX_BUSY)
+				__skb_queue_head(netdev->skb_blist, skb);
+			break;
+		}
+	}
+
+	if (skbs_done) {
+		e1000_kick_DMA(adapter, tx_ring, adapter->tx_ring->next_to_use);
+		netdev->trans_start = jiffies;
+		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+	}
+
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
+	if (ret == NETDEV_TX_DROPPED)
+		ret = NETDEV_TX_OK;
+
+	return ret;
+}
+
+static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+	unsigned long flags;
+
+	if (!skb)
+		return e1000_xmit_frames(netdev);
+
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
+
+	if (unlikely(e1000_prep_queue_frame(skb, netdev) != NETDEV_TX_OK)) {
+		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+		return NETDEV_TX_OK;
+	}
+
+	if (e1000_queue_frame(skb, netdev) == NETDEV_TX_OK) {
+		e1000_kick_DMA(adapter, tx_ring, adapter->tx_ring->next_to_use);
+		netdev->trans_start = jiffies;
+		/* Make sure there is space in the ring for the next send. */
+		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+	}
 
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
