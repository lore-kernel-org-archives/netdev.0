From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 1/2] iw_cxgb4/cxgb4/cxgb4i: Cleanup register defines/MACROS related to CM CPL messages
Date: Thu,  8 Jan 2015 21:38:15 -0800
Message-ID: <1420781896-25337-2-git-send-email-anish@chelsio.com>
References: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, hch@infradead.org,
	jbottomley@parallels.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, kxie@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>

This patch cleanups all macros/register define related to connection management
CPL messages that are defined in t4_msg.h and the affected files

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                   |  78 +++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        | 168 ++++++++++++++++-----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                 |  12 +-
 6 files changed, 183 insertions(+), 87 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 9edc200b311d..87872795c94f 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -235,19 +235,19 @@ static void release_tid(struct c4iw_rdev *rdev, u32 hwtid, struct sk_buff *skb)
 
 static void set_emss(struct c4iw_ep *ep, u16 opt)
 {
-	ep->emss = ep->com.dev->rdev.lldi.mtus[GET_TCPOPT_MSS(opt)] -
+	ep->emss = ep->com.dev->rdev.lldi.mtus[TCPOPT_MSS_G(opt)] -
 		   ((AF_INET == ep->com.remote_addr.ss_family) ?
 		    sizeof(struct iphdr) : sizeof(struct ipv6hdr)) -
 		   sizeof(struct tcphdr);
 	ep->mss = ep->emss;
-	if (GET_TCPOPT_TSTAMP(opt))
+	if (TCPOPT_TSTAMP_G(opt))
 		ep->emss -= round_up(TCPOLEN_TIMESTAMP, 4);
 	if (ep->emss < 128)
 		ep->emss = 128;
 	if (ep->emss & 7)
 		PDBG("Warning: misaligned mtu idx %u mss %u emss=%u\n",
-		     GET_TCPOPT_MSS(opt), ep->mss, ep->emss);
-	PDBG("%s mss_idx %u mss %u emss=%u\n", __func__, GET_TCPOPT_MSS(opt),
+		     TCPOPT_MSS_G(opt), ep->mss, ep->emss);
+	PDBG("%s mss_idx %u mss %u emss=%u\n", __func__, TCPOPT_MSS_G(opt),
 	     ep->mss, ep->emss);
 }
 
@@ -652,24 +652,24 @@ static int send_connect(struct c4iw_ep *ep)
 	if (win > RCV_BUFSIZ_M)
 		win = RCV_BUFSIZ_M;
 
-	opt0 = (nocong ? NO_CONG(1) : 0) |
+	opt0 = (nocong ? NO_CONG_F : 0) |
 	       KEEP_ALIVE_F |
-	       DELACK(1) |
+	       DELACK_F |
 	       WND_SCALE_V(wscale) |
 	       MSS_IDX_V(mtu_idx) |
 	       L2T_IDX_V(ep->l2t->idx) |
 	       TX_CHAN_V(ep->tx_chan) |
 	       SMAC_SEL_V(ep->smac_idx) |
-	       DSCP(ep->tos) |
+	       DSCP_V(ep->tos) |
 	       ULP_MODE_V(ULP_MODE_TCPDDP) |
 	       RCV_BUFSIZ_V(win);
 	opt2 = RX_CHANNEL_V(0) |
-	       CCTRL_ECN(enable_ecn) |
+	       CCTRL_ECN_V(enable_ecn) |
 	       RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid);
 	if (enable_tcp_timestamps)
-		opt2 |= TSTAMPS_EN(1);
+		opt2 |= TSTAMPS_EN_F;
 	if (enable_tcp_sack)
-		opt2 |= SACK_EN(1);
+		opt2 |= SACK_EN_F;
 	if (wscale && enable_tcp_window_scaling)
 		opt2 |= WND_SCALE_EN_F;
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
@@ -1042,7 +1042,7 @@ static int act_establish(struct c4iw_dev *dev, struct sk_buff *skb)
 	struct c4iw_ep *ep;
 	struct cpl_act_establish *req = cplhdr(skb);
 	unsigned int tid = GET_TID(req);
-	unsigned int atid = GET_TID_TID(ntohl(req->tos_atid));
+	unsigned int atid = TID_TID_G(ntohl(req->tos_atid));
 	struct tid_info *t = dev->rdev.lldi.tids;
 
 	ep = lookup_atid(t, atid);
