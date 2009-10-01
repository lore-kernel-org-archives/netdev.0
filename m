From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] be2net: Workaround to fix a bug in Rx Completion
	processing.
Date: Thu, 1 Oct 2009 09:33:22 +0530
Message-ID: <20091001040247.GA28228@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:6261 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750701AbZJAEDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 00:03:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vtp bit in RX completion descriptor could be wrongly set in
some skews of BladEngine.  Ignore this  bit if vtm is not set.
Resending because the previous patch was against net-next tree.
This patch is against the net-2.6 tree.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |    3 ++-
 drivers/net/benet/be_cmds.h |    3 ++-
 drivers/net/benet/be_main.c |   23 +++++++++++++++++++----
 4 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 684c6fe..a80da0e 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -258,6 +258,7 @@ struct be_adapter {
 	bool link_up;
 	u32 port_num;
 	bool promiscuous;
+	u32 cap;
 };
 
 extern const struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 3dd76c4..79d35d1 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1068,7 +1068,7 @@ int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc)
 }
 
 /* Uses mbox */
-int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
+int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *cap)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_query_fw_cfg *req;
@@ -1088,6 +1088,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num)
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
+		*cap = le32_to_cpu(resp->function_cap);
 	}
 
 	spin_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 93e432f..8b4c2cb 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -760,7 +760,8 @@ extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 			u32 *tx_fc, u32 *rx_fc);
-extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num);
+extern int be_cmd_query_fw_cfg(struct be_adapter *adapter,
+			u32 *port_num, u32 *cap);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
 extern int be_process_mcc(struct be_adapter *adapter);
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 409cf05..2f9b501 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -747,9 +747,16 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 			struct be_eth_rx_compl *rxcp)
 {
 	struct sk_buff *skb;
-	u32 vtp, vid;
+	u32 vlanf, vid;
+	u8 vtm;
 
-	vtp = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
+	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
+	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
+
+	/* vlanf could be wrongly set in some cards.
+	 * ignore if vtm is not set */
+	if ((adapter->cap == 0x400) && !vtm)
+		vlanf = 0;
 
 	skb = netdev_alloc_skb(adapter->netdev, BE_HDR_LEN + NET_IP_ALIGN);
 	if (!skb) {
@@ -772,7 +779,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 	skb->dev = adapter->netdev;
 
-	if (vtp) {
+	if (vlanf) {
 		if (!adapter->vlan_grp || adapter->num_vlans == 0) {
 			kfree_skb(skb);
 			return;
@@ -797,11 +804,18 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	struct be_eq_obj *eq_obj =  &adapter->rx_eq;
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
 	u16 i, rxq_idx = 0, vid, j;
+	u8 vtm;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 	pkt_size = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
+	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
+
+	/* vlanf could be wrongly set in some cards.
+	 * ignore if vtm is not set */
+	if ((adapter->cap == 0x400) && !vtm)
+		vlanf = 0;
 
 	skb = napi_get_frags(&eq_obj->napi);
 	if (!skb) {
@@ -2045,7 +2059,8 @@ static int be_hw_up(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num);
+	status = be_cmd_query_fw_cfg(adapter,
+				&adapter->port_num, &adapter->cap);
 	return status;
 }
 
-- 
1.6.0.4

