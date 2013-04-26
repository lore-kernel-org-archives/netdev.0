From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net-next 1/3] be2net: Add support for setting and getting rx flow hash options
Date: Fri, 26 Apr 2013 14:33:20 +0530
Message-ID: <0b1decac-3347-40c3-8fbf-4545bdfc4cf9@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Suresh Reddy <suresh.reddy@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:26226 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab3DZJBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 05:01:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   13 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    5 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  155 ++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c    |   14 ++-
 5 files changed, 177 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index e2d5ced..4b62e7f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -447,6 +447,7 @@ struct be_adapter {
 	u16 max_event_queues;
 	u32 if_cap_flags;
 	u8 pf_number;
+	u64 rss_flags;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d6291ab..d837e4c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1898,7 +1898,8 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	return status;
 }
 
-int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
+int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
+			u32 rss_hash_opts, u16 table_size)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_rss_config *req;
@@ -1917,16 +1918,12 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
 		OPCODE_ETH_RSS_CONFIG, sizeof(*req), wrb, NULL);
 
 	req->if_id = cpu_to_le32(adapter->if_handle);
-	req->enable_rss = cpu_to_le16(RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
-				      RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6);
+	req->enable_rss = cpu_to_le16(rss_hash_opts);
+	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
 
-	if (lancer_chip(adapter) || skyhawk_chip(adapter)) {
+	if (lancer_chip(adapter) || skyhawk_chip(adapter))
 		req->hdr.version = 1;
-		req->enable_rss |= cpu_to_le16(RSS_ENABLE_UDP_IPV4 |
-					       RSS_ENABLE_UDP_IPV6);
-	}
 
-	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
 	memcpy(req->cpu_table, rsstable, table_size);
 	memcpy(req->hash, myhash, sizeof(myhash));
 	be_dws_cpu_to_le(req->hash, sizeof(req->hash));
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 4603320..4d03789 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1090,6 +1090,9 @@ struct be_cmd_resp_query_fw_cfg {
 #define RSS_ENABLE_UDP_IPV4			0x10
 #define RSS_ENABLE_UDP_IPV6			0x20
 
+#define L3_RSS_FLAGS				(RXH_IP_DST | RXH_IP_SRC)
+#define L4_RSS_FLAGS				(RXH_L4_B_0_1 | RXH_L4_B_2_3)
+
 struct be_cmd_req_rss_config {
 	struct be_cmd_req_hdr hdr;
 	u32 if_id;
@@ -1860,7 +1863,7 @@ extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 			u32 *function_mode, u32 *function_caps, u16 *asic_rev);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
 extern int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-			u16 table_size);
+			     u32 rss_hash_opts, u16 table_size);
 extern int be_process_mcc(struct be_adapter *adapter);
 extern int be_cmd_set_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u8 beacon, u8 status, u8 state);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 07b7f27..ac05bbe 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -934,6 +934,159 @@ static void be_set_msg_level(struct net_device *netdev, u32 level)
 	return;
 }
 
