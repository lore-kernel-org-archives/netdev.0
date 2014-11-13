From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] cxgb4i/cxgb4 : Refactor macros to conform to uniform standards
Date: Wed, 12 Nov 2014 17:15:57 -0800
Message-ID: <1415841357-19700-1-git-send-email-anish@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Refactored all macros used in cxgb4i as part of previously started cxgb4 macro
names cleanup. Makes them more uniform and avoids namespace collision.
Minor changes in other drivers where required as some of these macros are used
 by multiple drivers, affected drivers are iw_cxgb4, cxgb4(vf) & csiostor

Signed-off-by: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c                | 104 ++++++++++----------
 drivers/infiniband/hw/cxgb4/mem.c               |  20 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     | 120 +++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   6 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |   2 +-
 drivers/scsi/csiostor/csio_lnode.c              |   2 +-
 drivers/scsi/csiostor/csio_scsi.c               |   2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              |  78 +++++++--------
 11 files changed, 200 insertions(+), 142 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index a07d8e124a80..83fa16fa4644 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -649,31 +649,31 @@ static int send_connect(struct c4iw_ep *ep)
 	 * remainder will be specified in the rx_data_ack.
 	 */
 	win = ep->rcv_win >> 10;
-	if (win > RCV_BUFSIZ_MASK)
-		win = RCV_BUFSIZ_MASK;
+	if (win > RCV_BUFSIZ_M)
+		win = RCV_BUFSIZ_M;
 
 	opt0 = (nocong ? NO_CONG(1) : 0) |
-	       KEEP_ALIVE(1) |
+	       KEEP_ALIVE_F |
 	       DELACK(1) |
-	       WND_SCALE(wscale) |
-	       MSS_IDX(mtu_idx) |
-	       L2T_IDX(ep->l2t->idx) |
-	       TX_CHAN(ep->tx_chan) |
-	       SMAC_SEL(ep->smac_idx) |
+	       WND_SCALE_V(wscale) |
+	       MSS_IDX_V(mtu_idx) |
+	       L2T_IDX_V(ep->l2t->idx) |
+	       TX_CHAN_V(ep->tx_chan) |
+	       SMAC_SEL_V(ep->smac_idx) |
 	       DSCP(ep->tos) |
-	       ULP_MODE(ULP_MODE_TCPDDP) |
-	       RCV_BUFSIZ(win);
-	opt2 = RX_CHANNEL(0) |
+	       ULP_MODE_V(ULP_MODE_TCPDDP) |
+	       RCV_BUFSIZ_V(win);
+	opt2 = RX_CHANNEL_V(0) |
 	       CCTRL_ECN(enable_ecn) |
-	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
+	       RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid);
 	if (enable_tcp_timestamps)
 		opt2 |= TSTAMPS_EN(1);
 	if (enable_tcp_sack)
 		opt2 |= SACK_EN(1);
 	if (wscale && enable_tcp_window_scaling)
-		opt2 |= WND_SCALE_EN(1);
+		opt2 |= WND_SCALE_EN_F;
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
-		opt2 |= T5_OPT_2_VALID;
+		opt2 |= T5_OPT_2_VALID_F;
 		opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
 		opt2 |= CONG_CNTRL_VALID; /* OPT_2_ISS for T5 */
 	}
@@ -736,7 +736,7 @@ static int send_connect(struct c4iw_ep *ep)
 			t5_req->local_ip = la->sin_addr.s_addr;
 			t5_req->peer_ip = ra->sin_addr.s_addr;
 			t5_req->opt0 = cpu_to_be64(opt0);
