From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][TCP] merge tcp_sock with tcp_opt
Date: Tue, 28 Dec 2004 16:39:50 -0200
Message-ID: <41D1A876.9050609@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010100030105070906050706"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010100030105070906050706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Here is the tcp_sock one, please consider pulling from:

bk://kernel.bkbits.net/acme/connection_sock-2.6

	There are some cases where both sock and tcp_sock pointers
are passed to functions, as one can be obtained from the other quite
easily, a following patch will leave those functions receiving only
a struct sock pointer.

Regards,

- Arnaldo

--------------010100030105070906050706
Content-Type: text/plain;
 name="tcp_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_sock.patch"

===================================================================


ChangeSet@1.2195, 2004-12-28 16:22:56-02:00, acme@conectiva.com.br
  [TCP] merge tcp_sock with tcp_opt
  
  No need for two structs, follow the new inet_sock layout
  style.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/ipv6.h     |    3 
 include/linux/tcp.h      |   14 --
 include/net/tcp.h        |  112 ++++++++++-----------
 include/net/tcp_ecn.h    |   37 ++-----
 net/ipv4/ip_sockglue.c   |    2 
 net/ipv4/syncookies.c    |    6 -
 net/ipv4/tcp.c           |   48 ++++-----
 net/ipv4/tcp_diag.c      |    4 
 net/ipv4/tcp_input.c     |  240 +++++++++++++++++++++++------------------------
 net/ipv4/tcp_ipv4.c      |   30 ++---
 net/ipv4/tcp_minisocks.c |   12 +-
 net/ipv4/tcp_output.c    |   63 ++++++------
 net/ipv4/tcp_timer.c     |   20 +--
 net/ipv6/ipv6_sockglue.c |    4 
 net/ipv6/tcp_ipv6.c      |   28 ++---
 net/sunrpc/svcsock.c     |    2 
 net/sunrpc/xprt.c        |    3 
 17 files changed, 308 insertions(+), 320 deletions(-)


diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2004-12-28 16:36:54 -02:00
+++ b/include/linux/ipv6.h	2004-12-28 16:36:54 -02:00
@@ -268,8 +268,7 @@
 };
 
 struct tcp6_sock {
-	struct inet_sock  inet;
-	struct tcp_opt	  tcp;
+	struct tcp_sock	  tcp;
 	struct ipv6_pinfo inet6;
 };
 
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-12-28 16:36:53 -02:00
+++ b/include/linux/tcp.h	2004-12-28 16:36:53 -02:00
@@ -214,7 +214,9 @@
 	TCP_BIC,
 };
 
-struct tcp_opt {
+struct tcp_sock {
+	/* inet_sock has to be the first member of tcp_sock */
+	struct inet_sock	inet;
 	int	tcp_header_len;	/* Bytes of tcp header to send		*/
 
 /*
@@ -438,15 +440,9 @@
 	} bictcp;
 };
 
-/* WARNING: don't change the layout of the members in tcp_sock! */
-struct tcp_sock {
-	struct inet_sock  inet;
-	struct tcp_opt	  tcp;
-};
-
-static inline struct tcp_opt * tcp_sk(const struct sock *__sk)
+static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 {
-	return &((struct tcp_sock *)__sk)->tcp;
+	return (struct tcp_sock *)sk;
 }
 
 #endif
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-12-28 16:36:53 -02:00
+++ b/include/net/tcp.h	2004-12-28 16:36:53 -02:00
@@ -808,17 +808,17 @@
 	TCP_ACK_PUSHED= 4
 };
 
-static inline void tcp_schedule_ack(struct tcp_opt *tp)
+static inline void tcp_schedule_ack(struct tcp_sock *tp)
 {
 	tp->ack.pending |= TCP_ACK_SCHED;
 }
 
-static inline int tcp_ack_scheduled(struct tcp_opt *tp)
+static inline int tcp_ack_scheduled(struct tcp_sock *tp)
 {
 	return tp->ack.pending&TCP_ACK_SCHED;
 }
 
-static __inline__ void tcp_dec_quickack_mode(struct tcp_opt *tp)
+static __inline__ void tcp_dec_quickack_mode(struct tcp_sock *tp)
 {
 	if (tp->ack.quick && --tp->ack.quick == 0) {
 		/* Leaving quickack mode we deflate ATO. */
@@ -826,14 +826,14 @@
 	}
 }
 
-extern void tcp_enter_quickack_mode(struct tcp_opt *tp);
+extern void tcp_enter_quickack_mode(struct tcp_sock *tp);
 
-static __inline__ void tcp_delack_init(struct tcp_opt *tp)
+static __inline__ void tcp_delack_init(struct tcp_sock *tp)
 {
 	memset(&tp->ack, 0, sizeof(tp->ack));
 }
 
-static inline void tcp_clear_options(struct tcp_opt *tp)
+static inline void tcp_clear_options(struct tcp_sock *tp)
 {
  	tp->tstamp_ok = tp->sack_ok = tp->wscale_ok = tp->snd_wscale = 0;
 }
@@ -860,7 +860,7 @@
 						  struct sk_buff *skb);
 extern void			tcp_enter_frto(struct sock *sk);
 extern void			tcp_enter_loss(struct sock *sk, int how);
-extern void			tcp_clear_retrans(struct tcp_opt *tp);
+extern void			tcp_clear_retrans(struct tcp_sock *tp);
 extern void			tcp_update_metrics(struct sock *sk);
 
 extern void			tcp_close(struct sock *sk, 
@@ -884,7 +884,7 @@
 extern int			tcp_listen_start(struct sock *sk);
 
 extern void			tcp_parse_options(struct sk_buff *skb,
-						  struct tcp_opt *tp,
+						  struct tcp_sock *tp,
 						  int estab);
 
 /*
@@ -980,7 +980,7 @@
 
 static inline void tcp_clear_xmit_timer(struct sock *sk, int what)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	
 	switch (what) {
 	case TCP_TIME_RETRANS:
@@ -1013,7 +1013,7 @@
  */
 static inline void tcp_reset_xmit_timer(struct sock *sk, int what, unsigned long when)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (when > TCP_RTO_MAX) {
 #ifdef TCP_DEBUG
@@ -1053,7 +1053,7 @@
 
 static inline void tcp_initialize_rcv_mss(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int hint = min(tp->advmss, tp->mss_cache_std);
 
 	hint = min(hint, tp->rcv_wnd/2);
@@ -1063,19 +1063,19 @@
 	tp->ack.rcv_mss = hint;
 }
 
-static __inline__ void __tcp_fast_path_on(struct tcp_opt *tp, u32 snd_wnd)
+static __inline__ void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
 			       ntohl(TCP_FLAG_ACK) |
 			       snd_wnd);
 }
 
-static __inline__ void tcp_fast_path_on(struct tcp_opt *tp)
+static __inline__ void tcp_fast_path_on(struct tcp_sock *tp)
 {
 	__tcp_fast_path_on(tp, tp->snd_wnd>>tp->snd_wscale);
 }
 
