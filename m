From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 12/15]bnx2x: Re-factor Tx code
Date: Tue, 17 Jun 2008 17:49:35 +0300
Message-ID: <1213714175.5817.182.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3020 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214AbYFQOtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:49:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for IPv6 TSO
Re-factor the Tx code with smaller functions to increase readability.
Add linearization code in case packet is too fragmented for the
microcode to handle.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  527 ++++++++++++++++++++++++++++------------------
 1 files changed, 327 insertions(+), 200 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 34f06a0..b12dbf8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1386,10 +1386,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 								len_on_bd);
 					bnx2x_tpa_stop(bp, fp, queue, pad,
 						    len, cqe, comp_ring_cons);
-				#ifdef BNX2X_STOP_ON_ERROR
+#ifdef BNX2X_STOP_ON_ERROR
 					if (bp->panic)
 						return -EINVAL;
-				#endif
+#endif
 
 					bnx2x_update_sge_prod(fp,
 							&cqe->fast_path_cqe);
@@ -4916,40 +4916,6 @@ static void enable_blocks_attention(struct bnx2x *bp)
 	REG_WR(bp, PBF_REG_PBF_INT_MASK, 0X18);		/* bit 3,4 masked */
 }
 
-#ifdef BNX2X_EXTRA_DEBUG
-static void enable_blocks_parity(struct bnx2x *bp)
-{
-	REG_WR(bp, PXP_REG_PXP_PRTY_MASK, 0x80000);	/* bit 19 masked */
-	REG_WR(bp, PXP2_REG_PXP2_PRTY_MASK_0, 0xfff40020);/* bit 5,18,20-31 */
-	REG_WR(bp, PXP2_REG_PXP2_PRTY_MASK_1, 0x20);	/* bit 5 */
-	REG_WR(bp, QM_REG_QM_PRTY_MASK, 0x0);
-	REG_WR(bp, DORQ_REG_DORQ_PRTY_MASK, 0x0);
-	REG_WR(bp, GRCBASE_UPB + PB_REG_PB_PRTY_MASK, 0x0);
-	REG_WR(bp, GRCBASE_XPB + PB_REG_PB_PRTY_MASK, 0x0);
-	REG_WR(bp, SRC_REG_SRC_PRTY_MASK, 0x4);		/* bit 2 */
-	REG_WR(bp, CDU_REG_CDU_PRTY_MASK, 0x0);
-	REG_WR(bp, CFC_REG_CFC_PRTY_MASK, 0x0);
-	REG_WR(bp, HC_REG_HC_PRTY_MASK, 0x0);
-	REG_WR(bp, MISC_REG_MISC_PRTY_MASK, 0x0);
-	REG_WR(bp, DBG_REG_DBG_PRTY_MASK, 0x0);
-	REG_WR(bp, DMAE_REG_DMAE_PRTY_MASK, 0x0);
-	REG_WR(bp, BRB1_REG_BRB1_PRTY_MASK, 0x0);
-	REG_WR(bp, PRS_REG_PRS_PRTY_MASK, 0x0);
-	REG_WR(bp, TSDM_REG_TSDM_PRTY_MASK, 0x8);	/* bit 3 */
-	REG_WR(bp, CSDM_REG_CSDM_PRTY_MASK, 0x8);	/* bit 3 */
-	REG_WR(bp, USDM_REG_USDM_PRTY_MASK, 0x28);	/* bit 3,5 */
-	REG_WR(bp, XSDM_REG_XSDM_PRTY_MASK, 0x8);	/* bit 3 */
-	REG_WR(bp, TSEM_REG_TSEM_PRTY_MASK_0, 0x0);
-	REG_WR(bp, TSEM_REG_TSEM_PRTY_MASK_1, 0x0);
-	REG_WR(bp, USEM_REG_USEM_PRTY_MASK_0, 0x0);
-	REG_WR(bp, USEM_REG_USEM_PRTY_MASK_1, 0x0);
-	REG_WR(bp, CSEM_REG_CSEM_PRTY_MASK_0, 0x0);
-	REG_WR(bp, CSEM_REG_CSEM_PRTY_MASK_1, 0x0);
-	REG_WR(bp, XSEM_REG_XSEM_PRTY_MASK_0, 0x0);
-	REG_WR(bp, XSEM_REG_XSEM_PRTY_MASK_1, 0x0);
-}
-#endif
-
 static int bnx2x_init_common(struct bnx2x *bp)
 {
 	u32 val, i;
@@ -5224,9 +5190,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
 
 	enable_blocks_attention(bp);
-#ifdef BNX2X_EXTRA_DEBUG
-	enable_blocks_parity(bp);
-#endif
 
 	if (bp->flags & TPA_ENABLE_FLAG) {
 		struct tstorm_eth_tpa_exist tmp = {0};
@@ -8152,10 +8115,13 @@ static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
 
 static int bnx2x_set_tso(struct net_device *dev, u32 data)
 {
-	if (data)
+	if (data) {
 		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
-	else
+		dev->features |= NETIF_F_TSO6;
+	} else {
 		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->features &= ~NETIF_F_TSO6;
+	}
 	return 0;
 }
 
@@ -8189,10 +8155,6 @@ static void bnx2x_self_test(struct net_device *dev,
 		buf[0] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
-
-#ifdef BNX2X_EXTRA_DEBUG
-	bnx2x_panic_dump(bp);
-#endif
 }
 
 static const struct {
@@ -8382,35 +8344,35 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 }
 
 static struct ethtool_ops bnx2x_ethtool_ops = {
-	.get_settings   	= bnx2x_get_settings,
-	.set_settings   	= bnx2x_set_settings,
-	.get_drvinfo    	= bnx2x_get_drvinfo,
+	.get_settings		= bnx2x_get_settings,
+	.set_settings		= bnx2x_set_settings,
+	.get_drvinfo		= bnx2x_get_drvinfo,
 	.get_wol		= bnx2x_get_wol,
 	.set_wol		= bnx2x_set_wol,
-	.get_msglevel   	= bnx2x_get_msglevel,
-	.set_msglevel   	= bnx2x_set_msglevel,
-	.nway_reset     	= bnx2x_nway_reset,
-	.get_link       	= ethtool_op_get_link,
-	.get_eeprom_len 	= bnx2x_get_eeprom_len,
-	.get_eeprom     	= bnx2x_get_eeprom,
-	.set_eeprom     	= bnx2x_set_eeprom,
-	.get_coalesce   	= bnx2x_get_coalesce,
-	.set_coalesce   	= bnx2x_set_coalesce,
-	.get_ringparam  	= bnx2x_get_ringparam,
-	.set_ringparam  	= bnx2x_set_ringparam,
-	.get_pauseparam 	= bnx2x_get_pauseparam,
-	.set_pauseparam 	= bnx2x_set_pauseparam,
-	.get_rx_csum    	= bnx2x_get_rx_csum,
-	.set_rx_csum    	= bnx2x_set_rx_csum,
-	.get_tx_csum    	= ethtool_op_get_tx_csum,
-	.set_tx_csum    	= ethtool_op_set_tx_csum,
-	.get_sg 		= ethtool_op_get_sg,
-	.set_sg 		= ethtool_op_set_sg,
+	.get_msglevel		= bnx2x_get_msglevel,
+	.set_msglevel		= bnx2x_set_msglevel,
+	.nway_reset		= bnx2x_nway_reset,
+	.get_link		= ethtool_op_get_link,
+	.get_eeprom_len		= bnx2x_get_eeprom_len,
+	.get_eeprom		= bnx2x_get_eeprom,
+	.set_eeprom		= bnx2x_set_eeprom,
+	.get_coalesce		= bnx2x_get_coalesce,
+	.set_coalesce		= bnx2x_set_coalesce,
+	.get_ringparam		= bnx2x_get_ringparam,
+	.set_ringparam		= bnx2x_set_ringparam,
+	.get_pauseparam		= bnx2x_get_pauseparam,
+	.set_pauseparam		= bnx2x_set_pauseparam,
+	.get_rx_csum		= bnx2x_get_rx_csum,
+	.set_rx_csum		= bnx2x_set_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_hw_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= bnx2x_set_tso,
 	.self_test_count	= bnx2x_self_test_count,
-	.self_test      	= bnx2x_self_test,
-	.get_strings    	= bnx2x_get_strings,
+	.self_test		= bnx2x_self_test,
+	.get_strings		= bnx2x_get_strings,
 	.phys_id		= bnx2x_phys_id,
 	.get_stats_count	= bnx2x_get_stats_count,
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
@@ -8506,9 +8468,181 @@ poll_panic:
 	return work_done;
 }
 
-/* Called with netif_tx_lock.
+
+/* we split the first BD into headers and data BDs
+ * to ease the pain of our fellow micocode engineers
+ * we use one mapping for both BDs
+ * So far this has only been observed to happen
+ * in Other Operating Systems(TM)
+ */
+static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
+				   struct bnx2x_fastpath *fp,
+				   struct eth_tx_bd **tx_bd, u16 hlen,
+				   u16 bd_prod, int nbd)
+{
+	struct eth_tx_bd *h_tx_bd = *tx_bd;
+	struct eth_tx_bd *d_tx_bd;
+	dma_addr_t mapping;
+	int old_len = le16_to_cpu(h_tx_bd->nbytes);
+
+	/* first fix first BD */
+	h_tx_bd->nbd = cpu_to_le16(nbd);
+	h_tx_bd->nbytes = cpu_to_le16(hlen);
+
+	DP(NETIF_MSG_TX_QUEUED,	"TSO split header size is %d "
+	   "(%x:%x) nbd %d\n", h_tx_bd->nbytes, h_tx_bd->addr_hi,
+	   h_tx_bd->addr_lo, h_tx_bd->nbd);
+
+	/* now get a new data BD
+	 * (after the pbd) and fill it */
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+	d_tx_bd = &fp->tx_desc_ring[bd_prod];
+
+	mapping = HILO_U64(le32_to_cpu(h_tx_bd->addr_hi),
+			   le32_to_cpu(h_tx_bd->addr_lo)) + hlen;
+
+	d_tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	d_tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	d_tx_bd->nbytes = cpu_to_le16(old_len - hlen);
+	d_tx_bd->vlan = 0;
+	/* this marks the BD as one that has no individual mapping
+	 * the FW ignores this flag in a BD not marked start
+	 */
+	d_tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
+	DP(NETIF_MSG_TX_QUEUED,
+	   "TSO split data size is %d (%x:%x)\n",
+	   d_tx_bd->nbytes, d_tx_bd->addr_hi, d_tx_bd->addr_lo);
+
+	/* update tx_bd for marking the last BD flag */
+	*tx_bd = d_tx_bd;
+
+	return bd_prod;
+}
+
+static inline u16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
+{
+	if (fix > 0)
+		csum = (u16) ~csum_fold(csum_sub(csum,
+				csum_partial(t_header - fix, fix, 0)));
+
+	else if (fix < 0)
+		csum = (u16) ~csum_fold(csum_add(csum,
+				csum_partial(t_header, -fix, 0)));
+
+	return swab16(csum);
+}
+
+static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
+{
+	u32 rc;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		rc = XMIT_PLAIN;
+
+	else {
+		if (skb->protocol == ntohs(ETH_P_IPV6)) {
+			rc = XMIT_CSUM_V6;
+			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+				rc |= XMIT_CSUM_TCP;
+
+		} else {
+			rc = XMIT_CSUM_V4;
+			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+				rc |= XMIT_CSUM_TCP;
+		}
+	}
+
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+		rc |= XMIT_GSO_V4;
+
+	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		rc |= XMIT_GSO_V6;
+
+	return rc;
+}
+
+/* check if packet requires linearization (packet is too is fragmented)
+*/
+static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
+			     u32 xmit_type)
+{
+	u8 to_copy = 0;
+	int hlen = 0;
+	int first_bd_sz = 0;
+
+	/* 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
+	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - 3)) {
+
+		if (xmit_type & XMIT_GSO) {
+			unsigned short lso_mss = skb_shinfo(skb)->gso_size;
+			/* Check if LSO packet needs to be copied:
+			   3 = 1 (for headers BD) + 2 (for PBD and last BD) */
+			int wnd_size = MAX_FETCH_BD - 3;
+			/* Number of widnows to check */
+			int num_wnds = skb_shinfo(skb)->nr_frags - wnd_size;
+			int wnd_idx = 0;
+			int frag_idx = 0;
+			u32 wnd_sum = 0;
+
+			/* Headers length */
+			hlen = (int)(skb_transport_header(skb) - skb->data) +
+				tcp_hdrlen(skb);
+
+			/* Amount of data (w/o headers) on linear part of SKB*/
+			first_bd_sz = skb_headlen(skb) - hlen;
+
+			wnd_sum  = first_bd_sz;
+
+			/* Calculate the first sum - it's special */
+			for (frag_idx = 0; frag_idx < wnd_size - 1; frag_idx++)
+				wnd_sum +=
+					skb_shinfo(skb)->frags[frag_idx].size;
+
+			/* If there was data on linear skb data - check it */
+			if (first_bd_sz > 0) {
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy = 1;
+					goto exit_lbl;
+				}
+
+				wnd_sum -= first_bd_sz;
+			}
+
+			/* Others are easier: run through the frag list and
+			   check all windows */
+			for (wnd_idx = 0; wnd_idx <= num_wnds; wnd_idx++) {
+				wnd_sum +=
+			  skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1].size;
+
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy = 1;
+					break;
+				}
+				wnd_sum -=
+					skb_shinfo(skb)->frags[wnd_idx].size;
+			}
+
+		} else {
+			/* in non-LSO too fragmented packet should always
+			   be linearized */
+			to_copy = 1;
+		}
+	}
+
+exit_lbl:
+	if (unlikely(to_copy))
+		DP(NETIF_MSG_TX_QUEUED,
+		   "Linearization IS REQUIRED for %s packet. "
+		   "num_frags %d  hlen %d  first_bd_sz %d\n",
+		   (xmit_type & XMIT_GSO) ? "LSO" : "non-LSO",
+		   skb_shinfo(skb)->nr_frags, hlen, first_bd_sz);
+
+	return to_copy;
+}
+
+/* called with netif_tx_lock
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
- * netif_wake_queue().
+ * netif_wake_queue()
  */
 static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -8518,17 +8652,22 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_bd *tx_bd;
 	struct eth_tx_parse_bd *pbd = NULL;
 	u16 pkt_prod, bd_prod;
