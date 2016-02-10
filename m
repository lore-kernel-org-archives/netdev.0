From: ajit.khaparde@broadcom.com
Subject: [PATCH net-next 1/2] be2net: Request RSS capability of Rx interface depending on number of Rx rings
Date: Wed, 10 Feb 2016 22:45:53 +0530
Message-ID: <1455124554-7819-2-git-send-email-ajit.khaparde@broadcom.com>
References: <1455124554-7819-1-git-send-email-ajit.khaparde@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:52737 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752856AbcBJRRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 12:17:47 -0500
In-Reply-To: <1455124554-7819-1-git-send-email-ajit.khaparde@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@broadcom.com>

Currently we request RSS capability even if a single Rx ring is created.
As a result in few cases we unnecessarily consume an RSS capable interface
which is a limited resource in the chip.
This patch enables RSS on an interface only if more than one Rx ring
is created.

Signed-off-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 19 +++-------
 drivers/net/ethernet/emulex/benet/be_main.c | 58 +++++++++++++++++++++--------
 2 files changed, 48 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 7d51d47..33cbbde 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1513,34 +1513,25 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 	return status;
 }
 
-/* Uses MCCQ */
+/* Uses MCCQ if available else MBOX */
 int be_cmd_if_destroy(struct be_adapter *adapter, int interface_id, u32 domain)
 {
-	struct be_mcc_wrb *wrb;
+	struct be_mcc_wrb wrb = {0};
 	struct be_cmd_req_if_destroy *req;
 	int status;
 
 	if (interface_id == -1)
 		return 0;
 
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-	req = embedded_payload(wrb);
+	req = embedded_payload(&wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			       OPCODE_COMMON_NTWK_INTERFACE_DESTROY,
-			       sizeof(*req), wrb, NULL);
+			       sizeof(*req), &wrb, NULL);
 	req->hdr.domain = domain;
 	req->interface_id = cpu_to_le32(interface_id);
 
-	status = be_mcc_notify_wait(adapter);
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
+	status = be_cmd_notify_wait(adapter, &wrb);
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c1fc9d..e4fc874 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3365,6 +3365,7 @@ done:
 
 static void be_rx_qs_destroy(struct be_adapter *adapter)
 {
+	struct rss_info *rss = &adapter->rss_info;
 	struct be_queue_info *q;
 	struct be_rx_obj *rxo;
 	int i;
@@ -3391,6 +3392,12 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 		}
 		be_queue_free(adapter, q);
 	}
+
+	if (rss->rss_flags) {
+		rss->rss_flags = RSS_ENABLE_NONE;
+		be_cmd_rss_config(adapter, rss->rsstable, rss->rss_flags,
+				  128, rss->rss_hkey);
+	}
 }
 
 static void be_disable_if_filters(struct be_adapter *adapter)
@@ -3511,20 +3518,21 @@ static int be_rx_qs_create(struct be_adapter *adapter)
 		if (!BEx_chip(adapter))
 			rss->rss_flags |= RSS_ENABLE_UDP_IPV4 |
 				RSS_ENABLE_UDP_IPV6;
+
+		netdev_rss_key_fill(rss_key, RSS_HASH_KEY_LEN);
+		rc = be_cmd_rss_config(adapter, rss->rsstable, rss->rss_flags,
+				       RSS_INDIR_TABLE_LEN, rss_key);
+		if (rc) {
+			rss->rss_flags = RSS_ENABLE_NONE;
+			return rc;
+		}
+
+		memcpy(rss->rss_hkey, rss_key, RSS_HASH_KEY_LEN);
 	} else {
 		/* Disable RSS, if only default RX Q is created */
 		rss->rss_flags = RSS_ENABLE_NONE;
 	}
 
-	netdev_rss_key_fill(rss_key, RSS_HASH_KEY_LEN);
-	rc = be_cmd_rss_config(adapter, rss->rsstable, rss->rss_flags,
-			       RSS_INDIR_TABLE_LEN, rss_key);
-	if (rc) {
-		rss->rss_flags = RSS_ENABLE_NONE;
-		return rc;
-	}
-
-	memcpy(rss->rss_hkey, rss_key, RSS_HASH_KEY_LEN);
 
 	/* Post 1 less than RXQ-len to avoid head being equal to tail,
 	 * which is a queue empty condition
@@ -4306,6 +4314,23 @@ err:
 	return status;
 }
 
+static int be_if_create(struct be_adapter *adapter)
+{
+	u32 en_flags = BE_IF_FLAGS_RSS | BE_IF_FLAGS_DEFQ_RSS;
+	u32 cap_flags = be_if_cap_flags(adapter);
+	int status;
+
+	if (adapter->cfg_num_qs == 1)
+		cap_flags &= ~(BE_IF_FLAGS_DEFQ_RSS | BE_IF_FLAGS_RSS);
+
+	en_flags &= cap_flags;
+	/* will enable all the needed filter flags in be_open() */
+	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
+				  &adapter->if_handle, 0);
+
+	return status;
+}
+
 int be_update_queues(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4323,6 +4348,9 @@ int be_update_queues(struct be_adapter *adapter)
 		be_msix_disable(adapter);
 
 	be_clear_queues(adapter);
+	status = be_cmd_if_destroy(adapter, adapter->if_handle,  0);
+	if (status)
+		return status;
 
 	if (!msix_enabled(adapter)) {
 		status = be_msix_enable(adapter);
@@ -4330,6 +4358,10 @@ int be_update_queues(struct be_adapter *adapter)
 			return status;
 	}
 
+	status = be_if_create(adapter);
+	if (status)
+		return status;
+
 	status = be_setup_queues(adapter);
 	if (status)
 		return status;
@@ -4394,7 +4426,6 @@ static int be_func_init(struct be_adapter *adapter)
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 en_flags;
 	int status;
 
 	status = be_func_init(adapter);
@@ -4427,10 +4458,7 @@ static int be_setup(struct be_adapter *adapter)
 		goto err;
 
 	/* will enable all the needed filter flags in be_open() */
-	en_flags = BE_IF_FLAGS_RSS | BE_IF_FLAGS_DEFQ_RSS;
-	en_flags = en_flags & be_if_cap_flags(adapter);
-	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
-				  &adapter->if_handle, 0);
+	status = be_if_create(adapter);
 	if (status)
 		goto err;
 
@@ -4803,7 +4831,7 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
 		NETIF_F_HW_VLAN_CTAG_TX;
-	if (be_multi_rxq(adapter))
+	if ((be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS))
 		netdev->hw_features |= NETIF_F_RXHASH;
 
 	netdev->features |= netdev->hw_features |
-- 
2.4.3
