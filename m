From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7] tcp: Add timewait recycling bits to ipv6 connect code.
Date: Thu, 02 Dec 2010 12:42:24 -0800 (PST)
Message-ID: <20101202.124224.59675585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757968Ab0LBUl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6979224C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will also improve handling of ipv6 tcp socket request
backlog when syncookies are not enabled.  When backlog
becomes very deep, last quarter of backlog is limited to
validated destinations.  Previously only ipv4 implemented
this logic, but now ipv6 does too.

Now we are only one step away from enabling timewait
recycling for ipv6, and that step is simply filling in
the implementation of tcp_v6_get_peer() and
tcp_v6_tw_get_peer().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/request_sock.c |    1 +
 net/ipv6/tcp_ipv6.c     |  101 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 77 insertions(+), 25 deletions(-)

diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 7552495..41d9943 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -33,6 +33,7 @@
  * Note : Dont forget somaxconn that may limit backlog too.
  */
 int sysctl_max_syn_backlog = 256;
+EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
 int reqsk_queue_alloc(struct request_sock_queue *queue,
 		      unsigned int nr_table_entries)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5f73a18..c2ebbe1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -130,6 +130,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p, final;
+	struct rt6_info *rt;
 	struct flowi fl;
 	struct dst_entry *dst;
 	int addr_type;
@@ -280,6 +281,26 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	sk->sk_gso_type = SKB_GSO_TCPV6;
 	__ip6_dst_store(sk, dst, NULL, NULL);
 
+	rt = (struct rt6_info *) dst;
+	if (tcp_death_row.sysctl_tw_recycle &&
+	    !tp->rx_opt.ts_recent_stamp &&
+	    ipv6_addr_equal(&rt->rt6i_dst.addr, &np->daddr)) {
+		struct inet_peer *peer = rt6_get_peer(rt);
+		/*
+		 * VJ's idea. We save last timestamp seen from
+		 * the destination in peer table, when entering state
+		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
+		 * when trying new connection.
+		 */
+		if (peer) {
+			inet_peer_refcheck(peer);
+			if ((u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
+				tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
+				tp->rx_opt.ts_recent = peer->tcp_ts;
+			}
+		}
+	}
+
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
 		icsk->icsk_ext_hdr_len = (np->opt->opt_flen +
@@ -1170,6 +1191,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
+	struct dst_entry *dst = NULL;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1267,6 +1289,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
 	if (!isn) {
+		struct inet_peer *peer = NULL;
+
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
@@ -1279,13 +1303,57 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (!sk->sk_bound_dev_if &&
 		    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
 			treq->iif = inet6_iif(skb);
-		if (!want_cookie) {
-			isn = tcp_v6_init_sequence(skb);
-		} else {
+
+		if (want_cookie) {
 			isn = cookie_v6_init_sequence(sk, skb, &req->mss);
 			req->cookie_ts = tmp_opt.tstamp_ok;
+			goto have_isn;
+		}
+
+		/* VJ's idea. We save last timestamp seen
+		 * from the destination in peer table, when entering
+		 * state TIME-WAIT, and check against it before
+		 * accepting new connection request.
+		 *
+		 * If "isn" is not zero, this request hit alive
+		 * timewait bucket, so that all the necessary checks
+		 * are made in the function processing timewait state.
+		 */
+		if (tmp_opt.saw_tstamp &&
+		    tcp_death_row.sysctl_tw_recycle &&
+		    (dst = inet6_csk_route_req(sk, req)) != NULL &&
+		    (peer = rt6_get_peer((struct rt6_info *)dst)) != NULL &&
+		    ipv6_addr_equal((struct in6_addr *)peer->daddr.a6,
+				    &treq->rmt_addr)) {
+			inet_peer_refcheck(peer);
+			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
+			    (s32)(peer->tcp_ts - req->ts_recent) >
+							TCP_PAWS_WINDOW) {
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
+				goto drop_and_release;
+			}
+		}
+		/* Kill the following clause, if you dislike this way. */
+		else if (!sysctl_tcp_syncookies &&
+			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
+			  (sysctl_max_syn_backlog >> 2)) &&
+			 (!peer || !peer->tcp_ts_stamp) &&
+			 (!dst || !dst_metric(dst, RTAX_RTT))) {
+			/* Without syncookies last quarter of
+			 * backlog is filled with destinations,
+			 * proven to be alive.
+			 * It means that we continue to communicate
+			 * to destinations, already remembered
+			 * to the moment of synflood.
+			 */
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open request from %pI6/%u\n",
+				       &treq->rmt_addr, ntohs(tcp_hdr(skb)->source));
+			goto drop_and_release;
 		}
+
+		isn = tcp_v6_init_sequence(skb);
 	}
+have_isn:
 	tcp_rsk(req)->snt_isn = isn;
 
 	security_inet_conn_request(sk, skb, req);
@@ -1298,6 +1366,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
 
+drop_and_release:
+	dst_release(dst);
 drop_and_free:
 	reqsk_free(req);
 drop:
@@ -1376,28 +1446,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
 
-	if (dst == NULL) {
-		struct in6_addr *final_p, final;
-		struct flowi fl;
-
-		memset(&fl, 0, sizeof(fl));
-		fl.proto = IPPROTO_TCP;
-		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
-		final_p = fl6_update_dst(&fl, opt, &final);
-		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
-		fl.oif = sk->sk_bound_dev_if;
-		fl.mark = sk->sk_mark;
-		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_rsk(req)->loc_port;
-		security_req_classify_flow(req, &fl);
-
-		if (ip6_dst_lookup(sk, &dst, &fl))
-			goto out;
-
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-		if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
+	if (!dst) {
+		dst = inet6_csk_route_req(sk, req);
+		if (!dst)
 			goto out;
 	}
 
-- 
1.7.3.2

