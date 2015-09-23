From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 2/2] iw_cxgb4: Adds support for T6 adapter
Date: Wed, 23 Sep 2015 17:19:27 +0530
Message-ID: <1443008967-8942-3-git-send-email-hariprasad@chelsio.com>
References: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford@redhat.com, davem@davemloft.net,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6171 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754304AbbIWLtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:49:16 -0400
In-Reply-To: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c       | 317 ++++++++++++++++++++-------------
 drivers/infiniband/hw/cxgb4/device.c   |  10 +-
 drivers/infiniband/hw/cxgb4/provider.c |   2 +-
 drivers/infiniband/hw/cxgb4/qp.c       |  16 +-
 drivers/infiniband/hw/cxgb4/t4.h       |   5 +-
 5 files changed, 204 insertions(+), 146 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 6c02211..c9cffce 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -632,22 +632,18 @@ static void best_mtu(const unsigned short *mtus, unsigned short mtu,
 
 static int send_connect(struct c4iw_ep *ep)
 {
-	struct cpl_act_open_req *req;
-	struct cpl_t5_act_open_req *t5_req;
-	struct cpl_act_open_req6 *req6;
-	struct cpl_t5_act_open_req6 *t5_req6;
+	struct cpl_act_open_req *req = NULL;
+	struct cpl_t5_act_open_req *t5req = NULL;
+	struct cpl_t6_act_open_req *t6req = NULL;
+	struct cpl_act_open_req6 *req6 = NULL;
+	struct cpl_t5_act_open_req6 *t5req6 = NULL;
+	struct cpl_t6_act_open_req6 *t6req6 = NULL;
 	struct sk_buff *skb;
 	u64 opt0;
 	u32 opt2;
 	unsigned int mtu_idx;
 	int wscale;
-	int wrlen;
-	int sizev4 = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
-				sizeof(struct cpl_act_open_req) :
-				sizeof(struct cpl_t5_act_open_req);
-	int sizev6 = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
-				sizeof(struct cpl_act_open_req6) :
-				sizeof(struct cpl_t5_act_open_req6);
+	int win, sizev4, sizev6, wrlen;
 	struct sockaddr_in *la = (struct sockaddr_in *)
 				 &ep->com.mapped_local_addr;
 	struct sockaddr_in *ra = (struct sockaddr_in *)
@@ -656,8 +652,28 @@ static int send_connect(struct c4iw_ep *ep)
 				   &ep->com.mapped_local_addr;
 	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)
 				   &ep->com.mapped_remote_addr;
-	int win;
 	int ret;
+	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
+	u32 isn = (prandom_u32() & ~7UL) - 1;
+
+	switch (CHELSIO_CHIP_VERSION(adapter_type)) {
+	case CHELSIO_T4:
+		sizev4 = sizeof(struct cpl_act_open_req);
+		sizev6 = sizeof(struct cpl_act_open_req6);
+		break;
+	case CHELSIO_T5:
+		sizev4 = sizeof(struct cpl_t5_act_open_req);
+		sizev6 = sizeof(struct cpl_t5_act_open_req6);
+		break;
+	case CHELSIO_T6:
+		sizev4 = sizeof(struct cpl_t6_act_open_req);
+		sizev6 = sizeof(struct cpl_t6_act_open_req6);
+		break;
+	default:
+		pr_err("T%d Chip is not supported\n",
+		       CHELSIO_CHIP_VERSION(adapter_type));
+		return -EINVAL;
+	}
 
 	wrlen = (ep->com.remote_addr.ss_family == AF_INET) ?
 			roundup(sizev4, 16) :
@@ -706,7 +722,10 @@ static int send_connect(struct c4iw_ep *ep)
 		opt2 |= SACK_EN_F;
 	if (wscale && enable_tcp_window_scaling)
 		opt2 |= WND_SCALE_EN_F;
-	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
+	if (CHELSIO_CHIP_VERSION(adapter_type) > CHELSIO_T4) {
+		if (peer2peer)
+			isn += 4;
+
 		opt2 |= T5_OPT_2_VALID_F;
 		opt2 |= CONG_CNTRL_V(CONG_ALG_TAHOE);
 		opt2 |= T5_ISS_F;
@@ -718,102 +737,109 @@ static int send_connect(struct c4iw_ep *ep)
 
 	t4_set_arp_err_handler(skb, ep, act_open_req_arp_failure);
 
-	if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
-		if (ep->com.remote_addr.ss_family == AF_INET) {
-			req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
+	if (ep->com.remote_addr.ss_family == AF_INET) {
+		switch (CHELSIO_CHIP_VERSION(adapter_type)) {
+		case CHELSIO_T4:
+			req = (struct cpl_act_open_req *)skb_put(skb, wrlen);
 			INIT_TP_WR(req, 0);
-			OPCODE_TID(req) = cpu_to_be32(
-					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
-					((ep->rss_qid << 14) | ep->atid)));
-			req->local_port = la->sin_port;
-			req->peer_port = ra->sin_port;
-			req->local_ip = la->sin_addr.s_addr;
-			req->peer_ip = ra->sin_addr.s_addr;
-			req->opt0 = cpu_to_be64(opt0);
+			break;
+		case CHELSIO_T5:
+			t5req = (struct cpl_t5_act_open_req *)skb_put(skb,
+					wrlen);
+			INIT_TP_WR(t5req, 0);
+			req = (struct cpl_act_open_req *)t5req;
+			break;
+		case CHELSIO_T6:
+			t6req = (struct cpl_t6_act_open_req *)skb_put(skb,
+					wrlen);
+			INIT_TP_WR(t6req, 0);
+			req = (struct cpl_act_open_req *)t6req;
+			t5req = (struct cpl_t5_act_open_req *)t6req;
+			break;
+		default:
+			pr_err("T%d Chip is not supported\n",
+			       CHELSIO_CHIP_VERSION(adapter_type));
+			ret = -EINVAL;
+			goto clip_release;
+		}
+
+		OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+					((ep->rss_qid<<14) | ep->atid)));
+		req->local_port = la->sin_port;
+		req->peer_port = ra->sin_port;
+		req->local_ip = la->sin_addr.s_addr;
+		req->peer_ip = ra->sin_addr.s_addr;
+		req->opt0 = cpu_to_be64(opt0);
+
+		if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
 			req->params = cpu_to_be32(cxgb4_select_ntuple(
 						ep->com.dev->rdev.lldi.ports[0],
 						ep->l2t));
 			req->opt2 = cpu_to_be32(opt2);
 		} else {
+			t5req->params = cpu_to_be64(FILTER_TUPLE_V(
+						cxgb4_select_ntuple(
+						ep->com.dev->rdev.lldi.ports[0],
+						ep->l2t)));
+			t5req->rsvd = cpu_to_be32(isn);
+			PDBG("%s snd_isn %u\n", __func__, t5req->rsvd);
+			t5req->opt2 = cpu_to_be32(opt2);
+		}
+	} else {
+		switch (CHELSIO_CHIP_VERSION(adapter_type)) {
+		case CHELSIO_T4:
 			req6 = (struct cpl_act_open_req6 *)skb_put(skb, wrlen);
-
 			INIT_TP_WR(req6, 0);
-			OPCODE_TID(req6) = cpu_to_be32(
-					   MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
-					   ((ep->rss_qid<<14)|ep->atid)));
-			req6->local_port = la6->sin6_port;
-			req6->peer_port = ra6->sin6_port;
-			req6->local_ip_hi = *((__be64 *)
-						(la6->sin6_addr.s6_addr));
-			req6->local_ip_lo = *((__be64 *)
-						(la6->sin6_addr.s6_addr + 8));
-			req6->peer_ip_hi = *((__be64 *)
-						(ra6->sin6_addr.s6_addr));
-			req6->peer_ip_lo = *((__be64 *)
-						(ra6->sin6_addr.s6_addr + 8));
-			req6->opt0 = cpu_to_be64(opt0);
+			break;
+		case CHELSIO_T5:
+			t5req6 = (struct cpl_t5_act_open_req6 *)skb_put(skb,
+					wrlen);
+			INIT_TP_WR(t5req6, 0);
+			req6 = (struct cpl_act_open_req6 *)t5req6;
+			break;
+		case CHELSIO_T6:
+			t6req6 = (struct cpl_t6_act_open_req6 *)skb_put(skb,
+					wrlen);
+			INIT_TP_WR(t6req6, 0);
+			req6 = (struct cpl_act_open_req6 *)t6req6;
+			t5req6 = (struct cpl_t5_act_open_req6 *)t6req6;
+			break;
+		default:
+			pr_err("T%d Chip is not supported\n",
+			       CHELSIO_CHIP_VERSION(adapter_type));
+			ret = -EINVAL;
+			goto clip_release;
+		}
+
+		OPCODE_TID(req6) = cpu_to_be32(MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
+					((ep->rss_qid<<14)|ep->atid)));
+		req6->local_port = la6->sin6_port;
+		req6->peer_port = ra6->sin6_port;
+		req6->local_ip_hi = *((__be64 *)(la6->sin6_addr.s6_addr));
+		req6->local_ip_lo = *((__be64 *)(la6->sin6_addr.s6_addr + 8));
+		req6->peer_ip_hi = *((__be64 *)(ra6->sin6_addr.s6_addr));
+		req6->peer_ip_lo = *((__be64 *)(ra6->sin6_addr.s6_addr + 8));
+		req6->opt0 = cpu_to_be64(opt0);
+
+		if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
 			req6->params = cpu_to_be32(cxgb4_select_ntuple(
 						ep->com.dev->rdev.lldi.ports[0],
 						ep->l2t));
 			req6->opt2 = cpu_to_be32(opt2);
