From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 04/15] be2net: Initialize and cleanup sriov
 resources only if pci_enable_sriov has succeeded.
Date: Fri, 11 Feb 2011 17:35:02 -0600
Message-ID: <20110211233502.GA18338@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51162 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757591Ab1BKXfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:35:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index aab464d..c8075c1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2277,22 +2277,26 @@ static int be_setup(struct be_adapter *adapter)
 		goto do_none;
 
 	if (be_physfn(adapter)) {
-		while (vf < num_vfs) {
-			cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED
-					| BE_IF_FLAGS_BROADCAST;
-			status = be_cmd_if_create(adapter, cap_flags, en_flags,
-					mac, true,
+		if (adapter->sriov_enabled) {
+			while (vf < num_vfs) {
+				cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED |
+							BE_IF_FLAGS_BROADCAST;
+				status = be_cmd_if_create(adapter, cap_flags,
+					en_flags, mac, true,
 					&adapter->vf_cfg[vf].vf_if_handle,
 					NULL, vf+1);
-			if (status) {
-				dev_err(&adapter->pdev->dev,
-				"Interface Create failed for VF %d\n", vf);
-				goto if_destroy;
+				if (status) {
+					dev_err(&adapter->pdev->dev,
+					"Interface Create failed for VF %d\n",
+					vf);
+					goto if_destroy;
+				}
+				adapter->vf_cfg[vf].vf_pmac_id =
+							BE_INVALID_PMAC_ID;
+				vf++;
 			}
-			adapter->vf_cfg[vf].vf_pmac_id = BE_INVALID_PMAC_ID;
-			vf++;
 		}
-	} else if (!be_physfn(adapter)) {
+	} else {
 		status = be_cmd_mac_addr_query(adapter, mac,
 			MAC_ADDRESS_TYPE_NETWORK, false, adapter->if_handle);
 		if (!status) {
@@ -2313,7 +2317,7 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
-	if (be_physfn(adapter)) {
+	if (be_physfn(adapter) && adapter->sriov_enabled) {
 		status = be_vf_eth_addr_config(adapter);
 		if (status)
 			goto mcc_q_destroy;
@@ -2332,9 +2336,10 @@ rx_qs_destroy:
 tx_qs_destroy:
 	be_tx_queues_destroy(adapter);
 if_destroy:
-	for (vf = 0; vf < num_vfs; vf++)
-		if (adapter->vf_cfg[vf].vf_if_handle)
-			be_cmd_if_destroy(adapter,
+	if (be_physfn(adapter) && adapter->sriov_enabled)
+		for (vf = 0; vf < num_vfs; vf++)
+			if (adapter->vf_cfg[vf].vf_if_handle)
+				be_cmd_if_destroy(adapter,
 					adapter->vf_cfg[vf].vf_if_handle,
 					vf + 1);
 	be_cmd_if_destroy(adapter, adapter->if_handle, 0);
@@ -2344,7 +2349,7 @@ do_none:
 
 static int be_clear(struct be_adapter *adapter)
 {
-	if (be_physfn(adapter))
+	if (be_physfn(adapter) && adapter->sriov_enabled)
 		be_vf_eth_addr_rem(adapter);
 
 	be_mcc_queues_destroy(adapter);
-- 
1.7.1

