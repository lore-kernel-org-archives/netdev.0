From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rps: tcp: fix rps_sock_flow_table table updates
Date: Thu, 03 Jun 2010 21:03:58 +0200
Message-ID: <1275591838.2533.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45309 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab0FCTEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 15:04:05 -0400
Received: by wwb28 with SMTP id 28so335064wwb.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 12:04:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe a moderate SYN flood attack can corrupt RFS flow table
(rps_sock_flow_table), making RPS/RFS much less effective.

Even in a normal situation, server handling short lived sessions suffer
from bad steering for the first data packet of a session, if another SYN
packet is received for another session.

We do following action in tcp_v4_rcv() :

	sock_rps_save_rxhash(sk, skb->rxhash);

We should _not_ do this if sk is a LISTEN socket, as about each
packet received on a LISTEN socket has a different rxhash than
previous one.
 -> RPS_NO_CPU markers are spread all over rps_sock_flow_table.

Also, it makes sense to protect sk->rxhash field changes with socket
lock (We currently can change it even if user thread owns the lock
and might use rxhash)

This patch moves sock_rps_save_rxhash() to a sock locked section,
and only for non LISTEN sockets.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 202cf09..fe193e5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1555,6 +1555,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
+		sock_rps_save_rxhash(sk, skb->rxhash);
 		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
@@ -1579,7 +1580,9 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 			}
 			return 0;
 		}
-	}
+	} else
+		sock_rps_save_rxhash(sk, skb->rxhash);
+
 
 	TCP_CHECK_TIMER(sk);
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
@@ -1672,8 +1675,6 @@ process:
 
 	skb->dev = NULL;
 
-	sock_rps_save_rxhash(sk, skb->rxhash);
-
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {


