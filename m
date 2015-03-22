From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/8] ipv4: tcp: handle ICMP messages on TCP_NEW_SYN_RECV request sockets
Date: Sun, 22 Mar 2015 10:22:22 -0700
Message-ID: <1427044945-32608-6-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:33811 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbbCVRXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:23:09 -0400
Received: by oiav63 with SMTP id v63so9357379oia.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:23:08 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_v4_err() can restrict lookups to ehash table, and not to listeners.

Note this patch creates the infrastructure, but this means that ICMP
messages for request sockets are ignored until complete conversion.

New tcp_req_err() helper is exported so that we can use it in IPv6
in following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   |  1 +
 net/ipv4/tcp_ipv4.c | 69 ++++++++++++++++++++++++++---------------------------
 2 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1876262afd59..fe60e00e1919 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -447,6 +447,7 @@ const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
 
 void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 void tcp_v4_mtu_reduced(struct sock *sk);
+void tcp_req_err(struct sock *sk, u32 seq);
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_create_openreq_child(struct sock *sk,
 				      struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8028ad5920a4..a57615062b66 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -310,6 +310,34 @@ static void do_redirect(struct sk_buff *skb, struct sock *sk)
 		dst->ops->redirect(dst, sk, skb);
 }
 
+
+/* handle ICMP messages on TCP_NEW_SYN_RECV request sockets */
+void tcp_req_err(struct sock *sk, u32 seq)
+{
+	struct request_sock *req = inet_reqsk(sk);
+	struct net *net = sock_net(sk);
+
+	/* ICMPs are not backlogged, hence we cannot get
+	 * an established socket here.
+	 */
+	WARN_ON(req->sk);
+
+	if (seq != tcp_rsk(req)->snt_isn) {
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+	} else {
+		/*
+		 * Still in SYN_RECV, just remove it silently.
+		 * There is no good way to pass the error to the newly
+		 * created socket, and POSIX does not want network
+		 * errors returned from accept().
+		 */
+		inet_csk_reqsk_queue_drop(req->rsk_listener, req);
+		NET_INC_STATS_BH(net, LINUX_MIB_LISTENDROPS);
+	}
+	reqsk_put(req);
+}
+EXPORT_SYMBOL(tcp_req_err);
+
 /*
  * This routine is called by the ICMP module when it gets some
  * sort of error condition.  If err < 0 then the socket should
@@ -343,8 +371,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	int err;
 	struct net *net = dev_net(icmp_skb->dev);
 
-	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
-			iph->saddr, th->source, inet_iif(icmp_skb));
+	sk = __inet_lookup_established(net, &tcp_hashinfo, iph->daddr,
+				       th->dest, iph->saddr, ntohs(th->source),
+				       inet_iif(icmp_skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
@@ -353,6 +382,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
+	seq = ntohl(th->seq);
+	if (sk->sk_state == TCP_NEW_SYN_RECV)
+		return tcp_req_err(sk, seq);
 
 	bh_lock_sock(sk);
 	/* If too many ICMPs get dropped on busy
@@ -374,7 +406,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 
 	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
-	seq = ntohl(th->seq);
 	/* XXX (TFO) - tp->snd_una should be ISN (tcp_create_openreq_child() */
 	fastopen = tp->fastopen_rsk;
 	snd_una = fastopen ? tcp_rsk(fastopen)->snt_isn : tp->snd_una;
@@ -458,38 +489,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	}
 
 	switch (sk->sk_state) {
-		struct request_sock *req;
-	case TCP_LISTEN:
-		if (sock_owned_by_user(sk))
-			goto out;
-
-		req = inet_csk_search_req(sk, th->dest,
-					  iph->daddr, iph->saddr);
-		if (!req)
-			goto out;
-
-		/* ICMPs are not backlogged, hence we cannot get
-		   an established socket here.
-		 */
-		WARN_ON(req->sk);
-
-		if (seq != tcp_rsk(req)->snt_isn) {
-			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-			reqsk_put(req);
-			goto out;
-		}
-
-		/*
-		 * Still in SYN_RECV, just remove it silently.
-		 * There is no good way to pass the error to the newly
-		 * created socket, and POSIX does not want network
-		 * errors returned from accept().
-		 */
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