-		}
-	} else {
-		u32 isn = (prandom_u32() & ~7UL) - 1;
-
-		if (peer2peer)
-			isn += 4;
-
-		if (ep->com.remote_addr.ss_family == AF_INET) {
-			t5_req = (struct cpl_t5_act_open_req *)
-				 skb_put(skb, wrlen);
-			INIT_TP_WR(t5_req, 0);
-			OPCODE_TID(t5_req) = cpu_to_be32(
-					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
-					((ep->rss_qid << 14) | ep->atid)));
-			t5_req->local_port = la->sin_port;
-			t5_req->peer_port = ra->sin_port;
-			t5_req->local_ip = la->sin_addr.s_addr;
-			t5_req->peer_ip = ra->sin_addr.s_addr;
-			t5_req->opt0 = cpu_to_be64(opt0);
-			t5_req->params = cpu_to_be64(FILTER_TUPLE_V(
-						     cxgb4_select_ntuple(
-					     ep->com.dev->rdev.lldi.ports[0],
-					     ep->l2t)));
-			t5_req->rsvd = cpu_to_be32(isn);
-			PDBG("%s snd_isn %u\n", __func__,
-			     be32_to_cpu(t5_req->rsvd));
-			t5_req->opt2 = cpu_to_be32(opt2);
 		} else {
-			t5_req6 = (struct cpl_t5_act_open_req6 *)
-				  skb_put(skb, wrlen);
-			INIT_TP_WR(t5_req6, 0);
-			OPCODE_TID(t5_req6) = cpu_to_be32(
-					      MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
-					      ((ep->rss_qid<<14)|ep->atid)));
-			t5_req6->local_port = la6->sin6_port;
-			t5_req6->peer_port = ra6->sin6_port;
-			t5_req6->local_ip_hi = *((__be64 *)
-						(la6->sin6_addr.s6_addr));
-			t5_req6->local_ip_lo = *((__be64 *)
-						(la6->sin6_addr.s6_addr + 8));
-			t5_req6->peer_ip_hi = *((__be64 *)
-						(ra6->sin6_addr.s6_addr));
-			t5_req6->peer_ip_lo = *((__be64 *)
-						(ra6->sin6_addr.s6_addr + 8));
-			t5_req6->opt0 = cpu_to_be64(opt0);
-			t5_req6->params = cpu_to_be64(FILTER_TUPLE_V(
-							cxgb4_select_ntuple(
+			t5req6->params = cpu_to_be64(FILTER_TUPLE_V(
+						cxgb4_select_ntuple(
 						ep->com.dev->rdev.lldi.ports[0],
 						ep->l2t)));
-			t5_req6->rsvd = cpu_to_be32(isn);
-			PDBG("%s snd_isn %u\n", __func__,
-			     be32_to_cpu(t5_req6->rsvd));
-			t5_req6->opt2 = cpu_to_be32(opt2);
+			t5req6->rsvd = cpu_to_be32(isn);
+			PDBG("%s snd_isn %u\n", __func__, t5req6->rsvd);
+			t5req6->opt2 = cpu_to_be32(opt2);
 		}
 	}
 
 	set_bit(ACT_OPEN_REQ, &ep->com.history);
 	ret = c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
+clip_release:
 	if (ret && ep->com.remote_addr.ss_family == AF_INET6)
 		cxgb4_clip_release(ep->com.dev->rdev.lldi.ports[0],
 				   (const u32 *)&la6->sin6_addr.s6_addr, 1);
@@ -1902,7 +1928,7 @@ static void set_tcp_window(struct c4iw_ep *ep, struct port_info *pi)
 
 static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 		     struct dst_entry *dst, struct c4iw_dev *cdev,
-		     bool clear_mpa_v1)
+		     bool clear_mpa_v1, enum chip_type adapter_type)
 {
 	struct neighbour *n;
 	int err, step;
@@ -1937,7 +1963,8 @@ static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 			goto out;
 		ep->mtu = pdev->mtu;
 		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
+		ep->smac_idx = cxgb4_tp_smt_idx(adapter_type,
+						cxgb4_port_viid(pdev));
 		step = cdev->rdev.lldi.ntxq /
 			cdev->rdev.lldi.nchan;
 		ep->txq_idx = cxgb4_port_idx(pdev) * step;
@@ -1956,7 +1983,8 @@ static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 			goto out;
 		ep->mtu = dst_mtu(dst);
 		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
+		ep->smac_idx = cxgb4_tp_smt_idx(adapter_type,
+						cxgb4_port_viid(pdev));
 		step = cdev->rdev.lldi.ntxq /
 			cdev->rdev.lldi.nchan;
 		ep->txq_idx = cxgb4_port_idx(pdev) * step;
@@ -2029,7 +2057,8 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 		err = -EHOSTUNREACH;
 		goto fail3;
 	}
