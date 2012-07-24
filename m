From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 1/1] bnx2x: Correct EEE statistics gathering
Date: Tue, 24 Jul 2012 10:16:06 +0300
Message-ID: <1343114166-30834-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3707 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755437Ab2GXHQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 03:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In boards with 4-ports, Tx LPI statistics were gathered incorrectly.
This patch guarantees that each pmf will only query its own port for
these statistics.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This fix is sent to 'net-next' since EEE implementation hasn't passed
to 'net' yet.

Please consider applying this to 'net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h   |    4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    8 +++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index ec62a5c..28a0bcf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1603,6 +1603,10 @@
  * of counts that the SM entered the EEE LPI state. Clock 25MHz. Read only
  * register. Reset on hard reset. */
 #define MISC_REG_CPMU_LP_SM_ENT_CNT_P0				 0xa8b8
+/* [RW 16] EEE LPI Entry Events Counter. A statistic counter with the number
+ * of counts that the SM entered the EEE LPI state. Clock 25MHz. Read only
+ * register. Reset on hard reset. */
+#define MISC_REG_CPMU_LP_SM_ENT_CNT_P1				 0xa8bc
 /* [RW 32] The following driver registers(1...16) represent 16 drivers and
    32 clients. Each client can be controlled by one driver only. One in each
    bit represent that this driver control the appropriate client (Ex: bit 5
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 667d890..332db64 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -785,9 +785,11 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 
 	pstats->host_port_stats_counter++;
 
-	if (CHIP_IS_E3(bp))
-		estats->eee_tx_lpi += REG_RD(bp,
-					     MISC_REG_CPMU_LP_SM_ENT_CNT_P0);
+	if (CHIP_IS_E3(bp)) {
+		u32 lpi_reg = BP_PORT(bp) ? MISC_REG_CPMU_LP_SM_ENT_CNT_P1
+					  : MISC_REG_CPMU_LP_SM_ENT_CNT_P0;
+		estats->eee_tx_lpi += REG_RD(bp, lpi_reg);
+	}
 
 	if (!BP_NOMCP(bp)) {
 		u32 nig_timer_max =
-- 
1.7.9.rc2