-	int nbd, fp_index = 0;
+	int nbd, fp_index;
 	dma_addr_t mapping;
+	u32 xmit_type = bnx2x_xmit_type(bp, skb);
+	int vlan_off = (bp->e1hovl ? 4 : 0);
+	int i;
+	u8 hlen = 0;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return NETDEV_TX_BUSY;
 #endif
 
-	fp_index = smp_processor_id() % (bp->num_queues);
+	fp_index = (smp_processor_id() % bp->num_queues);
 
 	fp = &bp->fp[fp_index];
+
 	if (unlikely(bnx2x_tx_avail(bp->fp) <
 					(skb_shinfo(skb)->nr_frags + 3))) {
 		bp->eth_stats.driver_xoff++,
@@ -8537,20 +8676,37 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
+	   "  gso type %x  xmit_type %x\n",
+	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
+	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
+
+	/* First, check if we need to linearaize the skb
+	   (due to FW restrictions) */
+	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
+		/* Statistics of linearization */
+		bp->lin_cnt++;
+		if (skb_linearize(skb) != 0) {
+			DP(NETIF_MSG_TX_QUEUED, "SKB linearization failed - "
+			   "silently dropping this SKB\n");
+			dev_kfree_skb_any(skb);
+			return 0;
+		}
+	}
+
 	/*
-	This is a bit ugly. First we use one BD which we mark as start,
+	Please read carefully. First we use one BD which we mark as start,
 	then for TSO or xsum we have a parsing info BD,
-	and only then we have the rest of the TSO bds.
+	and only then we have the rest of the TSO BDs.
 	(don't forget to mark the last one as last,
 	and to unmap only AFTER you write to the BD ...)
-	I would like to thank DovH for this mess.
+	And above all, all pdb sizes are in words - NOT DWORDS!
 	*/
 
 	pkt_prod = fp->tx_pkt_prod++;
