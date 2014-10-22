From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] net: fix saving TX flow hash in sock for outgoing connections
Date: Wed, 22 Oct 2014 21:42:01 +0530
Message-ID: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <therbert@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:27478 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbaJVQKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:10:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit "net: Save TX flow hash in sock and set in skbuf on xmit"
introduced the inet_set_txhash() and ip6_set_txhash() routines to calculate
and record flow hash(sk_txhash) in the socket structure. sk_txhash is used
to set skb->hash which is used to spread flows across multiple TXQs.

But, the above routines are invoked before the source port of the connection
is created. Because of this all outgoing connections that just differ in the
source port get hashed into the same TXQ.

This patch fixes this problem for IPv4/6 by invoking the the above routines
after the source port is available for the socket.

Fixes: b73c3d0e4("net: Save TX flow hash in sock and set in skbuf on xmit")

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 94d1a77..9c7d762 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -206,8 +206,6 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	inet->inet_dport = usin->sin_port;
 	inet->inet_daddr = daddr;
 
-	inet_set_txhash(sk);
-
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
 		inet_csk(sk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
@@ -224,6 +222,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
+	inet_set_txhash(sk);
+
 	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8314955..ace29b6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -200,8 +200,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk->sk_v6_daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
-	ip6_set_txhash(sk);
-
 	/*
 	 *	TCP over IPv4
 	 */
@@ -297,6 +295,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (err)
 		goto late_failure;
 
+	ip6_set_txhash(sk);
+
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     sk->sk_v6_daddr.s6_addr32,
-- 
1.7.1
