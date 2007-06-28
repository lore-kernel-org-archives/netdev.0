From: jamal <hadi@cyberus.ca>
Subject: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Wed, 27 Jun 2007 20:05:45 -0400
Message-ID: <1182989145.5155.81.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru>
	 <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <1182275300.4968.83.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mBkuRzd8b2iDN4fZ51fh"
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Michael Chan <mchan@broadcom.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:23159 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbXF1AFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 20:05:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so345916wxd
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 17:05:49 -0700 (PDT)
In-Reply-To: <1182275300.4968.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mBkuRzd8b2iDN4fZ51fh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

peoplez,

I have added support for tg3 on batching. I see equivalent performance
improvement for pktgen as i did with e1000 when using gige. 
I have only tested on two machines (one being a laptop which does
10/100Mbps). Unfortunately in both cases these are considered to be in
the class of  "buggy" tg3s (which take a longer code path).

To the tg3 folks - can you double check if am off on something?
I have split a few things that you may like as well.
I havent upgraded the tree - it is still circa 2.6.22-rc4 based; at some
point i will sync with Daves net-26

Anyone who has tg3 based hardware: I would appreciate any testing and
results ...

The git tree is at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git
but i have attached the patch in case you just wanna stare.

cheers,
jamal

--=-mBkuRzd8b2iDN4fZ51fh
Content-Disposition: attachment; filename=tg3-batchp
Content-Type: text/plain; name=tg3-batchp; charset=us-ascii
Content-Transfer-Encoding: 7bit

commit 91859b60521653a2f72ac70dfe9bfada4fdb28cb
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Wed Jun 27 19:50:35 2007 -0400

    [NET_BATCH] Add tg3 batch support
    Make tg3 use the batch api.
    
    I have tested on my old laptop and another server class
    machine; they all seem to work - unfortunately they are
    both considered old class tg3.
    
    I am sure theres improvements to be made, but this is as a
    functional good start.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2f31841..be03cbd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -581,6 +581,7 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 static inline void tg3_netif_start(struct tg3 *tp)
 {
 	netif_wake_queue(tp->dev);
+	tp->dev->xmit_win = TG3_TX_RING_SIZE >> 2;
 	/* NOTE: unconditional netif_wake_queue is only appropriate
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after tg3_init_hw)
@@ -3066,6 +3067,7 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
  */
 static void tg3_tx(struct tg3 *tp)
 {
+	int dcount;
 	u32 hw_idx = tp->hw_status->idx[0].tx_consumer;
 	u32 sw_idx = tp->tx_cons;
 
@@ -3118,12 +3120,16 @@ static void tg3_tx(struct tg3 *tp)
 	 */
 	smp_mb();
 
+	dcount = tg3_tx_avail(tp);
 	if (unlikely(netif_queue_stopped(tp->dev) &&
-		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
+		     (dcount > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
+		tp->dev->xmit_win = 1;
 		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
+		    (dcount > TG3_TX_WAKEUP_THRESH(tp))) {
 			netif_wake_queue(tp->dev);
+			tp->dev->xmit_win = dcount;
+		}
 		netif_tx_unlock(tp->dev);
 	}
 }
@@ -3877,47 +3883,56 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
-/* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLG2_HW_TSO_2 only.
- */
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
-
-	len = skb_headlen(skb);
+struct tg3_tx_cbdata {
+	u32 base_flags;
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+};
+#define TG3_SKB_CB(__skb)       ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))
+#define NETDEV_TX_DROPPED       -5
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+static int tg3_prep_bug_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
 
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
+	cb->base_flags = 0;
+	cb->mss = skb_shinfo(skb)->gso_size;
+	if (cb->mss != 0) {
+		if (skb_header_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			return NETDEV_TX_DROPPED;
 		}
-		return NETDEV_TX_BUSY;
+
+		cb->base_flags |= (TXD_FLAG_CPU_PRE_DMA |
+			       TXD_FLAG_CPU_POST_DMA);
 	}
 
-	entry = tp->tx_prod;
-	base_flags = 0;
-	mss = 0;
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		cb->base_flags |= TXD_FLAG_TCPUDP_CSUM;
+
+	return NETDEV_TX_OK;
+}
+
+static int tg3_prep_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
+
+	cb->base_flags = 0;
+	cb->mss = skb_shinfo(skb)->gso_size;
+	if (cb->mss != 0) {
 		int tcp_opt_len, ip_tcp_len;
 
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
-			goto out_unlock;
+			return NETDEV_TX_DROPPED;
 		}
 
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
+			cb->mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
 		else {
 			struct iphdr *iph = ip_hdr(skb);
 
@@ -3925,32 +3940,68 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
 			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			mss |= (ip_tcp_len + tcp_opt_len) << 9;
+			iph->tot_len = htons(cb->mss + ip_tcp_len
+					     + tcp_opt_len);
+			cb->mss |= (ip_tcp_len + tcp_opt_len) << 9;
 		}
 
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
+		cb->base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
 		tcp_hdr(skb)->check = 0;
 
 	}
 	else if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
