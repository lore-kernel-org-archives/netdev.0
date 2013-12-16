From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 9/9] RDMA/cxgb4: Use cxgb4_select_ntuple to correctly calculate ntuple fields
Date: Mon, 16 Dec 2013 17:42:18 +0530
Message-ID: <1387195938-3531-10-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24745 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab3LPMU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:20:26 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 71 ++++++++++------------------------------
 1 file changed, 17 insertions(+), 54 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index bfd4ed7..4512687 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -524,50 +524,6 @@ static int send_abort(struct c4iw_ep *ep, struct sk_buff *skb, gfp_t gfp)
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
 
-#define VLAN_NONE 0xfff
-#define FILTER_SEL_VLAN_NONE 0xffff
-#define FILTER_SEL_WIDTH_P_FC (3+1) /* port uses 3 bits, FCoE one bit */
-#define FILTER_SEL_WIDTH_VIN_P_FC \
-	(6 + 7 + FILTER_SEL_WIDTH_P_FC) /* 6 bits are unused, VF uses 7 bits*/
-#define FILTER_SEL_WIDTH_TAG_P_FC \
-	(3 + FILTER_SEL_WIDTH_VIN_P_FC) /* PF uses 3 bits */
-#define FILTER_SEL_WIDTH_VLD_TAG_P_FC (1 + FILTER_SEL_WIDTH_TAG_P_FC)
-
-static unsigned int select_ntuple(struct c4iw_dev *dev, struct dst_entry *dst,
-				  struct l2t_entry *l2t)
-{
-	unsigned int ntuple = 0;
-	u32 viid;
-
-	switch (dev->rdev.lldi.filt_mode) {
-
-	/* default filter mode */
-	case HW_TPL_FR_MT_PR_IV_P_FC:
-		if (l2t->vlan == VLAN_NONE)
-			ntuple |= FILTER_SEL_VLAN_NONE << FILTER_SEL_WIDTH_P_FC;
-		else {
-			ntuple |= l2t->vlan << FILTER_SEL_WIDTH_P_FC;
-			ntuple |= 1 << FILTER_SEL_WIDTH_TAG_P_FC;
-		}
-		ntuple |= l2t->lport << S_PORT | IPPROTO_TCP <<
-			  FILTER_SEL_WIDTH_VLD_TAG_P_FC;
-		break;
-	case HW_TPL_FR_MT_PR_OV_P_FC: {
-		viid = cxgb4_port_viid(l2t->neigh->dev);
-
-		ntuple |= FW_VIID_VIN_GET(viid) << FILTER_SEL_WIDTH_P_FC;
-		ntuple |= FW_VIID_PFN_GET(viid) << FILTER_SEL_WIDTH_VIN_P_FC;
-		ntuple |= FW_VIID_VIVLD_GET(viid) << FILTER_SEL_WIDTH_TAG_P_FC;
-		ntuple |= l2t->lport << S_PORT | IPPROTO_TCP <<
-			  FILTER_SEL_WIDTH_VLD_TAG_P_FC;
-		break;
-	}
-	default:
-		break;
-	}
-	return ntuple;
-}
-
 static int send_connect(struct c4iw_ep *ep)
 {
 	struct cpl_act_open_req *req;
@@ -641,8 +597,9 @@ static int send_connect(struct c4iw_ep *ep)
 			req->local_ip = la->sin_addr.s_addr;
 			req->peer_ip = ra->sin_addr.s_addr;
 			req->opt0 = cpu_to_be64(opt0);
-			req->params = cpu_to_be32(select_ntuple(ep->com.dev,
-						ep->dst, ep->l2t));
+			req->params = cpu_to_be32(cxgb4_select_ntuple(
+						ep->com.dev->rdev.lldi.ports[0],
+						ep->l2t));
 			req->opt2 = cpu_to_be32(opt2);
 		} else {
 			req6 = (struct cpl_act_open_req6 *)skb_put(skb, wrlen);
@@ -662,9 +619,9 @@ static int send_connect(struct c4iw_ep *ep)
 			req6->peer_ip_lo = *((__be64 *)
 						(ra6->sin6_addr.s6_addr + 8));
 			req6->opt0 = cpu_to_be64(opt0);
-			req6->params = cpu_to_be32(
-					select_ntuple(ep->com.dev, ep->dst,
-						      ep->l2t));
+			req6->params = cpu_to_be32(cxgb4_select_ntuple(
+						ep->com.dev->rdev.lldi.ports[0],
+						ep->l2t));
 			req6->opt2 = cpu_to_be32(opt2);
 		}
 	} else {
@@ -681,8 +638,9 @@ static int send_connect(struct c4iw_ep *ep)
 			t5_req->peer_ip = ra->sin_addr.s_addr;
 			t5_req->opt0 = cpu_to_be64(opt0);
 			t5_req->params = cpu_to_be64(V_FILTER_TUPLE(
-						select_ntuple(ep->com.dev,
-						ep->dst, ep->l2t)));
+						     cxgb4_select_ntuple(
+					     ep->com.dev->rdev.lldi.ports[0],
+					     ep->l2t)));
 			t5_req->opt2 = cpu_to_be32(opt2);
 		} else {
 			t5_req6 = (struct cpl_t5_act_open_req6 *)
@@ -703,7 +661,9 @@ static int send_connect(struct c4iw_ep *ep)
 						(ra6->sin6_addr.s6_addr + 8));
 			t5_req6->opt0 = cpu_to_be64(opt0);
 			t5_req6->params = (__force __be64)cpu_to_be32(
-				select_ntuple(ep->com.dev, ep->dst, ep->l2t));
+							cxgb4_select_ntuple(
+						ep->com.dev->rdev.lldi.ports[0],
+						ep->l2t));
 			t5_req6->opt2 = cpu_to_be32(opt2);
 		}
 	}
@@ -1630,7 +1590,8 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	memset(req, 0, sizeof(*req));
 	req->op_compl = htonl(V_WR_OP(FW_OFLD_CONNECTION_WR));
 	req->len16_pkd = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*req), 16)));
-	req->le.filter = cpu_to_be32(select_ntuple(ep->com.dev, ep->dst,
+	req->le.filter = cpu_to_be32(cxgb4_select_ntuple(
+				     ep->com.dev->rdev.lldi.ports[0],
 				     ep->l2t));
 	sin = (struct sockaddr_in *)&ep->com.local_addr;
 	req->le.lport = sin->sin_port;
@@ -3396,7 +3357,9 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	window = (__force u16) htons((__force u16)tcph->window);
 
 	/* Calcuate filter portion for LE region. */
-	filter = (__force unsigned int) cpu_to_be32(select_ntuple(dev, dst, e));
+	filter = (__force unsigned int) cpu_to_be32(cxgb4_select_ntuple(
+						    dev->rdev.lldi.ports[0],
+						    e));
 
 	/*
 	 * Synthesize the cpl_pass_accept_req. We have everything except the
-- 
1.8.0
