From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 13/13] tcp: add tcp_conn_request
Date: Wed, 25 Jun 2014 17:10:02 +0300
Message-ID: <1403705402-14388-14-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45758 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757354AbaFYOKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:39 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create tcp_conn_request and remove most of the code from
tcp_v4_conn_request and tcp_v6_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h    |   3 ++
 net/ipv4/tcp_input.c | 148 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c  | 128 +-------------------------------------------
 net/ipv6/tcp_ipv6.c  | 120 +----------------------------------------
 4 files changed, 155 insertions(+), 244 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cec6e2c..0d5389ae 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1574,6 +1574,9 @@ void tcp4_proc_exit(void);
 #endif
 
 int tcp_rtx_synack(struct sock *sk, struct request_sock *req);
+int tcp_conn_request(struct request_sock_ops *rsk_ops,
+		     const struct tcp_request_sock_ops *af_ops,
+		     struct sock *sk, struct sk_buff *skb);
 
 /* TCP af-specific functions */
 struct tcp_sock_af_ops {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 40661fc..401164e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5877,3 +5877,151 @@ discard:
 	return 0;
 }
 EXPORT_SYMBOL(tcp_rcv_state_process);
+
+static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+
+	if (family == AF_INET)
+		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI4/%u\n"),
+			       &ireq->ir_rmt_addr, port);
+	else
+		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI6/%u\n"),
+			       &ireq->ir_v6_rmt_addr, port);
+}
+
+int tcp_conn_request(struct request_sock_ops *rsk_ops,
+		     const struct tcp_request_sock_ops *af_ops,
+		     struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_options_received tmp_opt;
+	struct request_sock *req;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = NULL;
+	__u32 isn = TCP_SKB_CB(skb)->when;
+	bool want_cookie = false, fastopen;
+	struct flowi fl;
+	struct tcp_fastopen_cookie foc = { .len = -1 };
+	int err;
+
+
+	/* TW buckets are converted to open requests without
+	 * limitations, they conserve resources and peer is
+	 * evidently real one.
+	 */
+	if ((sysctl_tcp_syncookies == 2 ||
+	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
+		want_cookie = tcp_syn_flood_action(sk, skb, rsk_ops->slab_name);
+		if (!want_cookie)
+			goto drop;
+	}
+
+
+	/* Accept backlog is full. If we have already queued enough
+	 * of warm entries in syn queue, drop request. It is better than
+	 * clogging syn queue with openreqs with exponentially increasing
+	 * timeout.
+	 */
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
+		goto drop;
+	}
+
+	req = inet_reqsk_alloc(rsk_ops);
+	if (!req)
+		goto drop;
+
+	tcp_rsk(req)->af_specific = af_ops;
+
+	tcp_clear_options(&tmp_opt);
+	tmp_opt.mss_clamp = af_ops->mss_clamp;
+	tmp_opt.user_mss  = tp->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
+
+	if (want_cookie && !tmp_opt.saw_tstamp)
+		tcp_clear_options(&tmp_opt);
+
+	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
+	tcp_openreq_init(req, &tmp_opt, skb, sk);
+
+	af_ops->init_req(req, sk, skb);
+
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
+	if (!want_cookie || tmp_opt.tstamp_ok)
+		TCP_ECN_create_request(req, skb, sock_net(sk));
+
+	if (want_cookie) {
+		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
+		req->cookie_ts = tmp_opt.tstamp_ok;
+	} else if (!isn) {
+		/* VJ's idea. We save last timestamp seen
+		 * from the destination in peer table, when entering
+		 * state TIME-WAIT, and check against it before
+		 * accepting new connection request.
+		 *
+		 * If "isn" is not zero, this request hit alive
+		 * timewait bucket, so that all the necessary checks
+		 * are made in the function processing timewait state.
+		 */
+		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
+			bool strict;
+
+			dst = af_ops->route_req(sk, &fl, req, &strict);
+			if (dst && strict &&
+			    !tcp_peer_is_proven(req, dst, true)) {
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
+				goto drop_and_release;
+			}
+		}
+		/* Kill the following clause, if you dislike this way. */
+		else if (!sysctl_tcp_syncookies &&
+			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
+			  (sysctl_max_syn_backlog >> 2)) &&
+			 !tcp_peer_is_proven(req, dst, false)) {
+			/* Without syncookies last quarter of
+			 * backlog is filled with destinations,
+			 * proven to be alive.
+			 * It means that we continue to communicate
+			 * to destinations, already remembered
+			 * to the moment of synflood.
+			 */
+			pr_drop_req(req, ntohs(tcp_hdr(skb)->source),
+				    rsk_ops->family);
+			goto drop_and_release;
+		}
+
+		isn = af_ops->init_seq(skb);
+	}
+	if (!dst) {
+		dst = af_ops->route_req(sk, &fl, req, NULL);
+		if (!dst)
+			goto drop_and_free;
+	}
+
+	tcp_rsk(req)->snt_isn = isn;
+	tcp_openreq_init_rwin(req, sk, dst);
+	fastopen = !want_cookie &&
+		   tcp_try_fastopen(sk, skb, req, &foc, dst);
+	err = af_ops->send_synack(sk, dst, &fl, req,
+				  skb_get_queue_mapping(skb), &foc);
+	if (!fastopen) {
+		if (err || want_cookie)
+			goto drop_and_free;
+
+		tcp_rsk(req)->listener = NULL;
+		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	}
+
+	return 0;
+
+drop_and_release:
+	dst_release(dst);
+drop_and_free:
+	reqsk_free(req);
+drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	return 0;
+}
+EXPORT_SYMBOL(tcp_conn_request);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 845c39d..5dfebd2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1282,137 +1282,13 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_options_received tmp_opt;
-	struct request_sock *req;
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = NULL;
-	__be32 saddr = ip_hdr(skb)->saddr;
-	__u32 isn = TCP_SKB_CB(skb)->when;
-	bool want_cookie = false, fastopen;
-	struct flowi4 fl4;
-	struct tcp_fastopen_cookie foc = { .len = -1 };
-	const struct tcp_request_sock_ops *af_ops;
-	int err;
-
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
-	/* TW buckets are converted to open requests without
-	 * limitations, they conserve resources and peer is
-	 * evidently real one.
-	 */
-	if ((sysctl_tcp_syncookies == 2 ||
-	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
-		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
-		if (!want_cookie)
-			goto drop;
-	}
-
-	/* Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
-		goto drop;
-	}
-
-	req = inet_reqsk_alloc(&tcp_request_sock_ops);
-	if (!req)
-		goto drop;
-
-	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
-
-	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = af_ops->mss_clamp;
-	tmp_opt.user_mss  = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
-
-	if (want_cookie && !tmp_opt.saw_tstamp)
-		tcp_clear_options(&tmp_opt);
-
-	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-	tcp_openreq_init(req, &tmp_opt, skb, sk);
-
-	af_ops->init_req(req, sk, skb);
-
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_free;
+	return tcp_conn_request(&tcp_request_sock_ops,
+				&tcp_request_sock_ipv4_ops, sk, skb);
 
-	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sock_net(sk));
-
-	if (want_cookie) {
-		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-		req->cookie_ts = tmp_opt.tstamp_ok;
-	} else if (!isn) {
-		/* VJ's idea. We save last timestamp seen
-		 * from the destination in peer table, when entering
-		 * state TIME-WAIT, and check against it before
-		 * accepting new connection request.
-		 *
-		 * If "isn" is not zero, this request hit alive
-		 * timewait bucket, so that all the necessary checks
-		 * are made in the function processing timewait state.
-		 */
-		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
-			bool strict;
-
-			dst = af_ops->route_req(sk, (struct flowi *)&fl4, req,
-						&strict);
-			if (dst && strict &&
-			    !tcp_peer_is_proven(req, dst, true)) {
-				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
-				goto drop_and_release;
-			}
-		}
-		/* Kill the following clause, if you dislike this way. */
-		else if (!sysctl_tcp_syncookies &&
-			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
-			  (sysctl_max_syn_backlog >> 2)) &&
-			 !tcp_peer_is_proven(req, dst, false)) {
-			/* Without syncookies last quarter of
-			 * backlog is filled with destinations,
-			 * proven to be alive.
-			 * It means that we continue to communicate
-			 * to destinations, already remembered
-			 * to the moment of synflood.
-			 */
-			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI4/%u\n"),
-				       &saddr, ntohs(tcp_hdr(skb)->source));
-			goto drop_and_release;
-		}
-
-		isn = af_ops->init_seq(skb);
-	}
-	if (!dst) {
-		dst = af_ops->route_req(sk, (struct flowi *)&fl4, req, NULL);
-		if (!dst)
-			goto drop_and_free;
-	}
-
-	tcp_rsk(req)->snt_isn = isn;
-	tcp_openreq_init_rwin(req, sk, dst);
-	fastopen = !want_cookie &&
-		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = af_ops->send_synack(sk, dst, NULL, req,
-				  skb_get_queue_mapping(skb), &foc);
-	if (!fastopen) {
-		if (err || want_cookie)
-			goto drop_and_free;
-
-		tcp_rsk(req)->listener = NULL;
-		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-	}
-
-	return 0;
-
-drop_and_release:
-	dst_release(dst);
-drop_and_free:
-	reqsk_free(req);
 drop:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8232bc7..bc24ee2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1008,133 +1008,17 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 	return sk;
 }
 
