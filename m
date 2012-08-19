From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] net: tcp: move sk_rx_dst_set call after tcp_create_openreq_child()
Date: Sat, 18 Aug 2012 23:56:59 -0400
Message-ID: <1345348619-19327-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:57743 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab2HSD5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 23:57:09 -0400
Received: by wibhr14 with SMTP id hr14so144447wib.1
        for <netdev@vger.kernel.org>; Sat, 18 Aug 2012 20:57:07 -0700 (PDT)
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

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Reported-by: Artem Savkov <artem.savkov@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c      |    1 +
 net/ipv4/tcp_minisocks.c |    2 --
 net/ipv6/tcp_ipv6.c      |    3 +++
 3 files changed, 4 insertions(+), 2 deletions(-)

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
index bb9ce2b..492c2d9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -81,6 +81,8 @@ static void	__tcp_v6_send_check(struct sk_buff *skb,
 				    const struct in6_addr *saddr,
 				    const struct in6_addr *daddr);
 
+static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
+
 static const struct inet_connection_sock_af_ops ipv6_mapped;
 static const struct inet_connection_sock_af_ops ipv6_specific;
 #ifdef CONFIG_TCP_MD5SIG
@@ -1270,6 +1272,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newsk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(newsk, dst, NULL, NULL);
+	inet6_sk_rx_dst_set(newsk, skb);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
-- 
1.7.7.3
