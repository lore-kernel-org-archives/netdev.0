From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 13:56:01 +0530
Message-ID: <20090723082552.GA602@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52887 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752493AbZGWI0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 04:26:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review and apply patch to net-next tree. Patch implements the 
support for q-in-q mode.

- Sarvesh

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |    8 +++++++-
 drivers/net/benet/be_cmds.h |    4 +++-
 drivers/net/benet/be_main.c |   22 ++++++++++++++++++----
 4 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 41cddbe..317b77d 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -270,6 +270,7 @@ struct be_adapter {
 	bool link_up;
 	u32 port_num;
 	bool promiscuous;
+	bool qnq;
 };
 
 extern struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 583517e..848a75b 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1037,11 +1037,12 @@ int be_cmd_get_flow_control(struct be_ct
 	return status;
 }
 
-int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num)
+int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num, bool *qnq)
 {
 	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
 	struct be_cmd_req_query_fw_cfg *req = embedded_payload(wrb);
 	int status;
+	int mode;
 
 	spin_lock(&ctrl->mbox_lock);
 
@@ -1056,6 +1057,11 @@ int be_cmd_query_fw_cfg(struct be_ctrl_i
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
+		mode = le32_to_cpu(resp->function_mode);
+		if (mode & QNQ_MODE)
+			*qnq = true;
+		else
+			*qnq = false;
 	}
 
 	spin_unlock(&ctrl->mbox_lock);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 747626d..4cfe995 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -683,6 +683,7 @@ struct be_cmd_resp_modify_eq_delay {
 } __packed;
 
 /******************** Get FW Config *******************/
+#define QNQ_MODE 0x400
 struct be_cmd_req_query_fw_cfg {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd[30];
@@ -744,5 +745,6 @@ extern int be_cmd_set_flow_control(struc
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
 			u32 *tx_fc, u32 *rx_fc);
-extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
+extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num,
+			bool *qnq);
 extern void be_process_mcc(struct be_ctrl_info *ctrl);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 45df8e2..59c2a86 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -747,9 +747,16 @@ static void be_rx_compl_process(struct b
 			struct be_eth_rx_compl *rxcp)
 {
 	struct sk_buff *skb;
-	u32 vtp, vid;
+	u32 vlanf, vid;
+	u8 qnq;
 
-	vtp = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
+	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
+	qnq = AMAP_GET_BITS(struct amap_eth_rx_compl, qnq, rxcp);
+
+	/* In QnQ mode, if qnq is 0 it is a non-vlan packet
+	   irrespective of vlanf */
+	if (adapter->qnq && !qnq)
+		vlanf = 0;
 
 	skb = netdev_alloc_skb(adapter->netdev, BE_HDR_LEN + NET_IP_ALIGN);
 	if (!skb) {
@@ -772,7 +779,7 @@ static void be_rx_compl_process(struct b
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 	skb->dev = adapter->netdev;
 
-	if (vtp) {
+	if (vlanf) {
 		if (!adapter->vlan_grp || adapter->num_vlans == 0) {
 			kfree_skb(skb);
 			return;
@@ -799,11 +806,18 @@ static void be_rx_compl_process_gro(stru
 	struct be_eq_obj *eq_obj =  &adapter->rx_eq;
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
 	u16 i, rxq_idx = 0, vid, j;
+	u8 qnq;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
+	qnq = AMAP_GET_BITS(struct amap_eth_rx_compl, qnq, rxcp);
+
+	/* In QnQ mode, if qnq is 0 it is a non-vlan packet
+	   irrespective of vlanf */
+	if (adapter->qnq && !qnq)
+		vlanf = 0;
 
 	skb = napi_get_frags(&eq_obj->napi);
 	if (!skb) {
@@ -1851,7 +1865,7 @@ static int be_hw_up(struct be_adapter *a
 	if (status)
 		return status;
 
-	status = be_cmd_query_fw_cfg(ctrl, &adapter->port_num);
+	status = be_cmd_query_fw_cfg(ctrl, &adapter->port_num, &adapter->qnq);
 	return status;
 }
 
-- 
1.4.0

