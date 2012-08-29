From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 4/5] be2net: fixup malloc/free of adapter->pmac_id
Date: Wed, 29 Aug 2012 12:07:43 +0530
Message-ID: <b63ac3a4-f9b5-42f2-8db9-4be675a5aa43@exht1.ad.emulex.com>
References: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9999 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914Ab2H2G47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:56:59 -0400
In-Reply-To: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free was missing and kcalloc() is better placed in be_ctrl_init()

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1494f2fc..6d139d6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3438,6 +3438,7 @@ static void be_ctrl_cleanup(struct be_adapter *adapter)
 	if (mem->va)
 		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
 				  mem->dma);
+	kfree(adapter->pmac_id);
 }
 
 static int be_ctrl_init(struct be_adapter *adapter)
@@ -3474,6 +3475,12 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	}
 	memset(rx_filter->va, 0, rx_filter->size);
 
+	/* primary mac needs 1 pmac entry */
+	adapter->pmac_id = kcalloc(adapter->max_pmac_cnt + 1,
+				   sizeof(*adapter->pmac_id), GFP_KERNEL);
+	if (!adapter->pmac_id)
+		return -ENOMEM;
+
 	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
@@ -3610,12 +3617,6 @@ static int be_get_initial_config(struct be_adapter *adapter)
 	else
 		adapter->max_pmac_cnt = BE_VF_UC_PMAC_COUNT;
 
-	/* primary mac needs 1 pmac entry */
-	adapter->pmac_id = kcalloc(adapter->max_pmac_cnt + 1,
-				  sizeof(u32), GFP_KERNEL);
-	if (!adapter->pmac_id)
-		return -ENOMEM;
-
 	status = be_cmd_get_cntl_attributes(adapter);
 	if (status)
 		return status;
-- 
1.7.4
