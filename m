From: David Miller <davem@davemloft.net>
Subject: [PATCH 06/16] tcp: Move timestamps from inetpeer to metrics cache.
Date: Tue, 10 Jul 2012 08:07:26 -0700 (PDT)
Message-ID: <20120710.080726.1369956163447074824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab2GJPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:26 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id AACE858663C
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h   |    4 +-
 include/net/tcp.h        |    5 +-
 net/ipv4/inetpeer.c      |    1 -
 net/ipv4/route.c         |    8 +--
 net/ipv4/tcp_ipv4.c      |   30 ++---------
 net/ipv4/tcp_metrics.c   |  132 ++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_minisocks.c |   46 ----------------
 net/ipv6/route.c         |   13 +----
 net/ipv6/tcp_ipv6.c      |   33 ++----------
 9 files changed, 145 insertions(+), 127 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index c27c8f1..1119f6f 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -46,15 +46,13 @@ struct inet_peer {
 	};
 	/*
 	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
-	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
+	 * are not available: rid, ip_id_count
 	 * We can share memory with rcu_head to help keep inet_peer small.
 	 */
 	union {
 		struct {
 			atomic_t			rid;		/* Frag reception counter */
 			atomic_t			ip_id_count;	/* IP ID for the next packet */
-			__u32				tcp_ts;
-			__u32				tcp_ts_stamp;
 		};
 		struct rcu_head         rcu;
 		struct inet_peer	*gc_next;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0900d63..3618fef 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -390,7 +390,10 @@ extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
 extern void tcp_init_metrics(struct sock *sk);
 extern void tcp_metrics_init(void);
-extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst);
+extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check);
+extern bool tcp_remember_stamp(struct sock *sk);
+extern bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
+extern void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
 extern void tcp_disable_fack(struct tcp_sock *tp);
 extern void tcp_close(struct sock *sk, long timeout);
 extern void tcp_init_sock(struct sock *sk);
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index da90a8c..f457bcb 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -508,7 +508,6 @@ relookup:
 				(daddr->family == AF_INET) ?
 					secure_ip_id(daddr->addr.a4) :
 					secure_ipv6_id(daddr->addr.a6));
