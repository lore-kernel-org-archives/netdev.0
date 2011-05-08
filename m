From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/15] ipv4: Use cork flow in
 inet_sk_{reselect_saddr,rebuild_header}()
Date: Sun, 08 May 2011 15:37:37 -0700 (PDT)
Message-ID: <20110508.153737.59660459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755724Ab1EHWiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9A1CA24C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These two functions must be invoked only when the socket is locked
(because socket identity modifications are made non-atomically).

Therefore we can use the cork flow for output route lookups.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/af_inet.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7b91fa8..851aa05 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1103,7 +1103,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	__be32 old_saddr = inet->inet_saddr;
 	__be32 daddr = inet->inet_daddr;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	__be32 new_saddr;
 	struct ip_options_rcu *inet_opt;
@@ -1114,7 +1114,8 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		daddr = inet_opt->opt.faddr;
 
 	/* Query new route. */
-	rt = ip_route_connect(&fl4, daddr, 0, RT_CONN_FLAGS(sk),
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_connect(fl4, daddr, 0, RT_CONN_FLAGS(sk),
 			      sk->sk_bound_dev_if, sk->sk_protocol,
 			      inet->inet_sport, inet->inet_dport, sk, false);
 	if (IS_ERR(rt))
@@ -1122,7 +1123,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 
 	sk_setup_caps(sk, &rt->dst);
 
-	new_saddr = fl4.saddr;
+	new_saddr = fl4->saddr;
 
 	if (new_saddr == old_saddr)
 		return 0;
@@ -1152,7 +1153,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	struct rtable *rt = (struct rtable *)__sk_dst_check(sk, 0);
 	__be32 daddr;
 	struct ip_options_rcu *inet_opt;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	int err;
 
 	/* Route is OK, nothing to do. */
@@ -1166,7 +1167,8 @@ int inet_sk_rebuild_header(struct sock *sk)
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
 	rcu_read_unlock();
-	rt = ip_route_output_ports(sock_net(sk), &fl4, sk, daddr, inet->inet_saddr,
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr, inet->inet_saddr,
 				   inet->inet_dport, inet->inet_sport,
 				   sk->sk_protocol, RT_CONN_FLAGS(sk),
 				   sk->sk_bound_dev_if);
-- 
1.7.5.1