-			t5_req->params = cpu_to_be64(V_FILTER_TUPLE(
+			t5_req->params = cpu_to_be64(FILTER_TUPLE_V(
 						     cxgb4_select_ntuple(
 					     ep->com.dev->rdev.lldi.ports[0],
 					     ep->l2t)));
@@ -762,7 +762,7 @@ static int send_connect(struct c4iw_ep *ep)
 			t5_req6->peer_ip_lo = *((__be64 *)
 						(ra6->sin6_addr.s6_addr + 8));
 			t5_req6->opt0 = cpu_to_be64(opt0);
-			t5_req6->params = cpu_to_be64(V_FILTER_TUPLE(
+			t5_req6->params = cpu_to_be64(FILTER_TUPLE_V(
 							cxgb4_select_ntuple(
 						ep->com.dev->rdev.lldi.ports[0],
 						ep->l2t)));
@@ -1249,15 +1249,15 @@ static int update_rx_credits(struct c4iw_ep *ep, u32 credits)
 	 * due to the limit in the number of bits in the RCV_BUFSIZ field,
 	 * then add the overage in to the credits returned.
 	 */
-	if (ep->rcv_win > RCV_BUFSIZ_MASK * 1024)
-		credits += ep->rcv_win - RCV_BUFSIZ_MASK * 1024;
+	if (ep->rcv_win > RCV_BUFSIZ_M * 1024)
+		credits += ep->rcv_win - RCV_BUFSIZ_M * 1024;
 
 	req = (struct cpl_rx_data_ack *) skb_put(skb, wrlen);
 	memset(req, 0, wrlen);
 	INIT_TP_WR(req, ep->hwtid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
 						    ep->hwtid));
-	req->credit_dack = cpu_to_be32(credits | RX_FORCE_ACK(1) |
+	req->credit_dack = cpu_to_be32(credits | RX_FORCE_ACK_F |
 				       F_RX_DACK_CHANGE |
 				       V_RX_DACK_MODE(dack_mode));
 	set_wr_txq(skb, CPL_PRIORITY_ACK, ep->ctrlq_idx);
@@ -1778,34 +1778,34 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	 * remainder will be specified in the rx_data_ack.
 	 */
 	win = ep->rcv_win >> 10;
-	if (win > RCV_BUFSIZ_MASK)
-		win = RCV_BUFSIZ_MASK;
+	if (win > RCV_BUFSIZ_M)
+		win = RCV_BUFSIZ_M;
 
 	req->tcb.opt0 = (__force __be64) (TCAM_BYPASS(1) |
 		(nocong ? NO_CONG(1) : 0) |
-		KEEP_ALIVE(1) |
+		KEEP_ALIVE_F |
 		DELACK(1) |
-		WND_SCALE(wscale) |
-		MSS_IDX(mtu_idx) |
-		L2T_IDX(ep->l2t->idx) |
-		TX_CHAN(ep->tx_chan) |
-		SMAC_SEL(ep->smac_idx) |
+		WND_SCALE_V(wscale) |
+		MSS_IDX_V(mtu_idx) |
+		L2T_IDX_V(ep->l2t->idx) |
+		TX_CHAN_V(ep->tx_chan) |
+		SMAC_SEL_V(ep->smac_idx) |
 		DSCP(ep->tos) |
-		ULP_MODE(ULP_MODE_TCPDDP) |
-		RCV_BUFSIZ(win));
+		ULP_MODE_V(ULP_MODE_TCPDDP) |
+		RCV_BUFSIZ_V(win));
 	req->tcb.opt2 = (__force __be32) (PACE(1) |
 		TX_QUEUE(ep->com.dev->rdev.lldi.tx_modq[ep->tx_chan]) |
-		RX_CHANNEL(0) |
+		RX_CHANNEL_V(0) |
 		CCTRL_ECN(enable_ecn) |
-		RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid));
+		RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid));
 	if (enable_tcp_timestamps)
-		req->tcb.opt2 |= (__force __be32) TSTAMPS_EN(1);
+		req->tcb.opt2 |= (__force __be32)TSTAMPS_EN(1);
 	if (enable_tcp_sack)
-		req->tcb.opt2 |= (__force __be32) SACK_EN(1);
+		req->tcb.opt2 |= (__force __be32)SACK_EN(1);
 	if (wscale && enable_tcp_window_scaling)
-		req->tcb.opt2 |= (__force __be32) WND_SCALE_EN(1);
-	req->tcb.opt0 = cpu_to_be64((__force u64) req->tcb.opt0);
-	req->tcb.opt2 = cpu_to_be32((__force u32) req->tcb.opt2);
+		req->tcb.opt2 |= (__force __be32)WND_SCALE_EN_F;
+	req->tcb.opt0 = cpu_to_be64((__force u64)req->tcb.opt0);
+	req->tcb.opt2 = cpu_to_be32((__force u32)req->tcb.opt2);
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, ep->ctrlq_idx);
 	set_bit(ACT_OFLD_CONN, &ep->com.history);
 	c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
@@ -2178,28 +2178,28 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	 * remainder will be specified in the rx_data_ack.
 	 */
 	win = ep->rcv_win >> 10;
-	if (win > RCV_BUFSIZ_MASK)
-		win = RCV_BUFSIZ_MASK;
+	if (win > RCV_BUFSIZ_M)
+		win = RCV_BUFSIZ_M;
 	opt0 = (nocong ? NO_CONG(1) : 0) |
-	       KEEP_ALIVE(1) |
+	       KEEP_ALIVE_F |
 	       DELACK(1) |
-	       WND_SCALE(wscale) |
-	       MSS_IDX(mtu_idx) |
-	       L2T_IDX(ep->l2t->idx) |
-	       TX_CHAN(ep->tx_chan) |
-	       SMAC_SEL(ep->smac_idx) |
+	       WND_SCALE_V(wscale) |
+	       MSS_IDX_V(mtu_idx) |
+	       L2T_IDX_V(ep->l2t->idx) |
+	       TX_CHAN_V(ep->tx_chan) |
+	       SMAC_SEL_V(ep->smac_idx) |
 	       DSCP(ep->tos >> 2) |
