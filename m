From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 14:38:21 +0800
Message-ID: <4E82C0DD.6010304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50185 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112Ab1I1GiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 02:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lost_skb_hint is used by tcp_mark_head_lost() to mark the first
unhandled skb. lost_cnt_hint is the number of sacked packets before
the lost_skb_hint. tcp_shifted_skb() shouldn't increase lost_cnt_hint
when shifting a sacked skb that is before the lost_skb_hint, because
packets in it are already counted.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21fab3e..f712ace 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1390,9 +1390,14 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	BUG_ON(!pcount);
 
 	/* Tweak before seqno plays */
-	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
-	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
-		tp->lost_cnt_hint += pcount;
+	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
+		if (skb == tp->lost_skb_hint)
+			tp->lost_cnt_hint += pcount;
+		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
+			 before(TCP_SKB_CB(skb)->seq,
+				TCP_SKB_CB(tp->lost_skb_hint)->seq))
+			tp->lost_cnt_hint += pcount;
+	}
 
 	TCP_SKB_CB(prev)->end_seq += shifted;
 	TCP_SKB_CB(skb)->seq += shifted;
