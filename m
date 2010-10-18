From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 1/6] bnx2x: Optimized the branching in the
 bnx2x_rx_int()
Date: Mon, 18 Oct 2010 11:02:20 +0200
Message-ID: <1287392540.11597.22.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, vladz@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1978 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754070Ab0JRJMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Optimized the branching in the bnx2x_rx_int() based on the fact
that FP CQE will always have at least one of START or STOP flags set,
so if not both bits are set and START bit is not set,
then it's a STOP bit that is set.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 97ef674..cb2a3d6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -507,8 +507,11 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad = cqe->fast_path_cqe.placement_offset;
 
-			/* If CQE is marked both TPA_START and TPA_END
-			   it is a non-TPA CQE */
+			/* - If CQE is marked both TPA_START and TPA_END it is
+			 *   a non-TPA CQE.
+			 * - FP CQE will always have either TPA_START or/and
+			 *   TPA_STOP flags set.
+			 */
 			if ((!fp->disable_tpa) &&
 			    (TPA_TYPE(cqe_fp_flags) !=
 					(TPA_TYPE_START | TPA_TYPE_END))) {
@@ -526,9 +529,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 					bnx2x_set_skb_rxhash(bp, cqe, skb);
 
 					goto next_rx;
-				}
-
-				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_END) {
+				} else { /* TPA_STOP */
 					DP(NETIF_MSG_RX_STATUS,
 					   "calling tpa_stop on queue %d\n",
 					   queue);
-- 
1.7.1