-static inline void tcp_fast_path_check(struct sock *sk, struct tcp_opt *tp)
+static inline void tcp_fast_path_check(struct sock *sk, struct tcp_sock *tp)
 {
 	if (skb_queue_len(&tp->out_of_order_queue) == 0 &&
 	    tp->rcv_wnd &&
@@ -1088,7 +1088,7 @@
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
  */
-static __inline__ u32 tcp_receive_window(const struct tcp_opt *tp)
+static __inline__ u32 tcp_receive_window(const struct tcp_sock *tp)
 {
 	s32 win = tp->rcv_wup + tp->rcv_wnd - tp->rcv_nxt;
 
@@ -1220,7 +1220,7 @@
 }
 
 static inline void tcp_packets_out_inc(struct sock *sk, 
-				       struct tcp_opt *tp,
+				       struct tcp_sock *tp,
 				       const struct sk_buff *skb)
 {
 	int orig = tcp_get_pcount(&tp->packets_out);
@@ -1230,7 +1230,7 @@
 		tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 }
 
-static inline void tcp_packets_out_dec(struct tcp_opt *tp, 
+static inline void tcp_packets_out_dec(struct tcp_sock *tp, 
 				       const struct sk_buff *skb)
 {
 	tcp_dec_pcount(&tp->packets_out, skb);
@@ -1250,7 +1250,7 @@
  *	"Packets left network, but not honestly ACKed yet" PLUS
  *	"Packets fast retransmitted"
  */
-static __inline__ unsigned int tcp_packets_in_flight(const struct tcp_opt *tp)
+static __inline__ unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 {
 	return (tcp_get_pcount(&tp->packets_out) -
 		tcp_get_pcount(&tp->left_out) +
@@ -1274,7 +1274,7 @@
  *	behave like Reno until low_window is reached,
  *	then increase congestion window slowly
  */
-static inline __u32 tcp_recalc_ssthresh(struct tcp_opt *tp)
+static inline __u32 tcp_recalc_ssthresh(struct tcp_sock *tp)
 {
 	if (tcp_is_bic(tp)) {
 		if (sysctl_tcp_bic_fast_convergence &&
@@ -1296,7 +1296,7 @@
 /* Stop taking Vegas samples for now. */
 #define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
     
-static inline void tcp_vegas_enable(struct tcp_opt *tp)
+static inline void tcp_vegas_enable(struct tcp_sock *tp)
 {
 	/* There are several situations when we must "re-start" Vegas:
 	 *
@@ -1328,9 +1328,9 @@
 /* Should we be taking Vegas samples right now? */
 #define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
 
-extern void tcp_ca_init(struct tcp_opt *tp);
+extern void tcp_ca_init(struct tcp_sock *tp);
 
-static inline void tcp_set_ca_state(struct tcp_opt *tp, u8 ca_state)
+static inline void tcp_set_ca_state(struct tcp_sock *tp, u8 ca_state)
 {
 	if (tcp_is_vegas(tp)) {
 		if (ca_state == TCP_CA_Open) 
@@ -1345,7 +1345,7 @@
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
  */
-static inline __u32 tcp_current_ssthresh(struct tcp_opt *tp)
+static inline __u32 tcp_current_ssthresh(struct tcp_sock *tp)
 {
 	if ((1<<tp->ca_state)&(TCPF_CA_CWR|TCPF_CA_Recovery))
 		return tp->snd_ssthresh;
@@ -1355,7 +1355,7 @@
 			    (tp->snd_cwnd >> 2)));
 }
 
-static inline void tcp_sync_left_out(struct tcp_opt *tp)
+static inline void tcp_sync_left_out(struct tcp_sock *tp)
 {
 	if (tp->sack_ok &&
 	    (tcp_get_pcount(&tp->sacked_out) >=
@@ -1372,7 +1372,7 @@
 
 /* Congestion window validation. (RFC2861) */
 
-static inline void tcp_cwnd_validate(struct sock *sk, struct tcp_opt *tp)
+static inline void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
 {
 	__u32 packets_out = tcp_get_pcount(&tp->packets_out);
 
@@ -1391,7 +1391,7 @@
 }
 
 /* Set slow start threshould and cwnd not falling to slow start */
-static inline void __tcp_enter_cwr(struct tcp_opt *tp)
+static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 {
 	tp->undo_marker = 0;
 	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
@@ -1403,7 +1403,7 @@
 	TCP_ECN_queue_cwr(tp);
 }
 
-static inline void tcp_enter_cwr(struct tcp_opt *tp)
+static inline void tcp_enter_cwr(struct tcp_sock *tp)
 {
 	tp->prior_ssthresh = 0;
 	if (tp->ca_state < TCP_CA_CWR) {
@@ -1412,23 +1412,23 @@
 	}
 }
 
-extern __u32 tcp_init_cwnd(struct tcp_opt *tp, struct dst_entry *dst);
+extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
 
 /* Slow start with delack produces 3 packets of burst, so that
  * it is safe "de facto".
  */
-static __inline__ __u32 tcp_max_burst(const struct tcp_opt *tp)
+static __inline__ __u32 tcp_max_burst(const struct tcp_sock *tp)
 {
 	return 3;
 }
 
-static __inline__ int tcp_minshall_check(const struct tcp_opt *tp)
+static __inline__ int tcp_minshall_check(const struct tcp_sock *tp)
 {
 	return after(tp->snd_sml,tp->snd_una) &&
 		!after(tp->snd_sml, tp->snd_nxt);
 }
 
-static __inline__ void tcp_minshall_update(struct tcp_opt *tp, int mss, 
+static __inline__ void tcp_minshall_update(struct tcp_sock *tp, int mss, 
 					   const struct sk_buff *skb)
 {
 	if (skb->len < mss)
@@ -1444,7 +1444,7 @@
  */
 
 static __inline__ int
-tcp_nagle_check(const struct tcp_opt *tp, const struct sk_buff *skb, 
+tcp_nagle_check(const struct tcp_sock *tp, const struct sk_buff *skb, 
 		unsigned mss_now, int nonagle)
 {
 	return (skb->len < mss_now &&
@@ -1460,7 +1460,7 @@
 /* This checks if the data bearing packet SKB (usually sk->sk_send_head)
  * should be put on the wire right now.
  */
-static __inline__ int tcp_snd_test(const struct tcp_opt *tp, 
+static __inline__ int tcp_snd_test(const struct tcp_sock *tp, 
 				   struct sk_buff *skb,
 				   unsigned cur_mss, int nonagle)
 {
@@ -1502,7 +1502,7 @@
 		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
 }
 
-static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_opt *tp)
+static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
 {
 	if (!tcp_get_pcount(&tp->packets_out) && !tp->pending)
 		tcp_reset_xmit_timer(sk, TCP_TIME_PROBE0, tp->rto);
@@ -1519,7 +1519,7 @@
  * The socket must be locked by the caller.
  */
 static __inline__ void __tcp_push_pending_frames(struct sock *sk,
-						 struct tcp_opt *tp,
+						 struct tcp_sock *tp,
 						 unsigned cur_mss,
 						 int nonagle)
 {
@@ -1536,12 +1536,12 @@
 }
 
 static __inline__ void tcp_push_pending_frames(struct sock *sk,
-					       struct tcp_opt *tp)
+					       struct tcp_sock *tp)
 {
 	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 1), tp->nonagle);
 }
 
-static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_opt *tp)
+static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
 {
 	struct sk_buff *skb = sk->sk_send_head;
 
@@ -1550,12 +1550,12 @@
 			     tcp_skb_is_last(sk, skb) ? TCP_NAGLE_PUSH : tp->nonagle));
 }
 
-static __inline__ void tcp_init_wl(struct tcp_opt *tp, u32 ack, u32 seq)
+static __inline__ void tcp_init_wl(struct tcp_sock *tp, u32 ack, u32 seq)
 {
 	tp->snd_wl1 = seq;
 }
 
-static __inline__ void tcp_update_wl(struct tcp_opt *tp, u32 ack, u32 seq)
+static __inline__ void tcp_update_wl(struct tcp_sock *tp, u32 ack, u32 seq)
 {
 	tp->snd_wl1 = seq;
 }
@@ -1586,7 +1586,7 @@
 
 /* Prequeue for VJ style copy to user, combined with checksumming. */
 
-static __inline__ void tcp_prequeue_init(struct tcp_opt *tp)
+static __inline__ void tcp_prequeue_init(struct tcp_sock *tp)
 {
 	tp->ucopy.task = NULL;
 	tp->ucopy.len = 0;
@@ -1604,7 +1604,7 @@
  */
 static __inline__ int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!sysctl_tcp_low_latency && tp->ucopy.task) {
 		__skb_queue_tail(&tp->ucopy.prequeue, skb);
@@ -1688,14 +1688,14 @@
 		tcp_destroy_sock(sk);
 }
 
-static __inline__ void tcp_sack_reset(struct tcp_opt *tp)
+static __inline__ void tcp_sack_reset(struct tcp_sock *tp)
 {
 	tp->dsack = 0;
 	tp->eff_sacks = 0;
 	tp->num_sacks = 0;
 }
 
-static __inline__ void tcp_build_and_update_options(__u32 *ptr, struct tcp_opt *tp, __u32 tstamp)
+static __inline__ void tcp_build_and_update_options(__u32 *ptr, struct tcp_sock *tp, __u32 tstamp)
 {
 	if (tp->tstamp_ok) {
 		*ptr++ = __constant_htonl((TCPOPT_NOP << 24) |
@@ -1790,7 +1790,7 @@
 static inline void tcp_acceptq_queue(struct sock *sk, struct open_request *req,
 					 struct sock *child)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	req->sk = child;
 	sk_acceptq_added(sk);
@@ -1849,7 +1849,7 @@
 	return tcp_synq_len(sk) >> tcp_sk(sk)->listen_opt->max_qlen_log;
 }
 
-static inline void tcp_synq_unlink(struct tcp_opt *tp, struct open_request *req,
+static inline void tcp_synq_unlink(struct tcp_sock *tp, struct open_request *req,
 				       struct open_request **prev)
 {
 	write_lock(&tp->syn_wait_lock);
@@ -1866,7 +1866,7 @@
 }
 
 static __inline__ void tcp_openreq_init(struct open_request *req,
-					struct tcp_opt *tp,
+					struct tcp_sock *tp,
 					struct sk_buff *skb)
 {
 	req->rcv_wnd = 0;		/* So that tcp_send_synack() knows! */
@@ -1905,17 +1905,17 @@
 		wake_up(&tcp_lhash_wait);
 }
 
-static inline int keepalive_intvl_when(const struct tcp_opt *tp)
+static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
 	return tp->keepalive_intvl ? : sysctl_tcp_keepalive_intvl;
 }
 
-static inline int keepalive_time_when(const struct tcp_opt *tp)
+static inline int keepalive_time_when(const struct tcp_sock *tp)
 {
 	return tp->keepalive_time ? : sysctl_tcp_keepalive_time;
 }
 
-static inline int tcp_fin_time(const struct tcp_opt *tp)
+static inline int tcp_fin_time(const struct tcp_sock *tp)
 {
 	int fin_timeout = tp->linger2 ? : sysctl_tcp_fin_timeout;
 
@@ -1925,7 +1925,7 @@
 	return fin_timeout;
 }
 
-static inline int tcp_paws_check(const struct tcp_opt *tp, int rst)
+static inline int tcp_paws_check(const struct tcp_sock *tp, int rst)
 {
 	if ((s32)(tp->rcv_tsval - tp->ts_recent) >= 0)
 		return 0;
@@ -1962,7 +1962,7 @@
 
 static inline int tcp_use_frto(const struct sock *sk)
 {
-	const struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	
 	/* F-RTO must be activated in sysctl and there must be some
 	 * unsent new data, and the advertised window should allow
@@ -2014,7 +2014,7 @@
 #define TCP_WESTWOOD_INIT_RTT  (20*HZ)           /* maybe too conservative?! */
 #define TCP_WESTWOOD_RTT_MIN   (HZ/20)           /* 50ms */
 
-static inline void tcp_westwood_update_rtt(struct tcp_opt *tp, __u32 rtt_seq)
+static inline void tcp_westwood_update_rtt(struct tcp_sock *tp, __u32 rtt_seq)
 {
         if (tcp_is_westwood(tp))
                 tp->westwood.rtt = rtt_seq;
@@ -2035,19 +2035,19 @@
                 __tcp_westwood_slow_bw(sk, skb);
 }
 
-static inline __u32 __tcp_westwood_bw_rttmin(const struct tcp_opt *tp)
+static inline __u32 __tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
 {
         return max((tp->westwood.bw_est) * (tp->westwood.rtt_min) /
 		   (__u32) (tp->mss_cache_std),
 		   2U);
 }
 
-static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_opt *tp)
+static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
 {
 	return tcp_is_westwood(tp) ? __tcp_westwood_bw_rttmin(tp) : 0;
 }
 
-static inline int tcp_westwood_ssthresh(struct tcp_opt *tp)
+static inline int tcp_westwood_ssthresh(struct tcp_sock *tp)
 {
 	__u32 ssthresh = 0;
 
@@ -2060,7 +2060,7 @@
 	return (ssthresh != 0);
 }
 
-static inline int tcp_westwood_cwnd(struct tcp_opt *tp)
+static inline int tcp_westwood_cwnd(struct tcp_sock *tp)
 {
 	__u32 cwnd = 0;
 
diff -Nru a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
--- a/include/net/tcp_ecn.h	2004-12-28 16:36:54 -02:00
+++ b/include/net/tcp_ecn.h	2004-12-28 16:36:54 -02:00
@@ -9,8 +9,7 @@
 #define TCP_ECN_QUEUE_CWR	2
 #define TCP_ECN_DEMAND_CWR	4
 
-static __inline__ void
-TCP_ECN_queue_cwr(struct tcp_opt *tp)
+static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
 {
 	if (tp->ecn_flags&TCP_ECN_OK)
 		tp->ecn_flags |= TCP_ECN_QUEUE_CWR;
@@ -19,16 +18,16 @@
 
 /* Output functions */
 
-static __inline__ void
-TCP_ECN_send_synack(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void TCP_ECN_send_synack(struct tcp_sock *tp,
+				       struct sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_CWR;
 	if (!(tp->ecn_flags&TCP_ECN_OK))
 		TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_ECE;
 }
 
-static __inline__ void
-TCP_ECN_send_syn(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
+static inline void TCP_ECN_send_syn(struct sock *sk, struct tcp_sock *tp,
+				    struct sk_buff *skb)
 {
 	tp->ecn_flags = 0;
 	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
@@ -45,8 +44,8 @@
 		th->ece = 1;
 }
 
-static __inline__ void
-TCP_ECN_send(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb, int tcp_header_len)
+static inline void TCP_ECN_send(struct sock *sk, struct tcp_sock *tp,
+				struct sk_buff *skb, int tcp_header_len)
 {
 	if (tp->ecn_flags & TCP_ECN_OK) {
 		/* Not-retransmitted data segment: set ECT and inject CWR. */
@@ -68,21 +67,18 @@
 
 /* Input functions */
 
-static __inline__ void
-TCP_ECN_accept_cwr(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	if (skb->h.th->cwr)
 		tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
 }
 
-static __inline__ void
-TCP_ECN_withdraw_cwr(struct tcp_opt *tp)
+static inline void TCP_ECN_withdraw_cwr(struct tcp_sock *tp)
 {
 	tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
 }
 
-static __inline__ void
-TCP_ECN_check_ce(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void TCP_ECN_check_ce(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	if (tp->ecn_flags&TCP_ECN_OK) {
 		if (INET_ECN_is_ce(TCP_SKB_CB(skb)->flags))
@@ -95,30 +91,27 @@
 	}
 }
 
-static __inline__ void
-TCP_ECN_rcv_synack(struct tcp_opt *tp, struct tcphdr *th)
+static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, struct tcphdr *th)
 {
 	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static __inline__ void
-TCP_ECN_rcv_syn(struct tcp_opt *tp, struct tcphdr *th)
+static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, struct tcphdr *th)
 {
 	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || !th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static __inline__ int
-TCP_ECN_rcv_ecn_echo(struct tcp_opt *tp, struct tcphdr *th)
+static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcphdr *th)
 {
 	if (th->ece && !th->syn && (tp->ecn_flags&TCP_ECN_OK))
 		return 1;
 	return 0;
 }
 
-static __inline__ void
-TCP_ECN_openreq_child(struct tcp_opt *tp, struct open_request *req)
+static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
+					 struct open_request *req)
 {
 	tp->ecn_flags = req->ecn_ok ? TCP_ECN_OK : 0;
 }
diff -Nru a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv4/ip_sockglue.c	2004-12-28 16:36:53 -02:00
@@ -429,7 +429,7 @@
 			if (err)
 				break;
 			if (sk->sk_type == SOCK_STREAM) {
-				struct tcp_opt *tp = tcp_sk(sk);
+				struct tcp_sock *tp = tcp_sk(sk);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 				if (sk->sk_family == PF_INET ||
 				    (!((1 << sk->sk_state) &
diff -Nru a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
--- a/net/ipv4/syncookies.c	2004-12-28 16:36:54 -02:00
+++ b/net/ipv4/syncookies.c	2004-12-28 16:36:54 -02:00
@@ -47,7 +47,7 @@
  */
 __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int mssind;
 	const __u16 mss = *mssp;
 
@@ -98,7 +98,7 @@
 					   struct open_request *req,
 					   struct dst_entry *dst)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sock *child;
 
 	child = tp->af_specific->syn_recv_sock(sk, skb, req, dst);
@@ -114,7 +114,7 @@
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 cookie = ntohl(skb->h.th->ack_seq) - 1; 
 	struct sock *ret = sk;
 	struct open_request *req; 
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv4/tcp.c	2004-12-28 16:36:53 -02:00
@@ -330,7 +330,7 @@
 {
 	unsigned int mask;
 	struct sock *sk = sock->sk;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	poll_wait(file, sk->sk_sleep, wait);
 	if (sk->sk_state == TCP_LISTEN)
@@ -413,7 +413,7 @@
 
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int answ;
 
 	switch (cmd) {
@@ -461,7 +461,7 @@
 int tcp_listen_start(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;
 
 	sk->sk_max_ack_backlog = 0;
@@ -514,7 +514,7 @@
 
 static void tcp_listen_stop (struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt = tp->listen_opt;
 	struct open_request *acc_req = tp->accept_queue;
 	struct open_request *req;
@@ -578,18 +578,18 @@
 	BUG_TRAP(!sk->sk_ack_backlog);
 }
 
-static inline void tcp_mark_push(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 	tp->pushed_seq = tp->write_seq;
 }
 
-static inline int forced_push(struct tcp_opt *tp)
+static inline int forced_push(struct tcp_sock *tp)
 {
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
 
-static inline void skb_entail(struct sock *sk, struct tcp_opt *tp,
+static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
 			      struct sk_buff *skb)
 {
 	skb->csum = 0;
@@ -605,7 +605,7 @@
 		tp->nonagle &= ~TCP_NAGLE_PUSH; 
 }
 
-static inline void tcp_mark_urg(struct tcp_opt *tp, int flags,
+static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
 				struct sk_buff *skb)
 {
 	if (flags & MSG_OOB) {
@@ -615,7 +615,7 @@
 	}
 }
 
-static inline void tcp_push(struct sock *sk, struct tcp_opt *tp, int flags,
+static inline void tcp_push(struct sock *sk, struct tcp_sock *tp, int flags,
 			    int mss_now, int nonagle)
 {
 	if (sk->sk_send_head) {
@@ -631,7 +631,7 @@
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
 			 size_t psize, int flags)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now;
 	int err;
 	ssize_t copied;
@@ -760,7 +760,7 @@
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
 
-static inline int select_size(struct sock *sk, struct tcp_opt *tp)
+static inline int select_size(struct sock *sk, struct tcp_sock *tp)
 {
 	int tmp = tp->mss_cache_std;
 
@@ -778,7 +778,7 @@
 		size_t size)
 {
 	struct iovec *iov;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int iovlen, flags;
 	int mss_now;
@@ -1002,7 +1002,7 @@
 			struct msghdr *msg, int len, int flags,
 			int *addr_len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* No URG data to read. */
 	if (sock_flag(sk, SOCK_URGINLINE) || !tp->urg_data ||
@@ -1052,7 +1052,7 @@
  */
 static void cleanup_rbuf(struct sock *sk, int copied)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int time_to_ack = 0;
 
 #if TCP_DEBUG
@@ -1107,7 +1107,7 @@
 static void tcp_prequeue_process(struct sock *sk)
 {
 	struct sk_buff *skb;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	NET_ADD_STATS_USER(LINUX_MIB_TCPPREQUEUED, skb_queue_len(&tp->ucopy.prequeue));
 
@@ -1154,7 +1154,7 @@
 		  sk_read_actor_t recv_actor)
 {
 	struct sk_buff *skb;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 seq = tp->copied_seq;
 	u32 offset;
 	int copied = 0;
@@ -1213,7 +1213,7 @@
 int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int nonblock, int flags, int *addr_len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int copied = 0;
 	u32 peek_seq;
 	u32 *seq;
@@ -1719,7 +1719,7 @@
 	 */
 
 	if (sk->sk_state == TCP_FIN_WAIT2) {
-		struct tcp_opt *tp = tcp_sk(sk);
+		struct tcp_sock *tp = tcp_sk(sk);
 		if (tp->linger2 < 0) {
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
@@ -1773,7 +1773,7 @@
 int tcp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int err = 0;
 	int old_state = sk->sk_state;
 
@@ -1835,7 +1835,7 @@
  */
 static int wait_for_connect(struct sock *sk, long timeo)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	DEFINE_WAIT(wait);
 	int err;
 
@@ -1883,7 +1883,7 @@
 
 struct sock *tcp_accept(struct sock *sk, int flags, int *err)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct open_request *req;
 	struct sock *newsk;
 	int error;
@@ -1934,7 +1934,7 @@
 int tcp_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		   int optlen)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int val;
 	int err = 0;
 
@@ -2098,7 +2098,7 @@
 /* Return information about state of tcp endpoint in API format. */
 void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 now = tcp_time_stamp;
 
 	memset(info, 0, sizeof(*info));
@@ -2157,7 +2157,7 @@
 int tcp_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		   int __user *optlen)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int val, len;
 
 	if (level != SOL_TCP)
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv4/tcp_diag.c	2004-12-28 16:36:53 -02:00
@@ -56,7 +56,7 @@
 			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcpdiagmsg *r;
 	struct nlmsghdr  *nlh;
 	struct tcp_info  *info = NULL;
@@ -512,7 +512,7 @@
 {
 	struct tcpdiag_entry entry;
 	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;
 	struct rtattr *bc = NULL;
 	struct inet_sock *inet = inet_sk(sk);
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-12-28 16:36:54 -02:00
+++ b/net/ipv4/tcp_input.c	2004-12-28 16:36:54 -02:00
@@ -127,7 +127,8 @@
 /* Adapt the MSS value used to make delayed ack decision to the 
  * real world.
  */ 
-static __inline__ void tcp_measure_rcv_mss(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void tcp_measure_rcv_mss(struct tcp_sock *tp,
+				       struct sk_buff *skb)
 {
 	unsigned int len, lss;
 
@@ -170,7 +171,7 @@
 	}
 }
 
-static void tcp_incr_quickack(struct tcp_opt *tp)
+static void tcp_incr_quickack(struct tcp_sock *tp)
 {
 	unsigned quickacks = tp->rcv_wnd/(2*tp->ack.rcv_mss);
 
@@ -180,7 +181,7 @@
 		tp->ack.quick = min(quickacks, TCP_MAX_QUICKACKS);
 }
 
-void tcp_enter_quickack_mode(struct tcp_opt *tp)
+void tcp_enter_quickack_mode(struct tcp_sock *tp)
 {
 	tcp_incr_quickack(tp);
 	tp->ack.pingpong = 0;
@@ -191,7 +192,7 @@
  * and the session is not interactive.
  */
 
-static __inline__ int tcp_in_quickack_mode(struct tcp_opt *tp)
+static __inline__ int tcp_in_quickack_mode(struct tcp_sock *tp)
 {
 	return (tp->ack.quick && !tp->ack.pingpong);
 }
@@ -236,8 +237,8 @@
  */
 
 /* Slow part of check#2. */
-static int
-__tcp_grow_window(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
+static int __tcp_grow_window(struct sock *sk, struct tcp_sock *tp,
+			     struct sk_buff *skb)
 {
 	/* Optimize this! */
 	int truesize = tcp_win_from_space(skb->truesize)/2;
@@ -253,8 +254,8 @@
 	return 0;
 }
 
-static __inline__ void
-tcp_grow_window(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
+static inline void tcp_grow_window(struct sock *sk, struct tcp_sock *tp,
+				   struct sk_buff *skb)
 {
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
@@ -281,7 +282,7 @@
 
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int rcvmem = tp->advmss + MAX_TCP_HEADER + 16 + sizeof(struct sk_buff);
 
 	/* Try to select rcvbuf so that 4 mss-sized segments
@@ -299,7 +300,7 @@
  */
 static void tcp_init_buffer_space(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int maxwin;
 
 	if (!(sk->sk_userlocks & SOCK_RCVBUF_LOCK))
@@ -330,7 +331,7 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static void init_bictcp(struct tcp_opt *tp)
+static void init_bictcp(struct tcp_sock *tp)
 {
 	tp->bictcp.cnt = 0;
 
@@ -340,7 +341,7 @@
 }
 
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
-static void tcp_clamp_window(struct sock *sk, struct tcp_opt *tp)
+static void tcp_clamp_window(struct sock *sk, struct tcp_sock *tp)
 {
 	struct sk_buff *skb;
 	unsigned int app_win = tp->rcv_nxt - tp->copied_seq;
@@ -388,7 +389,7 @@
  * though this reference is out of date.  A new paper
  * is pending.
  */
-static void tcp_rcv_rtt_update(struct tcp_opt *tp, u32 sample, int win_dep)
+static void tcp_rcv_rtt_update(struct tcp_sock *tp, u32 sample, int win_dep)
 {
 	u32 new_sample = tp->rcv_rtt_est.rtt;
 	long m = sample;
@@ -421,7 +422,7 @@
 		tp->rcv_rtt_est.rtt = new_sample;
 }
 
-static inline void tcp_rcv_rtt_measure(struct tcp_opt *tp)
+static inline void tcp_rcv_rtt_measure(struct tcp_sock *tp)
 {
 	if (tp->rcv_rtt_est.time == 0)
 		goto new_measure;
@@ -436,7 +437,7 @@
 	tp->rcv_rtt_est.time = tcp_time_stamp;
 }
 
-static inline void tcp_rcv_rtt_measure_ts(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void tcp_rcv_rtt_measure_ts(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	if (tp->rcv_tsecr &&
 	    (TCP_SKB_CB(skb)->end_seq -
@@ -450,7 +451,7 @@
  */
 void tcp_rcv_space_adjust(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int time;
 	int space;
 	
@@ -511,7 +512,7 @@
  * each ACK we send, he increments snd_cwnd and transmits more of his
  * queue.  -DaveM
  */
-static void tcp_event_data_recv(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
+static void tcp_event_data_recv(struct sock *sk, struct tcp_sock *tp, struct sk_buff *skb)
 {
 	u32 now;
 
@@ -558,7 +559,7 @@
 /* When starting a new connection, pin down the current choice of 
  * congestion algorithm.
  */
-void tcp_ca_init(struct tcp_opt *tp)
+void tcp_ca_init(struct tcp_sock *tp)
 {
 	if (sysctl_tcp_westwood) 
 		tp->adv_cong = TCP_WESTWOOD;
@@ -579,7 +580,7 @@
  *   o min-filter RTT samples from a much longer window (forever for now)
  *     to find the propagation delay (baseRTT)
  */
-static inline void vegas_rtt_calc(struct tcp_opt *tp, __u32 rtt)
+static inline void vegas_rtt_calc(struct tcp_sock *tp, __u32 rtt)
 {
 	__u32 vrtt = rtt + 1; /* Never allow zero rtt or baseRTT */
 
@@ -603,7 +604,7 @@
  * To save cycles in the RFC 1323 implementation it was better to break
  * it up into three procedures. -- erics
  */
-static void tcp_rtt_estimator(struct tcp_opt *tp, __u32 mrtt)
+static void tcp_rtt_estimator(struct tcp_sock *tp, __u32 mrtt)
 {
 	long m = mrtt; /* RTT */
 
@@ -673,7 +674,7 @@
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
  * routine referred to above.
  */
-static __inline__ void tcp_set_rto(struct tcp_opt *tp)
+static inline void tcp_set_rto(struct tcp_sock *tp)
 {
 	/* Old crap is replaced with new one. 8)
 	 *
@@ -697,7 +698,7 @@
 /* NOTE: clamping at TCP_RTO_MIN is not required, current algo
  * guarantees that rto is higher.
  */
-static __inline__ void tcp_bound_rto(struct tcp_opt *tp)
+static inline void tcp_bound_rto(struct tcp_sock *tp)
 {
 	if (tp->rto > TCP_RTO_MAX)
 		tp->rto = TCP_RTO_MAX;
@@ -709,7 +710,7 @@
  */
 void tcp_update_metrics(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (sysctl_tcp_nometrics_save)
@@ -797,7 +798,7 @@
 }
 
 /* Numbers are taken from RFC2414.  */
-__u32 tcp_init_cwnd(struct tcp_opt *tp, struct dst_entry *dst)
+__u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
 {
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
@@ -814,7 +815,7 @@
 
 static void tcp_init_metrics(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (dst == NULL)
@@ -883,7 +884,7 @@
 	}
 }
 
-static void tcp_update_reordering(struct tcp_opt *tp, int metric, int ts)
+static void tcp_update_reordering(struct tcp_sock *tp, int metric, int ts)
 {
 	if (metric > tp->reordering) {
 		tp->reordering = min(TCP_MAX_REORDERING, metric);
@@ -961,7 +962,7 @@
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_una)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned char *ptr = ack_skb->h.raw + TCP_SKB_CB(ack_skb)->sacked;
 	struct tcp_sack_block *sp = (struct tcp_sack_block *)(ptr+2);
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
@@ -1178,7 +1179,7 @@
  */
 void tcp_enter_frto(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	tp->frto_counter = 1;
@@ -1215,7 +1216,7 @@
  */
 static void tcp_enter_frto_loss(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int cnt = 0;
 
@@ -1258,7 +1259,7 @@
 	init_bictcp(tp);
 }
 
-void tcp_clear_retrans(struct tcp_opt *tp)
+void tcp_clear_retrans(struct tcp_sock *tp)
 {
 	tcp_set_pcount(&tp->left_out, 0);
 	tcp_set_pcount(&tp->retrans_out, 0);
@@ -1277,7 +1278,7 @@
  */
 void tcp_enter_loss(struct sock *sk, int how)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int cnt = 0;
 
@@ -1321,7 +1322,7 @@
 	TCP_ECN_queue_cwr(tp);
 }
 
-static int tcp_check_sack_reneging(struct sock *sk, struct tcp_opt *tp)
+static int tcp_check_sack_reneging(struct sock *sk, struct tcp_sock *tp)
 {
 	struct sk_buff *skb;
 
@@ -1344,18 +1345,18 @@
 	return 0;
 }
 
-static inline int tcp_fackets_out(struct tcp_opt *tp)
+static inline int tcp_fackets_out(struct tcp_sock *tp)
 {
 	return IsReno(tp) ? tcp_get_pcount(&tp->sacked_out)+1 :
 		tcp_get_pcount(&tp->fackets_out);
 }
 
-static inline int tcp_skb_timedout(struct tcp_opt *tp, struct sk_buff *skb)
+static inline int tcp_skb_timedout(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	return (tcp_time_stamp - TCP_SKB_CB(skb)->when > tp->rto);
 }
 
-static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
+static inline int tcp_head_timedout(struct sock *sk, struct tcp_sock *tp)
 {
 	return tcp_get_pcount(&tp->packets_out) &&
 	       tcp_skb_timedout(tp, skb_peek(&sk->sk_write_queue));
@@ -1454,8 +1455,7 @@
  * Main question: may we further continue forward transmission
  * with the same cwnd?
  */
-static int
-tcp_time_to_recover(struct sock *sk, struct tcp_opt *tp)
+static int tcp_time_to_recover(struct sock *sk, struct tcp_sock *tp)
 {
 	__u32 packets_out;
 
@@ -1493,7 +1493,7 @@
  * in assumption of absent reordering, interpret this as reordering.
  * The only another reason could be bug in receiver TCP.
  */
-static void tcp_check_reno_reordering(struct tcp_opt *tp, int addend)
+static void tcp_check_reno_reordering(struct tcp_sock *tp, int addend)
 {
 	u32 holes;
 
@@ -1512,7 +1512,7 @@
 
 /* Emulate SACKs for SACKless connection: account for a new dupack. */
 
-static void tcp_add_reno_sack(struct tcp_opt *tp)
+static void tcp_add_reno_sack(struct tcp_sock *tp)
 {
 	tcp_inc_pcount_explicit(&tp->sacked_out, 1);
 	tcp_check_reno_reordering(tp, 0);
@@ -1521,7 +1521,7 @@
 
 /* Account for ACK, ACKing some data in Reno Recovery phase. */
 
-static void tcp_remove_reno_sacks(struct sock *sk, struct tcp_opt *tp, int acked)
+static void tcp_remove_reno_sacks(struct sock *sk, struct tcp_sock *tp, int acked)
 {
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
@@ -1534,15 +1534,15 @@
 	tcp_sync_left_out(tp);
 }
 
-static inline void tcp_reset_reno_sack(struct tcp_opt *tp)
+static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 {
 	tcp_set_pcount(&tp->sacked_out, 0);
 	tcp_set_pcount(&tp->left_out, tcp_get_pcount(&tp->lost_out));
 }
 
 /* Mark head of queue up as lost. */
-static void
-tcp_mark_head_lost(struct sock *sk, struct tcp_opt *tp, int packets, u32 high_seq)
+static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
+			       int packets, u32 high_seq)
 {
 	struct sk_buff *skb;
 	int cnt = packets;
@@ -1563,7 +1563,7 @@
 
 /* Account newly detected lost packet(s) */
 
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_opt *tp)
+static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
 {
 	if (IsFack(tp)) {
 		int lost = tcp_get_pcount(&tp->fackets_out) - tp->reordering;
@@ -1596,7 +1596,7 @@
 /* CWND moderation, preventing bursts due to too big ACKs
  * in dubious situations.
  */
-static __inline__ void tcp_moderate_cwnd(struct tcp_opt *tp)
+static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 {
 	tp->snd_cwnd = min(tp->snd_cwnd,
 			   tcp_packets_in_flight(tp)+tcp_max_burst(tp));
@@ -1605,7 +1605,7 @@
 
 /* Decrease cwnd each second ack. */
 
-static void tcp_cwnd_down(struct tcp_opt *tp)
+static void tcp_cwnd_down(struct tcp_sock *tp)
 {
 	int decr = tp->snd_cwnd_cnt + 1;
 	__u32 limit;
@@ -1635,7 +1635,7 @@
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
-static __inline__ int tcp_packet_delayed(struct tcp_opt *tp)
+static inline int tcp_packet_delayed(struct tcp_sock *tp)
 {
 	return !tp->retrans_stamp ||
 		(tp->saw_tstamp && tp->rcv_tsecr &&
@@ -1645,7 +1645,7 @@
 /* Undo procedures. */
 
 #if FASTRETRANS_DEBUG > 1
-static void DBGUNDO(struct sock *sk, struct tcp_opt *tp, const char *msg)
+static void DBGUNDO(struct sock *sk, struct tcp_sock *tp, const char *msg)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
@@ -1659,7 +1659,7 @@
 #define DBGUNDO(x...) do { } while (0)
 #endif
 
-static void tcp_undo_cwr(struct tcp_opt *tp, int undo)
+static void tcp_undo_cwr(struct tcp_sock *tp, int undo)
 {
 	if (tp->prior_ssthresh) {
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
@@ -1675,14 +1675,14 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static inline int tcp_may_undo(struct tcp_opt *tp)
+static inline int tcp_may_undo(struct tcp_sock *tp)
 {
 	return tp->undo_marker &&
 		(!tp->undo_retrans || tcp_packet_delayed(tp));
 }
 
 /* People celebrate: "We love our President!" */
-static int tcp_try_undo_recovery(struct sock *sk, struct tcp_opt *tp)
+static int tcp_try_undo_recovery(struct sock *sk, struct tcp_sock *tp)
 {
 	if (tcp_may_undo(tp)) {
 		/* Happy end! We did not retransmit anything
@@ -1708,7 +1708,7 @@
 }
 
 /* Try to undo cwnd reduction, because D-SACKs acked all retransmitted data */
-static void tcp_try_undo_dsack(struct sock *sk, struct tcp_opt *tp)
+static void tcp_try_undo_dsack(struct sock *sk, struct tcp_sock *tp)
 {
 	if (tp->undo_marker && !tp->undo_retrans) {
 		DBGUNDO(sk, tp, "D-SACK");
@@ -1720,7 +1720,8 @@
 
 /* Undo during fast recovery after partial ACK. */
 
-static int tcp_try_undo_partial(struct sock *sk, struct tcp_opt *tp, int acked)
+static int tcp_try_undo_partial(struct sock *sk, struct tcp_sock *tp,
+				int acked)
 {
 	/* Partial ACK arrived. Force Hoe's retransmit. */
 	int failed = IsReno(tp) || tcp_get_pcount(&tp->fackets_out)>tp->reordering;
@@ -1748,7 +1749,7 @@
 }
 
 /* Undo during loss recovery after partial ACK. */
-static int tcp_try_undo_loss(struct sock *sk, struct tcp_opt *tp)
+static int tcp_try_undo_loss(struct sock *sk, struct tcp_sock *tp)
 {
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
@@ -1769,7 +1770,7 @@
 	return 0;
 }
 
-static __inline__ void tcp_complete_cwr(struct tcp_opt *tp)
+static inline void tcp_complete_cwr(struct tcp_sock *tp)
 {
 	if (tcp_westwood_cwnd(tp)) 
 		tp->snd_ssthresh = tp->snd_cwnd;
@@ -1778,7 +1779,7 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static void tcp_try_to_open(struct sock *sk, struct tcp_opt *tp, int flag)
+static void tcp_try_to_open(struct sock *sk, struct tcp_sock *tp, int flag)
 {
 	tcp_set_pcount(&tp->left_out, tcp_get_pcount(&tp->sacked_out));
 
@@ -1821,7 +1822,7 @@
 tcp_fastretrans_alert(struct sock *sk, u32 prior_snd_una,
 		      int prior_packets, int flag)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int is_dupack = (tp->snd_una == prior_snd_una && !(flag&FLAG_NOT_DUP));
 
 	/* Some technical things:
@@ -1970,7 +1971,7 @@
 /* Read draft-ietf-tcplw-high-performance before mucking
  * with this code. (Superceeds RFC1323)
  */
-static void tcp_ack_saw_tstamp(struct tcp_opt *tp, int flag)
+static void tcp_ack_saw_tstamp(struct tcp_sock *tp, int flag)
 {
 	__u32 seq_rtt;
 
@@ -1996,7 +1997,7 @@
 	tcp_bound_rto(tp);
 }
 
-static void tcp_ack_no_tstamp(struct tcp_opt *tp, u32 seq_rtt, int flag)
+static void tcp_ack_no_tstamp(struct tcp_sock *tp, u32 seq_rtt, int flag)
 {
 	/* We don't have a timestamp. Can only use
 	 * packets that are not retransmitted to determine
@@ -2016,8 +2017,8 @@
 	tcp_bound_rto(tp);
 }
 
-static __inline__ void
-tcp_ack_update_rtt(struct tcp_opt *tp, int flag, s32 seq_rtt)
+static inline void tcp_ack_update_rtt(struct tcp_sock *tp,
+				      int flag, s32 seq_rtt)
 {
 	/* Note that peer MAY send zero echo. In this case it is ignored. (rfc1323) */
 	if (tp->saw_tstamp && tp->rcv_tsecr)
@@ -2039,7 +2040,7 @@
  * Unless BIC is enabled and congestion window is large
  * this behaves the same as the original Reno.
  */
-static inline __u32 bictcp_cwnd(struct tcp_opt *tp)
+static inline __u32 bictcp_cwnd(struct tcp_sock *tp)
 {
 	/* orignal Reno behaviour */
 	if (!tcp_is_bic(tp))
@@ -2092,7 +2093,7 @@
 /* This is Jacobson's slow start and congestion avoidance. 
  * SIGCOMM '88, p. 328.
  */
-static __inline__ void reno_cong_avoid(struct tcp_opt *tp)
+static inline void reno_cong_avoid(struct tcp_sock *tp)
 {
         if (tp->snd_cwnd <= tp->snd_ssthresh) {
                 /* In "safe" area, increase. */
@@ -2141,7 +2142,7 @@
  *     a cwnd adjustment decision. The original Vegas implementation
  *     assumed senders never went idle.
  */
-static void vegas_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+static void vegas_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
 {
 	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
 	 *
@@ -2334,7 +2335,7 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static inline void tcp_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
 {
 	if (tcp_vegas_enabled(tp))
 		vegas_cong_avoid(tp, ack, seq_rtt);
@@ -2346,7 +2347,7 @@
  * RFC2988 recommends to restart timer to now+rto.
  */
 
-static __inline__ void tcp_ack_packets_out(struct sock *sk, struct tcp_opt *tp)
+static inline void tcp_ack_packets_out(struct sock *sk, struct tcp_sock *tp)
 {
 	if (!tcp_get_pcount(&tp->packets_out)) {
 		tcp_clear_xmit_timer(sk, TCP_TIME_RETRANS);
@@ -2367,7 +2368,7 @@
 static int tcp_tso_acked(struct sock *sk, struct sk_buff *skb,
 			 __u32 now, __s32 *seq_rtt)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
 	__u32 seq = tp->snd_una;
 	__u32 packets_acked;
@@ -2428,7 +2429,7 @@
 /* Remove acknowledged frames from the retransmission queue. */
 static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	__u32 now = tcp_time_stamp;
 	int acked = 0;
@@ -2525,7 +2526,7 @@
 
 static void tcp_ack_probe(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Was it a usable window open? */
 
@@ -2542,13 +2543,13 @@
 	}
 }
 
-static __inline__ int tcp_ack_is_dubious(struct tcp_opt *tp, int flag)
+static inline int tcp_ack_is_dubious(struct tcp_sock *tp, int flag)
 {
 	return (!(flag & FLAG_NOT_DUP) || (flag & FLAG_CA_ALERT) ||
 		tp->ca_state != TCP_CA_Open);
 }
 
-static __inline__ int tcp_may_raise_cwnd(struct tcp_opt *tp, int flag)
+static inline int tcp_may_raise_cwnd(struct tcp_sock *tp, int flag)
 {
 	return (!(flag & FLAG_ECE) || tp->snd_cwnd < tp->snd_ssthresh) &&
 		!((1<<tp->ca_state)&(TCPF_CA_Recovery|TCPF_CA_CWR));
@@ -2557,8 +2558,8 @@
 /* Check that window update is acceptable.
  * The function assumes that snd_una<=ack<=snd_next.
  */
-static __inline__ int
-tcp_may_update_window(struct tcp_opt *tp, u32 ack, u32 ack_seq, u32 nwin)
+static inline int tcp_may_update_window(struct tcp_sock *tp, u32 ack,
+					u32 ack_seq, u32 nwin)
 {
 	return (after(ack, tp->snd_una) ||
 		after(ack_seq, tp->snd_wl1) ||
@@ -2570,7 +2571,7 @@
  * Window update algorithm, described in RFC793/RFC1122 (used in linux-2.2
  * and in FreeBSD. NetBSD's one is even worse.) is wrong.
  */
-static int tcp_ack_update_window(struct sock *sk, struct tcp_opt *tp,
+static int tcp_ack_update_window(struct sock *sk, struct tcp_sock *tp,
 				 struct sk_buff *skb, u32 ack, u32 ack_seq)
 {
 	int flag = 0;
@@ -2605,7 +2606,7 @@
 
 static void tcp_process_frto(struct sock *sk, u32 prior_snd_una)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	
 	tcp_sync_left_out(tp);
 	
@@ -2654,7 +2655,7 @@
 
 static void init_westwood(struct sock *sk)
 {
-        struct tcp_opt *tp = tcp_sk(sk);
+        struct tcp_sock *tp = tcp_sk(sk);
 
         tp->westwood.bw_ns_est = 0;
         tp->westwood.bw_est = 0;
@@ -2678,7 +2679,7 @@
 
 static void westwood_filter(struct sock *sk, __u32 delta)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->westwood.bw_ns_est =
 		westwood_do_filter(tp->westwood.bw_ns_est, 
@@ -2696,7 +2697,7 @@
 
 static inline __u32 westwood_update_rttmin(const struct sock *sk)
 {
-	const struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	__u32 rttmin = tp->westwood.rtt_min;
 
 	if (tp->westwood.rtt != 0 &&
@@ -2713,7 +2714,7 @@
 
 static inline __u32 westwood_acked(const struct sock *sk)
 {
-	const struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	return tp->snd_una - tp->westwood.snd_una;
 }
@@ -2729,7 +2730,7 @@
 
 static int westwood_new_window(const struct sock *sk)
 {
-	const struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	__u32 left_bound;
 	__u32 rtt;
 	int ret = 0;
@@ -2760,7 +2761,7 @@
 
 static void __westwood_update_window(struct sock *sk, __u32 now)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 delta = now - tp->westwood.rtt_win_sx;
 
         if (delta) {
@@ -2788,7 +2789,7 @@
 
 void __tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	westwood_update_window(sk, tcp_time_stamp);
 
@@ -2805,24 +2806,24 @@
 
 static void westwood_dupack_update(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->westwood.accounted += tp->mss_cache_std;
 	tp->westwood.cumul_ack = tp->mss_cache_std;
 }
 
-static inline int westwood_may_change_cumul(struct tcp_opt *tp)
+static inline int westwood_may_change_cumul(struct tcp_sock *tp)
 {
 	return (tp->westwood.cumul_ack > tp->mss_cache_std);
 }
 
-static inline void westwood_partial_update(struct tcp_opt *tp)
+static inline void westwood_partial_update(struct tcp_sock *tp)
 {
 	tp->westwood.accounted -= tp->westwood.cumul_ack;
 	tp->westwood.cumul_ack = tp->mss_cache_std;
 }
 
-static inline void westwood_complete_update(struct tcp_opt *tp)
+static inline void westwood_complete_update(struct tcp_sock *tp)
 {
 	tp->westwood.cumul_ack -= tp->westwood.accounted;
 	tp->westwood.accounted = 0;
@@ -2836,7 +2837,7 @@
 
 static inline __u32 westwood_acked_count(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->westwood.cumul_ack = westwood_acked(sk);
 
@@ -2869,7 +2870,7 @@
 
 void __tcp_westwood_slow_bw(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	westwood_update_window(sk, tcp_time_stamp);
 
@@ -2880,7 +2881,7 @@
 /* This routine deals with incoming acks, but not outgoing ones. */
 static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 prior_snd_una = tp->snd_una;
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
@@ -2985,7 +2986,7 @@
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
-void tcp_parse_options(struct sk_buff *skb, struct tcp_opt *tp, int estab)
+void tcp_parse_options(struct sk_buff *skb, struct tcp_sock *tp, int estab)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = skb->h.th;
@@ -3070,7 +3071,8 @@
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
  */
-static __inline__ int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th, struct tcp_opt *tp)
+static inline int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
+					 struct tcp_sock *tp)
 {
 	if (th->doff == sizeof(struct tcphdr)>>2) {
 		tp->saw_tstamp = 0;
@@ -3092,15 +3094,13 @@
 	return 1;
 }
 
-static __inline__ void
-tcp_store_ts_recent(struct tcp_opt *tp)
+static inline void tcp_store_ts_recent(struct tcp_sock *tp)
 {
 	tp->ts_recent = tp->rcv_tsval;
 	tp->ts_recent_stamp = xtime.tv_sec;
 }
 
-static __inline__ void
-tcp_replace_ts_recent(struct tcp_opt *tp, u32 seq)
+static inline void tcp_replace_ts_recent(struct tcp_sock *tp, u32 seq)
 {
 	if (tp->saw_tstamp && !after(seq, tp->rcv_wup)) {
 		/* PAWS bug workaround wrt. ACK frames, the PAWS discard
@@ -3139,7 +3139,7 @@
  * up to bandwidth of 18Gigabit/sec. 8) ]
  */
 
-static int tcp_disordered_ack(struct tcp_opt *tp, struct sk_buff *skb)
+static int tcp_disordered_ack(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	struct tcphdr *th = skb->h.th;
 	u32 seq = TCP_SKB_CB(skb)->seq;
@@ -3158,7 +3158,7 @@
 		(s32)(tp->ts_recent - tp->rcv_tsval) <= (tp->rto*1024)/HZ);
 }
 
-static __inline__ int tcp_paws_discard(struct tcp_opt *tp, struct sk_buff *skb)
+static inline int tcp_paws_discard(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	return ((s32)(tp->ts_recent - tp->rcv_tsval) > TCP_PAWS_WINDOW &&
 		xtime.tv_sec < tp->ts_recent_stamp + TCP_PAWS_24DAYS &&
@@ -3178,7 +3178,7 @@
  * (borrowed from freebsd)
  */
 
-static inline int tcp_sequence(struct tcp_opt *tp, u32 seq, u32 end_seq)
+static inline int tcp_sequence(struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	return	!before(end_seq, tp->rcv_wup) &&
 		!after(seq, tp->rcv_nxt + tcp_receive_window(tp));
@@ -3223,7 +3223,7 @@
  */
 static void tcp_fin(struct sk_buff *skb, struct sock *sk, struct tcphdr *th)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_schedule_ack(tp);
 
@@ -3303,7 +3303,7 @@
 	return 0;
 }
 
-static __inline__ void tcp_dsack_set(struct tcp_opt *tp, u32 seq, u32 end_seq)
+static inline void tcp_dsack_set(struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	if (tp->sack_ok && sysctl_tcp_dsack) {
 		if (before(seq, tp->rcv_nxt))
@@ -3318,7 +3318,7 @@
 	}
 }
 
-static __inline__ void tcp_dsack_extend(struct tcp_opt *tp, u32 seq, u32 end_seq)
+static inline void tcp_dsack_extend(struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	if (!tp->dsack)
 		tcp_dsack_set(tp, seq, end_seq);
@@ -3328,7 +3328,7 @@
 
 static void tcp_send_dupack(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 	    before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
@@ -3350,7 +3350,7 @@
 /* These routines update the SACK block as out-of-order packets arrive or
  * in-order packets close up the sequence space.
  */
-static void tcp_sack_maybe_coalesce(struct tcp_opt *tp)
+static void tcp_sack_maybe_coalesce(struct tcp_sock *tp)
 {
 	int this_sack;
 	struct tcp_sack_block *sp = &tp->selective_acks[0];
@@ -3391,7 +3391,7 @@
 
 static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_sack_block *sp = &tp->selective_acks[0];
 	int cur_sacks = tp->num_sacks;
 	int this_sack;
@@ -3434,7 +3434,7 @@
 
 /* RCV.NXT advances, some SACKs should be eaten. */
 
-static void tcp_sack_remove(struct tcp_opt *tp)
+static void tcp_sack_remove(struct tcp_sock *tp)
 {
 	struct tcp_sack_block *sp = &tp->selective_acks[0];
 	int num_sacks = tp->num_sacks;
@@ -3475,7 +3475,7 @@
  */
 static void tcp_ofo_queue(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 dsack_high = tp->rcv_nxt;
 	struct sk_buff *skb;
 
@@ -3513,7 +3513,7 @@
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = skb->h.th;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int eaten = -1;
 
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
@@ -3821,7 +3821,7 @@
  */
 static void tcp_collapse_ofo_queue(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = skb_peek(&tp->out_of_order_queue);
 	struct sk_buff *head;
 	u32 start, end;
@@ -3866,7 +3866,7 @@
  */
 static int tcp_prune_queue(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk); 
+	struct tcp_sock *tp = tcp_sk(sk); 
 
 	SOCK_DEBUG(sk, "prune_queue: c=%x\n", tp->copied_seq);
 
@@ -3926,7 +3926,7 @@
  */
 void tcp_cwnd_application_limited(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tp->ca_state == TCP_CA_Open &&
 	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
@@ -3950,7 +3950,7 @@
  */
 static void tcp_new_space(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_get_pcount(&tp->packets_out) < tp->snd_cwnd &&
 	    !(sk->sk_userlocks & SOCK_SNDBUF_LOCK) &&
@@ -3981,7 +3981,7 @@
 
 static void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd) ||
 	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
@@ -4003,7 +4003,7 @@
  */
 static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	    /* More than one full frame received... */
 	if (((tp->rcv_nxt - tp->rcv_wup) > tp->ack.rcv_mss
@@ -4026,7 +4026,7 @@
 
 static __inline__ void tcp_ack_snd_check(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	if (!tcp_ack_scheduled(tp)) {
 		/* We sent a data segment already. */
 		return;
@@ -4046,7 +4046,7 @@
  
 static void tcp_check_urg(struct sock * sk, struct tcphdr * th)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 ptr = ntohs(th->urg_ptr);
 
 	if (ptr && !sysctl_tcp_stdurg)
@@ -4113,7 +4113,7 @@
 /* This is the 'fast' part of urgent handling. */
 static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Check if we get a new urgent pointer - normally not. */
 	if (th->urg)
@@ -4138,7 +4138,7 @@
 
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int chunk = skb->len - hlen;
 	int err;
 
@@ -4206,7 +4206,7 @@
 int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			struct tcphdr *th, unsigned len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/*
 	 *	Header prediction.
@@ -4456,7 +4456,7 @@
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int saved_clamp = tp->mss_clamp;
 
 	tcp_parse_options(skb, tp, 0);
@@ -4701,7 +4701,7 @@
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			  struct tcphdr *th, unsigned len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int queued = 0;
 
 	tp->saw_tstamp = 0;
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv4/tcp_ipv4.c	2004-12-28 16:36:53 -02:00
@@ -568,7 +568,7 @@
 		tw = (struct tcp_tw_bucket *)sk2;
 
 		if (TCP_IPV4_TW_MATCH(sk2, acookie, saddr, daddr, ports, dif)) {
-			struct tcp_opt *tp = tcp_sk(sk);
+			struct tcp_sock *tp = tcp_sk(sk);
 
 			/* With PAWS, it is safe from the viewpoint
 			   of data integrity. Even without PAWS it
@@ -744,7 +744,7 @@
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	struct rtable *rt;
 	u32 daddr, nexthop;
@@ -867,7 +867,7 @@
 	return (jhash_2words(raddr, (u32) rport, rnd) & (TCP_SYNQ_HSIZE - 1));
 }
 
-static struct open_request *tcp_v4_search_req(struct tcp_opt *tp,
+static struct open_request *tcp_v4_search_req(struct tcp_sock *tp,
 					      struct open_request ***prevp,
 					      __u16 rport,
 					      __u32 raddr, __u32 laddr)
@@ -893,7 +893,7 @@
 
 static void tcp_v4_synq_add(struct sock *sk, struct open_request *req)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt = tp->listen_opt;
 	u32 h = tcp_v4_synq_hash(req->af.v4_req.rmt_addr, req->rmt_port, lopt->hash_rnd);
 
@@ -918,7 +918,7 @@
 {
 	struct dst_entry *dst;
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* We are not interested in TCP_LISTEN and open_requests (SYN-ACKs
 	 * send out by Linux are always <576bytes so they should go through
@@ -979,7 +979,7 @@
 {
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
-	struct tcp_opt *tp;
+	struct tcp_sock *tp;
 	struct inet_sock *inet;
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
@@ -1393,7 +1393,7 @@
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt tp;
+	struct tcp_sock tp;
 	struct open_request *req;
 	__u32 saddr = skb->nh.iph->saddr;
 	__u32 daddr = skb->nh.iph->daddr;
@@ -1550,7 +1550,7 @@
 				  struct dst_entry *dst)
 {
 	struct inet_sock *newinet;
-	struct tcp_opt *newtp;
+	struct tcp_sock *newtp;
 	struct sock *newsk;
 
 	if (sk_acceptq_is_full(sk))
@@ -1602,7 +1602,7 @@
 {
 	struct tcphdr *th = skb->h.th;
 	struct iphdr *iph = skb->nh.iph;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sock *nsk;
 	struct open_request **prev;
 	/* Find possible connection requests. */
@@ -1972,7 +1972,7 @@
 int tcp_v4_remember_stamp(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct rtable *rt = (struct rtable *)__sk_dst_get(sk);
 	struct inet_peer *peer = NULL;
 	int release_it = 0;
@@ -2040,7 +2040,7 @@
  */
 static int tcp_v4_init_sock(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
@@ -2082,7 +2082,7 @@
 
 int tcp_v4_destroy_sock(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_clear_xmit_timers(sk);
 
@@ -2131,7 +2131,7 @@
 
 static void *listening_get_next(struct seq_file *seq, void *cur)
 {
-	struct tcp_opt *tp;
+	struct tcp_sock *tp;
 	struct hlist_node *node;
 	struct sock *sk = cur;
 	struct tcp_iter_state* st = seq->private;
@@ -2368,7 +2368,7 @@
 	switch (st->state) {
 	case TCP_SEQ_STATE_OPENREQ:
 		if (v) {
-			struct tcp_opt *tp = tcp_sk(st->syn_wait_sk);
+			struct tcp_sock *tp = tcp_sk(st->syn_wait_sk);
 			read_unlock_bh(&tp->syn_wait_lock);
 		}
 	case TCP_SEQ_STATE_LISTENING:
@@ -2473,7 +2473,7 @@
 {
 	int timer_active;
 	unsigned long timer_expires;
-	struct tcp_opt *tp = tcp_sk(sp);
+	struct tcp_sock *tp = tcp_sk(sp);
 	struct inet_sock *inet = inet_sk(sp);
 	unsigned int dest = inet->daddr;
 	unsigned int src = inet->rcv_saddr;
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-12-28 16:36:54 -02:00
+++ b/net/ipv4/tcp_minisocks.c	2004-12-28 16:36:54 -02:00
@@ -123,7 +123,7 @@
 tcp_timewait_state_process(struct tcp_tw_bucket *tw, struct sk_buff *skb,
 			   struct tcphdr *th, unsigned len)
 {
-	struct tcp_opt tp;
+	struct tcp_sock tp;
 	int paws_reject = 0;
 
 	tp.saw_tstamp = 0;
@@ -327,7 +327,7 @@
 void tcp_time_wait(struct sock *sk, int state, int timeo)
 {
 	struct tcp_tw_bucket *tw = NULL;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int recycle_ok = 0;
 
 	if (sysctl_tcp_tw_recycle && tp->ts_recent_stamp)
@@ -690,7 +690,7 @@
 	struct sock *newsk = sk_alloc(PF_INET, GFP_ATOMIC, 0, sk->sk_prot->slab);
 
 	if(newsk != NULL) {
-		struct tcp_opt *newtp;
+		struct tcp_sock *newtp;
 		struct sk_filter *filter;
 
 		memcpy(newsk, sk, sizeof(struct tcp_sock));
@@ -734,7 +734,7 @@
 			return NULL;
 		}
 
-		/* Now setup tcp_opt */
+		/* Now setup tcp_sock */
 		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
 		newtp->rcv_nxt = req->rcv_isn + 1;
@@ -858,10 +858,10 @@
 			   struct open_request **prev)
 {
 	struct tcphdr *th = skb->h.th;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
-	struct tcp_opt ttp;
+	struct tcp_sock ttp;
 	struct sock *child;
 
 	ttp.saw_tstamp = 0;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-12-28 16:36:54 -02:00
+++ b/net/ipv4/tcp_output.c	2004-12-28 16:36:54 -02:00
@@ -51,8 +51,8 @@
  */
 int sysctl_tcp_tso_win_divisor = 8;
 
-static __inline__
-void update_send_head(struct sock *sk, struct tcp_opt *tp, struct sk_buff *skb)
+static inline void update_send_head(struct sock *sk, struct tcp_sock *tp,
+				    struct sk_buff *skb)
 {
 	sk->sk_send_head = skb->next;
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
@@ -67,7 +67,7 @@
  * Anything in between SND.UNA...SND.UNA+SND.WND also can be already
  * invalid. OK, let's make this for now:
  */
-static __inline__ __u32 tcp_acceptable_seq(struct sock *sk, struct tcp_opt *tp)
+static inline __u32 tcp_acceptable_seq(struct sock *sk, struct tcp_sock *tp)
 {
 	if (!before(tp->snd_una+tp->snd_wnd, tp->snd_nxt))
 		return tp->snd_nxt;
@@ -91,7 +91,7 @@
  */
 static __u16 tcp_advertise_mss(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	int mss = tp->advmss;
 
@@ -105,7 +105,7 @@
 
 /* RFC2861. Reset CWND after idle period longer RTO to "restart window".
  * This is the first part of cwnd validation mechanism. */
-static void tcp_cwnd_restart(struct tcp_opt *tp, struct dst_entry *dst)
+static void tcp_cwnd_restart(struct tcp_sock *tp, struct dst_entry *dst)
 {
 	s32 delta = tcp_time_stamp - tp->lsndtime;
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
@@ -124,7 +124,8 @@
 	tp->snd_cwnd_used = 0;
 }
 
-static __inline__ void tcp_event_data_sent(struct tcp_opt *tp, struct sk_buff *skb, struct sock *sk)
+static inline void tcp_event_data_sent(struct tcp_sock *tp,
+				       struct sk_buff *skb, struct sock *sk)
 {
 	u32 now = tcp_time_stamp;
 
@@ -143,7 +144,7 @@
 
 static __inline__ void tcp_event_ack_sent(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_dec_quickack_mode(tp);
 	tcp_clear_xmit_timer(sk, TCP_TIME_DACK);
@@ -208,14 +209,14 @@
 	(*window_clamp) = min(65535U << (*rcv_wscale), *window_clamp);
 }
 
-/* Chose a new window to advertise, update state in tcp_opt for the
+/* Chose a new window to advertise, update state in tcp_sock for the
  * socket, and return result with RFC1323 scaling applied.  The return
  * value can be stuffed directly into th->window for an outgoing
  * frame.
  */
 static __inline__ u16 tcp_select_window(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 cur_win = tcp_receive_window(tp);
 	u32 new_win = __tcp_select_window(sk);
 
@@ -267,7 +268,7 @@
 {
 	if (skb != NULL) {
 		struct inet_sock *inet = inet_sk(sk);
-		struct tcp_opt *tp = tcp_sk(sk);
+		struct tcp_sock *tp = tcp_sk(sk);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 		int tcp_header_size = tp->tcp_header_len;
 		struct tcphdr *th;
@@ -396,7 +397,7 @@
  */
 static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Advance write_seq and place onto the write_queue. */
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
@@ -413,7 +414,7 @@
  */
 void tcp_push_one(struct sock *sk, unsigned cur_mss)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = sk->sk_send_head;
 
 	if (tcp_snd_test(tp, skb, cur_mss, TCP_NAGLE_PUSH)) {
@@ -453,7 +454,7 @@
  */
 static int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
 	int nsize;
 	u16 flags;
@@ -619,7 +620,7 @@
 
 unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	int mss_now;
 
@@ -666,7 +667,7 @@
 
 unsigned int tcp_current_mss(struct sock *sk, int large)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	unsigned int do_large, mss_now;
 
@@ -727,7 +728,7 @@
  */
 int tcp_write_xmit(struct sock *sk, int nonagle)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int mss_now;
 
 	/* If we are closed, the bytes will have to remain here.
@@ -831,7 +832,7 @@
  */
 u32 __tcp_select_window(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	/* MSS for the peer's data.  Previous verions used mss_clamp
 	 * here.  I don't know if the value based on our guesses
 	 * of peer's MSS is better for the performance.  It's more correct
@@ -892,7 +893,7 @@
 /* Attempt to collapse two adjacent SKB's during retransmission. */
 static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *next_skb = skb->next;
 
 	/* The first test we must make is that neither of these two
@@ -970,7 +971,7 @@
  */ 
 void tcp_simple_retransmit(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	unsigned int mss = tcp_current_mss(sk, 0);
 	int lost = 0;
@@ -1016,7 +1017,7 @@
  */
 int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
  	unsigned int cur_mss = tcp_current_mss(sk, 0);
 	int err;
 
@@ -1140,7 +1141,7 @@
  */
 void tcp_xmit_retransmit_queue(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int packet_cnt = tcp_get_pcount(&tp->lost_out);
 
@@ -1235,7 +1236,7 @@
  */
 void tcp_send_fin(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);	
+	struct tcp_sock *tp = tcp_sk(sk);	
 	struct sk_buff *skb = skb_peek_tail(&sk->sk_write_queue);
 	int mss_now;
 	
@@ -1281,7 +1282,7 @@
  */
 void tcp_send_active_reset(struct sock *sk, int priority)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
@@ -1346,7 +1347,7 @@
 struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				 struct open_request *req)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
 	int tcp_header_size;
 	struct sk_buff *skb;
@@ -1417,7 +1418,7 @@
 static inline void tcp_connect_init(struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* We'll fix this up when we get a response from the other end.
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
@@ -1466,7 +1467,7 @@
  */ 
 int tcp_connect(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
 
 	tcp_connect_init(sk);
@@ -1510,7 +1511,7 @@
  */
 void tcp_send_delayed_ack(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int ato = tp->ack.ato;
 	unsigned long timeout;
 
@@ -1562,7 +1563,7 @@
 {
 	/* If we have been reset, we may not send again. */
 	if (sk->sk_state != TCP_CLOSE) {
-		struct tcp_opt *tp = tcp_sk(sk);
+		struct tcp_sock *tp = tcp_sk(sk);
 		struct sk_buff *buff;
 
 		/* We are not putting this on the write queue, so
@@ -1605,7 +1606,7 @@
  */
 static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
@@ -1634,7 +1635,7 @@
 int tcp_write_wakeup(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
-		struct tcp_opt *tp = tcp_sk(sk);
+		struct tcp_sock *tp = tcp_sk(sk);
 		struct sk_buff *skb;
 
 		if ((skb = sk->sk_send_head) != NULL &&
@@ -1688,7 +1689,7 @@
  */
 void tcp_send_probe0(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int err;
 
 	err = tcp_write_wakeup(sk);
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2004-12-28 16:36:54 -02:00
+++ b/net/ipv4/tcp_timer.c	2004-12-28 16:36:54 -02:00
@@ -48,7 +48,7 @@
 
 void tcp_init_xmit_timers(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	init_timer(&tp->retransmit_timer);
 	tp->retransmit_timer.function=&tcp_write_timer;
@@ -67,7 +67,7 @@
 
 void tcp_clear_xmit_timers(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->pending = 0;
 	sk_stop_timer(sk, &tp->retransmit_timer);
@@ -101,7 +101,7 @@
  */
 static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int orphans = atomic_read(&tcp_orphan_count);
 
 	/* If peer does not open window for long time, or did not transmit 
@@ -154,7 +154,7 @@
 /* A write timeout has occurred. Process the after effects. */
 static int tcp_write_timeout(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int retry_until;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
@@ -208,7 +208,7 @@
 static void tcp_delack_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock*)data;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -268,7 +268,7 @@
 
 static void tcp_probe_timer(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int max_probes;
 
 	if (tcp_get_pcount(&tp->packets_out) || !sk->sk_send_head) {
@@ -316,7 +316,7 @@
 
 static void tcp_retransmit_timer(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!tcp_get_pcount(&tp->packets_out))
 		goto out;
@@ -418,7 +418,7 @@
 static void tcp_write_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock*)data;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int event;
 
 	bh_lock_sock(sk);
@@ -462,7 +462,7 @@
 
 static void tcp_synack_timer(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt = tp->listen_opt;
 	int max_retries = tp->syn_retries ? : sysctl_tcp_synack_retries;
 	int thresh = max_retries;
@@ -573,7 +573,7 @@
 static void tcp_keepalive_timer (unsigned long data)
 {
 	struct sock *sk = (struct sock *) data;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 elapsed;
 
 	/* Only process if socket is not in use. */
diff -Nru a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
--- a/net/ipv6/ipv6_sockglue.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv6/ipv6_sockglue.c	2004-12-28 16:36:53 -02:00
@@ -164,7 +164,7 @@
 			ipv6_sock_mc_close(sk);
 
 			if (sk->sk_protocol == IPPROTO_TCP) {
-				struct tcp_opt *tp = tcp_sk(sk);
+				struct tcp_sock *tp = tcp_sk(sk);
 
 				local_bh_disable();
 				sock_prot_dec_use(sk->sk_prot);
@@ -281,7 +281,7 @@
 		retv = 0;
 		if (sk->sk_type == SOCK_STREAM) {
 			if (opt) {
-				struct tcp_opt *tp = tcp_sk(sk);
+				struct tcp_sock *tp = tcp_sk(sk);
 				if (!((1 << sk->sk_state) &
 				      (TCPF_LISTEN | TCPF_CLOSE))
 				    && inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2004-12-28 16:36:53 -02:00
+++ b/net/ipv6/tcp_ipv6.c	2004-12-28 16:36:54 -02:00
@@ -235,7 +235,7 @@
 static void tcp_v6_hash(struct sock *sk)
 {
 	if (sk->sk_state != TCP_CLOSE) {
-		struct tcp_opt *tp = tcp_sk(sk);
+		struct tcp_sock *tp = tcp_sk(sk);
 
 		if (tp->af_specific == &ipv6_mapped) {
 			tcp_prot.hash(sk);
@@ -391,7 +391,7 @@
 	return c & (TCP_SYNQ_HSIZE - 1);
 }
 
-static struct open_request *tcp_v6_search_req(struct tcp_opt *tp,
+static struct open_request *tcp_v6_search_req(struct tcp_sock *tp,
 					      struct open_request ***prevp,
 					      __u16 rport,
 					      struct in6_addr *raddr,
@@ -466,7 +466,7 @@
 		   ipv6_addr_equal(&tw->tw_v6_daddr, saddr)	&&
 		   ipv6_addr_equal(&tw->tw_v6_rcv_saddr, daddr)	&&
 		   sk2->sk_bound_dev_if == sk->sk_bound_dev_if) {
-			struct tcp_opt *tp = tcp_sk(sk);
+			struct tcp_sock *tp = tcp_sk(sk);
 
 			if (tw->tw_ts_recent_stamp) {
 				/* See comment in tcp_ipv4.c */
@@ -551,7 +551,7 @@
 	struct sockaddr_in6 *usin = (struct sockaddr_in6 *) uaddr;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct in6_addr *saddr = NULL, *final_p = NULL, final;
 	struct flowi fl;
 	struct dst_entry *dst;
@@ -741,7 +741,7 @@
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
-	struct tcp_opt *tp; 
+	struct tcp_sock *tp; 
 	__u32 seq;
 
 	sk = tcp_v6_lookup(&hdr->daddr, th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
@@ -1146,7 +1146,7 @@
 {
 	struct open_request *req, **prev;
 	struct tcphdr *th = skb->h.th;
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sock *nsk;
 
 	/* Find possible connection requests. */
@@ -1179,7 +1179,7 @@
 
 static void tcp_v6_synq_add(struct sock *sk, struct open_request *req)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt = tp->listen_opt;
 	u32 h = tcp_v6_synq_hash(&req->af.v6_req.rmt_addr, req->rmt_port, lopt->hash_rnd);
 
@@ -1202,7 +1202,7 @@
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_opt tmptp, *tp = tcp_sk(sk);
+	struct tcp_sock tmptp, *tp = tcp_sk(sk);
 	struct open_request *req = NULL;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 
@@ -1282,7 +1282,7 @@
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
 	struct inet_sock *newinet;
-	struct tcp_opt *newtp;
+	struct tcp_sock *newtp;
 	struct sock *newsk;
 	struct ipv6_txoptions *opt;
 
@@ -1297,7 +1297,7 @@
 			return NULL;
 
 		newtcp6sk = (struct tcp6_sock *)newsk;
-		newtcp6sk->inet.pinet6 = &newtcp6sk->inet6;
+		inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
 
 		newinet = inet_sk(newsk);
 		newnp = inet6_sk(newsk);
@@ -1390,7 +1390,7 @@
 		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
-	newtcp6sk->inet.pinet6 = &newtcp6sk->inet6;
+	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
 
 	newtp = tcp_sk(newsk);
 	newinet = inet_sk(newsk);
@@ -1497,7 +1497,7 @@
 static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_opt *tp;
+	struct tcp_sock *tp;
 	struct sk_buff *opt_skb = NULL;
 
 	/* Imagine: socket is IPv6. IPv4 packet arrives,
@@ -1919,7 +1919,7 @@
  */
 static int tcp_v6_init_sock(struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
@@ -2007,7 +2007,7 @@
 	int timer_active;
 	unsigned long timer_expires;
 	struct inet_sock *inet = inet_sk(sp);
-	struct tcp_opt *tp = tcp_sk(sp);
+	struct tcp_sock *tp = tcp_sk(sp);
 	struct ipv6_pinfo *np = inet6_sk(sp);
 
 	dest  = &np->daddr;
diff -Nru a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
--- a/net/sunrpc/svcsock.c	2004-12-28 16:36:53 -02:00
+++ b/net/sunrpc/svcsock.c	2004-12-28 16:36:53 -02:00
@@ -1077,7 +1077,7 @@
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
-	struct tcp_opt  *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	svsk->sk_recvfrom = svc_tcp_recvfrom;
 	svsk->sk_sendto = svc_tcp_sendto;
diff -Nru a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
--- a/net/sunrpc/xprt.c	2004-12-28 16:36:54 -02:00
+++ b/net/sunrpc/xprt.c	2004-12-28 16:36:54 -02:00
@@ -1545,8 +1545,7 @@
 		sk->sk_no_check = UDP_CSUM_NORCV;
 		xprt_set_connected(xprt);
 	} else {
-		struct tcp_opt *tp = tcp_sk(sk);
-		tp->nonagle = 1;	/* disable Nagle's algorithm */
+		tcp_sk(sk)->nonagle = 1;	/* disable Nagle's algorithm */
 		sk->sk_data_ready = tcp_data_ready;
 		sk->sk_state_change = tcp_state_change;
 		xprt_clear_connected(xprt);


--------------010100030105070906050706--
