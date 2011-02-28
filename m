From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 6/7] bnx2x: properly calculate lro_mss
Date: Mon, 28 Feb 2011 15:37:10 +0200
Message-ID: <1298900230.28024.116.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1936 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753583Ab1B1Niw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:38:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   48 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index a58baf3..73a1f8e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -259,10 +259,44 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 #endif
 }
 
+/* Timestamp option length allowed for TPA aggregation:
+ *
+ *		nop nop kind length echo val
+ */
+#define TPA_TSTAMP_OPT_LEN	12
+/**
+ * Calculate the approximate value of the MSS for this
+ * aggregation using the first packet of it.
+ *
+ * @param bp
+ * @param parsing_flags Parsing flags from the START CQE
+ * @param len_on_bd Total length of the first packet for the
+ *		     aggregation.
+ */
+static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
+				    u16 len_on_bd)
+{
+	/* TPA arrgregation won't have an IP options and TCP options
+	 * other than timestamp.
+	 */
+	u16 hdrs_len = ETH_HLEN + sizeof(struct iphdr) + sizeof(struct tcphdr);
+
+
+	/* Check if there was a TCP timestamp, if there is it's will
+	 * always be 12 bytes length: nop nop kind length echo val.
+	 *
+	 * Otherwise FW would close the aggregation.
+	 */
+	if (parsing_flags & PARSING_FLAGS_TIME_STAMP_EXIST_FLAG)
+		hdrs_len += TPA_TSTAMP_OPT_LEN;
+
+	return len_on_bd - hdrs_len;
+}
+
 static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			       struct sk_buff *skb,
 			       struct eth_fast_path_rx_cqe *fp_cqe,
-			       u16 cqe_idx)
+			       u16 cqe_idx, u16 parsing_flags)
 {
 	struct sw_rx_page *rx_pg, old_rx_pg;
 	u16 len_on_bd = le16_to_cpu(fp_cqe->len_on_bd);
@@ -275,8 +309,8 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* This is needed in order to enable forwarding support */
 	if (frag_size)
-		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
-					       max(frag_size, (u32)len_on_bd));
+		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp, parsing_flags,
+							      len_on_bd);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
@@ -344,6 +378,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	if (likely(new_skb)) {
 		/* fix ip xsum and give it to the stack */
 		/* (no need to map the new skb) */
+		u16 parsing_flags =
+			le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags);
 
 		prefetch(skb);
 		prefetch(((char *)(skb)) + L1_CACHE_BYTES);
@@ -373,9 +409,9 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		}
 
 		if (!bnx2x_fill_frag_skb(bp, fp, skb,
-					 &cqe->fast_path_cqe, cqe_idx)) {
-			if ((le16_to_cpu(cqe->fast_path_cqe.
-			    pars_flags.flags) & PARSING_FLAGS_VLAN))
+					 &cqe->fast_path_cqe, cqe_idx,
+					 parsing_flags)) {
+			if (parsing_flags & PARSING_FLAGS_VLAN)
 				__vlan_hwaccel_put_tag(skb,
 						 le16_to_cpu(cqe->fast_path_cqe.
 							     vlan_tag));
-- 
1.7.2.2




