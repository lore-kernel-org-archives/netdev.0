From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] Super TSO
Date: Thu, 19 May 2005 17:15:18 -0700
Message-ID: <200505200015.j4K0FNVG005262@guinness.s2io.com>
References: <20050517.192416.108741581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050517.192416.108741581.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A somewhat related thought, while we are at it...

It would arguably make sense to allow a NIC to set max TSO size that the
card is 
willing to support (rather than assume/enforce 64k). Some NICs support
bigger max 
TSO size today, but it is even more important to allow a NIC to limit
TSO to a smaller size.

One likely scenario where this feature is desirable is a system with highly
fragmented memory. 
In this case, the number of physical fragments per TSO frame could be always
so high that it will be cheaper 
(on a given platform) to copy the frame than to DMA it. 

In this case, 64k TSO becomes a liability and it will make sense to limit
it.
TSO "sweet spot" will be captured anyways - at least on fast networks, going

from 1.5k to 9k typically doubles throughput, while going from 9k to 64k
adds no more than another 10% 
(plus a little bit of free %cpu, but not that much).

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of David S. Miller
> Sent: Tuesday, May 17, 2005 7:24 PM
> To: netdev@oss.sgi.com
> Subject: [PATCH] Super TSO
> 
> 
> Ok, this implements the idea Herbert and I kicked around last week.
> 
> Basically, we build as large TSO segments as humanly possible.
> Then we slice and dice them to fit the congestion and send 
> windows at transmit time.
> 
> It works remarkably well.  Even application limited cases 
> like "scp" behave nicely.
> 
> During straight streaming tests like "bw_tcp", I see full
> "65535 MOD mss" sized frames going out to my onboard tg3 card 
> once the congestion and send window grow large enough.
> 
> I did some cross-continent (San Francisco --> east coast of 
> US) transfers to make sure TSO stays on when packet drops 
> occur and that performance doesn't suffer compared to TSO 
> being off.  It all looks fine so far.
> 
> There were many bugs discovered along the way.  For example, 
> the old code would use the TSO mss to do nagle calculations.  
> It also would mess up the packet sizing for TSO when SACK 
> blocks were being advertised.
> 
> So we don't have to calculate this "(65535 - headers) % mss" 
> thing all the time, I keep a cache of three pieces of state.  
> MSS, number of SACKS being advertized, and if TSO is enabled 
> or not.  If any of these change, we recalculate the packet 
> building goal size.
> 
> I moved all of the "should we send" logic privately into the 
> file net/ipv4/tcp_output.c, and I am sure there are many 
> simplifications possible.  There are several spurious 
> tcp_current_mss() calls scattered about in certain code paths 
> as well.  For example, some places would call it in order to 
> decide whether to call tcp_write_xmit() or not, then 
> tcp_write_xmit() does it once more.  But there are call sites 
> that do not do this, so tcp_write_xmit() has to do it for those cases.
> 
> Comments?
> 
> --- 1/include/linux/tcp.h.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/include/linux/tcp.h	2005-05-17 11:15:46.000000000 -0700
> @@ -280,13 +280,15 @@ struct tcp_sock {
>  	__u32	snd_wnd;	/* The window we expect to 
> receive	*/
>  	__u32	max_window;	/* Maximal window ever seen 
> from peer	*/
>  	__u32	pmtu_cookie;	/* Last pmtu seen by socket	
> 	*/
> -	__u32	mss_cache;	/* Cached effective mss, not 
> including SACKS */
> -	__u16	mss_cache_std;	/* Like mss_cache, but without TSO */
> +	__u16	mss_cache;	/* Cached effective mss, not 
> including SACKS */
> +	__u16	xmit_size_goal;	/* Goal for segmenting output 
> packets	*/
> +	__u32	xmit_size_cache;/* Cache for keeping 
> xmit_size_goal uptodate */
>  	__u16	ext_header_len;	/* Network protocol overhead 
> (IP/IPv6 options) */
>  	__u8	ca_state;	/* State of fast-retransmit 
> machine 	*/
>  	__u8	retransmits;	/* Number of unrecovered RTO 
> timeouts.	*/
>  
>  	__u16	advmss;		/* Advertised MSS		
> 	*/
> +	__u16	__pad0;
>  	__u32	window_clamp;	/* Maximal window to advertise	
> 	*/
>  	__u32	rcv_ssthresh;	/* Current window clamp		
> 	*/
>  
> --- 1/include/net/tcp.h.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/include/net/tcp.h	2005-05-17 16:44:32.000000000 -0700
> @@ -817,11 +817,18 @@ static inline int tcp_ack_scheduled(stru
>  	return tp->ack.pending&TCP_ACK_SCHED;
>  }
>  
> -static __inline__ void tcp_dec_quickack_mode(struct tcp_sock *tp)
> +static __inline__ void tcp_dec_quickack_mode(struct tcp_sock *tp, 
> +unsigned int pkts)
>  {
> -	if (tp->ack.quick && --tp->ack.quick == 0) {
> -		/* Leaving quickack mode we deflate ATO. */
> -		tp->ack.ato = TCP_ATO_MIN;
> +	if (tp->ack.quick) {
> +		if (pkts > tp->ack.quick)
> +			tp->ack.quick = 0;
> +		else
> +			tp->ack.quick -= pkts;
> +
> +		if (!tp->ack.quick) {
> +			/* Leaving quickack mode we deflate ATO. */
> +			tp->ack.ato = TCP_ATO_MIN;
> +		}
>  	}
>  }
>  
> @@ -939,7 +946,14 @@ extern __u32 cookie_v4_init_sequence(str
>  
>  /* tcp_output.c */
>  
> -extern int tcp_write_xmit(struct sock *, int nonagle);
> +extern void __tcp_data_snd_check(struct sock *sk, struct 
> sk_buff *skb); 
> +extern void __tcp_push_pending_frames(struct sock *sk,
> +				      struct tcp_sock *tp,
> +				      unsigned int cur_mss,
> +				      int nonagle);
> +extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp); 
> +extern int tcp_tso_mince(struct sock *sk, struct tcp_sock *tp,
> +			 struct sk_buff *skb);
>  extern int tcp_retransmit_skb(struct sock *, struct sk_buff 
> *);  extern void tcp_xmit_retransmit_queue(struct sock *);  
> extern void tcp_simple_retransmit(struct sock *); @@ -951,7 
> +965,7 @@ extern int  tcp_write_wakeup(struct sock  extern 
> void tcp_send_fin(struct sock *sk);  extern void 
> tcp_send_active_reset(struct sock *sk, int priority);  extern 
> int  tcp_send_synack(struct sock *); -extern void 
> tcp_push_one(struct sock *, unsigned mss_now);
> +extern void tcp_push_one(struct sock *, unsigned int mss_now);
>  extern void tcp_send_ack(struct sock *sk);  extern void 
> tcp_send_delayed_ack(struct sock *sk);
>  
> @@ -1054,7 +1068,7 @@ static inline void 
> tcp_reset_xmit_timer(  static inline void 
> tcp_initialize_rcv_mss(struct sock *sk)  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	unsigned int hint = min(tp->advmss, tp->mss_cache_std);
> +	unsigned int hint = min(tp->advmss, tp->mss_cache);
>  
>  	hint = min(hint, tp->rcv_wnd/2);
>  	hint = min(hint, TCP_MIN_RCVMSS);
> @@ -1353,23 +1367,23 @@ static inline void tcp_cwnd_validate(str  }
>  
>  /* Set slow start threshould and cwnd not falling to slow 
> start */ -static inline void __tcp_enter_cwr(struct tcp_sock *tp)
> +static inline void __tcp_enter_cwr(struct tcp_sock *tp, unsigned int 
> +pkts)
>  {
>  	tp->undo_marker = 0;
>  	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
>  	tp->snd_cwnd = min(tp->snd_cwnd,
> -			   tcp_packets_in_flight(tp) + 1U);
> +			   tcp_packets_in_flight(tp) + pkts);
>  	tp->snd_cwnd_cnt = 0;
>  	tp->high_seq = tp->snd_nxt;
>  	tp->snd_cwnd_stamp = tcp_time_stamp;
>  	TCP_ECN_queue_cwr(tp);
>  }
>  
> -static inline void tcp_enter_cwr(struct tcp_sock *tp)
> +static inline void tcp_enter_cwr(struct tcp_sock *tp, unsigned int 
> +pkts)
>  {
>  	tp->prior_ssthresh = 0;
>  	if (tp->ca_state < TCP_CA_CWR) {
> -		__tcp_enter_cwr(tp);
> +		__tcp_enter_cwr(tp, pkts);
>  		tcp_set_ca_state(tp, TCP_CA_CWR);
>  	}
>  }
> @@ -1397,74 +1411,6 @@ static __inline__ void tcp_minshall_upda
>  		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;  }
>  
> -/* Return 0, if packet can be sent now without violation 
> Nagle's rules:
> -   1. It is full sized.
> -   2. Or it contains FIN.
> -   3. Or TCP_NODELAY was set.
> -   4. Or TCP_CORK is not set, and all sent packets are ACKed.
> -      With Minshall's modification: all sent small packets are ACKed.
> - */
> -
> -static __inline__ int
> -tcp_nagle_check(const struct tcp_sock *tp, const struct 
> sk_buff *skb, 
> -		unsigned mss_now, int nonagle)
> -{
> -	return (skb->len < mss_now &&
> -		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
> -		((nonagle&TCP_NAGLE_CORK) ||
> -		 (!nonagle &&
> -		  tp->packets_out &&
> -		  tcp_minshall_check(tp))));
> -}
> -
> -extern void tcp_set_skb_tso_segs(struct sock *, struct sk_buff *);
> -
> -/* This checks if the data bearing packet SKB (usually 
> sk->sk_send_head)
> - * should be put on the wire right now.
> - */
> -static __inline__ int tcp_snd_test(struct sock *sk,
> -				   struct sk_buff *skb,
> -				   unsigned cur_mss, int nonagle)
> -{
> -	struct tcp_sock *tp = tcp_sk(sk);
> -	int pkts = tcp_skb_pcount(skb);
> -
> -	if (!pkts) {
> -		tcp_set_skb_tso_segs(sk, skb);
> -		pkts = tcp_skb_pcount(skb);
> -	}
> -
> -	/*	RFC 1122 - section 4.2.3.4
> -	 *
> -	 *	We must queue if
> -	 *
> -	 *	a) The right edge of this frame exceeds the window
> -	 *	b) There are packets in flight and we have a 
> small segment
> -	 *	   [SWS avoidance and Nagle algorithm]
> -	 *	   (part of SWS is done on packetization)
> -	 *	   Minshall version sounds: there are no _small_
> -	 *	   segments in flight. (tcp_nagle_check)
> -	 *	c) We have too many packets 'in flight'
> -	 *
> -	 * 	Don't use the nagle rule for urgent data (or
> -	 *	for the final FIN -DaveM).
> -	 *
> -	 *	Also, Nagle rule does not apply to frames, which
> -	 *	sit in the middle of queue (they have no chances
> -	 *	to get new data) and if room at tail of skb is
> -	 *	not enough to save something seriously (<32 for now).
> -	 */
> -
> -	/* Don't be strict about the congestion window for the
> -	 * final FIN frame.  -DaveM
> -	 */
> -	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
> -		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
> -		(((tcp_packets_in_flight(tp) + (pkts-1)) < 
> tp->snd_cwnd) ||
> -		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
> -		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + 
> tp->snd_wnd));
> -}
> -
>  static __inline__ void tcp_check_probe_timer(struct sock 
> *sk, struct tcp_sock *tp)  {
>  	if (!tp->packets_out && !tp->pending)
> @@ -1477,42 +1423,12 @@ static __inline__ int tcp_skb_is_last(co
>  	return skb->next == (struct sk_buff *)&sk->sk_write_queue;  }
>  
> -/* Push out any pending frames which were held back due to
> - * TCP_CORK or attempt at coalescing tiny packets.
> - * The socket must be locked by the caller.
> - */
> -static __inline__ void __tcp_push_pending_frames(struct sock *sk,
> -						 struct tcp_sock *tp,
> -						 unsigned cur_mss,
> -						 int nonagle)
> -{
> -	struct sk_buff *skb = sk->sk_send_head;
> -
> -	if (skb) {
> -		if (!tcp_skb_is_last(sk, skb))
> -			nonagle = TCP_NAGLE_PUSH;
> -		if (!tcp_snd_test(sk, skb, cur_mss, nonagle) ||
> -		    tcp_write_xmit(sk, nonagle))
> -			tcp_check_probe_timer(sk, tp);
> -	}
> -	tcp_cwnd_validate(sk, tp);
> -}
> -
>  static __inline__ void tcp_push_pending_frames(struct sock *sk,
>  					       struct tcp_sock *tp)
>  {
>  	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 
> 1), tp->nonagle);  }
>  
> -static __inline__ int tcp_may_send_now(struct sock *sk, 
> struct tcp_sock *tp) -{
> -	struct sk_buff *skb = sk->sk_send_head;
> -
> -	return (skb &&
> -		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
> -			     tcp_skb_is_last(sk, skb) ? 
> TCP_NAGLE_PUSH : tp->nonagle));
> -}
> -
>  static __inline__ void tcp_init_wl(struct tcp_sock *tp, u32 
> ack, u32 seq)  {
>  	tp->snd_wl1 = seq;
> @@ -1986,7 +1902,7 @@ static inline void 
> tcp_westwood_update_r  static inline __u32 
> __tcp_westwood_bw_rttmin(const struct tcp_sock *tp)  {
>          return max((tp->westwood.bw_est) * (tp->westwood.rtt_min) /
> -		   (__u32) (tp->mss_cache_std),
> +		   (__u32) (tp->mss_cache),
>  		   2U);
>  }
>  
> --- 1/include/net/sock.h.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/include/net/sock.h	2005-05-17 12:06:44.000000000 -0700
> @@ -1130,13 +1130,16 @@ static inline void 
> sk_stream_moderate_sn  static inline struct sk_buff 
> *sk_stream_alloc_pskb(struct sock *sk,
>  						   int size, 
> int mem, int gfp)
>  {
> -	struct sk_buff *skb = alloc_skb(size + 
> sk->sk_prot->max_header, gfp);
> +	struct sk_buff *skb;
> +	int hdr_len;
>  
> +	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
> +	skb = alloc_skb(size + hdr_len, gfp);
>  	if (skb) {
>  		skb->truesize += mem;
>  		if (sk->sk_forward_alloc >= (int)skb->truesize ||
>  		    sk_stream_mem_schedule(sk, skb->truesize, 0)) {
> -			skb_reserve(skb, sk->sk_prot->max_header);
> +			skb_reserve(skb, hdr_len);
>  			return skb;
>  		}
>  		__kfree_skb(skb);
> --- 1/net/ipv4/tcp_output.c.~1~	2005-05-16 
> 22:29:56.000000000 -0700
> +++ 2/net/ipv4/tcp_output.c	2005-05-17 19:14:23.000000000 -0700
> @@ -141,11 +141,11 @@ static inline void tcp_event_data_sent(s
>  		tp->ack.pingpong = 1;
>  }
>  
> -static __inline__ void tcp_event_ack_sent(struct sock *sk)
> +static __inline__ void tcp_event_ack_sent(struct sock *sk, 
> unsigned int 
> +pkts)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  
> -	tcp_dec_quickack_mode(tp);
> +	tcp_dec_quickack_mode(tp, pkts);
>  	tcp_clear_xmit_timer(sk, TCP_TIME_DACK);  }
>  
> @@ -361,7 +361,7 @@ static int tcp_transmit_skb(struct sock 
>  		tp->af_specific->send_check(sk, th, skb->len, skb);
>  
>  		if (tcb->flags & TCPCB_FLAG_ACK)
> -			tcp_event_ack_sent(sk);
> +			tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
>  
>  		if (skb->len != tcp_header_size)
>  			tcp_event_data_sent(tp, skb, sk);
> @@ -372,7 +372,7 @@ static int tcp_transmit_skb(struct sock 
>  		if (err <= 0)
>  			return err;
>  
> -		tcp_enter_cwr(tp);
> +		tcp_enter_cwr(tp, tcp_skb_pcount(skb));
>  
>  		/* NET_XMIT_CN is special. It does not guarantee,
>  		 * that this packet is lost. It tells that 
> device @@ -419,32 +419,11 @@ static inline void tcp_tso_set_push(stru
>  		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;  }
>  
> -/* Send _single_ skb sitting at the send head. This function requires
> - * true push pending frames to setup probe timer etc.
> - */
> -void tcp_push_one(struct sock *sk, unsigned cur_mss) -{
> -	struct tcp_sock *tp = tcp_sk(sk);
> -	struct sk_buff *skb = sk->sk_send_head;
> -
> -	if (tcp_snd_test(sk, skb, cur_mss, TCP_NAGLE_PUSH)) {
> -		/* Send it out now. */
> -		TCP_SKB_CB(skb)->when = tcp_time_stamp;
> -		tcp_tso_set_push(skb);
> -		if (!tcp_transmit_skb(sk, skb_clone(skb, 
> sk->sk_allocation))) {
> -			sk->sk_send_head = NULL;
> -			tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
> -			tcp_packets_out_inc(sk, tp, skb);
> -			return;
> -		}
> -	}
> -}
> -
>  void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb)  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  
> -	if (skb->len <= tp->mss_cache_std ||
> +	if (skb->len <= tp->mss_cache ||
>  	    !(sk->sk_route_caps & NETIF_F_TSO)) {
>  		/* Avoid the costly divide in the normal
>  		 * non-TSO case.
> @@ -454,10 +433,10 @@ void tcp_set_skb_tso_segs(struct sock *s
>  	} else {
>  		unsigned int factor;
>  
> -		factor = skb->len + (tp->mss_cache_std - 1);
> -		factor /= tp->mss_cache_std;
> +		factor = skb->len + (tp->mss_cache - 1);
> +		factor /= tp->mss_cache;
>  		skb_shinfo(skb)->tso_segs = factor;
> -		skb_shinfo(skb)->tso_size = tp->mss_cache_std;
> +		skb_shinfo(skb)->tso_size = tp->mss_cache;
>  	}
>  }
>  
> @@ -662,7 +641,7 @@ unsigned int tcp_sync_mss(struct sock *s
>  
>  	/* And store cached results */
>  	tp->pmtu_cookie = pmtu;
> -	tp->mss_cache = tp->mss_cache_std = mss_now;
> +	tp->mss_cache = mss_now;
>  
>  	return mss_now;
>  }
> @@ -674,59 +653,274 @@ unsigned int tcp_sync_mss(struct sock *s
>   * cannot be large. However, taking into account rare use of 
> URG, this
>   * is not a big flaw.
>   */
> +static inline u32 compute_xmit_cache(u32 mss, int sacks, int 
> +tso_enabled) {
> +	u32 ret = (mss << 16) | sacks;
> +
> +	if (tso_enabled)
> +		ret |= (1 << 8);
> +
> +	return ret;
> +}
>  
> -unsigned int tcp_current_mss(struct sock *sk, int large)
> +unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct dst_entry *dst = __sk_dst_get(sk);
> -	unsigned int do_large, mss_now;
> +	u32 mss_now;
> +	u32 xmit_cache;
> +	int doing_tso = 0;
> +
> +	mss_now = tp->mss_cache;
> +
> +	if (large_allowed &&
> +	    (sk->sk_route_caps & NETIF_F_TSO) &&
> +	    !tp->urg_mode)
> +		doing_tso = 1;
>  
> -	mss_now = tp->mss_cache_std;
>  	if (dst) {
>  		u32 mtu = dst_mtu(dst);
>  		if (mtu != tp->pmtu_cookie)
>  			mss_now = tcp_sync_mss(sk, mtu);
>  	}
>  
> -	do_large = (large &&
> -		    (sk->sk_route_caps & NETIF_F_TSO) &&
> -		    !tp->urg_mode);
> -
> -	if (do_large) {
> -		unsigned int large_mss, factor, limit;
> -
> -		large_mss = 65535 - tp->af_specific->net_header_len -
> -			tp->ext_header_len - tp->tcp_header_len;
> -
> -		if (tp->max_window && large_mss > (tp->max_window>>1))
> -			large_mss = max((tp->max_window>>1),
> -					68U - tp->tcp_header_len);
> -
> -		factor = large_mss / mss_now;
> -
> -		/* Always keep large mss multiple of real mss, but
> -		 * do not exceed 1/tso_win_divisor of the 
> congestion window
> -		 * so we can keep the ACK clock ticking and minimize
> -		 * bursting.
> -		 */
> -		limit = tp->snd_cwnd;
> -		if (sysctl_tcp_tso_win_divisor)
> -			limit /= sysctl_tcp_tso_win_divisor;
> -		limit = max(1U, limit);
> -		if (factor > limit)
> -			factor = limit;
> -
> -		tp->mss_cache = mss_now * factor;
> -
> -		mss_now = tp->mss_cache;
> -	}
> +	/* If the MSS, the TSO state, or the number of SACK blocks
> +	 * changes, we have to recompute tp->xmit_size_goal.
> +	 */
> +	xmit_cache = compute_xmit_cache(mss_now, tp->rx_opt.eff_sacks,
> +					doing_tso);
>  
>  	if (tp->rx_opt.eff_sacks)
>  		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
>  			    (tp->rx_opt.eff_sacks * 
> TCPOLEN_SACK_PERBLOCK));
> +
> +	if (tp->xmit_size_cache != xmit_cache) {
> +		u16 xmit_size_goal = mss_now;
> +
> +		if (doing_tso) {
> +			xmit_size_goal = 65535 -
> +				tp->af_specific->net_header_len -
> +				tp->ext_header_len - tp->tcp_header_len;
> +
> +			if (tp->rx_opt.eff_sacks)
> +				xmit_size_goal -= 
> (TCPOLEN_SACK_BASE_ALIGNED +
> +						   
> (tp->rx_opt.eff_sacks *
> +						    
> TCPOLEN_SACK_PERBLOCK));
> +
> +			xmit_size_goal -= (xmit_size_goal % mss_now);
> +		}
> +		tp->xmit_size_goal = xmit_size_goal;
> +		tp->xmit_size_cache = xmit_cache;
> +	}
> +
>  	return mss_now;
>  }
>  
> +/* This must be invoked the first time we consider transmitting
> + * SKB onto the wire.
> + */
> +static inline int tcp_init_tso_segs(struct sock *sk, struct sk_buff 
> +*skb) {
> +	int tso_segs = tcp_skb_pcount(skb);
> +
> +	if (!tso_segs) {
> +		tcp_set_skb_tso_segs(sk, skb);
> +		tso_segs = tcp_skb_pcount(skb);
> +	}
> +	return tso_segs;
> +}
> +
> +/* Return 0, if packet can be sent now without violation 
> Nagle's rules:
> + * 1. It is full sized.
> + * 2. Or it contains FIN.
> + * 3. Or TCP_NODELAY was set.
> + * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
> + *    With Minshall's modification: all sent small packets are ACKed.
> + */
> +
> +static inline int tcp_nagle_check(const struct tcp_sock *tp,
> +				  const struct sk_buff *skb, 
> +				  unsigned mss_now, int nonagle)
> +{
> +	return (skb->len < mss_now &&
> +		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
> +		((nonagle&TCP_NAGLE_CORK) ||
> +		 (!nonagle &&
> +		  tp->packets_out &&
> +		  tcp_minshall_check(tp))));
> +}
> +
> +/* Return non-zero if the Nagle test allows this packet to be
> + * sent now.
> + */
> +static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff 
> +*skb, unsigned int cur_mss, int nonagle) {
> +	/* Nagle rule does not apply to frames, which
> +	 * sit in the middle of queue (they have no chances
> +	 * to get new data) and if room at tail of skb is
> +	 * not enough to save something seriously (<32 for now).
> +	 *
> +	 * This is implemented in the callers, where they modify
> +	 * the 'nonagle' argument based upon the location of SKB
> +	 * in the send queue.
> +	 */
> +	if (nonagle & TCP_NAGLE_PUSH)
> +		return 1;
> +
> +	/* Don't use the nagle rule for urgent data (or
> +	 * for the final FIN -DaveM).
> +	 */
> +	if (tp->urg_mode ||
> +	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
> +		return 1;
> +
> +	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +/* Can at least one segment of SKB be sent right now, according
> + * to the congestion window rules?  If so, return how many segments
> + * are allowed.
> + */
> +static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp, struct 
> +sk_buff *skb) {
> +	u32 in_flight, cwnd;
> +
> +	/* Don't be strict about the congestion window for the
> +	 * final FIN frame.  -DaveM
> +	 */
> +	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
> +		return 1;
> +
> +	in_flight = tcp_packets_in_flight(tp);
> +	cwnd = tp->snd_cwnd;
> +	if (in_flight < cwnd)
> +		return (cwnd - in_flight);
> +
> +	return 0;
> +}
> +
> +/* Does at least the first segment of SKB fit into the congestion
> + * window?
> + */
> +static inline int tcp_snd_wnd_test(struct tcp_sock *tp, 
> struct sk_buff 
> +*skb, unsigned int cur_mss) {
> +	u32 end_seq = TCP_SKB_CB(skb)->end_seq;
> +
> +	if (skb->len > cur_mss)
> +		end_seq = TCP_SKB_CB(skb)->seq + cur_mss;
> +
> +	return !after(end_seq, tp->snd_una + tp->snd_wnd); }
> +
> +/* This checks if the data bearing packet SKB (usually
> + * sk->sk_send_head) should be put on the wire right now.  If so, it
> + * returns the number of packets allowed by the congestion window.
> + */
> +static unsigned int tcp_snd_test(struct sock *sk, struct 
> sk_buff *skb,
> +				 unsigned cur_mss, int nonagle)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	unsigned int cwnd_quota;
> +
> +	if (!tcp_nagle_test(tp, skb, cur_mss, nonagle))
> +		return 0;
> +
> +	cwnd_quota = tcp_cwnd_test(tp, skb);
> +	if (cwnd_quota &&
> +	    !tcp_snd_wnd_test(tp, skb, cur_mss))
> +		cwnd_quota = 0;
> +
> +	return cwnd_quota;
> +}
> +
> +int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp) {
> +	struct sk_buff *skb = sk->sk_send_head;
> +
> +	return (skb &&
> +		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
> +			     tcp_skb_is_last(sk, skb) ? 
> TCP_NAGLE_PUSH : tp->nonagle)); }
> +
> +/* Trim TSO SKB to LEN bytes, put the remaining data into a 
> new packet
> + * which is put after SKB on the list.  It is very much like
> + * tcp_fragment() except that it may make several kinds of 
> assumptions
> + * in order to speed up the splitting operation.  In particular, we
> + * know that all the data is in scatter-gather pages, and that the
> + * packet has never been sent out before (and thus is not cloned).
> + */
> +static int tso_fragment(struct sock *sk, struct sk_buff 
> *skb, unsigned 
> +int len) {
> +	struct sk_buff *buff;
> +	int nlen = skb->len - len;
> +	u16 flags;
> +
> +	/* All of a TSO frame must be composed of paged data.  */
> +	BUG_ON(skb->len != skb->data_len);
> +
> +	buff = sk_stream_alloc_pskb(sk, 0, 0, GFP_ATOMIC);
> +	if (unlikely(buff == NULL))
> +		return -ENOMEM;
> +	sk_charge_skb(sk, buff);
> +
> +	buff->truesize += nlen;
> +	skb->truesize -= nlen;
> +
> +	/* Correct the sequence numbers. */
> +	TCP_SKB_CB(buff)->seq = TCP_SKB_CB(skb)->seq + len;
> +	TCP_SKB_CB(buff)->end_seq = TCP_SKB_CB(skb)->end_seq;
> +	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(buff)->seq;
> +
> +	/* PSH and FIN should only be set in the second packet. */
> +	flags = TCP_SKB_CB(skb)->flags;
> +	TCP_SKB_CB(skb)->flags = flags & 
> ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
> +	TCP_SKB_CB(buff)->flags = flags;
> +
> +	/* This packet was never sent out yet, so no SACK bits. */
> +	TCP_SKB_CB(buff)->sacked = 0;
> +
> +	buff->ip_summed = skb->ip_summed = CHECKSUM_HW;
> +	skb_split(skb, buff, len);
> +
> +	/* Fix up tso_factor for both original and new SKB.  */
> +	tcp_set_skb_tso_segs(sk, skb);
> +	tcp_set_skb_tso_segs(sk, buff);
> +
> +	/* Link BUFF into the send queue. */
> +	__skb_append(skb, buff);
> +
> +	return 0;
> +}
> +
> +/* Split TSO frame SKB into one MSS sized packet, then the rest.
> + * This is called during SACK processing when some SACK information
> + * hits a TSO packet.
> + */
> +int tcp_tso_mince(struct sock *sk, struct tcp_sock *tp, 
> struct sk_buff 
> +*skb) {
> +	unsigned int mss_now = tcp_current_mss(sk, 1);
> +
> +	BUG_ON(tcp_skb_pcount(skb) <= 1);
> +
> +	/* We cannot use tso_fragment() in this case, because
> +	 * the packet has been sent once already and thus may
> +	 * be cloned or have other non-trivial details to deal
> +	 * with.
> +	 */
> +	return tcp_fragment(sk, skb, mss_now); }
> +
> +static inline unsigned int tso_size_limit(u32 window, unsigned int 
> +mss_now, unsigned int cwnd) {
> +	u32 cwnd_len;
> +
> +	cwnd_len = mss_now * cwnd;
> +	return min(window, cwnd_len);
> +}
> +
>  /* This routine writes packets to the network.  It advances the
>   * send_head.  This happens as incoming acks open up the remote
>   * window for us.
> @@ -734,57 +928,167 @@ unsigned int tcp_current_mss(struct sock
>   * Returns 1, if no segments are in flight and we have 
> queued segments, but
>   * cannot send anything now because of SWS or another problem.
>   */
> -int tcp_write_xmit(struct sock *sk, int nonagle)
> +static int tcp_write_xmit(struct sock *sk, int nonagle)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	unsigned int mss_now;
> +	unsigned int mss_now, cwnd_quota, sent_pkts, tso_segs;
> +	struct sk_buff *skb;
>  
>  	/* If we are closed, the bytes will have to remain here.
>  	 * In time closedown will finish, we empty the write 
> queue and all
>  	 * will be happy.
>  	 */
> -	if (sk->sk_state != TCP_CLOSE) {
> -		struct sk_buff *skb;
> -		int sent_pkts = 0;
> +	if (unlikely(sk->sk_state == TCP_CLOSE))
> +		return 0;
>  
> -		/* Account for SACKS, we may need to fragment 
> due to this.
> -		 * It is just like the real MSS changing on us 
> midstream.
> -		 * We also handle things correctly when the 
> user adds some
> -		 * IP options mid-stream.  Silly to do, but cover it.
> -		 */
> -		mss_now = tcp_current_mss(sk, 1);
> +	/* Account for SACKS, we may need to fragment due to this.
> +	 * It is just like the real MSS changing on us midstream.
> +	 * We also handle things correctly when the user adds some
> +	 * IP options mid-stream.  Silly to do, but cover it.
> +	 */
> +	mss_now = tcp_current_mss(sk, 1);
> +	skb = sk->sk_send_head;
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	tso_segs = tcp_init_tso_segs(sk, skb);
> +	cwnd_quota = tcp_cwnd_test(tp, skb);
> +	sent_pkts = 0;
> +
> +	while (cwnd_quota) {
> +		u32 end_seq, window_seq;
> +
> +		if (!tcp_nagle_test(tp, skb, mss_now,
> +				    (tcp_skb_is_last(sk, skb) ?
> +				     nonagle : TCP_NAGLE_PUSH)))
> +			break;
> +
> +		end_seq = TCP_SKB_CB(skb)->end_seq;
> +		window_seq = tp->snd_una + tp->snd_wnd;
> +		if (skb->len > mss_now)
> +			end_seq = TCP_SKB_CB(skb)->seq + mss_now;
> +		if (after(end_seq, window_seq))
> +			break;
> +
> +		BUG_ON(!tso_segs);
> +
> +		if (tso_segs > 1) {
> +			u32 limit = tso_size_limit(window_seq -
> +						   TCP_SKB_CB(skb)->seq,
> +						   mss_now, cwnd_quota);
>  
> -		while ((skb = sk->sk_send_head) &&
> -		       tcp_snd_test(sk, skb, mss_now,
> -			       	    tcp_skb_is_last(sk, skb) ? nonagle :
> -				    			       
> TCP_NAGLE_PUSH)) {
> -			if (skb->len > mss_now) {
> -				if (tcp_fragment(sk, skb, mss_now))
> +			if (skb->len > limit) {
> +				if (tso_fragment(sk, skb, limit))
>  					break;
>  			}
> -
> -			TCP_SKB_CB(skb)->when = tcp_time_stamp;
> -			tcp_tso_set_push(skb);
> -			if (tcp_transmit_skb(sk, skb_clone(skb, 
> GFP_ATOMIC)))
> +		} else if (skb->len > mss_now) {
> +			if (tcp_fragment(sk, skb, mss_now))
>  				break;
> +		}
>  
> -			/* Advance the send_head.  This one is sent out.
> -			 * This call will increment packets_out.
> -			 */
> -			update_send_head(sk, tp, skb);
> +		TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +		tcp_tso_set_push(skb);
> +		if (tcp_transmit_skb(sk, skb_clone(skb, GFP_ATOMIC)))
> +			break;
>  
> -			tcp_minshall_update(tp, mss_now, skb);
> -			sent_pkts = 1;
> -		}
> +		/* Advance the send_head.  This one is sent out.
> +		 * This call will increment packets_out.
> +		 */
> +		update_send_head(sk, tp, skb);
>  
> -		if (sent_pkts) {
> -			tcp_cwnd_validate(sk, tp);
> -			return 0;
> +		tcp_minshall_update(tp, mss_now, skb);
> +		sent_pkts++;
> +
> +		cwnd_quota -= tcp_skb_pcount(skb);
> +		skb = sk->sk_send_head;
> +		if (!skb)
> +			break;
> +		tso_segs = tcp_init_tso_segs(sk, skb);
> +	}
> +
> +	if (sent_pkts) {
> +		tcp_cwnd_validate(sk, tp);
> +		return 0;
> +	}
> +
> +	return !tp->packets_out && sk->sk_send_head; }
> +
> +/* Push out any pending frames which were held back due to
> + * TCP_CORK or attempt at coalescing tiny packets.
> + * The socket must be locked by the caller.
> + */
> +void __tcp_push_pending_frames(struct sock *sk,
> +			       struct tcp_sock *tp,
> +			       unsigned int cur_mss,
> +			       int nonagle)
> +{
> +	struct sk_buff *skb = sk->sk_send_head;
> +
> +	if (skb) {
> +		if (!tcp_skb_is_last(sk, skb))
> +			nonagle = TCP_NAGLE_PUSH;
> +		if (tcp_write_xmit(sk, nonagle))
> +			tcp_check_probe_timer(sk, tp);
> +	}
> +	tcp_cwnd_validate(sk, tp);
> +}
> +
> +/* As ACKs arrive and the send and congestion windows potentially
> + * open up, we call this to try and make write queue transmit
> + * progress.
> + *
> + * The caller has the socket locked, and has verified that
> + * sk->sk_send_head is not NULL.
> + */
> +void __tcp_data_snd_check(struct sock *sk, struct sk_buff *skb) {
> +	struct tcp_sock *tp = tcp_sk(sk);
> +
> +	if (tcp_write_xmit(sk, tp->nonagle))
> +		tcp_check_probe_timer(sk, tp);
> +}
> +
> +/* Send _single_ skb sitting at the send head. This function requires
> + * true push pending frames to setup probe timer etc.  Caller makes
> + * sure that sk->sk_send_head is non-NULL.
> + */
> +void tcp_push_one(struct sock *sk, unsigned int cur_mss) {
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sk_buff *skb = sk->sk_send_head;
> +	unsigned int tso_segs, cwnd_quota;
> +
> +	tso_segs = tcp_init_tso_segs(sk, skb);
> +	cwnd_quota = tcp_snd_test(sk, skb, cur_mss, TCP_NAGLE_PUSH);
> +	if (cwnd_quota) {
> +		u32 window_seq;
> +
> +		window_seq = tp->snd_una + tp->snd_wnd;
> +		BUG_ON(!tso_segs);
> +
> +		if (tso_segs > 1) {
> +			u32 limit = tso_size_limit(window_seq -
> +						   TCP_SKB_CB(skb)->seq,
> +						   cur_mss, cwnd_quota);
> +
> +			if (skb->len > limit) {
> +				if (tso_fragment(sk, skb, limit))
> +					return;
> +			}
> +		} else if (skb->len > cur_mss) {
> +			if (tcp_fragment(sk, skb, cur_mss))
> +				return;
>  		}
>  
> -		return !tp->packets_out && sk->sk_send_head;
> +		/* Send it out now. */
> +		TCP_SKB_CB(skb)->when = tcp_time_stamp;
> +		tcp_tso_set_push(skb);
> +		if (!tcp_transmit_skb(sk, skb_clone(skb, 
> sk->sk_allocation))) {
> +			update_send_head(sk, tp, skb);
> +			return;
> +		}
>  	}
> -	return 0;
>  }
>  
>  /* This function returns the amount that we can raise the @@ 
> -1041,12 +1345,6 @@ int tcp_retransmit_skb(struct sock *sk, 
>  		if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
>  			BUG();
>  
> -		if (sk->sk_route_caps & NETIF_F_TSO) {
> -			sk->sk_route_caps &= ~NETIF_F_TSO;
> -			sock_set_flag(sk, SOCK_NO_LARGESEND);
> -			tp->mss_cache = tp->mss_cache_std;
> -		}
> -
>  		if (tcp_trim_head(sk, skb, tp->snd_una - 
> TCP_SKB_CB(skb)->seq))
>  			return -ENOMEM;
>  	}
> @@ -1671,13 +1969,6 @@ int tcp_write_wakeup(struct sock *sk)
>  				TCP_SKB_CB(skb)->flags |= 
> TCPCB_FLAG_PSH;
>  				if (tcp_fragment(sk, skb, seg_size))
>  					return -1;
> -				/* SWS override triggered 
> forced fragmentation.
> -				 * Disable TSO, the connection 
> is too sick. */
> -				if (sk->sk_route_caps & NETIF_F_TSO) {
> -					sock_set_flag(sk, 
> SOCK_NO_LARGESEND);
> -					sk->sk_route_caps &= 
> ~NETIF_F_TSO;
> -					tp->mss_cache = 
> tp->mss_cache_std;
> -				}
>  			} else if (!tcp_skb_pcount(skb))
>  				tcp_set_skb_tso_segs(sk, skb);
>  
> --- 1/net/ipv4/tcp.c.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/net/ipv4/tcp.c	2005-05-17 12:07:26.000000000 -0700
> @@ -634,7 +634,7 @@ static ssize_t do_tcp_sendpages(struct s
>  			 size_t psize, int flags)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	int mss_now;
> +	int mss_now, size_goal;
>  	int err;
>  	ssize_t copied;
>  	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT); 
> @@ -647,6 +647,7 @@ static ssize_t do_tcp_sendpages(struct s
>  	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
>  
>  	mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
> +	size_goal = tp->xmit_size_goal;
>  	copied = 0;
>  
>  	err = -EPIPE;
> @@ -660,7 +661,7 @@ static ssize_t do_tcp_sendpages(struct s
>  		int offset = poffset % PAGE_SIZE;
>  		int size = min_t(size_t, psize, PAGE_SIZE - offset);
>  
> -		if (!sk->sk_send_head || (copy = mss_now - 
> skb->len) <= 0) {
> +		if (!sk->sk_send_head || (copy = size_goal - 
> skb->len) <= 0) {
>  new_segment:
>  			if (!sk_stream_memory_free(sk))
>  				goto wait_for_sndbuf;
> @@ -671,7 +672,7 @@ new_segment:
>  				goto wait_for_memory;
>  
>  			skb_entail(sk, tp, skb);
> -			copy = mss_now;
> +			copy = size_goal;
>  		}
>  
>  		if (copy > size)
> @@ -712,7 +713,7 @@ new_segment:
>  		if (!(psize -= copy))
>  			goto out;
>  
> -		if (skb->len != mss_now || (flags & MSG_OOB))
> +		if (skb->len != size_goal || (flags & MSG_OOB))
>  			continue;
>  
>  		if (forced_push(tp)) {
> @@ -732,6 +733,7 @@ wait_for_memory:
>  			goto do_error;
>  
>  		mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
> +		size_goal = tp->xmit_size_goal;
>  	}
>  
>  out:
> @@ -773,15 +775,11 @@ ssize_t tcp_sendpage(struct socket *sock
>  
>  static inline int select_size(struct sock *sk, struct 
> tcp_sock *tp)  {
> -	int tmp = tp->mss_cache_std;
> +	int tmp = tp->mss_cache;
>  
> -	if (sk->sk_route_caps & NETIF_F_SG) {
> -		int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
> +	if (sk->sk_route_caps & NETIF_F_SG)
> +		tmp = 0;
>  
> -		if (tmp >= pgbreak &&
> -		    tmp <= pgbreak + (MAX_SKB_FRAGS - 1) * PAGE_SIZE)
> -			tmp = pgbreak;
> -	}
>  	return tmp;
>  }
>  
> @@ -792,7 +790,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct sk_buff *skb;
>  	int iovlen, flags;
> -	int mss_now;
> +	int mss_now, size_goal;
>  	int err, copied;
>  	long timeo;
>  
> @@ -811,6 +809,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
>  	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
>  
>  	mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
> +	size_goal = tp->xmit_size_goal;
>  
>  	/* Ok commence sending. */
>  	iovlen = msg->msg_iovlen;
> @@ -833,7 +832,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
>  			skb = sk->sk_write_queue.prev;
>  
>  			if (!sk->sk_send_head ||
> -			    (copy = mss_now - skb->len) <= 0) {
> +			    (copy = size_goal - skb->len) <= 0) {
>  
>  new_segment:
>  				/* Allocate new segment. If the 
> interface is SG, @@ -856,7 +855,7 @@ new_segment:
>  					skb->ip_summed = CHECKSUM_HW;
>  
>  				skb_entail(sk, tp, skb);
> -				copy = mss_now;
> +				copy = size_goal;
>  			}
>  
>  			/* Try to append data to the end of 
> skb. */ @@ -891,11 +890,6 @@ new_segment:
>  					tcp_mark_push(tp, skb);
>  					goto new_segment;
>  				} else if (page) {
> -					/* If page is cached, align
> -					 * offset to L1 cache boundary
> -					 */
> -					off = (off + 
> L1_CACHE_BYTES - 1) &
> -					      ~(L1_CACHE_BYTES - 1);
>  					if (off == PAGE_SIZE) {
>  						put_page(page);
>  						TCP_PAGE(sk) = 
> page = NULL;
> @@ -956,7 +950,7 @@ new_segment:
>  			if ((seglen -= copy) == 0 && iovlen == 0)
>  				goto out;
>  
> -			if (skb->len != mss_now || (flags & MSG_OOB))
> +			if (skb->len != size_goal || (flags & MSG_OOB))
>  				continue;
>  
>  			if (forced_push(tp)) {
> @@ -976,6 +970,7 @@ wait_for_memory:
>  				goto do_error;
>  
>  			mss_now = tcp_current_mss(sk, !(flags&MSG_OOB));
> +			size_goal = tp->xmit_size_goal;
>  		}
>  	}
>  
> @@ -2135,7 +2130,7 @@ void tcp_get_info(struct sock *sk, struc
>  
>  	info->tcpi_rto = jiffies_to_usecs(tp->rto);
>  	info->tcpi_ato = jiffies_to_usecs(tp->ack.ato);
> -	info->tcpi_snd_mss = tp->mss_cache_std;
> +	info->tcpi_snd_mss = tp->mss_cache;
>  	info->tcpi_rcv_mss = tp->ack.rcv_mss;
>  
>  	info->tcpi_unacked = tp->packets_out;
> @@ -2185,7 +2180,7 @@ int tcp_getsockopt(struct sock *sk, int 
>  
>  	switch (optname) {
>  	case TCP_MAXSEG:
> -		val = tp->mss_cache_std;
> +		val = tp->mss_cache;
>  		if (!val && ((1 << sk->sk_state) & (TCPF_CLOSE 
> | TCPF_LISTEN)))
>  			val = tp->rx_opt.user_mss;
>  		break;
> --- 1/net/ipv4/tcp_input.c.~1~	2005-05-16 
> 22:29:56.000000000 -0700
> +++ 2/net/ipv4/tcp_input.c	2005-05-17 16:49:26.000000000 -0700
> @@ -805,10 +805,10 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp,
>  	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
>  
>  	if (!cwnd) {
> -		if (tp->mss_cache_std > 1460)
> +		if (tp->mss_cache > 1460)
>  			cwnd = 2;
>  		else
> -			cwnd = (tp->mss_cache_std > 1095) ? 3 : 4;
> +			cwnd = (tp->mss_cache > 1095) ? 3 : 4;
>  	}
>  	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);  } @@ 
> -974,14 +974,6 @@ tcp_sacktag_write_queue(struct sock *sk,
>  	int flag = 0;
>  	int i;
>  
> -	/* So, SACKs for already sent large segments will be lost.
> -	 * Not good, but alternative is to resegment the queue. */
> -	if (sk->sk_route_caps & NETIF_F_TSO) {
> -		sk->sk_route_caps &= ~NETIF_F_TSO;
> -		sock_set_flag(sk, SOCK_NO_LARGESEND);
> -		tp->mss_cache = tp->mss_cache_std;
> -	}
> -
>  	if (!tp->sacked_out)
>  		tp->fackets_out = 0;
>  	prior_fackets = tp->fackets_out;
> @@ -1038,6 +1030,15 @@ tcp_sacktag_write_queue(struct sock *sk,
>  			if(!before(TCP_SKB_CB(skb)->seq, end_seq))
>  				break;
>  
> +			/* Even if mincing a TSO frame fails, we
> +			 * continue anyways.  We will end up with
> +			 * more coarse SACK information, but it is
> +			 * better than ignoring all the SACK information
> +			 * altogether.
> +			 */
> +			if (tcp_skb_pcount(skb) > 1)
> +				tcp_tso_mince(sk, tp, skb);
> +
>  			fack_count += tcp_skb_pcount(skb);
>  
>  			in_sack = !after(start_seq, 
> TCP_SKB_CB(skb)->seq) && @@ -1142,7 +1143,7 @@ 
> tcp_sacktag_write_queue(struct sock *sk,
>  			    (IsFack(tp) ||
>  			     !before(lost_retrans,
>  				     TCP_SKB_CB(skb)->ack_seq + 
> tp->reordering *
> -				     tp->mss_cache_std))) {
> +				     tp->mss_cache))) {
>  				TCP_SKB_CB(skb)->sacked &= 
> ~TCPCB_SACKED_RETRANS;
>  				tp->retrans_out -= tcp_skb_pcount(skb);
>  
> @@ -1782,7 +1783,7 @@ static void tcp_try_to_open(struct sock 
>  		tp->retrans_stamp = 0;
>  
>  	if (flag&FLAG_ECE)
> -		tcp_enter_cwr(tp);
> +		tcp_enter_cwr(tp, 1);
>  
>  	if (tp->ca_state != TCP_CA_CWR) {
>  		int state = TCP_CA_Open;
> @@ -2170,7 +2171,7 @@ static void vegas_cong_avoid(struct tcp_
>  		 * is the cwnd during the previous RTT.
>  		 */
>  		old_wnd = (tp->vegas.beg_snd_nxt - 
> tp->vegas.beg_snd_una) /
> -			tp->mss_cache_std;
> +			tp->mss_cache;
>  		old_snd_cwnd = tp->vegas.beg_snd_cwnd;
>  
>  		/* Save the extent of the current window so we 
> can use this @@ -2799,19 +2800,19 @@ static void 
> westwood_dupack_update(struc  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  
> -	tp->westwood.accounted += tp->mss_cache_std;
> -	tp->westwood.cumul_ack = tp->mss_cache_std;
> +	tp->westwood.accounted += tp->mss_cache;
> +	tp->westwood.cumul_ack = tp->mss_cache;
>  }
>  
>  static inline int westwood_may_change_cumul(struct tcp_sock *tp)  {
> -	return (tp->westwood.cumul_ack > tp->mss_cache_std);
> +	return (tp->westwood.cumul_ack > tp->mss_cache);
>  }
>  
>  static inline void westwood_partial_update(struct tcp_sock *tp)  {
>  	tp->westwood.accounted -= tp->westwood.cumul_ack;
> -	tp->westwood.cumul_ack = tp->mss_cache_std;
> +	tp->westwood.cumul_ack = tp->mss_cache;
>  }
>  
>  static inline void westwood_complete_update(struct tcp_sock 
> *tp) @@ -3952,7 +3953,7 @@ static void tcp_new_space(struct sock *s
>  	    !(sk->sk_userlocks & SOCK_SNDBUF_LOCK) &&
>  	    !tcp_memory_pressure &&
>  	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
> - 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, 
> tp->mss_cache_std) +
> + 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, 
> tp->mss_cache) +
>  			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
>  		    demanded = max_t(unsigned int, tp->snd_cwnd,
>  						   tp->reordering + 1);
> @@ -3975,16 +3976,6 @@ static inline void tcp_check_space(struc
>  	}
>  }
>  
> -static void __tcp_data_snd_check(struct sock *sk, struct 
> sk_buff *skb) -{
> -	struct tcp_sock *tp = tcp_sk(sk);
> -
> -	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + 
> tp->snd_wnd) ||
> -	    tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
> -	    tcp_write_xmit(sk, tp->nonagle))
> -		tcp_check_probe_timer(sk, tp);
> -}
> -
>  static __inline__ void tcp_data_snd_check(struct sock *sk)  {
>  	struct sk_buff *skb = sk->sk_send_head;
> --- 1/net/ipv4/tcp_ipv4.c.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/net/ipv4/tcp_ipv4.c	2005-05-17 11:27:14.000000000 -0700
> @@ -2060,7 +2060,8 @@ static int tcp_v4_init_sock(struct sock 
>  	 */
>  	tp->snd_ssthresh = 0x7fffffff;	/* Infinity */
>  	tp->snd_cwnd_clamp = ~0;
> -	tp->mss_cache_std = tp->mss_cache = 536;
> +	tp->mss_cache = 536;
> +	tp->xmit_size_cache = ~0;
>  
>  	tp->reordering = sysctl_tcp_reordering;
>  
> --- 1/net/ipv6/tcp_ipv6.c.~1~	2005-05-16 22:29:56.000000000 -0700
> +++ 2/net/ipv6/tcp_ipv6.c	2005-05-17 11:27:25.000000000 -0700
> @@ -2021,7 +2021,8 @@ static int tcp_v6_init_sock(struct sock 
>  	 */
>  	tp->snd_ssthresh = 0x7fffffff;
>  	tp->snd_cwnd_clamp = ~0;
> -	tp->mss_cache_std = tp->mss_cache = 536;
> +	tp->mss_cache = 536;
> +	tp->xmit_size_cache = ~0;
>  
>  	tp->reordering = sysctl_tcp_reordering;
> 
> 
