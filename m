From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Sun, 23 Sep 2007 15:11:52 -0400
Message-ID: <1190574713.5030.4.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost> <46F6AE18.7080708@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ewtrZ1K9CQ4mjjdR1uTD"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F6AE18.7080708@garzik.org>
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


--=-ewtrZ1K9CQ4mjjdR1uTD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2007-23-09 at 14:19 -0400, Jeff Garzik wrote:

> 
> You should post at least a couple driver patches to see how its used on 
> Real Hardware(tm)...   :)

This is the tg3 patch i used for the testing - against whats in Daves
net-2.6.24 tree. Patch may be a bit hard to read.
For an example of an LLTX version look at the e1000 in the older git
tree at:
git://git.kernel.org/pub/scm/linux/kernel/git/hadi/batch-lin26.git

If the intel folks will accept the patch i'd really like to kill 
the e1000 LLTX interface.
The tg3 in that tree used the old style batch_xmit() interface.

cheers,
jamal

--=-ewtrZ1K9CQ4mjjdR1uTD
Content-Disposition: attachment; filename=tg3.p
Content-Type: text/x-patch; name=tg3.p; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d4ac6e9..ba0b49e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3103,6 +3103,13 @@ static inline u32 tg3_tx_avail(struct tg3 *tp)
 		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
 }
 
+static inline void tg3_set_win(struct tg3 *tp)
+{
+	tp->dev->xmit_win = tg3_tx_avail(tp) - (MAX_SKB_FRAGS + 1);
+	if (tp->dev->xmit_win < 1)
+		tp->dev->xmit_win = 1;
+}
+
 /* Tigon3 never reports partial packet sends.  So we do not
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
@@ -3165,8 +3172,10 @@ static void tg3_tx(struct tg3 *tp)
 		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
+		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))) {
+			tg3_set_win(tp);
 			netif_wake_queue(tp->dev);
+		}
 		netif_tx_unlock(tp->dev);
 	}
 }
@@ -3910,47 +3919,67 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
-/* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLG2_HW_TSO_2 only.
- */
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+struct tg3_tx_cbdata {
+	u32 base_flags;
+	unsigned int mss;
+};
+#define TG3_SKB_CB(__skb)       ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))
+#define NETDEV_TX_DROPPED       -5
+
+static int tg3_prep_bug_frame(struct sk_buff *skb, struct net_device *dev)
 {
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
 	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
-
-	len = skb_headlen(skb);
+	u32 vlantag = 0;
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+#if TG3_VLAN_TAG_USED
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
+#endif
 
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
+	cb->base_flags = vlantag;
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
+	struct tg3 *tp = netdev_priv(dev);
+	u32 vlantag = 0;
+
+#if TG3_VLAN_TAG_USED
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
+#endif
+
+	cb->base_flags = vlantag;
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
 
@@ -3958,32 +3987,63 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
+		cb->base_flags |= TXD_FLAG_TCPUDP_CSUM;
+
+	return NETDEV_TX_OK;
+}
+
+void tg3_kick_DMA(struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 entry = tp->tx_prod;
+
+	/* Packets are ready, update Tx producer idx local and on card. */
+	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+
+	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
+		netif_stop_queue(dev);
+		dev->xmit_win = 1;
+		if (tg3_tx_avail(tp) >= TG3_TX_WAKEUP_THRESH(tp)) {
+			tg3_set_win(tp);
+			netif_wake_queue(dev);
+		}
+	} else {
+		tg3_set_win(tp);
+	}
 
+	mmiowb();
+	dev->trans_start = jiffies;
+}
+
+static int tg3_enqueue(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	dma_addr_t mapping;
+	u32 len, entry;
+	struct tg3_tx_cbdata *cb = TG3_SKB_CB(skb);
+
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
 
@@ -4005,28 +4065,71 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 			tg3_set_txd(tp, entry, mapping, len,
-				    base_flags, (i == last) | (mss << 1));
+				    cb->base_flags,
+				    (i == last) | (cb->mss << 1));
 
 			entry = NEXT_TX(entry);
 		}
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
+/* hard_start_xmit for devices that don't have any bugs and
+ * support TG3_FLG2_HW_TSO_2 only.
+ */
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret = tg3_prep_frame(skb, dev);
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
+			tp->dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
 	}
 
-out_unlock:
-    	mmiowb();
+	ret = tg3_enqueue(skb, dev);
+	if (ret == NETDEV_TX_OK)
+		tg3_kick_DMA(dev);
 
-	dev->trans_start = jiffies;
+	return ret;
+}
 
-	return NETDEV_TX_OK;
+static int tg3_start_bxmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
+
+	return tg3_enqueue(skb, dev);
 }
 
 static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
@@ -4041,9 +4144,11 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 	/* Estimate the number of fragments in the worst case */
 	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
+		tp->dev->xmit_win = 1;
 		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
 			return NETDEV_TX_BUSY;
 
+		tg3_set_win(tp);
 		netif_wake_queue(tp->dev);
 	}
 
@@ -4067,46 +4172,19 @@ tg3_tso_bug_end:
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
-
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
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
 
@@ -4115,15 +4193,13 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
@@ -4136,22 +4212,19 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
+	len = skb_headlen(skb);
+	entry = tp->tx_prod;
 
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
@@ -4164,8 +4237,8 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
+	tg3_set_txd(tp, entry, mapping, len, cb->base_flags,
+		    (skb_shinfo(skb)->nr_frags == 0) | (cb->mss << 1));
 
 	entry = NEXT_TX(entry);
 
@@ -4194,10 +4267,11 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
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
@@ -4214,28 +4288,68 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
+static int tg3_start_bxmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+			dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
 	}
 
-out_unlock:
-    	mmiowb();
+	return  tg3_enqueue_buggy(skb, dev);
+}
 
-	dev->trans_start = jiffies;
+static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret = tg3_prep_bug_frame(skb, dev);
 
-	return NETDEV_TX_OK;
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
+			dev->xmit_win = 1;
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
+
+	ret = tg3_enqueue_buggy(skb, dev);
+	if (ret == NETDEV_TX_OK)
+		tg3_kick_DMA(dev);
+
+	return ret;
 }
 
 static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
@@ -11039,15 +11153,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
+	tp->dev->hard_end_xmit = tg3_kick_DMA;
 	/* All chips before 5787 can get confused if TX buffers
 	 * straddle the 4GB address boundary in some cases.
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->dev->hard_start_xmit = tg3_start_xmit;
-	else
-		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		tp->dev->hard_start_xmit = tg3_start_bxmit;
+		tp->dev->hard_prep_xmit = tg3_prep_frame;
+	} else {
+		tp->dev->hard_start_xmit = tg3_start_bxmit_dma_bug;
+		tp->dev->hard_prep_xmit = tg3_prep_bug_frame;
+	}
 
 	tp->rx_offset = 2;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
@@ -11895,6 +12013,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->change_mtu = tg3_change_mtu;
 	dev->irq = pdev->irq;
+	dev->features |= NETIF_F_BTX;
+	dev->xmit_win = tp->tx_pending >> 2;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = tg3_poll_controller;
 #endif

--=-ewtrZ1K9CQ4mjjdR1uTD
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-ewtrZ1K9CQ4mjjdR1uTD--
