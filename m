From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix req->saved_syn race
Date: Thu, 05 Nov 2015 11:07:13 -0800
Message-ID: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36644 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbKETHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:07:15 -0500
Received: by pacdm15 with SMTP id dm15so71159062pac.3
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 11:07:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
ireq->pktopts race"), we need to make sure we do not access
req->saved_syn unless we own the request sock.

This fixes races for listeners using TCP_SAVE_SYN option.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Ying Cai <ycai@google.com>
---
 include/linux/tcp.h      |    7 +++++++
 net/ipv4/tcp_ipv4.c      |    2 ++
 net/ipv4/tcp_minisocks.c |    3 ---
 net/ipv6/tcp_ipv6.c      |   20 ++++++++++++--------
 4 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c906f4534581..b386361ba3e8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -397,6 +397,13 @@ static inline void fastopen_queue_tune(struct sock *sk, int backlog)
 	queue->fastopenq.max_qlen = min_t(unsigned int, backlog, somaxconn);
 }
 
+static inline void tcp_move_syn(struct tcp_sock *tp,
+				struct request_sock *req)
+{
+	tp->saved_syn = req->saved_syn;
+	req->saved_syn = NULL;
+}
+
 static inline void tcp_saved_syn_free(struct tcp_sock *tp)
 {
 	kfree(tp->saved_syn);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1c2648bbac4b..59aff63b1776 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1326,6 +1326,8 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
+	if (*own_req)
+		tcp_move_syn(newtp, req_unhash);
 
 	return newsk;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3575dd1e5b67..ac6b1961ffeb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -551,9 +551,6 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		newtp->rack.mstamp.v64 = 0;
 		newtp->rack.advanced = 0;
 
-		newtp->saved_syn = req->saved_syn;
-		req->saved_syn = NULL;
-
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ea2f4d5440b5..c509e5562429 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1140,14 +1140,18 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		goto out;
 	}
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
-	/* Clone pktoptions received with SYN, if we own the req */
-	if (*own_req && ireq->pktopts) {
-		newnp->pktoptions = skb_clone(ireq->pktopts,
-					      sk_gfp_atomic(sk, GFP_ATOMIC));
-		consume_skb(ireq->pktopts);
-		ireq->pktopts = NULL;
-		if (newnp->pktoptions)
-			skb_set_owner_r(newnp->pktoptions, newsk);
+	if (*own_req) {
+		tcp_move_syn(newtp, req_unhash);
+
+		/* Clone pktoptions received with SYN, if we own the req */
+		if (ireq->pktopts) {
+			newnp->pktoptions = skb_clone(ireq->pktopts,
+						      sk_gfp_atomic(sk, GFP_ATOMIC));
+			consume_skb(ireq->pktopts);
+			ireq->pktopts = NULL;
+			if (newnp->pktoptions)
+				skb_set_owner_r(newnp->pktoptions, newsk);
+		}
 	}
 
 	return newsk;
