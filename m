From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: [RFC PATCH 1/2] tcp: extract syncookie part of tcp_v4_conn_request()
Date: Mon, 28 May 2012 13:52:21 +0200
Message-ID: <20120528115221.12068.52761.stgit@localhost.localdomain>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:14369 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752579Ab2E1L7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 07:59:12 -0400
In-Reply-To: <20120528115102.12068.79994.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Place SYN cookie handling, from tcp_v4_conn_request() into seperate
function, named tcp_v4_syn_conn_limit(). The semantics should be
almost the same.

Besides code cleanup, this patch is preparing for handling SYN cookie
in an ealier step, to avoid a spinlock and achive parallel processing.

Signed-off-by: Martin Topholm <mph@hoth.dk>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_ipv4.c |  125 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 101 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a43b87d..15958b2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1268,6 +1268,98 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 };
 #endif
 
+/* Check SYN connect limit and send SYN-ACK cookies
+ * - Return 0 = No limitation needed, continue processing
+ * - Return 1 = Stop processing, free SKB, SYN cookie send (if enabled)
+ */
+int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
+{
+	struct request_sock *req;
+	struct inet_request_sock *ireq;
+	struct tcp_options_received tmp_opt;
+	__be32 saddr = ip_hdr(skb)->saddr;
+	__be32 daddr = ip_hdr(skb)->daddr;
+	__u32 isn = TCP_SKB_CB(skb)->when;
+	const u8 *hash_location; /* No really used */
+
+//	WARN_ON(!tcp_hdr(skb)->syn); /* MUST only be called for SYN req */
+//	WARN_ON(!(sk->sk_state == TCP_LISTEN)); /* On a LISTEN socket */
+
+	/* Never answer to SYNs send to broadcast or multicast */
+	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		goto drop;
+
+	/* If "isn" is not zero, this request hit alive timewait bucket */
+	if (isn)
+		goto no_limit;
+
+	/* Start sending SYN cookies when request sock queue is full*/
+	if (!inet_csk_reqsk_queue_is_full(sk))
+		goto no_limit;
+
+	/* Check if SYN cookies are enabled
+	 * - Side effect: NET_INC_STATS_BH counters + printk logging
+	 */
+	if (!tcp_syn_flood_action(sk, skb, "TCP"))
+		goto drop; /* Not enabled, indicate drop, due to queue full */
+
+	/* Allocate a request_sock */
+	req = inet_reqsk_alloc(&tcp_request_sock_ops);
+	if (!req) {
+		net_warn_ratelimited ("%s: Could not alloc request_sock"
+				      ", drop conn from %pI4",
+				      __FUNCTION__, &saddr);
+		goto drop;
+	}
+
+#ifdef CONFIG_TCP_MD5SIG
+	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
+#endif
+
+	tcp_clear_options(&tmp_opt);
+        tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
+	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+
+	if (!tmp_opt.saw_tstamp)
+		tcp_clear_options(&tmp_opt);
+
+	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
+	tcp_openreq_init(req, &tmp_opt, skb);
+
+	/* Update req as an inet_request_sock (typecast trick)*/
+	ireq = inet_rsk(req);
+	ireq->loc_addr = daddr;
+	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
+	ireq->opt = tcp_v4_save_options(sk, skb);
+
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
+	/* Cookie support for ECN if TCP timestamp option avail */
+	if (tmp_opt.tstamp_ok)
+		TCP_ECN_create_request(req, skb);
+
+	/* Encode cookie in InitialSeqNum of SYN-ACK packet */
+	isn = cookie_v4_init_sequence(sk, skb, &req->mss);
+	req->cookie_ts = tmp_opt.tstamp_ok;
+
+	tcp_rsk(req)->snt_isn = isn;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+
+	/* Send SYN-ACK containing cookie */
+	tcp_v4_send_synack(sk, NULL, req, NULL);
+
+drop_and_free:
+	reqsk_free(req);
+drop:
+	return 1;
+no_limit:
+	return 0;
+}
+
+/* Handle SYN request */
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
@@ -1280,22 +1372,11 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
-	bool want_cookie = false;
 
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
 		goto drop;
 
-	/* TW buckets are converted to open requests without
-	 * limitations, they conserve resources and peer is
-	 * evidently real one.
-	 */
-	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
-		if (!want_cookie)
-			goto drop;
-	}
-
 	/* Accept backlog is full. If we have already queued enough
 	 * of warm entries in syn queue, drop request. It is better than
 	 * clogging syn queue with openreqs with exponentially increasing
@@ -1304,6 +1385,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
+	/* SYN cookie handling */
+	if (tcp_v4_syn_conn_limit(sk, skb))
+		goto drop;
+
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
 		goto drop;
@@ -1317,6 +1402,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
 	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
 
+	/* Handle RFC6013 - TCP Cookie Transactions (TCPCT) options */
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
 	    !tp->rx_opt.cookie_out_never &&
@@ -1339,7 +1425,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;
 
-		want_cookie = false;	/* not our kind of cookie */
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 	} else if (!tp->rx_opt.cookie_in_always) {
@@ -1351,12 +1436,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
-	if (want_cookie && !tmp_opt.saw_tstamp)
-		tcp_clear_options(&tmp_opt);
-
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
 
+	/* Update req as an inet_request_sock (typecast trick)*/
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
@@ -1366,13 +1449,9 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	if (!want_cookie || tmp_opt.tstamp_ok)
-		TCP_ECN_create_request(req, skb);
+	TCP_ECN_create_request(req, skb);
 
-	if (want_cookie) {
-		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
-		req->cookie_ts = tmp_opt.tstamp_ok;
-	} else if (!isn) {
+	if (!isn) { /* Timewait bucket handling */
 		struct inet_peer *peer = NULL;
 		struct flowi4 fl4;
 
@@ -1422,8 +1501,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
 	if (tcp_v4_send_synack(sk, dst, req,
-			       (struct request_values *)&tmp_ext) ||
-	    want_cookie)
+			       (struct request_values *)&tmp_ext))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
@@ -1438,7 +1516,6 @@ drop:
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
 
-
 /*
  * The three way handshake has completed - we got a valid synack -
  * now create the new socket.
