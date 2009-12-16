From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Tue, 15 Dec 2009 20:57:12 -0800 (PST)
Message-ID: <20091215.205712.226792174.davem@davemloft.net>
References: <20091214.143522.102450157.davem@davemloft.net>
	<20091214.231840.106434922.davem@davemloft.net>
	<20091215.205055.193693273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gilad@codefidence.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761563AbZLPE5P@vger.kernel.org>
In-Reply-To: <20091215.205055.193693273.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 15 Dec 2009 20:50:55 -0800 (PST)

> I'm simply going to revert this entire series.

tcp: Revert per-route SACK/DSACK/TIMESTAMP changes.

It creates a regression, triggering badness for SYN_RECV
sockets, for example:

[19148.022102] Badness at net/ipv4/inet_connection_sock.c:293
[19148.022570] NIP: c02a0914 LR: c02a0904 CTR: 00000000
[19148.023035] REGS: eeecbd30 TRAP: 0700   Not tainted  (2.6.32)
[19148.023496] MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002442  XER: 00000000
[19148.024012] TASK = eee9a820[1756] 'privoxy' THREAD: eeeca000

This is likely caused by the change in the 'estab' parameter
passed to tcp_parse_options() when invoked by the functions
in net/ipv4/tcp_minisocks.c

But even if that is fixed, the ->conn_request() changes made in
this patch series is fundamentally wrong.  They try to use the
listening socket's 'dst' to probe the route settings.  The
listening socket doesn't even have a route, and you can't
get the right route (the child request one) until much later
after we setup all of the state, and it must be done by hand.

This stuff really isn't ready, so the best thing to do is a
full revert.  This reverts the following commits:

f55017a93f1a74d50244b1254b9a2bd7ac9bbf7d
022c3f7d82f0f1c68018696f2f027b87b9bb45c2
1aba721eba1d84a2defce45b950272cee1e6c72a
cda42ebd67ee5fdf09d7057b5a4584d36fe8a335
345cda2fd695534be5a4494f1b59da9daed33663
dc343475ed062e13fc260acccaab91d7d80fd5b2
05eaade2782fb0c90d3034fd7a7d5a16266182bb
6a2a2d6bf8581216e08be15fcb563cfd6c430e1e

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/rtnetlink.h |    6 ++----
 include/net/dst.h         |    2 +-
 include/net/tcp.h         |    3 +--
 net/ipv4/syncookies.c     |   27 +++++++++++++--------------
 net/ipv4/tcp_input.c      |   24 ++++++++----------------
 net/ipv4/tcp_ipv4.c       |   21 +++++++++------------
 net/ipv4/tcp_minisocks.c  |   10 +++++-----
 net/ipv4/tcp_output.c     |   18 +++++-------------
 net/ipv6/syncookies.c     |   28 +++++++++++++---------------
 net/ipv6/tcp_ipv6.c       |    3 +--
 10 files changed, 58 insertions(+), 84 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 14fc906..05330fc 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -368,11 +368,9 @@ enum {
 #define RTAX_MAX (__RTAX_MAX - 1)
 
 #define RTAX_FEATURE_ECN	0x00000001
-#define RTAX_FEATURE_NO_SACK	0x00000002
-#define RTAX_FEATURE_NO_TSTAMP	0x00000004
+#define RTAX_FEATURE_SACK	0x00000002
+#define RTAX_FEATURE_TIMESTAMP	0x00000004
 #define RTAX_FEATURE_ALLFRAG	0x00000008
-#define RTAX_FEATURE_NO_WSCALE	0x00000010
-#define RTAX_FEATURE_NO_DSACK	0x00000020
 
 struct rta_session {
 	__u8	proto;
diff --git a/include/net/dst.h b/include/net/dst.h
index 387cb3c..39c4a59 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -113,7 +113,7 @@ dst_metric(const struct dst_entry *dst, int metric)
 static inline u32
 dst_feature(const struct dst_entry *dst, u32 feature)
 {
-	return (dst ? dst_metric(dst, RTAX_FEATURES) & feature : 0);
+	return dst_metric(dst, RTAX_FEATURES) & feature;
 }
 
 static inline u32 dst_mtu(const struct dst_entry *dst)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1b6f7d3..34f5cc2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -408,8 +408,7 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
 						  u8 **hvpp,
-						  int estab,
-						  struct dst_entry *dst);
+						  int estab);
 
 extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 26399ad..66fd80e 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -277,6 +277,13 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
 	ret = NULL;
 	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
 	if (!req)
