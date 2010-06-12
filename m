From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] tcp: unify tcp flag macros
Date: Sat, 12 Jun 2010 13:59:32 +0800
Message-ID: <1276322372-12584-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unify tcp flag macros

unify tcp flag macros: TH_FIN, TH_SYN, TH_RST, TH_PUSH, TH_ACK, TH_URG, TH_ECE
and TH_CWR. TCBCB_FLAG_* are replaced with the corresponding TH_*.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/tcp.h                      |   24 +++++-------
 net/ipv4/tcp.c                         |    8 ++--
 net/ipv4/tcp_input.c                   |    2 -
 net/ipv4/tcp_output.c                  |   62 +++++++++++++++------------------
 net/netfilter/nf_conntrack_proto_tcp.c |   11 -----
 net/netfilter/xt_TCPMSS.c              |    2 -
 6 files changed, 46 insertions(+), 63 deletions(-)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5731664..238b636 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -602,6 +602,17 @@ extern u32	__tcp_select_window(struct sock *sk);
  */
 #define tcp_time_stamp		((__u32)(jiffies))
 
+#define tcp_flag_byte(th) (((u_int8_t *)th)[13])
+
+#define	TH_FIN	0x01
+#define	TH_SYN	0x02
+#define	TH_RST	0x04
+#define	TH_PUSH	0x08
+#define	TH_ACK	0x10
+#define	TH_URG	0x20
+#define	TH_ECE	0x40
+#define	TH_CWR	0x80
+
 /* This is what the send packet queuing engine uses to pass
  * TCP per-packet control information to the transmission
  * code.  We also store the host-order sequence numbers in
@@ -620,19 +631,6 @@ struct tcp_skb_cb {
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
 	__u8		flags;		/* TCP header flags.		*/
-
-	/* NOTE: These must match up to the flags byte in a
-	 *       real TCP header.
-	 */
-#define TCPCB_FLAG_FIN		0x01
-#define TCPCB_FLAG_SYN		0x02
-#define TCPCB_FLAG_RST		0x04
-#define TCPCB_FLAG_PSH		0x08
-#define TCPCB_FLAG_ACK		0x10
-#define TCPCB_FLAG_URG		0x20
-#define TCPCB_FLAG_ECE		0x40
-#define TCPCB_FLAG_CWR		0x80
-
 	__u8		sacked;		/* State flags for SACK/FACK.	*/
 #define TCPCB_SACKED_ACKED	0x01	/* SKB ACK'd by a SACK block	*/
 #define TCPCB_SACKED_RETRANS	0x02	/* SKB retransmitted		*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 49d0d2b..ada200d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -511,7 +511,7 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
-	TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
+	TCP_SKB_CB(skb)->flags |= TH_PUSH;
 	tp->pushed_seq = tp->write_seq;
 }
 
@@ -527,7 +527,7 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 
 	skb->csum    = 0;
 	tcb->seq     = tcb->end_seq = tp->write_seq;
-	tcb->flags   = TCPCB_FLAG_ACK;
+	tcb->flags   = TH_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
@@ -815,7 +815,7 @@ new_segment:
 		skb_shinfo(skb)->gso_segs = 0;
 
 		if (!copied)
-			TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
+			TCP_SKB_CB(skb)->flags &= ~TH_PUSH;
 
 		copied += copy;
 		poffset += copy;
@@ -1061,7 +1061,7 @@ new_segment:
 			}
 
 			if (!copied)
-				TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
+				TCP_SKB_CB(skb)->flags &= ~TH_PUSH;
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 548d575..fbadd66 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3286,7 +3286,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		 * connection startup slow start one packet too
 		 * quickly.  This is severely frowned upon behavior.
 		 */
-		if (!(scb->flags & TCPCB_FLAG_SYN)) {
+		if (!(scb->flags & TH_SYN)) {
 			flag |= FLAG_DATA_ACKED;
 		} else {
 			flag |= FLAG_SYN_ACKED;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b4ed957..011199a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -294,9 +294,9 @@ static u16 tcp_select_window(struct sock *sk)
 /* Packet ECN state for a SYN-ACK */
 static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_buff *skb)
 {
-	TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_CWR;
+	TCP_SKB_CB(skb)->flags &= ~TH_CWR;
 	if (!(tp->ecn_flags & TCP_ECN_OK))
-		TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_ECE;
+		TCP_SKB_CB(skb)->flags &= ~TH_ECE;
 }
 
 /* Packet ECN state for a SYN.  */
@@ -306,7 +306,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 
 	tp->ecn_flags = 0;
 	if (sysctl_tcp_ecn == 1) {
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE | TCPCB_FLAG_CWR;
+		TCP_SKB_CB(skb)->flags |= TH_ECE | TH_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
 }
@@ -361,7 +361,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	skb_shinfo(skb)->gso_type = 0;
 
 	TCP_SKB_CB(skb)->seq = seq;
-	if (flags & (TCPCB_FLAG_SYN | TCPCB_FLAG_FIN))
+	if (flags & (TH_SYN | TH_FIN))
 		seq++;
 	TCP_SKB_CB(skb)->end_seq = seq;
 }
