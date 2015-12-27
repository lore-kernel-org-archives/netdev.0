From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 06/12] bnxt_en: Don't treat single segment rx frames as GRO frames.
Date: Sun, 27 Dec 2015 18:19:23 -0500
Message-ID: <1451258369-21543-7-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:19787 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476AbbL0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:30 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If hardware completes single segment rx frames, don't bother setting
up all the GRO related fields.  Pass the SKB up as a normal frame.

Reviewed-by: vasundhara volam <vvolam@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 06ce100..082c1e9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -856,8 +856,13 @@ static inline struct sk_buff *bnxt_gro_skb(struct bnxt_tpa_info *tpa_info,
 	struct tcphdr *th;
 	int payload_off, tcp_opt_len = 0;
 	int len, nw_off;
+	u16 segs;
 
-	NAPI_GRO_CB(skb)->count = TPA_END_TPA_SEGS(tpa_end);
+	segs = TPA_END_TPA_SEGS(tpa_end);
+	if (segs == 1)
+		return skb;
+
+	NAPI_GRO_CB(skb)->count = segs;
 	skb_shinfo(skb)->gso_size =
 		le32_to_cpu(tpa_end1->rx_tpa_end_cmp_seg_len);
 	skb_shinfo(skb)->gso_type = tpa_info->gso_type;
-- 
1.8.3.1
