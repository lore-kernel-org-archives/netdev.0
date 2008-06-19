From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3]: tg3: Consolidate two ->hard_start_xmit() handlers.
Date: Thu, 19 Jun 2008 04:10:16 -0700 (PDT)
Message-ID: <20080619.041016.202137414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756688AbYFSLKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 07:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tg3: Consolidate two ->hard_start_xmit() handlers.

In order to facilitate making changes to the TX handling
of this driver easier to implement, combine the two transmit
handlers.

One is for working around DMA bugs in various chip versions.
This is replaced with a feature bit, which guards the DMA
condition checks.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |  169 +++++++---------------------------------------------
 drivers/net/tg3.h |    1 +
 2 files changed, 24 insertions(+), 146 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 633c128..51b5f1c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4685,126 +4685,7 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
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
-
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
-
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			mss |= (skb_headlen(skb) - ETH_HLEN) << 9;
-		else {
-			struct iphdr *iph = ip_hdr(skb);
-
-			tcp_opt_len = tcp_optlen(skb);
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
-			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			mss |= (ip_tcp_len + tcp_opt_len) << 9;
-		}
-
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
-
-		tcp_hdr(skb)->check = 0;
-
-	}
-	else if (skb->ip_summed == CHECKSUM_PARTIAL)
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-#if TG3_VLAN_TAG_USED
-	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-#endif
-
-	/* Queue skb data, a.k.a. the main skb fragment. */
-	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-
-	tp->tx_buffers[entry].skb = skb;
-	pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
-
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
-
-	entry = NEXT_TX(entry);
-
-	/* Now loop through additional data fragments, and queue them. */
-	if (skb_shinfo(skb)->nr_frags > 0) {
-		unsigned int i, last;
-
-		last = skb_shinfo(skb)->nr_frags - 1;
-		for (i = 0; i <= last; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-			len = frag->size;
-			mapping = pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
-
-			tp->tx_buffers[entry].skb = NULL;
-			pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);
-
-			tg3_set_txd(tp, entry, mapping, len,
-				    base_flags, (i == last) | (mss << 1));
-
-			entry = NEXT_TX(entry);
-		}
-	}
-
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
-
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-			netif_wake_queue(tp->dev);
-	}
-
-out_unlock:
-    	mmiowb();
-
-	dev->trans_start = jiffies;
-
-	return NETDEV_TX_OK;
-}
-
-static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
+static int tg3_start_xmit(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
  * TSO header is greater than 80 bytes.
@@ -4830,7 +4711,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		nskb = segs;
 		segs = segs->next;
 		nskb->next = NULL;
-		tg3_start_xmit_dma_bug(nskb, tp->dev);
+		tg3_start_xmit(nskb, tp->dev);
 	} while (segs);
 
 tg3_tso_bug_end:
@@ -4839,10 +4720,7 @@ tg3_tso_bug_end:
 	return NETDEV_TX_OK;
 }
 
-/* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
- * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
- */
-static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	dma_addr_t mapping;
@@ -4935,12 +4813,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
 
@@ -4963,12 +4841,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
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
@@ -12506,15 +12384,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
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
@@ -13351,6 +13227,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	dev->open = tg3_open;
 	dev->stop = tg3_close;
+	dev->hard_start_xmit = tg3_start_xmit;
 	dev->get_stats = tg3_get_stats;
 	dev->set_multicast_list = tg3_set_rx_mode;
 	dev->set_mac_address = tg3_set_mac_addr;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index df07842..c89ca40 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2448,6 +2448,7 @@ struct tg3 {
 #define TG3_FLAG_EEPROM_WRITE_PROT	0x00001000
 #define TG3_FLAG_NVRAM			0x00002000
 #define TG3_FLAG_NVRAM_BUFFERED		0x00004000
+#define TG3_FLAG_4GB_DMA_BUG		0x00008000
 #define TG3_FLAG_PCIX_MODE		0x00020000
 #define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
 #define TG3_FLAG_PCI_32BIT		0x00080000
-- 
1.5.6.rc3.21.g8c6b5

