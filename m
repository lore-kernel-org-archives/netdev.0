From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Wed, 14 Jan 2009 18:42:55 +0200
Message-ID: <1231951375.11301.126.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2653 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762900AbZANQno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TPA (HW GRO) is used, the GSO_TYPE should be set

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    9 ++++++---
 drivers/net/bnx2x_main.c |    7 ++++++-
 drivers/net/bnx2x_reg.h  |    1 +
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 73f6c21..b9bc285 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -401,10 +401,13 @@ struct bnx2x_fastpath {
 #define BNX2X_RX_CSUM_OK(cqe) \
 			(!(BNX2X_L4_CSUM_ERR(cqe) || BNX2X_IP_CSUM_ERR(cqe)))
 
+#define BNX2X_PRS_FLAG_OVERETH_IPV4(flags) \
+				(((le16_to_cpu(flags) & \
+				   PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) >> \
+				  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT) \
+				 == PRS_FLAG_OVERETH_IPV4)
 #define BNX2X_RX_SUM_FIX(cqe) \
-			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
-			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) == \
-			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
+	BNX2X_PRS_FLAG_OVERETH_IPV4(cqe->fast_path_cqe.pars_flags.flags)
 
 
 #define FP_USB_FUNC_OFF			(2 + 2*HC_USTORM_SB_NUM_INDICES)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e811ecb..da18528 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1225,9 +1225,14 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
 
 	/* This is needed in order to enable forwarding support */
-	if (frag_size)
+	if (frag_size) {
 		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
 					       max(frag_size, (u32)len_on_bd));
+		if (BNX2X_PRS_FLAG_OVERETH_IPV4(fp_cqe->pars_flags.flags))
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+		else
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+	}
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (pages >
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index a67b0c3..ed0d19a 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5020,6 +5020,7 @@
 #define HW_LOCK_RESOURCE_PORT0_ATT_MASK 			 3
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
+#define PRS_FLAG_OVERETH_IPV4					 1
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT		      (1<<31)
 #define AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT		      (1<<9)
-- 
1.5.4.3




