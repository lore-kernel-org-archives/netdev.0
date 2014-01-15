From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 06/11] be2net: fix incorrect setting of cmd_privileges for VFs
Date: Wed, 15 Jan 2014 13:23:36 +0530
Message-ID: <1389772421-24925-7-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:17689 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaAOHtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:16 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

An earlier commit (f25b119c "Fix error messages while driver load for VFs")
incorrectly set the adapter->cmd_privileges value for VFs (in a
multi-channel config) to MAX_PRIVILEGES. This causes FW cmd failures
and avoidable error logs when certian cmds are issued by a VF.
Also, move the multi-channel hack to be_cmds.c inside
be_cmd_get_fn_privileges() routine.

Fixes: f25b119c "Fix error messages while driver load for VFs"

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    7 +++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    8 ++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   11 -----------
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index b0a2fd6..cf5b8b0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2691,6 +2691,13 @@ int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 		struct be_cmd_resp_get_fn_privileges *resp =
 						embedded_payload(wrb);
 		*privilege = le32_to_cpu(resp->privilege_mask);
+
+		/* In UMC mode FW does not return right privileges.
+		 * Override with correct privilege equivalent to PF.
+		 */
+		if (BEx_chip(adapter) && be_is_mc(adapter) &&
+		    be_physfn(adapter))
+			*privilege = MAX_PRIVILEGES;
 	}
 
 err:
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 39b99f2..da182c0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1098,6 +1098,14 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 function_caps;
 };
 
+/* Is BE in a multi-channel mode */
+static inline bool be_is_mc(struct be_adapter *adapter)
+{
+	return adapter->function_mode & FLEX10_MODE ||
+		adapter->function_mode & VNIC_MODE ||
+		adapter->function_mode & UMC_ENABLED;
+}
+
 /******************** RSS Config ****************************************/
 /* RSS type		Input parameters used to compute RX hash
  * RSS_ENABLE_IPV4	SRC IPv4, DST IPv4
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ce589b4..9c90a87 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -121,12 +121,6 @@ static const char * const ue_status_hi_desc[] = {
 	"Unknown"
 };
 
-/* Is BE in a multi-channel mode */
-static inline bool be_is_mc(struct be_adapter *adapter) {
-	return (adapter->function_mode & FLEX10_MODE ||
-		adapter->function_mode & VNIC_MODE ||
-		adapter->function_mode & UMC_ENABLED);
-}
 
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
@@ -3410,11 +3404,6 @@ static int be_setup(struct be_adapter *adapter)
 		goto err;
 
 	be_cmd_get_fn_privileges(adapter, &adapter->cmd_privileges, 0);
-	/* In UMC mode FW does not return right privileges.
-	 * Override with correct privilege equivalent to PF.
-	 */
-	if (be_is_mc(adapter))
-		adapter->cmd_privileges = MAX_PRIVILEGES;
 
 	status = be_mac_setup(adapter);
 	if (status)
-- 
1.7.1