+		cb->base_flags |= TXD_FLAG_TCPUDP_CSUM;
+
+	return NETDEV_TX_OK;
+}
+
+void tg3_kick_DMA(struct tg3 *tp)
+{
+	u32 entry = tp->tx_prod;
+	u32 count = tg3_tx_avail(tp);
+	/* Packets are ready, update Tx producer idx local and on card. */
+	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+
+	if (unlikely(count <= (MAX_SKB_FRAGS + 1))) {
+		netif_stop_queue(tp->dev);
+		tp->dev->xmit_win = 1;
+		if (count > TG3_TX_WAKEUP_THRESH(tp)) {
+			netif_wake_queue(tp->dev);
+			tp->dev->xmit_win = count;
+		}
+	}
+
+	mmiowb();
+	tp->dev->trans_start = jiffies;
+}
+
+
+static int tg3_enqueue(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	dma_addr_t mapping;
+	u32 len, entry;
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
+
+
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
+		cb->base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
 
+	entry = tp->tx_prod;
+	len = skb_headlen(skb);
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
 	tp->tx_buffers[entry].skb = skb;
 	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
+	tg3_set_txd(tp, entry, mapping, len, cb->base_flags,
+		    (skb_shinfo(skb)->nr_frags == 0) | (cb->mss << 1));
 
 	entry = NEXT_TX(entry);
 
@@ -3972,30 +4023,79 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 			tg3_set_txd(tp, entry, mapping, len,
-				    base_flags, (i == last) | (mss << 1));
+				    cb->base_flags,
+				    (i == last) | (cb->mss << 1));
 
 			entry = NEXT_TX(entry);
 		}
 	}
+  
+	tp->tx_prod = entry;
+	return NETDEV_TX_OK;
+}
 
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+/* hard_start_xmit for devices that don't have any bugs and
+ * support TG3_FLG2_HW_TSO_2 only.
+ */
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret = tg3_prep_frame(skb, dev);
 
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-			netif_wake_queue(tp->dev);
-	}
+	/* XXX: original code did mmiowb(); on failure,
+	* I dont think thats necessary
+	*/
+	if (unlikely(ret != NETDEV_TX_OK))
+	       return NETDEV_TX_OK;
+
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
 
-out_unlock:
-    	mmiowb();
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
 
-	dev->trans_start = jiffies;
+	ret = tg3_enqueue(skb, dev);
+	if (ret == NETDEV_TX_OK)
+		tg3_kick_DMA(tp);
 
-	return NETDEV_TX_OK;
+	return ret;
 }
 
+static int tg3_start_bxmit(struct net_device *dev)
+{
+	struct sk_buff *skb = NULL;
+	int didq = 0, ret = NETDEV_TX_OK;
+	struct tg3 *tp = netdev_priv(dev);
+
+	while ((skb = __skb_dequeue(dev->blist)) != NULL) {
+		if (unlikely(tg3_tx_avail(tp) <=
+			    (skb_shinfo(skb)->nr_frags + 1))) {
+			netif_stop_queue(dev);
+			__skb_queue_head(dev->blist, skb);
+			ret = NETDEV_TX_OK;
+			break;
+		}
+
+		ret = tg3_enqueue(skb, dev);
+		if (ret == NETDEV_TX_OK)
+			didq++;
+	}
+
+	if (didq)
+		tg3_kick_DMA(tp);
+
+	return ret;
+}
 static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
@@ -4008,9 +4108,11 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 	/* Estimate the number of fragments in the worst case */
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
+		tp->dev->xmit_win = 1;
 		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
 			return NETDEV_TX_BUSY;
 
+		tp->dev->xmit_win = tg3_tx_avail(tp);
 		netif_wake_queue(tp->dev);
 	}
 
@@ -4034,46 +4136,19 @@ tg3_tso_bug_end:
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
  */
-static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+static int tg3_enqueue_buggy(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
+	u32 len, entry;
 	int would_hit_hwbug;
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
 
-	len = skb_headlen(skb);
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
-		}
-		return NETDEV_TX_BUSY;
-	}
-
-	entry = tp->tx_prod;
-	base_flags = 0;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-	mss = 0;
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
+	if (cb->mss != 0) {
 		struct iphdr *iph;
 		int tcp_opt_len, ip_tcp_len, hdr_len;
 
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			goto out_unlock;
-		}
-
 		tcp_opt_len = tcp_optlen(skb);
 		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