-	bd_prod = fp->tx_bd_prod;
-	bd_prod = TX_BD(bd_prod);
+	bd_prod = TX_BD(fp->tx_bd_prod);
 
-	/* get a tx_buff and first bd */
+	/* get a tx_buf and first BD */
 	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
 	tx_bd = &fp->tx_desc_ring[bd_prod];
 
@@ -8559,65 +8715,79 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
 	tx_bd->general_data |= 1; /* header nbd */
 
-	/* remember the first bd of the packet */
-	tx_buf->first_bd = bd_prod;
+	/* remember the first BD of the packet */
+	tx_buf->first_bd = fp->tx_bd_prod;
+	tx_buf->skb = skb;
 
 	DP(NETIF_MSG_TX_QUEUED,
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
 	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_bd);
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		struct iphdr *iph = ip_hdr(skb);
-		u8 len;
+	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb)) {
+		tx_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
+		vlan_off += 4;
+	} else
+		tx_bd->vlan = cpu_to_le16(pkt_prod);
 
-		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IP_CSUM;
+	if (xmit_type) {
 
-		/* turn on parsing and get a bd */
+		/* turn on parsing and get a BD */
 		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 		pbd = (void *)&fp->tx_desc_ring[bd_prod];
-		len = ((u8 *)iph - (u8 *)skb->data) / 2;
+
+		memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
+	}
+
+	if (xmit_type & XMIT_CSUM) {
+		hlen = (skb_network_header(skb) - skb->data + vlan_off) / 2;
 
 		/* for now NS flag is not used in Linux */
-		pbd->global_data = (len |
+		pbd->global_data = (hlen |
 				    ((skb->protocol == ntohs(ETH_P_8021Q)) <<
 				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
-		pbd->ip_hlen = ip_hdrlen(skb) / 2;
-		pbd->total_hlen = cpu_to_le16(len + pbd->ip_hlen);
-		if (iph->protocol == IPPROTO_TCP) {
-			struct tcphdr *th = tcp_hdr(skb);
 
-			tx_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->tcp_flags = pbd_tcp_flags(skb);
-			pbd->total_hlen += cpu_to_le16(tcp_hdrlen(skb) / 2);
-			pbd->tcp_pseudo_csum = swab16(th->check);
+		pbd->ip_hlen = (skb_transport_header(skb) -
+				skb_network_header(skb)) / 2;
+
+		hlen += pbd->ip_hlen + tcp_hdrlen(skb) / 2;
 
-		} else if (iph->protocol == IPPROTO_UDP) {
-			struct udphdr *uh = udp_hdr(skb);
+		pbd->total_hlen = cpu_to_le16(hlen);
+		hlen = hlen*2 - vlan_off;
 
+		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_TCP_CSUM;
+
+		if (xmit_type & XMIT_CSUM_V4)
 			tx_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->total_hlen += cpu_to_le16(4);
+						ETH_TX_BD_FLAGS_IP_CSUM;
+		else
+			tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IPV6;
+
+		if (xmit_type & XMIT_CSUM_TCP) {
+			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
+
+		} else {
+			s8 fix = SKB_CS_OFF(skb); /* signed! */
+
 			pbd->global_data |= ETH_TX_PARSE_BD_CS_ANY_FLG;
-			pbd->cs_offset = 5; /* 10 >> 1 */
-			pbd->tcp_pseudo_csum = 0;
-			/* HW bug: we need to subtract 10 bytes before the
-			 * UDP header from the csum
-			 */
-			uh->check = (u16) ~csum_fold(csum_sub(uh->check,
-				csum_partial(((u8 *)(uh)-10), 10, 0)));
-		}
-	}
+			pbd->cs_offset = fix / 2;
 
-	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb)) {
-		tx_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
-		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
-	} else {
-		tx_bd->vlan = cpu_to_le16(pkt_prod);
+			DP(NETIF_MSG_TX_QUEUED,
+			   "hlen %d  offset %d  fix %d  csum befor fix %x\n",
+			   pbd->total_hlen, pbd->cs_offset, fix, SKB_CS(skb));
+
+			/* HW bug: fixup the CSUM */
+			pbd->tcp_pseudo_csum =
+				bnx2x_csum_fix(skb_transport_header(skb),
+					       SKB_CS(skb), fix);
+
+			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
+			   pbd->tcp_pseudo_csum);
+		}
 	}
 
 	mapping = pci_map_single(bp->pdev, skb->data,
-				 skb->len, PCI_DMA_TODEVICE);
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -8626,13 +8796,12 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_bd->nbytes = cpu_to_le16(skb_headlen(skb));
 
 	DP(NETIF_MSG_TX_QUEUED, "first bd @%p  addr (%x:%x)  nbd %d"
-	   "  nbytes %d  flags %x  vlan %u\n",
-	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, tx_bd->nbd,
-	   tx_bd->nbytes, tx_bd->bd_flags.as_bitfield, tx_bd->vlan);
+	   "  nbytes %d  flags %x  vlan %x\n",
+	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, le16_to_cpu(tx_bd->nbd),
+	   le16_to_cpu(tx_bd->nbytes), tx_bd->bd_flags.as_bitfield,
+	   le16_to_cpu(tx_bd->vlan));
 
