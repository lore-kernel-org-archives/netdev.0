From: James Morris <jmorris@namei.org>
Subject: [PATCH] net: Convert xtime.tv_sec to get_seconds()
Date: Tue, 27 Feb 2007 16:24:49 -0500 (EST)
Message-ID: <Line.LNX.4.64.0702271622390.32168@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:46965 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbXB0VYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 16:24:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Where appropriate, convert references to xtime.tv_sec to the
get_seconds() helper function.

Signed-off-by: James Morris <jmorris@namei.org>
---

Please review & apply if ok.

 include/net/tcp.h        |    4 ++--
 net/ipv4/route.c         |    2 +-
 net/ipv4/tcp_input.c     |    6 +++---
 net/ipv4/tcp_ipv4.c      |   10 +++++-----
 net/ipv4/tcp_minisocks.c |    8 ++++----
 net/ipv6/xfrm6_output.c  |    2 +-
 net/rxrpc/main.c         |    2 +-
 net/xfrm/xfrm_policy.c   |   12 ++++++------
 net/xfrm/xfrm_state.c    |    6 +++---
 9 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c472f2..fbeddcb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1011,7 +1011,7 @@ static inline int tcp_paws_check(const s
 {
 	if ((s32)(rx_opt->rcv_tsval - rx_opt->ts_recent) >= 0)
 		return 0;
-	if (xtime.tv_sec >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS)
+	if (get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS)
 		return 0;
 
 	/* RST segments are not recommended to carry timestamp,
@@ -1026,7 +1026,7 @@ static inline int tcp_paws_check(const s
 
 	   However, we can relax time bounds for RST segments to MSL.
 	 */
-	if (rst && xtime.tv_sec >= rx_opt->ts_recent_stamp + TCP_PAWS_MSL)
+	if (rst && get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_MSL)
 		return 0;
 	return 1;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 37e0d4d..0b3d7bf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2683,7 +2683,7 @@ #endif
 		id = rt->peer->ip_id_count;
 		if (rt->peer->tcp_ts_stamp) {
 			ts = rt->peer->tcp_ts;
-			tsage = xtime.tv_sec - rt->peer->tcp_ts_stamp;
+			tsage = get_seconds() - rt->peer->tcp_ts_stamp;
 		}
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1a14191..eb613cd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2737,7 +2737,7 @@ static int tcp_fast_parse_options(struct
 static inline void tcp_store_ts_recent(struct tcp_sock *tp)
 {
 	tp->rx_opt.ts_recent = tp->rx_opt.rcv_tsval;
-	tp->rx_opt.ts_recent_stamp = xtime.tv_sec;
+	tp->rx_opt.ts_recent_stamp = get_seconds();
 }
 
 static inline void tcp_replace_ts_recent(struct tcp_sock *tp, u32 seq)
@@ -2751,7 +2751,7 @@ static inline void tcp_replace_ts_recent
 		 */
 
 		if((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >= 0 ||
-		   xtime.tv_sec >= tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS)
+		   get_seconds() >= tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS)
 			tcp_store_ts_recent(tp);
 	}
 }
@@ -2803,7 +2803,7 @@ static inline int tcp_paws_discard(const
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return ((s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) > TCP_PAWS_WINDOW &&
-		xtime.tv_sec < tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS &&
+		get_seconds() < tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS &&
 		!tcp_disordered_ack(sk, skb));
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ba74bb..b34149b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -149,7 +149,7 @@ int tcp_twsk_unique(struct sock *sk, str
 	 */
 	if (tcptw->tw_ts_recent_stamp &&
 	    (twp == NULL || (sysctl_tcp_tw_reuse &&
-			     xtime.tv_sec - tcptw->tw_ts_recent_stamp > 1))) {
+			     get_seconds() - tcptw->tw_ts_recent_stamp > 1))) {
 		tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
 		if (tp->write_seq == 0)
 			tp->write_seq = 1;
@@ -224,7 +224,7 @@ int tcp_v4_connect(struct sock *sk, stru
 		 * when trying new connection.
 		 */
 		if (peer != NULL &&
-		    peer->tcp_ts_stamp + TCP_PAWS_MSL >= xtime.tv_sec) {
+		    peer->tcp_ts_stamp + TCP_PAWS_MSL >= get_seconds()) {
 			tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
 			tp->rx_opt.ts_recent = peer->tcp_ts;
 		}
@@ -1351,7 +1351,7 @@ #endif
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->v4daddr == saddr) {
-			if (xtime.tv_sec < peer->tcp_ts_stamp + TCP_PAWS_MSL &&
+			if (get_seconds() < peer->tcp_ts_stamp + TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {
 				NET_INC_STATS_BH(LINUX_MIB_PAWSPASSIVEREJECTED);
@@ -1770,7 +1770,7 @@ int tcp_v4_remember_stamp(struct sock *s
 
 	if (peer) {
 		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
-		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < xtime.tv_sec &&
+		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < get_seconds() &&
 		     peer->tcp_ts_stamp <= tp->rx_opt.ts_recent_stamp)) {
 			peer->tcp_ts_stamp = tp->rx_opt.ts_recent_stamp;
 			peer->tcp_ts = tp->rx_opt.ts_recent;
@@ -1791,7 +1791,7 @@ int tcp_v4_tw_remember_stamp(struct inet
 		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 
 		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
-		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < xtime.tv_sec &&
+		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < get_seconds() &&
 		     peer->tcp_ts_stamp <= tcptw->tw_ts_recent_stamp)) {
 			peer->tcp_ts_stamp = tcptw->tw_ts_recent_stamp;
 			peer->tcp_ts	   = tcptw->tw_ts_recent;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 30b1e52..0cfc0e2 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -149,7 +149,7 @@ kill_with_rst:
 		tw->tw_substate	  = TCP_TIME_WAIT;
 		tcptw->tw_rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (tmp_opt.saw_tstamp) {
-			tcptw->tw_ts_recent_stamp = xtime.tv_sec;
+			tcptw->tw_ts_recent_stamp = get_seconds();
 			tcptw->tw_ts_recent	  = tmp_opt.rcv_tsval;
 		}
 
@@ -208,7 +208,7 @@ kill:
 
 		if (tmp_opt.saw_tstamp) {
 			tcptw->tw_ts_recent	  = tmp_opt.rcv_tsval;
-			tcptw->tw_ts_recent_stamp = xtime.tv_sec;
+			tcptw->tw_ts_recent_stamp = get_seconds();
 		}
 
 		inet_twsk_put(tw);
@@ -460,7 +460,7 @@ struct sock *tcp_create_openreq_child(st
 
 		if (newtp->rx_opt.tstamp_ok) {
 			newtp->rx_opt.ts_recent = req->ts_recent;
-			newtp->rx_opt.ts_recent_stamp = xtime.tv_sec;
+			newtp->rx_opt.ts_recent_stamp = get_seconds();
 			newtp->tcp_header_len = sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED;
 		} else {
 			newtp->rx_opt.ts_recent_stamp = 0;
@@ -506,7 +506,7 @@ struct sock *tcp_check_req(struct sock *
 			 * it can be estimated (approximately)
 			 * from another data.
 			 */
-			tmp_opt.ts_recent_stamp = xtime.tv_sec - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
+			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
 			paws_reject = tcp_paws_check(&tmp_opt, th->rst);
 		}
 	}
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index d6d786b..8e4170f 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -76,7 +76,7 @@ static int xfrm6_output_one(struct sk_bu
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 		if (x->props.mode == XFRM_MODE_ROUTEOPTIMIZATION)
-			x->lastused = (u64)xtime.tv_sec;
+			x->lastused = get_seconds();
 
 		spin_unlock_bh(&x->lock);
 
diff --git a/net/rxrpc/main.c b/net/rxrpc/main.c
index baec1f7..cead31b 100644
--- a/net/rxrpc/main.c
+++ b/net/rxrpc/main.c
@@ -37,7 +37,7 @@ static int __init rxrpc_initialise(void)
 	int ret;
 
 	/* my epoch value */
-	rxrpc_epoch = htonl(xtime.tv_sec);
+	rxrpc_epoch = htonl(get_seconds());
 
 	/* register the /proc interface */
 #ifdef CONFIG_PROC_FS
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 946b715..ce356aa 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -268,7 +268,7 @@ static inline unsigned long make_jiffies
 static void xfrm_policy_timer(unsigned long data)
 {
 	struct xfrm_policy *xp = (struct xfrm_policy*)data;
-	unsigned long now = (unsigned long)xtime.tv_sec;
+	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
 	int dir;
@@ -690,7 +690,7 @@ int xfrm_policy_insert(int dir, struct x
 	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(policy->type, dir);
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
-	policy->curlft.add_time = (unsigned long)xtime.tv_sec;
+	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
@@ -1119,7 +1119,7 @@ #endif
 	old_pol = sk->sk_policy[dir];
 	sk->sk_policy[dir] = pol;
 	if (pol) {
-		pol->curlft.add_time = (unsigned long)xtime.tv_sec;
+		pol->curlft.add_time = get_seconds();
 		pol->index = xfrm_gen_index(pol->type, XFRM_POLICY_MAX+dir);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
@@ -1372,7 +1372,7 @@ restart:
 		return 0;
 
 	family = dst_orig->ops->family;
-	policy->curlft.use_time = (unsigned long)xtime.tv_sec;
+	policy->curlft.use_time = get_seconds();
 	pols[0] = policy;
 	npols ++;
 	xfrm_nr += pols[0]->xfrm_nr;
@@ -1668,7 +1668,7 @@ int __xfrm_policy_check(struct sock *sk,
 		return 1;
 	}
 
-	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
+	pol->curlft.use_time = get_seconds();
 
 	pols[0] = pol;
 	npols ++;
@@ -1680,7 +1680,7 @@ #ifdef CONFIG_XFRM_SUB_POLICY
 		if (pols[1]) {
 			if (IS_ERR(pols[1]))
 				return 0;
-			pols[1]->curlft.use_time = (unsigned long)xtime.tv_sec;
+			pols[1]->curlft.use_time = get_seconds();
 			npols ++;
 		}
 	}
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a35f9e4..ee2561b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -233,7 +233,7 @@ static inline unsigned long make_jiffies
 static void xfrm_timer_handler(unsigned long data)
 {
 	struct xfrm_state *x = (struct xfrm_state*)data;
-	unsigned long now = (unsigned long)xtime.tv_sec;
+	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
 	int err = 0;
@@ -326,7 +326,7 @@ struct xfrm_state *xfrm_state_alloc(void
 		init_timer(&x->rtimer);
 		x->rtimer.function = xfrm_replay_timer_handler;
 		x->rtimer.data     = (unsigned long)x;
-		x->curlft.add_time = (unsigned long)xtime.tv_sec;
+		x->curlft.add_time = get_seconds();
 		x->lft.soft_byte_limit = XFRM_INF;
 		x->lft.soft_packet_limit = XFRM_INF;
 		x->lft.hard_byte_limit = XFRM_INF;
@@ -1049,7 +1049,7 @@ EXPORT_SYMBOL(xfrm_state_update);
 int xfrm_state_check_expire(struct xfrm_state *x)
 {
 	if (!x->curlft.use_time)
-		x->curlft.use_time = (unsigned long)xtime.tv_sec;
+		x->curlft.use_time = get_seconds();
 
 	if (x->km.state != XFRM_STATE_VALID)
 		return -EINVAL;
-- 
1.4.2.1

