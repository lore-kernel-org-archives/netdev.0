From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3]: tg3: Consolidate two ->hard_start_xmit() handlers.
Date: Fri, 20 Jun 2008 16:16:46 -0700 (PDT)
Message-ID: <20080620.161646.98292699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756415AbYFTXQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tg3: Consolidate two ->hard_start_xmit() handlers.

In order to facilitate making changes to the TX handling
of this driver easier to implement, combine the two transmit
handlers.

One is for working around DMA bugs in various chip versions.
This is replaced with a feature bit, which guards the DMA
condition checks.

With help from Michael Chan:

	Different TG3 chips require slightly different ways of setting
	up the TX descriptor and different initial values for some
	IP/TCP header fields.  It is cleaner to have dedicated TSO
	setup methods for the different chips and to call the proper
	one using a function pointer.  The missing logic for
	TG3_FLG2_HW_TSO_2 has also been added.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |  295 ++++++++++++++++++++---------------------------------
 drivers/net/tg3.h |    4 +
 2 files changed, 115 insertions(+), 184 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 633c128..b94a16d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4685,164 +4685,129 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
-/* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLG2_HW_TSO_2 only.
+static int tg3_start_xmit(struct sk_buff *, struct net_device *);
+
+/* Use GSO to workaround a rare TSO bug that may be triggered when the
+ * TSO header is greater than 80 bytes.
  */
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 {
-	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
-
-	len = skb_headlen(skb);
+	struct sk_buff *segs, *nskb;
 
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+	/* Estimate the number of fragments in the worst case */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
+		netif_stop_queue(tp->dev);
+		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
+			return NETDEV_TX_BUSY;
 
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
-		}
-		return NETDEV_TX_BUSY;
+		netif_wake_queue(tp->dev);
 	}
 
-	entry = tp->tx_prod;
-	base_flags = 0;
-	mss = 0;
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
-		int tcp_opt_len, ip_tcp_len;
-
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			goto out_unlock;
-		}
+	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
+	if (IS_ERR(segs))
+		goto tg3_tso_bug_end;
 
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
-		else {
-			struct iphdr *iph = ip_hdr(skb);
+	do {
+		nskb = segs;
+		segs = segs->next;
+		nskb->next = NULL;
+		tg3_start_xmit(nskb, tp->dev);
+	} while (segs);
 
-			tcp_opt_len = tcp_optlen(skb);
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
+tg3_tso_bug_end:
+	dev_kfree_skb(skb);
 
-			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			mss |= (ip_tcp_len + tcp_opt_len) << 9;
-		}
+	return NETDEV_TX_OK;
+}
 
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
+static int tg3_setup_fw_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			    u32 *base_flags)
+{
+	int tcp_opt_len, ip_tcp_len, hdr_len;
+	struct iphdr *iph;
 
-		tcp_hdr(skb)->check = 0;
+	tcp_opt_len = tcp_optlen(skb);
+	ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
-	}
-	else if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
+	hdr_len = ip_tcp_len + tcp_opt_len;
 
-	/* Queue skb data, a.k.a. the main skb fragment. */
-	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (unlikely((ETH_HLEN + hdr_len) > 80))
+		return -E2BIG;
 
-	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
+	iph = ip_hdr(skb);
+	iph->check = 0;
+	iph->tot_len = htons(*mss + hdr_len);
 
-	entry = NEXT_TX(entry);
+	tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
+						 IPPROTO_TCP, 0);
 
-	/* Now loop through additional data fragments, and queue them. */
-	if (skb_shinfo(skb)->nr_frags > 0) {
-		unsigned int i, last;
+	if (tcp_opt_len || iph->ihl > 5) {
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+			*mss |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) << 11;
+		else
+			*base_flags |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) <<
+				       12;
+	}
 
-		last = skb_shinfo(skb)->nr_frags - 1;
-		for (i = 0; i <= last; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+	return 0;
+}
 
-			len = frag->size;
-			mapping = pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
+static int tg3_setup_hw1_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			     u32 *base_flags)
+{
+	int tcp_opt_len, ip_tcp_len, hdr_len;
+	struct iphdr *iph;
 
-			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
+	tcp_opt_len = tcp_optlen(skb);
+	ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
-			tg3_set_txd(tp, entry, mapping, len,
-				    base_flags, (i == last) | (mss << 1));
+	hdr_len = ip_tcp_len + tcp_opt_len;
 
-			entry = NEXT_TX(entry);
-		}
-	}
+	if (unlikely((ETH_HLEN + hdr_len) > 80) &&
+		     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
+		return -E2BIG;
 
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
+	*base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
 
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-			netif_wake_queue(tp->dev);
-	}
+	iph = ip_hdr(skb);
+	iph->check = 0;
+	iph->tot_len = htons(*mss + hdr_len);
 
-out_unlock:
-    	mmiowb();
+	tcp_hdr(skb)->check = 0;
 
-	dev->trans_start = jiffies;
+	if (tcp_opt_len || iph->ihl > 5)
+		*mss |= ((iph->ihl - 5) + (tcp_opt_len >> 2)) << 11;
 
-	return NETDEV_TX_OK;
+	return 0;
 }
 
