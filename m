From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/7] be2net: Use GET_PROFILE_CONFIG cmd for BE3-R to query max-vfs
Date: Tue, 11 Mar 2014 18:53:03 +0530
Message-ID: <1394544189-20277-2-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:35588 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbaCKNTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:19:50 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Use GET_PROFILE_CONFIG_V1 cmd even for BE3-R (it's already used for
Lancer-R and Skyhawk-R), to query max-vfs value supported by the FW.
This is needed as on some configs, the value exported in the PCI-config
space is not accurate.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6e10230..5ba1ea5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3150,13 +3150,16 @@ static void BEx_get_resources(struct be_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 	bool use_sriov = false;
-	int max_vfs;
-
-	max_vfs = pci_sriov_get_totalvfs(pdev);
-
-	if (BE3_chip(adapter) && sriov_want(adapter)) {
-		res->max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
-		use_sriov = res->max_vfs;
+	int max_vfs = 0;
+
+	if (be_physfn(adapter) && BE3_chip(adapter)) {
+		be_cmd_get_profile_config(adapter, res, 0);
+		/* Some old versions of BE3 FW don't report max_vfs value */
+		if (res->max_vfs == 0) {
+			max_vfs = pci_sriov_get_totalvfs(pdev);
+			res->max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
+		}
+		use_sriov = res->max_vfs && sriov_want(adapter);
 	}
 
 	if (be_physfn(adapter))
@@ -3197,7 +3200,7 @@ static void BEx_get_resources(struct be_adapter *adapter,
 	res->max_rx_qs = res->max_rss_qs + 1;
 
 	if (be_physfn(adapter))
-		res->max_evt_qs = (max_vfs > 0) ?
+		res->max_evt_qs = (res->max_vfs > 0) ?
 					BE3_SRIOV_MAX_EVT_QS : BE3_MAX_EVT_QS;
 	else
 		res->max_evt_qs = 1;
-- 
1.7.1
