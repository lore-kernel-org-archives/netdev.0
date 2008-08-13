From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 02/25] bnx2x: Not dropping packets with L3/L4 checksum
 error
Date: Wed, 13 Aug 2008 17:12:03 +0300
Message-ID: <1218636723.547.76.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3193 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbYHMOM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not dropping packets with L3/L4 checksum error
Those packets should be passed to the OS. The problem is clear in
forwarding mode.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   24 ++++++++++++++++--------
 drivers/net/bnx2x_main.c |    7 +++----
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4bf4f7b..dc54602 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -386,20 +386,28 @@ struct bnx2x_fastpath {
 #define TPA_TYPE(cqe_fp_flags)		((cqe_fp_flags) & \
 					 (TPA_TYPE_START | TPA_TYPE_END))
 
-#define BNX2X_RX_SUM_OK(cqe) \
-			(!(cqe->fast_path_cqe.status_flags & \
-			 (ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG | \
-			  ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG)))
+#define ETH_RX_ERROR_FALGS		ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG
+
+#define BNX2X_IP_CSUM_ERR(cqe) \
+			(!((cqe)->fast_path_cqe.status_flags & \
+			   ETH_FAST_PATH_RX_CQE_IP_XSUM_NO_VALIDATION_FLG) && \
+			 ((cqe)->fast_path_cqe.type_error_flags & \
+			  ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG))
+
+#define BNX2X_L4_CSUM_ERR(cqe) \
+			(!((cqe)->fast_path_cqe.status_flags & \
+			   ETH_FAST_PATH_RX_CQE_L4_XSUM_NO_VALIDATION_FLG) && \
+			 ((cqe)->fast_path_cqe.type_error_flags & \
+			  ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG))
+
+#define BNX2X_RX_CSUM_OK(cqe) \
+			(!(BNX2X_L4_CSUM_ERR(cqe) || BNX2X_IP_CSUM_ERR(cqe)))
 
 #define BNX2X_RX_SUM_FIX(cqe) \
 			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
 			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) == \
 			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
 
-#define ETH_RX_ERROR_FALGS	(ETH_FAST_PATH_RX_CQE_PHY_DECODE_ERR_FLG | \
-				 ETH_FAST_PATH_RX_CQE_IP_BAD_XSUM_FLG | \
-				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
-
 
 #define FP_USB_FUNC_OFF			(2 + 2*HC_USTORM_SB_NUM_INDICES)
 #define FP_CSB_FUNC_OFF			(2 + 2*HC_CSTORM_SB_NUM_INDICES)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9eb8a3e..b9d376d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1501,7 +1501,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 			/* is this an error packet? */
 			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
-			/* do we sometimes forward error packets anyway? */
 				DP(NETIF_MSG_RX_ERR,
 				   "ERROR  flags %x  rx packet %u\n",
 				   cqe_fp_flags, sw_comp_cons);
@@ -1557,10 +1556,10 @@ reuse_rx:
 			skb->protocol = eth_type_trans(skb, bp->dev);
 
 			skb->ip_summed = CHECKSUM_NONE;
-			if (bp->rx_csum && BNX2X_RX_SUM_OK(cqe))
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			if (bp->rx_csum)
+				if (likely(BNX2X_RX_CSUM_OK(cqe)))
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			/* TBD do we pass bad csum packets in promisc */
 		}
 
 #ifdef BCM_VLAN
-- 
1.5.3.2