-static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
-
-/* Use GSO to workaround a rare TSO bug that may be triggered when the
- * TSO header is greater than 80 bytes.
- */
-static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
+static int tg3_setup_hw2_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
+			     u32 *base_flags)
 {
-	struct sk_buff *segs, *nskb;
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		*mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
+	else {
+		int tcp_opt_len, ip_tcp_len;
+		struct iphdr *iph = ip_hdr(skb);
 
-	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
-		netif_stop_queue(tp->dev);
-		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
-			return NETDEV_TX_BUSY;
+		tcp_opt_len = tcp_optlen(skb);
+		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
 
-		netif_wake_queue(tp->dev);
+		iph->check = 0;
+		iph->tot_len = htons(*mss + ip_tcp_len + tcp_opt_len);
+		*mss |= (ip_tcp_len + tcp_opt_len) << 9;
 	}
+	*base_flags |= (TXD_FLAG_CPU_PRE_DMA | TXD_FLAG_CPU_POST_DMA);
+	*base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
 
-	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
-	if (IS_ERR(segs))
-		goto tg3_tso_bug_end;
-
-	do {
-		nskb = segs;
-		segs = segs->next;
-		nskb->next = NULL;
-		tg3_start_xmit_dma_bug(nskb, tp->dev);
-	} while (segs);
-
-tg3_tso_bug_end:
-	dev_kfree_skb(skb);
-
-	return NETDEV_TX_OK;
+	tcp_hdr(skb)->check = 0;
+	return 0;
 }
 
-/* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
- * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
- */
-static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	dma_addr_t mapping;
@@ -4873,54 +4838,14 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 	mss = 0;
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
-		struct iphdr *iph;
-		int tcp_opt_len, ip_tcp_len, hdr_len;
-
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			goto out_unlock;
 		}
 
-		tcp_opt_len = tcp_optlen(skb);
-		ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
-		hdr_len = ip_tcp_len + tcp_opt_len;
-		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
+		if (unlikely(tp->setup_tso(tp, skb, &mss, &base_flags)))
 			return (tg3_tso_bug(tp, skb));
-
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
-
-		iph = ip_hdr(skb);
-		iph->check = 0;
-		iph->tot_len = htons(mss + hdr_len);
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
-			tcp_hdr(skb)->check = 0;
-			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
-		} else
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
-
-		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)) {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				mss |= (tsflags << 11);
-			}
-		} else {
-			if (tcp_opt_len || iph->ihl > 5) {
-				int tsflags;
-
-				tsflags = (iph->ihl - 5) + (tcp_opt_len >> 2);
-				base_flags |= tsflags << 12;
-			}
-		}
 	}
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
@@ -4935,12 +4860,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
 	would_hit_hwbug = 0;
-
-	if (tp->tg3_flags3 & TG3_FLG3_5701_DMA_BUG)
-		would_hit_hwbug = 1;
-	else if (tg3_4g_overflow_test(mapping, len))
-		would_hit_hwbug = 1;
-
+	if (tp->tg3_flags & TG3_FLAG_4GB_DMA_BUG) {
+		if (tp->tg3_flags3 & TG3_FLG3_5701_DMA_BUG)
+			would_hit_hwbug = 1;
+		else if (tg3_4g_overflow_test(mapping, len))
+			would_hit_hwbug = 1;
+	}
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 
@@ -4963,12 +4888,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			tp->tx_buffers[entry].skb = NULL;
 			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
 
-			if (tg3_4g_overflow_test(mapping, len))
-				would_hit_hwbug = 1;
-
-			if (tg3_40bit_overflow_test(tp, mapping, len))
-				would_hit_hwbug = 1;
-
+			if (tp->tg3_flags & TG3_FLAG_4GB_DMA_BUG) {
+				if (tg3_4g_overflow_test(mapping, len))
+					would_hit_hwbug = 1;
+				if (tg3_40bit_overflow_test(tp, mapping, len))
+					would_hit_hwbug = 1;
+			}
 			if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 				tg3_set_txd(tp, entry, mapping, len,
 					    base_flags, (i == last)|(mss << 1));
@@ -12044,6 +11969,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
 
+	tp->setup_tso = tg3_setup_fw_tso;
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
@@ -12061,8 +11987,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
+			tp->setup_tso = tg3_setup_hw2_tso;
 		} else {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
+			tp->setup_tso = tg3_setup_hw1_tso;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
 				ASIC_REV_5750 &&
 	     		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
@@ -12506,15 +12434,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* All chips before 5787 can get confused if TX buffers
 	 * straddle the 4GB address boundary in some cases.
 	 */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->dev->hard_start_xmit = tg3_start_xmit;
-	else
-		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
+		tp->tg3_flags |= TG3_FLAG_4GB_DMA_BUG;
 
 	tp->rx_offset = 2;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
@@ -13351,6 +13277,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	dev->open = tg3_open;
 	dev->stop = tg3_close;
+	dev->hard_start_xmit = tg3_start_xmit;
 	dev->get_stats = tg3_get_stats;
 	dev->set_multicast_list = tg3_set_rx_mode;
 	dev->set_mac_address = tg3_set_mac_addr;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index df07842..9ff3ba8 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2388,6 +2388,9 @@ struct tg3 {
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
+	int				(*setup_tso) (struct tg3 *,
+						      struct sk_buff *,
+						      u32 *, u32 *);
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
@@ -2448,6 +2451,7 @@ struct tg3 {
 #define TG3_FLAG_EEPROM_WRITE_PROT	0x00001000
 #define TG3_FLAG_NVRAM			0x00002000
 #define TG3_FLAG_NVRAM_BUFFERED		0x00004000
+#define TG3_FLAG_4GB_DMA_BUG		0x00008000
 #define TG3_FLAG_PCIX_MODE		0x00020000
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000
-- 
1.5.6