-	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, false);
+	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, false,
+			ep->com.dev->rdev.lldi.adapter_type);
 	if (err) {
 		pr_err("%s - cannot alloc l2e.\n", __func__);
 		goto fail4;
@@ -2217,13 +2246,14 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 	int wscale;
 	struct cpl_t5_pass_accept_rpl *rpl5 = NULL;
 	int win;
+	enum chip_type adapter_type = ep->com.dev->rdev.lldi.adapter_type;
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	BUG_ON(skb_cloned(skb));
 
 	skb_get(skb);
 	rpl = cplhdr(skb);
-	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
+	if (!is_t4(adapter_type)) {
 		skb_trim(skb, roundup(sizeof(*rpl5), 16));
 		rpl5 = (void *)rpl;
 		INIT_TP_WR(rpl5, ep->hwtid);
@@ -2270,12 +2300,16 @@ static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 		const struct tcphdr *tcph;
 		u32 hlen = ntohl(req->hdr_len);
 
-		tcph = (const void *)(req + 1) + ETH_HDR_LEN_G(hlen) +
-			IP_HDR_LEN_G(hlen);
+		if (CHELSIO_CHIP_VERSION(adapter_type) <= CHELSIO_T5)
+			tcph = (const void *)(req + 1) + ETH_HDR_LEN_G(hlen) +
+				IP_HDR_LEN_G(hlen);
+		else
+			tcph = (const void *)(req + 1) +
+				T6_ETH_HDR_LEN_G(hlen) + T6_IP_HDR_LEN_G(hlen);
 		if (tcph->ece && tcph->cwr)
 			opt2 |= CCTRL_ECN_V(1);
 	}
-	if (is_t5(ep->com.dev->rdev.lldi.adapter_type)) {
+	if (CHELSIO_CHIP_VERSION(adapter_type) > CHELSIO_T4) {
 		u32 isn = (prandom_u32() & ~7UL) - 1;
 		opt2 |= T5_OPT_2_VALID_F;
 		opt2 |= CONG_CNTRL_V(CONG_ALG_TAHOE);
@@ -2306,12 +2340,16 @@ static void reject_cr(struct c4iw_dev *dev, u32 hwtid, struct sk_buff *skb)
 	return;
 }
 
-static void get_4tuple(struct cpl_pass_accept_req *req, int *iptype,
-		       __u8 *local_ip, __u8 *peer_ip,
+static void get_4tuple(struct cpl_pass_accept_req *req, enum chip_type type,
+		       int *iptype, __u8 *local_ip, __u8 *peer_ip,
 		       __be16 *local_port, __be16 *peer_port)
 {
-	int eth_len = ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
-	int ip_len = IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
+	int eth_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
+		      ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
+		      T6_ETH_HDR_LEN_G(be32_to_cpu(req->hdr_len));
+	int ip_len = (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) ?
+		     IP_HDR_LEN_G(be32_to_cpu(req->hdr_len)) :
+		     T6_IP_HDR_LEN_G(be32_to_cpu(req->hdr_len));
 	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
 	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
 	struct tcphdr *tcp = (struct tcphdr *)
@@ -2366,7 +2404,8 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	get_4tuple(req, &iptype, local_ip, peer_ip, &local_port, &peer_port);
+	get_4tuple(req, parent_ep->com.dev->rdev.lldi.adapter_type, &iptype,
+		   local_ip, peer_ip, &local_port, &peer_port);
 
 	/* Find output route */
 	if (iptype == 4)  {
@@ -2401,7 +2440,8 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	err = import_ep(child_ep, iptype, peer_ip, dst, dev, false);
+	err = import_ep(child_ep, iptype, peer_ip, dst, dev, false,
+			parent_ep->com.dev->rdev.lldi.adapter_type);
 	if (err) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -3193,7 +3233,8 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		goto fail2;
 	}
 
-	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, true);
+	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, true,
+			ep->com.dev->rdev.lldi.adapter_type);
 	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		goto fail3;
@@ -3601,20 +3642,23 @@ static int deferred_fw6_msg(struct c4iw_dev *dev, struct sk_buff *skb)
 
 static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 {
-	u32 l2info;
-	u16 vlantag, len, hdr_len, eth_hdr_len;
+	__be32 l2info;
+	__be16 hdr_len, vlantag, len;
+	u16 eth_hdr_len;
+	int tcp_hdr_len, ip_hdr_len;
 	u8 intf;
 	struct cpl_rx_pkt *cpl = cplhdr(skb);
 	struct cpl_pass_accept_req *req;
 	struct tcp_options_received tmp_opt;
 	struct c4iw_dev *dev;
+	enum chip_type type;
 
 	dev = *((struct c4iw_dev **) (skb->cb + sizeof(void *)));
 	/* Store values from cpl_rx_pkt in temporary location. */
-	vlantag = (__force u16) cpl->vlan;
-	len = (__force u16) cpl->len;
-	l2info  = (__force u32) cpl->l2info;
-	hdr_len = (__force u16) cpl->hdr_len;
+	vlantag = cpl->vlan;
+	len = cpl->len;
+	l2info  = cpl->l2info;
+	hdr_len = cpl->hdr_len;
 	intf = cpl->iff;
 
 	__skb_pull(skb, sizeof(*req) + sizeof(struct rss_header));
@@ -3631,20 +3675,28 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 	memset(req, 0, sizeof(*req));
 	req->l2info = cpu_to_be16(SYN_INTF_V(intf) |
 			 SYN_MAC_IDX_V(RX_MACIDX_G(
-			 (__force int) htonl(l2info))) |
+			 be32_to_cpu(l2info))) |
 			 SYN_XACT_MATCH_F);
-	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
-			    RX_ETHHDR_LEN_G((__force int)htonl(l2info)) :
-			    RX_T5_ETHHDR_LEN_G((__force int)htonl(l2info));
-	req->hdr_len = cpu_to_be32(SYN_RX_CHAN_V(RX_CHAN_G(
-					(__force int) htonl(l2info))) |
-				   TCP_HDR_LEN_V(RX_TCPHDR_LEN_G(
-					(__force int) htons(hdr_len))) |
-				   IP_HDR_LEN_V(RX_IPHDR_LEN_G(
-					(__force int) htons(hdr_len))) |
-				   ETH_HDR_LEN_V(RX_ETHHDR_LEN_G(eth_hdr_len)));
-	req->vlan = (__force __be16) vlantag;
-	req->len = (__force __be16) len;
+	type = dev->rdev.lldi.adapter_type;
+	tcp_hdr_len = RX_TCPHDR_LEN_G(be16_to_cpu(hdr_len));
+	ip_hdr_len = RX_IPHDR_LEN_G(be16_to_cpu(hdr_len));
+	req->hdr_len =
+		cpu_to_be32(SYN_RX_CHAN_V(RX_CHAN_G(be32_to_cpu(l2info))));
+	if (CHELSIO_CHIP_VERSION(type) <= CHELSIO_T5) {
+		eth_hdr_len = is_t4(type) ?
+				RX_ETHHDR_LEN_G(be32_to_cpu(l2info)) :
+				RX_T5_ETHHDR_LEN_G(be32_to_cpu(l2info));
+		req->hdr_len |= cpu_to_be32(TCP_HDR_LEN_V(tcp_hdr_len) |
+					    IP_HDR_LEN_V(ip_hdr_len) |
+					    ETH_HDR_LEN_V(eth_hdr_len));
+	} else { /* T6 and later */
+		eth_hdr_len = RX_T6_ETHHDR_LEN_G(be32_to_cpu(l2info));
+		req->hdr_len |= cpu_to_be32(T6_TCP_HDR_LEN_V(tcp_hdr_len) |
+					    T6_IP_HDR_LEN_V(ip_hdr_len) |
+					    T6_ETH_HDR_LEN_V(eth_hdr_len));
+	}
+	req->vlan = vlantag;
+	req->len = len;
 	req->tos_stid = cpu_to_be32(PASS_OPEN_TID_V(stid) |
 				    PASS_OPEN_TOS_V(tos));
 	req->tcpopt.mss = htons(tmp_opt.mss_clamp);
@@ -3763,9 +3815,22 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
-			    RX_ETHHDR_LEN_G(htonl(cpl->l2info)) :
-			    RX_T5_ETHHDR_LEN_G(htonl(cpl->l2info));
+	switch (CHELSIO_CHIP_VERSION(dev->rdev.lldi.adapter_type)) {
+	case CHELSIO_T4:
+		eth_hdr_len = RX_ETHHDR_LEN_G(be32_to_cpu(cpl->l2info));
+		break;
+	case CHELSIO_T5:
+		eth_hdr_len = RX_T5_ETHHDR_LEN_G(be32_to_cpu(cpl->l2info));
+		break;
+	case CHELSIO_T6:
+		eth_hdr_len = RX_T6_ETHHDR_LEN_G(be32_to_cpu(cpl->l2info));
+		break;
+	default:
+		pr_err("T%d Chip is not supported\n",
+		       CHELSIO_CHIP_VERSION(dev->rdev.lldi.adapter_type));
+		goto reject;
+	}
+
 	if (eth_hdr_len == ETH_HLEN) {
 		eh = (struct ethhdr *)(req + 1);
 		iph = (struct iphdr *)(eh + 1);
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 1a29739..58fce174 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -962,12 +962,12 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 		devp->rdev.lldi.sge_egrstatuspagesize;
 
 	/*
-	 * For T5 devices, we map all of BAR2 with WC.
+	 * For T5/T6 devices, we map all of BAR2 with WC.
 	 * For T4 devices with onchip qp mem, we map only that part
 	 * of BAR2 with WC.
 	 */
 	devp->rdev.bar2_pa = pci_resource_start(devp->rdev.lldi.pdev, 2);
-	if (is_t5(devp->rdev.lldi.adapter_type)) {
+	if (!is_t4(devp->rdev.lldi.adapter_type)) {
 		devp->rdev.bar2_kva = ioremap_wc(devp->rdev.bar2_pa,
 			pci_resource_len(devp->rdev.lldi.pdev, 2));
 		if (!devp->rdev.bar2_kva) {
@@ -1267,11 +1267,9 @@ static int enable_qp_db(int id, void *p, void *data)
 static void resume_rc_qp(struct c4iw_qp *qp)
 {
 	spin_lock(&qp->lock);
-	t4_ring_sq_db(&qp->wq, qp->wq.sq.wq_pidx_inc,
-		      is_t5(qp->rhp->rdev.lldi.adapter_type), NULL);
+	t4_ring_sq_db(&qp->wq, qp->wq.sq.wq_pidx_inc, NULL);
 	qp->wq.sq.wq_pidx_inc = 0;
-	t4_ring_rq_db(&qp->wq, qp->wq.rq.wq_pidx_inc,
-		      is_t5(qp->rhp->rdev.lldi.adapter_type), NULL);
+	t4_ring_rq_db(&qp->wq, qp->wq.rq.wq_pidx_inc, NULL);
 	qp->wq.rq.wq_pidx_inc = 0;
 	spin_unlock(&qp->lock);
 }
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 7746113..df3b3f1 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -209,7 +209,7 @@ static int c4iw_mmap(struct ib_ucontext *context, struct vm_area_struct *vma)
 		if (addr >= rdev->oc_mw_pa)
 			vma->vm_page_prot = t4_pgprot_wc(vma->vm_page_prot);
 		else {
-			if (is_t5(rdev->lldi.adapter_type))
+			if (!is_t4(rdev->lldi.adapter_type))
 				vma->vm_page_prot =
 					t4_pgprot_wc(vma->vm_page_prot);
 			else
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 6517e12..acfc2f2 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -712,8 +712,7 @@ static int ring_kernel_sq_db(struct c4iw_qp *qhp, u16 inc)
 	spin_lock_irqsave(&qhp->rhp->lock, flags);
 	spin_lock(&qhp->lock);
 	if (qhp->rhp->db_state == NORMAL)
-		t4_ring_sq_db(&qhp->wq, inc,
-			      is_t5(qhp->rhp->rdev.lldi.adapter_type), NULL);
+		t4_ring_sq_db(&qhp->wq, inc, NULL);
 	else {
 		add_to_fc_list(&qhp->rhp->db_fc_list, &qhp->db_fc_entry);
 		qhp->wq.sq.wq_pidx_inc += inc;
@@ -730,8 +729,7 @@ static int ring_kernel_rq_db(struct c4iw_qp *qhp, u16 inc)
 	spin_lock_irqsave(&qhp->rhp->lock, flags);
 	spin_lock(&qhp->lock);
 	if (qhp->rhp->db_state == NORMAL)
-		t4_ring_rq_db(&qhp->wq, inc,
-			      is_t5(qhp->rhp->rdev.lldi.adapter_type), NULL);
+		t4_ring_rq_db(&qhp->wq, inc, NULL);
 	else {
 		add_to_fc_list(&qhp->rhp->db_fc_list, &qhp->db_fc_entry);
 		qhp->wq.rq.wq_pidx_inc += inc;
@@ -817,7 +815,7 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 			fw_opcode = FW_RI_FR_NSMR_WR;
 			swsqe->opcode = FW_RI_FAST_REGISTER;
 			err = build_fastreg(&qhp->wq.sq, wqe, wr, &len16,
-					    is_t5(
+					    !is_t4(
 					    qhp->rhp->rdev.lldi.adapter_type) ?
 					    1 : 0);
 			break;
@@ -860,8 +858,7 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		idx += DIV_ROUND_UP(len16*16, T4_EQ_ENTRY_SIZE);
 	}
 	if (!qhp->rhp->rdev.status_page->db_off) {
-		t4_ring_sq_db(&qhp->wq, idx,
-			      is_t5(qhp->rhp->rdev.lldi.adapter_type), wqe);
+		t4_ring_sq_db(&qhp->wq, idx, wqe);
 		spin_unlock_irqrestore(&qhp->lock, flag);
 	} else {
 		spin_unlock_irqrestore(&qhp->lock, flag);
@@ -934,8 +931,7 @@ int c4iw_post_receive(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 		num_wrs--;
 	}
 	if (!qhp->rhp->rdev.status_page->db_off) {
-		t4_ring_rq_db(&qhp->wq, idx,
-			      is_t5(qhp->rhp->rdev.lldi.adapter_type), wqe);
+		t4_ring_rq_db(&qhp->wq, idx, wqe);
 		spin_unlock_irqrestore(&qhp->lock, flag);
 	} else {
 		spin_unlock_irqrestore(&qhp->lock, flag);
@@ -1875,7 +1871,7 @@ int c4iw_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 	attrs.rq_db_inc = attr->rq_psn;
 	mask |= (attr_mask & IB_QP_SQ_PSN) ? C4IW_QP_ATTR_SQ_DB : 0;
 	mask |= (attr_mask & IB_QP_RQ_PSN) ? C4IW_QP_ATTR_RQ_DB : 0;
-	if (is_t5(to_c4iw_qp(ibqp)->rhp->rdev.lldi.adapter_type) &&
+	if (!is_t4(to_c4iw_qp(ibqp)->rhp->rdev.lldi.adapter_type) &&
 	    (mask & (C4IW_QP_ATTR_SQ_DB|C4IW_QP_ATTR_RQ_DB)))
 		return -EINVAL;
 
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 274a7ab..1092a2d 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -455,8 +455,7 @@ static inline void pio_copy(u64 __iomem *dst, u64 *src)
 	}
 }
 
-static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, u8 t5,
-				 union t4_wr *wqe)
+static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, union t4_wr *wqe)
 {
 
 	/* Flush host queue memory writes. */
@@ -482,7 +481,7 @@ static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, u8 t5,
 	writel(QID_V(wq->sq.qid) | PIDX_V(inc), wq->db);
 }
 
-static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc, u8 t5,
+static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc,
 				 union t4_recv_wr *wqe)
 {
 
-- 
2.3.4
