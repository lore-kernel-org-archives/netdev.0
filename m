From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/7] be2net: move interface create code to a separate routine
Date: Tue, 20 Jan 2015 03:51:43 -0500
Message-ID: <1421743909-14716-2-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:11712 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbbATItH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:07 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This removes a bit of duplication of code that initializes the en_flags.
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 49 +++++++++++++++++------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ed46610..c40d7ef 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3183,13 +3183,32 @@ static int be_clear(struct be_adapter *adapter)
 	return 0;
 }
 
+static int be_if_create(struct be_adapter *adapter, u32 *if_handle,
+			u32 cap_flags, u32 vf)
+{
+	u32 en_flags;
+	int status;
+
+	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
+		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS |
+		   BE_IF_FLAGS_RSS;
+
+	en_flags &= cap_flags;
+
+	status = be_cmd_if_create(adapter, cap_flags, en_flags,
+				  if_handle, vf);
+
+	return status;
+}
+
 static int be_vfs_if_create(struct be_adapter *adapter)
 {
 	struct be_resources res = {0};
 	struct be_vf_cfg *vf_cfg;
-	u32 cap_flags, en_flags, vf;
-	int status = 0;
+	u32 cap_flags, vf;
+	int status;
 
+	/* If a FW profile exists, then cap_flags are updated */
 	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
 		    BE_IF_FLAGS_MULTICAST;
 
@@ -3201,18 +3220,13 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 				cap_flags = res.if_cap_flags;
 		}
 
-		/* If a FW profile exists, then cap_flags are updated */
-		en_flags = cap_flags & (BE_IF_FLAGS_UNTAGGED |
-					BE_IF_FLAGS_BROADCAST |
-					BE_IF_FLAGS_MULTICAST);
-		status =
-		    be_cmd_if_create(adapter, cap_flags, en_flags,
-				     &vf_cfg->if_handle, vf + 1);
+		status = be_if_create(adapter, &vf_cfg->if_handle,
+				      cap_flags, vf + 1);
 		if (status)
-			goto err;
+			return status;
 	}
-err:
-	return status;
+
+	return 0;
 }
 
 static int be_vf_setup_init(struct be_adapter *adapter)
@@ -3653,7 +3667,7 @@ int be_update_queues(struct be_adapter *adapter)
 static int be_setup(struct be_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
-	u32 tx_fc, rx_fc, en_flags;
+	u32 tx_fc, rx_fc;
 	int status;
 
 	be_setup_init(adapter);
@@ -3669,13 +3683,8 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
-		   BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
-	if (adapter->function_caps & BE_FUNCTION_CAPS_RSS)
-		en_flags |= BE_IF_FLAGS_RSS;
-	en_flags = en_flags & be_if_cap_flags(adapter);
-	status = be_cmd_if_create(adapter, be_if_cap_flags(adapter), en_flags,
-				  &adapter->if_handle, 0);
+	status = be_if_create(adapter, &adapter->if_handle,
+			      be_if_cap_flags(adapter), 0);
 	if (status)
 		goto err;
 
-- 
2.2.0
