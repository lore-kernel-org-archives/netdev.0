From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V2 net-next] tcp: add const qualifiers where possible
Date: Fri, 21 Oct 2011 10:58:13 +0200
Message-ID: <1319187493.2338.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1319179993.2854.63.camel@edumazet-laptop>
	 <20111021.025549.113655582134326444.davem@redhat.com>
	 <20111021.033648.1029307040209750463.davem@davemloft.net>
	 <1319185263.2338.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46557 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab1JUI6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 04:58:17 -0400
Received: by wyg36 with SMTP id 36so3727271wyg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 01:58:16 -0700 (PDT)
In-Reply-To: <1319185263.2338.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding const qualifiers to pointers can ease code review, and spot some
bugs. It might allow compiler to optimize code further.

For example, is it legal to temporary write a null cksum into tcphdr
in tcp_md5_hash_header() ? I am afraid a sniffer could catch the
temporary null value...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: no need to change __sk_dst_get() prototype...

 include/net/secure_seq.h |    2 
 include/net/tcp.h        |   43 +++++++-------
 net/core/secure_seq.c    |    2 
 net/ipv4/syncookies.c    |    2 
 net/ipv4/tcp.c           |   18 +++---
 net/ipv4/tcp_input.c     |  110 ++++++++++++++++++-------------------
 net/ipv4/tcp_ipv4.c      |   26 ++++----
 net/ipv4/tcp_minisocks.c |    4 -
 net/ipv4/tcp_output.c    |   72 ++++++++++++------------
 net/ipv6/syncookies.c    |    6 +-
 net/ipv6/tcp_ipv6.c      |   27 ++++-----
 11 files changed, 160 insertions(+), 152 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index d97f689..c2e542b 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -10,7 +10,7 @@ extern u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
 				      __be16 dport);
 extern __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 					__be16 sport, __be16 dport);
-extern __u32 secure_tcpv6_sequence_number(__be32 *saddr, __be32 *daddr,
+extern __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 					  __be16 sport, __be16 dport);
 extern u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				       __be16 sport, __be16 dport);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0113d30..3edef0b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -327,9 +327,9 @@ extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-				 struct tcphdr *th, unsigned len);
+				 const struct tcphdr *th, unsigned int len);
 extern int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			       struct tcphdr *th, unsigned len);
+			       const struct tcphdr *th, unsigned int len);
 extern void tcp_rcv_space_adjust(struct sock *sk);
 extern void tcp_cleanup_rbuf(struct sock *sk, int copied);
 extern int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
@@ -401,10 +401,10 @@ extern void tcp_set_keepalive(struct sock *sk, int val);
 extern void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
 extern int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t len, int nonblock, int flags, int *addr_len);
-extern void tcp_parse_options(struct sk_buff *skb,
-			      struct tcp_options_received *opt_rx, u8 **hvpp,
+extern void tcp_parse_options(const struct sk_buff *skb,
+			      struct tcp_options_received *opt_rx, const u8 **hvpp,
 			      int estab);
-extern u8 *tcp_parse_md5sig_option(struct tcphdr *th);
+extern const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
 
 /*
  *	TCP v4 functions exported for the inet6 API
@@ -450,7 +450,7 @@ extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
-extern __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb,
+extern __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
 				     __u16 *mss);
 #else
 static inline __u32 cookie_v6_init_sequence(struct sock *sk,
@@ -522,7 +522,7 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 }
 
 /* tcp.c */
-extern void tcp_get_info(struct sock *, struct tcp_info *);
+extern void tcp_get_info(const struct sock *, struct tcp_info *);
 
 /* Read 'sendfile()'-style from a TCP socket */
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
@@ -532,8 +532,8 @@ extern int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 
 extern void tcp_initialize_rcv_mss(struct sock *sk);
 
-extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
-extern int tcp_mss_to_mtu(struct sock *sk, int mss);
+extern int tcp_mtu_to_mss(const struct sock *sk, int pmtu);
+extern int tcp_mss_to_mtu(const struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
 extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);
 
@@ -574,7 +574,7 @@ static inline void tcp_fast_path_check(struct sock *sk)
 /* Compute the actual rto_min value */
 static inline u32 tcp_rto_min(struct sock *sk)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 	u32 rto_min = TCP_RTO_MIN;
 
 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
@@ -820,6 +820,7 @@ static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
 static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
+
 	if ((1 << inet_csk(sk)->icsk_ca_state) & (TCPF_CA_CWR | TCPF_CA_Recovery))
 		return tp->snd_ssthresh;
 	else
@@ -832,7 +833,7 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
-extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
+extern __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst);
 
 /* Slow start with delack produces 3 packets of burst, so that
  * it is safe "de facto".  This will be the default - same as
@@ -861,7 +862,7 @@ static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
 
 static inline void tcp_check_probe_timer(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	if (!tp->packets_out && !icsk->icsk_pending)
@@ -1209,10 +1210,10 @@ extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
 extern void tcp_put_md5sig_pool(void);
 
 extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
-extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
+extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
 				 unsigned header_len);
 extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
-			    struct tcp_md5sig_key *key);
+			    const struct tcp_md5sig_key *key);
 
 /* write queue abstraction */
 static inline void tcp_write_queue_purge(struct sock *sk)
