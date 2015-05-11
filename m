From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4/cxgb4vf: Cleanup macros, add comments and add new MACROS
Date: Tue, 12 May 2015 04:43:43 +0530
Message-ID: <1431386023-25982-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24875 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751926AbbEKSBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 14:01:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup few MACROS left out in t4_hw.h to be consistent with the
existing ones. Also replace few hardcoded values with MACROS. Also
update comments for some code

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 160 ++++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  34 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  83 +++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |  14 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  13 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  73 +++++-----
 9 files changed, 235 insertions(+), 147 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 10d82b5..401272a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -578,7 +578,7 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 	const struct sge_rspq *rq = &adap->sge.ethrxq[pi->first_qset].rspq;
 
 	c->rx_coalesce_usecs = qtimer_val(adap, rq);
-	c->rx_max_coalesced_frames = (rq->intr_params & QINTR_CNT_EN) ?
+	c->rx_max_coalesced_frames = (rq->intr_params & QINTR_CNT_EN_F) ?
 		adap->sge.counter_val[rq->pktcnt_idx] : 0;
 	c->use_adaptive_rx_coalesce = get_adaptive_rx_setting(dev);
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 223995e7..5aecf69 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1420,7 +1420,7 @@ int cxgb4_set_rspq_intr_params(struct sge_rspq *q,
 	}
 
 	us = us == 0 ? 6 : closest_timer(&adap->sge, us);
-	q->intr_params = QINTR_TIMER_IDX(us) | (cnt > 0 ? QINTR_CNT_EN : 0);
+	q->intr_params = QINTR_TIMER_IDX_V(us) | QINTR_CNT_EN_V(cnt > 0);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 898842d..dd18fcb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -530,6 +530,10 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 			val = PIDX_T5_V(q->pend_cred / 8) |
 				DBTYPE_F;
 		val |= DBPRIO_F;
+
+		/* Make sure all memory writes to the Free List queue are
+		 * committed before we tell the hardware about them.
+		 */
 		wmb();
 
 		/* If we don't have access to the new User Doorbell (T5+), use
@@ -920,7 +924,10 @@ static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
  */
 static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 {
-	wmb();            /* write descriptors before telling HW */
+	/* Make sure that all writes to the TX Descriptors are committed
+	 * before we tell the hardware about them.
+	 */
+	wmb();
 
 	/* If we don't have access to the new User Doorbell (T5+), use the old
 	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
@@ -1037,7 +1044,7 @@ nocsum:			/*
 			 * unknown protocol, disable HW csum
 			 * and hope a bad packet is detected
 			 */
-			return TXPKT_L4CSUM_DIS;
+			return TXPKT_L4CSUM_DIS_F;
 		}
 	} else {
 		/*
@@ -1054,14 +1061,15 @@ nocsum:			/*
 	}
 
 	if (likely(csum_type >= TX_CSUM_TCPIP))
-		return TXPKT_CSUM_TYPE(csum_type) |
-			TXPKT_IPHDR_LEN(skb_network_header_len(skb)) |
-			TXPKT_ETHHDR_LEN(skb_network_offset(skb) - ETH_HLEN);
+		return TXPKT_CSUM_TYPE_V(csum_type) |
+			TXPKT_IPHDR_LEN_V(skb_network_header_len(skb)) |
+			TXPKT_ETHHDR_LEN_V(skb_network_offset(skb) - ETH_HLEN);
 	else {
 		int start = skb_transport_offset(skb);
 
-		return TXPKT_CSUM_TYPE(csum_type) | TXPKT_CSUM_START(start) |
-			TXPKT_CSUM_LOC(start + skb->csum_offset);
+		return TXPKT_CSUM_TYPE_V(csum_type) |
+			TXPKT_CSUM_START_V(start) |
+			TXPKT_CSUM_LOC_V(start + skb->csum_offset);
 	}
 }
 
@@ -1102,11 +1110,11 @@ cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
 		return -ENOTSUPP;
 
 	/* FC CRC offload */
-	*cntrl = TXPKT_CSUM_TYPE(TX_CSUM_FCOE) |
-		     TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS |
-		     TXPKT_CSUM_START(CXGB_FCOE_TXPKT_CSUM_START) |
-		     TXPKT_CSUM_END(CXGB_FCOE_TXPKT_CSUM_END) |
-		     TXPKT_CSUM_LOC(CXGB_FCOE_TXPKT_CSUM_END);
+	*cntrl = TXPKT_CSUM_TYPE_V(TX_CSUM_FCOE) |
+		     TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F |
+		     TXPKT_CSUM_START_V(CXGB_FCOE_TXPKT_CSUM_START) |
+		     TXPKT_CSUM_END_V(CXGB_FCOE_TXPKT_CSUM_END) |
+		     TXPKT_CSUM_LOC_V(CXGB_FCOE_TXPKT_CSUM_END);
 	return 0;
 }
 #endif /* CONFIG_CHELSIO_T4_FCOE */
@@ -1159,7 +1167,7 @@ out_free:	dev_kfree_skb_any(skb);
 	q = &adap->sge.ethtxq[qidx + pi->first_qset];
 
 	reclaim_completed_tx(adap, &q->q, true);
