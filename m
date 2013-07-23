From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/6] be2net: delete primary MAC address while unloading
Date: Tue, 23 Jul 2013 15:25:04 +0530
Message-ID: <1374573304-6865-7-git-send-email-sathya.perla@emulex.com>
References: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:49018 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756355Ab3GWJwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 05:52:04 -0400
In-Reply-To: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the UC-list is being deleted from the HW MAC table, but the primary
MAC is not.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9b22791..7c6f03c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2790,7 +2790,7 @@ done:
 
 static int be_clear(struct be_adapter *adapter)
 {
-	int i = 1;
+	int i;
 
 	if (adapter->flags & BE_FLAGS_WORKER_SCHEDULED) {
 		cancel_delayed_work_sync(&adapter->work);
@@ -2800,9 +2800,11 @@ static int be_clear(struct be_adapter *adapter)
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
-	for (; adapter->uc_macs > 0; adapter->uc_macs--, i++)
+	/* delete the primary mac along with the uc-mac list */
+	for (i = 0; i < (adapter->uc_macs + 1); i++)
 		be_cmd_pmac_del(adapter, adapter->if_handle,
-			adapter->pmac_id[i], 0);
+				adapter->pmac_id[i], 0);
+	adapter->uc_macs = 0;
 
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
-- 
1.7.1
