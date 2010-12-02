From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7] tcp: Implement ipv6 ->get_peer() and ->tw_get_peer().
Date: Thu, 02 Dec 2010 12:42:29 -0800 (PST)
Message-ID: <20101202.124229.115929131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757968Ab0LBUmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:42:02 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7F6EC24C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now ipv6 timewait recycling is fully implemented and
enabled.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/tcp_ipv6.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c2ebbe1..3194585 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1865,19 +1865,33 @@ do_time_wait:
 
 static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 {
-	/* Alas, not yet... */
-	return NULL;
+	struct rt6_info *rt = (struct rt6_info *) __sk_dst_get(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct inet_peer *peer;
+
+	if (!rt ||
+	    !ipv6_addr_equal(&np->daddr, &rt->rt6i_dst.addr)) {
+		peer = inet_getpeer_v6(&np->daddr, 1);
+		*release_it = true;
+	} else {
+		if (!rt->rt6i_peer)
+			rt6_bind_peer(rt, 1);
+		peer = rt->rt6i_peer;
+		*release_it = true;
+	}
+
+	return peer;
 }
 
 static void *tcp_v6_tw_get_peer(struct sock *sk)
 {
+	struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 
 	if (tw->tw_family == AF_INET)
 		return tcp_v4_tw_get_peer(sk);
 
-	/* Alas, not yet... */
-	return NULL;
+	return inet_getpeer_v6(&tw6->tw_v6_daddr, 1);
 }
 
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
-- 
1.7.3.2

