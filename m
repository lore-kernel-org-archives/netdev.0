From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/8] ipv6: tcp: handle ICMP messages on TCP_NEW_SYN_RECV request sockets
Date: Sun, 22 Mar 2015 10:22:23 -0700
Message-ID: <1427044945-32608-7-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33091 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbbCVRXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:23:16 -0400
Received: by yhoc41 with SMTP id c41so6107993yho.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:23:16 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_v6_err() can restrict lookups to ehash table, and not to listeners.

Note this patch creates the infrastructure, but this means that ICMP
messages for request sockets are ignored until complete conversion.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c | 47 ++++++++++++-----------------------------------
 1 file changed, 12 insertions(+), 35 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6e3f90db038c..4a4e6d30c448 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -324,18 +324,20 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct tcphdr *th = (struct tcphdr *)(skb->data+offset);
+	struct net *net = dev_net(skb->dev);
+	struct request_sock *fastopen;
 	struct ipv6_pinfo *np;
-	struct sock *sk;
-	int err;
 	struct tcp_sock *tp;
-	struct request_sock *fastopen;
 	__u32 seq, snd_una;
-	struct net *net = dev_net(skb->dev);
+	struct sock *sk;
+	int err;
 
-	sk = inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
-			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
+	sk = __inet6_lookup_established(net, &tcp_hashinfo,
+					&hdr->daddr, th->dest,
+					&hdr->saddr, ntohs(th->source),
+					skb->dev->ifindex);
 
-	if (sk == NULL) {
+	if (!sk) {
 		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
 				   ICMP6_MIB_INERRORS);
 		return;
@@ -345,6 +347,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
+	seq = ntohl(th->seq);
+	if (sk->sk_state == TCP_NEW_SYN_RECV)
+		return tcp_req_err(sk, seq);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk) && type != ICMPV6_PKT_TOOBIG)
@@ -359,7 +364,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	}
 
 	tp = tcp_sk(sk);
-	seq = ntohl(th->seq);
 	/* XXX (TFO) - tp->snd_una should be ISN (tcp_create_openreq_child() */
 	fastopen = tp->fastopen_rsk;
 	snd_una = fastopen ? tcp_rsk(fastopen)->snt_isn : tp->snd_una;
@@ -403,33 +407,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
-		struct request_sock *req;
-	case TCP_LISTEN:
-		if (sock_owned_by_user(sk))
-			goto out;
-
-		/* Note : We use inet6_iif() here, not tcp_v6_iif() */
-		req = inet6_csk_search_req(sk, th->dest, &hdr->daddr,
-					   &hdr->saddr, inet6_iif(skb));
-		if (!req)
-			goto out;
-
-		/* ICMPs are not backlogged, hence we cannot get
-		 * an established socket here.
-		 */
-		WARN_ON(req->sk != NULL);
-
-		if (seq != tcp_rsk(req)->snt_isn) {
-			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-			reqsk_put(req);
-			goto out;
-		}
-
-		inet_csk_reqsk_queue_drop(sk, req);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-		reqsk_put(req);
-		goto out;
-
 	case TCP_SYN_SENT:
 	case TCP_SYN_RECV:
 		/* Only in fast or simultaneous open. If a fast open socket is
-- 
2.2.0.rc0.207.ga3a616c