-	if (skb_shinfo(skb)->gso_size &&
-	    (skb->len > (bp->dev->mtu + ETH_HLEN))) {
-		int hlen = 2 * le16_to_cpu(pbd->total_hlen);
+	if (xmit_type & XMIT_GSO) {
 
 		DP(NETIF_MSG_TX_QUEUED,
 		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
@@ -8641,99 +8810,60 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
 
-		if (tx_bd->nbytes > cpu_to_le16(hlen)) {
-			/* we split the first bd into headers and data bds
-			 * to ease the pain of our fellow micocode engineers
-			 * we use one mapping for both bds
-			 * So far this has only been observed to happen
-			 * in Other Operating Systems(TM)
-			 */
-
-			/* first fix first bd */
-			nbd++;
-			tx_bd->nbd = cpu_to_le16(nbd);
-			tx_bd->nbytes = cpu_to_le16(hlen);
-
-			/* we only print this as an error
-			 * because we don't think this will ever happen.
-			 */
-			BNX2X_ERR("TSO split header size is %d (%x:%x)"
-				  "  nbd %d\n", tx_bd->nbytes, tx_bd->addr_hi,
-				  tx_bd->addr_lo, tx_bd->nbd);
-
-			/* now get a new data bd
-			 * (after the pbd) and fill it */
-			bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-			tx_bd = &fp->tx_desc_ring[bd_prod];
-
-			tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-			tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping) + hlen);
-			tx_bd->nbytes = cpu_to_le16(skb_headlen(skb) - hlen);
-			tx_bd->vlan = cpu_to_le16(pkt_prod);
-			/* this marks the bd
-			 * as one that has no individual mapping
-			 * the FW ignores this flag in a bd not marked start
-			 */
-			tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
-			DP(NETIF_MSG_TX_QUEUED,
-			   "TSO split data size is %d (%x:%x)\n",
-			   tx_bd->nbytes, tx_bd->addr_hi, tx_bd->addr_lo);
-		}
-
-		if (!pbd) {
-			/* supposed to be unreached
-			 * (and therefore not handled properly...)
-			 */
-			BNX2X_ERR("LSO with no PBD\n");
-			BUG();
-		}
+		if (unlikely(skb_headlen(skb) > hlen))
+			bd_prod = bnx2x_tx_split(bp, fp, &tx_bd, hlen,
+						 bd_prod, ++nbd);
 
 		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
-		pbd->ip_id = swab16(ip_hdr(skb)->id);
-		pbd->tcp_pseudo_csum =
+		pbd->tcp_flags = pbd_tcp_flags(skb);
+
+		if (xmit_type & XMIT_GSO_V4) {
+			pbd->ip_id = swab16(ip_hdr(skb)->id);
+			pbd->tcp_pseudo_csum =
 				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
 							  ip_hdr(skb)->daddr,
 							  0, IPPROTO_TCP, 0));
