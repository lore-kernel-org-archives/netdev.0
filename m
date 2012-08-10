From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: fix ip_send_skb()
Date: Fri, 10 Aug 2012 14:22:47 +0200
Message-ID: <1344601367.31104.2672.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60227 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842Ab2HJMWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 08:22:52 -0400
Received: by weyx8 with SMTP id x8so952817wey.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 05:22:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip_send_skb() can send orphaned skb, so we must pass the net pointer to
avoid possible NULL dereference in error path.

Bug added by commit 3a7c384ffd57 (ipv4: tcp: unicast_sock should not
land outside of TCP stack)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h     |    2 +-
 net/ipv4/ip_output.c |    5 ++---
 net/ipv4/udp.c       |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bd5e444..5a5d84d 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -120,7 +120,7 @@ extern struct sk_buff  *__ip_make_skb(struct sock *sk,
 				      struct flowi4 *fl4,
 				      struct sk_buff_head *queue,
 				      struct inet_cork *cork);
-extern int		ip_send_skb(struct sk_buff *skb);
+extern int		ip_send_skb(struct net *net, struct sk_buff *skb);
 extern int		ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4);
 extern void		ip_flush_pending_frames(struct sock *sk);
 extern struct sk_buff  *ip_make_skb(struct sock *sk,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ec410e0..147ccc3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1366,9 +1366,8 @@ out:
 	return skb;
 }
 
-int ip_send_skb(struct sk_buff *skb)
+int ip_send_skb(struct net *net, struct sk_buff *skb)
 {
-	struct net *net = sock_net(skb->sk);
 	int err;
 
 	err = ip_local_out(skb);
@@ -1391,7 +1390,7 @@ int ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4)
 		return 0;
 
 	/* Netfilter gets whole the not fragmented skb. */
-	return ip_send_skb(skb);
+	return ip_send_skb(sock_net(sk), skb);
 }
 
 /*
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b4c3582..6f6d1ac 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -758,7 +758,7 @@ static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 		uh->check = CSUM_MANGLED_0;
 
 send:
-	err = ip_send_skb(skb);
+	err = ip_send_skb(sock_net(sk), skb);
 	if (err) {
 		if (err == -ENOBUFS && !inet->recverr) {
 			UDP_INC_STATS_USER(sock_net(sk),