-	cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
+	cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
 
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	err = cxgb_fcoe_offload(skb, adap, pi, &cntrl);
@@ -1210,23 +1218,23 @@ out_free:	dev_kfree_skb_any(skb);
 		len += sizeof(*lso);
 		wr->op_immdlen = htonl(FW_WR_OP_V(FW_ETH_TX_PKT_WR) |
 				       FW_WR_IMMDLEN_V(len));
-		lso->c.lso_ctrl = htonl(LSO_OPCODE(CPL_TX_PKT_LSO) |
-					LSO_FIRST_SLICE | LSO_LAST_SLICE |
-					LSO_IPV6(v6) |
-					LSO_ETHHDR_LEN(eth_xtra_len / 4) |
-					LSO_IPHDR_LEN(l3hdr_len / 4) |
-					LSO_TCPHDR_LEN(tcp_hdr(skb)->doff));
+		lso->c.lso_ctrl = htonl(LSO_OPCODE_V(CPL_TX_PKT_LSO) |
+					LSO_FIRST_SLICE_F | LSO_LAST_SLICE_F |
+					LSO_IPV6_V(v6) |
+					LSO_ETHHDR_LEN_V(eth_xtra_len / 4) |
+					LSO_IPHDR_LEN_V(l3hdr_len / 4) |
+					LSO_TCPHDR_LEN_V(tcp_hdr(skb)->doff));
 		lso->c.ipid_ofst = htons(0);
 		lso->c.mss = htons(ssi->gso_size);
 		lso->c.seqno_offset = htonl(0);
 		if (is_t4(adap->params.chip))
 			lso->c.len = htonl(skb->len);
 		else
-			lso->c.len = htonl(LSO_T5_XFER_SIZE(skb->len));
+			lso->c.len = htonl(LSO_T5_XFER_SIZE_V(skb->len));
 		cpl = (void *)(lso + 1);