-/* FIXME: this is substantially similar to the ipv4 code.
- * Can some kind of merge be done? -- erics
- */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_options_received tmp_opt;
-	struct request_sock *req;
-	struct inet_request_sock *ireq;
-	struct tcp_sock *tp = tcp_sk(sk);
-	__u32 isn = TCP_SKB_CB(skb)->when;
-	struct dst_entry *dst = NULL;
-	struct tcp_fastopen_cookie foc = { .len = -1 };
-	bool want_cookie = false, fastopen;
-	struct flowi6 fl6;
-	const struct tcp_request_sock_ops *af_ops;
-	int err;
-
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
 
 	if (!ipv6_unicast_destination(skb))
 		goto drop;
 
-	if ((sysctl_tcp_syncookies == 2 ||
-	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
-		want_cookie = tcp_syn_flood_action(sk, skb, "TCPv6");
-		if (!want_cookie)
-			goto drop;
-	}
+	return tcp_conn_request(&tcp6_request_sock_ops,
+				&tcp_request_sock_ipv6_ops, sk, skb);
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
-		goto drop;
-	}
-
-	req = inet_reqsk_alloc(&tcp6_request_sock_ops);
-	if (req == NULL)
-		goto drop;
-
-	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
-
-	tcp_clear_options(&tmp_opt);
-	tmp_opt.mss_clamp = af_ops->mss_clamp;
-	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
-
-	if (want_cookie && !tmp_opt.saw_tstamp)
-		tcp_clear_options(&tmp_opt);
-
-	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-	tcp_openreq_init(req, &tmp_opt, skb, sk);
-
-	ireq = inet_rsk(req);
-	af_ops->init_req(req, sk, skb);
-
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_release;
-
-	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb, sock_net(sk));
-
-	if (want_cookie) {
-		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-		req->cookie_ts = tmp_opt.tstamp_ok;
-	} else if (!isn) {
-		/* VJ's idea. We save last timestamp seen
-		 * from the destination in peer table, when entering
-		 * state TIME-WAIT, and check against it before
-		 * accepting new connection request.
-		 *
-		 * If "isn" is not zero, this request hit alive
-		 * timewait bucket, so that all the necessary checks
-		 * are made in the function processing timewait state.
-		 */
-		if (tmp_opt.saw_tstamp && tcp_death_row.sysctl_tw_recycle) {
-			dst = af_ops->route_req(sk, (struct flowi *)&fl6, req,
-						NULL);
-			if (dst && !tcp_peer_is_proven(req, dst, true)) {
-				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
-				goto drop_and_release;
-			}
-		}
-		/* Kill the following clause, if you dislike this way. */
-		else if (!sysctl_tcp_syncookies &&
-			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
-			  (sysctl_max_syn_backlog >> 2)) &&
-			 !tcp_peer_is_proven(req, dst, false)) {
-			/* Without syncookies last quarter of
-			 * backlog is filled with destinations,
-			 * proven to be alive.
-			 * It means that we continue to communicate
-			 * to destinations, already remembered
-			 * to the moment of synflood.
-			 */
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open request from %pI6/%u\n",
-				       &ireq->ir_v6_rmt_addr, ntohs(tcp_hdr(skb)->source));
-			goto drop_and_release;
-		}
-
-		isn = af_ops->init_seq(skb);
-	}
-
-	if (!dst) {
-		dst = af_ops->route_req(sk, (struct flowi *)&fl6, req, NULL);
-		if (!dst)
-			goto drop_and_free;
-	}
-
-	tcp_rsk(req)->snt_isn = isn;
-	tcp_openreq_init_rwin(req, sk, dst);
-	fastopen = !want_cookie &&
-		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = af_ops->send_synack(sk, dst, (struct flowi *)&fl6, req,
-				  skb_get_queue_mapping(skb), &foc);
-	if (!fastopen) {
-		if (err || want_cookie)
-			goto drop_and_free;
-
-		tcp_rsk(req)->listener = NULL;
-		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-	}
-	return 0;
-
-drop_and_release:
-	dst_release(dst);
-drop_and_free:
-	reqsk_free(req);
 drop:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return 0; /* don't send reset */
-- 
1.8.3.2
