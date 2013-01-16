From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH net-next] bnx2x: fix GRO parameters
Date: Tue, 15 Jan 2013 21:37:42 -0800
Message-ID: <1358314662.19956.51.camel@edumazet-glaptop>
References: <50F50537.3030608@broadcom.com>
	 <1358260752.8744.5677.camel@edumazet-glaptop>
	 <50F56178.8000502@broadcom.com>
	 <20130115.150914.729025796621947521.davem@davemloft.net>
	 <1358312188.19956.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, ariele@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:58329 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047Ab3APFhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 00:37:45 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so517933pbb.1
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 21:37:45 -0800 (PST)
In-Reply-To: <1358312188.19956.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bnx2x does an internal GRO pass but doesn't provide gso_segs, thus
breaking qdisc_pkt_len_init() in case ingress qdisc is used.

We store gso_segs in NAPI_GRO_CB(skb)->count, where tcp_gro_complete()
expects to find the number of aggregated segments.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuval Mintz <yuvalmin@broadcom.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   44 +++++++-------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 18fc26e..e9bea2e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -439,31 +439,37 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
  */
 #define TPA_TSTAMP_OPT_LEN	12
 /**
- * bnx2x_set_lro_mss - calculate the approximate value of the MSS
+ * bnx2x_set_gro_params - compute GRO values
  *
+ * @skb:		packet skb
  * @bp:			driver handle
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
+static void bnx2x_set_gro_params(struct sk_buff *skb, struct bnx2x *bp,
+				 u16 parsing_flags, u16 len_on_bd,
+				 unsigned int pkt_len)
 {
 	/*
-	 * TPA arrgregation won't have either IP options or TCP options
+	 * TPA aggregation won't have either IP options or TCP options
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
@@ -473,7 +479,13 @@ static u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
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
@@ -527,18 +539,10 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	}
 
 	/* This is needed in order to enable forwarding support */
-	if (frag_size) {
-		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
-					tpa_info->parsing_flags, len_on_bd);
+	if (frag_size)
+		bnx2x_set_gro_params(skb, bp, tpa_info->parsing_flags,
+				     len_on_bd, le16_to_cpu(cqe->pkt_len));
 
-		/* set for GRO */
-		if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size)
-			skb_shinfo(skb)->gso_type =
-			    (GET_FLAG(tpa_info->parsing_flags,
-				      PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
-						PRS_FLAG_OVERETH_IPV6) ?
-				SKB_GSO_TCPV6 : SKB_GSO_TCPV4;
-	}
 
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -651,7 +655,7 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			       struct sk_buff *skb)
 {
 #ifdef CONFIG_INET
-	if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size) {
+	if (skb_shinfo(skb)->gso_size) {
 		skb_set_network_header(skb, 0);
 		switch (be16_to_cpu(skb->protocol)) {
 		case ETH_P_IP:
