From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net 1/5] bnx2x: limit number of interrupt vectors for 57711
Date: Sun, 5 Jan 2014 18:33:50 +0200
Message-ID: <1388939634-19948-2-git-send-email-yuvalmin@broadcom.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Dmitry Kravkov <dmitry@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:13126 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaAEQeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 11:34:10 -0500
In-Reply-To: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Original straightforward division may lead to zeroing number of SB and
null-pointer dereference when device is short of MSIX vectors or lacks
MSIX capabilities.

Reported-by: Vladislav Zolotarov <vladz@cloudius-systems.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      | 2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 +++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a1f66e2..cb30d1a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2499,4 +2499,6 @@ void bnx2x_set_local_cmng(struct bnx2x *bp);
 #define MCPR_SCRATCH_BASE(bp) \
 	(CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
 
+#define E1H_MAX_MF_SB_COUNT (HC_SB_MAX_SB_E1X/(E1HVN_MAX * PORT_MAX))
+
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 814d0ec..8b3107b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11447,9 +11447,9 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 		}
 	}
 
-	/* adjust igu_sb_cnt to MF for E1x */
-	if (CHIP_IS_E1x(bp) && IS_MF(bp))
-		bp->igu_sb_cnt /= E1HVN_MAX;
+	/* adjust igu_sb_cnt to MF for E1H */
+	if (CHIP_IS_E1H(bp) && IS_MF(bp))
+		bp->igu_sb_cnt = min_t(u8, bp->igu_sb_cnt, E1H_MAX_MF_SB_COUNT);
 
 	/* port info */
 	bnx2x_get_port_hwinfo(bp);
-- 
1.8.1.227.g44fe835
