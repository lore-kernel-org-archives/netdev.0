From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 6/8][BNX2X]: Xmit rework, add TSO6 and CSUM_HW
 support
Date: Wed, 20 Feb 2008 19:34:04 +0200
Message-ID: <1203528844.8232.94.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1726 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759446AbYBTReP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:34:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: Xmit rework, add TSO6 and CSUM_HW support


Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  307 +++++++++++++++++++++++++++++++-------------------
 drivers/net/bnx2x.h |   18 +++
 2 files changed, 208 insertions(+), 117 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index d2258f5..a213d67 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -8792,9 +8792,10 @@ static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
 static int bnx2x_set_tso(struct net_device *dev, u32 data)
 {
 	if (data)
-		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6);
 	else
-		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN |
+				   NETIF_F_TSO6);
 	return 0;
 }
 
@@ -9015,7 +9016,7 @@ static struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_rx_csum    	= bnx2x_get_rx_csum,
 	.set_rx_csum    	= bnx2x_set_rx_csum,
 	.get_tx_csum    	= ethtool_op_get_tx_csum,
-	.set_tx_csum    	= ethtool_op_set_tx_csum,
+	.set_tx_csum    	= ethtool_op_set_tx_hw_csum,
 	.get_sg 		= ethtool_op_get_sg,
 	.set_sg 		= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
@@ -9197,6 +9198,96 @@ out_panic:
 
 	return work_done;
 }
+/* we split the first BD into headers and data BDs
+ * to ease the pain of our fellow micocode engineers
+ * we use one mapping for both BDs
+ * So far this has only been observed to happen
+ * in Other Operating Systems(TM)
+ */
+static u16 bnx2x_tx_split(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			  struct eth_tx_bd **tx_bd, u16 hlen, u16 bd_prod,
+			  int nbd)
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
 
 /* Called with netif_tx_lock.
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
@@ -9210,8 +9301,10 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_bd *tx_bd;
 	struct eth_tx_parse_bd *pbd = NULL;
 	u16 pkt_prod, bd_prod;
-	int nbd, fp_index = 0;
+	int nbd, fp_index;
 	dma_addr_t mapping;
+	u32 xmit_type = bnx2x_xmit_type(bp, skb);
+	int i;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -9229,20 +9322,25 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
+	   "  gso type %x  xmit_type %x\n",
+	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
+	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
+
 	/*
 	This is a bit ugly. First we use one BD which we mark as start,
 	then for TSO or xsum we have a parsing info BD,
 	and only then we have the rest of the TSO bds.
 	(don't forget to mark the last one as last,
 	and to unmap only AFTER you write to the BD ...)
+	And above all, all pdb sizes are in words - NOT DWORDS!
 	I would like to thank DovH for this mess.
 	*/
 
 	pkt_prod = fp->tx_pkt_prod++;
-	bd_prod = fp->tx_bd_prod;
-	bd_prod = TX_BD(bd_prod);
+	bd_prod = TX_BD(fp->tx_bd_prod);
 
-	/* get a tx_buff and first bd */
+	/* get a tx_buf and first BD */
 	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
 	tx_bd = &fp->tx_desc_ring[bd_prod];
 
@@ -9251,65 +9349,78 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
 	tx_bd->general_data |= 1; /* header nbd */
 
-	/* remember the first bd of the packet */
+	/* remember the first BD of the packet */
 	tx_buf->first_bd = bd_prod;
