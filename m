From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 4/5] bnx2x: Fix VF memory leak unload
Date: Wed, 28 Aug 2013 01:13:03 +0300
Message-ID: <1377641584-2939-5-git-send-email-yuvalmin@broadcom.com>
References: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2561 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab3H0WNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:13:21 -0400
In-Reply-To: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Due to incorrect VF/PF conditions, when unloading a VF it will not release
part of the memory it has previously allocated.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 9 ++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 26b4dfc..0cc2611 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2962,8 +2962,9 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 	if (IS_PF(bp)) {
 		if (CNIC_LOADED(bp))
 			bnx2x_free_mem_cnic(bp);
-		bnx2x_free_mem(bp);
 	}
+	bnx2x_free_mem(bp);
+
 	bp->state = BNX2X_STATE_CLOSED;
 	bp->cnic_loaded = false;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 8bdc8b9..1627a4e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7855,12 +7855,15 @@ void bnx2x_free_mem(struct bnx2x *bp)
 {
 	int i;
 
-	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
-		       sizeof(struct host_sp_status_block));
-
 	BNX2X_PCI_FREE(bp->fw_stats, bp->fw_stats_mapping,
 		       bp->fw_stats_data_sz + bp->fw_stats_req_sz);
 
+	if (IS_VF(bp))
+		return;
+
+	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
+		       sizeof(struct host_sp_status_block));
+
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
 		       sizeof(struct bnx2x_slowpath));
 
-- 
1.8.1.227.g44fe835