-		cntrl = TXPKT_CSUM_TYPE(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
-			TXPKT_IPHDR_LEN(l3hdr_len) |
-			TXPKT_ETHHDR_LEN(eth_xtra_len);
+		cntrl = TXPKT_CSUM_TYPE_V(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
+			TXPKT_IPHDR_LEN_V(l3hdr_len) |
+			TXPKT_ETHHDR_LEN_V(eth_xtra_len);
 		q->tso++;
 		q->tx_cso += ssi->gso_segs;
 	} else {
@@ -1235,23 +1243,24 @@ out_free:	dev_kfree_skb_any(skb);
 				       FW_WR_IMMDLEN_V(len));
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS;
+			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS_F;
 			q->tx_cso++;
 		}
 	}
 
 	if (skb_vlan_tag_present(skb)) {
 		q->vlan_ins++;
-		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(skb_vlan_tag_get(skb));
+		cntrl |= TXPKT_VLAN_VLD_F | TXPKT_VLAN_V(skb_vlan_tag_get(skb));
 #ifdef CONFIG_CHELSIO_T4_FCOE
 		if (skb->protocol == htons(ETH_P_FCOE))
-			cntrl |= TXPKT_VLAN(
+			cntrl |= TXPKT_VLAN_V(
 				 ((skb->priority & 0x7) << VLAN_PRIO_SHIFT));
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 	}
 
-	cpl->ctrl0 = htonl(TXPKT_OPCODE(CPL_TX_PKT_XT) |
-			   TXPKT_INTF(pi->tx_chan) | TXPKT_PF(adap->fn));
+	cpl->ctrl0 = htonl(TXPKT_OPCODE_V(CPL_TX_PKT_XT) |
+			   TXPKT_INTF_V(pi->tx_chan) |
+			   TXPKT_PF_V(adap->fn));
 	cpl->pack = htons(0);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
@@ -1961,7 +1970,7 @@ static void restore_rx_bufs(const struct pkt_gl *si, struct sge_fl *q,
 static inline bool is_new_response(const struct rsp_ctrl *r,
 				   const struct sge_rspq *q)
 {
-	return RSPD_GEN(r->type_gen) == q->gen;
+	return (r->type_gen >> RSPD_GEN_S) == q->gen;
 }
 
 /**
@@ -2008,19 +2017,19 @@ static int process_responses(struct sge_rspq *q, int budget)
 			break;
 
 		dma_rmb();
-		rsp_type = RSPD_TYPE(rc->type_gen);
-		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
+		rsp_type = RSPD_TYPE_G(rc->type_gen);
+		if (likely(rsp_type == RSPD_TYPE_FLBUF_X)) {
 			struct page_frag *fp;
 			struct pkt_gl si;
 			const struct rx_sw_desc *rsd;
 			u32 len = ntohl(rc->pldbuflen_qid), bufsz, frags;
 
-			if (len & RSPD_NEWBUF) {
+			if (len & RSPD_NEWBUF_F) {
 				if (likely(q->offset > 0)) {
 					free_rx_bufs(q->adap, &rxq->fl, 1);
 					q->offset = 0;
 				}
-				len = RSPD_LEN(len);
+				len = RSPD_LEN_G(len);
 			}
 			si.tot_len = len;
 
@@ -2055,7 +2064,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 				q->offset += ALIGN(fp->size, s->fl_align);
 			else
 				restore_rx_bufs(&si, &rxq->fl, frags);
-		} else if (likely(rsp_type == RSP_TYPE_CPL)) {
+		} else if (likely(rsp_type == RSPD_TYPE_CPL_X)) {
 			ret = q->handler(q, q->cur_desc, NULL);
 		} else {
 			ret = q->handler(q, (const __be64 *)rc, CXGB4_MSG_AN);
@@ -2063,7 +2072,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 
 		if (unlikely(ret)) {
 			/* couldn't process descriptor, back off for recovery */
-			q->next_intr_params = QINTR_TIMER_IDX(NOMEM_TMR_IDX);
+			q->next_intr_params = QINTR_TIMER_IDX_V(NOMEM_TMR_IDX);
 			break;
 		}
 
@@ -2087,7 +2096,7 @@ int cxgb_busy_poll(struct napi_struct *napi)
 		return LL_FLUSH_BUSY;
 
 	work_done = process_responses(q, 4);
-	params = QINTR_TIMER_IDX(TIMERREG_COUNTER0_X) | QINTR_CNT_EN;
+	params = QINTR_TIMER_IDX_V(TIMERREG_COUNTER0_X) | QINTR_CNT_EN_V(1);
 	q->next_intr_params = params;
 	val = CIDXINC_V(work_done) | SEINTARM_V(params);
 
@@ -2134,7 +2143,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		int timer_index;
 
 		napi_complete(napi);
-		timer_index = QINTR_TIMER_IDX_GET(q->next_intr_params);
+		timer_index = QINTR_TIMER_IDX_G(q->next_intr_params);
 
 		if (q->adaptive_rx) {
 			if (work_done > max(timer_pkt_quota[timer_index],
@@ -2144,15 +2153,16 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 				timer_index = timer_index - 1;
 
 			timer_index = clamp(timer_index, 0, SGE_TIMERREGS - 1);
-			q->next_intr_params = QINTR_TIMER_IDX(timer_index) |
-							      V_QINTR_CNT_EN;
+			q->next_intr_params =
+					QINTR_TIMER_IDX_V(timer_index) |
+					QINTR_CNT_EN_V(0);
 			params = q->next_intr_params;
 		} else {
 			params = q->next_intr_params;
 			q->next_intr_params = q->intr_params;
 		}
 	} else
-		params = QINTR_TIMER_IDX(7);
+		params = QINTR_TIMER_IDX_V(7);
 
 	val = CIDXINC_V(work_done) | SEINTARM_V(params);
 
@@ -2200,7 +2210,7 @@ static unsigned int process_intrq(struct adapter *adap)
 			break;
 
 		dma_rmb();
-		if (RSPD_TYPE(rc->type_gen) == RSP_TYPE_INTR) {
+		if (RSPD_TYPE_G(rc->type_gen) == RSPD_TYPE_INTR_X) {
 			unsigned int qid = ntohl(rc->pldbuflen_qid);
 
 			qid -= adap->sge.ingr_start;
@@ -2411,7 +2421,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 				 FW_LEN16(c));
 	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(FW_IQ_TYPE_FL_INT_CAP) |
 		FW_IQ_CMD_IQASYNCH_V(fwevtq) | FW_IQ_CMD_VIID_V(pi->viid) |
-		FW_IQ_CMD_IQANDST_V(intr_idx < 0) | FW_IQ_CMD_IQANUD_V(1) |
+		FW_IQ_CMD_IQANDST_V(intr_idx < 0) |
+		FW_IQ_CMD_IQANUD_V(UPDATEDELIVERY_INTERRUPT_X) |
 		FW_IQ_CMD_IQANDSTINDEX_V(intr_idx >= 0 ? intr_idx :
 							-intr_idx - 1));
 	c.iqdroprss_to_iqesize = htons(FW_IQ_CMD_IQPCIECH_V(pi->tx_chan) |
@@ -2450,8 +2461,9 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 				htonl(FW_IQ_CMD_FL0CNGCHMAP_V(cong) |
 				      FW_IQ_CMD_FL0CONGCIF_F |
 				      FW_IQ_CMD_FL0CONGEN_F);
-		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN_V(2) |
-				FW_IQ_CMD_FL0FBMAX_V(3));
+		c.fl0dcaen_to_fl0cidxfthresh =
+			htons(FW_IQ_CMD_FL0FBMIN_V(FETCHBURSTMIN_64B_X) |
+			      FW_IQ_CMD_FL0FBMAX_V(FETCHBURSTMAX_512B_X));
 		c.fl0size = htons(flsz);
 		c.fl0addr = cpu_to_be64(fl->addr);
 	}
@@ -2595,14 +2607,15 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 				 FW_EQ_ETH_CMD_EQSTART_F | FW_LEN16(c));
 	c.viid_pkd = htonl(FW_EQ_ETH_CMD_AUTOEQUEQE_F |
 			   FW_EQ_ETH_CMD_VIID_V(pi->viid));