+
+		} else
+			pbd->tcp_pseudo_csum =
+				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+							&ipv6_hdr(skb)->daddr,
+							0, IPPROTO_TCP, 0));
+
 		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
 	}
 
-	{
-		int i;
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+		tx_bd = &fp->tx_desc_ring[bd_prod];
 
-			bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-			tx_bd = &fp->tx_desc_ring[bd_prod];
+		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
+				       frag->size, PCI_DMA_TODEVICE);
 
-			mapping = pci_map_page(bp->pdev, frag->page,
-					       frag->page_offset,
-					       frag->size, PCI_DMA_TODEVICE);
+		tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+		tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+		tx_bd->nbytes = cpu_to_le16(frag->size);
+		tx_bd->vlan = cpu_to_le16(pkt_prod);
+		tx_bd->bd_flags.as_bitfield = 0;
 
-			tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-			tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-			tx_bd->nbytes = cpu_to_le16(frag->size);
-			tx_bd->vlan = cpu_to_le16(pkt_prod);
-			tx_bd->bd_flags.as_bitfield = 0;
-			DP(NETIF_MSG_TX_QUEUED, "frag %d  bd @%p"
-			   "  addr (%x:%x)  nbytes %d  flags %x\n",
-			   i, tx_bd, tx_bd->addr_hi, tx_bd->addr_lo,
-			   tx_bd->nbytes, tx_bd->bd_flags.as_bitfield);
-		} /* for */
+		DP(NETIF_MSG_TX_QUEUED, "frag %d  bd @%p"
+		   "  addr (%x:%x)  nbytes %d  flags %x\n",
+		   i, tx_bd, tx_bd->addr_hi, tx_bd->addr_lo,
+		   tx_bd->nbytes, tx_bd->bd_flags.as_bitfield);
 	}
 