+static u64 be_get_rss_hash_opts(struct be_adapter *adapter, u64 flow_type)
+{
+	u64 data = 0;
+
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+		if (adapter->rss_flags & RSS_ENABLE_IPV4)
+			data |= RXH_IP_DST | RXH_IP_SRC;
+		if (adapter->rss_flags & RSS_ENABLE_TCP_IPV4)
+			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case UDP_V4_FLOW:
+		if (adapter->rss_flags & RSS_ENABLE_IPV4)
+			data |= RXH_IP_DST | RXH_IP_SRC;
+		if (adapter->rss_flags & RSS_ENABLE_UDP_IPV4)
+			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case TCP_V6_FLOW:
+		if (adapter->rss_flags & RSS_ENABLE_IPV6)
+			data |= RXH_IP_DST | RXH_IP_SRC;
+		if (adapter->rss_flags & RSS_ENABLE_TCP_IPV6)
+			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case UDP_V6_FLOW:
+		if (adapter->rss_flags & RSS_ENABLE_IPV6)
+			data |= RXH_IP_DST | RXH_IP_SRC;
+		if (adapter->rss_flags & RSS_ENABLE_UDP_IPV6)
+			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	}
+
+	return data;
+}
+
+static int be_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
+		      u32 *rule_locs)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (!be_multi_rxq(adapter)) {
+		dev_info(&adapter->pdev->dev,
+			 "ethtool::get_rxnfc: RX flow hashing is disabled\n");
+		return -EINVAL;
+	}
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXFH:
+		cmd->data = be_get_rss_hash_opts(adapter, cmd->flow_type);
+		break;
+	case ETHTOOL_GRXRINGS:
+		cmd->data = adapter->num_rx_qs - 1;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int be_set_rss_hash_opts(struct be_adapter *adapter,
+				struct ethtool_rxnfc *cmd)
+{
+	struct be_rx_obj *rxo;
+	int status = 0, i, j;
+	u8 rsstable[128];
+	u32 rss_flags = adapter->rss_flags;
+
+	if (cmd->data != L3_RSS_FLAGS &&
+	    cmd->data != (L3_RSS_FLAGS | L4_RSS_FLAGS))
+		return -EINVAL;
+
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+		if (cmd->data == L3_RSS_FLAGS)
+			rss_flags &= ~RSS_ENABLE_TCP_IPV4;
+		else if (cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS))
+			rss_flags |= RSS_ENABLE_IPV4 |
+					RSS_ENABLE_TCP_IPV4;
+		break;
+	case TCP_V6_FLOW:
+		if (cmd->data == L3_RSS_FLAGS)
+			rss_flags &= ~RSS_ENABLE_TCP_IPV6;
+		else if (cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS))
+			rss_flags |= RSS_ENABLE_IPV6 |
+					RSS_ENABLE_TCP_IPV6;
+		break;
+	case UDP_V4_FLOW:
+		if ((cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS)) &&
+		    BEx_chip(adapter))
+			return -EINVAL;
+
+		if (cmd->data == L3_RSS_FLAGS)
+			rss_flags &= ~RSS_ENABLE_UDP_IPV4;
+		else if (cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS))
+			rss_flags |= RSS_ENABLE_IPV4 |
+					RSS_ENABLE_UDP_IPV4;
+		break;
+	case UDP_V6_FLOW:
+		if ((cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS)) &&
+		    BEx_chip(adapter))
+			return -EINVAL;
+
+		if (cmd->data == L3_RSS_FLAGS)
+			rss_flags &= ~RSS_ENABLE_UDP_IPV6;
+		else if (cmd->data == (L3_RSS_FLAGS | L4_RSS_FLAGS))
+			rss_flags |= RSS_ENABLE_IPV6 |
+					RSS_ENABLE_UDP_IPV6;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (rss_flags == adapter->rss_flags)
+		return status;
+
+	if (be_multi_rxq(adapter)) {
+		for (j = 0; j < 128; j += adapter->num_rx_qs - 1) {
+			for_all_rss_queues(adapter, rxo, i) {
+				if ((j + i) >= 128)
+					break;
+				rsstable[j + i] = rxo->rss_id;
+			}
+		}
+	}
+	status = be_cmd_rss_config(adapter, rsstable, rss_flags, 128);
+	if (!status)
+		adapter->rss_flags = rss_flags;
+
+	return status;
+}
+
+static int be_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
+
+	if (!be_multi_rxq(adapter)) {
+		dev_err(&adapter->pdev->dev,
+			"ethtool::set_rxnfc: RX flow hashing is disabled\n");
+		return -EINVAL;
+	}
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		status = be_set_rss_hash_opts(adapter, cmd);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return status;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -957,4 +1110,6 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_regs = be_get_regs,
 	.flash_device = be_do_flash,
 	.self_test = be_self_test,
+	.get_rxnfc = be_get_rxnfc,
+	.set_rxnfc = be_set_rxnfc,
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 654e782..a8926eb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2510,9 +2510,19 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 				rsstable[j + i] = rxo->rss_id;
 			}
 		}
-		rc = be_cmd_rss_config(adapter, rsstable, 128);
-		if (rc)
+		adapter->rss_flags = RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
+					RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6;
+
+		if (!BEx_chip(adapter))
+			adapter->rss_flags |= RSS_ENABLE_UDP_IPV4 |
+						RSS_ENABLE_UDP_IPV6;
+
+		rc = be_cmd_rss_config(adapter, rsstable, adapter->rss_flags,
+				       128);
+		if (rc) {
+			adapter->rss_flags = 0;
 			return rc;
+		}
 	}
 
 	/* First time posting */
-- 
1.7.9.5
