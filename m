From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH net-next 4/4] benet: Support for configurable RSS hash key.
Date: Fri, 17 Jan 2014 13:03:23 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D905@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56801 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaAQNDY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:03:24 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This be2net patch implements the get/set_rsshkey() ethtool hooks.
RSS_CONFIG device command is invoked to set the hashkey.
It also uses an initial random value for RSS hash key instead of a hard-coded value as hard-coded values for a hash-key are usually considered a security risk.

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   12 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    9 +---
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    4 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   58 ++++++++++++++++++-----
 drivers/net/ethernet/emulex/benet/be_main.c    |   24 ++++++----
 5 files changed, 74 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8d09615..544361c 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2013 Emulex
+ * Copyright (C) 2005 - 2014 Emulex
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or @@ -121,6 +121,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_VFS			30 /* Max VFs supported by BE3 FW */
 #define FW_VER_LEN		32
 
+#define RSS_HASH_KEY_LEN	40
+
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -403,6 +405,12 @@ struct be_resources {
 	u32 if_cap_flags;
 };
 
+struct rss_info {
+	u64 rss_flags;
+	u8 rsstable[128];
+	u8 rss_hkey[RSS_HASH_KEY_LEN];
+};
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -499,7 +507,7 @@ struct be_adapter {
 	u32 msg_enable;
 	int be_get_temp_freq;
 	u8 pf_number;
-	u64 rss_flags;
+	struct rss_info rss_info;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 48076a6..7984252 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2013 Emulex
+ * Copyright (C) 2005 - 2014 Emulex
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or @@ -2013,13 +2013,10 @@ int be_cmd_reset_function(struct be_adapter *adapter)  }
 
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
 
 	if (!(be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS)) @@ -2042,7 +2039,7 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 		req->hdr.version = 1;
 
 	memcpy(req->cpu_table, rsstable, table_size);
-	memcpy(req->hash, myhash, sizeof(myhash));
+	memcpy(req->hash, rss_hkey, RSS_HASH_KEY_LEN);
 	be_dws_cpu_to_le(req->hash, sizeof(req->hash));
 
 	status = be_mbox_notify_wait(adapter); diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index fc4e076..630406d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2013 Emulex
+ * Copyright (C) 2005 - 2014 Emulex
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or @@ -2012,7 +2012,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 			u32 *function_mode, u32 *function_caps, u16 *asic_rev);  int be_cmd_reset_function(struct be_adapter *adapter);  int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
-		      u32 rss_hash_opts, u16 table_size);
+		      u32 rss_hash_opts, u16 table_size, u8 *rss_hkey);
 int be_process_mcc(struct be_adapter *adapter);  int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num, u8 beacon,
 			    u8 status, u8 state);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 05be007..7357a69 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2013 Emulex
+ * Copyright (C) 2005 - 2014 Emulex
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or @@ -931,27 +931,27 @@ static u64 be_get_rss_hash_opts(struct be_adapter *adapter, u64 flow_type)
 
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
@@ -990,7 +990,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 	struct be_rx_obj *rxo;
 	int status = 0, i, j;
 	u8 rsstable[128];
-	u32 rss_flags = adapter->rss_flags;
+	u32 rss_flags = adapter->rss_info.rss_flags;
 
 	if (cmd->data != L3_RSS_FLAGS &&
 	    cmd->data != (L3_RSS_FLAGS | L4_RSS_FLAGS)) @@ -1037,7 +1037,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 		return -EINVAL;
 	}
 
