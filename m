From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: fix TCP early demux
Date: Fri, 27 Jul 2012 18:23:40 +0200
Message-ID: <1343406220.2626.13092.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61288 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2G0QXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:23:45 -0400
Received: by bkwj10 with SMTP id j10so2006999bkw.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:23:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 92101b3b2e317 (ipv4: Prepare for change of rt->rt_iif encoding.)
invalidated TCP early demux, because rx_dst_ifindex is not properly
initialized and checked.

Also remove the use of inet_iif(skb) in favor or skb->skb_iif

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c     |    1 +
 net/ipv4/tcp_ipv4.c      |   14 ++++++--------
 net/ipv4/tcp_minisocks.c |    1 +
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3e07a64..aa659e8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5603,6 +5603,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 
 	if (skb != NULL) {
 		sk->sk_rx_dst = dst_clone(skb_dst(skb));
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 		security_inet_conn_established(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b6b07c9..2fbd992 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1620,17 +1620,15 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		sock_rps_save_rxhash(sk, skb);
 		if (sk->sk_rx_dst) {
 			struct dst_entry *dst = sk->sk_rx_dst;
-			if (dst->ops->check(dst, 0) == NULL) {
+			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
+			    dst->ops->check(dst, 0) == NULL) {
 				dst_release(dst);
 				sk->sk_rx_dst = NULL;
 			}
 		}
 		if (unlikely(sk->sk_rx_dst == NULL)) {
-			struct inet_sock *icsk = inet_sk(sk);
-			struct rtable *rt = skb_rtable(skb);
-
-			sk->sk_rx_dst = dst_clone(&rt->dst);
-			icsk->rx_dst_ifindex = inet_iif(skb);
+			sk->sk_rx_dst = dst_clone(skb_dst(skb));
+			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 		}
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
@@ -1709,11 +1707,11 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 		skb->destructor = sock_edemux;
 		if (sk->sk_state != TCP_TIME_WAIT) {
 			struct dst_entry *dst = sk->sk_rx_dst;
-			struct inet_sock *icsk = inet_sk(sk);
+
 			if (dst)
 				dst = dst_check(dst, 0);
 			if (dst &&
-			    icsk->rx_dst_ifindex == skb->skb_iif)
+			    inet_sk(sk)->rx_dst_ifindex == skb->skb_iif)
 				skb_dst_set_noref(skb, dst);
 		}
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 5912ac3..3f1cc20 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -388,6 +388,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
 		newsk->sk_rx_dst = dst_clone(skb_dst(skb));
+		inet_sk(newsk)->rx_dst_ifindex = skb->skb_iif;
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
