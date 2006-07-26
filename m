From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Wed, 26 Jul 2006 14:35:46 +1000
Message-ID: <20060726043546.GA3749@gondor.apana.org.au>
References: <E1G5ZBx-00084U-00@gondolin.me.apana.org.au> <44C6E39F.8010602@trash.net> <20060726034650.GA3393@gondor.apana.org.au> <44C6E924.2010902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, zdzichu@irc.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36873 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030378AbWGZEgG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 00:36:06 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44C6E924.2010902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 06:01:40AM +0200, Patrick McHardy wrote:
> 
> Please send it, I'll update my patch based on that. Thanks.

Here it is, it sits on top of

commit ca6bb5d7ab22ac79f608fe6cbc6b12de6a5a19f0
Author: David Woodhouse <dwmw2@infradead.org>
Date:   Thu Jun 22 16:07:52 2006 -0700

    [NET]: Require CAP_NET_ADMIN to create tuntap devices.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
61a015eb86469404587e910e9b852fc35ce436b8
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index fde9334..601e7ee 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1913,7 +1913,7 @@ #endif
 				skb->tail = skb->data + skb->len;
 #ifdef USE_CHECKSUM_HW
 				if (vcc->vpi == 0 && vcc->vci >= ATM_NOT_RSV_VCI) {
-					skb->ip_summed = CHECKSUM_HW;
+					skb->ip_summed = CHECKSUM_COMPLETE;
 					skb->csum = TCP_CKSUM(skb->data,
 							he_vcc->pdu_len);
 				}
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index e277789..15dcd4e 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2243,7 +2243,7 @@ boomerang_start_xmit(struct sk_buff *skb
 
 	vp->tx_ring[entry].next = 0;
 #if DO_ZEROCOPY
-	if (skb->ip_summed != CHECKSUM_HW)
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
 			vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded);
 	else
 			vp->tx_ring[entry].status = cpu_to_le32(skb->len | TxIntrUploaded | AddTCPChksum | AddUDPChksum);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index ad0c8c3..4f566d8 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -809,7 +809,7 @@ #endif
 
 		if (mss)
 			flags |= LargeSend | ((mss & MSSMask) << MSSShift);
