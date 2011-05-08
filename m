From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/15] l2tp: Use cork flow in l2tp_ip_connect() and
 l2tp_ip_sendmsg()
Date: Sun, 08 May 2011 15:37:29 -0700 (PDT)
Message-ID: <20110508.153729.183028292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755708Ab1EHWiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B025A24C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that the socket is consistently locked in these two routines,
this transformation is legal.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_ip.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index bd0cc0b..1ca7489 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -298,7 +298,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 {
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
 	struct inet_sock *inet = inet_sk(sk);
-	struct flowi4 fl4;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	__be32 saddr;
 	int oif, rc;
@@ -322,7 +322,8 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
 		goto out;
 
-	rt = ip_route_connect(&fl4, lsa->l2tp_addr.s_addr, saddr,
+	fl4 = &inet->cork.fl.u.ip4;
+	rt = ip_route_connect(fl4, lsa->l2tp_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      IPPROTO_L2TP,
 			      0, 0, sk, true);
@@ -342,10 +343,10 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	l2tp_ip_sk(sk)->peer_conn_id = lsa->l2tp_conn_id;
 
 	if (!inet->inet_saddr)
-		inet->inet_saddr = fl4.saddr;
+		inet->inet_saddr = fl4->saddr;
 	if (!inet->inet_rcv_saddr)
-		inet->inet_rcv_saddr = fl4.saddr;
-	inet->inet_daddr = fl4.daddr;
+		inet->inet_rcv_saddr = fl4->saddr;
+	inet->inet_daddr = fl4->daddr;
 	sk->sk_state = TCP_ESTABLISHED;
 	inet->inet_id = jiffies;
 
@@ -420,6 +421,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	struct l2tp_ip_sock *lsa = l2tp_ip_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct rtable *rt = NULL;
+	struct flowi4 *fl4;
 	int connected = 0;
 	__be32 daddr;
 
@@ -474,12 +476,12 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		goto error;
 	}
 
+	fl4 = &inet->cork.fl.u.ip4;
 	if (connected)
 		rt = (struct rtable *) __sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
 		struct ip_options_rcu *inet_opt;
-		struct flowi4 fl4;
 
 		rcu_read_lock();
 		inet_opt = rcu_dereference(inet->inet_opt);
@@ -494,7 +496,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), &fl4, sk,
+		rt = ip_route_output_ports(sock_net(sk), fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport, inet->inet_sport,
 					   sk->sk_protocol, RT_CONN_FLAGS(sk),
-- 
1.7.5.1

