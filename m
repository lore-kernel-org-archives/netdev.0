From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 2/5] bnxt_en: Determine tcp/ipv6 RSS hash type correctly.
Date: Thu, 5 Nov 2015 16:25:48 -0500
Message-ID: <1446758751-27999-3-git-send-email-mchan@broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:6079 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757193AbbKEVZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:52 -0500
In-Reply-To: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The profile ID in the completion record needs to be ANDed with the
profile ID mask of 0x1f.  This bug was causing the SKB hash type
and the gso_type to be wrong in some cases.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 4cae492..5afe65d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -166,9 +166,11 @@ struct rx_cmp {
 #define RX_CMP_HASH_VALID(rxcmp)				\
 	((rxcmp)->rx_cmp_len_flags_type & cpu_to_le32(RX_CMP_FLAGS_RSS_VALID))
 
+#define RSS_PROFILE_ID_MASK	0x1f
+
 #define RX_CMP_HASH_TYPE(rxcmp)					\
-	((le32_to_cpu((rxcmp)->rx_cmp_misc_v1) & RX_CMP_RSS_HASH_TYPE) >>\
-	 RX_CMP_RSS_HASH_TYPE_SHIFT)
+	(((le32_to_cpu((rxcmp)->rx_cmp_misc_v1) & RX_CMP_RSS_HASH_TYPE) >>\
+	  RX_CMP_RSS_HASH_TYPE_SHIFT) & RSS_PROFILE_ID_MASK)
 
 struct rx_cmp_ext {
 	__le32 rx_cmp_flags2;
@@ -282,9 +284,9 @@ struct rx_tpa_start_cmp {
 	 cpu_to_le32(RX_TPA_START_CMP_FLAGS_RSS_VALID))
 
 #define TPA_START_HASH_TYPE(rx_tpa_start)				\
-	((le32_to_cpu((rx_tpa_start)->rx_tpa_start_cmp_misc_v1) &	\
-	  RX_TPA_START_CMP_RSS_HASH_TYPE) >>				\
-	 RX_TPA_START_CMP_RSS_HASH_TYPE_SHIFT)
+	(((le32_to_cpu((rx_tpa_start)->rx_tpa_start_cmp_misc_v1) &	\
+	   RX_TPA_START_CMP_RSS_HASH_TYPE) >>				\
+	  RX_TPA_START_CMP_RSS_HASH_TYPE_SHIFT) & RSS_PROFILE_ID_MASK)
 
 #define TPA_START_AGG_ID(rx_tpa_start)					\
 	((le32_to_cpu((rx_tpa_start)->rx_tpa_start_cmp_misc_v1) &	\
-- 
1.8.3.1
