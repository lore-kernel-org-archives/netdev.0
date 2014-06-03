From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH RFC] new-CWV for Linux
Date: Tue, 03 Jun 2014 13:23:10 -0400
Message-ID: <538E047E.6050500@gmail.com>
References: <1401810414-18891-1-git-send-email-raffaello@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raffaello@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:63981 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932565AbaFCRXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 13:23:13 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so5310182qab.14
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 10:23:13 -0700 (PDT)
In-Reply-To: <1401810414-18891-1-git-send-email-raffaello@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2014 11:46 AM, raffaello@erg.abdn.ac.uk wrote:
> Thanks Neal for the hints on how to send from git.
> 
> Please consider this corrected patch for new-CWV.
> 
> Raffaello
> 
> 
> ---
>  include/linux/tcp.h        |   13 +++++++++++++
>  include/net/tcp.h          |   14 +++++++++++++-
>  net/ipv4/Makefile          |    2 +-
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  net/ipv4/tcp_cong.c        |   13 ++++++++++---
>  net/ipv4/tcp_input.c       |   20 ++++++++++++++++++++
>  net/ipv4/tcp_output.c      |    3 +++
>  7 files changed, 67 insertions(+), 5 deletions(-)

I think you forgot to do
 # git-add tcp_newcwv.c

-vlad

