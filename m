From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] tcp6: don't move IP6CB before xfrm6_policy_check()
Date: Mon, 22 Dec 2014 18:22:48 +0100
Message-ID: <1419268968-4136-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34012 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846AbaLVRXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 12:23:08 -0500
In-Reply-To: <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xfrm6_policy_check() is used, _decode_session6() is called after some
intermediate functions. This function uses IP6CB(), thus TCP_SKB_CB() must be
prepared after the call of xfrm6_policy_check().

Before this patch, scenarii with IPv6 + TCP + IPsec Transport are broken.

Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
Reported-by: Huaibin Wang <huaibin.wang@6wind.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/tcp_ipv6.c | 45 +++++++++++++++++++++++++++++----------------
 1 file changed, 29 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ff87805258e..9c0b54e87b47 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1387,6 +1387,28 @@ ipv6_pktoptions:
 	return 0;
 }
 
+static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
+			   const struct tcphdr *th)
+{
+	/* This is tricky: we move IP6CB at its correct location into
+	 * TCP_SKB_CB(). It must be done after xfrm6_policy_check(), because
+	 * _decode_session6() uses IP6CB().
+	 * barrier() makes sure compiler won't play aliasing games.
+	 */
+	memmove(&TCP_SKB_CB(skb)->header.h6, IP6CB(skb),
+		sizeof(struct inet6_skb_parm));
+	barrier();
+
+	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
+	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
+				    skb->len - th->doff*4);
+	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+	TCP_SKB_CB(skb)->tcp_flags = tcp_flag_byte(th);
+	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
+	TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
+	TCP_SKB_CB(skb)->sacked = 0;
+}
+
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
 	const struct tcphdr *th;
@@ -1418,24 +1440,9 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 
 	th = tcp_hdr(skb);
 	hdr = ipv6_hdr(skb);
-	/* This is tricky : We move IPCB at its correct location into TCP_SKB_CB()
-	 * barrier() makes sure compiler wont play fool^Waliasing games.
-	 */
-	memmove(&TCP_SKB_CB(skb)->header.h6, IP6CB(skb),
-		sizeof(struct inet6_skb_parm));
-	barrier();
-
-	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
-	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
-				    skb->len - th->doff*4);
-	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
-	TCP_SKB_CB(skb)->tcp_flags = tcp_flag_byte(th);
-	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
-	TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
-	TCP_SKB_CB(skb)->sacked = 0;
 
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest,
-				tcp_v6_iif(skb));
+				inet6_iif(skb));
 	if (!sk)
 		goto no_tcp_socket;
 
@@ -1451,6 +1458,8 @@ process:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
+	tcp_v6_fill_cb(skb, hdr, th);
+
 #ifdef CONFIG_TCP_MD5SIG
 	if (tcp_v6_inbound_md5_hash(sk, skb))
 		goto discard_and_relse;
@@ -1482,6 +1491,8 @@ no_tcp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
+	tcp_v6_fill_cb(skb, hdr, th);
+
 	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
 csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
@@ -1505,6 +1516,8 @@ do_time_wait:
 		goto discard_it;
 	}
 
+	tcp_v6_fill_cb(skb, hdr, th);
+
 	if (skb->len < (th->doff<<2)) {
 		inet_twsk_put(inet_twsk(sk));
 		goto bad_packet;
-- 
2.1.0
