From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH for-next 3/3] cxgb4/iw_cxgb4: TOS support
Date: Fri,  5 Feb 2016 11:43:30 +0530
Message-ID: <1454652810-25086-4-git-send-email-hariprasad@chelsio.com>
References: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454652810-25086-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series provides support for iWARP applications to specify a TOS
value and have that map to a VLAN Priority for iw_cxgb4 iWARP connections.

In iw_cxgb4, when allocating an L2T entry, pass the skb_priority based
on the tos value in the cm_id. Also pass the correct tos value during
connection setup so the passive side gets the client's desired tos.
When sending the FLOWC work request to FW, if the egress device is
in a vlan, then use the vlan priority bits as the scheduling class.
This allows associating RDMA connections with scheduling classes to
provide traffic shaping per flow.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c              | 51 ++++++++++++++++++---------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h   |  2 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  1 +
 3 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index fe4e81b993d3..d159e168b786 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -485,12 +485,19 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 	unsigned int flowclen = 80;
 	struct fw_flowc_wr *flowc;
 	int i;
+	u16 vlan = ep->l2t->vlan;
+	int nparams;
+
+	if (vlan == CPL_L2T_VLAN_NONE)
+		nparams = 8;
+	else
+		nparams = 9;
 
 	skb = get_skb(skb, flowclen, GFP_KERNEL);
 	flowc = (struct fw_flowc_wr *)__skb_put(skb, flowclen);
 
 	flowc->op_to_nparams = cpu_to_be32(FW_WR_OP_V(FW_FLOWC_WR) |
-					   FW_FLOWC_WR_NPARAMS_V(8));
+					   FW_FLOWC_WR_NPARAMS_V(nparams));
 	flowc->flowid_len16 = cpu_to_be32(FW_WR_LEN16_V(DIV_ROUND_UP(flowclen,
 					  16)) | FW_WR_FLOWID_V(ep->hwtid));
 
@@ -511,9 +518,17 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 	flowc->mnemval[6].val = cpu_to_be32(ep->snd_win);
 	flowc->mnemval[7].mnemonic = FW_FLOWC_MNEM_MSS;
 	flowc->mnemval[7].val = cpu_to_be32(ep->emss);
-	/* Pad WR to 16 byte boundary */
-	flowc->mnemval[8].mnemonic = 0;
-	flowc->mnemval[8].val = 0;
+	if (nparams == 9) {
+		u16 pri;
+
+		pri = (vlan & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+		flowc->mnemval[8].mnemonic = FW_FLOWC_MNEM_SCHEDCLASS;
+		flowc->mnemval[8].val = cpu_to_be32(pri);
+	} else {
+		/* Pad WR to 16 byte boundary */
+		flowc->mnemval[8].mnemonic = 0;
+		flowc->mnemval[8].val = 0;
+	}
 	for (i = 0; i < 9; i++) {
 		flowc->mnemval[i].r4[0] = 0;
 		flowc->mnemval[i].r4[1] = 0;
@@ -710,7 +725,7 @@ static int send_connect(struct c4iw_ep *ep)
 	       L2T_IDX_V(ep->l2t->idx) |
 	       TX_CHAN_V(ep->tx_chan) |
 	       SMAC_SEL_V(ep->smac_idx) |
-	       DSCP_V(ep->tos) |
+	       DSCP_V(ep->tos >> 2) |
 	       ULP_MODE_V(ULP_MODE_TCPDDP) |
 	       RCV_BUFSIZ_V(win);
 	opt2 = RX_CHANNEL_V(0) |
@@ -1864,7 +1879,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 		L2T_IDX_V(ep->l2t->idx) |
 		TX_CHAN_V(ep->tx_chan) |
 		SMAC_SEL_V(ep->smac_idx) |
-		DSCP_V(ep->tos) |
+		DSCP_V(ep->tos >> 2) |
 		ULP_MODE_V(ULP_MODE_TCPDDP) |
 		RCV_BUFSIZ_V(win));
 	req->tcb.opt2 = (__force __be32) (PACE_V(1) |
@@ -1928,7 +1943,7 @@ static void set_tcp_window(struct c4iw_ep *ep, struct port_info *pi)
 
 static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 		     struct dst_entry *dst, struct c4iw_dev *cdev,
-		     bool clear_mpa_v1, enum chip_type adapter_type)
+		     bool clear_mpa_v1, enum chip_type adapter_type, u8 tos)
 {
 	struct neighbour *n;
 	int err, step;
@@ -1958,7 +1973,7 @@ static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
 			goto out;
 		}
 		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
