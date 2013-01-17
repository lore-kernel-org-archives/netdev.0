From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: fix GRO parameters
Date: Thu, 17 Jan 2013 15:26:21 +0200
Message-ID: <1358429181-3348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1336 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab3AQOZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 09:25:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x does an internal GRO pass but doesn't provide gso_segs, thus
breaking qdisc_pkt_len_init() in case ingress qdisc is used.

We store gso_segs in NAPI_GRO_CB(skb)->count, where tcp_gro_complete()
expects to find the number of aggregated segments.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
This is Eric Dumazet's patch with slight semantic modifications.
Eric - Do you want to put your ack or signoff on this patch?

Dave - Please apply this to 'net-next' afterwards.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 47 ++++++++++++-------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 18fc26e..49810a0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -439,31 +439,34 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
  */
 #define TPA_TSTAMP_OPT_LEN	12
 /**
- * bnx2x_set_lro_mss - calculate the approximate value of the MSS
+ * bnx2x_set_gro_params - compute GRO values
  *
- * @bp:			driver handle
+ * @skb:		packet skb
  * @parsing_flags:	parsing flags from the START CQE
  * @len_on_bd:		total length of the first packet for the
  *			aggregation.
+ * @pkt_len:		length of all segments
  *
  * Approximate value of the MSS for this aggregation calculated using
  * the first packet of it.
+ * Compute number of aggregated segments, and gso_type
  */
-static u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
-			     u16 len_on_bd)
+static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
+				 u16 len_on_bd, unsigned int pkt_len)
 {
-	/*
-	 * TPA arrgregation won't have either IP options or TCP options
+	/* TPA aggregation won't have either IP options or TCP options
 	 * other than timestamp or IPv6 extension headers.
 	 */
 	u16 hdrs_len = ETH_HLEN + sizeof(struct tcphdr);
 
 	if (GET_FLAG(parsing_flags, PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
-	    PRS_FLAG_OVERETH_IPV6)
+	    PRS_FLAG_OVERETH_IPV6) {
 		hdrs_len += sizeof(struct ipv6hdr);
-	else /* IPv4 */
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+	} else {
 		hdrs_len += sizeof(struct iphdr);
-
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	}
 
 	/* Check if there was a TCP timestamp, if there is it's will
 	 * always be 12 bytes length: nop nop kind length echo val.
@@ -473,7 +476,13 @@ static u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
 	if (parsing_flags & PARSING_FLAGS_TIME_STAMP_EXIST_FLAG)
 		hdrs_len += TPA_TSTAMP_OPT_LEN;
 
-	return len_on_bd - hdrs_len;
+	skb_shinfo(skb)->gso_size = len_on_bd - hdrs_len;
+
+	/* tcp_gro_complete() will copy NAPI_GRO_CB(skb)->count
+	 * to skb_shinfo(skb)->gso_segs
+	 */
+	NAPI_GRO_CB(skb)->count = DIV_ROUND_UP(pkt_len - hdrs_len,
+					       skb_shinfo(skb)->gso_size);
 }
 
 static int bnx2x_alloc_rx_sge(struct bnx2x *bp,
@@ -527,19 +536,9 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	}
 
 	/* This is needed in order to enable forwarding support */
-	if (frag_size) {
-		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
-					tpa_info->parsing_flags, len_on_bd);
-
-		/* set for GRO */
-		if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size)
-			skb_shinfo(skb)->gso_type =
-			    (GET_FLAG(tpa_info->parsing_flags,
-				      PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
-						PRS_FLAG_OVERETH_IPV6) ?
-				SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
-	}
-
+	if (frag_size)
+		bnx2x_set_gro_params(skb, tpa_info->parsing_flags, len_on_bd,
+				     le16_to_cpu(cqe->pkt_len));
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
@@ -651,7 +650,7 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			       struct sk_buff *skb)
 {
 #ifdef CONFIG_INET
-	if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		skb_set_network_header(skb, 0);
 		switch (be16_to_cpu(skb->protocol)) {
 		case ETH_P_IP:
-- 
1.8.1.227.g44fe835
