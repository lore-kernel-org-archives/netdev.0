From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/2] bnxt_en: Add missing logic to handle TPA end error conditions.
Date: Fri, 23 Jun 2017 14:01:00 -0400
Message-ID: <1498240861-17730-2-git-send-email-michael.chan@broadcom.com>
References: <1498240861-17730-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:33175 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754592AbdFWSBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:01:17 -0400
Received: by mail-qt0-f173.google.com with SMTP id u12so40289851qth.0
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 11:01:17 -0700 (PDT)
In-Reply-To: <1498240861-17730-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we get a TPA_END completion to handle a completed LRO packet, it
is possible that hardware would indicate errors.  The current code is
not checking for the error condition.  Define the proper error bits and
the macro to check for this error and abort properly.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 7 ++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 6 +++++-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 03f55da..f5ba8ec 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1301,10 +1301,11 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 		cp_cons = NEXT_CMP(cp_cons);
 	}
 
-	if (unlikely(agg_bufs > MAX_SKB_FRAGS)) {
+	if (unlikely(agg_bufs > MAX_SKB_FRAGS || TPA_END_ERRORS(tpa_end1))) {
 		bnxt_abort_tpa(bp, bnapi, cp_cons, agg_bufs);
-		netdev_warn(bp->dev, "TPA frags %d exceeded MAX_SKB_FRAGS %d\n",
-			    agg_bufs, (int)MAX_SKB_FRAGS);
+		if (agg_bufs > MAX_SKB_FRAGS)
+			netdev_warn(bp->dev, "TPA frags %d exceeded MAX_SKB_FRAGS %d\n",
+				    agg_bufs, (int)MAX_SKB_FRAGS);
 		return NULL;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3ef42db..d46a850 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -374,12 +374,16 @@ struct rx_tpa_end_cmp_ext {
 
 	__le32 rx_tpa_end_cmp_errors_v2;
 	#define RX_TPA_END_CMP_V2				(0x1 << 0)
-	#define RX_TPA_END_CMP_ERRORS				(0x7fff << 1)
+	#define RX_TPA_END_CMP_ERRORS				(0x3 << 1)
 	#define RX_TPA_END_CMPL_ERRORS_SHIFT			 1
 
 	u32 rx_tpa_end_cmp_start_opaque;
 };
 
+#define TPA_END_ERRORS(rx_tpa_end_ext)					\
+	((rx_tpa_end_ext)->rx_tpa_end_cmp_errors_v2 &			\
+	 cpu_to_le32(RX_TPA_END_CMP_ERRORS))
+
 #define DB_IDX_MASK						0xffffff
 #define DB_IDX_VALID						(0x1 << 26)
 #define DB_IRQ_DIS						(0x1 << 27)
-- 
1.8.3.1