@@ -1225,22 +1226,24 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 	tcp_clear_all_retrans_hints(tcp_sk(sk));
 }
 
-static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
+static inline struct sk_buff *tcp_write_queue_head(const struct sock *sk)
 {
 	return skb_peek(&sk->sk_write_queue);
 }
 
-static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
+static inline struct sk_buff *tcp_write_queue_tail(const struct sock *sk)
 {
 	return skb_peek_tail(&sk->sk_write_queue);
 }
 
-static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_buff *skb)
+static inline struct sk_buff *tcp_write_queue_next(const struct sock *sk,
+						   const struct sk_buff *skb)
 {
 	return skb_queue_next(&sk->sk_write_queue, skb);
 }
 
-static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
+static inline struct sk_buff *tcp_write_queue_prev(const struct sock *sk,
+						   const struct sk_buff *skb)
 {
 	return skb_queue_prev(&sk->sk_write_queue, skb);
 }
@@ -1254,7 +1257,7 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
-static inline struct sk_buff *tcp_send_head(struct sock *sk)
+static inline struct sk_buff *tcp_send_head(const struct sock *sk)
 {
 	return sk->sk_send_head;
 }
@@ -1265,7 +1268,7 @@ static inline bool tcp_skb_is_last(const struct sock *sk,
 	return skb_queue_is_last(&sk->sk_write_queue, skb);
 }
 
-static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
+static inline void tcp_advance_send_head(struct sock *sk, const struct sk_buff *skb)
 {
 	if (tcp_skb_is_last(sk, skb))
 		sk->sk_send_head = NULL;
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 45329d7..025233d 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -35,7 +35,7 @@ static u32 seq_scale(u32 seq)
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-__u32 secure_tcpv6_sequence_number(__be32 *saddr, __be32 *daddr,
+__u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				   __be16 sport, __be16 dport)
 {
 	u32 secret[MD5_MESSAGE_BYTES / 4];
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 3bc5c8f..d7b89b1 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -265,7 +265,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
 	struct tcp_options_received tcp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
 	struct tcp_sock *tp = tcp_sk(sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 132be08..704adad 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -374,7 +374,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	unsigned int mask;
 	struct sock *sk = sock->sk;
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	if (sk->sk_state == TCP_LISTEN)
@@ -528,7 +528,7 @@ static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 	tp->pushed_seq = tp->write_seq;
 }
 
-static inline int forced_push(struct tcp_sock *tp)
+static inline int forced_push(const struct tcp_sock *tp)
 {
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
@@ -891,9 +891,9 @@ EXPORT_SYMBOL(tcp_sendpage);
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
 
-static inline int select_size(struct sock *sk, int sg)
+static inline int select_size(const struct sock *sk, int sg)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	int tmp = tp->mss_cache;
 
 	if (sg) {
@@ -2408,7 +2408,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 int tcp_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		   unsigned int optlen)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	if (level != SOL_TCP)
 		return icsk->icsk_af_ops->setsockopt(sk, level, optname,
@@ -2430,9 +2430,9 @@ EXPORT_SYMBOL(compat_tcp_setsockopt);
 #endif
 
 /* Return information about state of tcp endpoint in API format. */
-void tcp_get_info(struct sock *sk, struct tcp_info *info)
+void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
 
@@ -3010,7 +3010,7 @@ int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 EXPORT_SYMBOL(tcp_md5_hash_header);
 
 int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
-			  struct sk_buff *skb, unsigned header_len)
+			  const struct sk_buff *skb, unsigned int header_len)
 {
 	struct scatterlist sg;
 	const struct tcphdr *tp = tcp_hdr(skb);
@@ -3043,7 +3043,7 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 }
 EXPORT_SYMBOL(tcp_md5_hash_skb_data);
 
-int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, struct tcp_md5sig_key *key)
+int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, const struct tcp_md5sig_key *key)
 {
 	struct scatterlist sg;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 69a90b8..52b5c2d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -206,7 +206,7 @@ static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
 		tp->ecn_flags |= TCP_ECN_QUEUE_CWR;
 }
 
