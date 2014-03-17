From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v5 net-next 2/2] be2net: Support for configurable RSS hash key
Date: Mon, 17 Mar 2014 18:01:35 +0530
Message-ID: <d82ab694-8236-416d-9c18-1d4cf3b7c726@CMEXHTCAS2.ad.emulex.com>
References: <1395059495-16073-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28288 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933018AbaCQMcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:32:05 -0400
In-Reply-To: <1395059495-16073-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This be2net patch implements the get/set_rxfh() ethtool hooks.
RSS_CONFIG device command is invoked to set hashkey and indirection table.
It also uses an initial random value for RSS hash key instead of a hard-coded
value as hard-coded values for a hash-key are usually considered a security risk.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   12 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    7 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  103 +++++++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_main.c    |   31 +++++---
 5 files changed, 124 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a587c8a..5e8cfa4 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -120,6 +120,9 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_VFS			30 /* Max VFs supported by BE3 FW */
 #define FW_VER_LEN		32
 
+#define	RSS_INDIR_TABLE_LEN	128
+#define RSS_HASH_KEY_LEN	40
+
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -406,6 +409,13 @@ struct be_resources {
 	u32 if_cap_flags;
 };
 
+struct rss_info {
+	u64 rss_flags;
+	u8 rsstable[RSS_INDIR_TABLE_LEN];
+	u8 rss_queue[RSS_INDIR_TABLE_LEN];
+	u8 rss_hkey[RSS_HASH_KEY_LEN];
+};
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -503,7 +513,7 @@ struct be_adapter {
 	u32 msg_enable;
 	int be_get_temp_freq;
 	u8 pf_number;
-	u64 rss_flags;
+	struct rss_info rss_info;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index cf5afe7..e1b007d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2020,13 +2020,10 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 }
 
 int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-			u32 rss_hash_opts, u16 table_size)
+			u32 rss_hash_opts, u16 table_size, u8 *rss_hkey)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_rss_config *req;
-	u32 myhash[10] = {0x15d43fa5, 0x2534685a, 0x5f87693a, 0x5668494e,
-			0x33cf6a53, 0x383334c6, 0x76ac4257, 0x59b242b2,
-			0x3ea83c02, 0x4a110304};
 	int status;
 
 	if (!(be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS))
@@ -2049,7 +2046,7 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 		req->hdr.version = 1;
 
 	memcpy(req->cpu_table, rsstable, table_size);
-	memcpy(req->hash, myhash, sizeof(myhash));
+	memcpy(req->hash, rss_hkey, RSS_HASH_KEY_LEN);
 	be_dws_cpu_to_le(req->hash, sizeof(req->hash));
 
 	status = be_mbox_notify_wait(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index fda3e88..fc194b5 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2040,7 +2040,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 			u32 *function_mode, u32 *function_caps, u16 *asic_rev);
 int be_cmd_reset_function(struct be_adapter *adapter);
 int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-		      u32 rss_hash_opts, u16 table_size);
+		      u32 rss_hash_opts, u16 table_size, u8 *rss_hkey);
 int be_process_mcc(struct be_adapter *adapter);
 int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num, u8 beacon,
 			    u8 status, u8 state);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 66759b6..50cf742 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -933,27 +933,27 @@ static u64 be_get_rss_hash_opts(struct be_adapter *adapter, u64 flow_type)
 
 	switch (flow_type) {
 	case TCP_V4_FLOW:
-		if (adapter->rss_flags & RSS_ENABLE_IPV4)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_IPV4)
 			data |= RXH_IP_DST | RXH_IP_SRC;
-		if (adapter->rss_flags & RSS_ENABLE_TCP_IPV4)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_TCP_IPV4)
 			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V4_FLOW:
-		if (adapter->rss_flags & RSS_ENABLE_IPV4)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_IPV4)
 			data |= RXH_IP_DST | RXH_IP_SRC;
-		if (adapter->rss_flags & RSS_ENABLE_UDP_IPV4)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_UDP_IPV4)
 			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case TCP_V6_FLOW:
