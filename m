From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: dont handle MTU reduction on LISTEN socket
Date: Mon, 18 Mar 2013 10:01:28 -0700
Message-ID: <1363626088.29475.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, dormando <dormando@rydia.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:60067 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3CRRBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:01:31 -0400
Received: by mail-pb0-f49.google.com with SMTP id xa12so6525677pbc.22
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 10:01:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When an ICMP ICMP_FRAG_NEEDED (or ICMPV6_PKT_TOOBIG) message finds a
LISTEN socket, and this socket is currently owned by the user, we
set TCP_MTU_REDUCED_DEFERRED flag in listener tsq_flags.

This is bad because if we clone the parent before it had a chance to
clear the flag, the child inherits the tsq_flags value, and next
tcp_release_cb() on the child will decrement sk_refcnt.

Result is that we might free a live TCP socket, as reported by
Dormando.

IPv4: Attempt to release TCP socket in state 1

Fix this issue by testing sk_state against TCP_LISTEN early, so that we
set TCP_MTU_REDUCED_DEFERRED on appropriate sockets (not a LISTEN one)

This bug was introduced in commit 563d34d05786
(tcp: dont drop MTU reduction indications)

Reported-by: dormando <dormando@rydia.net>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |   14 +++++++-------
 net/ipv6/tcp_ipv6.c |    7 +++++++
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4a8ec45..d09203c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -274,13 +274,6 @@ static void tcp_v4_mtu_reduced(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	u32 mtu = tcp_sk(sk)->mtu_info;
 
-	/* We are not interested in TCP_LISTEN and open_requests (SYN-ACKs
-	 * send out by Linux are always <576bytes so they should go through
-	 * unfragmented).
-	 */
-	if (sk->sk_state == TCP_LISTEN)
-		return;
-
 	dst = inet_csk_update_pmtu(sk, mtu);
 	if (!dst)
 		return;
@@ -408,6 +401,13 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 			goto out;
 
 		if (code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
+			/* We are not interested in TCP_LISTEN and open_requests
+			 * (SYN-ACKs send out by Linux are always <576bytes so
+			 * they should go through unfragmented).
+			 */
+			if (sk->sk_state == TCP_LISTEN)
+				goto out;
+
 			tp->mtu_info = info;
 			if (!sock_owned_by_user(sk)) {
 				tcp_v4_mtu_reduced(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9b64600..f6d629f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -389,6 +389,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
+		/* We are not interested in TCP_LISTEN and open_requests
+		 * (SYN-ACKs send out by Linux are always <576bytes so
+		 * they should go through unfragmented).
+		 */
+		if (sk->sk_state == TCP_LISTEN)
+			goto out;
+
 		tp->mtu_info = ntohl(info);
 		if (!sock_owned_by_user(sk))
 			tcp_v6_mtu_reduced(sk);