-		p->tcp_ts_stamp = 0;
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		p->rate_last = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d02c911..78d8154 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2846,7 +2846,7 @@ static int rt_fill_info(struct net *net,
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
-	u32 id = 0, ts = 0, tsage = 0, error;
+	u32 id = 0, error;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
@@ -2903,10 +2903,6 @@ static int rt_fill_info(struct net *net,
 		const struct inet_peer *peer = rt_peer_ptr(rt);
 		inet_peer_refcheck(peer);
 		id = atomic_read(&peer->ip_id_count) & 0xffff;
-		if (peer->tcp_ts_stamp) {
-			ts = peer->tcp_ts;
-			tsage = get_seconds() - peer->tcp_ts_stamp;
-		}
 		expires = ACCESS_ONCE(peer->pmtu_expires);
 		if (expires) {
 			if (time_before(jiffies, expires))
@@ -2942,7 +2938,7 @@ static int rt_fill_info(struct net *net,
 				goto nla_put_failure;
 	}
 
-	if (rtnl_put_cacheinfo(skb, &rt->dst, id, ts, tsage,
+	if (rtnl_put_cacheinfo(skb, &rt->dst, id, 0, 0,
 			       expires, error) < 0)
 		goto nla_put_failure;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e9312a8..d406bf7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -209,22 +209,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
-	    !tp->rx_opt.ts_recent_stamp && fl4->daddr == daddr) {
-		struct inet_peer *peer = rt_get_peer(rt, fl4->daddr);
-		/*
-		 * VJ's idea. We save last timestamp seen from
-		 * the destination in peer table, when entering state
-		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
-		 * when trying new connection.
-		 */
-		if (peer) {
-			inet_peer_refcheck(peer);
-			if ((u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
-				tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
-				tp->rx_opt.ts_recent = peer->tcp_ts;
-			}
-		}
-	}
+	    !tp->rx_opt.ts_recent_stamp && fl4->daddr == daddr)
+		tcp_fetch_timewait_stamp(sk, &rt->dst);
 
 	inet->inet_dport = usin->sin_port;
 	inet->inet_daddr = daddr;
@@ -1375,7 +1361,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
 		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
-		struct inet_peer *peer = NULL;
 		struct flowi4 fl4;
 
 		/* VJ's idea. We save last timestamp seen
@@ -1390,12 +1375,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, &fl4, req, want_cookie)) != NULL &&
-		    fl4.daddr == saddr &&
-		    (peer = rt_get_peer((struct rtable *)dst, fl4.daddr)) != NULL) {
-			inet_peer_refcheck(peer);
-			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
-			    (s32)(peer->tcp_ts - req->ts_recent) >
-							TCP_PAWS_WINDOW) {
+		    fl4.daddr == saddr) {
+			if (!tcp_peer_is_proven(req, dst, true)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
@@ -1404,8 +1385,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		else if (!sysctl_tcp_syncookies &&
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
-			 (!peer || !peer->tcp_ts_stamp) &&
-			 !tcp_peer_is_proven(req, dst)) {
+			 !tcp_peer_is_proven(req, dst, false)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 286af75..e25f78e 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -32,6 +32,8 @@ struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
 	struct inetpeer_addr		tcpm_addr;
 	unsigned long			tcpm_stamp;
+	u32				tcpm_ts;
+	u32				tcpm_ts_stamp;
 	u32				tcpm_lock;
 	u32				tcpm_vals[TCP_METRIC_MAX];
 };
@@ -114,6 +116,8 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
 	tm->tcpm_vals[TCP_METRIC_SSTHRESH] = dst_metric_raw(dst, RTAX_SSTHRESH);
 	tm->tcpm_vals[TCP_METRIC_CWND] = dst_metric_raw(dst, RTAX_CWND);
 	tm->tcpm_vals[TCP_METRIC_REORDERING] = dst_metric_raw(dst, RTAX_REORDERING);
+	tm->tcpm_ts = 0;
+	tm->tcpm_ts_stamp = 0;
 }
 
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
@@ -217,6 +221,41 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	return tm;
 }
 
+static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock *tw)
+{
+	struct inet6_timewait_sock *tw6;
+	struct tcp_metrics_block *tm;
+	struct inetpeer_addr addr;
+	unsigned int hash;
+
+	addr.family = tw->tw_family;
+	switch (addr.family) {
+	case AF_INET:
+		hash = addr.addr.a4 = tw->tw_daddr;
+		break;
+	case AF_INET6:
+		tw6 = inet6_twsk((struct sock *)tw);
+		*(struct in6_addr *)addr.addr.a6 = tw6->tw_v6_daddr;
+		hash = (addr.addr.a6[0] ^
+			addr.addr.a6[1] ^
+			addr.addr.a6[2] ^
+			addr.addr.a6[3]);
+		break;
+	default:
+		return NULL;
+	}
+
+	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
+	hash &= tcp_metrics_hash_mask;
+
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
+	     tm = rcu_dereference(tm->tcpm_next)) {
+		if (addr_same(&tm->tcpm_addr, &addr))
+			break;
+	}
+	return tm;
+}
+
 static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 						 struct dst_entry *dst,
 						 bool create)
@@ -479,7 +518,7 @@ reset:
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst)
+bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check)
 {
 	struct tcp_metrics_block *tm;
 	bool ret;
@@ -489,16 +528,99 @@ bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst)
 
 	rcu_read_lock();
 	tm = __tcp_get_metrics_req(req, dst);
-	if (tm && tcp_metric_get(tm, TCP_METRIC_RTT))
-		ret = true;
-	else
-		ret = false;
+	if (paws_check) {
+		if (tm &&
+		    (u32)get_seconds() - tm->tcpm_ts_stamp < TCP_PAWS_MSL &&
+		    (s32)(tm->tcpm_ts - req->ts_recent) > TCP_PAWS_WINDOW)
+			ret = false;
+		else
+			ret = true;
+	} else {
+		if (tm && tcp_metric_get(tm, TCP_METRIC_RTT) && tm->tcpm_ts_stamp)
+			ret = true;
+		else
+			ret = false;
+	}
 	rcu_read_unlock();
 
 	return ret;
 }
 EXPORT_SYMBOL_GPL(tcp_peer_is_proven);
 
+void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst)
+{
+	struct tcp_metrics_block *tm;
+
+	rcu_read_lock();
+	tm = tcp_get_metrics(sk, dst, true);
+	if (tm) {
+		struct tcp_sock *tp = tcp_sk(sk);
+
+		if ((u32)get_seconds() - tm->tcpm_ts_stamp <= TCP_PAWS_MSL) {
+			tp->rx_opt.ts_recent_stamp = tm->tcpm_ts_stamp;
+			tp->rx_opt.ts_recent = tm->tcpm_ts;
+		}
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(tcp_fetch_timewait_stamp);
+
+/* VJ's idea. Save last timestamp seen from this destination and hold
+ * it at least for normal timewait interval to use for duplicate
+ * segment detection in subsequent connections, before they enter
+ * synchronized state.
+ */
+bool tcp_remember_stamp(struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_get(sk);
+	bool ret = false;
+
+	if (dst) {
+		struct tcp_metrics_block *tm;
+
+		rcu_read_lock();
+		tm = tcp_get_metrics(sk, dst, true);
+		if (tm) {
+			struct tcp_sock *tp = tcp_sk(sk);
+
+			if ((s32)(tm->tcpm_ts - tp->rx_opt.ts_recent) <= 0 ||
+			    ((u32)get_seconds() - tm->tcpm_ts_stamp > TCP_PAWS_MSL &&
+			     tm->tcpm_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
+				tm->tcpm_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
+				tm->tcpm_ts = tp->rx_opt.ts_recent;
+			}
+			ret = true;
+		}
+		rcu_read_unlock();
+	}		
+	return ret;
+}
+
+bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
+{
+	struct tcp_metrics_block *tm;
+	bool ret = false;
+
+	rcu_read_lock();
+	tm = __tcp_get_metrics_tw(tw);
+	if (tw) {
+		const struct tcp_timewait_sock *tcptw;
+		struct sock *sk = (struct sock *) tw;
+
+		tcptw = tcp_twsk(sk);
+		if ((s32)(tm->tcpm_ts - tcptw->tw_ts_recent) <= 0 ||
+		    ((u32)get_seconds() - tm->tcpm_ts_stamp > TCP_PAWS_MSL &&
+		     tm->tcpm_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
+			tm->tcpm_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
+			tm->tcpm_ts	   = tcptw->tw_ts_recent;
+		}
+		ret = true;
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+
 static __initdata unsigned long tcpmhash_entries;
 static int __init set_tcpmhash_entries(char *str)
 {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 72b7c63..a51aa53 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -49,52 +49,6 @@ struct inet_timewait_death_row tcp_death_row = {
 };
 EXPORT_SYMBOL_GPL(tcp_death_row);
 
-/* VJ's idea. Save last timestamp seen from this destination
- * and hold it at least for normal timewait interval to use for duplicate
- * segment detection in subsequent connections, before they enter synchronized
- * state.
- */
-
-static bool tcp_remember_stamp(struct sock *sk)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct inet_peer *peer;
-
-	peer = icsk->icsk_af_ops->get_peer(sk);
-	if (peer) {
-		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
-		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
-		     peer->tcp_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
-			peer->tcp_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
-			peer->tcp_ts = tp->rx_opt.ts_recent;
-		}
-		return true;
-	}
-
-	return false;
-}
-
-static bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
-{
-	const struct tcp_timewait_sock *tcptw;
-	struct sock *sk = (struct sock *) tw;
-	struct inet_peer *peer;
-
-	tcptw = tcp_twsk(sk);
-	peer = tcptw->tw_peer;
-	if (peer) {
-		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
-		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
-		     peer->tcp_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
-			peer->tcp_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
-			peer->tcp_ts	   = tcptw->tw_ts_recent;
-		}
-		return true;
-	}
-	return false;
-}
-
 static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6cc6c88..0c06847 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2348,13 +2348,11 @@ static int rt6_fill_node(struct net *net,
 			 int iif, int type, u32 pid, u32 seq,
 			 int prefix, int nowait, unsigned int flags)
 {
-	const struct inet_peer *peer;
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
 	struct neighbour *n;
-	u32 ts, tsage;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2473,16 +2471,7 @@ static int rt6_fill_node(struct net *net,
 	else
 		expires = INT_MAX;
 
-	peer = NULL;
-	if (rt6_has_peer(rt))
-		peer = rt6_peer_ptr(rt);
-	ts = tsage = 0;
-	if (peer && peer->tcp_ts_stamp) {
-		ts = peer->tcp_ts;
-		tsage = get_seconds() - peer->tcp_ts_stamp;
-	}
-
-	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, ts, tsage,
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0,
 			       expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 75d1795..9e96b5f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -277,22 +277,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	rt = (struct rt6_info *) dst;
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp &&
-	    ipv6_addr_equal(&rt->rt6i_dst.addr, &np->daddr)) {
-		struct inet_peer *peer = rt6_get_peer(rt);
-		/*
-		 * VJ's idea. We save last timestamp seen from
-		 * the destination in peer table, when entering state
-		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
-		 * when trying new connection.
-		 */
-		if (peer) {
-			inet_peer_refcheck(peer);
-			if ((u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
-				tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
-				tp->rx_opt.ts_recent = peer->tcp_ts;
-			}
-		}
-	}
+	    ipv6_addr_equal(&rt->rt6i_dst.addr, &np->daddr))
+		tcp_fetch_timewait_stamp(sk, dst);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
@@ -1134,8 +1120,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		treq->iif = inet6_iif(skb);
 
 	if (!isn) {
-		struct inet_peer *peer = NULL;
-
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
@@ -1160,14 +1144,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet6_csk_route_req(sk, &fl6, req)) != NULL &&
-		    (peer = rt6_get_peer((struct rt6_info *)dst)) != NULL &&
-		    ipv6_addr_equal((struct in6_addr *)peer->daddr.addr.a6,
-				    &treq->rmt_addr)) {
-			inet_peer_refcheck(peer);
-			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
-			    (s32)(peer->tcp_ts - req->ts_recent) >
-							TCP_PAWS_WINDOW) {
+		    (dst = inet6_csk_route_req(sk, &fl6, req)) != NULL) {
+			if (!tcp_peer_is_proven(req, dst, true)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
@@ -1176,8 +1154,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		else if (!sysctl_tcp_syncookies &&
 			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
 			  (sysctl_max_syn_backlog >> 2)) &&
-			 (!peer || !peer->tcp_ts_stamp) &&
-			 !tcp_peer_is_proven(req, dst)) {
+			 !tcp_peer_is_proven(req, dst, false)) {
 			/* Without syncookies last quarter of
 			 * backlog is filled with destinations,
 			 * proven to be alive.
-- 
1.7.10.4
