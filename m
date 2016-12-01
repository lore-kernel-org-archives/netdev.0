From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH scsi 2/3] scsi: cxgb4i,libcxgbi: add active open cmd for T6 adapters
Date: Thu,  1 Dec 2016 20:28:28 +0530
Message-ID: <94d4589a810d160ae239d5c79d59580495105b6d.1480603332.git.varun@chelsio.com>
References: <cover.1480603332.git.varun@chelsio.com>
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net, indranil@chelsio.com, varun@chelsio.com
To: martin.petersen@oracle.com, jejb@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:64920 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759213AbcLAO7q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 09:59:46 -0500
In-Reply-To: <cover.1480603332.git.varun@chelsio.com>
In-Reply-To: <cover.1480603332.git.varun@chelsio.com>
References: <cover.1480603332.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add T6 active open cmd to open active connections
on T6 adapters.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 86 ++++++++++++++++++++++++++++++++------
 drivers/scsi/cxgbi/libcxgbi.c      |  6 +--
 2 files changed, 77 insertions(+), 15 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 90522d4..a6fc990 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -188,7 +188,6 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 				struct l2t_entry *e)
 {
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(csk->cdev);
-	int t4 = is_t4(lldi->adapter_type);
 	int wscale = cxgbi_sock_compute_wscale(csk->mss_idx);
 	unsigned long long opt0;
 	unsigned int opt2;
@@ -231,7 +230,7 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 			csk, &req->local_ip, ntohs(req->local_port),
 			&req->peer_ip, ntohs(req->peer_port),
 			csk->atid, csk->rss_qid);
-	} else {
+	} else if (is_t5(lldi->adapter_type)) {
 		struct cpl_t5_act_open_req *req =
 				(struct cpl_t5_act_open_req *)skb->head;
 		u32 isn = (prandom_u32() & ~7UL) - 1;
@@ -259,12 +258,45 @@ static void send_act_open_req(struct cxgbi_sock *csk, struct sk_buff *skb,
 			csk, &req->local_ip, ntohs(req->local_port),
 			&req->peer_ip, ntohs(req->peer_port),
 			csk->atid, csk->rss_qid);
+	} else {
+		struct cpl_t6_act_open_req *req =
+				(struct cpl_t6_act_open_req *)skb->head;
+		u32 isn = (prandom_u32() & ~7UL) - 1;
+
+		INIT_TP_WR(req, 0);
+		OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+							    qid_atid));
+		req->local_port = csk->saddr.sin_port;
+		req->peer_port = csk->daddr.sin_port;
+		req->local_ip = csk->saddr.sin_addr.s_addr;
+		req->peer_ip = csk->daddr.sin_addr.s_addr;
+		req->opt0 = cpu_to_be64(opt0);
+		req->params = cpu_to_be64(FILTER_TUPLE_V(
+				cxgb4_select_ntuple(
+					csk->cdev->ports[csk->port_id],
+					csk->l2t)));
+		req->rsvd = cpu_to_be32(isn);
+
+		opt2 |= T5_ISS_VALID;
+		opt2 |= RX_FC_DISABLE_F;
+		opt2 |= T5_OPT_2_VALID_F;
+
+		req->opt2 = cpu_to_be32(opt2);
+		req->rsvd2 = cpu_to_be32(0);
+		req->opt3 = cpu_to_be32(0);
+
+		log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
+			  "csk t6 0x%p, %pI4:%u-%pI4:%u, atid %d, qid %u.\n",
+			  csk, &req->local_ip, ntohs(req->local_port),
+			  &req->peer_ip, ntohs(req->peer_port),
+			  csk->atid, csk->rss_qid);
 	}
 
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, csk->port_id);
 
 	pr_info_ipaddr("t%d csk 0x%p,%u,0x%lx,%u, rss_qid %u.\n",
-		       (&csk->saddr), (&csk->daddr), t4 ? 4 : 5, csk,
+		       (&csk->saddr), (&csk->daddr),
+		       CHELSIO_CHIP_VERSION(lldi->adapter_type), csk,
 		       csk->state, csk->flags, csk->atid, csk->rss_qid);
 
 	cxgb4_l2t_send(csk->cdev->ports[csk->port_id], skb, csk->l2t);