-	       ULP_MODE(ULP_MODE_TCPDDP) |
-	       RCV_BUFSIZ(win);
-	opt2 = RX_CHANNEL(0) |
-	       RSS_QUEUE_VALID | RSS_QUEUE(ep->rss_qid);
+	       ULP_MODE_V(ULP_MODE_TCPDDP) |
+	       RCV_BUFSIZ_V(win);
+	opt2 = RX_CHANNEL_V(0) |
+	       RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid);
 
 	if (enable_tcp_timestamps && req->tcpopt.tstamp)
 		opt2 |= TSTAMPS_EN(1);
 	if (enable_tcp_sack && req->tcpopt.sack)
 		opt2 |= SACK_EN(1);
 	if (wscale && enable_tcp_window_scaling)
-		opt2 |= WND_SCALE_EN(1);
+		opt2 |= WND_SCALE_EN_F;
 	if (enable_ecn) {
 		const struct tcphdr *tcph;
 		u32 hlen = ntohl(req->hdr_len);
@@ -2211,7 +2211,7 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	}
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
 		u32 isn = (prandom_u32() & ~7UL) - 1;
-		opt2 |= T5_OPT_2_VALID;
+		opt2 |= T5_OPT_2_VALID_F;
 		opt2 |= V_CONG_CNTRL(CONG_ALG_TAHOE);
 		opt2 |= CONG_CNTRL_VALID; /* OPT_2_ISS for T5 */
 		rpl5 = (void *)rpl;
@@ -3557,7 +3557,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	 * We store the qid in opt2 which will be used by the firmware
 	 * to send us the wr response.
 	 */
-	req->tcb.opt2 = htonl(V_RSS_QUEUE(rss_qid));
+	req->tcb.opt2 = htonl(RSS_QUEUE_V(rss_qid));
 
 	/*
 	 * We initialize the MSS index in TCB to 0xF.
@@ -3565,7 +3565,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	 * TCB picks up the correct value. If this was 0
 	 * TP will ignore any value > 0 for MSS index.
 	 */
-	req->tcb.opt0 = cpu_to_be64(V_MSS_IDX(0xF));
+	req->tcb.opt0 = cpu_to_be64(MSS_IDX_V(0xF));
 	req->cookie = (unsigned long)skb;
 
 	set_wr_txq(req_skb, CPL_PRIORITY_CONTROL, port_id);
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 9335148c1ad9..0744455cd88b 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -78,14 +78,14 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 			(wait ? FW_WR_COMPL_F : 0));
 	req->wr.wr_lo = wait ? (__force __be64)(unsigned long) &wr_wait : 0L;
 	req->wr.wr_mid = cpu_to_be32(FW_WR_LEN16_V(DIV_ROUND_UP(wr_len, 16)));
-	req->cmd = cpu_to_be32(ULPTX_CMD(ULP_TX_MEM_WRITE));
+	req->cmd = cpu_to_be32(ULPTX_CMD_V(ULP_TX_MEM_WRITE));
 	req->cmd |= cpu_to_be32(V_T5_ULP_MEMIO_ORDER(1));
-	req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN(len>>5));
+	req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN_V(len>>5));
 	req->len16 = cpu_to_be32(DIV_ROUND_UP(wr_len-sizeof(req->wr), 16));
-	req->lock_addr = cpu_to_be32(ULP_MEMIO_ADDR(addr));
+	req->lock_addr = cpu_to_be32(ULP_MEMIO_ADDR_V(addr));
 
 	sgl = (struct ulptx_sgl *)(req + 1);
