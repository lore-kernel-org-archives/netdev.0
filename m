From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 1/2] be2net: fix promiscuous and multicast promiscuous
	modes being enabled always
Date: Thu, 15 Oct 2009 11:50:42 +0530
Message-ID: <20091015062042.GA31485@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:28643 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752887AbZJOGWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 02:22:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply to net-2.6 tree.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    8 ++++----
 drivers/net/benet/be_cmds.h |    5 +++--
 drivers/net/benet/be_main.c |   19 +++++++++++--------
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 89876ad..b57abc0 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -729,8 +729,8 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 /* Create an rx filtering policy configuration on an i/f
  * Uses mbox
  */
-int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
-		bool pmac_invalid, u32 *if_handle, u32 *pmac_id)
+int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
+		u8 *mac, bool pmac_invalid, u32 *if_handle, u32 *pmac_id)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_if_create *req;
@@ -746,8 +746,8 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 flags, u8 *mac,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_INTERFACE_CREATE, sizeof(*req));
 
-	req->capability_flags = cpu_to_le32(flags);
-	req->enable_flags = cpu_to_le32(flags);
+	req->capability_flags = cpu_to_le32(cap_flags);
+	req->enable_flags = cpu_to_le32(en_flags);
 	req->pmac_invalid = pmac_invalid;
 	if (!pmac_invalid)
 		memcpy(req->mac_addr, mac, ETH_ALEN);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index a86f917..4995378 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -720,8 +720,9 @@ extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 			u32 if_id, u32 *pmac_id);
 extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id);
-extern int be_cmd_if_create(struct be_adapter *adapter, u32 if_flags, u8 *mac,
-			bool pmac_invalid, u32 *if_handle, u32 *pmac_id);
+extern int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags,
+			u32 en_flags, u8 *mac, bool pmac_invalid,
+			u32 *if_handle, u32 *pmac_id);
 extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle);
 extern int be_cmd_eq_create(struct be_adapter *adapter,
 			struct be_queue_info *eq, int eq_delay);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6d5e81f..36cb948 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1620,19 +1620,22 @@ static int be_open(struct net_device *netdev)
 static int be_setup(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 if_flags;
+	u32 cap_flags, en_flags;
 	int status;
 
-	if_flags = BE_IF_FLAGS_BROADCAST | BE_IF_FLAGS_PROMISCUOUS |
-		BE_IF_FLAGS_MCAST_PROMISCUOUS | BE_IF_FLAGS_UNTAGGED |
-		BE_IF_FLAGS_PASS_L3L4_ERRORS;
-	status = be_cmd_if_create(adapter, if_flags, netdev->dev_addr,
-			false/* pmac_invalid */, &adapter->if_handle,
-			&adapter->pmac_id);
+	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
+			BE_IF_FLAGS_MCAST_PROMISCUOUS |
+			BE_IF_FLAGS_PROMISCUOUS |
+			BE_IF_FLAGS_PASS_L3L4_ERRORS;
+	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
+			BE_IF_FLAGS_PASS_L3L4_ERRORS;
+
+	status = be_cmd_if_create(adapter, cap_flags, en_flags,
+			netdev->dev_addr, false/* pmac_invalid */,
+			&adapter->if_handle, &adapter->pmac_id);
 	if (status != 0)
 		goto do_none;
 
-
 	status = be_tx_queues_create(adapter);
 	if (status != 0)
 		goto if_destroy;
-- 
1.6.0.4

