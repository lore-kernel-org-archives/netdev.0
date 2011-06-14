From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 2/24] bnx2x: do not allocate FCoE ring if
 disabled
Date: Tue, 14 Jun 2011 14:32:47 +0300
Message-ID: <201106141432.47817.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2153 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276Ab1FNLd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index d89a877..3742514 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2606,7 +2606,12 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 #ifdef BCM_CNIC
 	}
 #endif
-	set_sb_shortcuts(bp, index);
+
+	/* FCoE Queue uses Default SB and doesn't ACK the SB, thus no need to
+	 * set shortcuts for it.
+	 */
+	if (!IS_FCOE_IDX(index))
+		set_sb_shortcuts(bp, index);
 
 	/* Tx */
 	if (!skip_tx_queue(bp, index)) {
@@ -2683,9 +2688,13 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 	if (bnx2x_alloc_fp_mem_at(bp, 0))
 		return -ENOMEM;
 #ifdef BCM_CNIC
-	/* FCoE */
-	if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX))
-		return -ENOMEM;
+	if (!NO_FCOE(bp))
+		/* FCoE */
+		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX))
+			/* we will fail load process instead of mark
+			 * NO_FCOE_FLAG
+			 */
+			return -ENOMEM;
 #endif
 	/* RSS */
 	for_each_nondefault_eth_queue(bp, i)
-- 
1.7.2.2