-		else if (skb->ip_summed == CHECKSUM_HW) {
+		else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			const struct iphdr *ip = skb->nh.iph;
 			if (ip->protocol == IPPROTO_TCP)
 				flags |= IPCS | TCPCS;
@@ -863,7 +863,7 @@ #endif
 			if (mss)
 				ctrl |= LargeSend |
 					((mss & MSSMask) << MSSShift);
-			else if (skb->ip_summed == CHECKSUM_HW) {
+			else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				if (ip->protocol == IPPROTO_TCP)
 					ctrl |= IPCS | TCPCS;
 				else if (ip->protocol == IPPROTO_UDP)
@@ -894,7 +894,7 @@ #endif
 		txd->addr = cpu_to_le64(first_mapping);
 		wmb();
 
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			if (ip->protocol == IPPROTO_TCP)
 				txd->opts1 = cpu_to_le32(first_eor | first_len |
 							 FirstFrag | DescOwn |
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 23ff22b..3ab0e76 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2041,7 +2041,7 @@ static void ace_rx_int(struct net_device
 		 */
 		if (bd_flags & BD_FLG_TCP_UDP_SUM) {
 			skb->csum = htons(csum);
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 		} else {
 			skb->ip_summed = CHECKSUM_NONE;
 		}
@@ -2512,7 +2512,7 @@ restart:
 
 		mapping = ace_map_tx_skb(ap, skb, skb, idx);
 		flagsize = (skb->len << 16) | (BD_FLG_END);
-		if (skb->ip_summed == CHECKSUM_HW)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
 #if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
@@ -2535,7 +2535,7 @@ #endif
 
 		mapping = ace_map_tx_skb(ap, skb, NULL, idx);
 		flagsize = (skb_headlen(skb) << 16);
-		if (skb->ip_summed == CHECKSUM_HW)
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flagsize |= BD_FLG_TCP_UDP_SUM;
 #if ACENIC_DO_VLAN
 		if (vlan_tx_tag_present(skb)) {
@@ -2561,7 +2561,7 @@ #endif
 					       PCI_DMA_TODEVICE);
 
 			flagsize = (frag->size << 16);
-			if (skb->ip_summed == CHECKSUM_HW)
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				flagsize |= BD_FLG_TCP_UDP_SUM;
 			idx = (idx + 1) % ACE_TX_RING_ENTRIES(ap);
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7635736..f25d7e7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4419,7 +4419,7 @@ bnx2_start_xmit(struct sk_buff *skb, str
 	ring_prod = TX_RING_IDX(prod);
 
 	vlan_tag_flags = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 565a54f..c812072 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2168,7 +2168,7 @@ end_copy_pkt:
 			cas_page_unmap(addr);
 	}
 	skb->csum = ntohs(i ^ 0xffff);
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->protocol = eth_type_trans(skb, cp->dev);
 	return len;
 }
@@ -2822,7 +2822,7 @@ static inline int cas_xmit_tx_ringN(stru
 	}
 
 	ctrl = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u64 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u64) (skb->h.raw - skb->data);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 53efff6..7abbfd3 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1471,9 +1471,9 @@ #endif
 		}
 
 		if (!(adapter->flags & UDP_CSUM_CAPABLE) &&
-		    skb->ip_summed == CHECKSUM_HW &&
+		    skb->ip_summed == CHECKSUM_PARTIAL &&
 		    skb->nh.iph->protocol == IPPROTO_UDP)
-			if (unlikely(skb_checksum_help(skb, 0))) {
+			if (unlikely(skb_checksum_help(skb))) {
 				dev_kfree_skb_any(skb);
 				return NETDEV_TX_OK;
 			}
@@ -1496,11 +1496,11 @@ #endif
 		cpl = (struct cpl_tx_pkt *)__skb_push(skb, sizeof(*cpl));
 		cpl->opcode = CPL_TX_PKT;
 		cpl->ip_csum_dis = 1;    /* SW calculates IP csum */
-		cpl->l4_csum_dis = skb->ip_summed == CHECKSUM_HW ? 0 : 1;
+		cpl->l4_csum_dis = skb->ip_summed == CHECKSUM_PARTIAL ? 0 : 1;
 		/* the length field isn't used so don't bother setting it */
 
-		st->tx_cso += (skb->ip_summed == CHECKSUM_HW);
-		sge->stats.tx_do_cksum += (skb->ip_summed == CHECKSUM_HW);
+		st->tx_cso += (skb->ip_summed == CHECKSUM_PARTIAL);
+		sge->stats.tx_do_cksum += (skb->ip_summed == CHECKSUM_PARTIAL);
 		sge->stats.tx_reg_pkts++;
 	}
 	cpl->iff = dev->if_port;
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 038447f..b49665a 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -650,7 +650,7 @@ start_xmit (struct sk_buff *skb, struct 
 	txdesc = &np->tx_ring[entry];
 
 #if 0
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdesc->status |=
 		    cpu_to_le64 (TCPChecksumEnable | UDPChecksumEnable |
 				 IPChecksumEnable);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 32b7d44..39ea3ae 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2470,7 +2470,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 	unsigned int i;
 	uint8_t css;
 
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb->h.raw - skb->data;
 
 		i = tx_ring->next_to_use;
@@ -2796,11 +2796,11 @@ #ifdef NETIF_F_TSO
 	}
 
 	/* reserve a descriptor for the offload context */
-	if ((mss) || (skb->ip_summed == CHECKSUM_HW))
+	if ((mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
 		count++;
 	count++;
 #else
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		count++;
 #endif
 
@@ -3479,7 +3479,7 @@ e1000_rx_checksum(struct e1000_adapter *
 		 */
 		csum = ntohl(csum ^ 0xFFFF);
 		skb->csum = csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 	adapter->hw_csum_good++;
 }
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1218538..c78e846 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1499,7 +1499,8 @@ #ifdef NETIF_F_TSO
 		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
 	else
 #endif
-	tx_flags_extra = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
+	tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
+			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
 	if (np->vlangrp && vlan_tx_tag_present(skb)) {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 218d317..461ff61 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -948,7 +948,7 @@ static int gfar_start_xmit(struct sk_buf
 
 	/* Set up checksumming */
 	if (likely((dev->features & NETIF_F_IP_CSUM)
-			&& (CHECKSUM_HW == skb->ip_summed))) {
+			&& (CHECKSUM_PARTIAL == skb->ip_summed))) {
 		fcb = gfar_add_fcb(skb, txbdp);
 		status |= TXBD_TOE;
 		gfar_tx_checksum(skb, fcb);
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 0ea4cb4..dd3c89b 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1654,7 +1654,7 @@ #ifdef RX_CHECKSUM
 						* could do the pseudo myself and return
 						* CHECKSUM_UNNECESSARY
 						*/
-						skb->ip_summed = CHECKSUM_HW;
+						skb->ip_summed = CHECKSUM_COMPLETE;
 					}
 				}	
 			}
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 7e49522..32a38cb 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1037,7 +1037,7 @@ static inline u16 emac_tx_csum(struct oc
 			       struct sk_buff *skb)
 {
 #if defined(CONFIG_IBM_EMAC_TAH)
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		++dev->stats.tx_packets_csum;
 		return EMAC_TX_CTRL_TAH_CSUM;
 	}
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index ae71ed5..660ef42 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1388,7 +1388,7 @@ #ifdef CONFIG_SGI_IOC3_ETH_HW_TX_CSUM
 	 * MAC header which should not be summed and the TCP/UDP pseudo headers
 	 * manually.
 	 */
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		int proto = ntohs(skb->nh.iph->protocol);
 		unsigned int csoff;
 		struct iphdr *ih = skb->nh.iph;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 8bb32f9..9ff92f9 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1232,7 +1232,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 	unsigned int i;
 	uint8_t css, cso;
 
-	if(likely(skb->ip_summed == CHECKSUM_HW)) {
+	if(likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb->h.raw - skb->data;
 		cso = (skb->h.raw + skb->csum) - skb->data;
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 625ff61..137d828 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1145,7 +1145,7 @@ static void eth_tx_submit_descs_for_skb(
 	desc->byte_cnt = length;
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		BUG_ON(skb->protocol != ETH_P_IP);
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 49e1368..1de2a2f 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -935,7 +935,7 @@ static inline void myri10ge_vlan_ip_csum
 	    (vh->h_vlan_encapsulated_proto == htons(ETH_P_IP) ||
 	     vh->h_vlan_encapsulated_proto == htons(ETH_P_IPV6))) {
 		skb->csum = hw_csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 }
 
@@ -978,7 +978,7 @@ myri10ge_rx_done(struct myri10ge_priv *m
 		if ((skb->protocol == ntohs(ETH_P_IP)) ||
 		    (skb->protocol == ntohs(ETH_P_IPV6))) {
 			skb->csum = ntohs((u16) csum);
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 		} else
 			myri10ge_vlan_ip_csum(skb, ntohs((u16) csum));
 	}
@@ -1897,13 +1897,13 @@ #endif				/*NETIF_F_TSO */
 	pseudo_hdr_offset = 0;
 	odd_flag = 0;
 	flags = (MXGEFW_FLAGS_NO_TSO | MXGEFW_FLAGS_FIRST);
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		cksum_offset = (skb->h.raw - skb->data);
 		pseudo_hdr_offset = (skb->h.raw + skb->csum) - skb->data;
 		/* If the headers are excessively large, then we must
 		 * fall back to a software checksum */
 		if (unlikely(cksum_offset > 255 || pseudo_hdr_offset > 127)) {
-			if (skb_checksum_help(skb, 0))
+			if (skb_checksum_help(skb))
 				goto drop;
 			cksum_offset = 0;
 			pseudo_hdr_offset = 0;
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 706aed7..6ad8b9b 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1157,7 +1157,7 @@ again:
 	if (!nr_frags)
 		frag = NULL;
 	extsts = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		extsts |= EXTSTS_IPPKT;
 		if (IPPROTO_TCP == skb->nh.iph->protocol)
 			extsts |= EXTSTS_TCPPKT;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 12d1cb2..1512ce7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2177,7 +2177,7 @@ static inline u32 rtl8169_tso_csum(struc
 		if (mss)
 			return LargeSend | ((mss & MSSMask) << MSSShift);
 	}
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = skb->nh.iph;
 
 		if (ip->protocol == IPPROTO_TCP)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e277b0b..c131dd3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3921,7 +3921,7 @@ #ifdef NETIF_F_TSO
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(mss);
 	}
 #endif
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		txdp->Control_2 |=
 		    (TXD_TX_CKO_IPV4_EN | TXD_TX_CKO_TCP_EN |
 		     TXD_TX_CKO_UDP_EN);
diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index f3efbd1..6790d01 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -1559,7 +1559,7 @@ #endif
 	pTxd->VDataHigh = (SK_U32) (PhysAddr >> 32);
 	pTxd->pMBuf     = pMessage;
 
-	if (pMessage->ip_summed == CHECKSUM_HW) {
+	if (pMessage->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdrlen = pMessage->h.raw - pMessage->data;
 		u16 offset = hdrlen + pMessage->csum;
 
@@ -1678,7 +1678,7 @@ #endif
 	/* 
 	** Does the HW need to evaluate checksum for TCP or UDP packets? 
 	*/
-	if (pMessage->ip_summed == CHECKSUM_HW) {
+	if (pMessage->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdrlen = pMessage->h.raw - pMessage->data;
 		u16 offset = hdrlen + pMessage->csum;
 
@@ -2158,7 +2158,7 @@ #endif
 
 #ifdef USE_SK_RX_CHECKSUM
 		pMsg->csum = pRxd->TcpSums & 0xffff;
-		pMsg->ip_summed = CHECKSUM_HW;
+		pMsg->ip_summed = CHECKSUM_COMPLETE;
 #else
 		pMsg->ip_summed = CHECKSUM_NONE;
 #endif
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 19a4a16..95f0a0f 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2340,7 +2340,7 @@ static int skge_xmit_frame(struct sk_buf
 	td->dma_lo = map;
 	td->dma_hi = map >> 32;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		int offset = skb->h.raw - skb->data;
 
 		/* This seems backwards, but it is what the sk98lin
@@ -2644,7 +2644,7 @@ static inline struct sk_buff *skge_rx_ge
 	skb->dev = skge->netdev;
 	if (skge->rx_csum) {
 		skb->csum = csum;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 
 	skb->protocol = eth_type_trans(skb, skge->netdev);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d357787..d638095 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1163,7 +1163,7 @@ static unsigned tx_le_req(const struct s
 	if (skb_shinfo(skb)->gso_size)
 		++count;
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
 
 	return count;
@@ -1272,7 +1272,7 @@ #ifdef SKY2_VLAN_TAG_USED
 #endif
 
 	/* Handle TCP checksum offload */
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u16 hdr = skb->h.raw - skb->data;
 		u16 offset = hdr + skb->csum;
 
@@ -1994,7 +1994,7 @@ #ifdef SKY2_VLAN_TAG_USED
 #endif
 		case OP_RXCHKS:
 			skb = sky2->rx_ring[sky2->rx_next].skb;
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 			skb->csum = le16_to_cpu(status);
 			break;
 
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 394339d..c64a9d0 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -834,7 +834,7 @@ spider_net_set_txdescr_cmdstat(struct sp
 	/* make sure the other fields in the descriptor are written */
 	wmb();
 
-	if (skb->ip_summed != CHECKSUM_HW) {
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		descr->dmac_cmd_status = SPIDER_NET_DMAC_CMDSTAT_NOCS;
 		return;
 	}
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index c158eed..9b11a93 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1348,7 +1348,7 @@ static int start_tx(struct sk_buff *skb,
 	}
 
 #if defined(ZEROCOPY) && defined(HAS_BROKEN_FIRMWARE)
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (skb_padto(skb, (skb->len + PADDING_MASK) & ~PADDING_MASK))
 			return NETDEV_TX_OK;
 	}
@@ -1370,7 +1370,7 @@ #endif /* ZEROCOPY && HAS_BROKEN_FIRMWAR
 				status |= TxDescIntr;
 				np->reap_tx = 0;
 			}
-			if (skb->ip_summed == CHECKSUM_HW) {
+			if (skb->ip_summed == CHECKSUM_PARTIAL) {
 				status |= TxCalTCP;
 				np->stats.tx_compressed++;
 			}
@@ -1617,7 +1617,7 @@ #endif
 		 * Until then, the printk stays. :-) -Ion
 		 */
 		else if (le16_to_cpu(desc->status2) & 0x0040) {
-			skb->ip_summed = CHECKSUM_HW;
+			skb->ip_summed = CHECKSUM_COMPLETE;
 			skb->csum = le16_to_cpu(desc->csum);
 			printk(KERN_DEBUG "%s: checksum_hw, status2 = %#x\n", dev->name, le16_to_cpu(desc->status2));
 		}
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 38cd30c..3f1ae0a 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -855,7 +855,7 @@ static int gem_rx(struct gem *gp, int wo
 		}
 
 		skb->csum = ntohs((status & RXDCTRL_TCPCSUM) ^ 0xffff);
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->protocol = eth_type_trans(skb, gp->dev);
 
 		netif_receive_skb(skb);
@@ -1026,7 +1026,7 @@ static int gem_start_xmit(struct sk_buff
 	unsigned long flags;
 
 	ctrl = 0;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u64 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u64) (skb->h.raw - skb->data);
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index bd5d266..cd75b41 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1232,7 +1232,7 @@ static void happy_meal_transceiver_check
  * flags, thus:
  *
  * 	skb->csum = rxd->rx_flags & 0xffff;
- * 	skb->ip_summed = CHECKSUM_HW;
+ * 	skb->ip_summed = CHECKSUM_COMPLETE;
  *
  * before sending off the skb to the protocols, and we are good as gold.
  */
@@ -2099,7 +2099,7 @@ static void happy_meal_rx(struct happy_m
 
 		/* This card is _fucking_ hot... */
 		skb->csum = ntohs(csum ^ 0xffff);
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_COMPLETE;
 
 		RXD(("len=%d csum=%4x]", len, csum));
 		skb->protocol = eth_type_trans(skb, dev);
@@ -2293,7 +2293,7 @@ static int happy_meal_start_xmit(struct 
  	u32 tx_flags;
 
 	tx_flags = TXFLAG_OWN;
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u32 csum_start_off, csum_stuff_off;
 
 		csum_start_off = (u32) (skb->h.raw - skb->data);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e3e380f..3467f6a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3802,11 +3802,11 @@ #if TG3_TSO_SUPPORT != 0
 
 		mss |= (ip_tcp_len + tcp_opt_len) << 9;
 	}
-	else if (skb->ip_summed == CHECKSUM_HW)
+	else if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #else
 	mss = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #endif
 #if TG3_VLAN_TAG_USED
@@ -3900,7 +3900,7 @@ static int tg3_start_xmit_dma_bug(struct
 
 	entry = tp->tx_prod;
 	base_flags = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 #if TG3_TSO_SUPPORT != 0
 	mss = 0;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index e49e8b5..8d645f1 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -830,7 +830,7 @@ typhoon_start_tx(struct sk_buff *skb, st
 	first_txd->addrHi = (u64)((unsigned long) skb) >> 32;
 	first_txd->processFlags = 0;
 
-	if(skb->ip_summed == CHECKSUM_HW) {
+	if(skb->ip_summed == CHECKSUM_PARTIAL) {
 		/* The 3XP will figure out if this is UDP/TCP */
 		first_txd->processFlags |= TYPHOON_TX_PF_TCP_CHKSUM;
 		first_txd->processFlags |= TYPHOON_TX_PF_UDP_CHKSUM;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index c80a4f1..521a9d7 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1290,7 +1290,7 @@ static int rhine_start_tx(struct sk_buff
 	rp->tx_skbuff[entry] = skb;
 
 	if ((rp->quirks & rqRhineI) &&
-	    (((unsigned long)skb->data & 3) || skb_shinfo(skb)->nr_frags != 0 || skb->ip_summed == CHECKSUM_HW)) {
+	    (((unsigned long)skb->data & 3) || skb_shinfo(skb)->nr_frags != 0 || skb->ip_summed == CHECKSUM_PARTIAL)) {
 		/* Must use alignment buffer. */
 		if (skb->len > PKT_BUF_SZ) {
 			/* packet too long, drop it */
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 2eb6b5f..d2a60b4 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2000,7 +2000,7 @@ #endif
 	 *	Handle hardware checksum
 	 */
 	if ((vptr->flags & VELOCITY_FLAGS_TX_CSUM)
-				 && (skb->ip_summed == CHECKSUM_HW)) {
+				 && (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		struct iphdr *ip = skb->nh.iph;
 		if (ip->protocol == IPPROTO_TCP)
 			td_ptr->tdesc1.TCR |= TCR0_TCPCK;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bc747e5..5a8d02e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -968,7 +968,7 @@ extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern int skb_checksum_help(struct sk_buff *skb, int inward);
+extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int sg);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 16eef03..720c8b8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -34,8 +34,9 @@ #define HAVE_ALLOC_SKB		/* For the drive
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
 
 #define CHECKSUM_NONE 0
-#define CHECKSUM_HW 1
+#define CHECKSUM_PARTIAL 1
 #define CHECKSUM_UNNECESSARY 2
+#define CHECKSUM_COMPLETE 3
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
@@ -56,17 +57,17 @@ #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0,
  *	      Apparently with secret goal to sell you new device, when you
  *	      will add new protocol to your host. F.e. IPv6. 8)
  *
- *	HW: the most generic way. Device supplied checksum of _all_
+ *	COMPLETE: the most generic way. Device supplied checksum of _all_
  *	    the packet as seen by netif_rx in skb->csum.
  *	    NOTE: Even if device supports only some protocols, but
- *	    is able to produce some skb->csum, it MUST use HW,
+ *	    is able to produce some skb->csum, it MUST use COMPLETE,
  *	    not UNNECESSARY.
  *
  * B. Checksumming on output.
  *
  *	NONE: skb is checksummed by protocol or csum is not required.
  *
- *	HW: device is required to csum packet as seen by hard_start_xmit
+ *	PARTIAL: device is required to csum packet as seen by hard_start_xmit
  *	from skb->h.raw to the end and to record the checksum
  *	at skb->h.raw+skb->csum.
  *
@@ -1212,14 +1213,14 @@ static inline int skb_linearize_cow(stru
  *	@len: length of data pulled
  *
  *	After doing a pull on a received packet, you need to call this to
- *	update the CHECKSUM_HW checksum, or set ip_summed to CHECKSUM_NONE
- *	so that it can be recomputed from scratch.
+ *	update the CHECKSUM_COMPLETE checksum, or set ip_summed to
+ *	CHECKSUM_NONE so that it can be recomputed from scratch.
  */
 
 static inline void skb_postpull_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
 {
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 }
 
@@ -1238,7 +1239,7 @@ static inline int pskb_trim_rcsum(struct
 {
 	if (likely(len >= skb->len))
 		return 0;
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 	return __pskb_trim(skb, len);
 }
diff --git a/net/core/datagram.c b/net/core/datagram.c
index aecddcc..f558c61 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -417,7 +417,7 @@ unsigned int __skb_checksum_complete(str
 
 	sum = (u16)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
 	if (likely(!sum)) {
-		if (unlikely(skb->ip_summed == CHECKSUM_HW))
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
@@ -462,7 +462,7 @@ int skb_copy_and_csum_datagram_iovec(str
 			goto fault;
 		if ((unsigned short)csum_fold(csum))
 			goto csum_error;
-		if (unlikely(skb->ip_summed == CHECKSUM_HW))
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
 		iov->iov_len -= chunk;
 		iov->iov_base += chunk;
diff --git a/net/core/dev.c b/net/core/dev.c
index 9b8f0f2..5d58c11 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1158,15 +1158,13 @@ EXPORT_SYMBOL(netif_device_attach);
  * Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
  */
-int skb_checksum_help(struct sk_buff *skb, int inward)
+int skb_checksum_help(struct sk_buff *skb)
 {
 	unsigned int csum;
 	int ret = 0, offset = skb->h.raw - skb->data;
 
-	if (inward) {
-		skb->ip_summed = CHECKSUM_NONE;
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		goto out;
-	}
 
 	if (skb_cloned(skb)) {
 		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
@@ -1182,8 +1180,8 @@ int skb_checksum_help(struct sk_buff *sk
 	BUG_ON(skb->csum + 2 > offset);
 
 	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
-	skb->ip_summed = CHECKSUM_NONE;
 out:	
+	skb->ip_summed = CHECKSUM_NONE;
 	return ret;
 }
 
@@ -1201,7 +1199,7 @@ struct sk_buff *skb_gso_segment(struct s
 	int type = skb->protocol;
 
 	BUG_ON(skb_shinfo(skb)->frag_list);
-	BUG_ON(skb->ip_summed != CHECKSUM_HW);
+	BUG_ON(skb->ip_summed != CHECKSUM_PARTIAL);
 
 	skb->mac.raw = skb->data;
 	skb->mac_len = skb->nh.raw - skb->data;
@@ -1402,11 +1400,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 	/* If packet is not checksummed and device does not support
 	 * checksumming for this protocol, complete checksumming here.
 	 */
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    (!(dev->features & NETIF_F_GEN_CSUM) &&
 	     (!(dev->features & NETIF_F_IP_CSUM) ||
 	      skb->protocol != htons(ETH_P_IP))))
-	      	if (skb_checksum_help(skb, 0))
+	      	if (skb_checksum_help(skb))
 	      		goto out_kfree_skb;
 
 gso:
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 9cb7818..4e5bb84 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -109,7 +109,7 @@ static int checksum_udp(struct sk_buff *
 
 	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
 
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !(u16)csum_fold(csum_add(psum, skb->csum)))
 		return 0;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8e5044b..cc7c4cc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1328,7 +1328,7 @@ void skb_copy_and_csum_dev(const struct 
 	unsigned int csum;
 	long csstart;
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		csstart = skb->h.raw - skb->data;
 	else
 		csstart = skb_headlen(skb);
@@ -1342,7 +1342,7 @@ void skb_copy_and_csum_dev(const struct 
 		csum = skb_copy_and_csum_bits(skb, csstart, to + csstart,
 					      skb->len - csstart, 0);
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		long csstuff = csstart + skb->csum;
 
 		*((unsigned short *)(to + csstuff)) = csum_fold(csum);
@@ -1826,10 +1826,10 @@ int skb_append_datato_frags(struct sock 
  *	@len: length of data pulled
  *
  *	This function performs an skb_pull on the packet and updates
- *	update the CHECKSUM_HW checksum.  It should be used on receive
- *	path processing instead of skb_pull unless you know that the
- *	checksum difference is zero (e.g., a valid IP header) or you
- *	are setting ip_summed to CHECKSUM_NONE.
+ *	update the CHECKSUM_COMPLETE checksum.  It should be used on
+ *	receive path processing instead of skb_pull unless you know
+ *	that the checksum difference is zero (e.g., a valid IP header)
+ *	or you are setting ip_summed to CHECKSUM_NONE.
  */
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
 {
@@ -1921,7 +1921,7 @@ struct sk_buff *skb_segment(struct sk_bu
 		frag = skb_shinfo(nskb)->frags;
 		k = 0;
 
-		nskb->ip_summed = CHECKSUM_HW;
+		nskb->ip_summed = CHECKSUM_PARTIAL;
 		nskb->csum = skb->csum;
 		memcpy(skb_put(nskb, hsize), skb->data + offset, hsize);
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0179001..433fb39 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -929,7 +929,7 @@ int icmp_rcv(struct sk_buff *skb)
 	ICMP_INC_STATS_BH(ICMP_MIB_INMSGS);
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!(u16)csum_fold(skb->csum))
 			break;
 		/* fall through */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index ab680c8..403f3d8 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -932,7 +932,7 @@ int igmp_rcv(struct sk_buff *skb)
 		goto drop;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!(u16)csum_fold(skb->csum))
 			break;
 		/* fall through */
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index da734c4..13d1f28 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -666,7 +666,7 @@ static struct sk_buff *ip_frag_reasm(str
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &ip_frag_mem);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index ab99beb..eaffe4e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -577,7 +577,7 @@ static int ipgre_rcv(struct sk_buff *skb
 
 		if (flags&GRE_CSUM) {
 			switch (skb->ip_summed) {
-			case CHECKSUM_HW:
+			case CHECKSUM_COMPLETE:
 				csum = (u16)csum_fold(skb->csum);
 				if (!csum)
 					break;
@@ -585,7 +585,7 @@ static int ipgre_rcv(struct sk_buff *skb
 			case CHECKSUM_NONE:
 				skb->csum = 0;
 				csum = __skb_checksum_complete(skb);
-				skb->ip_summed = CHECKSUM_HW;
+				skb->ip_summed = CHECKSUM_COMPLETE;
 			}
 			offset += 4;
 		}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7624fd1..6433eb6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -678,7 +678,7 @@ ip_generic_getfrag(void *from, char *to,
 {
 	struct iovec *iov = from;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (memcpy_fromiovecend(to, iov, offset, len) < 0)
 			return -EFAULT;
 	} else {
@@ -734,7 +734,7 @@ static inline int ip_ufo_append_data(str
 		/* initialize protocol header pointer */
 		skb->h.raw = skb->data + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
@@ -842,7 +842,7 @@ int ip_append_data(struct sock *sk,
 	    length + fragheaderlen <= mtu &&
 	    rt->u.dst.dev->features & NETIF_F_ALL_CSUM &&
 	    !exthdrlen)
-		csummode = CHECKSUM_HW;
+		csummode = CHECKSUM_PARTIAL;
 
 	inet->cork.length += length;
 	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index bc28b11..820e831 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -151,7 +151,7 @@ tcp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -204,7 +204,7 @@ tcp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -229,7 +229,7 @@ tcp_csum_check(struct sk_buff *skb, stru
 	switch (skb->ip_summed) {
 	case CHECKSUM_NONE:
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (csum_tcpudp_magic(skb->nh.iph->saddr, skb->nh.iph->daddr,
 				      skb->len - tcphoff,
 				      skb->nh.iph->protocol, skb->csum)) {
@@ -239,7 +239,7 @@ tcp_csum_check(struct sk_buff *skb, stru
 		}
 		break;
 	default:
-		/* CHECKSUM_UNNECESSARY */
+		/* No need to checksum. */
 		break;
 	}
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 89d9175..90c8166 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -161,7 +161,7 @@ udp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -216,7 +216,7 @@ udp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_HW)
+		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
 			(*pskb)->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
@@ -250,7 +250,7 @@ udp_csum_check(struct sk_buff *skb, stru
 		case CHECKSUM_NONE:
 			skb->csum = skb_checksum(skb, udphoff,
 						 skb->len - udphoff, 0);
-		case CHECKSUM_HW:
+		case CHECKSUM_COMPLETE:
 			if (csum_tcpudp_magic(skb->nh.iph->saddr,
 					      skb->nh.iph->daddr,
 					      skb->len - udphoff,
@@ -262,7 +262,7 @@ udp_csum_check(struct sk_buff *skb, stru
 			}
 			break;
 		default:
-			/* CHECKSUM_UNNECESSARY */
+			/* No need to checksum. */
 			break;
 		}
 	}
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 6a9e34b..f88347d 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -168,7 +168,7 @@ unsigned int nf_ip_checksum(struct sk_bu
 	unsigned int csum = 0;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (hook != NF_IP_PRE_ROUTING && hook != NF_IP_LOCAL_IN)
 			break;
 		if ((protocol == 0 && !(u16)csum_fold(skb->csum)) ||
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
index c5c2ce5..c5eaa43 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -866,8 +866,7 @@ static int tcp_error(struct sk_buff *skb
   
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because it is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
 	if (ip_conntrack_checksum && hooknum == NF_IP_PRE_ROUTING &&
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
index 9b2c16b..e58e52f 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
@@ -117,8 +117,7 @@ static int udp_error(struct sk_buff *skb
 
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
 	if (ip_conntrack_checksum && hooknum == NF_IP_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, iph->ihl * 4, IPPROTO_UDP)) {
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index 67e6767..b3228df 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -112,8 +112,9 @@ ip_nat_fn(unsigned int hooknum,
 		       & htons(IP_MF|IP_OFFSET)));
 
 	/* If we had a hardware checksum before, it's now invalid */
-	if ((*pskb)->ip_summed == CHECKSUM_HW)
-		if (skb_checksum_help(*pskb, (out == NULL)))
+	if ((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	    (*pskb)->ip_summed == CHECKSUM_COMPLETE)
+		if (skb_checksum_help(*pskb))
 			return NF_DROP;
 
 	ct = ip_conntrack_get(*pskb, &ctinfo);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index b93f049..01bdf68 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -208,9 +208,9 @@ ipq_build_packet_message(struct ipq_queu
 		break;
 	
 	case IPQ_COPY_PACKET:
-		if (entry->skb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entry->skb,
-		                               entry->info->outdev == NULL))) {
+		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
+		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;
 		}
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 4adf5c9..4ec43f9 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -49,7 +49,7 @@ set_ect_ip(struct sk_buff **pskb, const 
 
 /* Return 0 if there was an error. */
 static inline int
-set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo, int inward)
+set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 {
 	struct tcphdr _tcph, *tcph;
 	u_int16_t diffs[2];
@@ -70,8 +70,9 @@ set_ect_tcp(struct sk_buff **pskb, const
 		return 0;
 	tcph = (void *)(*pskb)->nh.iph + (*pskb)->nh.iph->ihl*4;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW &&
-	    skb_checksum_help(*pskb, inward))
+	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
+	    skb_checksum_help(*pskb))
 		return 0;
 
 	diffs[0] = ((u_int16_t *)tcph)[6];
@@ -106,7 +107,7 @@ target(struct sk_buff **pskb,
 
 	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR)
 	    && (*pskb)->nh.iph->protocol == IPPROTO_TCP)
-		if (!set_ect_tcp(pskb, einfo, (out == NULL)))
+		if (!set_ect_tcp(pskb, einfo))
 			return NF_DROP;
 
 	return IPT_CONTINUE;
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMSS.c
index ef2fe5b..c998dc0 100644
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -62,8 +62,9 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	if (!skb_make_writable(pskb, (*pskb)->len))
 		return NF_DROP;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW &&
-	    skb_checksum_help(*pskb, out == NULL))
+	if (((*pskb)->ip_summed == CHECKSUM_PARTIAL ||
+	     (*pskb)->ip_summed == CHECKSUM_COMPLETE) &&
+	    skb_checksum_help(*pskb))
 		return NF_DROP;
 
 	iph = (*pskb)->nh.iph;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0e029c4..435612c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -569,7 +569,7 @@ new_segment:
 		skb->truesize += copy;
 		sk->sk_wmem_queued += copy;
 		sk->sk_forward_alloc -= copy;
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
 		skb_shinfo(skb)->gso_segs = 0;
@@ -724,7 +724,7 @@ new_segment:
 				 * Check whether we can use HW checksum.
 				 */
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
-					skb->ip_summed = CHECKSUM_HW;
+					skb->ip_summed = CHECKSUM_PARTIAL;
 
 				skb_entail(sk, tp, skb);
 				copy = size_goal;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 25ecc6e..2fc59ab 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -485,7 +485,7 @@ void tcp_v4_send_check(struct sock *sk, 
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcphdr *th = skb->h.th;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~tcp_v4_check(th, len, inet->saddr, inet->daddr, 0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
@@ -953,7 +953,7 @@ #endif
 
 static int tcp_v4_checksum_init(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!tcp_v4_check(skb->h.th, skb->len, skb->nh.iph->saddr,
 				  skb->nh.iph->daddr, skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdd71db..6303e1a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -576,7 +576,7 @@ int tcp_fragment(struct sock *sk, struct
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
 	TCP_SKB_CB(skb)->sacked &= ~TCPCB_AT_TAIL;
 
-	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_HW) {
+	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Copy and checksum data tail into the new buffer. */
 		buff->csum = csum_partial_copy_nocheck(skb->data + len, skb_put(buff, nsize),
 						       nsize, 0);
@@ -585,7 +585,7 @@ int tcp_fragment(struct sock *sk, struct
 
 		skb->csum = csum_block_sub(skb->csum, buff->csum, len);
 	} else {
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb_split(skb, buff, len);
 	}
 
@@ -688,7 +688,7 @@ int tcp_trim_head(struct sock *sk, struc
 		__pskb_trim_head(skb, len - skb_headlen(skb));
 
 	TCP_SKB_CB(skb)->seq += len;
-	skb->ip_summed = CHECKSUM_HW;
+	skb->ip_summed = CHECKSUM_PARTIAL;
 
 	skb->truesize	     -= len;
 	sk->sk_wmem_queued   -= len;
@@ -1063,7 +1063,7 @@ static int tso_fragment(struct sock *sk,
 	/* This packet was never sent out yet, so no SACK bits. */
 	TCP_SKB_CB(buff)->sacked = 0;
 
-	buff->ip_summed = skb->ip_summed = CHECKSUM_HW;
+	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
 	skb_split(skb, buff, len);
 
 	/* Fix up tso_factor for both original and new SKB.  */
@@ -1207,8 +1207,7 @@ static int tcp_mtu_probe(struct sock *sk
 	TCP_SKB_CB(nskb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
 	nskb->csum = 0;
-	if (skb->ip_summed == CHECKSUM_HW)
-		nskb->ip_summed = CHECKSUM_HW;
+	nskb->ip_summed = skb->ip_summed;
 
 	len = 0;
 	while (len < probe_size) {
@@ -1232,7 +1231,7 @@ static int tcp_mtu_probe(struct sock *sk
 			                           ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
-				if (skb->ip_summed != CHECKSUM_HW)
+				if (skb->ip_summed != CHECKSUM_PARTIAL)
 					skb->csum = csum_partial(skb->data, skb->len, 0);
 			} else {
 				__pskb_trim_head(skb, copy);
@@ -1573,10 +1572,9 @@ static void tcp_retrans_try_collapse(str
 
 		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
 
-		if (next_skb->ip_summed == CHECKSUM_HW)
-			skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = next_skb->ip_summed;
 
-		if (skb->ip_summed != CHECKSUM_HW)
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			skb->csum = csum_block_add(skb->csum, next_skb->csum, skb_size);
 
 		/* Update sequence range on original skb. */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3f93292..7cf6c84 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -430,7 +430,7 @@ static int udp_push_pending_frames(struc
 		/*
 		 * Only one fragment on the socket.
 		 */
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			skb->csum = offsetof(struct udphdr, check);
 			uh->check = ~csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst,
 					up->len, IPPROTO_UDP, 0);
@@ -449,7 +449,7 @@ static int udp_push_pending_frames(struc
 		 * fragments on the socket so that all csums of sk_buffs
 		 * should be together.
 		 */
-		if (skb->ip_summed == CHECKSUM_HW) {
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			int offset = (unsigned char *)uh - skb->data;
 			skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
 
@@ -1088,7 +1088,7 @@ static void udp_checksum_init(struct sk_
 {
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (skb->ip_summed == CHECKSUM_HW) {
+	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!udp_check(uh, ulen, saddr, daddr, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 193363e..7a4e111 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -48,8 +48,8 @@ static int xfrm4_output_one(struct sk_bu
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
-	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(skb, 0);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
 		if (err)
 			goto error_nolock;
 	}
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a18d425..e281372 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -294,7 +294,7 @@ looped_back:
 		hdr = (struct ipv6_rt_hdr *) skb2->h.raw;
 	}
 
-	if (skb->ip_summed == CHECKSUM_HW)
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 
 	i = n - --hdr->segments_left;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1044b6f..3e795c4 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -604,7 +604,7 @@ static int icmpv6_rcv(struct sk_buff **p
 
 	/* Perform checksum. */
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (!csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
 				     skb->csum))
 			break;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index abb94de..021c651 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -822,7 +822,7 @@ static inline int ip6_ufo_append_data(st
 		/* initialize protocol header pointer */
 		skb->h.raw = skb->data + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_HW;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 395a417..580b1ab 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -87,7 +87,7 @@ unsigned int nf_ip6_checksum(struct sk_b
 	unsigned int csum = 0;
 
 	switch (skb->ip_summed) {
-	case CHECKSUM_HW:
+	case CHECKSUM_COMPLETE:
 		if (hook != NF_IP6_PRE_ROUTING && hook != NF_IP6_LOCAL_IN)
 			break;
 		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index b4b7d44..403b1af 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -206,9 +206,9 @@ ipq_build_packet_message(struct ipq_queu
 		break;
 	
 	case IPQ_COPY_PACKET:
-		if (entry->skb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entry->skb,
-		                               entry->info->outdev == NULL))) {
+		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
+		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;
 		}
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c32a029..f814c20 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -409,7 +409,7 @@ static int nf_ct_frag6_queue(struct nf_c
  		return -1;
 	}
 
- 	if (skb->ip_summed == CHECKSUM_HW)
+ 	if (skb->ip_summed == CHECKSUM_COMPLETE)
  		skb->csum = csum_sub(skb->csum,
  				     csum_partial(skb->nh.raw,
 						  (u8*)(fhdr + 1) - skb->nh.raw,
@@ -641,7 +641,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &nf_ct_frag6_mem);
@@ -653,7 +653,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 	head->nh.ipv6h->payload_len = htons(payload_len);
 
 	/* Yes, and fold redundant checksum back. 8) */
-	if (head->ip_summed == CHECKSUM_HW)
+	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
 	fq->fragments = NULL;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fa1ce0a..98f79e7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -334,7 +334,7 @@ int rawv6_rcv(struct sock *sk, struct sk
 	if (!rp->checksum)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		skb_postpull_rcsum(skb, skb->nh.raw,
 		                   skb->h.raw - skb->nh.raw);
 		if (!csum_ipv6_magic(&skb->nh.ipv6h->saddr,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index eef985e..5653d1d 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -434,7 +434,7 @@ static void ip6_frag_queue(struct frag_q
  		return;
 	}
 
- 	if (skb->ip_summed == CHECKSUM_HW)
+ 	if (skb->ip_summed == CHECKSUM_COMPLETE)
  		skb->csum = csum_sub(skb->csum,
  				     csum_partial(skb->nh.raw, (u8*)(fhdr+1)-skb->nh.raw, 0));
 
@@ -648,7 +648,7 @@ static int ip6_frag_reasm(struct frag_qu
 		head->len += fp->len;
 		if (head->ip_summed != fp->ip_summed)
 			head->ip_summed = CHECKSUM_NONE;
-		else if (head->ip_summed == CHECKSUM_HW)
+		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
 		atomic_sub(fp->truesize, &ip6_frag_mem);
@@ -663,7 +663,7 @@ static int ip6_frag_reasm(struct frag_qu
 	*skb_in = head;
 
 	/* Yes, and fold redundant checksum back. 8) */
-	if (head->ip_summed == CHECKSUM_HW)
+	if (head->ip_summed == CHECKSUM_COMPLETE)
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
 	IP6_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a50eb30..5f431f6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -544,7 +544,7 @@ static void tcp_v6_send_check(struct soc
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcphdr *th = skb->h.th;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		th->check = ~csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
@@ -1011,7 +1011,7 @@ out:
 
 static int tcp_v6_checksum_init(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_HW) {
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (!tcp_v6_check(skb->h.th,skb->len,&skb->nh.ipv6h->saddr,
 				  &skb->nh.ipv6h->daddr,skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8d3432a..960d4ac 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -476,7 +476,7 @@ static int udpv6_rcv(struct sk_buff **ps
 		uh = skb->h.uh;
 	}
 
-	if (skb->ip_summed == CHECKSUM_HW &&
+	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !csum_ipv6_magic(saddr, daddr, ulen, IPPROTO_UDP, skb->csum))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 48fccb1..374b33a 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -41,8 +41,8 @@ static int xfrm6_output_one(struct sk_bu
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 	
-	if (skb->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(skb, 0);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
 		if (err)
 			goto error_nolock;
 	}
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 12fb7c0..105cb68 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -824,8 +824,7 @@ static int tcp_error(struct sk_buff *skb
   
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there 
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
 	if (nf_conntrack_checksum &&
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index ae07ebe..d36e031 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -131,8 +131,7 @@ static int udp_error(struct sk_buff *skb
 
 	/* Checksum invalid? Ignore.
 	 * We skip checking packets on the outgoing path
-	 * because the semantic of CHECKSUM_HW is different there
-	 * and moreover root might send raw packets.
+	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
 	if (nf_conntrack_checksum &&
 	    ((pf == PF_INET && hooknum == NF_IP_PRE_ROUTING) ||
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 86a4ac3..854f1a3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -377,9 +377,9 @@ #endif
 		break;
 	
 	case NFQNL_COPY_PACKET:
-		if (entskb->ip_summed == CHECKSUM_HW &&
-		    (*errp = skb_checksum_help(entskb,
-		                               outdev == NULL))) {
+		if ((entskb->ip_summed == CHECKSUM_PARTIAL ||
+		     entskb->ip_summed == CHECKSUM_COMPLETE) &&
+		    (*errp = skb_checksum_help(entskb))) {
 			spin_unlock_bh(&queue->lock);
 			return NULL;
 		}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9db7dbd..90bfeb2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -587,7 +587,7 @@ static int tpacket_rcv(struct sk_buff *s
 		else if (skb->pkt_type == PACKET_OUTGOING) {
 			/* Special case: outgoing packets have ll header at head */
 			skb_pull(skb, skb->nh.raw - skb->data);
-			if (skb->ip_summed == CHECKSUM_HW)
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				status |= TP_STATUS_CSUMNOTREADY;
 		}
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5a4a4d0..9cd5e5e 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -192,8 +192,8 @@ static int netem_enqueue(struct sk_buff 
 	 */
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC))
-		    || (skb->ip_summed == CHECKSUM_HW
-			&& skb_checksum_help(skb, 0))) {
+		    || (skb->ip_summed == CHECKSUM_PARTIAL
+			&& skb_checksum_help(skb))) {
 			sch->qstats.drops++;
 			return NET_XMIT_DROP;
 		}
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index eb330d4..6f17527 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -168,7 +168,7 @@ int csum_partial_copy_to_xdr(struct xdr_
 		return -1;
 	if ((unsigned short)csum_fold(desc.csum))
 		return -1;
-	if (unlikely(skb->ip_summed == CHECKSUM_HW))
+	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 		netdev_rx_csum_fault(skb->dev);
 	return 0;
 no_checksum:
