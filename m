From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 7/12]bnx2x: Re-factor Tx code
Date: Tue, 27 May 2008 10:17:34 -0400
Message-ID: <1211897854.6967.80.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3397 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756028AbYE0ORw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Re-factor Tx code
=EF=BB=BF
Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  527 ++++++++++++++++++++++++++++----------=
--------
 1 files changed, 327 insertions(+), 200 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 366764e..b92cef1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1385,10 +1385,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *=
fp, int budget)
 								len_on_bd);
 					bnx2x_tpa_stop(bp, fp, queue, pad,
 						    len, cqe, comp_ring_cons);
-				#ifdef BNX2X_STOP_ON_ERROR
+#ifdef BNX2X_STOP_ON_ERROR
 					if (bp->panic)
 						return -EINVAL;
-				#endif
+#endif
=20
 					bnx2x_update_sge_prod(fp,
 							&cqe->fast_path_cqe);
@@ -4915,40 +4915,6 @@ static void enable_blocks_attention(struct bnx2x=
 *bp)
 	REG_WR(bp, PBF_REG_PBF_INT_MASK, 0X18);		/* bit 3,4 masked */
 }
=20
-#ifdef BNX2X_EXTRA_DEBUG
-static void enable_blocks_parity(struct bnx2x *bp)
-{
-	REG_WR(bp, PXP_REG_PXP_PRTY_MASK, 0x80000);	/* bit 19 masked */
-	REG_WR(bp, PXP2_REG_PXP2_PRTY_MASK_0, 0xfff40020);/* bit 5,18,20-31 *=
/
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
@@ -5223,9 +5189,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
=20
 	enable_blocks_attention(bp);
-#ifdef BNX2X_EXTRA_DEBUG
-	enable_blocks_parity(bp);
-#endif
=20
 	if (bp->flags & TPA_ENABLE_FLAG) {
 		struct tstorm_eth_tpa_exist tmp =3D {0};
@@ -8151,10 +8114,13 @@ static int bnx2x_set_rx_csum(struct net_device =
*dev, u32 data)
=20
 static int bnx2x_set_tso(struct net_device *dev, u32 data)
 {
-	if (data)
+	if (data) {
 		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-	else
+		dev->features |=3D NETIF_F_TSO6;
+	} else {
 		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
+		dev->features &=3D ~NETIF_F_TSO6;
+	}
 	return 0;
 }
=20
@@ -8188,10 +8154,6 @@ static void bnx2x_self_test(struct net_device *d=
ev,
 		buf[0] =3D 1;
 		etest->flags |=3D ETH_TEST_FL_FAILED;
 	}
-
-#ifdef BNX2X_EXTRA_DEBUG
-	bnx2x_panic_dump(bp);
-#endif
 }
=20
 static const struct {
@@ -8381,35 +8343,35 @@ static int bnx2x_phys_id(struct net_device *dev=
, u32 data)
 }
=20
 static struct ethtool_ops bnx2x_ethtool_ops =3D {
-	.get_settings   	=3D bnx2x_get_settings,
-	.set_settings   	=3D bnx2x_set_settings,
-	.get_drvinfo    	=3D bnx2x_get_drvinfo,
+	.get_settings		=3D bnx2x_get_settings,
+	.set_settings		=3D bnx2x_set_settings,
+	.get_drvinfo		=3D bnx2x_get_drvinfo,
 	.get_wol		=3D bnx2x_get_wol,
 	.set_wol		=3D bnx2x_set_wol,
-	.get_msglevel   	=3D bnx2x_get_msglevel,
-	.set_msglevel   	=3D bnx2x_set_msglevel,
-	.nway_reset     	=3D bnx2x_nway_reset,
-	.get_link       	=3D ethtool_op_get_link,
-	.get_eeprom_len 	=3D bnx2x_get_eeprom_len,
-	.get_eeprom     	=3D bnx2x_get_eeprom,
-	.set_eeprom     	=3D bnx2x_set_eeprom,
-	.get_coalesce   	=3D bnx2x_get_coalesce,
-	.set_coalesce   	=3D bnx2x_set_coalesce,
-	.get_ringparam  	=3D bnx2x_get_ringparam,
-	.set_ringparam  	=3D bnx2x_set_ringparam,
-	.get_pauseparam 	=3D bnx2x_get_pauseparam,
-	.set_pauseparam 	=3D bnx2x_set_pauseparam,
-	.get_rx_csum    	=3D bnx2x_get_rx_csum,
-	.set_rx_csum    	=3D bnx2x_set_rx_csum,
-	.get_tx_csum    	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum    	=3D ethtool_op_set_tx_csum,
-	.get_sg 		=3D ethtool_op_get_sg,
-	.set_sg 		=3D ethtool_op_set_sg,
+	.get_msglevel		=3D bnx2x_get_msglevel,
+	.set_msglevel		=3D bnx2x_set_msglevel,
+	.nway_reset		=3D bnx2x_nway_reset,
+	.get_link		=3D ethtool_op_get_link,
+	.get_eeprom_len		=3D bnx2x_get_eeprom_len,
+	.get_eeprom		=3D bnx2x_get_eeprom,
+	.set_eeprom		=3D bnx2x_set_eeprom,
+	.get_coalesce		=3D bnx2x_get_coalesce,
+	.set_coalesce		=3D bnx2x_set_coalesce,
+	.get_ringparam		=3D bnx2x_get_ringparam,
+	.set_ringparam		=3D bnx2x_set_ringparam,
+	.get_pauseparam		=3D bnx2x_get_pauseparam,
+	.set_pauseparam		=3D bnx2x_set_pauseparam,
+	.get_rx_csum		=3D bnx2x_get_rx_csum,
+	.set_rx_csum		=3D bnx2x_set_rx_csum,
+	.get_tx_csum		=3D ethtool_op_get_tx_csum,
+	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
+	.get_sg			=3D ethtool_op_get_sg,
+	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.set_tso		=3D bnx2x_set_tso,
 	.self_test_count	=3D bnx2x_self_test_count,
-	.self_test      	=3D bnx2x_self_test,
-	.get_strings    	=3D bnx2x_get_strings,
+	.self_test		=3D bnx2x_self_test,
+	.get_strings		=3D bnx2x_get_strings,
 	.phys_id		=3D bnx2x_phys_id,
 	.get_stats_count	=3D bnx2x_get_stats_count,
 	.get_ethtool_stats	=3D bnx2x_get_ethtool_stats,
@@ -8505,9 +8467,181 @@ poll_panic:
 	return work_done;
 }
=20
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
+	struct eth_tx_bd *h_tx_bd =3D *tx_bd;
+	struct eth_tx_bd *d_tx_bd;
+	dma_addr_t mapping;
+	int old_len =3D le16_to_cpu(h_tx_bd->nbytes);
+
+	/* first fix first BD */
+	h_tx_bd->nbd =3D cpu_to_le16(nbd);
+	h_tx_bd->nbytes =3D cpu_to_le16(hlen);
+
+	DP(NETIF_MSG_TX_QUEUED,	"TSO split header size is %d "
+	   "(%x:%x) nbd %d\n", h_tx_bd->nbytes, h_tx_bd->addr_hi,
+	   h_tx_bd->addr_lo, h_tx_bd->nbd);
+
+	/* now get a new data BD
+	 * (after the pbd) and fill it */
+	bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
+	d_tx_bd =3D &fp->tx_desc_ring[bd_prod];
+
+	mapping =3D HILO_U64(le32_to_cpu(h_tx_bd->addr_hi),
+			   le32_to_cpu(h_tx_bd->addr_lo)) + hlen;
+
+	d_tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
+	d_tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
+	d_tx_bd->nbytes =3D cpu_to_le16(old_len - hlen);
+	d_tx_bd->vlan =3D 0;
+	/* this marks the BD as one that has no individual mapping
+	 * the FW ignores this flag in a BD not marked start
+	 */
+	d_tx_bd->bd_flags.as_bitfield =3D ETH_TX_BD_FLAGS_SW_LSO;
+	DP(NETIF_MSG_TX_QUEUED,
+	   "TSO split data size is %d (%x:%x)\n",
+	   d_tx_bd->nbytes, d_tx_bd->addr_hi, d_tx_bd->addr_lo);
+
+	/* update tx_bd for marking the last BD flag */
+	*tx_bd =3D d_tx_bd;
+
+	return bd_prod;
+}
+
+static inline u16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8=
 fix)
+{
+	if (fix > 0)
+		csum =3D (u16) ~csum_fold(csum_sub(csum,
+				csum_partial(t_header - fix, fix, 0)));
+
+	else if (fix < 0)
+		csum =3D (u16) ~csum_fold(csum_add(csum,
+				csum_partial(t_header, -fix, 0)));
+
+	return swab16(csum);
+}
+
+static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *sk=
b)
+{
+	u32 rc;
+
+	if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
+		rc =3D XMIT_PLAIN;
+
+	else {
+		if (skb->protocol =3D=3D ntohs(ETH_P_IPV6)) {
+			rc =3D XMIT_CSUM_V6;
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_TCP)
+				rc |=3D XMIT_CSUM_TCP;
+
+		} else {
+			rc =3D XMIT_CSUM_V4;
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_TCP)
+				rc |=3D XMIT_CSUM_TCP;
+		}
+	}
+
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+		rc |=3D XMIT_GSO_V4;
+
+	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		rc |=3D XMIT_GSO_V6;
+
+	return rc;
+}
+
+/* check if packet requires linearization (packet is too is fragmented=
)
+*/
+static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
+			     u32 xmit_type)
+{
+	u8 to_copy =3D 0;
+	int hlen =3D 0;
+	int first_bd_sz =3D 0;
+
+	/* 3 =3D 1 (for linear data BD) + 2 (for PBD and last BD) */
+	if (skb_shinfo(skb)->nr_frags >=3D (MAX_FETCH_BD - 3)) {
+
+		if (xmit_type & XMIT_GSO) {
+			unsigned short lso_mss =3D skb_shinfo(skb)->gso_size;
+			/* Check if LSO packet needs to be copied:
+			   3 =3D 1 (for headers BD) + 2 (for PBD and last BD) */
+			int wnd_size =3D MAX_FETCH_BD - 3;
+			/* Number of widnows to check */
+			int num_wnds =3D skb_shinfo(skb)->nr_frags - wnd_size;
+			int wnd_idx =3D 0;
+			int frag_idx =3D 0;
+			u32 wnd_sum =3D 0;
+
+			/* Headers length */
+			hlen =3D (int)(skb_transport_header(skb) - skb->data) +
+				tcp_hdrlen(skb);
+
+			/* Amount of data (w/o headers) on linear part of SKB*/
+			first_bd_sz =3D skb_headlen(skb) - hlen;
+
+			wnd_sum  =3D first_bd_sz;
+
+			/* Calculate the first sum - it's special */
+			for (frag_idx =3D 0; frag_idx < wnd_size - 1; frag_idx++)
+				wnd_sum +=3D
+					skb_shinfo(skb)->frags[frag_idx].size;
+
+			/* If there was data on linear skb data - check it */
+			if (first_bd_sz > 0) {
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy =3D 1;
+					goto exit_lbl;
+				}
+
+				wnd_sum -=3D first_bd_sz;
+			}
+
+			/* Others are easier: run through the frag list and
+			   check all windows */
+			for (wnd_idx =3D 0; wnd_idx <=3D num_wnds; wnd_idx++) {
+				wnd_sum +=3D
+			  skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1].size;
+
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy =3D 1;
+					break;
+				}
+				wnd_sum -=3D
+					skb_shinfo(skb)->frags[wnd_idx].size;
+			}
+
+		} else {
+			/* in non-LSO too fragmented packet should always
+			   be linearized */
+			to_copy =3D 1;
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
 static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *de=
v)
 {
@@ -8517,17 +8651,22 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
 	struct eth_tx_bd *tx_bd;
 	struct eth_tx_parse_bd *pbd =3D NULL;
 	u16 pkt_prod, bd_prod;
-	int nbd, fp_index =3D 0;
+	int nbd, fp_index;
 	dma_addr_t mapping;
+	u32 xmit_type =3D bnx2x_xmit_type(bp, skb);
+	int vlan_off =3D (bp->e1hovl ? 4 : 0);
+	int i;
+	u8 hlen =3D 0;
=20
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return NETDEV_TX_BUSY;
 #endif
=20
-	fp_index =3D smp_processor_id() % (bp->num_queues);
+	fp_index =3D (smp_processor_id() % bp->num_queues);
=20
 	fp =3D &bp->fp[fp_index];
+
 	if (unlikely(bnx2x_tx_avail(bp->fp) <
 					(skb_shinfo(skb)->nr_frags + 3))) {
 		bp->eth_stats.driver_xoff++,
@@ -8536,20 +8675,37 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
=20
+	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)=
"
+	   "  gso type %x  xmit_type %x\n",
+	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
+	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
+
+	/* First, check if we need to linearaize the skb
+	   (due to FW restrictions) */
+	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
+		/* Statistics of linearization */
+		bp->lin_cnt++;
+		if (skb_linearize(skb) !=3D 0) {
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
=20
 	pkt_prod =3D fp->tx_pkt_prod++;
-	bd_prod =3D fp->tx_bd_prod;
-	bd_prod =3D TX_BD(bd_prod);
+	bd_prod =3D TX_BD(fp->tx_bd_prod);
=20
-	/* get a tx_buff and first bd */
+	/* get a tx_buf and first BD */
 	tx_buf =3D &fp->tx_buf_ring[TX_BD(pkt_prod)];
 	tx_bd =3D &fp->tx_desc_ring[bd_prod];
=20
@@ -8558,65 +8714,79 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
 	tx_bd->general_data |=3D 1; /* header nbd */
=20
-	/* remember the first bd of the packet */
-	tx_buf->first_bd =3D bd_prod;
+	/* remember the first BD of the packet */
+	tx_buf->first_bd =3D fp->tx_bd_prod;
+	tx_buf->skb =3D skb;
=20
 	DP(NETIF_MSG_TX_QUEUED,
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
 	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_bd);
=20
-	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		struct iphdr *iph =3D ip_hdr(skb);
-		u8 len;
+	if ((bp->vlgrp !=3D NULL) && vlan_tx_tag_present(skb)) {
+		tx_bd->vlan =3D cpu_to_le16(vlan_tx_tag_get(skb));
+		tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_VLAN_TAG;
+		vlan_off +=3D 4;
+	} else
+		tx_bd->vlan =3D cpu_to_le16(pkt_prod);
=20
-		tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_IP_CSUM;
+	if (xmit_type) {
=20
-		/* turn on parsing and get a bd */
+		/* turn on parsing and get a BD */
 		bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
 		pbd =3D (void *)&fp->tx_desc_ring[bd_prod];
-		len =3D ((u8 *)iph - (u8 *)skb->data) / 2;
+
+		memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
+	}
+
+	if (xmit_type & XMIT_CSUM) {
+		hlen =3D (skb_network_header(skb) - skb->data + vlan_off) / 2;
=20
 		/* for now NS flag is not used in Linux */
-		pbd->global_data =3D (len |
+		pbd->global_data =3D (hlen |
 				    ((skb->protocol =3D=3D ntohs(ETH_P_8021Q)) <<
 				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
-		pbd->ip_hlen =3D ip_hdrlen(skb) / 2;
-		pbd->total_hlen =3D cpu_to_le16(len + pbd->ip_hlen);
-		if (iph->protocol =3D=3D IPPROTO_TCP) {
-			struct tcphdr *th =3D tcp_hdr(skb);
=20
-			tx_bd->bd_flags.as_bitfield |=3D
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->tcp_flags =3D pbd_tcp_flags(skb);
-			pbd->total_hlen +=3D cpu_to_le16(tcp_hdrlen(skb) / 2);
-			pbd->tcp_pseudo_csum =3D swab16(th->check);
+		pbd->ip_hlen =3D (skb_transport_header(skb) -
+				skb_network_header(skb)) / 2;
+
+		hlen +=3D pbd->ip_hlen + tcp_hdrlen(skb) / 2;
=20
-		} else if (iph->protocol =3D=3D IPPROTO_UDP) {
-			struct udphdr *uh =3D udp_hdr(skb);
+		pbd->total_hlen =3D cpu_to_le16(hlen);
+		hlen =3D hlen*2 - vlan_off;
=20
+		tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_TCP_CSUM;
+
+		if (xmit_type & XMIT_CSUM_V4)
 			tx_bd->bd_flags.as_bitfield |=3D
-						ETH_TX_BD_FLAGS_TCP_CSUM;
-			pbd->total_hlen +=3D cpu_to_le16(4);
+						ETH_TX_BD_FLAGS_IP_CSUM;
+		else
+			tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_IPV6;
+
+		if (xmit_type & XMIT_CSUM_TCP) {
+			pbd->tcp_pseudo_csum =3D swab16(tcp_hdr(skb)->check);
+
+		} else {
+			s8 fix =3D SKB_CS_OFF(skb); /* signed! */
+
 			pbd->global_data |=3D ETH_TX_PARSE_BD_CS_ANY_FLG;
-			pbd->cs_offset =3D 5; /* 10 >> 1 */
-			pbd->tcp_pseudo_csum =3D 0;
-			/* HW bug: we need to subtract 10 bytes before the
-			 * UDP header from the csum
-			 */
-			uh->check =3D (u16) ~csum_fold(csum_sub(uh->check,
-				csum_partial(((u8 *)(uh)-10), 10, 0)));
-		}
-	}
+			pbd->cs_offset =3D fix / 2;
=20
-	if ((bp->vlgrp !=3D NULL) && vlan_tx_tag_present(skb)) {
-		tx_bd->vlan =3D cpu_to_le16(vlan_tx_tag_get(skb));
-		tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_VLAN_TAG;
-	} else {
-		tx_bd->vlan =3D cpu_to_le16(pkt_prod);
+			DP(NETIF_MSG_TX_QUEUED,
+			   "hlen %d  offset %d  fix %d  csum befor fix %x\n",
+			   pbd->total_hlen, pbd->cs_offset, fix, SKB_CS(skb));
+
+			/* HW bug: fixup the CSUM */
+			pbd->tcp_pseudo_csum =3D
+				bnx2x_csum_fix(skb_transport_header(skb),
+					       SKB_CS(skb), fix);
+
+			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
+			   pbd->tcp_pseudo_csum);
+		}
 	}
=20
 	mapping =3D pci_map_single(bp->pdev, skb->data,
-				 skb->len, PCI_DMA_TODEVICE);
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
=20
 	tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
 	tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
@@ -8625,13 +8795,12 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
 	tx_bd->nbytes =3D cpu_to_le16(skb_headlen(skb));
=20
 	DP(NETIF_MSG_TX_QUEUED, "first bd @%p  addr (%x:%x)  nbd %d"
-	   "  nbytes %d  flags %x  vlan %u\n",
-	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, tx_bd->nbd,
-	   tx_bd->nbytes, tx_bd->bd_flags.as_bitfield, tx_bd->vlan);
+	   "  nbytes %d  flags %x  vlan %x\n",
+	   tx_bd, tx_bd->addr_hi, tx_bd->addr_lo, le16_to_cpu(tx_bd->nbd),
+	   le16_to_cpu(tx_bd->nbytes), tx_bd->bd_flags.as_bitfield,
+	   le16_to_cpu(tx_bd->vlan));
=20
-	if (skb_shinfo(skb)->gso_size &&
-	    (skb->len > (bp->dev->mtu + ETH_HLEN))) {
-		int hlen =3D 2 * le16_to_cpu(pbd->total_hlen);
+	if (xmit_type & XMIT_GSO) {
=20
 		DP(NETIF_MSG_TX_QUEUED,
 		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
@@ -8640,99 +8809,60 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
=20
 		tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_SW_LSO;
=20
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
-			tx_bd->nbd =3D cpu_to_le16(nbd);
-			tx_bd->nbytes =3D cpu_to_le16(hlen);
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
-			bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
-			tx_bd =3D &fp->tx_desc_ring[bd_prod];
-
-			tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
-			tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping) + hlen);
-			tx_bd->nbytes =3D cpu_to_le16(skb_headlen(skb) - hlen);
-			tx_bd->vlan =3D cpu_to_le16(pkt_prod);
-			/* this marks the bd
-			 * as one that has no individual mapping
-			 * the FW ignores this flag in a bd not marked start
-			 */
-			tx_bd->bd_flags.as_bitfield =3D ETH_TX_BD_FLAGS_SW_LSO;
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
+			bd_prod =3D bnx2x_tx_split(bp, fp, &tx_bd, hlen,
+						 bd_prod, ++nbd);
=20
 		pbd->lso_mss =3D cpu_to_le16(skb_shinfo(skb)->gso_size);
 		pbd->tcp_send_seq =3D swab32(tcp_hdr(skb)->seq);
-		pbd->ip_id =3D swab16(ip_hdr(skb)->id);
-		pbd->tcp_pseudo_csum =3D
+		pbd->tcp_flags =3D pbd_tcp_flags(skb);
+
+		if (xmit_type & XMIT_GSO_V4) {
+			pbd->ip_id =3D swab16(ip_hdr(skb)->id);
+			pbd->tcp_pseudo_csum =3D
 				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
 							  ip_hdr(skb)->daddr,
 							  0, IPPROTO_TCP, 0));
+
+		} else
+			pbd->tcp_pseudo_csum =3D
+				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+							&ipv6_hdr(skb)->daddr,
+							0, IPPROTO_TCP, 0));
+
 		pbd->global_data |=3D ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
 	}
=20
-	{
-		int i;
+	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+		bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
+		tx_bd =3D &fp->tx_desc_ring[bd_prod];
=20
-			bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
-			tx_bd =3D &fp->tx_desc_ring[bd_prod];
+		mapping =3D pci_map_page(bp->pdev, frag->page, frag->page_offset,
+				       frag->size, PCI_DMA_TODEVICE);
=20
-			mapping =3D pci_map_page(bp->pdev, frag->page,
-					       frag->page_offset,
-					       frag->size, PCI_DMA_TODEVICE);
+		tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
+		tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
+		tx_bd->nbytes =3D cpu_to_le16(frag->size);
+		tx_bd->vlan =3D cpu_to_le16(pkt_prod);
+		tx_bd->bd_flags.as_bitfield =3D 0;
=20
-			tx_bd->addr_hi =3D cpu_to_le32(U64_HI(mapping));
-			tx_bd->addr_lo =3D cpu_to_le32(U64_LO(mapping));
-			tx_bd->nbytes =3D cpu_to_le16(frag->size);
-			tx_bd->vlan =3D cpu_to_le16(pkt_prod);
-			tx_bd->bd_flags.as_bitfield =3D 0;
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
=20
-	/* now at last mark the bd as the last bd */
+	/* now at last mark the BD as the last BD */
 	tx_bd->bd_flags.as_bitfield |=3D ETH_TX_BD_FLAGS_END_BD;
=20
 	DP(NETIF_MSG_TX_QUEUED, "last bd @%p  flags %x\n",
 	   tx_bd, tx_bd->bd_flags.as_bitfield);
=20
-	tx_buf->skb =3D skb;
-
 	bd_prod =3D TX_BD(NEXT_TX_IDX(bd_prod));
=20
-	/* now send a tx doorbell, counting the next bd
+	/* now send a tx doorbell, counting the next BD
 	 * if the packet contains or ends with it
 	 */
 	if (TX_BD_POFF(bd_prod) < nbd)
@@ -8746,18 +8876,18 @@ static int bnx2x_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
 		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
 		   pbd->tcp_send_seq, pbd->total_hlen);
=20
-	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %u  bd %d\n", nbd, bd_prod);
+	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
=20
 	fp->hw_tx_prods->bds_prod =3D
 		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =3D
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, fp_index, 0);
+	DOORBELL(bp, FP_IDX(fp), 0);
=20
 	mmiowb();
=20
-	fp->tx_bd_prod =3D bd_prod;
+	fp->tx_bd_prod +=3D nbd;
 	dev->trans_start =3D jiffies;
=20
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
@@ -9176,10 +9306,7 @@ static int __devinit bnx2x_init_dev(struct pci_d=
ev *pdev,
 	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 #endif
 	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-
-	bp->timer_interval =3D HZ;
-	bp->current_interval =3D (poll ? poll : HZ);
-
+	dev->features |=3D NETIF_F_TSO6;
=20
 	return 0;
=20
--=20
1.5.5