-	sgl->cmd_nsge = cpu_to_be32(ULPTX_CMD(ULP_TX_SC_DSGL) |
+	sgl->cmd_nsge = cpu_to_be32(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
 				    ULPTX_NSGE(1));
 	sgl->len0 = cpu_to_be32(len);
 	sgl->addr0 = cpu_to_be64(data);
@@ -107,12 +107,12 @@ static int _c4iw_write_mem_inline(struct c4iw_rdev *rdev, u32 addr, u32 len,
 	u8 wr_len, *to_dp, *from_dp;
 	int copy_len, num_wqe, i, ret = 0;
 	struct c4iw_wr_wait wr_wait;
-	__be32 cmd = cpu_to_be32(ULPTX_CMD(ULP_TX_MEM_WRITE));
+	__be32 cmd = cpu_to_be32(ULPTX_CMD_V(ULP_TX_MEM_WRITE));
 
 	if (is_t4(rdev->lldi.adapter_type))
-		cmd |= cpu_to_be32(ULP_MEMIO_ORDER(1));
+		cmd |= cpu_to_be32(ULP_MEMIO_ORDER_F);
 	else
-		cmd |= cpu_to_be32(V_T5_ULP_MEMIO_IMM(1));
+		cmd |= cpu_to_be32(T5_ULP_MEMIO_IMM_F);
 
 	addr &= 0x7FFFFFF;
 	PDBG("%s addr 0x%x len %u\n", __func__, addr, len);
@@ -144,14 +144,14 @@ static int _c4iw_write_mem_inline(struct c4iw_rdev *rdev, u32 addr, u32 len,
 				       FW_WR_LEN16_V(DIV_ROUND_UP(wr_len, 16)));
 
 		req->cmd = cmd;
-		req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN(
+		req->dlen = cpu_to_be32(ULP_MEMIO_DATA_LEN_V(
 				DIV_ROUND_UP(copy_len, T4_ULPTX_MIN_IO)));
 		req->len16 = cpu_to_be32(DIV_ROUND_UP(wr_len-sizeof(req->wr),
 						      16));
-		req->lock_addr = cpu_to_be32(ULP_MEMIO_ADDR(addr + i * 3));
+		req->lock_addr = cpu_to_be32(ULP_MEMIO_ADDR_V(addr + i * 3));
 
 		sc = (struct ulptx_idata *)(req + 1);
-		sc->cmd_more = cpu_to_be32(ULPTX_CMD(ULP_TX_SC_IMM));
+		sc->cmd_more = cpu_to_be32(ULPTX_CMD_V(ULP_TX_SC_IMM));
 		sc->len = cpu_to_be32(roundup(copy_len, T4_ULPTX_MIN_IO));
 
 		to_dp = (u8 *)(sc + 1);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 660bf0f79ac5..19ffe9bc1933 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3476,7 +3476,7 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 	req->local_ip = sip;
 	req->peer_ip = htonl(0);
 	chan = rxq_to_chan(&adap->sge, queue);
-	req->opt0 = cpu_to_be64(TX_CHAN(chan));
+	req->opt0 = cpu_to_be64(TX_CHAN_V(chan));
 	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
 				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
 	ret = t4_mgmt_tx(adap, skb);
@@ -3519,7 +3519,7 @@ int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
 	req->peer_ip_hi = cpu_to_be64(0);
 	req->peer_ip_lo = cpu_to_be64(0);
 	chan = rxq_to_chan(&adap->sge, queue);
-	req->opt0 = cpu_to_be64(TX_CHAN(chan));
+	req->opt0 = cpu_to_be64(TX_CHAN_V(chan));
 	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
 				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
 	ret = t4_mgmt_tx(adap, skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 96041397ee15..1eca0e21f738 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -436,7 +436,7 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
 	if (tp->vnic_shift >= 0) {
 		u32 viid = cxgb4_port_viid(dev);
 		u32 vf = FW_VIID_VIN_GET(viid);
-		u32 pf = FW_VIID_PFN_GET(viid);
+		u32 pf = FW_VIID_PFN_G(viid);
 		u32 vld = FW_VIID_VIVLD_GET(viid);
 
 		ntuple |= (u64)(V_FT_VNID_ID_VF(vf) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index dacd95008333..91dbf98036cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -816,7 +816,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		sgl->addr0 = cpu_to_be64(addr[1]);
 	}
 
-	sgl->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_NSGE(nfrags));
+	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) | ULPTX_NSGE(nfrags));
 	if (likely(--nfrags == 0))
 		return;
 	/*
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 5f4db2398c71..0f89f68948ab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -205,16 +205,62 @@ struct work_request_hdr {
 #define WR_HDR struct work_request_hdr wr
 
 /* option 0 fields */
-#define S_MSS_IDX    60
-#define M_MSS_IDX    0xF
-#define V_MSS_IDX(x) ((__u64)(x) << S_MSS_IDX)
-#define G_MSS_IDX(x) (((x) >> S_MSS_IDX) & M_MSS_IDX)
+#define TX_CHAN_S    2
+#define TX_CHAN_V(x) ((x) << TX_CHAN_S)
+
+#define ULP_MODE_S    8
+#define ULP_MODE_V(x) ((x) << ULP_MODE_S)
+
+#define RCV_BUFSIZ_S    12
+#define RCV_BUFSIZ_M    0x3FFU
+#define RCV_BUFSIZ_V(x) ((x) << RCV_BUFSIZ_S)
+
+#define SMAC_SEL_S    28
+#define SMAC_SEL_V(x) ((__u64)(x) << SMAC_SEL_S)
+
+#define L2T_IDX_S    36
+#define L2T_IDX_V(x) ((__u64)(x) << L2T_IDX_S)
+
+#define WND_SCALE_S    50
+#define WND_SCALE_V(x) ((__u64)(x) << WND_SCALE_S)
+
+#define KEEP_ALIVE_S    54
+#define KEEP_ALIVE_V(x) ((__u64)(x) << KEEP_ALIVE_S)
+#define KEEP_ALIVE_F    KEEP_ALIVE_V(1ULL)
+
+#define MSS_IDX_S    60
+#define MSS_IDX_M    0xF
+#define MSS_IDX_V(x) ((__u64)(x) << MSS_IDX_S)
+#define MSS_IDX_G(x) (((x) >> MSS_IDX_S) & MSS_IDX_M)
 
 /* option 2 fields */
-#define S_RSS_QUEUE    0
-#define M_RSS_QUEUE    0x3FF
-#define V_RSS_QUEUE(x) ((x) << S_RSS_QUEUE)
-#define G_RSS_QUEUE(x) (((x) >> S_RSS_QUEUE) & M_RSS_QUEUE)
+#define RSS_QUEUE_S    0
+#define RSS_QUEUE_M    0x3FF
+#define RSS_QUEUE_V(x) ((x) << RSS_QUEUE_S)
+#define RSS_QUEUE_G(x) (((x) >> RSS_QUEUE_S) & RSS_QUEUE_M)
+
+#define RSS_QUEUE_VALID_S    10
+#define RSS_QUEUE_VALID_V(x) ((x) << RSS_QUEUE_VALID_S)
+#define RSS_QUEUE_VALID_F    RSS_QUEUE_VALID_V(1U)
+
+#define RX_FC_DISABLE_S    20
+#define RX_FC_DISABLE_V(x) ((x) << RX_FC_DISABLE_S)
+#define RX_FC_DISABLE_F    RX_FC_DISABLE_V(1U)
+
+#define RX_FC_VALID_S    22
+#define RX_FC_VALID_V(x) ((x) << RX_FC_VALID_S)
+#define RX_FC_VALID_F    RX_FC_VALID_V(1U)
+
+#define RX_CHANNEL_S    26
+#define RX_CHANNEL_V(x) ((x) << RX_CHANNEL_S)
+
+#define WND_SCALE_EN_S    28
+#define WND_SCALE_EN_V(x) ((x) << WND_SCALE_EN_S)
+#define WND_SCALE_EN_F    WND_SCALE_EN_V(1U)
+
+#define T5_OPT_2_VALID_S    31
+#define T5_OPT_2_VALID_V(x) ((x) << T5_OPT_2_VALID_S)
+#define T5_OPT_2_VALID_F    T5_OPT_2_VALID_V(1U)
 
 struct cpl_pass_open_req {
 	WR_HDR;
@@ -224,20 +270,11 @@ struct cpl_pass_open_req {
 	__be32 local_ip;
 	__be32 peer_ip;
 	__be64 opt0;
-#define TX_CHAN(x)    ((x) << 2)
 #define NO_CONG(x)    ((x) << 4)
 #define DELACK(x)     ((x) << 5)
-#define ULP_MODE(x)   ((x) << 8)
-#define RCV_BUFSIZ(x) ((x) << 12)
-#define RCV_BUFSIZ_MASK 0x3FFU
 #define DSCP(x)       ((x) << 22)
-#define SMAC_SEL(x)   ((u64)(x) << 28)
-#define L2T_IDX(x)    ((u64)(x) << 36)
 #define TCAM_BYPASS(x) ((u64)(x) << 48)
 #define NAGLE(x)      ((u64)(x) << 49)
-#define WND_SCALE(x)  ((u64)(x) << 50)
-#define KEEP_ALIVE(x) ((u64)(x) << 54)
-#define MSS_IDX(x)    ((u64)(x) << 60)
 	__be64 opt1;
 #define SYN_RSS_ENABLE   (1 << 0)
 #define SYN_RSS_QUEUE(x) ((x) << 2)
@@ -267,20 +304,13 @@ struct cpl_pass_accept_rpl {
 	WR_HDR;
 	union opcode_tid ot;
 	__be32 opt2;
-#define RSS_QUEUE(x)         ((x) << 0)
-#define RSS_QUEUE_VALID      (1 << 10)
 #define RX_COALESCE_VALID(x) ((x) << 11)
 #define RX_COALESCE(x)       ((x) << 12)
 #define PACE(x)	      ((x) << 16)
-#define RX_FC_VALID	     ((1U) << 19)
-#define RX_FC_DISABLE	     ((1U) << 20)
 #define TX_QUEUE(x)          ((x) << 23)
-#define RX_CHANNEL(x)        ((x) << 26)
 #define CCTRL_ECN(x)         ((x) << 27)
-#define WND_SCALE_EN(x)      ((x) << 28)
 #define TSTAMPS_EN(x)        ((x) << 29)
 #define SACK_EN(x)           ((x) << 30)
-#define T5_OPT_2_VALID	     ((1U) << 31)
 	__be64 opt0;
 };
 
@@ -305,10 +335,10 @@ struct cpl_act_open_req {
 	__be32 opt2;
 };
 
-#define S_FILTER_TUPLE  24
-#define M_FILTER_TUPLE  0xFFFFFFFFFF
-#define V_FILTER_TUPLE(x) ((x) << S_FILTER_TUPLE)
-#define G_FILTER_TUPLE(x) (((x) >> S_FILTER_TUPLE) & M_FILTER_TUPLE)
+#define FILTER_TUPLE_S  24
+#define FILTER_TUPLE_M  0xFFFFFFFFFF
+#define FILTER_TUPLE_V(x) ((x) << FILTER_TUPLE_S)
+#define FILTER_TUPLE_G(x) (((x) >> FILTER_TUPLE_S) & FILTER_TUPLE_M)
 struct cpl_t5_act_open_req {
 	WR_HDR;
 	union opcode_tid ot;
@@ -579,10 +609,16 @@ struct cpl_rx_data_ack {
 	WR_HDR;
 	union opcode_tid ot;
 	__be32 credit_dack;
-#define RX_CREDITS(x)   ((x) << 0)
-#define RX_FORCE_ACK(x) ((x) << 28)
 };
 
+/* cpl_rx_data_ack.ack_seq fields */
+#define RX_CREDITS_S    0
+#define RX_CREDITS_V(x) ((x) << RX_CREDITS_S)
+
+#define RX_FORCE_ACK_S    28
+#define RX_FORCE_ACK_V(x) ((x) << RX_FORCE_ACK_S)
+#define RX_FORCE_ACK_F    RX_FORCE_ACK_V(1U)
+
 struct cpl_rx_pkt {
 	struct rss_header rsshdr;
 	u8 opcode;
@@ -803,6 +839,9 @@ enum {
 	ULP_TX_SC_ISGL = 0x83
 };
 
+#define ULPTX_CMD_S    24
+#define ULPTX_CMD_V(x) ((x) << ULPTX_CMD_S)
+
 struct ulptx_sge_pair {
 	__be32 len[2];
 	__be64 addr[2];
@@ -810,7 +849,6 @@ struct ulptx_sge_pair {
 
 struct ulptx_sgl {
 	__be32 cmd_nsge;
-#define ULPTX_CMD(x) ((x) << 24)
 #define ULPTX_NSGE(x) ((x) << 0)
 #define ULPTX_MORE (1U << 23)
 	__be32 len0;
@@ -821,15 +859,21 @@ struct ulptx_sgl {
 struct ulp_mem_io {
 	WR_HDR;
 	__be32 cmd;
-#define ULP_MEMIO_ORDER(x) ((x) << 23)
 	__be32 len16;             /* command length */
 	__be32 dlen;              /* data length in 32-byte units */
-#define ULP_MEMIO_DATA_LEN(x) ((x) << 0)
 	__be32 lock_addr;
-#define ULP_MEMIO_ADDR(x) ((x) << 0)
 #define ULP_MEMIO_LOCK(x) ((x) << 31)
 };
 
+/* additional ulp_mem_io.cmd fields */
+#define ULP_MEMIO_ORDER_S    23
+#define ULP_MEMIO_ORDER_V(x) ((x) << ULP_MEMIO_ORDER_S)
+#define ULP_MEMIO_ORDER_F    ULP_MEMIO_ORDER_V(1U)
+
+#define T5_ULP_MEMIO_IMM_S    23
+#define T5_ULP_MEMIO_IMM_V(x) ((x) << T5_ULP_MEMIO_IMM_S)
+#define T5_ULP_MEMIO_IMM_F    T5_ULP_MEMIO_IMM_V(1U)
+
 #define S_T5_ULP_MEMIO_IMM    23
 #define V_T5_ULP_MEMIO_IMM(x) ((x) << S_T5_ULP_MEMIO_IMM)
 #define F_T5_ULP_MEMIO_IMM    V_T5_ULP_MEMIO_IMM(1U)
@@ -838,4 +882,12 @@ struct ulp_mem_io {
 #define V_T5_ULP_MEMIO_ORDER(x) ((x) << S_T5_ULP_MEMIO_ORDER)
 #define F_T5_ULP_MEMIO_ORDER    V_T5_ULP_MEMIO_ORDER(1U)
 
+/* ulp_mem_io.lock_addr fields */
+#define ULP_MEMIO_ADDR_S    0
+#define ULP_MEMIO_ADDR_V(x) ((x) << ULP_MEMIO_ADDR_S)
+
+/* ulp_mem_io.dlen fields */
+#define ULP_MEMIO_DATA_LEN_S    0
+#define ULP_MEMIO_DATA_LEN_V(x) ((x) << ULP_MEMIO_DATA_LEN_S)
+
 #endif  /* __T4_MSG_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 7cca67fde4f4..6fc46dc11988 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1395,7 +1395,11 @@ struct fw_eq_ofld_cmd {
  * Macros for VIID parsing:
  * VIID - [10:8] PFN, [7] VI Valid, [6:0] VI number
  */
-#define FW_VIID_PFN_GET(x) (((x) >> 8) & 0x7)
+
+#define FW_VIID_PFN_S           8
+#define FW_VIID_PFN_M           0x7
+#define FW_VIID_PFN_G(x)        (((x) >> FW_VIID_PFN_S) & FW_VIID_PFN_M)
+
 #define FW_VIID_VIVLD_GET(x) (((x) >> 7) & 0x1)
 #define FW_VIID_VIN_GET(x) (((x) >> 0) & 0x7F)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index cd538afa40dd..aff6d37f2676 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -907,7 +907,7 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *tq,
 		sgl->addr0 = cpu_to_be64(addr[1]);
 	}
 
-	sgl->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) |
+	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
 			      ULPTX_NSGE(nfrags));
 	if (likely(--nfrags == 0))
 		return;
diff --git a/drivers/scsi/csiostor/csio_lnode.c b/drivers/scsi/csiostor/csio_lnode.c
index 48e45b1ea4e5..87f9280d9b43 100644
--- a/drivers/scsi/csiostor/csio_lnode.c
+++ b/drivers/scsi/csiostor/csio_lnode.c
@@ -1757,7 +1757,7 @@ csio_ln_mgmt_submit_wr(struct csio_mgmtm *mgmtm, struct csio_ioreq *io_req,
 		csio_wr_copy_to_wrp(pld->vaddr, &wrp, wr_off, im_len);
 	else {
 		/* Program DSGL to dma payload */
-		dsgl.cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) |
+		dsgl.cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) |
 					ULPTX_MORE | ULPTX_NSGE(1));
 		dsgl.len0 = cpu_to_be32(pld_len);
 		dsgl.addr0 = cpu_to_be64(pld->paddr);
diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
index b37c69a2772a..b9c012ba34f8 100644
--- a/drivers/scsi/csiostor/csio_scsi.c
+++ b/drivers/scsi/csiostor/csio_scsi.c
@@ -322,7 +322,7 @@ csio_scsi_init_ultptx_dsgl(struct csio_hw *hw, struct csio_ioreq *req,
 	struct csio_dma_buf *dma_buf;
 	struct scsi_cmnd *scmnd = csio_scsi_cmnd(req);
 
-	sgl->cmd_nsge = htonl(ULPTX_CMD(ULP_TX_SC_DSGL) | ULPTX_MORE |
+	sgl->cmd_nsge = htonl(ULPTX_CMD_V(ULP_TX_SC_DSGL) | ULPTX_MORE |
 				     ULPTX_NSGE(req->nsge));
 	/* Now add the data SGLs */
 	if (likely(!req->dcopy)) {
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index ccacf09c2c16..ed0e16866dc7 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -188,18 +188,18 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 	unsigned int qid_atid = ((unsigned int)csk->atid) |
 				 (((unsigned int)csk->rss_qid) << 14);
 
-	opt0 = KEEP_ALIVE(1) |
-		WND_SCALE(wscale) |
-		MSS_IDX(csk->mss_idx) |
-		L2T_IDX(((struct l2t_entry *)csk->l2t)->idx) |
-		TX_CHAN(csk->tx_chan) |
-		SMAC_SEL(csk->smac_idx) |
-		ULP_MODE(ULP_MODE_ISCSI) |
-		RCV_BUFSIZ(cxgb4i_rcv_win >> 10);
-	opt2 = RX_CHANNEL(0) |
-		RSS_QUEUE_VALID |
-		(1 << 20) |
-		RSS_QUEUE(csk->rss_qid);
+	opt0 = KEEP_ALIVE_F |
+		WND_SCALE_V(wscale) |
+		MSS_IDX_V(csk->mss_idx) |
+		L2T_IDX_V(((struct l2t_entry *)csk->l2t)->idx) |
+		TX_CHAN_V(csk->tx_chan) |
+		SMAC_SEL_V(csk->smac_idx) |
+		ULP_MODE_V(ULP_MODE_ISCSI) |
+		RCV_BUFSIZ_V(cxgb4i_rcv_win >> 10);
+	opt2 = RX_CHANNEL_V(0) |
+		RSS_QUEUE_VALID_F |
+		(RX_FC_DISABLE_F) |
+		RSS_QUEUE_V(csk->rss_qid);
 
 	if (is_t4(lldi->adapter_type)) {
 		struct cpl_act_open_req *req =
@@ -216,7 +216,7 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 		req->params = cpu_to_be32(cxgb4_select_ntuple(
 					csk->cdev->ports[csk->port_id],
 					csk->l2t));
-		opt2 |= 1 << 22;
+		opt2 |= RX_FC_VALID_F;
 		req->opt2 = cpu_to_be32(opt2);
 
 		log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
@@ -236,7 +236,7 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 		req->local_ip = csk->saddr.sin_addr.s_addr;
 		req->peer_ip = csk->daddr.sin_addr.s_addr;
 		req->opt0 = cpu_to_be64(opt0);
-		req->params = cpu_to_be64(V_FILTER_TUPLE(
+		req->params = cpu_to_be64(FILTER_TUPLE_V(
 				cxgb4_select_ntuple(
 					csk->cdev->ports[csk->port_id],
 					csk->l2t)));
@@ -271,19 +271,19 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 	unsigned int qid_atid = ((unsigned int)csk->atid) |
 				 (((unsigned int)csk->rss_qid) << 14);
 
-	opt0 = KEEP_ALIVE(1) |
-		WND_SCALE(wscale) |
-		MSS_IDX(csk->mss_idx) |
-		L2T_IDX(((struct l2t_entry *)csk->l2t)->idx) |
-		TX_CHAN(csk->tx_chan) |
-		SMAC_SEL(csk->smac_idx) |
-		ULP_MODE(ULP_MODE_ISCSI) |
-		RCV_BUFSIZ(cxgb4i_rcv_win >> 10);
+	opt0 = KEEP_ALIVE_F |
+		WND_SCALE_V(wscale) |
+		MSS_IDX_V(csk->mss_idx) |
+		L2T_IDX_V(((struct l2t_entry *)csk->l2t)->idx) |
+		TX_CHAN_V(csk->tx_chan) |
+		SMAC_SEL_V(csk->smac_idx) |
+		ULP_MODE_V(ULP_MODE_ISCSI) |
+		RCV_BUFSIZ_V(cxgb4i_rcv_win >> 10);
 
-	opt2 = RX_CHANNEL(0) |
-		RSS_QUEUE_VALID |
-		RX_FC_DISABLE |
-		RSS_QUEUE(csk->rss_qid);
+	opt2 = RX_CHANNEL_V(0) |
+		RSS_QUEUE_VALID_F |
+		RX_FC_DISABLE_F |
+		RSS_QUEUE_V(csk->rss_qid);
 
 	if (t4) {
 		struct cpl_act_open_req6 *req =
@@ -304,7 +304,7 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 
 		req->opt0 = cpu_to_be64(opt0);
 
-		opt2 |= RX_FC_VALID;
+		opt2 |= RX_FC_VALID_F;
 		req->opt2 = cpu_to_be32(opt2);
 
 		req->params = cpu_to_be32(cxgb4_select_ntuple(
@@ -327,10 +327,10 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 									8);
 		req->opt0 = cpu_to_be64(opt0);
 
-		opt2 |= T5_OPT_2_VALID;
+		opt2 |= T5_OPT_2_VALID_F;
 		req->opt2 = cpu_to_be32(opt2);
 
-		req->params = cpu_to_be64(V_FILTER_TUPLE(cxgb4_select_ntuple(
+		req->params = cpu_to_be64(FILTER_TUPLE_V(cxgb4_select_ntuple(
 					  csk->cdev->ports[csk->port_id],
 					  csk->l2t)));
 	}
@@ -451,7 +451,8 @@ static u32 send_rx_credits(struct cxgbi_sock *csk, u32 credits)
 	INIT_TP_WR(req, csk->tid);
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_RX_DATA_ACK,
 				      csk->tid));
-	req->credit_dack = cpu_to_be32(RX_CREDITS(credits) | RX_FORCE_ACK(1));
+	req->credit_dack = cpu_to_be32(RX_CREDITS_V(credits)
+				       | RX_FORCE_ACK_F);
 	cxgb4_ofld_send(csk->cdev->ports[csk->port_id], skb);
 	return credits;
 }
@@ -1440,16 +1441,16 @@ static inline void ulp_mem_io_set_hdr(struct cxgb4_lld_info *lldi,
 
 	INIT_ULPTX_WR(req, wr_len, 0, 0);
 	if (is_t4(lldi->adapter_type))
-		req->cmd = htonl(ULPTX_CMD(ULP_TX_MEM_WRITE) |
-					(ULP_MEMIO_ORDER(1)));
+		req->cmd = htonl(ULPTX_CMD_V(ULP_TX_MEM_WRITE) |
+					(ULP_MEMIO_ORDER_F));
 	else
-		req->cmd = htonl(ULPTX_CMD(ULP_TX_MEM_WRITE) |
-					(V_T5_ULP_MEMIO_IMM(1)));
-	req->dlen = htonl(ULP_MEMIO_DATA_LEN(dlen >> 5));
-	req->lock_addr = htonl(ULP_MEMIO_ADDR(pm_addr >> 5));
+		req->cmd = htonl(ULPTX_CMD_V(ULP_TX_MEM_WRITE) |
+					(T5_ULP_MEMIO_IMM_F));
+	req->dlen = htonl(ULP_MEMIO_DATA_LEN_V(dlen >> 5));
+	req->lock_addr = htonl(ULP_MEMIO_ADDR_V(pm_addr >> 5));
 	req->len16 = htonl(DIV_ROUND_UP(wr_len - sizeof(req->wr), 16));
 
-	idata->cmd_more = htonl(ULPTX_CMD(ULP_TX_SC_IMM));
+	idata->cmd_more = htonl(ULPTX_CMD_V(ULP_TX_SC_IMM));
 	idata->len = htonl(dlen);
 }
 
@@ -1673,7 +1674,8 @@ static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 	cdev->skb_rx_extra = sizeof(struct cpl_iscsi_hdr);
 	cdev->itp = &cxgb4i_iscsi_transport;
 
-	cdev->pfvf = FW_VIID_PFN_GET(cxgb4_port_viid(lldi->ports[0])) << 8;
+	cdev->pfvf = FW_VIID_PFN_G(cxgb4_port_viid(lldi->ports[0]))
+			<< FW_VIID_PFN_S;
 	pr_info("cdev 0x%p,%s, pfvf %u.\n",
 		cdev, lldi->ports[0]->name, cdev->pfvf);
 
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