@@ -292,6 +299,12 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->ecn_ok		= 0;
+	ireq->snd_wscale	= tcp_opt.snd_wscale;
+	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
+	ireq->sack_ok		= tcp_opt.sack_ok;
+	ireq->wscale_ok		= tcp_opt.wscale_ok;
+	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
+	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
@@ -340,20 +353,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
-	/* check for timestamp cookie support */
-	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, &rt->u.dst);
-
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
-
-	ireq->snd_wscale        = tcp_opt.snd_wscale;
-	ireq->rcv_wscale        = tcp_opt.rcv_wscale;
-	ireq->sack_ok           = tcp_opt.sack_ok;
-	ireq->wscale_ok         = tcp_opt.wscale_ok;
-	ireq->tstamp_ok         = tcp_opt.saw_tstamp;
-	req->ts_recent          = tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
-
 	/* Try to redo what tcp_v4_send_synack did. */
 	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->u.dst, RTAX_WINDOW);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 12cab7d..28e0296 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3727,7 +3727,7 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       u8 **hvpp, int estab,  struct dst_entry *dst)
+		       u8 **hvpp, int estab)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
@@ -3766,8 +3766,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				break;
 			case TCPOPT_WINDOW:
 				if (opsize == TCPOLEN_WINDOW && th->syn &&
-				    !estab && sysctl_tcp_window_scaling &&
-				    !dst_feature(dst, RTAX_FEATURE_NO_WSCALE)) {
+				    !estab && sysctl_tcp_window_scaling) {
 					__u8 snd_wscale = *(__u8 *)ptr;
 					opt_rx->wscale_ok = 1;
 					if (snd_wscale > 14) {
@@ -3783,8 +3782,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 			case TCPOPT_TIMESTAMP:
 				if ((opsize == TCPOLEN_TIMESTAMP) &&
 				    ((estab && opt_rx->tstamp_ok) ||
-				     (!estab && sysctl_tcp_timestamps &&
-				      !dst_feature(dst, RTAX_FEATURE_NO_TSTAMP)))) {
+				     (!estab && sysctl_tcp_timestamps))) {
 					opt_rx->saw_tstamp = 1;
 					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
 					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
@@ -3792,8 +3790,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				break;
 			case TCPOPT_SACK_PERM:
 				if (opsize == TCPOLEN_SACK_PERM && th->syn &&
-				    !estab && sysctl_tcp_sack &&
-				    !dst_feature(dst, RTAX_FEATURE_NO_SACK)) {
+				    !estab && sysctl_tcp_sack) {
 					opt_rx->sack_ok = 1;
 					tcp_sack_reset(opt_rx);
 				}
@@ -3878,7 +3875,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1, NULL);
+	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1);
 	return 1;
 }
 
@@ -4133,10 +4130,8 @@ static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
 static void tcp_dsack_set(struct sock *sk, u32 seq, u32 end_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 
-	if (tcp_is_sack(tp) && sysctl_tcp_dsack &&
-	    !dst_feature(dst, RTAX_FEATURE_NO_DSACK)) {
+	if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
 		int mib_idx;
 
 		if (before(seq, tp->rcv_nxt))
@@ -4165,15 +4160,13 @@ static void tcp_dsack_extend(struct sock *sk, u32 seq, u32 end_seq)
 static void tcp_send_dupack(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 	    before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
 		tcp_enter_quickack_mode(sk);
 
-		if (tcp_is_sack(tp) && sysctl_tcp_dsack &&
-		    !dst_feature(dst, RTAX_FEATURE_NO_DSACK)) {
+		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
 			u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
 			if (after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))
@@ -5428,11 +5421,10 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
-	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, dst);
+	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0);
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 15e9603..65b8ebf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1262,20 +1262,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
-	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
-	ireq->no_srccheck = inet_sk(sk)->transparent;
-	ireq->opt = tcp_v4_save_options(sk, skb);
-
-	dst = inet_csk_route_req(sk, req);
-	if(!dst)
-		goto drop_and_free;
-
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0, dst);
+	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
@@ -1319,8 +1309,14 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
 
+	ireq = inet_rsk(req);
+	ireq->loc_addr = daddr;
+	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
+	ireq->opt = tcp_v4_save_options(sk, skb);
+
 	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_release;
+		goto drop_and_free;
 
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
@@ -1345,6 +1341,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
+		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->v4daddr == saddr) {
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 87accec..f206ee5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -95,9 +95,9 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	int paws_reject = 0;
 
+	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 1, NULL);
+		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -526,9 +526,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
 
-	if ((th->doff > (sizeof(*th) >> 2)) && (req->ts_recent)) {
-		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 1, NULL);
+	tmp_opt.saw_tstamp = 0;
+	if (th->doff > (sizeof(struct tcphdr)>>2)) {
+		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 93316a9..383ce23 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -553,7 +553,6 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
-	struct dst_entry *dst = __sk_dst_get(sk);
 	unsigned remaining = MAX_TCP_OPTION_SPACE;
 	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL) ?
 			 tcp_cookie_size_check(cvp->cookie_desired) :
@@ -581,22 +580,18 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	remaining -= TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps &&
-		   !dst_feature(dst, RTAX_FEATURE_NO_TSTAMP) &&
-		   *md5 == NULL)) {
+	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = TCP_SKB_CB(skb)->when;
 		opts->tsecr = tp->rx_opt.ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
-	if (likely(sysctl_tcp_window_scaling &&
-		   !dst_feature(dst, RTAX_FEATURE_NO_WSCALE))) {
+	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
 		opts->options |= OPTION_WSCALE;
 		remaining -= TCPOLEN_WSCALE_ALIGNED;
 	}
-	if (likely(sysctl_tcp_sack &&
-		   !dst_feature(dst, RTAX_FEATURE_NO_SACK))) {
+	if (likely(sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
 		if (unlikely(!(OPTION_TS & opts->options)))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
@@ -2527,9 +2522,7 @@ static void tcp_connect_init(struct sock *sk)
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
 	 */
 	tp->tcp_header_len = sizeof(struct tcphdr) +
-		(sysctl_tcp_timestamps &&
-		(!dst_feature(dst, RTAX_FEATURE_NO_TSTAMP) ?
-		  TCPOLEN_TSTAMP_ALIGNED : 0));
+		(sysctl_tcp_timestamps ? TCPOLEN_TSTAMP_ALIGNED : 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (tp->af_specific->md5_lookup(sk, sk) != NULL)
@@ -2555,8 +2548,7 @@ static void tcp_connect_init(struct sock *sk)
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
-				  (sysctl_tcp_window_scaling &&
-				   !dst_feature(dst, RTAX_FEATURE_NO_WSCALE)),
+				  sysctl_tcp_window_scaling,
 				  &rcv_wscale);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 5b9af50..7208a06 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -185,6 +185,13 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
+	/* check for timestamp cookie support */
+	memset(&tcp_opt, 0, sizeof(tcp_opt));
+	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+
+	if (tcp_opt.saw_tstamp)
+		cookie_check_timestamp(&tcp_opt);
+
 	ret = NULL;
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
 	if (!req)
@@ -218,6 +225,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->expires = 0UL;
 	req->retrans = 0;
 	ireq->ecn_ok		= 0;
+	ireq->snd_wscale	= tcp_opt.snd_wscale;
+	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
+	ireq->sack_ok		= tcp_opt.sack_ok;
+	ireq->wscale_ok		= tcp_opt.wscale_ok;
+	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
+	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
 
@@ -253,21 +266,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 			goto out_free;
 	}
 
-	/* check for timestamp cookie support */
-	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, dst);
-
-	if (tcp_opt.saw_tstamp)
-		cookie_check_timestamp(&tcp_opt);
-
-	req->ts_recent          = tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
-
-	ireq->snd_wscale        = tcp_opt.snd_wscale;
-	ireq->rcv_wscale        = tcp_opt.rcv_wscale;
-	ireq->sack_ok           = tcp_opt.sack_ok;
-	ireq->wscale_ok         = tcp_opt.wscale_ok;
-	ireq->tstamp_ok         = tcp_opt.saw_tstamp;
-
 	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ee9cf62..febfd59 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1169,7 +1169,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
@@ -1208,7 +1207,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0, dst);
+	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
-- 
1.6.5
