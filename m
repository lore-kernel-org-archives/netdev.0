From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 3/3] tcp: send packets with a socket timestamp
Date: Mon, 11 Feb 2013 19:50:19 +0400
Message-ID: <1360597819-23783-4-git-send-email-avagin@openvz.org>
References: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A socket timestamp is a sum of the global tcp_time_stamp and
a per-socket offset.

A socket offset is added in places where externally visible
tcp timestamp option is parsed/initialized.

Connections in the SYN_RECV state are not supported, global
tcp_time_stamp is used for them, because repair mode doesn't support
this state. In a future it can be implemented by the similar way
as for TIME_WAIT sockets.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv4/tcp_input.c     |  8 +++++++-
 net/ipv4/tcp_ipv4.c      | 12 +++++++-----
 net/ipv4/tcp_minisocks.c |  1 +
 net/ipv4/tcp_output.c    |  4 ++--
 net/ipv6/tcp_ipv6.c      | 22 +++++++++++++---------
 5 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a28e4db..dcb7a52 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3872,7 +3872,7 @@ static bool tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr
 		++ptr;
 		tp->rx_opt.rcv_tsval = ntohl(*ptr);
 		++ptr;
-		tp->rx_opt.rcv_tsecr = ntohl(*ptr);
+		tp->rx_opt.rcv_tsecr = ntohl(*ptr) - tp->tsoffset;
 		return true;
 	}
 	return false;
@@ -3896,7 +3896,11 @@ static bool tcp_fast_parse_options(const struct sk_buff *skb,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return true;
 	}
+
 	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1, NULL);
+	if (tp->rx_opt.saw_tstamp)
+		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
+
 	return true;
 }
 
@@ -5678,6 +5682,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
 	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, &foc);
+	if (tp->rx_opt.saw_tstamp)
+		tp->rx_opt.rcv_tsecr -= tp->tsoffset;
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 54139fa..0679fb7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -725,7 +725,7 @@ release_sk1:
  */
 
 static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 ts, int oif,
+			    u32 win, u32 tsval, u32 tsecr, int oif,
 			    struct tcp_md5sig_key *key,
 			    int reply_flags, u8 tos)
 {
@@ -746,12 +746,12 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 
 	arg.iov[0].iov_base = (unsigned char *)&rep;
 	arg.iov[0].iov_len  = sizeof(rep.th);
-	if (ts) {
+	if (tsecr) {
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				   (TCPOPT_TIMESTAMP << 8) |
 				   TCPOLEN_TIMESTAMP);
-		rep.opt[1] = htonl(tcp_time_stamp);
-		rep.opt[2] = htonl(ts);
+		rep.opt[1] = htonl(tsval);
+		rep.opt[2] = htonl(tsecr);
 		arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;
 	}
 
@@ -766,7 +766,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 
 #ifdef CONFIG_TCP_MD5SIG
 	if (key) {
-		int offset = (ts) ? 3 : 0;
+		int offset = (tsecr) ? 3 : 0;
 
 		rep.opt[offset++] = htonl((TCPOPT_NOP << 24) |
 					  (TCPOPT_NOP << 16) |
@@ -801,6 +801,7 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 
 	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
+			tcp_time_stamp + tcptw->tw_ts_offset,
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
 			tcp_twsk_md5_key(tcptw),
@@ -820,6 +821,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 	tcp_v4_send_ack(skb, (sk->sk_state == TCP_LISTEN) ?
 			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
 			tcp_rsk(req)->rcv_nxt, req->rcv_wnd,
+			tcp_time_stamp,
 			req->ts_recent,
 			0,
 			tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&ip_hdr(skb)->daddr,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b94940e..9f26eb3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -102,6 +102,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
 
 		if (tmp_opt.saw_tstamp) {
+			tmp_opt.rcv_tsecr	-= tcptw->tw_ts_offset;
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
 			tmp_opt.ts_recent_stamp	= tcptw->tw_ts_recent_stamp;
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..5c6fc14 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -622,7 +622,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 
 	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = TCP_SKB_CB(skb)->when;
+		opts->tsval = TCP_SKB_CB(skb)->when + tp->tsoffset;
 		opts->tsecr = tp->rx_opt.ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
@@ -806,7 +806,7 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 
 	if (likely(tp->rx_opt.tstamp_ok)) {
 		opts->options |= OPTION_TS;
-		opts->tsval = tcb ? tcb->when : 0;
+		opts->tsval = tcb ? tcb->when + tp->tsoffset : 0;
 		opts->tsecr = tp->rx_opt.ts_recent;
 		size += TCPOLEN_TSTAMP_ALIGNED;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..0aa0d1d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -712,7 +712,8 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 #endif
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
-				 u32 ts, struct tcp_md5sig_key *key, int rst, u8 tclass)
+				 u32 tsval, u32 tsecr,
+				 struct tcp_md5sig_key *key, int rst, u8 tclass)
 {
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcphdr *t1;
@@ -724,7 +725,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	struct dst_entry *dst;
 	__be32 *topt;
 
-	if (ts)
+	if (tsecr)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
 #ifdef CONFIG_TCP_MD5SIG
 	if (key)
@@ -754,11 +755,11 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 
 	topt = (__be32 *)(t1 + 1);
 
-	if (ts) {
+	if (tsecr) {
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
-		*topt++ = htonl(tcp_time_stamp);
-		*topt++ = htonl(ts);
+		*topt++ = htonl(tsval);
+		*topt++ = htonl(tsecr);
 	}
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -858,7 +859,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1, 0);
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 release_sk1:
@@ -869,10 +870,11 @@ release_sk1:
 #endif
 }
 
-static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
+static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+			    u32 win, u32 tsval, u32 tsecr,
 			    struct tcp_md5sig_key *key, u8 tclass)
 {
-	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0, tclass);
+	tcp_v6_send_response(skb, seq, ack, win, tsval, tsecr, key, 0, tclass);
 }
 
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -882,6 +884,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 
 	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
+			tcp_time_stamp + tcptw->tw_ts_offset,
 			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
 			tw->tw_tclass);
 
@@ -891,7 +894,8 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
+	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
+			req->rcv_wnd, tcp_time_stamp, req->ts_recent,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr), 0);
 }
 
-- 
1.7.11.7