+	tx_buf->skb = skb;
 
 	DP(NETIF_MSG_TX_QUEUED,
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
 	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_bd);
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		struct iphdr *iph = ip_hdr(skb);
-		u8 len;
-
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
+		u8 len;
+
+		len = (skb_network_header(skb) - skb->data) / 2;
+
+		pbd->ip_hlen = (skb_transport_header(skb) -
+				skb_network_header(skb)) / 2;
+
+		pbd->total_hlen = cpu_to_le16(len + pbd->ip_hlen +
+					      tcp_hdrlen(skb) / 2);
 
 		/* for now NS flag is not used in Linux */
 		pbd->global_data = (len |
-				    ((skb->protocol == ETH_P_8021Q) <<
+				    ((skb->protocol == ntohs(ETH_P_8021Q)) <<
 				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
-		pbd->ip_hlen = ip_hdrlen(skb) / 2;
-		pbd->total_hlen = cpu_to_le16(len + pbd->ip_hlen);
-		if (iph->protocol == IPPROTO_TCP) {
-			struct tcphdr *th = tcp_hdr(skb);
 
+		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_TCP_CSUM;
+
+		if (xmit_type & XMIT_CSUM_V4)
 			tx_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->tcp_flags = htonl(tcp_flag_word(skb)) & 0xFFFF;
-			pbd->total_hlen += cpu_to_le16(tcp_hdrlen(skb) / 2);
-			pbd->tcp_pseudo_csum = swab16(th->check);
+						ETH_TX_BD_FLAGS_IP_CSUM;
+		else
+			tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IPV6;
 
-		} else if (iph->protocol == IPPROTO_UDP) {
-			struct udphdr *uh = udp_hdr(skb);
+		if (xmit_type & XMIT_CSUM_TCP) {
+			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
+
+		} else {
+			s8 fix = SKB_CS_OFF(skb); /* signed! */
 
-			tx_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->total_hlen += cpu_to_le16(4);
 			pbd->global_data |= ETH_TX_PARSE_BD_CS_ANY_FLG;
-			pbd->cs_offset = 5; /* 10 >> 1 */
-			pbd->tcp_pseudo_csum = 0;
-			/* HW bug: we need to subtract 10 bytes before the
-			 * UDP header from the csum
-			 */
-			uh->check = (u16) ~csum_fold(csum_sub(uh->check,
-				csum_partial(((u8 *)(uh)-10), 10, 0)));
+			pbd->cs_offset = fix / 2;
+
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
 		}
 	}
 
 	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb)) {
 		tx_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
-	} else {
+	} else
 		tx_bd->vlan = cpu_to_le16(pkt_prod);
-	}
 
 	mapping = pci_map_single(bp->pdev, skb->data,
-				 skb->len, PCI_DMA_TODEVICE);
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -9322,9 +9433,8 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, tx_bd->nbd,
 	   tx_bd->nbytes, tx_bd->bd_flags.as_bitfield, tx_bd->vlan);
 
-	if (skb_shinfo(skb)->gso_size &&
-	    (skb->len > (bp->dev->mtu + ETH_HLEN))) {
-		int hlen = 2 * le32_to_cpu(pbd->total_hlen);
+	if (xmit_type & XMIT_GSO) {
+		int hlen = 2 * le16_to_cpu(pbd->total_hlen);
 
 		DP(NETIF_MSG_TX_QUEUED,
 		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
@@ -9333,99 +9443,60 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
@@ -9441,9 +9512,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %u  bd %d\n", nbd, bd_prod);
 
-	fp->hw_tx_prods->bds_prod += cpu_to_le16(nbd);
+	fp->hw_tx_prods->bds_prod =
+		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod += cpu_to_le32(1);
+	fp->hw_tx_prods->packets_prod =
+		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
 	DOORBELL(bp, fp_index, 0);
 
 	mmiowb();
@@ -9885,11 +9958,11 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	dev->features |= NETIF_F_SG;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |= NETIF_F_HIGHDMA;
-	dev->features |= NETIF_F_IP_CSUM;
+	dev->features |= NETIF_F_HW_CSUM;
 #ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
-	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
+	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6;
 
 	rc = register_netdev(dev);
 	if (rc) {
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 0cdcb1b..f088f5f 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -869,6 +869,24 @@ struct bnx2x {
 #define PCICFG_LINK_SPEED_SHIFT		16
 
 #define BMAC_CONTROL_RX_ENABLE		2
+
+/* TX CSUM helpers */
+#define SKB_CS_OFF(skb)		(offsetof(struct tcphdr, check) - \
+				 skb->csum_offset)
+#define SKB_CS(skb)		(*(u16 *)(skb_transport_header(skb) + \
+					  skb->csum_offset))
+#define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 & 0xff)
+
+#define XMIT_PLAIN			0
+#define XMIT_CSUM_V4			0x1
+#define XMIT_CSUM_V6			0x2
+#define XMIT_CSUM_TCP			0x4
+#define XMIT_GSO_V4			0x8
+#define XMIT_GSO_V6			0x10
+
+#define XMIT_CSUM			(XMIT_CSUM_V4 | XMIT_CSUM_V6)
+#define XMIT_GSO			(XMIT_GSO_V4 | XMIT_GSO_V6)
+
 /* stuff added to make the code fit 80Col */
 
 #define TPA_TYPE_START  		ETH_FAST_PATH_RX_CQE_START_FLG
-- 
1.5.3.2




