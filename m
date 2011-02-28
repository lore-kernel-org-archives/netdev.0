From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 4/7] bnx2x: properly configure coefficients for
 MinBW algorithm (NPAR mode).
Date: Mon, 28 Feb 2011 15:37:11 +0200
Message-ID: <1298900231.28024.118.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4080 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727Ab1B1NjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:39:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |   26 +++++++++++++++-----------
 drivers/net/bnx2x/bnx2x_main.c |    3 ++-
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 653c624..368cfcd 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1613,19 +1613,23 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_BTR			4
 #define MAX_SPQ_PENDING			8
 
-
-/* CMNG constants
-   derived from lab experiments, and not from system spec calculations !!! */
-#define DEF_MIN_RATE			100
+/* CMNG constants, as derived from system spec calculations */
+/* default MIN rate in case VNIC min rate is configured to zero - 100Mbps */
+#define DEF_MIN_RATE					100
 /* resolution of the rate shaping timer - 100 usec */
-#define RS_PERIODIC_TIMEOUT_USEC	100
-/* resolution of fairness algorithm in usecs -
-   coefficient for calculating the actual t fair */
-#define T_FAIR_COEF			10000000
+#define RS_PERIODIC_TIMEOUT_USEC			100
 /* number of bytes in single QM arbitration cycle -
-   coefficient for calculating the fairness timer */
-#define QM_ARB_BYTES			40000
-#define FAIR_MEM			2
+ * coefficient for calculating the fairness timer */
+#define QM_ARB_BYTES					160000
+/* resolution of Min algorithm 1:100 */
+#define MIN_RES						100
+/* how many bytes above threshold for the minimal credit of Min algorithm*/
+#define MIN_ABOVE_THRESH				32768
+/* Fairness algorithm integration time coefficient -
+ * for calculating the actual Tfair */
+#define T_FAIR_COEF	((MIN_ABOVE_THRESH +  QM_ARB_BYTES) * 8 * MIN_RES)
+/* Memory of fairness algorithm . 2 cycles */
+#define FAIR_MEM					2
 
 
 #define ATTN_NIG_FOR_FUNC		(1L << 8)
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 203e9bf..032ae18 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2015,7 +2015,8 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 		m_fair_vn.vn_credit_delta =
 			max_t(u32, (vn_min_rate * (T_FAIR_COEF /
 						   (8 * bp->vn_weight_sum))),
-			      (bp->cmng.fair_vars.fair_threshold * 2));
+			      (bp->cmng.fair_vars.fair_threshold +
+							MIN_ABOVE_THRESH));
 		DP(NETIF_MSG_IFUP, "m_fair_vn.vn_credit_delta %d\n",
 		   m_fair_vn.vn_credit_delta);
 	}
-- 
1.7.2.2




