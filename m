From: jamal <hadi@cyberus.ca>
Subject: [PATCH][TG3]Some cleanups
Date: Sun, 30 Sep 2007 14:11:30 -0400
Message-ID: <1191175890.6165.17.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-7+v2XlLicn201c2qfkaC"
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:5706 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbXI3SLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 14:11:37 -0400
Received: by an-out-0708.google.com with SMTP id d31so510765and
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2007 11:11:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7+v2XlLicn201c2qfkaC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Here are some non-batching related changes that i have in my batching
tree. Like the e1000e, they make the xmit code more readable.
I wouldnt mind if you take them over.

cheers,
jamal


--=-7+v2XlLicn201c2qfkaC
Content-Disposition: attachment; filename=tg3-p1
Content-Type: text/plain; name=tg3-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[TG3] Some cleanups
These cleanups make the xmit path code better functionally organized.
Matt Carlson contributed the moving of the VLAN formatting into
XXXX_prep_frame() portion.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 260dbcc4b0195897c539c5ff79d95afdddeb3378
tree b2047b0e474abb9f05dd40c22af7f0a86369957d
parent ad63c288ce980907f68d94d5faac08625c0b1782
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 14:01:46 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 14:01:46 -0400

 drivers/net/tg3.c |  278 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 169 insertions(+), 109 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d4ac6e9..5a864bd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3910,47 +3910,69 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
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
+#if TG3_VLAN_TAG_USED
 	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
+	u32 vlantag = 0;
 
-	len = skb_headlen(skb);
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+	cb->base_flags = vlantag;
+#endif
 
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
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
+#if TG3_VLAN_TAG_USED
+	struct tg3 *tp = netdev_priv(dev);
+	u32 vlantag = 0;
+
+	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
+		vlantag = (TXD_FLAG_VLAN | (vlan_tx_tag_get(skb) << 16));
+
+	cb->base_flags = vlantag;
+#endif
+
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
 
@@ -3958,32 +3980,58 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
+		if (tg3_tx_avail(tp) >= TG3_TX_WAKEUP_THRESH(tp))
+			netif_wake_queue(dev);
+	}
+
+	mmiowb();
+	dev->trans_start = jiffies;
+}
 
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
 
@@ -4005,28 +4053,51 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
-	}
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
 
-out_unlock:
-    	mmiowb();
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
 
-	dev->trans_start = jiffies;
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
+	}
 
-	return NETDEV_TX_OK;
+	ret = tg3_enqueue(skb, dev);
+	if (ret == NETDEV_TX_OK)
+		tg3_kick_DMA(dev);
+
+	return ret;
 }
 
 static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
@@ -4067,46 +4138,19 @@ tg3_tso_bug_end:
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
 
@@ -4115,15 +4159,13 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
@@ -4136,22 +4178,19 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
@@ -4164,8 +4203,8 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
+	tg3_set_txd(tp, entry, mapping, len, cb->base_flags,
+		    (skb_shinfo(skb)->nr_frags == 0) | (cb->mss << 1));
 
 	entry = NEXT_TX(entry);
 
@@ -4194,10 +4233,11 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
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
@@ -4214,28 +4254,48 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
-	}
+	return NETDEV_TX_OK;
+}
+
+static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int ret = tg3_prep_bug_frame(skb, dev);
 
-out_unlock:
-    	mmiowb();
+	if (unlikely(ret != NETDEV_TX_OK))
+	       return NETDEV_TX_OK;
 
-	dev->trans_start = jiffies;
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
 
-	return NETDEV_TX_OK;
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

--=-7+v2XlLicn201c2qfkaC--

