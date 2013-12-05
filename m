From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 3/3] be2net: Free/delete pmacs (in be_clear()) only if they exist
Date: Thu, 5 Dec 2013 10:35:05 +0530
Message-ID: <70433d29-3e63-4d5b-8b2f-ed3b27ab9e24@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37365 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723Ab3LEFGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:06:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During suspend-resume and lancer error recovery we will cleanup and
re-initialize the resources through be_clear() and be_setup() respectively.
During re-initialisation in be_setup(), if be_get_config() fails, will again
call be_clear() which will cause a NULL pointer reference as adapter->pmac_id is
already freed.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e24294e..1132c1b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2955,28 +2955,35 @@ static void be_cancel_worker(struct be_adapter *adapter)
 	}
 }
 
-static int be_clear(struct be_adapter *adapter)
+static void be_mac_clear(struct be_adapter *adapter)
 {
 	int i;
 
+	if (adapter->pmac_id) {
+		for (i = 0; i < (adapter->uc_macs + 1); i++)
+			be_cmd_pmac_del(adapter, adapter->if_handle,
+					adapter->pmac_id[i], 0);
+		adapter->uc_macs = 0;
+
+		kfree(adapter->pmac_id);
+		adapter->pmac_id = NULL;
+	}
+}
+
+static int be_clear(struct be_adapter *adapter)
+{
 	be_cancel_worker(adapter);
 
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
 	/* delete the primary mac along with the uc-mac list */
-	for (i = 0; i < (adapter->uc_macs + 1); i++)
-		be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id[i], 0);
-	adapter->uc_macs = 0;
+	be_mac_clear(adapter);
 
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
 	be_clear_queues(adapter);
 
-	kfree(adapter->pmac_id);
-	adapter->pmac_id = NULL;
-
 	be_msix_disable(adapter);
 	return 0;
 }
-- 
1.6.0.2