-					n, pdev, 0);
+					n, pdev, rt_tos2priority(tos));
 		if (!ep->l2t)
 			goto out;
 		ep->mtu = pdev->mtu;
@@ -2041,7 +2056,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	if (ep->com.cm_id->local_addr.ss_family == AF_INET) {
 		ep->dst = find_route(ep->com.dev, laddr->sin_addr.s_addr,
 				     raddr->sin_addr.s_addr, laddr->sin_port,
-				     raddr->sin_port, 0);
+				     raddr->sin_port, ep->com.cm_id->tos);
 		iptype = 4;
 		ra = (__u8 *)&raddr->sin_addr;
 	} else {
@@ -2058,7 +2073,8 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 		goto fail3;
 	}
 	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, false,
-			ep->com.dev->rdev.lldi.adapter_type);
+			ep->com.dev->rdev.lldi.adapter_type,
+			ep->com.cm_id->tos);
 	if (err) {
 		pr_err("%s - cannot alloc l2e.\n", __func__);
 		goto fail4;
@@ -2069,7 +2085,7 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	     ep->l2t->idx);
 
 	state_set(&ep->com, CONNECTING);
-	ep->tos = 0;
+	ep->tos = ep->com.cm_id->tos;
 
 	/* send connect request to rnic */
 	err = send_connect(ep);
@@ -2391,6 +2407,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	u16 peer_mss = ntohs(req->tcpopt.mss);
 	int iptype;
 	unsigned short hdrs;
+	u8 tos = PASS_OPEN_TOS_G(ntohl(req->tos_stid));
 
 	parent_ep = lookup_stid(t, stid);
 	if (!parent_ep) {
@@ -2414,7 +2431,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		     ntohs(peer_port), peer_mss);
 		dst = find_route(dev, *(__be32 *)local_ip, *(__be32 *)peer_ip,
 				 local_port, peer_port,
-				 PASS_OPEN_TOS_G(ntohl(req->tos_stid)));
+				 tos);
 	} else {
 		PDBG("%s parent ep %p hwtid %u laddr %pI6 raddr %pI6 lport %d rport %d peer_mss %d\n"
 		     , __func__, parent_ep, hwtid,
@@ -2440,7 +2457,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	}
 
 	err = import_ep(child_ep, iptype, peer_ip, dst, dev, false,
-			parent_ep->com.dev->rdev.lldi.adapter_type);
+			parent_ep->com.dev->rdev.lldi.adapter_type, tos);
 	if (err) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -2508,7 +2525,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 
 	c4iw_get_ep(&parent_ep->com);
 	child_ep->parent_ep = parent_ep;
-	child_ep->tos = PASS_OPEN_TOS_G(ntohl(req->tos_stid));
+	child_ep->tos = tos;
 	child_ep->dst = dst;
 	child_ep->hwtid = hwtid;
 
@@ -3202,7 +3219,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		     ra, ntohs(raddr->sin_port));
 		ep->dst = find_route(dev, laddr->sin_addr.s_addr,
 				     raddr->sin_addr.s_addr, laddr->sin_port,
-				     raddr->sin_port, 0);
+				     raddr->sin_port, cm_id->tos);
 	} else {
 		iptype = 6;
 		ra = (__u8 *)&raddr6->sin6_addr;
@@ -3233,7 +3250,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 
 	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, true,
-			ep->com.dev->rdev.lldi.adapter_type);
+			ep->com.dev->rdev.lldi.adapter_type, cm_id->tos);
 	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		goto fail3;
@@ -3244,7 +3261,7 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		ep->l2t->idx);
 
 	state_set(&ep->com, CONNECTING);
-	ep->tos = 0;
+	ep->tos = cm_id->tos;
 
 	/* send connect request to rnic */
 	err = send_connect(ep);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index a072d341e205..1d2d1da40c80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1021,6 +1021,8 @@ struct cpl_l2t_write_req {
 #define L2T_W_NOREPLY_V(x) ((x) << L2T_W_NOREPLY_S)
 #define L2T_W_NOREPLY_F    L2T_W_NOREPLY_V(1U)
 
+#define CPL_L2T_VLAN_NONE 0xfff
+
 struct cpl_l2t_write_rpl {
 	union opcode_tid ot;
 	u8 status;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index a32de30ea663..c8661c77b4e3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -561,6 +561,7 @@ enum fw_flowc_mnem {
 	FW_FLOWC_MNEM_SNDBUF,
 	FW_FLOWC_MNEM_MSS,
 	FW_FLOWC_MNEM_TXDATAPLEN_MAX,
+	FW_FLOWC_MNEM_SCHEDCLASS = 11,
 };
 
 struct fw_flowc_mnemval {
-- 
2.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
