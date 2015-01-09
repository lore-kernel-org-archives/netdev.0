From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 2/2] iw_cxgb4/cxgb4/cxgb4vf/cxgb4i/csiostor: Cleanup register defines/macros related to all other cpl messages
Date: Thu,  8 Jan 2015 21:38:16 -0800
Message-ID: <1420781896-25337-3-git-send-email-anish@chelsio.com>
References: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, hch@infradead.org,
	jbottomley@parallels.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, kxie@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15278 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754031AbbAIFje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 00:39:34 -0500
In-Reply-To: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>

This patch cleanups all other macros/register define related to
CPL messages that are defined in t4_msg.h and the affected files

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                   |  20 +--
 drivers/infiniband/hw/cxgb4/mem.c                  |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |   9 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        | 199 +++++++++++++++------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   6 +-
 drivers/scsi/csiostor/csio_lnode.c                 |   2 +-
 drivers/scsi/csiostor/csio_scsi.c                  |   4 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |   6 +-
 11 files changed, 173 insertions(+), 89 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 87872795c94f..694e03075b4b 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -3501,19 +3501,19 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 	req = (struct cpl_pass_accept_req *)__skb_push(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
 	req->l2info = cpu_to_be16(V_SYN_INTF(intf) |
-			 V_SYN_MAC_IDX(G_RX_MACIDX(
+			 V_SYN_MAC_IDX(RX_MACIDX_G(
 			 (__force int) htonl(l2info))) |
 			 F_SYN_XACT_MATCH);
 	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
-			    G_RX_ETHHDR_LEN((__force int) htonl(l2info)) :
-			    G_RX_T5_ETHHDR_LEN((__force int) htonl(l2info));
-	req->hdr_len = cpu_to_be32(V_SYN_RX_CHAN(G_RX_CHAN(
+			    RX_ETHHDR_LEN_G((__force int)htonl(l2info)) :
+			    RX_T5_ETHHDR_LEN_G((__force int)htonl(l2info));
+	req->hdr_len = cpu_to_be32(V_SYN_RX_CHAN(RX_CHAN_G(
 					(__force int) htonl(l2info))) |
-				   V_TCP_HDR_LEN(G_RX_TCPHDR_LEN(
+				   V_TCP_HDR_LEN(RX_TCPHDR_LEN_G(
 					(__force int) htons(hdr_len))) |
-				   V_IP_HDR_LEN(G_RX_IPHDR_LEN(
+				   V_IP_HDR_LEN(RX_IPHDR_LEN_G(
 					(__force int) htons(hdr_len))) |
-				   V_ETH_HDR_LEN(G_RX_ETHHDR_LEN(eth_hdr_len)));
+				   V_ETH_HDR_LEN(RX_ETHHDR_LEN_G(eth_hdr_len)));
 	req->vlan = (__force __be16) vlantag;
 	req->len = (__force __be16) len;
 	req->tos_stid = cpu_to_be32(PASS_OPEN_TID_V(stid) |
@@ -3613,7 +3613,7 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	struct neighbour *neigh;
 
 	/* Drop all non-SYN packets */
-	if (!(cpl->l2info & cpu_to_be32(F_RXF_SYN)))
+	if (!(cpl->l2info & cpu_to_be32(RXF_SYN_F)))
 		goto reject;
 
 	/*
@@ -3635,8 +3635,8 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	}
 
 	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
-			    G_RX_ETHHDR_LEN(htonl(cpl->l2info)) :
-			    G_RX_T5_ETHHDR_LEN(htonl(cpl->l2info));
+			    RX_ETHHDR_LEN_G(htonl(cpl->l2info)) :
+			    RX_T5_ETHHDR_LEN_G(htonl(cpl->l2info));
 	if (eth_hdr_len == ETH_HLEN) {
 		eh = (struct ethhdr *)(req + 1);
 		iph = (struct iphdr *)(eh + 1);
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index cb43c2299ac0..b9dc9fc6be66 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -86,14 +86,14 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 	req->wr.wr_lo = wait ? (__force __be64)(unsigned long) &wr_wait : 0L;
 	req->wr.wr_mid = cpu_to_be32(FW_WR_LEN16_V(DIV_ROUND_UP(wr_len, 16)));
 	req->cmd = cpu_to_be32(ULPTX_CMD_V(ULP_TX_MEM_WRITE));
-	req->cmd |= cpu_to_be32(V_T5_ULP_MEMIO_ORDER(1));
+	req->cmd |= cpu_to_be32(T5_ULP_MEMIO_ORDER_V(1));
 	req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN_V(len>>5));
 	req->len16 = cpu_to_be32(DIV_ROUND_UP(wr_len-sizeof(req->wr), 16));
 	req->lock_addr = cpu_to_be32(ULP_MEMIO_ADDR_V(addr));
 
 	sgl = (struct ulptx_sgl *)(req + 1);
 	sgl->cmd_nsge = cpu_to_be32(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
-				    ULPTX_NSGE(1));
+				    ULPTX_NSGE_V(1));
 	sgl->len0 = cpu_to_be32(len);
 	sgl->addr0 = cpu_to_be64(data);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2897f956bb21..23ae0b7a9019 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -672,7 +672,7 @@ static void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
 	if (idx >= adap->tids.ftid_base && nidx <
 	   (adap->tids.nftids + adap->tids.nsftids)) {
 		idx = nidx;
-		ret = GET_TCB_COOKIE(rpl->cookie);
+		ret = TCB_COOKIE_G(rpl->cookie);
 		f = &adap->tids.ftid_tab[idx];
 
 		if (ret == FW_FILTER_WR_FLT_DELETED) {
@@ -724,7 +724,7 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	if (likely(opcode == CPL_SGE_EGR_UPDATE)) {
 		const struct cpl_sge_egr_update *p = (void *)rsp;
-		unsigned int qid = EGR_QID(ntohl(p->opcode_qid));
+		unsigned int qid = EGR_QID_G(ntohl(p->opcode_qid));
 		struct sge_txq *txq;
 
 		txq = q->adap->sge.egr_map[qid - q->adap->sge.egr_start];
@@ -3483,8 +3483,8 @@ int cxgb4_remove_server(const struct net_device *dev, unsigned int stid,
 	req = (struct cpl_close_listsvr_req *)__skb_put(skb, sizeof(*req));
 	INIT_TP_WR(req, 0);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, stid));
-	req->reply_ctrl = htons(NO_REPLY(0) | (ipv6 ? LISTSVR_IPV6(1) :
-				LISTSVR_IPV6(0)) | QUEUENO(queue));
+	req->reply_ctrl = htons(NO_REPLY_V(0) | (ipv6 ? LISTSVR_IPV6_V(1) :
+				LISTSVR_IPV6_V(0)) | QUEUENO_V(queue));
 	ret = t4_mgmt_tx(adap, skb);
 	return net_xmit_eval(ret);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index dea984bbdb99..252efc29321f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -152,7 +152,7 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
 					e->idx | (sync ? F_SYNC_WR : 0) |
 					TID_QID_V(adap->sge.fw_evtq.abs_id)));
-	req->params = htons(L2T_W_PORT(e->lport) | L2T_W_NOREPLY(!sync));
+	req->params = htons(L2T_W_PORT_V(e->lport) | L2T_W_NOREPLY_V(!sync));
 	req->l2t_idx = htons(e->idx);
 	req->vlan = htons(e->vlan);
 	if (e->neigh && !(e->neigh->dev->flags & IFF_LOOPBACK))
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index d7c301c77060..a79fa6a0f5c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -821,7 +821,8 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		sgl->addr0 = cpu_to_be64(addr[1]);
 	}
 
-	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) | ULPTX_NSGE(nfrags));
+	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
+			      ULPTX_NSGE_V(nfrags));
 	if (likely(--nfrags == 0))
 		return;
 	/*
@@ -1761,7 +1762,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	pkt = (const struct cpl_rx_pkt *)rsp;
 	csum_ok = pkt->csum_calc && !pkt->err_vec &&
 		  (q->netdev->features & NETIF_F_RXCSUM);
-	if ((pkt->l2info & htonl(RXF_TCP)) &&
+	if ((pkt->l2info & htonl(RXF_TCP_F)) &&
 	    (q->netdev->features & NETIF_F_GRO) && csum_ok && !pkt->ip_frag) {
 		do_gro(rxq, si, pkt);
 		return 0;
@@ -1783,11 +1784,11 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	rxq->stats.pkts++;
 
-	if (csum_ok && (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
+	if (csum_ok && (pkt->l2info & htonl(RXF_UDP_F | RXF_TCP_F))) {
 		if (!pkt->ip_frag) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			rxq->stats.rx_cso++;
-		} else if (pkt->l2info & htonl(RXF_IP)) {
+		} else if (pkt->l2info & htonl(RXF_IP_F)) {
 			__sum16 c = (__force __sum16)pkt->csum;
 			skb->csum = csum_unfold(c);
 			skb->ip_summed = CHECKSUM_COMPLETE;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 15e72063fc95..0fb975e258b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -518,24 +518,39 @@ struct cpl_get_tcb {
 	WR_HDR;
 	union opcode_tid ot;
 	__be16 reply_ctrl;
-#define QUEUENO(x)    ((x) << 0)
-#define REPLY_CHAN(x) ((x) << 14)
-#define NO_REPLY(x)   ((x) << 15)
 	__be16 cookie;
 };
 
+/* cpl_get_tcb.reply_ctrl fields */
+#define QUEUENO_S    0
+#define QUEUENO_V(x) ((x) << QUEUENO_S)
+
+#define REPLY_CHAN_S    14
+#define REPLY_CHAN_V(x) ((x) << REPLY_CHAN_S)
+#define REPLY_CHAN_F    REPLY_CHAN_V(1U)
+
+#define NO_REPLY_S    15
+#define NO_REPLY_V(x) ((x) << NO_REPLY_S)
+#define NO_REPLY_F    NO_REPLY_V(1U)
+
 struct cpl_set_tcb_field {
 	WR_HDR;
 	union opcode_tid ot;
 	__be16 reply_ctrl;
 	__be16 word_cookie;
-#define TCB_WORD(x)   ((x) << 0)
-#define TCB_COOKIE(x) ((x) << 5)
-#define GET_TCB_COOKIE(x) (((x) >> 5) & 7)
 	__be64 mask;
 	__be64 val;
 };
 
+/* cpl_set_tcb_field.word_cookie fields */
+#define TCB_WORD_S    0
+#define TCB_WORD(x)   ((x) << TCB_WORD_S)
+
+#define TCB_COOKIE_S    5
+#define TCB_COOKIE_M    0x7
+#define TCB_COOKIE_V(x) ((x) << TCB_COOKIE_S)
+#define TCB_COOKIE_G(x) (((x) >> TCB_COOKIE_S) & TCB_COOKIE_M)
+
 struct cpl_set_tcb_rpl {
 	union opcode_tid ot;
 	__be16 rsvd;
@@ -562,10 +577,14 @@ struct cpl_close_listsvr_req {
 	WR_HDR;
 	union opcode_tid ot;
 	__be16 reply_ctrl;
-#define LISTSVR_IPV6(x) ((x) << 14)
 	__be16 rsvd;
 };
 
+/* additional cpl_close_listsvr_req.reply_ctrl field */
+#define LISTSVR_IPV6_S    14
+#define LISTSVR_IPV6_V(x) ((x) << LISTSVR_IPV6_S)
+#define LISTSVR_IPV6_F    LISTSVR_IPV6_V(1U)
+
 struct cpl_close_listsvr_rpl {
 	union opcode_tid ot;
 	u8 rsvd[3];
@@ -661,6 +680,34 @@ struct cpl_tx_pkt_lso_core {
 	/* encapsulated CPL (TX_PKT, TX_PKT_XT or TX_DATA) follows here */
 };
 
+/* cpl_tx_pkt_lso_core.lso_ctrl fields */
+#define LSO_TCPHDR_LEN_S    0
+#define LSO_TCPHDR_LEN_V(x) ((x) << LSO_TCPHDR_LEN_S)
+
+#define LSO_IPHDR_LEN_S    4
+#define LSO_IPHDR_LEN_V(x) ((x) << LSO_IPHDR_LEN_S)
+
+#define LSO_ETHHDR_LEN_S    16
+#define LSO_ETHHDR_LEN_V(x) ((x) << LSO_ETHHDR_LEN_S)
+
+#define LSO_IPV6_S    20
+#define LSO_IPV6_V(x) ((x) << LSO_IPV6_S)
+#define LSO_IPV6_F    LSO_IPV6_V(1U)
+
+#define LSO_LAST_SLICE_S    22
+#define LSO_LAST_SLICE_V(x) ((x) << LSO_LAST_SLICE_S)
+#define LSO_LAST_SLICE_F    LSO_LAST_SLICE_V(1U)
+
+#define LSO_FIRST_SLICE_S    23
+#define LSO_FIRST_SLICE_V(x) ((x) << LSO_FIRST_SLICE_S)
+#define LSO_FIRST_SLICE_F    LSO_FIRST_SLICE_V(1U)
+
+#define LSO_OPCODE_S    24
+#define LSO_OPCODE_V(x) ((x) << LSO_OPCODE_S)
+
+#define LSO_T5_XFER_SIZE_S	   0
+#define LSO_T5_XFER_SIZE_V(x) ((x) << LSO_T5_XFER_SIZE_S)
+
 struct cpl_tx_pkt_lso {
 	WR_HDR;
 	struct cpl_tx_pkt_lso_core c;
@@ -670,8 +717,6 @@ struct cpl_tx_pkt_lso {
 struct cpl_iscsi_hdr {
 	union opcode_tid ot;
 	__be16 pdu_len_ddp;
-#define ISCSI_PDU_LEN(x) ((x) & 0x7FFF)
-#define ISCSI_DDP        (1 << 15)
 	__be16 len;
 	__be32 seq;
 	__be16 urg;
@@ -679,6 +724,16 @@ struct cpl_iscsi_hdr {
 	u8 status;
 };
 
+/* cpl_iscsi_hdr.pdu_len_ddp fields */
+#define ISCSI_PDU_LEN_S    0
+#define ISCSI_PDU_LEN_M    0x7FFF
+#define ISCSI_PDU_LEN_V(x) ((x) << ISCSI_PDU_LEN_S)
+#define ISCSI_PDU_LEN_G(x) (((x) >> ISCSI_PDU_LEN_S) & ISCSI_PDU_LEN_M)
+
+#define ISCSI_DDP_S    15
+#define ISCSI_DDP_V(x) ((x) << ISCSI_DDP_S)
+#define ISCSI_DDP_F    ISCSI_DDP_V(1U)
+
 struct cpl_rx_data {
 	union opcode_tid ot;
 	__be16 rsvd;
@@ -735,49 +790,61 @@ struct cpl_rx_pkt {
 	__be16 vlan;
 	__be16 len;
 	__be32 l2info;
-#define RXF_UDP (1 << 22)
-#define RXF_TCP (1 << 23)
-#define RXF_IP  (1 << 24)
-#define RXF_IP6 (1 << 25)
 	__be16 hdr_len;
 	__be16 err_vec;
 };
 
+#define RXF_UDP_S    22
+#define RXF_UDP_V(x) ((x) << RXF_UDP_S)
+#define RXF_UDP_F    RXF_UDP_V(1U)
+
+#define RXF_TCP_S    23
+#define RXF_TCP_V(x) ((x) << RXF_TCP_S)
+#define RXF_TCP_F    RXF_TCP_V(1U)
+
+#define RXF_IP_S    24
+#define RXF_IP_V(x) ((x) << RXF_IP_S)
+#define RXF_IP_F    RXF_IP_V(1U)
+
+#define RXF_IP6_S    25
+#define RXF_IP6_V(x) ((x) << RXF_IP6_S)
+#define RXF_IP6_F    RXF_IP6_V(1U)
+
 /* rx_pkt.l2info fields */
-#define S_RX_ETHHDR_LEN    0
-#define M_RX_ETHHDR_LEN    0x1F
-#define V_RX_ETHHDR_LEN(x) ((x) << S_RX_ETHHDR_LEN)
-#define G_RX_ETHHDR_LEN(x) (((x) >> S_RX_ETHHDR_LEN) & M_RX_ETHHDR_LEN)
-
-#define S_RX_T5_ETHHDR_LEN    0
-#define M_RX_T5_ETHHDR_LEN    0x3F
-#define V_RX_T5_ETHHDR_LEN(x) ((x) << S_RX_T5_ETHHDR_LEN)
-#define G_RX_T5_ETHHDR_LEN(x) (((x) >> S_RX_T5_ETHHDR_LEN) & M_RX_T5_ETHHDR_LEN)
-
-#define S_RX_MACIDX    8
-#define M_RX_MACIDX    0x1FF
-#define V_RX_MACIDX(x) ((x) << S_RX_MACIDX)
-#define G_RX_MACIDX(x) (((x) >> S_RX_MACIDX) & M_RX_MACIDX)
-
-#define S_RXF_SYN    21
-#define V_RXF_SYN(x) ((x) << S_RXF_SYN)
-#define F_RXF_SYN    V_RXF_SYN(1U)
-
-#define S_RX_CHAN    28
-#define M_RX_CHAN    0xF
-#define V_RX_CHAN(x) ((x) << S_RX_CHAN)
-#define G_RX_CHAN(x) (((x) >> S_RX_CHAN) & M_RX_CHAN)
+#define RX_ETHHDR_LEN_S    0
+#define RX_ETHHDR_LEN_M    0x1F
+#define RX_ETHHDR_LEN_V(x) ((x) << RX_ETHHDR_LEN_S)
+#define RX_ETHHDR_LEN_G(x) (((x) >> RX_ETHHDR_LEN_S) & RX_ETHHDR_LEN_M)
+
+#define RX_T5_ETHHDR_LEN_S    0
+#define RX_T5_ETHHDR_LEN_M    0x3F
+#define RX_T5_ETHHDR_LEN_V(x) ((x) << RX_T5_ETHHDR_LEN_S)
+#define RX_T5_ETHHDR_LEN_G(x) (((x) >> RX_T5_ETHHDR_LEN_S) & RX_T5_ETHHDR_LEN_M)
+
+#define RX_MACIDX_S    8
+#define RX_MACIDX_M    0x1FF
+#define RX_MACIDX_V(x) ((x) << RX_MACIDX_S)
+#define RX_MACIDX_G(x) (((x) >> RX_MACIDX_S) & RX_MACIDX_M)
+
+#define RXF_SYN_S    21
+#define RXF_SYN_V(x) ((x) << RXF_SYN_S)
+#define RXF_SYN_F    RXF_SYN_V(1U)
+
+#define RX_CHAN_S    28
+#define RX_CHAN_M    0xF
+#define RX_CHAN_V(x) ((x) << RX_CHAN_S)
+#define RX_CHAN_G(x) (((x) >> RX_CHAN_S) & RX_CHAN_M)
 
 /* rx_pkt.hdr_len fields */
-#define S_RX_TCPHDR_LEN    0
-#define M_RX_TCPHDR_LEN    0x3F
-#define V_RX_TCPHDR_LEN(x) ((x) << S_RX_TCPHDR_LEN)
-#define G_RX_TCPHDR_LEN(x) (((x) >> S_RX_TCPHDR_LEN) & M_RX_TCPHDR_LEN)
+#define RX_TCPHDR_LEN_S    0
+#define RX_TCPHDR_LEN_M    0x3F
+#define RX_TCPHDR_LEN_V(x) ((x) << RX_TCPHDR_LEN_S)
+#define RX_TCPHDR_LEN_G(x) (((x) >> RX_TCPHDR_LEN_S) & RX_TCPHDR_LEN_M)
 
-#define S_RX_IPHDR_LEN    6
-#define M_RX_IPHDR_LEN    0x3FF
-#define V_RX_IPHDR_LEN(x) ((x) << S_RX_IPHDR_LEN)
-#define G_RX_IPHDR_LEN(x) (((x) >> S_RX_IPHDR_LEN) & M_RX_IPHDR_LEN)
+#define RX_IPHDR_LEN_S    6
+#define RX_IPHDR_LEN_M    0x3FF
+#define RX_IPHDR_LEN_V(x) ((x) << RX_IPHDR_LEN_S)
+#define RX_IPHDR_LEN_G(x) (((x) >> RX_IPHDR_LEN_S) & RX_IPHDR_LEN_M)
 
 struct cpl_trace_pkt {
 	u8 opcode;
@@ -826,14 +893,22 @@ struct cpl_l2t_write_req {
 	WR_HDR;
 	union opcode_tid ot;
 	__be16 params;
-#define L2T_W_INFO(x)    ((x) << 2)
-#define L2T_W_PORT(x)    ((x) << 8)
-#define L2T_W_NOREPLY(x) ((x) << 15)
 	__be16 l2t_idx;
 	__be16 vlan;
 	u8 dst_mac[6];
 };
 
+/* cpl_l2t_write_req.params fields */
+#define L2T_W_INFO_S    2
+#define L2T_W_INFO_V(x) ((x) << L2T_W_INFO_S)
+
+#define L2T_W_PORT_S    8
+#define L2T_W_PORT_V(x) ((x) << L2T_W_PORT_S)
+
+#define L2T_W_NOREPLY_S    15
+#define L2T_W_NOREPLY_V(x) ((x) << L2T_W_NOREPLY_S)
+#define L2T_W_NOREPLY_F    L2T_W_NOREPLY_V(1U)
+
 struct cpl_l2t_write_rpl {
 	union opcode_tid ot;
 	u8 status;
@@ -848,11 +923,15 @@ struct cpl_rdma_terminate {
 
 struct cpl_sge_egr_update {
 	__be32 opcode_qid;
-#define EGR_QID(x) ((x) & 0x1FFFF)
 	__be16 cidx;
 	__be16 pidx;
 };
 
+/* cpl_sge_egr_update.ot fields */
+#define EGR_QID_S    0
+#define EGR_QID_M    0x1FFFF
+#define EGR_QID_G(x) (((x) >> EGR_QID_S) & EGR_QID_M)
+
 /* cpl_fw*.type values */
 enum {
 	FW_TYPE_CMD_RPL = 0,
@@ -945,22 +1024,30 @@ struct ulptx_sge_pair {
 
 struct ulptx_sgl {
 	__be32 cmd_nsge;
-#define ULPTX_NSGE(x) ((x) << 0)
-#define ULPTX_MORE (1U << 23)
 	__be32 len0;
 	__be64 addr0;
 	struct ulptx_sge_pair sge[0];
 };
 
+#define ULPTX_NSGE_S    0
+#define ULPTX_NSGE_V(x) ((x) << ULPTX_NSGE_S)
+
+#define ULPTX_MORE_S	23
+#define ULPTX_MORE_V(x)	((x) << ULPTX_MORE_S)
+#define ULPTX_MORE_F	ULPTX_MORE_V(1U)
+
 struct ulp_mem_io {
 	WR_HDR;
 	__be32 cmd;
 	__be32 len16;             /* command length */
 	__be32 dlen;              /* data length in 32-byte units */
 	__be32 lock_addr;
-#define ULP_MEMIO_LOCK(x) ((x) << 31)
 };
 
+#define ULP_MEMIO_LOCK_S    31
+#define ULP_MEMIO_LOCK_V(x) ((x) << ULP_MEMIO_LOCK_S)
+#define ULP_MEMIO_LOCK_F    ULP_MEMIO_LOCK_V(1U)
+
 /* additional ulp_mem_io.cmd fields */
 #define ULP_MEMIO_ORDER_S    23
 #define ULP_MEMIO_ORDER_V(x) ((x) << ULP_MEMIO_ORDER_S)
@@ -970,13 +1057,9 @@ struct ulp_mem_io {
 #define T5_ULP_MEMIO_IMM_V(x) ((x) << T5_ULP_MEMIO_IMM_S)
 #define T5_ULP_MEMIO_IMM_F    T5_ULP_MEMIO_IMM_V(1U)
 
-#define S_T5_ULP_MEMIO_IMM    23
-#define V_T5_ULP_MEMIO_IMM(x) ((x) << S_T5_ULP_MEMIO_IMM)
-#define F_T5_ULP_MEMIO_IMM    V_T5_ULP_MEMIO_IMM(1U)
-
-#define S_T5_ULP_MEMIO_ORDER    22
-#define V_T5_ULP_MEMIO_ORDER(x) ((x) << S_T5_ULP_MEMIO_ORDER)
-#define F_T5_ULP_MEMIO_ORDER    V_T5_ULP_MEMIO_ORDER(1U)
+#define T5_ULP_MEMIO_ORDER_S    22
+#define T5_ULP_MEMIO_ORDER_V(x) ((x) << T5_ULP_MEMIO_ORDER_S)
+#define T5_ULP_MEMIO_ORDER_F    T5_ULP_MEMIO_ORDER_V(1U)
 
 /* ulp_mem_io.lock_addr fields */
 #define ULP_MEMIO_ADDR_S    0
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 4591d934e221..710e5e2bac9f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -471,7 +471,7 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		 * free TX Queue Descriptors ...
 		 */
 		const struct cpl_sge_egr_update *p = cpl;
-		unsigned int qid = EGR_QID(be32_to_cpu(p->opcode_qid));
+		unsigned int qid = EGR_QID_G(be32_to_cpu(p->opcode_qid));
 		struct sge *s = &adapter->sge;
 		struct sge_txq *tq;
 		struct sge_eth_txq *txq;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index ef4da3e1829b..4424277a7e4d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -926,7 +926,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 	}
 
 	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
-			      ULPTX_NSGE(nfrags));
+			      ULPTX_NSGE_V(nfrags));
 	if (likely(--nfrags == 0))
 		return;
 	/*
@@ -1604,7 +1604,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	 * If this is a good TCP packet and we have Generic Receive Offload
 	 * enabled, handle the packet in the GRO path.
 	 */
-	if ((pkt->l2info & cpu_to_be32(RXF_TCP)) &&
+	if ((pkt->l2info & cpu_to_be32(RXF_TCP_F)) &&
 	    (rspq->netdev->features & NETIF_F_GRO) && csum_ok &&
 	    !pkt->ip_frag) {
 		do_gro(rxq, gl, pkt);
@@ -1626,7 +1626,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	rxq->stats.pkts++;
 
 	if (csum_ok && !pkt->err_vec &&
-	    (be32_to_cpu(pkt->l2info) & (RXF_UDP|RXF_TCP))) {
+	    (be32_to_cpu(pkt->l2info) & (RXF_UDP_F | RXF_TCP_F))) {
 		if (!pkt->ip_frag)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else {
diff --git a/drivers/scsi/csiostor/csio_lnode.c b/drivers/scsi/csiostor/csio_lnode.c
index 87f9280d9b43..c00b2ff72b55 100644
--- a/drivers/scsi/csiostor/csio_lnode.c
+++ b/drivers/scsi/csiostor/csio_lnode.c
@@ -1758,7 +1758,7 @@ csio_ln_mgmt_submit_wr(struct csio_mgmtm *mgmtm, struct csio_ioreq *io_req,
 	else {
 		/* Program DSGL to dma payload */
 		dsgl.cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
-					ULPTX_MORE | ULPTX_NSGE(1));
+					ULPTX_MORE_F | ULPTX_NSGE_V(1));
 		dsgl.len0 = cpu_to_be32(pld_len);
 		dsgl.addr0 = cpu_to_be64(pld->paddr);
 		csio_wr_copy_to_wrp(&dsgl, &wrp, ALIGN(wr_off, 8),
diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
index 3987284e0d2a..2c4562d82dc0 100644
--- a/drivers/scsi/csiostor/csio_scsi.c
+++ b/drivers/scsi/csiostor/csio_scsi.c
@@ -298,8 +298,8 @@ csio_scsi_init_ultptx_dsgl(struct csio_hw *hw, struct csio_ioreq *req,
 	struct csio_dma_buf *dma_buf;
 	struct scsi_cmnd *scmnd = csio_scsi_cmnd(req);
 
-	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) | ULPTX_MORE |
-				     ULPTX_NSGE(req->nsge));
+	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) | ULPTX_MORE_F |
+				     ULPTX_NSGE_V(req->nsge));
 	/* Now add the data SGLs */
 	if (likely(!req->dcopy)) {
 		scsi_for_each_sg(scmnd, sgel, req->nsge, i) {
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index c3f2b973149b..37d7191a3c38 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1112,7 +1112,7 @@ static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 		hlen = ntohs(cpl->len);
 		dlen = ntohl(*(unsigned int *)(bhs + 4)) & 0xFFFFFF;
 
-		plen = ISCSI_PDU_LEN(pdu_len_ddp);
+		plen = ISCSI_PDU_LEN_G(pdu_len_ddp);
 		if (is_t4(lldi->adapter_type))
 			plen -= 40;
 
@@ -1619,7 +1619,7 @@ static int ddp_setup_conn_pgidx(struct cxgbi_sock *csk, unsigned int tid,
 	req = (struct cpl_set_tcb_field *)skb->head;
 	INIT_TP_WR(req, csk->tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, csk->tid));
-	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
+	req->reply_ctrl = htons(NO_REPLY_V(reply) | QUEUENO_V(csk->rss_qid));
 	req->word_cookie = htons(0);
 	req->mask = cpu_to_be64(0x3 << 8);
 	req->val = cpu_to_be64(pg_idx << 8);
@@ -1651,7 +1651,7 @@ static int ddp_setup_conn_digest(struct cxgbi_sock *csk, unsigned int tid,
 	req = (struct cpl_set_tcb_field *)skb->head;
 	INIT_TP_WR(req, tid);
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
-	req->reply_ctrl = htons(NO_REPLY(reply) | QUEUENO(csk->rss_qid));
+	req->reply_ctrl = htons(NO_REPLY_V(reply) | QUEUENO_V(csk->rss_qid));
 	req->word_cookie = htons(0);
 	req->mask = cpu_to_be64(0x3 << 4);
 	req->val = cpu_to_be64(((hcrc ? ULP_CRC_HEADER : 0) |
-- 
2.2.1
