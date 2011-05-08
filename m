From: David Miller <davem@davemloft.net>
Subject: [PATCH] udp: Use flow key information instead of rt->rt_{src,dst}
Date: Sun, 08 May 2011 16:40:47 -0700 (PDT)
Message-ID: <20110508.164047.233687352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752333Ab1EHXlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 19:41:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A0A1B24C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 16:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have two cases.

Either the socket is in TCP_ESTABLISHED state and connect() filled
in the inet socket cork flow, or we looked up the route here and
used an on-stack flow.

Track which one it was, and use it to obtain src/dst addrs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

This is a prelude to passing a flow key down into the datagram
packet sending engine interfaces in ip_output.c

 net/ipv4/udp.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 544f435..ba9f137 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -791,6 +791,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct udp_sock *up = udp_sk(sk);
+	struct flowi4 fl4_stack;
 	struct flowi4 *fl4;
 	int ulen = len;
 	struct ipcm_cookie ipc;
@@ -919,17 +920,18 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (connected)
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
+	fl4 = &inet->cork.fl.u.ip4;
 	if (rt == NULL) {
-		struct flowi4 fl4;
 		struct net *net = sock_net(sk);
 
-		flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+		fl4 = &fl4_stack;
+		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   inet_sk_flowi_flags(sk)|FLOWI_FLAG_CAN_SLEEP,
 				   faddr, saddr, dport, inet->inet_sport);
 
-		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_flow(net, &fl4, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
+		rt = ip_route_output_flow(net, fl4, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			rt = NULL;
@@ -950,9 +952,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto do_confirm;
 back_from_confirm:
 
-	saddr = rt->rt_src;
+	saddr = fl4->saddr;
 	if (!ipc.addr)
-		daddr = ipc.addr = rt->rt_dst;
+		daddr = ipc.addr = fl4->daddr;
 
 	/* Lockless fast path for the non-corking case. */
 	if (!corkreq) {
-- 
1.7.5.1

