From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/5] bnx2x: Fix memory leak
Date: Wed, 24 Apr 2013 14:45:01 +0300
Message-ID: <1366803902-17870-5-git-send-email-yuvalmin@broadcom.com>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1044 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab3DXMqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:34 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exists an `allocation race' between the CNIC and bnx2x drivers,
in which both drivers allocate the same t2 memory while disregarding a possible
previous allocation.

Additionally, due to the current order of memory releases, some of the
ILT memory in the driver is not released correctly when unloading the driver.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e8ed78f..fd20a4f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2934,9 +2934,9 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 		bnx2x_free_fp_mem_cnic(bp);
 
 	if (IS_PF(bp)) {
-		bnx2x_free_mem(bp);
 		if (CNIC_LOADED(bp))
 			bnx2x_free_mem_cnic(bp);
+		bnx2x_free_mem(bp);
 	}
 	bp->state = BNX2X_STATE_CLOSED;
 	bp->cnic_loaded = false;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9b4fb20..4019465 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7786,7 +7786,7 @@ int bnx2x_alloc_mem_cnic(struct bnx2x *bp)
 				sizeof(struct
 				       host_hc_status_block_e1x));
 
-	if (CONFIGURE_NIC_MODE(bp))
+	if (CONFIGURE_NIC_MODE(bp) && !bp->t2)
 		/* allocate searcher T2 table, as it wan't allocated before */
 		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
 
@@ -7809,7 +7809,7 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 {
 	int i, allocated, context_size;
 
-	if (!CONFIGURE_NIC_MODE(bp))
+	if (!CONFIGURE_NIC_MODE(bp) && !bp->t2)
 		/* allocate searcher T2 table */
 		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, SRC_T2_SZ);
 
-- 
1.8.1.227.g44fe835