-		if (adapter->rss_flags & RSS_ENABLE_IPV6)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_IPV6)
 			data |= RXH_IP_DST | RXH_IP_SRC;
-		if (adapter->rss_flags & RSS_ENABLE_TCP_IPV6)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_TCP_IPV6)
 			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	case UDP_V6_FLOW:
-		if (adapter->rss_flags & RSS_ENABLE_IPV6)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_IPV6)
 			data |= RXH_IP_DST | RXH_IP_SRC;
-		if (adapter->rss_flags & RSS_ENABLE_UDP_IPV6)
+		if (adapter->rss_info.rss_flags & RSS_ENABLE_UDP_IPV6)
 			data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
 		break;
 	}
@@ -992,7 +992,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 	struct be_rx_obj *rxo;
 	int status = 0, i, j;
 	u8 rsstable[128];
-	u32 rss_flags = adapter->rss_flags;
+	u32 rss_flags = adapter->rss_info.rss_flags;
 
 	if (cmd->data != L3_RSS_FLAGS &&
 	    cmd->data != (L3_RSS_FLAGS | L4_RSS_FLAGS))
@@ -1039,7 +1039,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 		return -EINVAL;
 	}
 
-	if (rss_flags == adapter->rss_flags)
+	if (rss_flags == adapter->rss_info.rss_flags)
 		return status;
 
 	if (be_multi_rxq(adapter)) {
@@ -1051,9 +1051,11 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 			}
 		}
 	}
-	status = be_cmd_rss_config(adapter, rsstable, rss_flags, 128);
+
+	status = be_cmd_rss_config(adapter, adapter->rss_info.rsstable,
+				   rss_flags, 128, adapter->rss_info.rss_hkey);
 	if (!status)
-		adapter->rss_flags = rss_flags;
+		adapter->rss_info.rss_flags = rss_flags;
 
 	return status;
 }
@@ -1103,6 +1105,79 @@ static int be_set_channels(struct net_device  *netdev,
 	return be_update_queues(adapter);
 }
 
