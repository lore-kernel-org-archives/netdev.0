From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/15] ipv4: Use cork flow in ip_queue_xmit()
Date: Sun, 08 May 2011 15:37:39 -0700 (PDT)
Message-ID: <20110508.153739.115914680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42650
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755754Ab1EHWiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E9C1F24C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All invokers of ip_queue_xmit() must make certain that the
socket is locked.  All of SCTP, TCP, DCCP, and L2TP now make
sure this is the case.

Therefore we can use the cork flow during output route lookup in
ip_queue_xmit() when the socket route check fails.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0a2f49a..4ba26d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -317,6 +317,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_rcu *inet_opt;
+	struct flowi4 *fl4;
 	struct rtable *rt;
 	struct iphdr *iph;
 	int res;
@@ -331,9 +332,9 @@ int ip_queue_xmit(struct sk_buff *skb)
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
+	fl4 = &inet->cork.fl.u.ip4;
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
-		struct flowi4 fl4;
 		__be32 daddr;
 
 		/* Use correct destination address if we have options. */
@@ -345,7 +346,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), &fl4, sk,
+		rt = ip_route_output_ports(sock_net(sk), fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport,
 					   inet->inet_sport,
-- 
1.7.5.1