-static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, struct sk_buff *skb)
+static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, const struct sk_buff *skb)
 {
 	if (tcp_hdr(skb)->cwr)
 		tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
@@ -239,19 +239,19 @@ static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *s
 	}
 }
 
-static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, struct tcphdr *th)
+static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, struct tcphdr *th)
+static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || !th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcphdr *th)
+static inline int TCP_ECN_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if (th->ece && !th->syn && (tp->ecn_flags & TCP_ECN_OK))
 		return 1;
@@ -315,7 +315,7 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 	return 0;
 }
 
-static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
+static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -429,7 +429,7 @@ static void tcp_clamp_window(struct sock *sk)
  */
 void tcp_initialize_rcv_mss(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int hint = min_t(unsigned int, tp->advmss, tp->mss_cache);
 
 	hint = min(hint, tp->rcv_wnd / 2);
@@ -824,7 +824,7 @@ void tcp_update_metrics(struct sock *sk)
 	}
 }
 
-__u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
+__u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst)
 {
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
@@ -1216,7 +1216,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		tp->lost_retrans_low = new_low_seq;
 }
 
-static int tcp_check_dsack(struct sock *sk, struct sk_buff *ack_skb,
+static int tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
 {
@@ -1310,7 +1310,7 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 	return in_sack;
 }
 
-static u8 tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
+static u8 tcp_sacktag_one(const struct sk_buff *skb, struct sock *sk,
 			  struct tcp_sacktag_state *state,
 			  int dup_sack, int pcount)
 {
@@ -1465,13 +1465,13 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 /* I wish gso_size would have a bit more sane initialization than
  * something-or-zero which complicates things
  */
-static int tcp_skb_seglen(struct sk_buff *skb)
+static int tcp_skb_seglen(const struct sk_buff *skb)
 {
 	return tcp_skb_pcount(skb) == 1 ? skb->len : tcp_skb_mss(skb);
 }
 
 /* Shifting pages past head area doesn't work */
-static int skb_can_shift(struct sk_buff *skb)
+static int skb_can_shift(const struct sk_buff *skb)
 {
 	return !skb_headlen(skb) && skb_is_nonlinear(skb);
 }
@@ -1720,19 +1720,19 @@ static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
 	return skb;
 }
 
-static int tcp_sack_cache_ok(struct tcp_sock *tp, struct tcp_sack_block *cache)
+static int tcp_sack_cache_ok(const struct tcp_sock *tp, const struct tcp_sack_block *cache)
 {
 	return cache < tp->recv_sack_cache + ARRAY_SIZE(tp->recv_sack_cache);
 }
 
 static int
-tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
+tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 			u32 prior_snd_una)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned char *ptr = (skb_transport_header(ack_skb) +
-			      TCP_SKB_CB(ack_skb)->sacked);
+	const unsigned char *ptr = (skb_transport_header(ack_skb) +
+				    TCP_SKB_CB(ack_skb)->sacked);
 	struct tcp_sack_block_wire *sp_wire = (struct tcp_sack_block_wire *)(ptr+2);
 	struct tcp_sack_block sp[TCP_NUM_SACKS];
 	struct tcp_sack_block *cache;
@@ -2296,7 +2296,7 @@ static int tcp_check_sack_reneging(struct sock *sk, int flag)
 	return 0;
 }
 
-static inline int tcp_fackets_out(struct tcp_sock *tp)
+static inline int tcp_fackets_out(const struct tcp_sock *tp)
 {
 	return tcp_is_reno(tp) ? tp->sacked_out + 1 : tp->fackets_out;
 }
@@ -2316,19 +2316,20 @@ static inline int tcp_fackets_out(struct tcp_sock *tp)
  * they differ. Since neither occurs due to loss, TCP should really
  * ignore them.
  */
-static inline int tcp_dupack_heuristics(struct tcp_sock *tp)
+static inline int tcp_dupack_heuristics(const struct tcp_sock *tp)
 {
 	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
 }
 
