From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/15] tcp: Use cork flow in tcp_v4_connect()
Date: Sun, 08 May 2011 15:37:22 -0700 (PDT)
Message-ID: <20110508.153722.104037532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755543Ab1EHWhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:37:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2DA8724C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since this is invoked from inet_stream_connect() the socket is locked
and therefore this usage is safe.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f3d16d8..a712171 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -151,7 +151,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__be16 orig_sport, orig_dport;
 	__be32 daddr, nexthop;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	int err;
 	struct ip_options_rcu *inet_opt;
@@ -173,7 +173,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	rt = ip_route_connect(&fl4, nexthop, inet->inet_saddr,
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_TCP,
 			      orig_sport, orig_dport, sk, true);
@@ -190,10 +191,10 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (!inet_opt || !inet_opt->opt.srr)
-		daddr = fl4.daddr;
+		daddr = fl4->daddr;
 
 	if (!inet->inet_saddr)
-		inet->inet_saddr = fl4.saddr;
+		inet->inet_saddr = fl4->saddr;
 	inet->inet_rcv_saddr = inet->inet_saddr;
 
 	if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
@@ -204,7 +205,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
-	    !tp->rx_opt.ts_recent_stamp && fl4.daddr == daddr) {
+	    !tp->rx_opt.ts_recent_stamp && fl4->daddr == daddr) {
 		struct inet_peer *peer = rt_get_peer(rt);
 		/*
 		 * VJ's idea. We save last timestamp seen from
@@ -240,7 +241,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
-	rt = ip_route_newports(&fl4, rt, orig_sport, orig_dport,
+	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
-- 
1.7.5.1

