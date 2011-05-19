From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 01/13] tg3: Set tx bug flags for more devices
Date: Thu, 19 May 2011 15:12:44 -0700
Message-ID: <1305843176-32358-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1069 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has been recently discovered that all tg3 devices have a 4Gb boundary
DMA problem, and that all 5755 and newer devices can't handle fragments
less than or equal to 8 bytes in size.  This patch adjusts the flags and
removes tg3_start_xmit().  tg3_start_xmit_dma_bug() has been renamed to
tg3_start_xmit().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  262 +++++++----------------------------------------------
 1 files changed, 33 insertions(+), 229 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d5a1f9e..4c44168 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5735,7 +5735,28 @@ static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 #endif
 }
 
-static void tg3_set_txd(struct tg3_napi *, int, dma_addr_t, int, u32, u32);
+static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
+			dma_addr_t mapping, int len, u32 flags,
+			u32 mss_and_is_end)
+{
+	struct tg3_tx_buffer_desc *txd = &tnapi->tx_ring[entry];
+	int is_end = (mss_and_is_end & 0x1);
+	u32 mss = (mss_and_is_end >> 1);
+	u32 vlan_tag = 0;
+
+	if (is_end)
+		flags |= TXD_FLAG_END;
+	if (flags & TXD_FLAG_VLAN) {
+		vlan_tag = flags >> 16;
+		flags &= 0xffff;
+	}
+	vlan_tag |= (mss << TXD_MSS_SHIFT);
+
+	txd->addr_hi = ((u64) mapping >> 32);
+	txd->addr_lo = ((u64) mapping & 0xffffffff);
+	txd->len_flags = (len << TXD_LEN_SHIFT) | flags;
+	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
+}
 
 /* Workaround 4GB and 40-bit hardware DMA bugs. */
 static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
@@ -5818,202 +5839,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 	return ret;
 }
 
-static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
-			dma_addr_t mapping, int len, u32 flags,
-			u32 mss_and_is_end)
-{
-	struct tg3_tx_buffer_desc *txd = &tnapi->tx_ring[entry];
-	int is_end = (mss_and_is_end & 0x1);
-	u32 mss = (mss_and_is_end >> 1);
-	u32 vlan_tag = 0;
-
-	if (is_end)
-		flags |= TXD_FLAG_END;
-	if (flags & TXD_FLAG_VLAN) {
-		vlan_tag = flags >> 16;
-		flags &= 0xffff;
-	}
-	vlan_tag |= (mss << TXD_MSS_SHIFT);
-
-	txd->addr_hi = ((u64) mapping >> 32);
-	txd->addr_lo = ((u64) mapping & 0xffffffff);
-	txd->len_flags = (len << TXD_LEN_SHIFT) | flags;
-	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
-}
-
-/* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLAG_HW_TSO_2 and TG3_FLAG_HW_TSO_3 only.
- */
-static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
-				  struct net_device *dev)
-{
-	struct tg3 *tp = netdev_priv(dev);
-	u32 len, entry, base_flags, mss;
-	dma_addr_t mapping;
-	struct tg3_napi *tnapi;
-	struct netdev_queue *txq;
-	unsigned int i, last;
-
-	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
-	if (tg3_flag(tp, ENABLE_TSS))
-		tnapi++;
-
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tnapi) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_tx_queue_stopped(txq)) {
-			netif_tx_stop_queue(txq);
-
-			/* This is a hard error, log it. */
-			netdev_err(dev,
-				   "BUG! Tx Ring full when queue awake!\n");
-		}
-		return NETDEV_TX_BUSY;
-	}
-
-	entry = tnapi->tx_prod;
-	base_flags = 0;
-	mss = skb_shinfo(skb)->gso_size;
-	if (mss) {
-		int tcp_opt_len, ip_tcp_len;
-		u32 hdrlen;
-
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			goto out_unlock;
-		}
-
-		if (skb_is_gso_v6(skb)) {
-			hdrlen = skb_headlen(skb) - ETH_HLEN;
-		} else {
-			struct iphdr *iph = ip_hdr(skb);
-
-			tcp_opt_len = tcp_optlen(skb);
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
-			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			hdrlen = ip_tcp_len + tcp_opt_len;
-		}
-
-		if (tg3_flag(tp, HW_TSO_3)) {
-			mss |= (hdrlen & 0xc) << 12;
-			if (hdrlen & 0x10)
-				base_flags |= 0x00000010;
-			base_flags |= (hdrlen & 0x3e0) << 5;
-		} else
-			mss |= hdrlen << 9;
-
-		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
-			       TXD_FLAG_CPU_POST_DMA);
-
-		tcp_hdr(skb)->check = 0;
-
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-	}
-
-	if (vlan_tx_tag_present(skb))
-		base_flags |= (TXD_FLAG_VLAN |
-			       (vlan_tx_tag_get(skb) << 16));
-
-	len = skb_headlen(skb);
-
-	/* Queue skb data, a.k.a. the main skb fragment. */
-	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(tp->pdev, mapping)) {
-		dev_kfree_skb(skb);
-		goto out_unlock;
-	}
-
-	tnapi->tx_buffers[entry].skb = skb;
-	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
-
-	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
-	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
-		base_flags |= TXD_FLAG_JMB_PKT;
-
-	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
-		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
-
-	entry = NEXT_TX(entry);
-
-	/* Now loop through additional data fragments, and queue them. */
-	if (skb_shinfo(skb)->nr_frags > 0) {
-		last = skb_shinfo(skb)->nr_frags - 1;
-		for (i = 0; i <= last; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-			len = frag->size;
-			mapping = pci_map_page(tp->pdev,
-					       frag->page,
-					       frag->page_offset,
-					       len, PCI_DMA_TODEVICE);
-			if (pci_dma_mapping_error(tp->pdev, mapping))
-				goto dma_error;
-
-			tnapi->tx_buffers[entry].skb = NULL;
-			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
-					   mapping);
-
-			tg3_set_txd(tnapi, entry, mapping, len,
-				    base_flags, (i == last) | (mss << 1));
-
-			entry = NEXT_TX(entry);
-		}
-	}
-
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox(tnapi->prodmbox, entry);
-
-	tnapi->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
-		netif_tx_stop_queue(txq);
-
-		/* netif_tx_stop_queue() must be done before checking
-		 * checking tx index in tg3_tx_avail() below, because in
-		 * tg3_tx(), we update tx index before checking for
-		 * netif_tx_queue_stopped().
-		 */
-		smp_mb();
-		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
-			netif_tx_wake_queue(txq);
-	}
-
-out_unlock:
-	mmiowb();
-
-	return NETDEV_TX_OK;
-
-dma_error:
-	last = i;
-	entry = tnapi->tx_prod;
-	tnapi->tx_buffers[entry].skb = NULL;
-	pci_unmap_single(tp->pdev,
-			 dma_unmap_addr(&tnapi->tx_buffers[entry], mapping),
-			 skb_headlen(skb),
-			 PCI_DMA_TODEVICE);
-	for (i = 0; i <= last; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		entry = NEXT_TX(entry);
-
-		pci_unmap_page(tp->pdev,
-			       dma_unmap_addr(&tnapi->tx_buffers[entry],
-					      mapping),
-			       frag->size, PCI_DMA_TODEVICE);
-	}
-
-	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
-}
-
-static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *,
-					  struct net_device *);
+static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
  * TSO header is greater than 80 bytes.
@@ -6047,7 +5873,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		nskb = segs;
 		segs = segs->next;
 		nskb->next = NULL;
-		tg3_start_xmit_dma_bug(nskb, tp->dev);
+		tg3_start_xmit(nskb, tp->dev);
 	} while (segs);
 
 tg3_tso_bug_end:
@@ -6059,8 +5885,7 @@ tg3_tso_bug_end:
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
  * support TG3_FLAG_HW_TSO_1 or firmware TSO only.
  */
-static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
-					  struct net_device *dev)
+static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	u32 len, entry, base_flags, mss;
@@ -13857,14 +13682,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	/* All chips can get confused if TX buffers
+	 * straddle the 4GB address boundary.
+	 */
+	tg3_flag_set(tp, 4G_DMA_BNDRY_BUG);
+
+	if (tg3_flag(tp, 5755_PLUS))
 		tg3_flag_set(tp, SHORT_DMA_BUG);
-	else if (!tg3_flag(tp, 5755_PLUS)) {
-		tg3_flag_set(tp, 4G_DMA_BNDRY_BUG);
+	else
 		tg3_flag_set(tp, 40BIT_DMA_LIMIT_BUG);
-	}
 
 	if (tg3_flag(tp, 5717_PLUS))
 		tg3_flag_set(tp, LRG_PROD_RING_CAP);
@@ -15092,23 +14918,6 @@ static const struct net_device_ops tg3_netdev_ops = {
 #endif
 };
 
-static const struct net_device_ops tg3_netdev_ops_dma_bug = {
-	.ndo_open		= tg3_open,
-	.ndo_stop		= tg3_close,
-	.ndo_start_xmit		= tg3_start_xmit_dma_bug,
-	.ndo_get_stats64	= tg3_get_stats64,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= tg3_set_rx_mode,
-	.ndo_set_mac_address	= tg3_set_mac_addr,
-	.ndo_do_ioctl		= tg3_ioctl,
-	.ndo_tx_timeout		= tg3_tx_timeout,
-	.ndo_change_mtu		= tg3_change_mtu,
-	.ndo_set_features	= tg3_set_features,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= tg3_poll_controller,
-#endif
-};
-
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -15205,6 +15014,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
+	dev->netdev_ops = &tg3_netdev_ops;
 	dev->irq = pdev->irq;
 
 	err = tg3_get_invariants(tp);
@@ -15214,12 +15024,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if (tg3_flag(tp, 5755_PLUS) && !tg3_flag(tp, 5717_PLUS))
-		dev->netdev_ops = &tg3_netdev_ops;
-	else
-		dev->netdev_ops = &tg3_netdev_ops_dma_bug;
-
-
 	/* The EPB bridge inside 5714, 5715, and 5780 and any
 	 * device behind the EPB cannot support DMA addresses > 40-bit.
 	 * On 64-bit systems with IOMMU, use 40-bit dma_mask.
-- 
1.7.3.4