> 
> Signed-off-by: Raffaello Secchi <raffaello@erg.abdn.ac.uk>
> Reviewed-by: Tom Jones <tom@erg.abdn.ac.uk>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 2399468..fb82343 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -323,6 +323,19 @@ struct tcp_sock {
>  	 * socket. Used to retransmit SYNACKs etc.
>  	 */
>  	struct request_sock *fastopen_rsk;
> +
> +/* TCP newcwv related information */
> +	u32 psample[4];		/* pipeACK samples circular buffer */
> +	u32 time_stamp[4];
> +	u32 head;		/* index for psample buffer */
> +
> +	u32 pipeack;		/* pipeACK value after filtering */
> +	u32 loss_flight_size;	/* flightsize at loss detection */
> +	u32 prior_retrans;	/* Retransmission before going into FR */
> +	u32 prev_snd_una;	/* snd_una of last record */
> +	u32 prev_snd_nxt;	/* snd_nxt of last record */
> +	u32 cwnd_valid_ts;	/* last time cwnd was found valid */
> +
>  };
>  
>  enum tsq_flags {
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 87d8774..6d71de5 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -235,6 +235,10 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
>   */
>  #define	TFO_SERVER_ALWAYS	0x1000
>  
> +/* NewCWV defaults */
> +#define NCWV_UNDEF			0xFFFFFFFF
> +#define NCWV_FIVEMIN			(HZ*300)
> +
>  extern struct inet_timewait_death_row tcp_death_row;
>  
>  /* sysctl variables for tcp */
> @@ -284,6 +288,7 @@ extern int sysctl_tcp_challenge_ack_limit;
>  extern unsigned int sysctl_tcp_notsent_lowat;
>  extern int sysctl_tcp_min_tso_segs;
>  extern int sysctl_tcp_autocorking;
> +extern int sysctl_tcp_newcwv;
>  
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> @@ -975,7 +980,7 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
>  {
>  	return tp->snd_una + tp->snd_wnd;
>  }
> -bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
> +bool tcp_is_cwnd_limited(struct sock *sk, u32 in_flight);
>  
>  static inline void tcp_check_probe_timer(struct sock *sk)
>  {
> @@ -1324,6 +1329,13 @@ struct tcp_fastopen_context {
>  	struct rcu_head		rcu;
>  };
>  
> +/* TCP New CWV functions */
> +void tcp_newcwv_update_pipeack(struct sock *sk);
> +void tcp_newcwv_datalim_closedown(struct sock *sk);
> +void tcp_newcwv_enter_recovery(struct sock *sk);
> +void tcp_newcwv_end_recovery(struct sock *sk);
> +void tcp_newcwv_reset(struct sock *sk);
> +
>  /* write queue abstraction */
>  static inline void tcp_write_queue_purge(struct sock *sk)
>  {
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index f032688..f687746 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -10,7 +10,7 @@ obj-y     := route.o inetpeer.o protocol.o \
>  	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
>  	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
>  	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
> -	     fib_frontend.o fib_semantics.o fib_trie.o \
> +	     fib_frontend.o fib_semantics.o fib_trie.o tcp_newcwv.o \
>  	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
>  
>  obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 5cde8f2..bfdf30e 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -493,6 +493,13 @@ static struct ctl_table ipv4_table[] = {
>  		.proc_handler	= proc_dointvec
>  	},
>  	{
> +		.procname	= "tcp_newcwv",
> +		.data		= &sysctl_tcp_newcwv,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec
> +	},
> +	{
>  		.procname	= "tcp_reordering",
>  		.data		= &sysctl_tcp_reordering,
>  		.maxlen		= sizeof(int),
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 2b9464c..6fb0719 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -93,6 +93,9 @@ void tcp_init_congestion_control(struct sock *sk)
>  		rcu_read_unlock();
>  	}
>  
> +	/* draft-ietf-tcpm-newcwv initial state */
> +	tcp_newcwv_reset(sk);
> +
>  	if (icsk->icsk_ca_ops->init)
>  		icsk->icsk_ca_ops->init(sk);
>  }
> @@ -279,13 +282,17 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>  /* RFC2861 Check whether we are limited by application or congestion window
>   * This is the inverse of cwnd check in tcp_tso_should_defer
>   */
> -bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
> +bool tcp_is_cwnd_limited(struct sock *sk, u32 in_flight)
>  {
> -	const struct tcp_sock *tp = tcp_sk(sk);
> +	struct tcp_sock *tp = tcp_sk(sk);
>  	u32 left;
>  
> -	if (in_flight >= tp->snd_cwnd)
> +	/* draft-ietf-tcpm-newcwv relaxes conditions for growing cwnd */
> +	if (in_flight >= tp->snd_cwnd || (sysctl_tcp_newcwv &&
> +	    tp->pipeack >= (tp->snd_cwnd*tp->mss_cache >> 1))) {
> +		tp->cwnd_valid_ts = tcp_time_stamp;
>  		return true;
> +	}
>  
>  	left = tp->snd_cwnd - in_flight;
>  	if (sk_can_gso(sk) &&
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 3a26b3b..f2d855e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1927,6 +1927,7 @@ void tcp_enter_loss(struct sock *sk, int how)
>  	tp->snd_cwnd	   = 1;
>  	tp->snd_cwnd_cnt   = 0;
>  	tp->snd_cwnd_stamp = tcp_time_stamp;
> +	tcp_newcwv_reset(sk);
>  
>  	tcp_clear_retrans_partial(tp);
>  
> @@ -2522,7 +2523,16 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
>  	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
>  		tp->snd_cwnd = tp->snd_ssthresh;
>  		tp->snd_cwnd_stamp = tcp_time_stamp;
> +
> +		/* draft-ietf-tcpm-newcwv actions at the end of recovery */
> +		if (sysctl_tcp_newcwv) {
> +			if (tp->loss_flight_size)
> +				tcp_newcwv_end_recovery(sk);
> +			tcp_newcwv_reset(sk);
> +		}
>  	}
> +	tp->loss_flight_size = 0;
> +
>  	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
>  }
>  
> @@ -2666,6 +2676,11 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
>  	tp->undo_marker = tp->snd_una;
>  	tp->undo_retrans = tp->retrans_out;
>  
> +	/* draft-ietf-tcpm-newcwv reduction at start of recovery */
> +	if (sysctl_tcp_newcwv &&
> +	    tp->pipeack <= (tp->snd_cwnd*tp->mss_cache >> 1))
> +		tcp_newcwv_enter_recovery(sk);
> +
>  	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
>  		if (!ece_ack)
>  			tp->prior_ssthresh = tcp_current_ssthresh(sk);
> @@ -3449,6 +3464,11 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>  				    sack_rtt_us);
>  	acked -= tp->packets_out;
>  
> +	/* draft-ietf-tcpm-newcwv pipeack estimation */
> +	if (sysctl_tcp_newcwv && icsk->icsk_ca_state <= TCP_CA_Disorder
> +	    && (flag & FLAG_DATA_ACKED))
> +		tcp_newcwv_update_pipeack(sk);
> +
>  	/* Advance cwnd if state allows */
>  	if (tcp_may_raise_cwnd(sk, flag))
>  		tcp_cong_avoid(sk, ack, acked, prior_in_flight);
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 12d6016..e868211 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -168,6 +168,9 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
>  	const u32 now = tcp_time_stamp;
>  	const struct dst_entry *dst = __sk_dst_get(sk);
>  
> +	if (sysctl_tcp_newcwv)
> +		tcp_newcwv_datalim_closedown(sk);
> +
>  	if (sysctl_tcp_slow_start_after_idle &&
>  	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
>  		tcp_cwnd_restart(sk, __sk_dst_get(sk));
> 
