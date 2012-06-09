From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] tcp: Get rid of inetpeer special cases.
Date: Sat, 09 Jun 2012 01:33:35 -0700 (PDT)
Message-ID: <20120609.013335.2201386709676237109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab2FIIdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 04:33:38 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3E834583E8D
	for <netdev@vger.kernel.org>; Sat,  9 Jun 2012 01:33:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The get_peer method TCP uses is full of special cases that make no
sense accommodating, and it also gets in the way of doing more
reasonable things here.

First of all, if the socket doesn't have a usable cached route, there
is no sense in trying to optimize timewait recycling.

Likewise for the case where we have IP options, such as SRR enabled,
that make the IP header destination address (and thus the destination
address of the route key) differ from that of the connection's
destination address.

Just return a NULL peer in these cases, and thus we're also able to
get rid of the clumsy inetpeer release logic.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    2 +-
 include/net/tcp.h                  |    2 +-
 net/ipv4/tcp_ipv4.c                |   21 ++++++++-------------
 net/ipv4/tcp_minisocks.c           |    5 +----
 net/ipv6/tcp_ipv6.c                |   21 ++++++++-------------
 5 files changed, 19 insertions(+), 32 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 7d83f90..e1b7734 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -43,7 +43,7 @@ struct inet_connection_sock_af_ops {
 	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
 				      struct dst_entry *dst);
-	struct inet_peer *(*get_peer)(struct sock *sk, bool *release_it);
+	struct inet_peer *(*get_peer)(struct sock *sk);
 	u16	    net_header_len;
 	u16	    net_frag_header_len;
 	u16	    sockaddr_len;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e79aa48..4245918 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -327,7 +327,7 @@ extern void tcp_shutdown (struct sock *sk, int how);
 
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
-extern struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it);
+extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
 extern void *tcp_v4_tw_get_peer(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 833e8d9..77f049d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1820,23 +1820,18 @@ do_time_wait:
 	goto discard_it;
 }
 
-struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
+struct inet_peer *tcp_v4_get_peer(struct sock *sk)
 {
 	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
-	struct inet_peer *peer;
-
-	if (!rt ||
-	    inet->cork.fl.u.ip4.daddr != inet->inet_daddr) {
-		peer = inet_getpeer_v4(net, inet->inet_daddr, 1);
-		*release_it = true;
-	} else {
-		peer = rt_get_peer_create(rt, inet->inet_daddr);
-		*release_it = false;
-	}
 
-	return peer;
+	/* If we don't have a valid cached route, or we're doing IP
+	 * options which make the IPv4 header destination address
+	 * different from our peer's, do not bother with this.
+	 */
+	if (!rt || inet->cork.fl.u.ip4.daddr != inet->inet_daddr)
+		return NULL;
+	return rt_get_peer_create(rt, inet->inet_daddr);
 }
 EXPORT_SYMBOL(tcp_v4_get_peer);
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b85d9fe..fef9dbf 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -60,9 +60,8 @@ static bool tcp_remember_stamp(struct sock *sk)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_peer *peer;
-	bool release_it;
 
-	peer = icsk->icsk_af_ops->get_peer(sk, &release_it);
+	peer = icsk->icsk_af_ops->get_peer(sk);
 	if (peer) {
 		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
 		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
@@ -70,8 +69,6 @@ static bool tcp_remember_stamp(struct sock *sk)
 			peer->tcp_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
 			peer->tcp_ts = tp->rx_opt.ts_recent;
 		}
-		if (release_it)
-			inet_putpeer(peer);
 		return true;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 218433c..b5ecf37 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1732,23 +1732,18 @@ do_time_wait:
 	goto discard_it;
 }
 
-static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
+static struct inet_peer *tcp_v6_get_peer(struct sock *sk)
 {
 	struct rt6_info *rt = (struct rt6_info *) __sk_dst_get(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct net *net = sock_net(sk);
-	struct inet_peer *peer;
-
-	if (!rt ||
-	    !ipv6_addr_equal(&np->daddr, &rt->rt6i_dst.addr)) {
-		peer = inet_getpeer_v6(net, &np->daddr, 1);
-		*release_it = true;
-	} else {
-		peer = rt6_get_peer_create(rt);
-		*release_it = false;
-	}
 
-	return peer;
+	/* If we don't have a valid cached route, or we're doing IP
+	 * options which make the IPv6 header destination address
+	 * different from our peer's, do not bother with this.
+	 */
+	if (!rt || !ipv6_addr_equal(&np->daddr, &rt->rt6i_dst.addr))
+		return NULL;
+	return rt6_get_peer_create(rt);
 }
 
 static void *tcp_v6_tw_get_peer(struct sock *sk)
-- 
1.7.10
