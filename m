From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/15] dccp: Use cork flow in dccp_v4_connect()
Date: Sun, 08 May 2011 15:37:20 -0700 (PDT)
Message-ID: <20110508.153720.71093376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42629
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755390Ab1EHWhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:37:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 113C724C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since this is invoked from inet_stream_connect() the socket is locked
and therefore this usage is safe.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 36700a4..4ac1a72 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -45,7 +45,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct dccp_sock *dp = dccp_sk(sk);
 	__be16 orig_sport, orig_dport;
 	__be32 daddr, nexthop;
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	int err;
 	struct ip_options_rcu *inet_opt;
@@ -70,7 +70,8 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	rt = ip_route_connect(&fl4, nexthop, inet->inet_saddr,
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_connect(fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_DCCP,
 			      orig_sport, orig_dport, sk, true);
@@ -83,10 +84,10 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (inet_opt == NULL || !inet_opt->opt.srr)
-		daddr = fl4.daddr;
+		daddr = fl4->daddr;
 
 	if (inet->inet_saddr == 0)
-		inet->inet_saddr = fl4.saddr;
+		inet->inet_saddr = fl4->saddr;
 	inet->inet_rcv_saddr = inet->inet_saddr;
 
 	inet->inet_dport = usin->sin_port;
@@ -106,7 +107,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err != 0)
 		goto failure;
 
-	rt = ip_route_newports(&fl4, rt, orig_sport, orig_dport,
+	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
 		rt = NULL;
-- 
1.7.5.1