-	c.fetchszm_to_iqid = htonl(FW_EQ_ETH_CMD_HOSTFCMODE_V(2) |
-				   FW_EQ_ETH_CMD_PCIECHN_V(pi->tx_chan) |
-				   FW_EQ_ETH_CMD_FETCHRO_V(1) |
-				   FW_EQ_ETH_CMD_IQID_V(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_ETH_CMD_FBMIN_V(2) |
-				  FW_EQ_ETH_CMD_FBMAX_V(3) |
-				  FW_EQ_ETH_CMD_CIDXFTHRESH_V(5) |
-				  FW_EQ_ETH_CMD_EQSIZE_V(nentries));
+	c.fetchszm_to_iqid =
+		htonl(FW_EQ_ETH_CMD_HOSTFCMODE_V(HOSTFCMODE_STATUS_PAGE_X) |
+		      FW_EQ_ETH_CMD_PCIECHN_V(pi->tx_chan) |
+		      FW_EQ_ETH_CMD_FETCHRO_F | FW_EQ_ETH_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize =
+		htonl(FW_EQ_ETH_CMD_FBMIN_V(FETCHBURSTMIN_64B_X) |
+		      FW_EQ_ETH_CMD_FBMAX_V(FETCHBURSTMAX_512B_X) |
+		      FW_EQ_ETH_CMD_CIDXFTHRESH_V(CIDXFLUSHTHRESH_32_X) |
+		      FW_EQ_ETH_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -2649,14 +2662,15 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 				 FW_EQ_CTRL_CMD_EQSTART_F | FW_LEN16(c));
 	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_CMPLIQID_V(cmplqid));
 	c.physeqid_pkd = htonl(0);
-	c.fetchszm_to_iqid = htonl(FW_EQ_CTRL_CMD_HOSTFCMODE_V(2) |
-				   FW_EQ_CTRL_CMD_PCIECHN_V(pi->tx_chan) |
-				   FW_EQ_CTRL_CMD_FETCHRO_F |
-				   FW_EQ_CTRL_CMD_IQID_V(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_CTRL_CMD_FBMIN_V(2) |
-				  FW_EQ_CTRL_CMD_FBMAX_V(3) |
-				  FW_EQ_CTRL_CMD_CIDXFTHRESH_V(5) |
-				  FW_EQ_CTRL_CMD_EQSIZE_V(nentries));
+	c.fetchszm_to_iqid =
+		htonl(FW_EQ_CTRL_CMD_HOSTFCMODE_V(HOSTFCMODE_STATUS_PAGE_X) |
+		      FW_EQ_CTRL_CMD_PCIECHN_V(pi->tx_chan) |
+		      FW_EQ_CTRL_CMD_FETCHRO_F | FW_EQ_CTRL_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize =
+		htonl(FW_EQ_CTRL_CMD_FBMIN_V(FETCHBURSTMIN_64B_X) |
+		      FW_EQ_CTRL_CMD_FBMAX_V(FETCHBURSTMAX_512B_X) |
+		      FW_EQ_CTRL_CMD_CIDXFTHRESH_V(CIDXFLUSHTHRESH_32_X) |
+		      FW_EQ_CTRL_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -2701,14 +2715,15 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 			    FW_EQ_OFLD_CMD_VFN_V(0));
 	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC_F |
 				 FW_EQ_OFLD_CMD_EQSTART_F | FW_LEN16(c));
-	c.fetchszm_to_iqid = htonl(FW_EQ_OFLD_CMD_HOSTFCMODE_V(2) |
-				   FW_EQ_OFLD_CMD_PCIECHN_V(pi->tx_chan) |
-				   FW_EQ_OFLD_CMD_FETCHRO_F |
-				   FW_EQ_OFLD_CMD_IQID_V(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_OFLD_CMD_FBMIN_V(2) |
-				  FW_EQ_OFLD_CMD_FBMAX_V(3) |
-				  FW_EQ_OFLD_CMD_CIDXFTHRESH_V(5) |
-				  FW_EQ_OFLD_CMD_EQSIZE_V(nentries));
+	c.fetchszm_to_iqid =
+		htonl(FW_EQ_OFLD_CMD_HOSTFCMODE_V(HOSTFCMODE_STATUS_PAGE_X) |
+		      FW_EQ_OFLD_CMD_PCIECHN_V(pi->tx_chan) |
+		      FW_EQ_OFLD_CMD_FETCHRO_F | FW_EQ_OFLD_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize =
+		htonl(FW_EQ_OFLD_CMD_FBMIN_V(FETCHBURSTMIN_64B_X) |
+		      FW_EQ_OFLD_CMD_FBMAX_V(FETCHBURSTMAX_512B_X) |
+		      FW_EQ_OFLD_CMD_CIDXFTHRESH_V(CIDXFLUSHTHRESH_32_X) |
+		      FW_EQ_OFLD_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -3023,7 +3038,11 @@ int t4_sge_init(struct adapter *adap)
 	 * Packing Boundary.  T5 introduced the ability to specify these
 	 * separately.  The actual Ingress Packet Data alignment boundary
 	 * within Packed Buffer Mode is the maximum of these two
-	 * specifications.
+	 * specifications.  (Note that it makes no real practical sense to
+	 * have the Pading Boudary be larger than the Packing Boundary but you
+	 * could set the chip up that way and, in fact, legacy T4 code would
+	 * end doing this because it would initialize the Padding Boundary and
+	 * leave the Packing Boundary initialized to 0 (16 bytes).)
 	 */
 	ingpadboundary = 1 << (INGPADBOUNDARY_G(sge_control) +
 			       INGPADBOUNDARY_SHIFT_X);
@@ -3069,6 +3088,9 @@ int t4_sge_init(struct adapter *adap)
 
 	t4_idma_monitor_init(adap, &s->idma_monitor);
 
+	/* Set up timers used for recuring callbacks to process RX and TX
+	 * administrative tasks.
+	 */
 	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adap);
 	setup_timer(&s->tx_timer, sge_tx_timer_cb, (unsigned long)adap);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 380b15c..88067d9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -152,17 +152,33 @@ struct rsp_ctrl {
 	};
 };
 
-#define RSPD_NEWBUF 0x80000000U
-#define RSPD_LEN(x) (((x) >> 0) & 0x7fffffffU)
-#define RSPD_QID(x) RSPD_LEN(x)
+#define RSPD_NEWBUF_S    31
+#define RSPD_NEWBUF_V(x) ((x) << RSPD_NEWBUF_S)
+#define RSPD_NEWBUF_F    RSPD_NEWBUF_V(1U)
 
-#define RSPD_GEN(x)  ((x) >> 7)
-#define RSPD_TYPE(x) (((x) >> 4) & 3)
+#define RSPD_LEN_S    0
+#define RSPD_LEN_M    0x7fffffff
+#define RSPD_LEN_G(x) (((x) >> RSPD_LEN_S) & RSPD_LEN_M)
 
-#define V_QINTR_CNT_EN	   0x0
-#define QINTR_CNT_EN       0x1
-#define QINTR_TIMER_IDX(x) ((x) << 1)
-#define QINTR_TIMER_IDX_GET(x) (((x) >> 1) & 0x7)
+#define RSPD_QID_S    RSPD_LEN_S
+#define RSPD_QID_M    RSPD_LEN_M
+#define RSPD_QID_G(x) RSPD_LEN_G(x)
+
+#define RSPD_GEN_S    7
+
+#define RSPD_TYPE_S    4
+#define RSPD_TYPE_M    0x3
+#define RSPD_TYPE_G(x) (((x) >> RSPD_TYPE_S) & RSPD_TYPE_M)
+
+/* Rx queue interrupt deferral fields: counter enable and timer index */
+#define QINTR_CNT_EN_S    0
+#define QINTR_CNT_EN_V(x) ((x) << QINTR_CNT_EN_S)
+#define QINTR_CNT_EN_F    QINTR_CNT_EN_V(1U)
+
+#define QINTR_TIMER_IDX_S    1
+#define QINTR_TIMER_IDX_M    0x7
+#define QINTR_TIMER_IDX_V(x) ((x) << QINTR_TIMER_IDX_S)
+#define QINTR_TIMER_IDX_G(x) (((x) >> QINTR_TIMER_IDX_S) & QINTR_TIMER_IDX_M)
 
 /*
  * Flash layout.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 30a2f56..d90f8a0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -634,26 +634,9 @@ struct cpl_tid_release {
 
 struct cpl_tx_pkt_core {
 	__be32 ctrl0;
-#define TXPKT_VF(x)        ((x) << 0)
-#define TXPKT_PF(x)        ((x) << 8)
-#define TXPKT_VF_VLD       (1 << 11)
-#define TXPKT_OVLAN_IDX(x) ((x) << 12)
-#define TXPKT_INTF(x)      ((x) << 16)
-#define TXPKT_INS_OVLAN    (1 << 21)
-#define TXPKT_OPCODE(x)    ((x) << 24)
 	__be16 pack;
 	__be16 len;
 	__be64 ctrl1;
-#define TXPKT_CSUM_END(x)   ((x) << 12)
-#define TXPKT_CSUM_START(x) ((x) << 20)
-#define TXPKT_IPHDR_LEN(x)  ((u64)(x) << 20)
-#define TXPKT_CSUM_LOC(x)   ((u64)(x) << 30)
-#define TXPKT_ETHHDR_LEN(x) ((u64)(x) << 34)
-#define TXPKT_CSUM_TYPE(x)  ((u64)(x) << 40)
-#define TXPKT_VLAN(x)       ((u64)(x) << 44)
-#define TXPKT_VLAN_VLD      (1ULL << 60)
-#define TXPKT_IPCSUM_DIS    (1ULL << 62)
-#define TXPKT_L4CSUM_DIS    (1ULL << 63)
 };
 
 struct cpl_tx_pkt {
@@ -663,16 +646,66 @@ struct cpl_tx_pkt {
 
 #define cpl_tx_pkt_xt cpl_tx_pkt
 
+/* cpl_tx_pkt_core.ctrl0 fields */
+#define TXPKT_VF_S    0
+#define TXPKT_VF_V(x) ((x) << TXPKT_VF_S)
+
+#define TXPKT_PF_S    8
+#define TXPKT_PF_V(x) ((x) << TXPKT_PF_S)
+
+#define TXPKT_VF_VLD_S    11
+#define TXPKT_VF_VLD_V(x) ((x) << TXPKT_VF_VLD_S)
+#define TXPKT_VF_VLD_F    TXPKT_VF_VLD_V(1U)
+
+#define TXPKT_OVLAN_IDX_S    12
+#define TXPKT_OVLAN_IDX_V(x) ((x) << TXPKT_OVLAN_IDX_S)
+
+#define TXPKT_INTF_S    16
+#define TXPKT_INTF_V(x) ((x) << TXPKT_INTF_S)
+
+#define TXPKT_INS_OVLAN_S    21
+#define TXPKT_INS_OVLAN_V(x) ((x) << TXPKT_INS_OVLAN_S)
+#define TXPKT_INS_OVLAN_F    TXPKT_INS_OVLAN_V(1U)
+
+#define TXPKT_OPCODE_S    24
+#define TXPKT_OPCODE_V(x) ((x) << TXPKT_OPCODE_S)
+
+/* cpl_tx_pkt_core.ctrl1 fields */
+#define TXPKT_CSUM_END_S    12
+#define TXPKT_CSUM_END_V(x) ((x) << TXPKT_CSUM_END_S)
+
+#define TXPKT_CSUM_START_S    20
+#define TXPKT_CSUM_START_V(x) ((x) << TXPKT_CSUM_START_S)
+
+#define TXPKT_IPHDR_LEN_S    20
+#define TXPKT_IPHDR_LEN_V(x) ((__u64)(x) << TXPKT_IPHDR_LEN_S)
+
+#define TXPKT_CSUM_LOC_S    30
+#define TXPKT_CSUM_LOC_V(x) ((__u64)(x) << TXPKT_CSUM_LOC_S)
+
+#define TXPKT_ETHHDR_LEN_S    34
+#define TXPKT_ETHHDR_LEN_V(x) ((__u64)(x) << TXPKT_ETHHDR_LEN_S)
+
+#define TXPKT_CSUM_TYPE_S    40
+#define TXPKT_CSUM_TYPE_V(x) ((__u64)(x) << TXPKT_CSUM_TYPE_S)
+
+#define TXPKT_VLAN_S    44
+#define TXPKT_VLAN_V(x) ((__u64)(x) << TXPKT_VLAN_S)
+
+#define TXPKT_VLAN_VLD_S    60
+#define TXPKT_VLAN_VLD_V(x) ((__u64)(x) << TXPKT_VLAN_VLD_S)
+#define TXPKT_VLAN_VLD_F    TXPKT_VLAN_VLD_V(1ULL)
+
+#define TXPKT_IPCSUM_DIS_S    62
+#define TXPKT_IPCSUM_DIS_V(x) ((__u64)(x) << TXPKT_IPCSUM_DIS_S)
+#define TXPKT_IPCSUM_DIS_F    TXPKT_IPCSUM_DIS_V(1ULL)
+
+#define TXPKT_L4CSUM_DIS_S    63
+#define TXPKT_L4CSUM_DIS_V(x) ((__u64)(x) << TXPKT_L4CSUM_DIS_S)
+#define TXPKT_L4CSUM_DIS_F    TXPKT_L4CSUM_DIS_V(1ULL)
+
 struct cpl_tx_pkt_lso_core {
 	__be32 lso_ctrl;
-#define LSO_TCPHDR_LEN(x) ((x) << 0)
-#define LSO_IPHDR_LEN(x)  ((x) << 4)
-#define LSO_ETHHDR_LEN(x) ((x) << 16)
-#define LSO_IPV6(x)       ((x) << 20)
-#define LSO_LAST_SLICE    (1 << 22)
-#define LSO_FIRST_SLICE   (1 << 23)
-#define LSO_OPCODE(x)     ((x) << 24)
-#define LSO_T5_XFER_SIZE(x) ((x) << 0)
 	__be16 ipid_ofst;
 	__be16 mss;
 	__be32 seqno_offset;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index c4d9952..72ec1f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -61,6 +61,20 @@
 #define SGE_TIMERREGS			6
 #define TIMERREG_COUNTER0_X		0
 
+#define FETCHBURSTMIN_64B_X		2
+
+#define FETCHBURSTMAX_512B_X		3
+
+#define HOSTFCMODE_STATUS_PAGE_X	2
+
+#define CIDXFLUSHTHRESH_32_X		5
+
+#define UPDATEDELIVERY_INTERRUPT_X	1
+
+#define RSPD_TYPE_FLBUF_X		0
+#define RSPD_TYPE_CPL_X			1
+#define RSPD_TYPE_INTR_X		2
+
 /* Congestion Manager Definitions.
  */
 #define CONMCTXT_CNGTPMODE_S		19
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index d75fca7..16c6d67 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1592,6 +1592,7 @@ struct fw_eq_eth_cmd {
 
 #define FW_EQ_ETH_CMD_FETCHRO_S		22
 #define FW_EQ_ETH_CMD_FETCHRO_V(x)	((x) << FW_EQ_ETH_CMD_FETCHRO_S)
+#define FW_EQ_ETH_CMD_FETCHRO_F		FW_EQ_ETH_CMD_FETCHRO_V(1U)
 
 #define FW_EQ_ETH_CMD_HOSTFCMODE_S	20
 #define FW_EQ_ETH_CMD_HOSTFCMODE_V(x)	((x) << FW_EQ_ETH_CMD_HOSTFCMODE_S)
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 1d893b0..b2b5e5b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1021,7 +1021,7 @@ static int closest_thres(const struct sge *s, int thres)
 static unsigned int qtimer_val(const struct adapter *adapter,
 			       const struct sge_rspq *rspq)
 {
-	unsigned int timer_idx = QINTR_TIMER_IDX_GET(rspq->intr_params);
+	unsigned int timer_idx = QINTR_TIMER_IDX_G(rspq->intr_params);
 
 	return timer_idx < SGE_NTIMERS
 		? adapter->sge.timer_val[timer_idx]
@@ -1086,8 +1086,8 @@ static int set_rxq_intr_params(struct adapter *adapter, struct sge_rspq *rspq,
 	 * Update the response queue's interrupt coalescing parameters and
 	 * return success.
 	 */
-	rspq->intr_params = (QINTR_TIMER_IDX(timer_idx) |
-			     (cnt > 0 ? QINTR_CNT_EN : 0));
+	rspq->intr_params = (QINTR_TIMER_IDX_V(timer_idx) |
+			     QINTR_CNT_EN_V(cnt > 0));
 	return 0;
 }
 
@@ -1439,7 +1439,7 @@ static int cxgb4vf_get_coalesce(struct net_device *dev,
 
 	coalesce->rx_coalesce_usecs = qtimer_val(adapter, rspq);
 	coalesce->rx_max_coalesced_frames =
-		((rspq->intr_params & QINTR_CNT_EN)
+		((rspq->intr_params & QINTR_CNT_EN_F)
 		 ? adapter->sge.counter_val[rspq->pktcnt_idx]
 		 : 0);
 	return 0;
@@ -2393,8 +2393,9 @@ static inline void init_rspq(struct sge_rspq *rspq, u8 timer_idx,
 			     u8 pkt_cnt_idx, unsigned int size,
 			     unsigned int iqe_size)
 {
-	rspq->intr_params = (QINTR_TIMER_IDX(timer_idx) |
-			     (pkt_cnt_idx < SGE_NCOUNTERS ? QINTR_CNT_EN : 0));
+	rspq->intr_params = (QINTR_TIMER_IDX_V(timer_idx) |
+			     (pkt_cnt_idx < SGE_NCOUNTERS ?
+			      QINTR_CNT_EN_F : 0));
 	rspq->pktcnt_idx = (pkt_cnt_idx < SGE_NCOUNTERS
 			    ? pkt_cnt_idx
 			    : 0);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 98cd47c..2e41d15 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1100,7 +1100,7 @@ nocsum:
 			 * unknown protocol, disable HW csum
 			 * and hope a bad packet is detected
 			 */
-			return TXPKT_L4CSUM_DIS;
+			return TXPKT_L4CSUM_DIS_F;
 		}
 	} else {
 		/*
@@ -1117,15 +1117,15 @@ nocsum:
 	}
 
 	if (likely(csum_type >= TX_CSUM_TCPIP))
-		return TXPKT_CSUM_TYPE(csum_type) |
-			TXPKT_IPHDR_LEN(skb_network_header_len(skb)) |
-			TXPKT_ETHHDR_LEN(skb_network_offset(skb) - ETH_HLEN);
+		return TXPKT_CSUM_TYPE_V(csum_type) |
+			TXPKT_IPHDR_LEN_V(skb_network_header_len(skb)) |
+			TXPKT_ETHHDR_LEN_V(skb_network_offset(skb) - ETH_HLEN);
 	else {
 		int start = skb_transport_offset(skb);
 
-		return TXPKT_CSUM_TYPE(csum_type) |
-			TXPKT_CSUM_START(start) |
-			TXPKT_CSUM_LOC(start + skb->csum_offset);
+		return TXPKT_CSUM_TYPE_V(csum_type) |
+			TXPKT_CSUM_START_V(start) |
+			TXPKT_CSUM_LOC_V(start + skb->csum_offset);
 	}
 }
 
@@ -1288,29 +1288,30 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * Fill in the LSO CPL message.
 		 */
 		lso->lso_ctrl =
-			cpu_to_be32(LSO_OPCODE(CPL_TX_PKT_LSO) |
-				    LSO_FIRST_SLICE |
-				    LSO_LAST_SLICE |
-				    LSO_IPV6(v6) |
-				    LSO_ETHHDR_LEN(eth_xtra_len/4) |
-				    LSO_IPHDR_LEN(l3hdr_len/4) |
-				    LSO_TCPHDR_LEN(tcp_hdr(skb)->doff));
+			cpu_to_be32(LSO_OPCODE_V(CPL_TX_PKT_LSO) |
+				    LSO_FIRST_SLICE_F |
+				    LSO_LAST_SLICE_F |
+				    LSO_IPV6_V(v6) |
+				    LSO_ETHHDR_LEN_V(eth_xtra_len / 4) |
+				    LSO_IPHDR_LEN_V(l3hdr_len / 4) |
+				    LSO_TCPHDR_LEN_V(tcp_hdr(skb)->doff));
 		lso->ipid_ofst = cpu_to_be16(0);
 		lso->mss = cpu_to_be16(ssi->gso_size);
 		lso->seqno_offset = cpu_to_be32(0);
 		if (is_t4(adapter->params.chip))
 			lso->len = cpu_to_be32(skb->len);
 		else
-			lso->len = cpu_to_be32(LSO_T5_XFER_SIZE(skb->len));
+			lso->len = cpu_to_be32(LSO_T5_XFER_SIZE_V(skb->len));
 
 		/*
 		 * Set up TX Packet CPL pointer, control word and perform
 		 * accounting.
 		 */
 		cpl = (void *)(lso + 1);
-		cntrl = (TXPKT_CSUM_TYPE(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
-			 TXPKT_IPHDR_LEN(l3hdr_len) |
-			 TXPKT_ETHHDR_LEN(eth_xtra_len));
+		cntrl = (TXPKT_CSUM_TYPE_V(v6 ?
+					   TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
+			 TXPKT_IPHDR_LEN_V(l3hdr_len) |
+			 TXPKT_ETHHDR_LEN_V(eth_xtra_len));
 		txq->tso++;
 		txq->tx_cso += ssi->gso_segs;
 	} else {
@@ -1327,10 +1328,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS;
+			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS_F;
 			txq->tx_cso++;
 		} else
-			cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
+			cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
 	}
 
 	/*
@@ -1339,15 +1340,15 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (skb_vlan_tag_present(skb)) {
 		txq->vlan_ins++;
-		cntrl |= TXPKT_VLAN_VLD | TXPKT_VLAN(skb_vlan_tag_get(skb));
+		cntrl |= TXPKT_VLAN_VLD_F | TXPKT_VLAN_V(skb_vlan_tag_get(skb));
 	}
 
 	/*
 	 * Fill in the TX Packet CPL message header.
 	 */
-	cpl->ctrl0 = cpu_to_be32(TXPKT_OPCODE(CPL_TX_PKT_XT) |
-				 TXPKT_INTF(pi->port_id) |
-				 TXPKT_PF(0));
+	cpl->ctrl0 = cpu_to_be32(TXPKT_OPCODE_V(CPL_TX_PKT_XT) |
+				 TXPKT_INTF_V(pi->port_id) |
+				 TXPKT_PF_V(0));
 	cpl->pack = cpu_to_be16(0);
 	cpl->len = cpu_to_be16(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
@@ -1670,7 +1671,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 static inline bool is_new_response(const struct rsp_ctrl *rc,
 				   const struct sge_rspq *rspq)
 {
-	return RSPD_GEN(rc->type_gen) == rspq->gen;
+	return ((rc->type_gen >> RSPD_GEN_S) & 0x1) == rspq->gen;
 }
 
 /**
@@ -1759,8 +1760,8 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 		 * SGE.
 		 */
 		dma_rmb();
-		rsp_type = RSPD_TYPE(rc->type_gen);
-		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
+		rsp_type = RSPD_TYPE_G(rc->type_gen);
+		if (likely(rsp_type == RSPD_TYPE_FLBUF_X)) {
 			struct page_frag *fp;
 			struct pkt_gl gl;
 			const struct rx_sw_desc *sdesc;
@@ -1771,7 +1772,7 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 			 * If we get a "new buffer" message from the SGE we
 			 * need to move on to the next Free List buffer.
 			 */
-			if (len & RSPD_NEWBUF) {
+			if (len & RSPD_NEWBUF_F) {
 				/*
 				 * We get one "new buffer" message when we
 				 * first start up a queue so we need to ignore
@@ -1782,7 +1783,7 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 						     1);
 					rspq->offset = 0;
 				}
-				len = RSPD_LEN(len);
+				len = RSPD_LEN_G(len);
 			}
 			gl.tot_len = len;
 
@@ -1825,10 +1826,10 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 				rspq->offset += ALIGN(fp->size, s->fl_align);
 			else
 				restore_rx_bufs(&gl, &rxq->fl, frag);
-		} else if (likely(rsp_type == RSP_TYPE_CPL)) {
+		} else if (likely(rsp_type == RSPD_TYPE_CPL_X)) {
 			ret = rspq->handler(rspq, rspq->cur_desc, NULL);
 		} else {
-			WARN_ON(rsp_type > RSP_TYPE_CPL);
+			WARN_ON(rsp_type > RSPD_TYPE_CPL_X);
 			ret = 0;
 		}
 
@@ -1840,7 +1841,7 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 			 */
 			const int NOMEM_TIMER_IDX = SGE_NTIMERS-1;
 			rspq->next_intr_params =
-				QINTR_TIMER_IDX(NOMEM_TIMER_IDX);
+				QINTR_TIMER_IDX_V(NOMEM_TIMER_IDX);
 			break;
 		}
 
@@ -1882,7 +1883,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		intr_params = rspq->next_intr_params;
 		rspq->next_intr_params = rspq->intr_params;
 	} else
-		intr_params = QINTR_TIMER_IDX(SGE_TIMER_UPD_CIDX);
+		intr_params = QINTR_TIMER_IDX_V(SGE_TIMER_UPD_CIDX);
 
 	if (unlikely(work_done == 0))
 		rspq->unhandled_irqs++;
@@ -1943,10 +1944,10 @@ static unsigned int process_intrq(struct adapter *adapter)
 		 * never happen ...
 		 */
 		dma_rmb();
-		if (unlikely(RSPD_TYPE(rc->type_gen) != RSP_TYPE_INTR)) {
+		if (unlikely(RSPD_TYPE_G(rc->type_gen) != RSPD_TYPE_INTR_X)) {
 			dev_err(adapter->pdev_dev,
 				"Unexpected INTRQ response type %d\n",
-				RSPD_TYPE(rc->type_gen));
+				RSPD_TYPE_G(rc->type_gen));
 			continue;
 		}
 
@@ -1958,7 +1959,7 @@ static unsigned int process_intrq(struct adapter *adapter)
 		 * want to either make them fatal and/or conditionalized under
 		 * DEBUG.
 		 */
-		qid = RSPD_QID(be32_to_cpu(rc->pldbuflen_qid));
+		qid = RSPD_QID_G(be32_to_cpu(rc->pldbuflen_qid));
 		iq_idx = IQ_IDX(s, qid);
 		if (unlikely(iq_idx >= MAX_INGQ)) {
 			dev_err(adapter->pdev_dev,
-- 
2.3.4
