From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net v2] net: tcp: move sk_rx_dst_set call after tcp_create_openreq_child()
Date: Sun, 19 Aug 2012 09:30:38 -0400
Message-ID: <1345383038-8330-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:40318 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab2HSNam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 09:30:42 -0400
Received: by obbwc20 with SMTP id wc20so3482253obb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 06:30:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit removes the sk_rx_dst_set calls from
tcp_create_openreq_child(), because at that point the icsk_af_ops
field of ipv6_mapped TCP sockets has not been set to its proper final
value.

Instead, to make sure we get the right sk_rx_dst_set variant
appropriate for the address family of the new connection, we have
tcp_v{4,6}_syn_recv_sock() directly call the appropriate function
shortly after the call to tcp_create_openreq_child() returns.

This also moves inet6_sk_rx_dst_set() to avoid a forward declaration
with the new approach.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Reported-by: Artem Savkov <artem.savkov@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c      |    1 +
 net/ipv4/tcp_minisocks.c |    2 --
 net/ipv6/tcp_ipv6.c      |   25 +++++++++++++------------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7678237..5bf2040 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1462,6 +1462,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		goto exit_nonewsk;
 
 	newsk->sk_gso_type = SKB_GSO_TCPV4;
+	inet_sk_rx_dst_set(newsk, skb);
 
 	newtp		      = tcp_sk(newsk);
 	newinet		      = inet_sk(newsk);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d9c9dce..6ff7f10 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,8 +387,6 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
-		newicsk->icsk_af_ops->sk_rx_dst_set(newsk, skb);
-
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
 		 * copy any s_data_payload stored at the original socket.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bb9ce2b..a3e60cc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -94,6 +94,18 @@ static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 }
 #endif
 
+static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	const struct rt6_info *rt = (const struct rt6_info *)dst;
+
+	dst_hold(dst);
+	sk->sk_rx_dst = dst;
+	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	if (rt->rt6i_node)
+		inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
+}
+
 static void tcp_v6_hash(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
@@ -1270,6 +1282,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newsk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(newsk, dst, NULL, NULL);
+	inet6_sk_rx_dst_set(newsk, skb);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
@@ -1729,18 +1742,6 @@ static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_destructor= tcp_twsk_destructor,
 };
 
-static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-	const struct rt6_info *rt = (const struct rt6_info *)dst;
-
-	dst_hold(dst);
-	sk->sk_rx_dst = dst;
-	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-	if (rt->rt6i_node)
-		inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
-}
-
 static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = tcp_v6_send_check,
-- 
1.7.7.3
