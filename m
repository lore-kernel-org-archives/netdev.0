From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: fix behavior of stale SYN_RECV request
 sockets
Date: Tue, 13 Oct 2015 17:12:54 -0700
Message-ID: <1444781574.4166.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35705 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbJNAM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 20:12:58 -0400
Received: by padcn9 with SMTP id cn9so4602527pad.2
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 17:12:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When a TCP/DCCP listener is closed, its pending SYN_RECV request sockets
become stale, meaning 3WHS can not complete.

But current behavior is wrong :
incoming packets finding such stale sockets are dropped.

We need instead to cleanup the request socket and perform another
lookup :
- Incoming ACK will give a RST answer,
- SYN rtx might find another listener if available.
- We expedite cleanup of request sockets and old listener socket.

Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv4.c     |   15 +++++++--------
 net/dccp/ipv6.c     |   15 +++++++--------
 net/ipv4/tcp_ipv4.c |    7 ++++++-
 net/ipv6/tcp_ipv6.c |    7 ++++++-
 4 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8e99681c8189d82e3e5f6a3c6089b103c0df2ca3..0dcf1963b323db7c7501dd58292795ee62fc0736 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -799,15 +799,10 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 				  DCCP_SKB_CB(skb)->dccpd_ack_seq);
 	}
 
-	/* Step 2:
-	 *	Look up flow ID in table and get corresponding socket */
+lookup:
 	sk = __inet_lookup_skb(&dccp_hashinfo, skb,
 			       dh->dccph_sport, dh->dccph_dport);
-	/*
-	 * Step 2:
-	 *	If no socket ...
-	 */
-	if (sk == NULL) {
+	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
 		goto no_dccp_socket;
@@ -830,8 +825,12 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 		struct sock *nsk = NULL;
 
 		sk = req->rsk_listener;
-		if (sk->sk_state == DCCP_LISTEN)
+		if (likely(sk->sk_state == DCCP_LISTEN)) {
 			nsk = dccp_check_req(sk, skb, req);
+		} else {
+			inet_csk_reqsk_queue_drop(sk, req);
+			goto lookup;
+		}
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_it;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index aed314f8c7c60b00191aabc42c733f02304b18b0..68831931b1fe63a46031fe3324f8a0546f330236 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -656,16 +656,11 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 	else
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
 
-	/* Step 2:
-	 *	Look up flow ID in table and get corresponding socket */
+lookup:
 	sk = __inet6_lookup_skb(&dccp_hashinfo, skb,
 			        dh->dccph_sport, dh->dccph_dport,
 				inet6_iif(skb));
-	/*
-	 * Step 2:
-	 *	If no socket ...
-	 */
-	if (sk == NULL) {
+	if (!sk) {
 		dccp_pr_debug("failed to look up flow ID in table and "
 			      "get corresponding socket\n");
 		goto no_dccp_socket;
@@ -688,8 +683,12 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 		struct sock *nsk = NULL;
 
 		sk = req->rsk_listener;
-		if (sk->sk_state == DCCP_LISTEN)
+		if (likely(sk->sk_state == DCCP_LISTEN)) {
 			nsk = dccp_check_req(sk, skb, req);
+		} else {
+			inet_csk_reqsk_queue_drop(sk, req);
+			goto lookup;
+		}
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_it;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ddb198392c7fd9be24d62a5d87da051b86cc8c55..1ff0923df7153d37f153fb0fa100a88cdeef0509 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1572,6 +1572,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
+lookup:
 	sk = __inet_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest);
 	if (!sk)
 		goto no_tcp_socket;
@@ -1587,8 +1588,12 @@ process:
 		sk = req->rsk_listener;
 		if (tcp_v4_inbound_md5_hash(sk, skb))
 			goto discard_and_relse;
-		if (sk->sk_state == TCP_LISTEN)
+		if (likely(sk->sk_state == TCP_LISTEN)) {
 			nsk = tcp_check_req(sk, skb, req, false);
+		} else {
+			inet_csk_reqsk_queue_drop(sk, req);
+			goto lookup;
+		}
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_it;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2887c8474b650468a76919fe9d25aff43361e1ba..7ce1c57199d13ac4b5d20ab47a32471493322edd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1363,6 +1363,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	th = tcp_hdr(skb);
 	hdr = ipv6_hdr(skb);
 
+lookup:
 	sk = __inet6_lookup_skb(&tcp_hashinfo, skb, th->source, th->dest,
 				inet6_iif(skb));
 	if (!sk)
@@ -1382,8 +1383,12 @@ process:
 			reqsk_put(req);
 			goto discard_it;
 		}
-		if (sk->sk_state == TCP_LISTEN)
+		if (likely(sk->sk_state == TCP_LISTEN)) {
 			nsk = tcp_check_req(sk, skb, req, false);
+		} else {
+			inet_csk_reqsk_queue_drop(sk, req);
+			goto lookup;
+		}
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_it;
