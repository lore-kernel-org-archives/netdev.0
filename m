From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/11] bnxt_en: Refactor bnxt_gro_skb().
Date: Mon, 13 Jun 2016 02:25:34 -0400
Message-ID: <1465799138-27529-8-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34618 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964808AbcFMGZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:58 -0400
Received: by mail-pa0-f42.google.com with SMTP id bz2so42651396pad.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:57 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer chips require different logic to handle GRO packets.  So refactor
the code so that we can call different functions depending on the chip.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 52 ++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 ++
 2 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 0fd27b0..4e3b9f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -945,29 +945,15 @@ static void bnxt_abort_tpa(struct bnxt *bp, struct bnxt_napi *bnapi,
 #define BNXT_IPV4_HDR_SIZE	(sizeof(struct iphdr) + sizeof(struct tcphdr))
 #define BNXT_IPV6_HDR_SIZE	(sizeof(struct ipv6hdr) + sizeof(struct tcphdr))
 
-static inline struct sk_buff *bnxt_gro_skb(struct bnxt_tpa_info *tpa_info,
-					   struct rx_tpa_end_cmp *tpa_end,
-					   struct rx_tpa_end_cmp_ext *tpa_end1,
+static struct sk_buff *bnxt_gro_func_5730x(struct bnxt_tpa_info *tpa_info,
+					   int payload_off, int tcp_ts,
 					   struct sk_buff *skb)
 {
 #ifdef CONFIG_INET
 	struct tcphdr *th;
-	int payload_off, tcp_opt_len = 0;
-	int len, nw_off;
-	u16 segs;
-
-	segs = TPA_END_TPA_SEGS(tpa_end);
-	if (segs == 1)
-		return skb;
+	int len, nw_off, tcp_opt_len;
 
-	NAPI_GRO_CB(skb)->count = segs;
-	skb_shinfo(skb)->gso_size =
-		le32_to_cpu(tpa_end1->rx_tpa_end_cmp_seg_len);
-	skb_shinfo(skb)->gso_type = tpa_info->gso_type;
-	payload_off = (le32_to_cpu(tpa_end->rx_tpa_end_cmp_misc_v1) &
-		       RX_TPA_END_CMP_PAYLOAD_OFFSET) >>
-		      RX_TPA_END_CMP_PAYLOAD_OFFSET_SHIFT;
-	if (TPA_END_GRO_TS(tpa_end))
+	if (tcp_ts)
 		tcp_opt_len = 12;
 
 	if (tpa_info->gso_type == SKB_GSO_TCPV4) {
@@ -1024,6 +1010,32 @@ static inline struct sk_buff *bnxt_gro_skb(struct bnxt_tpa_info *tpa_info,
 	return skb;
 }
 
+static inline struct sk_buff *bnxt_gro_skb(struct bnxt *bp,
+					   struct bnxt_tpa_info *tpa_info,
+					   struct rx_tpa_end_cmp *tpa_end,
+					   struct rx_tpa_end_cmp_ext *tpa_end1,
+					   struct sk_buff *skb)
+{
+#ifdef CONFIG_INET
+	int payload_off;
+	u16 segs;
+
+	segs = TPA_END_TPA_SEGS(tpa_end);
+	if (segs == 1)
+		return skb;
+
+	NAPI_GRO_CB(skb)->count = segs;
+	skb_shinfo(skb)->gso_size =
+		le32_to_cpu(tpa_end1->rx_tpa_end_cmp_seg_len);
+	skb_shinfo(skb)->gso_type = tpa_info->gso_type;
+	payload_off = (le32_to_cpu(tpa_end->rx_tpa_end_cmp_misc_v1) &
+		       RX_TPA_END_CMP_PAYLOAD_OFFSET) >>
+		      RX_TPA_END_CMP_PAYLOAD_OFFSET_SHIFT;
+	skb = bp->gro_func(tpa_info, payload_off, TPA_END_GRO_TS(tpa_end), skb);
+#endif
+	return skb;
+}
+
 static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 					   struct bnxt_napi *bnapi,
 					   u32 *raw_cons,
@@ -1134,7 +1146,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 	}
 
 	if (TPA_END_GRO(tpa_end))
-		skb = bnxt_gro_skb(tpa_info, tpa_end, tpa_end1, skb);
+		skb = bnxt_gro_skb(bp, tpa_info, tpa_end, tpa_end1, skb);
 
 	return skb;
 }
@@ -6420,6 +6432,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
+	bp->gro_func = bnxt_gro_func_5730x;
+
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
 	if (rc)
 		goto init_err;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b754be6..d62f4c2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -953,6 +953,9 @@ struct bnxt {
 	struct bnxt_rx_ring_info	*rx_ring;
 	struct bnxt_tx_ring_info	*tx_ring;
 
+	struct sk_buff *	(*gro_func)(struct bnxt_tpa_info *, int, int,
+					    struct sk_buff *);
+
 	u32			rx_buf_size;
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_ring_size;
-- 
1.8.3.1