@@ -275,7 +307,6 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 			       struct l2t_entry *e)
 {
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(csk->cdev);
-	int t4 = is_t4(lldi->adapter_type);
 	int wscale = cxgbi_sock_compute_wscale(csk->mss_idx);
 	unsigned long long opt0;
 	unsigned int opt2;
@@ -293,10 +324,9 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 
 	opt2 = RX_CHANNEL_V(0) |
 		RSS_QUEUE_VALID_F |
-		RX_FC_DISABLE_F |
 		RSS_QUEUE_V(csk->rss_qid);
 
-	if (t4) {
+	if (is_t4(lldi->adapter_type)) {
 		struct cpl_act_open_req6 *req =
 			    (struct cpl_act_open_req6 *)skb->head;
 
@@ -321,7 +351,7 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 		req->params = cpu_to_be32(cxgb4_select_ntuple(
 					  csk->cdev->ports[csk->port_id],
 					  csk->l2t));
-	} else {
+	} else if (is_t5(lldi->adapter_type)) {
 		struct cpl_t5_act_open_req6 *req =
 				(struct cpl_t5_act_open_req6 *)skb->head;
 
@@ -344,12 +374,41 @@ static void send_act_open_req6(struct cxgbi_sock *csk, struct sk_buff *skb,
 		req->params = cpu_to_be64(FILTER_TUPLE_V(cxgb4_select_ntuple(
 					  csk->cdev->ports[csk->port_id],
 					  csk->l2t)));
+	} else {
+		struct cpl_t6_act_open_req6 *req =
+				(struct cpl_t6_act_open_req6 *)skb->head;
+
+		INIT_TP_WR(req, 0);
+		OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
+							    qid_atid));
+		req->local_port = csk->saddr6.sin6_port;
+		req->peer_port = csk->daddr6.sin6_port;
+		req->local_ip_hi = *(__be64 *)(csk->saddr6.sin6_addr.s6_addr);
+		req->local_ip_lo = *(__be64 *)(csk->saddr6.sin6_addr.s6_addr +
+									8);
+		req->peer_ip_hi = *(__be64 *)(csk->daddr6.sin6_addr.s6_addr);
+		req->peer_ip_lo = *(__be64 *)(csk->daddr6.sin6_addr.s6_addr +
+									8);
+		req->opt0 = cpu_to_be64(opt0);
+
+		opt2 |= RX_FC_DISABLE_F;
+		opt2 |= T5_OPT_2_VALID_F;
+
+		req->opt2 = cpu_to_be32(opt2);
+
+		req->params = cpu_to_be64(FILTER_TUPLE_V(cxgb4_select_ntuple(
+					  csk->cdev->ports[csk->port_id],
+					  csk->l2t)));
+
+		req->rsvd2 = cpu_to_be32(0);
+		req->opt3 = cpu_to_be32(0);
 	}
 
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, csk->port_id);
 
 	pr_info("t%d csk 0x%p,%u,0x%lx,%u, [%pI6]:%u-[%pI6]:%u, rss_qid %u.\n",
-		t4 ? 4 : 5, csk, csk->state, csk->flags, csk->atid,
+		CHELSIO_CHIP_VERSION(lldi->adapter_type), csk, csk->state,
+		csk->flags, csk->atid,
 		&csk->saddr6.sin6_addr, ntohs(csk->saddr.sin_port),
 		&csk->daddr6.sin6_addr, ntohs(csk->daddr.sin_port),
 		csk->rss_qid);
@@ -1381,7 +1440,6 @@ static int init_act_open(struct cxgbi_sock *csk)
 	void *daddr;
 	unsigned int step;
 	unsigned int size, size6;
-	int t4 = is_t4(lldi->adapter_type);
 	unsigned int linkspeed;
 	unsigned int rcv_winf, snd_winf;
 
@@ -1427,12 +1485,15 @@ static int init_act_open(struct cxgbi_sock *csk)
 		cxgb4_clip_get(ndev, (const u32 *)&csk->saddr6.sin6_addr, 1);
 #endif
 
-	if (t4) {
+	if (is_t4(lldi->adapter_type)) {
 		size = sizeof(struct cpl_act_open_req);
 		size6 = sizeof(struct cpl_act_open_req6);
-	} else {
+	} else if (is_t5(lldi->adapter_type)) {
 		size = sizeof(struct cpl_t5_act_open_req);
 		size6 = sizeof(struct cpl_t5_act_open_req6);
+	} else {
+		size = sizeof(struct cpl_t6_act_open_req);
+		size6 = sizeof(struct cpl_t6_act_open_req6);
 	}
 
 	if (csk->csk_family == AF_INET)
@@ -1793,7 +1854,8 @@ static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 	cdev->nports = lldi->nports;
 	cdev->mtus = lldi->mtus;
 	cdev->nmtus = NMTUS;
-	cdev->rx_credit_thres = cxgb4i_rx_credit_thres;
+	cdev->rx_credit_thres = (CHELSIO_CHIP_VERSION(lldi->adapter_type) <=
+				 CHELSIO_T5) ? cxgb4i_rx_credit_thres : 0;
 	cdev->skb_tx_rsvd = CXGB4I_TX_HEADER_LEN;
 	cdev->skb_rx_extra = sizeof(struct cpl_iscsi_hdr);
 	cdev->itp = &cxgb4i_iscsi_transport;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 2ffe029..5423378 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1627,15 +1627,15 @@ static void csk_return_rx_credits(struct cxgbi_sock *csk, int copied)
 		csk->rcv_wup, cdev->rx_credit_thres,
 		csk->rcv_win);
 
+	if (!cdev->rx_credit_thres)
+		return;
+
 	if (csk->state != CTP_ESTABLISHED)
 		return;
 
 	credits = csk->copied_seq - csk->rcv_wup;
 	if (unlikely(!credits))
 		return;
-	if (unlikely(cdev->rx_credit_thres == 0))
-		return;
-
 	must_send = credits + 16384 >= csk->rcv_win;
 	if (must_send || credits >= cdev->rx_credit_thres)
 		csk->rcv_wup += cdev->csk_send_rx_credits(csk, credits);
-- 
2.0.2