-static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *skb)
+static inline int tcp_skb_timedout(const struct sock *sk,
+				   const struct sk_buff *skb)
 {
 	return tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto;
 }
 
-static inline int tcp_head_timedout(struct sock *sk)
+static inline int tcp_head_timedout(const struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	return tp->packets_out &&
 	       tcp_skb_timedout(sk, tcp_write_queue_head(sk));
@@ -2639,7 +2640,7 @@ static void tcp_cwnd_down(struct sock *sk, int flag)
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
-static inline int tcp_packet_delayed(struct tcp_sock *tp)
+static inline int tcp_packet_delayed(const struct tcp_sock *tp)
 {
 	return !tp->retrans_stamp ||
 		(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
@@ -2700,7 +2701,7 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static inline int tcp_may_undo(struct tcp_sock *tp)
+static inline int tcp_may_undo(const struct tcp_sock *tp)
 {
 	return tp->undo_marker && (!tp->undo_retrans || tcp_packet_delayed(tp));
 }
@@ -2764,9 +2765,9 @@ static void tcp_try_undo_dsack(struct sock *sk)
  * that successive retransmissions of a segment must not advance
  * retrans_stamp under any conditions.
  */
-static int tcp_any_retrans_done(struct sock *sk)
+static int tcp_any_retrans_done(const struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	if (tp->retrans_out)
@@ -3245,7 +3246,7 @@ static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
  */
 static void tcp_rearm_rto(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
@@ -3497,7 +3498,7 @@ static inline int tcp_may_update_window(const struct tcp_sock *tp,
  * Window update algorithm, described in RFC793/RFC1122 (used in linux-2.2
  * and in FreeBSD. NetBSD's one is even worse.) is wrong.
  */
-static int tcp_ack_update_window(struct sock *sk, struct sk_buff *skb, u32 ack,
+static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32 ack,
 				 u32 ack_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -3673,7 +3674,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 }
 
 /* This routine deals with incoming acks, but not outgoing ones. */
-static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
+static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -3810,14 +3811,14 @@ old_ack:
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
-void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       u8 **hvpp, int estab)
+void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *opt_rx,
+		       const u8 **hvpp, int estab)
 {
-	unsigned char *ptr;
-	struct tcphdr *th = tcp_hdr(skb);
+	const unsigned char *ptr;
+	const struct tcphdr *th = tcp_hdr(skb);
 	int length = (th->doff * 4) - sizeof(struct tcphdr);
 
-	ptr = (unsigned char *)(th + 1);
+	ptr = (const unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
 
 	while (length > 0) {
@@ -3928,9 +3929,9 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 }
 EXPORT_SYMBOL(tcp_parse_options);
 
-static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
+static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr *th)
 {
-	__be32 *ptr = (__be32 *)(th + 1);
+	const __be32 *ptr = (const __be32 *)(th + 1);
 
 	if (*ptr == htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
 			  | (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)) {
@@ -3947,8 +3948,9 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
  */
-static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
-				  struct tcp_sock *tp, u8 **hvpp)
+static int tcp_fast_parse_options(const struct sk_buff *skb,
+				  const struct tcphdr *th,
+				  struct tcp_sock *tp, const u8 **hvpp)
 {
 	/* In the spirit of fast parsing, compare doff directly to constant
 	 * values.  Because equality is used, short doff can be ignored here.
@@ -3969,10 +3971,10 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 /*
  * Parse MD5 Signature option
  */
-u8 *tcp_parse_md5sig_option(struct tcphdr *th)
+const u8 *tcp_parse_md5sig_option(const struct tcphdr *th)
 {
-	int length = (th->doff << 2) - sizeof (*th);
-	u8 *ptr = (u8*)(th + 1);
+	int length = (th->doff << 2) - sizeof(*th);
+	const u8 *ptr = (const u8 *)(th + 1);
 
 	/* If the TCP option is too short, we can short cut */
 	if (length < TCPOLEN_MD5SIG)
@@ -4049,8 +4051,8 @@ static inline void tcp_replace_ts_recent(struct tcp_sock *tp, u32 seq)
 
 static int tcp_disordered_ack(const struct sock *sk, const struct sk_buff *skb)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 
@@ -4089,7 +4091,7 @@ static inline int tcp_paws_discard(const struct sock *sk,
  * (borrowed from freebsd)
  */
 
-static inline int tcp_sequence(struct tcp_sock *tp, u32 seq, u32 end_seq)
+static inline int tcp_sequence(const struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	return	!before(end_seq, tp->rcv_wup) &&
 		!after(seq, tp->rcv_nxt + tcp_receive_window(tp));
@@ -4246,7 +4248,7 @@ static void tcp_dsack_extend(struct sock *sk, u32 seq, u32 end_seq)
 		tcp_sack_extend(tp->duplicate_sack, seq, end_seq);
 }
 
-static void tcp_send_dupack(struct sock *sk, struct sk_buff *skb)
+static void tcp_send_dupack(struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -4433,7 +4435,7 @@ static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
 
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int eaten = -1;
 
@@ -4917,9 +4919,9 @@ void tcp_cwnd_application_limited(struct sock *sk)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static int tcp_should_expand_sndbuf(struct sock *sk)
+static int tcp_should_expand_sndbuf(const struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	/* If the user specified a specific send buffer setting, do
 	 * not modify it.
@@ -5028,7 +5030,7 @@ static inline void tcp_ack_snd_check(struct sock *sk)
  *	either form (or just set the sysctl tcp_stdurg).
  */
 
-static void tcp_check_urg(struct sock *sk, struct tcphdr *th)
+static void tcp_check_urg(struct sock *sk, const struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 ptr = ntohs(th->urg_ptr);
@@ -5094,7 +5096,7 @@ static void tcp_check_urg(struct sock *sk, struct tcphdr *th)
 }
 
 /* This is the 'fast' part of urgent handling. */
-static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
+static void tcp_urg(struct sock *sk, struct sk_buff *skb, const struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -5215,9 +5217,9 @@ out:
  * play significant role here.
  */
 static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
-			      struct tcphdr *th, int syn_inerr)
+			      const struct tcphdr *th, int syn_inerr)
 {
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* RFC1323: H1. Apply PAWS check first. */
@@ -5298,7 +5300,7 @@ discard:
  *	tcp_data_queue when everything is OK.
  */
 int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			struct tcphdr *th, unsigned len)
+			const struct tcphdr *th, unsigned int len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int res;
@@ -5509,9 +5511,9 @@ discard:
 EXPORT_SYMBOL(tcp_rcv_established);
 
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
-					 struct tcphdr *th, unsigned len)
+					 const struct tcphdr *th, unsigned int len)
 {
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
@@ -5786,7 +5788,7 @@ reset_and_undo:
  */
 
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  struct tcphdr *th, unsigned len)
+			  const struct tcphdr *th, unsigned int len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 48da7cc..955c925 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -104,7 +104,7 @@ struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
 struct inet_hashinfo tcp_hashinfo;
 EXPORT_SYMBOL(tcp_hashinfo);
 
-static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
+static inline __u32 tcp_v4_init_sequence(const struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
 					  ip_hdr(skb)->saddr,
@@ -552,7 +552,7 @@ static void __tcp_v4_send_check(struct sk_buff *skb,
 /* This routine computes an IPv4 TCP checksum. */
 void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_sock *inet = inet_sk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
 
 	__tcp_v4_send_check(skb, inet->inet_saddr, inet->inet_daddr);
 }
@@ -590,7 +590,7 @@ int tcp_v4_gso_send_check(struct sk_buff *skb)
 
 static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	struct {
 		struct tcphdr th;
 #ifdef CONFIG_TCP_MD5SIG
@@ -668,7 +668,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    struct tcp_md5sig_key *key,
 			    int reply_flags)
 {
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	struct {
 		struct tcphdr th;
 		__be32 opt[(TCPOLEN_TSTAMP_ALIGNED >> 2)
@@ -1182,10 +1182,10 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	 * o MD5 hash and we're not expecting one.
 	 * o MD5 hash and its wrong.
 	 */
-	__u8 *hash_location = NULL;
+	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
 	const struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	int genhash;
 	unsigned char newhash[16];
 
@@ -1248,7 +1248,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1645,7 +1645,7 @@ EXPORT_SYMBOL(tcp_v4_do_rcv);
 int tcp_v4_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
-	struct tcphdr *th;
+	const struct tcphdr *th;
 	struct sock *sk;
 	int ret;
 	struct net *net = dev_net(skb->dev);
@@ -1809,7 +1809,7 @@ EXPORT_SYMBOL(tcp_v4_get_peer);
 
 void *tcp_v4_tw_get_peer(struct sock *sk)
 {
-	struct inet_timewait_sock *tw = inet_twsk(sk);
+	const struct inet_timewait_sock *tw = inet_twsk(sk);
 
 	return inet_getpeer_v4(tw->tw_daddr, 1);
 }
@@ -2381,7 +2381,7 @@ void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 }
 EXPORT_SYMBOL(tcp_proc_unregister);
 
-static void get_openreq4(struct sock *sk, struct request_sock *req,
+static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 			 struct seq_file *f, int i, int uid, int *len)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
@@ -2411,9 +2411,9 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 {
 	int timer_active;
 	unsigned long timer_expires;
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct inet_sock *inet = inet_sk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
 	__be32 dest = inet->inet_daddr;
 	__be32 src = inet->inet_rcv_saddr;
 	__u16 destp = ntohs(inet->inet_dport);
@@ -2462,7 +2462,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		len);
 }
 
-static void get_timewait4_sock(struct inet_timewait_sock *tw,
+static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 			       struct seq_file *f, int i, int *len)
 {
 	__be32 dest, src;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d2fe4e0..b767a95 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -141,7 +141,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			   const struct tcphdr *th)
 {
 	struct tcp_options_received tmp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	int paws_reject = 0;
 
@@ -566,7 +566,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock **prev)
 {
 	struct tcp_options_received tmp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct sock *child;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ed96c54..980b98f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,7 +65,7 @@ EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
 
 /* Account for new data that has been sent to the network. */
-static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
+static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int prior_packets = tp->packets_out;
@@ -89,9 +89,9 @@ static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
  * Anything in between SND.UNA...SND.UNA+SND.WND also can be already
  * invalid. OK, let's make this for now:
  */
-static inline __u32 tcp_acceptable_seq(struct sock *sk)
+static inline __u32 tcp_acceptable_seq(const struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!before(tcp_wnd_end(tp), tp->snd_nxt))
 		return tp->snd_nxt;
@@ -116,7 +116,7 @@ static inline __u32 tcp_acceptable_seq(struct sock *sk)
 static __u16 tcp_advertise_mss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 	int mss = tp->advmss;
 
 	if (dst) {
@@ -133,7 +133,7 @@ static __u16 tcp_advertise_mss(struct sock *sk)
 
 /* RFC2861. Reset CWND after idle period longer RTO to "restart window".
  * This is the first part of cwnd validation mechanism. */
-static void tcp_cwnd_restart(struct sock *sk, struct dst_entry *dst)
+static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	s32 delta = tcp_time_stamp - tp->lsndtime;
@@ -154,7 +154,7 @@ static void tcp_cwnd_restart(struct sock *sk, struct dst_entry *dst)
 
 /* Congestion state accounting after a packet has been sent. */
 static void tcp_event_data_sent(struct tcp_sock *tp,
-				struct sk_buff *skb, struct sock *sk)
+				struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
@@ -295,7 +295,7 @@ static u16 tcp_select_window(struct sock *sk)
 }
 
 /* Packet ECN state for a SYN-ACK */
-static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_buff *skb)
+static inline void TCP_ECN_send_synack(const struct tcp_sock *tp, struct sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_CWR;
 	if (!(tp->ecn_flags & TCP_ECN_OK))
@@ -315,7 +315,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 }
 
 static __inline__ void
-TCP_ECN_make_synack(struct request_sock *req, struct tcphdr *th)
+TCP_ECN_make_synack(const struct request_sock *req, struct tcphdr *th)
 {
 	if (inet_rsk(req)->ecn_ok)
 		th->ece = 1;
@@ -565,7 +565,8 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
  */
 static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
-				struct tcp_md5sig_key **md5) {
+				struct tcp_md5sig_key **md5)
+{
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	unsigned remaining = MAX_TCP_OPTION_SPACE;
@@ -743,7 +744,8 @@ static unsigned tcp_synack_options(struct sock *sk,
  */
 static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 					struct tcp_out_options *opts,
-					struct tcp_md5sig_key **md5) {
+					struct tcp_md5sig_key **md5)
+{
 	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned size = 0;
@@ -893,7 +895,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
 
 	if (skb->len != tcp_header_size)
-		tcp_event_data_sent(tp, skb, sk);
+		tcp_event_data_sent(tp, sk);
 
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
@@ -926,7 +928,7 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Initialize TSO segments for a packet. */
-static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
+static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
 	if (skb->len <= mss_now || !sk_can_gso(sk) ||
@@ -947,7 +949,7 @@ static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
 /* When a modification to fackets out becomes necessary, we need to check
  * skb is counted to fackets_out or not.
  */
-static void tcp_adjust_fackets_out(struct sock *sk, struct sk_buff *skb,
+static void tcp_adjust_fackets_out(struct sock *sk, const struct sk_buff *skb,
 				   int decr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -962,7 +964,7 @@ static void tcp_adjust_fackets_out(struct sock *sk, struct sk_buff *skb,
 /* Pcount in the middle of the write queue got changed, we need to do various
  * tweaks to fix counters
  */
-static void tcp_adjust_pcount(struct sock *sk, struct sk_buff *skb, int decr)
+static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int decr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -1146,10 +1148,10 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 }
 
 /* Calculate MSS. Not accounting for SACKs here.  */
-int tcp_mtu_to_mss(struct sock *sk, int pmtu)
+int tcp_mtu_to_mss(const struct sock *sk, int pmtu)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 	int mss_now;
 
 	/* Calculate base mss without TCP options:
@@ -1175,10 +1177,10 @@ int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 }
 
 /* Inverse of above */
-int tcp_mss_to_mtu(struct sock *sk, int mss)
+int tcp_mss_to_mtu(const struct sock *sk, int mss)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 	int mtu;
 
 	mtu = mss +
@@ -1252,8 +1254,8 @@ EXPORT_SYMBOL(tcp_sync_mss);
  */
 unsigned int tcp_current_mss(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 	u32 mss_now;
 	unsigned header_len;
 	struct tcp_out_options opts;
@@ -1313,10 +1315,10 @@ static void tcp_cwnd_validate(struct sock *sk)
  * modulo only when the receiver window alone is the limiting factor or
  * when we would be allowed to send the split-due-to-Nagle skb fully.
  */
-static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
+static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_buff *skb,
 					unsigned int mss_now, unsigned int cwnd)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	u32 needed, window, cwnd_len;
 
 	window = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
@@ -1336,8 +1338,8 @@ static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
 /* Can at least one segment of SKB be sent right now, according to the
  * congestion window rules?  If so, return how many segments are allowed.
  */
-static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp,
-					 struct sk_buff *skb)
+static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
+					 const struct sk_buff *skb)
 {
 	u32 in_flight, cwnd;
 
@@ -1358,7 +1360,7 @@ static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp,
  * This must be invoked the first time we consider transmitting
  * SKB onto the wire.
  */
-static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
+static int tcp_init_tso_segs(const struct sock *sk, struct sk_buff *skb,
 			     unsigned int mss_now)
 {
 	int tso_segs = tcp_skb_pcount(skb);
@@ -1396,7 +1398,7 @@ static inline int tcp_nagle_check(const struct tcp_sock *tp,
 /* Return non-zero if the Nagle test allows this packet to be
  * sent now.
  */
-static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff *skb,
+static inline int tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buff *skb,
 				 unsigned int cur_mss, int nonagle)
 {
 	/* Nagle rule does not apply to frames, which sit in the middle of the
@@ -1422,7 +1424,7 @@ static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff *skb,
 }
 
 /* Does at least the first segment of SKB fit into the send window? */
-static inline int tcp_snd_wnd_test(struct tcp_sock *tp, struct sk_buff *skb,
+static inline int tcp_snd_wnd_test(const struct tcp_sock *tp, const struct sk_buff *skb,
 				   unsigned int cur_mss)
 {
 	u32 end_seq = TCP_SKB_CB(skb)->end_seq;
@@ -1437,10 +1439,10 @@ static inline int tcp_snd_wnd_test(struct tcp_sock *tp, struct sk_buff *skb,
  * should be put on the wire right now.  If so, it returns the number of
  * packets allowed by the congestion window.
  */
-static unsigned int tcp_snd_test(struct sock *sk, struct sk_buff *skb,
+static unsigned int tcp_snd_test(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int cur_mss, int nonagle)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int cwnd_quota;
 
 	tcp_init_tso_segs(sk, skb, cur_mss);
@@ -1458,7 +1460,7 @@ static unsigned int tcp_snd_test(struct sock *sk, struct sk_buff *skb,
 /* Test if sending is allowed right now. */
 int tcp_may_send_now(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = tcp_send_head(sk);
 
 	return skb &&
@@ -2008,7 +2010,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Check if coalescing SKBs is legal. */
-static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
+static int tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 {
 	if (tcp_skb_pcount(skb) > 1)
 		return 0;
@@ -2184,7 +2186,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 static int tcp_can_forward_retransmit(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Forward retransmissions are possible only during Recovery. */
 	if (icsk->icsk_ca_state != TCP_CA_Recovery)
@@ -2550,7 +2552,7 @@ EXPORT_SYMBOL(tcp_make_synack);
 /* Do all connect socket setups that can be done AF independent. */
 static void tcp_connect_init(struct sock *sk)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u8 rcv_wscale;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index ac83896..5a0d664 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -115,7 +115,7 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, const struct in6_addr *saddr,
 		& COOKIEMASK;
 }
 
-__u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16 *mssp)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
@@ -137,7 +137,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 				     jiffies / (HZ * 60), mssind);
 }
 
-static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
+static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	const struct tcphdr *th = tcp_hdr(skb);
@@ -152,7 +152,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tcp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5357902..da2ada8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -114,7 +114,7 @@ static __inline__ __sum16 tcp_v6_check(int len,
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_TCP, base);
 }
 
-static __u32 tcp_v6_init_sequence(struct sk_buff *skb)
+static __u32 tcp_v6_init_sequence(const struct sk_buff *skb)
 {
 	return secure_tcpv6_sequence_number(ipv6_hdr(skb)->daddr.s6_addr32,
 					    ipv6_hdr(skb)->saddr.s6_addr32,
@@ -844,7 +844,7 @@ clear_hash_noput:
 
 static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 {
-	__u8 *hash_location = NULL;
+	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
@@ -980,7 +980,8 @@ static int tcp6_gro_complete(struct sk_buff *skb)
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 ts, struct tcp_md5sig_key *key, int rst)
 {
-	struct tcphdr *th = tcp_hdr(skb), *t1;
+	const struct tcphdr *th = tcp_hdr(skb);
+	struct tcphdr *t1;
 	struct sk_buff *buff;
 	struct flowi6 fl6;
 	struct net *net = dev_net(skb_dst(skb)->dev);
@@ -1070,7 +1071,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 
 static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
 
@@ -1160,7 +1161,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
-	u8 *hash_location;
+	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1688,7 +1689,7 @@ ipv6_pktoptions:
 
 static int tcp_v6_rcv(struct sk_buff *skb)
 {
-	struct tcphdr *th;
+	const struct tcphdr *th;
 	const struct ipv6hdr *hdr;
 	struct sock *sk;
 	int ret;
@@ -1856,8 +1857,8 @@ static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 
 static void *tcp_v6_tw_get_peer(struct sock *sk)
 {
-	struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
-	struct inet_timewait_sock *tw = inet_twsk(sk);
+	const struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
+	const struct inet_timewait_sock *tw = inet_twsk(sk);
 
 	if (tw->tw_family == AF_INET)
 		return tcp_v4_tw_get_peer(sk);
@@ -2012,7 +2013,7 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 #ifdef CONFIG_PROC_FS
 /* Proc filesystem TCPv6 sock list dumping. */
 static void get_openreq6(struct seq_file *seq,
-			 struct sock *sk, struct request_sock *req, int i, int uid)
+			 const struct sock *sk, struct request_sock *req, int i, int uid)
 {
 	int ttd = req->expires - jiffies;
 	const struct in6_addr *src = &inet6_rsk(req)->loc_addr;
@@ -2048,10 +2049,10 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	__u16 destp, srcp;
 	int timer_active;
 	unsigned long timer_expires;
-	struct inet_sock *inet = inet_sk(sp);
-	struct tcp_sock *tp = tcp_sk(sp);
+	const struct inet_sock *inet = inet_sk(sp);
+	const struct tcp_sock *tp = tcp_sk(sp);
 	const struct inet_connection_sock *icsk = inet_csk(sp);
-	struct ipv6_pinfo *np = inet6_sk(sp);
+	const struct ipv6_pinfo *np = inet6_sk(sp);
 
 	dest  = &np->daddr;
 	src   = &np->rcv_saddr;
@@ -2103,7 +2104,7 @@ static void get_timewait6_sock(struct seq_file *seq,
 {
 	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
-	struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
+	const struct inet6_timewait_sock *tw6 = inet6_twsk((struct sock *)tw);
 	int ttd = tw->tw_ttd - jiffies;
 
 	if (ttd < 0)