+static u32 be_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return RSS_INDIR_TABLE_LEN;
+}
+
+static u32 be_get_rxfh_key_size(struct net_device *netdev)
+{
+	return RSS_HASH_KEY_LEN;
+}
+
+static int be_get_rxfh(struct net_device *netdev,
+		       struct ethtool_rxfh *cmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	u32 key_offset = 0;
+	int i;
+	struct rss_info *rss = &adapter->rss_info;
+
+	if (cmd->indir_size) {
+		for (i = 0; i < RSS_INDIR_TABLE_LEN; i++)
+			cmd->rss_config[i] = rss->rss_queue[i];
+
+		key_offset = cmd->indir_size * sizeof(cmd->rss_config[0]);
+	}
+
+	if (cmd->key_size)
+		memcpy(((char *)cmd->rss_config) + key_offset,
+		       rss->rss_hkey,
+		       cmd->key_size);
+
+	return 0;
+}
+
+static int be_set_rxfh(struct net_device *netdev,
+		       struct ethtool_rxfh *cmd)
+{
+	int rc = 0, key_offset = 0, i, j;
+	char *hkey = NULL;
+	struct be_adapter *adapter = netdev_priv(netdev);
+	u8 rsstable[RSS_INDIR_TABLE_LEN];
+
+	if (cmd->indir_size) {
+		struct be_rx_obj *rxo;
+		for (i = 0; i < RSS_INDIR_TABLE_LEN; i++) {
+			j = cmd->rss_config[i];
+			rxo = &adapter->rx_obj[j];
+			rsstable[i] = rxo->rss_id;
+			adapter->rss_info.rss_queue[i] = j;
+		}
+		key_offset = RSS_INDIR_TABLE_LEN * sizeof(cmd->rss_config[0]);
+	} else {
+		memcpy(rsstable, adapter->rss_info.rsstable,
+		       RSS_INDIR_TABLE_LEN);
+	}
+
+	if (cmd->key_size)
+		hkey = (char *)cmd->rss_config + key_offset;
+	else
+		hkey =  adapter->rss_info.rss_hkey;
+
+	rc = be_cmd_rss_config(adapter, rsstable,
+			adapter->rss_info.rss_flags,
+			RSS_INDIR_TABLE_LEN, hkey);
+	if (rc) {
+		adapter->rss_info.rss_flags = RSS_ENABLE_NONE;
+		return -EIO;
+	}
+	memcpy(adapter->rss_info.rss_hkey, hkey, RSS_HASH_KEY_LEN);
+	memcpy(adapter->rss_info.rsstable, rsstable,
+	       RSS_INDIR_TABLE_LEN);
+	return 0;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -1129,6 +1204,10 @@ const struct ethtool_ops be_ethtool_ops = {
 	.self_test = be_self_test,
 	.get_rxnfc = be_get_rxnfc,
 	.set_rxnfc = be_set_rxnfc,
+	.get_rxfh_indir_size = be_get_rxfh_indir_size,
+	.get_rxfh_key_size = be_get_rxfh_key_size,
+	.get_rxfh = be_get_rxfh,
+	.set_rxfh = be_set_rxfh,
 	.get_channels = be_get_channels,
 	.set_channels = be_set_channels
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 239273b..cbb228f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2744,7 +2744,8 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 {
 	struct be_rx_obj *rxo;
 	int rc, i, j;
-	u8 rsstable[128];
+	u8 rss_hkey[RSS_HASH_KEY_LEN];
+	struct rss_info *rss = &adapter->rss_info;
 
 	for_all_rx_queues(adapter, rxo, i) {
 		rc = be_queue_alloc(adapter, &rxo->q, RX_Q_LEN,
@@ -2769,31 +2770,37 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 	}
 
 	if (be_multi_rxq(adapter)) {
-		for (j = 0; j < 128; j += adapter->num_rx_qs - 1) {
+		for (j = 0; j < RSS_INDIR_TABLE_LEN;
+			j += adapter->num_rx_qs - 1) {
 			for_all_rss_queues(adapter, rxo, i) {
-				if ((j + i) >= 128)
+				if ((j + i) >= RSS_INDIR_TABLE_LEN)
 					break;
-				rsstable[j + i] = rxo->rss_id;
+				rss->rsstable[j + i] = rxo->rss_id;
+				rss->rss_queue[j + i] = i;
 			}
 		}
-		adapter->rss_flags = RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
-					RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6;
+		rss->rss_flags = RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
+			RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6;
 
 		if (!BEx_chip(adapter))
-			adapter->rss_flags |= RSS_ENABLE_UDP_IPV4 |
-						RSS_ENABLE_UDP_IPV6;
+			rss->rss_flags |= RSS_ENABLE_UDP_IPV4 |
+				RSS_ENABLE_UDP_IPV6;
 	} else {
 		/* Disable RSS, if only default RX Q is created */
-		adapter->rss_flags = RSS_ENABLE_NONE;
+		rss->rss_flags = RSS_ENABLE_NONE;
 	}
 
-	rc = be_cmd_rss_config(adapter, rsstable, adapter->rss_flags,
-			       128);
+	get_random_bytes(rss_hkey, RSS_HASH_KEY_LEN);
+	rc = be_cmd_rss_config(adapter, rss->rsstable,
+			       rss->rss_flags,
+			       128, rss_hkey);
 	if (rc) {
-		adapter->rss_flags = RSS_ENABLE_NONE;
+		rss->rss_flags = RSS_ENABLE_NONE;
 		return rc;
 	}
 
+	memcpy(rss->rss_hkey, rss_hkey, RSS_HASH_KEY_LEN);
+
 	/* First time posting */
 	for_all_rx_queues(adapter, rxo, i)
 		be_post_rx_frags(rxo, GFP_KERNEL);
-- 
1.7.1