-	if (rss_flags == adapter->rss_flags)
+	if (rss_flags == adapter->rss_info.rss_flags)
 		return status;
 
 	if (be_multi_rxq(adapter)) {
@@ -1049,9 +1049,11 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
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
@@ -1101,6 +1103,34 @@ static int be_set_channels(struct net_device  *netdev,
 	return be_update_queues(adapter);
 }
 
+static int be_get_rss_hkey(struct net_device *netdev,
+			  struct ethtool_rss_hkey *cmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	memcpy(cmd->data, adapter->rss_info.rss_hkey, RSS_HASH_KEY_LEN);
+	cmd->data_len = RSS_HASH_KEY_LEN;
+
+	return 0;
+}
+
+static int be_set_rss_hkey(struct net_device *netdev,
+			  struct ethtool_rss_hkey *cmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int rc = 0;
+
+	rc = be_cmd_rss_config(adapter, adapter->rss_info.rsstable,
+			       adapter->rss_info.rss_flags,
+			       128, cmd->data);
+	if (rc) {
+		adapter->rss_info.rss_flags = RSS_ENABLE_NONE;
+		return -EIO;
+	}
+	memcpy(adapter->rss_info.rss_hkey, cmd->data, RSS_HASH_KEY_LEN);
+	return rc;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -1127,6 +1157,8 @@ const struct ethtool_ops be_ethtool_ops = {
 	.self_test = be_self_test,
 	.get_rxnfc = be_get_rxnfc,
 	.set_rxnfc = be_set_rxnfc,
+	.get_rsshkey = be_get_rss_hkey,
+	.set_rsshkey = be_set_rss_hkey,
 	.get_channels = be_get_channels,
 	.set_channels = be_set_channels
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6d22d6f..04f8a66 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2013 Emulex
+ * Copyright (C) 2005 - 2014 Emulex
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or @@ -2695,7 +2695,7 @@ static int be_rx_qs_create(struct be_adapter *adapter)  {
 	struct be_rx_obj *rxo;
 	int rc, i, j;
-	u8 rsstable[128];
+	u8 rss_hkey[RSS_HASH_KEY_LEN];
 
 	for_all_rx_queues(adapter, rxo, i) {
 		rc = be_queue_alloc(adapter, &rxo->q, RX_Q_LEN, @@ -2724,27 +2724,31 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 			for_all_rss_queues(adapter, rxo, i) {
 				if ((j + i) >= 128)
 					break;
-				rsstable[j + i] = rxo->rss_id;
+				adapter->rss_info.rsstable[j + i] = rxo->rss_id;
 			}
 		}
-		adapter->rss_flags = RSS_ENABLE_TCP_IPV4 | RSS_ENABLE_IPV4 |
-					RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6;
+		adapter->rss_info.rss_flags = RSS_ENABLE_TCP_IPV4 |
+			RSS_ENABLE_IPV4 | RSS_ENABLE_TCP_IPV6 | RSS_ENABLE_IPV6;
 
 		if (!BEx_chip(adapter))
-			adapter->rss_flags |= RSS_ENABLE_UDP_IPV4 |
+			adapter->rss_info.rss_flags |= RSS_ENABLE_UDP_IPV4 |
 						RSS_ENABLE_UDP_IPV6;
 	} else {
 		/* Disable RSS, if only default RX Q is created */
-		adapter->rss_flags = RSS_ENABLE_NONE;
+		adapter->rss_info.rss_flags = RSS_ENABLE_NONE;
 	}
 
-	rc = be_cmd_rss_config(adapter, rsstable, adapter->rss_flags,
-			       128);
+	get_random_bytes(rss_hkey, RSS_HASH_KEY_LEN);
+	rc = be_cmd_rss_config(adapter, adapter->rss_info.rsstable,
+			       adapter->rss_info.rss_flags,
+			       128, rss_hkey);
 	if (rc) {
-		adapter->rss_flags = RSS_ENABLE_NONE;
+		adapter->rss_info.rss_flags = RSS_ENABLE_NONE;
 		return rc;
 	}
 
+	memcpy(adapter->rss_info.rss_hkey, rss_hkey, RSS_HASH_KEY_LEN);
+
 	/* First time posting */
 	for_all_rx_queues(adapter, rxo, i)
 		be_post_rx_frags(rxo, GFP_KERNEL);
--
1.7.1