@@ -1751,7 +1751,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
-	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR));
+	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR));
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.filter = cpu_to_be32(cxgb4_select_ntuple(
 				     ep->com.dev->rdev.lldi.ports[0],
@@ -1782,27 +1782,27 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	if (win > RCV_BUFSIZ_M)
 		win = RCV_BUFSIZ_M;
 
-	req->tcb.opt0 = (__force __be64) (TCAM_BYPASS(1) |
-		(nocong ? NO_CONG(1) : 0) |
+	req->tcb.opt0 = (__force __be64) (TCAM_BYPASS_F |
+		(nocong ? NO_CONG_F : 0) |
 		KEEP_ALIVE_F |
-		DELACK(1) |
+		DELACK_F |
 		WND_SCALE_V(wscale) |
 		MSS_IDX_V(mtu_idx) |
 		L2T_IDX_V(ep->l2t->idx) |
 		TX_CHAN_V(ep->tx_chan) |
 		SMAC_SEL_V(ep->smac_idx) |
-		DSCP(ep->tos) |
+		DSCP_V(ep->tos) |
 		ULP_MODE_V(ULP_MODE_TCPDDP) |
 		RCV_BUFSIZ_V(win));
-	req->tcb.opt2 = (__force __be32) (PACE(1) |
-		TX_QUEUE(ep->com.dev->rdev.lldi.tx_modq[ep->tx_chan]) |
+	req->tcb.opt2 = (__force __be32) (PACE_V(1) |
+		TX_QUEUE_V(ep->com.dev->rdev.lldi.tx_modq[ep->tx_chan]) |
 		RX_CHANNEL_V(0) |
-		CCTRL_ECN(enable_ecn) |
+		CCTRL_ECN_V(enable_ecn) |
 		RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid));
 	if (enable_tcp_timestamps)
-		req->tcb.opt2 |= (__force __be32)TSTAMPS_EN(1);
+		req->tcb.opt2 |= (__force __be32)TSTAMPS_EN_F;
 	if (enable_tcp_sack)
-		req->tcb.opt2 |= (__force __be32)SACK_EN(1);
+		req->tcb.opt2 |= (__force __be32)SACK_EN_F;
 	if (wscale && enable_tcp_window_scaling)
 		req->tcb.opt2 |= (__force __be32)WND_SCALE_EN_F;
 	req->tcb.opt0 = cpu_to_be64((__force u64)req->tcb.opt0);
@@ -2023,10 +2023,10 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct c4iw_ep *ep;
 	struct cpl_act_open_rpl *rpl = cplhdr(skb);
-	unsigned int atid = GET_TID_TID(GET_AOPEN_ATID(
-					ntohl(rpl->atid_status)));
+	unsigned int atid = TID_TID_G(AOPEN_ATID_G(
+				      ntohl(rpl->atid_status)));
 	struct tid_info *t = dev->rdev.lldi.tids;
-	int status = GET_AOPEN_STATUS(ntohl(rpl->atid_status));
+	int status = AOPEN_STATUS_G(ntohl(rpl->atid_status));
 	struct sockaddr_in *la;
 	struct sockaddr_in *ra;
 	struct sockaddr_in6 *la6;
@@ -2064,7 +2064,7 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 		if (ep->com.local_addr.ss_family == AF_INET &&
 		    dev->rdev.lldi.enable_fw_ofld_conn) {
 			send_fw_act_open_req(ep,
-					     GET_TID_TID(GET_AOPEN_ATID(
+					     TID_TID_G(AOPEN_ATID_G(
 					     ntohl(rpl->atid_status))));
 			return 0;
 		}
@@ -2181,24 +2181,24 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	win = ep->rcv_win >> 10;
 	if (win > RCV_BUFSIZ_M)
 		win = RCV_BUFSIZ_M;
-	opt0 = (nocong ? NO_CONG(1) : 0) |
+	opt0 = (nocong ? NO_CONG_F : 0) |
 	       KEEP_ALIVE_F |
-	       DELACK(1) |
+	       DELACK_F |
 	       WND_SCALE_V(wscale) |
 	       MSS_IDX_V(mtu_idx) |
 	       L2T_IDX_V(ep->l2t->idx) |
 	       TX_CHAN_V(ep->tx_chan) |
 	       SMAC_SEL_V(ep->smac_idx) |
-	       DSCP(ep->tos >> 2) |
+	       DSCP_V(ep->tos >> 2) |
 	       ULP_MODE_V(ULP_MODE_TCPDDP) |
 	       RCV_BUFSIZ_V(win);
 	opt2 = RX_CHANNEL_V(0) |
 	       RSS_QUEUE_VALID_F | RSS_QUEUE_V(ep->rss_qid);
 
 	if (enable_tcp_timestamps && req->tcpopt.tstamp)
-		opt2 |= TSTAMPS_EN(1);
+		opt2 |= TSTAMPS_EN_F;
 	if (enable_tcp_sack && req->tcpopt.sack)
-		opt2 |= SACK_EN(1);
+		opt2 |= SACK_EN_F;
 	if (wscale && enable_tcp_window_scaling)
 		opt2 |= WND_SCALE_EN_F;
 	if (enable_ecn) {
@@ -2208,7 +2208,7 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 		tcph = (const void *)(req + 1) + G_ETH_HDR_LEN(hlen) +
 			G_IP_HDR_LEN(hlen);
 		if (tcph->ece && tcph->cwr)
-			opt2 |= CCTRL_ECN(1);
+			opt2 |= CCTRL_ECN_V(1);
 	}
 	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
 		u32 isn = (prandom_u32() & ~7UL) - 1;
@@ -2277,7 +2277,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct c4iw_ep *child_ep = NULL, *parent_ep;
 	struct cpl_pass_accept_req *req = cplhdr(skb);
-	unsigned int stid = GET_POPEN_TID(ntohl(req->tos_stid));
+	unsigned int stid = PASS_OPEN_TID_G(ntohl(req->tos_stid));
 	struct tid_info *t = dev->rdev.lldi.tids;
 	unsigned int hwtid = GET_TID(req);
 	struct dst_entry *dst;
@@ -2310,14 +2310,14 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		     ntohs(peer_port), peer_mss);
 		dst = find_route(dev, *(__be32 *)local_ip, *(__be32 *)peer_ip,
 				 local_port, peer_port,
-				 GET_POPEN_TOS(ntohl(req->tos_stid)));
+				 PASS_OPEN_TOS_G(ntohl(req->tos_stid)));
 	} else {
 		PDBG("%s parent ep %p hwtid %u laddr %pI6 raddr %pI6 lport %d rport %d peer_mss %d\n"
 		     , __func__, parent_ep, hwtid,
 		     local_ip, peer_ip, ntohs(local_port),
 		     ntohs(peer_port), peer_mss);
 		dst = find_route6(dev, local_ip, peer_ip, local_port, peer_port,
-				  PASS_OPEN_TOS(ntohl(req->tos_stid)),
+				  PASS_OPEN_TOS_G(ntohl(req->tos_stid)),
 				  ((struct sockaddr_in6 *)
 				  &parent_ep->com.local_addr)->sin6_scope_id);
 	}
@@ -2375,7 +2375,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	}
 	c4iw_get_ep(&parent_ep->com);
 	child_ep->parent_ep = parent_ep;
-	child_ep->tos = GET_POPEN_TOS(ntohl(req->tos_stid));
+	child_ep->tos = PASS_OPEN_TOS_G(ntohl(req->tos_stid));
 	child_ep->dst = dst;
 	child_ep->hwtid = hwtid;
 
@@ -3516,8 +3516,8 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 				   V_ETH_HDR_LEN(G_RX_ETHHDR_LEN(eth_hdr_len)));
 	req->vlan = (__force __be16) vlantag;
 	req->len = (__force __be16) len;