-	/* now at last mark the bd as the last bd */
+	/* now at last mark the BD as the last BD */
 	tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_END_BD;
 
 	DP(NETIF_MSG_TX_QUEUED, "last bd @%p  flags %x\n",
 	   tx_bd, tx_bd->bd_flags.as_bitfield);
 
-	tx_buf->skb = skb;
-
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
 
-	/* now send a tx doorbell, counting the next bd
+	/* now send a tx doorbell, counting the next BD
 	 * if the packet contains or ends with it
 	 */
 	if (TX_BD_POFF(bd_prod) < nbd)
@@ -8747,18 +8877,18 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
 		   pbd->tcp_send_seq, pbd->total_hlen);
 
-	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %u  bd %d\n", nbd, bd_prod);
+	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
 
 	fp->hw_tx_prods->bds_prod =
 		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, fp_index, 0);
+	DOORBELL(bp, FP_IDX(fp), 0);
 
 	mmiowb();
 
-	fp->tx_bd_prod = bd_prod;
+	fp->tx_bd_prod += nbd;
 	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
@@ -9177,10 +9307,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 #endif
 	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
-
-	bp->timer_interval = HZ;
-	bp->current_interval = (poll ? poll : HZ);
-
+	dev->features |= NETIF_F_TSO6;
 
 	return 0;
 
-- 
1.5.3.2




