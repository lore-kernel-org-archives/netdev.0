From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: DCB message handler needs to use correct portid to netdev mapping
Date: Tue, 26 Apr 2016 20:10:27 +0530
Message-ID: <1461681629-28275-7-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:36099 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752463AbcDZOgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:52 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 052c660aca80..6ee2ed30626b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -253,7 +253,7 @@ void cxgb4_dcb_handle_fw_update(struct adapter *adap,
 {
 	const union fw_port_dcb *fwdcb = &pcmd->u.dcb;
 	int port = FW_PORT_CMD_PORTID_G(be32_to_cpu(pcmd->op_to_portid));
-	struct net_device *dev = adap->port[port];
+	struct net_device *dev = adap->port[adap->chan_map[port]];
 	struct port_info *pi = netdev_priv(dev);
 	struct port_dcb_info *dcb = &pi->dcb;
 	int dcb_type = pcmd->u.dcb.pgid.type;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index abc425bfc744..4f627f3edb98 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -515,7 +515,7 @@ EXPORT_SYMBOL(cxgb4_dcb_enabled);
 static void dcb_rpl(struct adapter *adap, const struct fw_port_cmd *pcmd)
 {
 	int port = FW_PORT_CMD_PORTID_G(ntohl(pcmd->op_to_portid));
-	struct net_device *dev = adap->port[port];
+	struct net_device *dev = adap->port[adap->chan_map[port]];
 	int old_dcb_enabled = cxgb4_dcb_enabled(dev);
 	int new_dcb_enabled;
 
@@ -645,7 +645,8 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 		    action == FW_PORT_ACTION_GET_PORT_INFO) {
 			int port = FW_PORT_CMD_PORTID_G(
 					be32_to_cpu(pcmd->op_to_portid));
-			struct net_device *dev = q->adap->port[port];
+			struct net_device *dev =
+				q->adap->port[q->adap->chan_map[port]];
 			int state_input = ((pcmd->u.info.dcbxdis_pkd &
 					    FW_PORT_CMD_DCBXDIS_F)
 					   ? CXGB4_DCB_INPUT_FW_DISABLED
-- 
2.3.4