@@ -4082,15 +4157,13 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
 			return (tg3_tso_bug(tp, skb));
 
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
 
 		iph = ip_hdr(skb);
 		iph->check = 0;
-		iph->tot_len = htons(mss + hdr_len);
+		iph->tot_len = htons(cb->mss + hdr_len);
 		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 			tcp_hdr(skb)->check = 0;
-			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
+			cb->base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
 		} else
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
 								 iph->daddr, 0,
@@ -4103,22 +4176,24 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 				int tsflags;
 
 				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
+				cb->mss |= (tsflags << 11);
 			}
 		} else {
 			if (tcp_opt_len || iph->ihl > 5) {
 				int tsflags;
 
 				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
+				cb->base_flags |= tsflags << 12;
 			}
 		}
 	}
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
+		cb->base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
+	len = skb_headlen(skb);
+	entry = tp->tx_prod;
 
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
@@ -4131,8 +4206,8 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
+	tg3_set_txd(tp, entry, mapping, len, cb->base_flags,
+		    (skb_shinfo(skb)->nr_frags == 0) | (cb->mss << 1));
 
 	entry = NEXT_TX(entry);
 
@@ -4161,10 +4236,11 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
 			if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 				tg3_set_txd(tp, entry, mapping, len,
-					    base_flags, (i == last)|(mss << 1));
+					    cb->base_flags,
+					    (i == last)|(cb->mss << 1));
 			else
 				tg3_set_txd(tp, entry, mapping, len,
-					    base_flags, (i == last));
+					    cb->base_flags, (i == last));
 
 			entry = NEXT_TX(entry);
 		}
@@ -4181,28 +4257,78 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 		 * failure, silently drop this packet.
 		 */
 		if (tigon3_dma_hwbug_workaround(tp, skb, last_plus_one,
-						&start, base_flags, mss))
-			goto out_unlock;
+						&start, cb->base_flags,
+						cb->mss)) {
+			mmiowb();
+			return NETDEV_TX_OK;
+		}
 
 		entry = start;
 	}
 
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
-
 	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-			netif_wake_queue(tp->dev);
+	return NETDEV_TX_OK;
+}
+
+static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret = tg3_prep_bug_frame(skb, dev);
+
+	if (unlikely(ret != NETDEV_TX_OK))
+	       return NETDEV_TX_OK;
+
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
 	}
 
-out_unlock:
-    	mmiowb();
+	ret = tg3_enqueue_buggy(skb, dev);
+	if (ret == NETDEV_TX_OK)
+		tg3_kick_DMA(tp);
 
-	dev->trans_start = jiffies;
+	return ret;
+}
 
-	return NETDEV_TX_OK;
+static int tg3_start_bxmit_buggy(struct net_device *dev)
+{
+	int ret = NETDEV_TX_OK, didq = 0;
+	struct sk_buff *skb = NULL;
+	struct tg3 *tp = netdev_priv(dev);
+
+	while ((skb = __skb_dequeue(dev->blist)) != NULL) {
+		/*XXX: inline this and optimize this check
+		 *eventually to not keep checking unless
+		 *necessary
+		 **/
+		if (unlikely(tg3_tx_avail(tp) <=
+			    (skb_shinfo(skb)->nr_frags + 1))) {
+			netif_stop_queue(dev);
+			__skb_queue_head(dev->blist, skb);
+			ret = NETDEV_TX_OK;
+			break;
+		}
+
+		ret = tg3_enqueue_buggy(skb, dev);
+		if (ret == NETDEV_TX_OK)
+			didq++;
+	}
+
+	if (didq)
+		tg3_kick_DMA(tp);
+
+	return ret;
 }
 
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
@@ -10978,10 +11104,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		tp->dev->hard_start_xmit = tg3_start_xmit;
-	else
+		tp->dev->hard_prep_xmit = tg3_prep_frame;
+		tp->dev->hard_batch_xmit = tg3_start_bxmit;
+	} else {
 		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
+		tp->dev->hard_prep_xmit = tg3_prep_bug_frame;
+		tp->dev->hard_batch_xmit = tg3_start_bxmit_buggy;
+	}
 
 	tp->rx_offset = 2;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
@@ -11831,6 +11962,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
+	dev->features |= NETIF_F_BTX;
+	dev->xmit_win = TG3_TX_RING_SIZE >> 2;
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tg3_poll_controller;
 #endif

--=-mBkuRzd8b2iDN4fZ51fh--

