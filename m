From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: prevent FW assert on low mem during
 unload
Date: Sun, 27 Oct 2013 13:07:00 +0200
Message-ID: <1382872021-1116-2-git-send-email-yuvalmin@broadcom.com>
References: <1382872021-1116-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2315 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881Ab3J0LHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 07:07:18 -0400
In-Reply-To: <1382872021-1116-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Buffers for FW statistics were allocated at an inappropriate time; In a machine
where the driver encounters problems allocating all of its queues, the driver
would still create FW requests for the statistics of the non-existing queues.
The wrong order of memory allocation could lead to zeroed statistics messages
being sent, leading to fw assert in case function 0 was down.

This changes the order of allocations, guaranteeing that statistic requests will
only be generated for actual queues.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4ab4c89..74d6486 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2545,10 +2545,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	}
 
-	/* Allocated memory for FW statistics  */
-	if (bnx2x_alloc_fw_stats_mem(bp))
-		LOAD_ERROR_EXIT(bp, load_error0);
-
 	/* need to be done after alloc mem, since it's self adjusting to amount
 	 * of memory available for RSS queues
 	 */
@@ -2558,6 +2554,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		LOAD_ERROR_EXIT(bp, load_error0);
 	}
 
+	/* Allocated memory for FW statistics  */
+	if (bnx2x_alloc_fw_stats_mem(bp))
+		LOAD_ERROR_EXIT(bp, load_error0);
+
 	/* request pf to initialize status blocks */
 	if (IS_VF(bp)) {
 		rc = bnx2x_vfpf_init(bp);
@@ -2812,8 +2812,8 @@ load_error1:
 	if (IS_PF(bp))
 		bnx2x_clear_pf_load(bp);
 load_error0:
-	bnx2x_free_fp_mem(bp);
 	bnx2x_free_fw_stats_mem(bp);
+	bnx2x_free_fp_mem(bp);
 	bnx2x_free_mem(bp);
 
 	return rc;
-- 
1.8.1.227.g44fe835