@@ -820,7 +820,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-	if (unlikely(tcb->flags & TCPCB_FLAG_SYN))
+	if (unlikely(tcb->flags & TH_SYN))
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
 	else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
@@ -843,7 +843,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	*(((__be16 *)th) + 6)	= htons(((tcp_header_size >> 2) << 12) |
 					tcb->flags);
 
-	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
+	if (unlikely(tcb->flags & TH_SYN)) {
 		/* RFC1323: The window in SYN & SYN/ACK segments
 		 * is never scaled.
 		 */
@@ -866,7 +866,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
-	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
+	if (likely((tcb->flags & TH_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -880,7 +880,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	icsk->icsk_af_ops->send_check(sk, skb);
 
-	if (likely(tcb->flags & TCPCB_FLAG_ACK))
+	if (likely(tcb->flags & TH_ACK))
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
 
 	if (skb->len != tcp_header_size)
@@ -1023,7 +1023,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 
 	/* PSH and FIN should only be set in the second packet. */
 	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_FIN | TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags = flags & ~(TH_FIN | TH_PUSH);
 	TCP_SKB_CB(buff)->flags = flags;
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
 
@@ -1328,8 +1328,7 @@ static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp,
 	u32 in_flight, cwnd;
 
 	/* Don't be strict about the congestion window for the final FIN.  */
-	if ((TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
-	    tcp_skb_pcount(skb) == 1)
+	if ((TCP_SKB_CB(skb)->flags & TH_FIN) && tcp_skb_pcount(skb) == 1)
 		return 1;
 
 	in_flight = tcp_packets_in_flight(tp);
@@ -1398,7 +1397,7 @@ static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff *skb,
 	 * Nagle can be ignored during F-RTO too (see RFC4138).
 	 */
 	if (tcp_urg_mode(tp) || (tp->frto_counter == 2) ||
-	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
+	    (TCP_SKB_CB(skb)->flags & TH_FIN))
 		return 1;
 
 	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
@@ -1487,7 +1486,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* PSH and FIN should only be set in the second packet. */
 	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_FIN | TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags = flags & ~(TH_FIN | TH_PUSH);
 	TCP_SKB_CB(buff)->flags = flags;
 
 	/* This packet was never sent out yet, so no SACK bits. */
@@ -1518,7 +1517,7 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
 
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
+	if (TCP_SKB_CB(skb)->flags & TH_FIN)
 		goto send_now;
 
 	if (icsk->icsk_ca_state != TCP_CA_Open)
@@ -1644,7 +1643,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
-	TCP_SKB_CB(nskb)->flags = TCPCB_FLAG_ACK;
+	TCP_SKB_CB(nskb)->flags = TH_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
 	nskb->csum = 0;
 	nskb->ip_summed = skb->ip_summed;
@@ -1669,7 +1668,7 @@ static int tcp_mtu_probe(struct sock *sk)
 			sk_wmem_free_skb(sk, skb);
 		} else {
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
-						   ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+						   ~(TH_FIN|TH_PUSH);
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
 				if (skb->ip_summed != CHECKSUM_PARTIAL)
@@ -2020,7 +2019,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 
 	if (!sysctl_tcp_retrans_collapse)
 		return;
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
+	if (TCP_SKB_CB(skb)->flags & TH_SYN)
 		return;
 
 	tcp_for_write_queue_from_safe(skb, tmp, sk) {
@@ -2112,7 +2111,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * since it is cheap to do so and saves bytes on the network.
 	 */
 	if (skb->len > 0 &&
-	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
+	    (TCP_SKB_CB(skb)->flags & TH_FIN) &&
 	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			/* Reuse, even though it does some unnecessary work */
@@ -2301,7 +2300,7 @@ void tcp_send_fin(struct sock *sk)
 	mss_now = tcp_current_mss(sk);
 
 	if (tcp_send_head(sk) != NULL) {
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
+		TCP_SKB_CB(skb)->flags |= TH_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
 	} else {
@@ -2317,8 +2316,7 @@ void tcp_send_fin(struct sock *sk)
 		/* Reserve space for headers and prepare control bits. */
 		skb_reserve(skb, MAX_TCP_HEADER);
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
-		tcp_init_nondata_skb(skb, tp->write_seq,
-				     TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
+		tcp_init_nondata_skb(skb, tp->write_seq, TH_ACK | TH_FIN);
 		tcp_queue_skb(sk, skb);
 	}
 	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
@@ -2342,8 +2340,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, MAX_TCP_HEADER);
-	tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
-			     TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
+	tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk), TH_ACK | TH_RST);
 	/* Send it off. */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
@@ -2363,11 +2360,11 @@ int tcp_send_synack(struct sock *sk)
 	struct sk_buff *skb;
 
 	skb = tcp_write_queue_head(sk);
-	if (skb == NULL || !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)) {
+	if (skb == NULL || !(TCP_SKB_CB(skb)->flags & TH_SYN)) {
 		printk(KERN_DEBUG "tcp_send_synack: wrong queue state\n");
 		return -EFAULT;
 	}
-	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_ACK)) {
+	if (!(TCP_SKB_CB(skb)->flags & TH_ACK)) {
 		if (skb_cloned(skb)) {
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 			if (nskb == NULL)
@@ -2381,7 +2378,7 @@ int tcp_send_synack(struct sock *sk)
 			skb = nskb;
 		}
 
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ACK;
+		TCP_SKB_CB(skb)->flags |= TH_ACK;
 		TCP_ECN_send_synack(tcp_sk(sk), skb);
 	}
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
@@ -2459,8 +2456,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)
 	 */
-	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
-			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn, TH_SYN | TH_ACK);
 
 	if (OPTION_COOKIE_EXTENSION & opts.options) {
 		if (s_data_desired) {
@@ -2592,7 +2588,7 @@ int tcp_connect(struct sock *sk)
 	skb_reserve(buff, MAX_TCP_HEADER);
 
 	tp->snd_nxt = tp->write_seq;
-	tcp_init_nondata_skb(buff, tp->write_seq++, TCPCB_FLAG_SYN);
+	tcp_init_nondata_skb(buff, tp->write_seq++, TH_SYN);
 	TCP_ECN_send_syn(sk, buff);
 
 	/* Send it off. */
@@ -2698,7 +2694,7 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(buff, MAX_TCP_HEADER);
-	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPCB_FLAG_ACK);
+	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TH_ACK);
 
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
@@ -2732,7 +2728,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 * end to send an ack.  Don't queue or clone SKB, just
 	 * send it.
 	 */
-	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPCB_FLAG_ACK);
+	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TH_ACK);
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
@@ -2762,13 +2758,13 @@ int tcp_write_wakeup(struct sock *sk)
 		if (seg_size < TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq ||
 		    skb->len > mss) {
 			seg_size = min(seg_size, mss);
-			TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
+			TCP_SKB_CB(skb)->flags |= TH_PUSH;
 			if (tcp_fragment(sk, skb, seg_size, mss))
 				return -1;
 		} else if (!tcp_skb_pcount(skb))
 			tcp_set_skb_tso_segs(sk, skb, mss);
 
-		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
+		TCP_SKB_CB(skb)->flags |= TH_PUSH;
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 		if (!err)
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 9dd8cd4..8c65d62 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -736,15 +736,6 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	return res;
 }
 
-#define	TH_FIN	0x01
-#define	TH_SYN	0x02
-#define	TH_RST	0x04
-#define	TH_PUSH	0x08
-#define	TH_ACK	0x10
-#define	TH_URG	0x20
-#define	TH_ECE	0x40
-#define	TH_CWR	0x80
-
 /* table of valid flag combinations - PUSH, ECE and CWR are always valid */
 static const u8 tcp_valid_flags[(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG) + 1] =
 {
@@ -803,7 +794,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* Check TCP flags. */
-	tcpflags = (((u_int8_t *)th)[13] & ~(TH_ECE|TH_CWR|TH_PUSH));
+	tcpflags = (tcp_flag_byte(th) & ~(TH_ECE|TH_CWR|TH_PUSH));
 	if (!tcp_valid_flags[tcpflags]) {
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 1841388..5bd203b 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -220,8 +220,6 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 }
 #endif
 
-#define TH_SYN 0x02
-
 /* Must specify -p tcp --syn */
 static inline bool find_syn_match(const struct xt_entry_match *m)
 {