-	req->tos_stid = cpu_to_be32(PASS_OPEN_TID(stid) |
-				    PASS_OPEN_TOS(tos));
+	req->tos_stid = cpu_to_be32(PASS_OPEN_TID_V(stid) |
+				    PASS_OPEN_TOS_V(tos));
 	req->tcpopt.mss = htons(tmp_opt.mss_clamp);
 	if (tmp_opt.wscale_ok)
 		req->tcpopt.wsf = tmp_opt.snd_wscale;
@@ -3542,7 +3542,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 	req_skb = alloc_skb(sizeof(struct fw_ofld_connection_wr), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(req_skb, sizeof(*req));
 	memset(req, 0, sizeof(*req));
-	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL_F);
+	req->op_compl = htonl(WR_OP_V(FW_OFLD_CONNECTION_WR) | FW_WR_COMPL_F);
 	req->len16_pkd = htonl(FW_WR_LEN16_V(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.version_cpl = htonl(FW_OFLD_CONNECTION_WR_CPL_F);
 	req->le.filter = (__force __be32) filter;
@@ -3556,7 +3556,7 @@ static void send_fw_pass_open_req(struct c4iw_dev *dev, struct sk_buff *skb,
 		 htonl(FW_OFLD_CONNECTION_WR_T_STATE_V(TCP_SYN_RECV) |
 			FW_OFLD_CONNECTION_WR_RCV_SCALE_V(cpl->tcpopt.wsf) |
 			FW_OFLD_CONNECTION_WR_ASTID_V(
-			GET_PASS_OPEN_TID(ntohl(cpl->tos_stid))));
+			PASS_OPEN_TID_G(ntohl(cpl->tos_stid))));
 
 	/*
 	 * We store the qid in opt2 which will be used by the firmware
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6de41cc6687e..2897f956bb21 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3416,8 +3416,8 @@ int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
 	req->peer_ip = htonl(0);
 	chan = rxq_to_chan(&adap->sge, queue);
 	req->opt0 = cpu_to_be64(TX_CHAN_V(chan));
-	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
-				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
+	req->opt1 = cpu_to_be64(CONN_POLICY_V(CPL_CONN_POLICY_ASK) |
+				SYN_RSS_ENABLE_F | SYN_RSS_QUEUE_V(queue));
 	ret = t4_mgmt_tx(adap, skb);
 	return net_xmit_eval(ret);
 }
@@ -3459,8 +3459,8 @@ int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
 	req->peer_ip_lo = cpu_to_be64(0);
 	chan = rxq_to_chan(&adap->sge, queue);
 	req->opt0 = cpu_to_be64(TX_CHAN_V(chan));
-	req->opt1 = cpu_to_be64(CONN_POLICY_ASK |
-				SYN_RSS_ENABLE | SYN_RSS_QUEUE(queue));
+	req->opt1 = cpu_to_be64(CONN_POLICY_V(CPL_CONN_POLICY_ASK) |
+				SYN_RSS_ENABLE_F | SYN_RSS_QUEUE_V(queue));
 	ret = t4_mgmt_tx(adap, skb);
 	return net_xmit_eval(ret);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 5ae14451c3a4..dea984bbdb99 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -151,7 +151,7 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 
 	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
 					e->idx | (sync ? F_SYNC_WR : 0) |
-					TID_QID(adap->sge.fw_evtq.abs_id)));
+					TID_QID_V(adap->sge.fw_evtq.abs_id)));
 	req->params = htons(L2T_W_PORT(e->lport) | L2T_W_NOREPLY(!sync));
 	req->l2t_idx = htons(e->idx);
 	req->vlan = htons(e->vlan);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 0f89f68948ab..15e72063fc95 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -124,6 +124,13 @@ enum CPL_error {
 };
 
 enum {
+	CPL_CONN_POLICY_AUTO = 0,
+	CPL_CONN_POLICY_ASK  = 1,
+	CPL_CONN_POLICY_FILTER = 2,
+	CPL_CONN_POLICY_DENY = 3
+};
+
+enum {
 	ULP_MODE_NONE          = 0,
 	ULP_MODE_ISCSI         = 2,
 	ULP_MODE_RDMA          = 4,
@@ -160,16 +167,28 @@ union opcode_tid {
 	u8 opcode;
 };
 
-#define CPL_OPCODE(x) ((x) << 24)
-#define G_CPL_OPCODE(x) (((x) >> 24) & 0xFF)
-#define MK_OPCODE_TID(opcode, tid) (CPL_OPCODE(opcode) | (tid))
+#define CPL_OPCODE_S    24
+#define CPL_OPCODE_V(x) ((x) << CPL_OPCODE_S)
+#define CPL_OPCODE_G(x) (((x) >> CPL_OPCODE_S) & 0xFF)
+#define TID_G(x)    ((x) & 0xFFFFFF)
+
+/* tid is assumed to be 24-bits */
+#define MK_OPCODE_TID(opcode, tid) (CPL_OPCODE_V(opcode) | (tid))
+
 #define OPCODE_TID(cmd) ((cmd)->ot.opcode_tid)
-#define GET_TID(cmd) (ntohl(OPCODE_TID(cmd)) & 0xFFFFFF)
+
+/* extract the TID from a CPL command */
+#define GET_TID(cmd) (TID_G(be32_to_cpu(OPCODE_TID(cmd))))
 
 /* partitioning of TID fields that also carry a queue id */
-#define GET_TID_TID(x) ((x) & 0x3fff)
-#define GET_TID_QID(x) (((x) >> 14) & 0x3ff)
-#define TID_QID(x)     ((x) << 14)
+#define TID_TID_S    0
+#define TID_TID_M    0x3fff
+#define TID_TID_G(x) (((x) >> TID_TID_S) & TID_TID_M)
+
+#define TID_QID_S    14
+#define TID_QID_M    0x3ff
+#define TID_QID_V(x) ((x) << TID_QID_S)
+#define TID_QID_G(x) (((x) >> TID_QID_S) & TID_QID_M)
 
 struct rss_header {
 	u8 opcode;
@@ -199,8 +218,8 @@ struct work_request_hdr {
 };
 
 /* wr_hi fields */
-#define S_WR_OP    24
-#define V_WR_OP(x) ((__u64)(x) << S_WR_OP)
+#define WR_OP_S    24
+#define WR_OP_V(x) ((__u64)(x) << WR_OP_S)
 
 #define WR_HDR struct work_request_hdr wr
 
@@ -270,17 +289,42 @@ struct cpl_pass_open_req {
 	__be32 local_ip;
 	__be32 peer_ip;
 	__be64 opt0;
-#define NO_CONG(x)    ((x) << 4)
-#define DELACK(x)     ((x) << 5)
-#define DSCP(x)       ((x) << 22)
-#define TCAM_BYPASS(x) ((u64)(x) << 48)
-#define NAGLE(x)      ((u64)(x) << 49)
 	__be64 opt1;
-#define SYN_RSS_ENABLE   (1 << 0)
-#define SYN_RSS_QUEUE(x) ((x) << 2)
-#define CONN_POLICY_ASK  (1 << 22)
 };
 
+/* option 0 fields */
+#define NO_CONG_S    4
+#define NO_CONG_V(x) ((x) << NO_CONG_S)
+#define NO_CONG_F    NO_CONG_V(1U)
+
+#define DELACK_S    5
+#define DELACK_V(x) ((x) << DELACK_S)
+#define DELACK_F    DELACK_V(1U)
+
+#define DSCP_S    22
+#define DSCP_M    0x3F
+#define DSCP_V(x) ((x) << DSCP_S)
+#define DSCP_G(x) (((x) >> DSCP_S) & DSCP_M)
+
+#define TCAM_BYPASS_S    48
+#define TCAM_BYPASS_V(x) ((__u64)(x) << TCAM_BYPASS_S)
+#define TCAM_BYPASS_F    TCAM_BYPASS_V(1ULL)
+
+#define NAGLE_S    49
+#define NAGLE_V(x) ((__u64)(x) << NAGLE_S)
+#define NAGLE_F    NAGLE_V(1ULL)
+
+/* option 1 fields */
+#define SYN_RSS_ENABLE_S    0
+#define SYN_RSS_ENABLE_V(x) ((x) << SYN_RSS_ENABLE_S)
+#define SYN_RSS_ENABLE_F    SYN_RSS_ENABLE_V(1U)
+
+#define SYN_RSS_QUEUE_S    2
+#define SYN_RSS_QUEUE_V(x) ((x) << SYN_RSS_QUEUE_S)
+
+#define CONN_POLICY_S    22
+#define CONN_POLICY_V(x) ((x) << CONN_POLICY_S)
+
 struct cpl_pass_open_req6 {
 	WR_HDR;
 	union opcode_tid ot;
@@ -304,16 +348,37 @@ struct cpl_pass_accept_rpl {
 	WR_HDR;
 	union opcode_tid ot;
 	__be32 opt2;
-#define RX_COALESCE_VALID(x) ((x) << 11)
-#define RX_COALESCE(x)       ((x) << 12)
-#define PACE(x)	      ((x) << 16)
-#define TX_QUEUE(x)          ((x) << 23)
-#define CCTRL_ECN(x)         ((x) << 27)
-#define TSTAMPS_EN(x)        ((x) << 29)
-#define SACK_EN(x)           ((x) << 30)
 	__be64 opt0;
 };
 
+/* option 2 fields */
+#define RX_COALESCE_VALID_S    11
+#define RX_COALESCE_VALID_V(x) ((x) << RX_COALESCE_VALID_S)
+#define RX_COALESCE_VALID_F    RX_COALESCE_VALID_V(1U)
+
+#define RX_COALESCE_S    12
+#define RX_COALESCE_V(x) ((x) << RX_COALESCE_S)
+
+#define PACE_S    16
+#define PACE_V(x) ((x) << PACE_S)
+
+#define TX_QUEUE_S    23
+#define TX_QUEUE_M    0x7
+#define TX_QUEUE_V(x) ((x) << TX_QUEUE_S)
+#define TX_QUEUE_G(x) (((x) >> TX_QUEUE_S) & TX_QUEUE_M)
+
+#define CCTRL_ECN_S    27
+#define CCTRL_ECN_V(x) ((x) << CCTRL_ECN_S)
+#define CCTRL_ECN_F    CCTRL_ECN_V(1U)
+
+#define TSTAMPS_EN_S    29
+#define TSTAMPS_EN_V(x) ((x) << TSTAMPS_EN_S)
+#define TSTAMPS_EN_F    TSTAMPS_EN_V(1U)
+
+#define SACK_EN_S    30
+#define SACK_EN_V(x) ((x) << SACK_EN_S)
+#define SACK_EN_F    SACK_EN_V(1U)
+
 struct cpl_t5_pass_accept_rpl {
 	WR_HDR;
 	union opcode_tid ot;
@@ -384,30 +449,61 @@ struct cpl_t5_act_open_req6 {
 struct cpl_act_open_rpl {
 	union opcode_tid ot;
 	__be32 atid_status;
-#define GET_AOPEN_STATUS(x) ((x) & 0xff)
-#define GET_AOPEN_ATID(x)   (((x) >> 8) & 0xffffff)
 };
 
+/* cpl_act_open_rpl.atid_status fields */
+#define AOPEN_STATUS_S    0
+#define AOPEN_STATUS_M    0xFF
+#define AOPEN_STATUS_G(x) (((x) >> AOPEN_STATUS_S) & AOPEN_STATUS_M)
+
+#define AOPEN_ATID_S    8
+#define AOPEN_ATID_M    0xFFFFFF
+#define AOPEN_ATID_G(x) (((x) >> AOPEN_ATID_S) & AOPEN_ATID_M)
+
 struct cpl_pass_establish {
 	union opcode_tid ot;
 	__be32 rsvd;
 	__be32 tos_stid;
-#define PASS_OPEN_TID(x) ((x) << 0)
-#define PASS_OPEN_TOS(x) ((x) << 24)
-#define GET_PASS_OPEN_TID(x)	(((x) >> 0) & 0xFFFFFF)
-#define GET_POPEN_TID(x) ((x) & 0xffffff)
-#define GET_POPEN_TOS(x) (((x) >> 24) & 0xff)
 	__be16 mac_idx;
 	__be16 tcp_opt;
-#define GET_TCPOPT_WSCALE_OK(x)  (((x) >> 5) & 1)
-#define GET_TCPOPT_SACK(x)       (((x) >> 6) & 1)
-#define GET_TCPOPT_TSTAMP(x)     (((x) >> 7) & 1)
-#define GET_TCPOPT_SND_WSCALE(x) (((x) >> 8) & 0xf)
-#define GET_TCPOPT_MSS(x)        (((x) >> 12) & 0xf)
 	__be32 snd_isn;
 	__be32 rcv_isn;
 };
 
+/* cpl_pass_establish.tos_stid fields */
+#define PASS_OPEN_TID_S    0
+#define PASS_OPEN_TID_M    0xFFFFFF
+#define PASS_OPEN_TID_V(x) ((x) << PASS_OPEN_TID_S)
+#define PASS_OPEN_TID_G(x) (((x) >> PASS_OPEN_TID_S) & PASS_OPEN_TID_M)
+
+#define PASS_OPEN_TOS_S    24
+#define PASS_OPEN_TOS_M    0xFF
+#define PASS_OPEN_TOS_V(x) ((x) << PASS_OPEN_TOS_S)
+#define PASS_OPEN_TOS_G(x) (((x) >> PASS_OPEN_TOS_S) & PASS_OPEN_TOS_M)
+
+/* cpl_pass_establish.tcp_opt fields (also applies to act_open_establish) */
+#define TCPOPT_WSCALE_OK_S	5
+#define TCPOPT_WSCALE_OK_M	0x1
+#define TCPOPT_WSCALE_OK_G(x)	\
+	(((x) >> TCPOPT_WSCALE_OK_S) & TCPOPT_WSCALE_OK_M)
+
+#define TCPOPT_SACK_S		6
+#define TCPOPT_SACK_M		0x1
+#define TCPOPT_SACK_G(x)	(((x) >> TCPOPT_SACK_S) & TCPOPT_SACK_M)
+
+#define TCPOPT_TSTAMP_S		7
+#define TCPOPT_TSTAMP_M		0x1
+#define TCPOPT_TSTAMP_G(x)	(((x) >> TCPOPT_TSTAMP_S) & TCPOPT_TSTAMP_M)
+
+#define TCPOPT_SND_WSCALE_S	8
+#define TCPOPT_SND_WSCALE_M	0xF
+#define TCPOPT_SND_WSCALE_G(x)	\
+	(((x) >> TCPOPT_SND_WSCALE_S) & TCPOPT_SND_WSCALE_M)
+
+#define TCPOPT_MSS_S	12
+#define TCPOPT_MSS_M	0xF
+#define TCPOPT_MSS_G(x)	(((x) >> TCPOPT_MSS_S) & TCPOPT_MSS_M)
+
 struct cpl_act_establish {
 	union opcode_tid ot;
 	__be32 rsvd;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 7bfbacd63f7a..4591d934e221 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -450,7 +450,7 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		/* FW can send EGR_UPDATEs encapsulated in a CPL_FW4_MSG.
 		 */
 		const struct cpl_sge_egr_update *p = (void *)(rsp + 3);
-		opcode = G_CPL_OPCODE(ntohl(p->opcode_qid));
+		opcode = CPL_OPCODE_G(ntohl(p->opcode_qid));
 		if (opcode != CPL_SGE_EGR_UPDATE) {
 			dev_err(adapter->pdev_dev, "unexpected FW4/CPL %#x on FW event queue\n"
 				, opcode);
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index a83d2ceded83..c3f2b973149b 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -704,7 +704,7 @@ static void do_act_establish(struct cxgbi_device *cdev, struct sk_buff *skb)
 	struct cpl_act_establish *req = (struct cpl_act_establish *)skb->data;
 	unsigned short tcp_opt = ntohs(req->tcp_opt);
 	unsigned int tid = GET_TID(req);
-	unsigned int atid = GET_TID_TID(ntohl(req->tos_atid));
+	unsigned int atid = TID_TID_G(ntohl(req->tos_atid));
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
 	struct tid_info *t = lldi->tids;
 	u32 rcv_isn = be32_to_cpu(req->rcv_isn);
@@ -752,15 +752,15 @@ static void do_act_establish(struct cxgbi_device *cdev, struct sk_buff *skb)
 	if (cxgb4i_rcv_win > (RCV_BUFSIZ_MASK << 10))
 		csk->rcv_wup -= cxgb4i_rcv_win - (RCV_BUFSIZ_MASK << 10);
 
-	csk->advmss = lldi->mtus[GET_TCPOPT_MSS(tcp_opt)] - 40;
-	if (GET_TCPOPT_TSTAMP(tcp_opt))
+	csk->advmss = lldi->mtus[TCPOPT_MSS_G(tcp_opt)] - 40;
+	if (TCPOPT_TSTAMP_G(tcp_opt))
 		csk->advmss -= 12;
 	if (csk->advmss < 128)
 		csk->advmss = 128;
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p, mss_idx %u, advmss %u.\n",
-			csk, GET_TCPOPT_MSS(tcp_opt), csk->advmss);
+			csk, TCPOPT_MSS_G(tcp_opt), csk->advmss);
 
 	cxgbi_sock_established(csk, ntohl(req->snd_isn), ntohs(req->tcp_opt));
 
@@ -856,8 +856,8 @@ static void do_act_open_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 	struct cpl_act_open_rpl *rpl = (struct cpl_act_open_rpl *)skb->data;
 	unsigned int tid = GET_TID(rpl);
 	unsigned int atid =
-		GET_TID_TID(GET_AOPEN_ATID(be32_to_cpu(rpl->atid_status)));
-	unsigned int status = GET_AOPEN_STATUS(be32_to_cpu(rpl->atid_status));
+		TID_TID_G(AOPEN_ATID_G(be32_to_cpu(rpl->atid_status)));
+	unsigned int status = AOPEN_STATUS_G(be32_to_cpu(rpl->atid_status));
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
 	struct tid_info *t = lldi->tids;
 
-- 
2.2.1

