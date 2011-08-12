From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] Proportional Rate Reduction for TCP.
Date: Fri, 12 Aug 2011 14:36:16 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108121432240.12780@wel-95.cs.helsinki.fi>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36477 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab1HLLlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 07:41:22 -0400
In-Reply-To: <1313134197-5082-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch implements Proportional Rate Reduction (PRR) for TCP.
> PRR is an algorithm that determines TCP's sending rate in fast
> recovery. PRR avoids excessive window reductions and aims for
> the actual congestion window size at the end of recovery to be as
> close as possible to the window determined by the congestion control
> algorithm. PRR also improves accuracy of the amount of data sent
> during loss recovery.
> 
> The patch implements the recommended flavor of PRR called PRR-SSRB
> (Proportional rate reduction with slow start reduction bound) and
> replaces the existing rate halving algorithm. PRR improves upon the
> existing Linux fast recovery under a number of conditions including:
>   1) burst losses where the losses implicitly reduce the amount of
> outstanding data (pipe) below the ssthresh value selected by the
> congestion control algorithm and,
>   2) losses near the end of short flows where application runs out of
> data to send.
> 
> As an example, with the existing rate halving implementation a single
> loss event can cause a connection carrying short Web transactions to
> go into the slow start mode after the recovery. This is because during
> recovery Linux pulls the congestion window down to packets_in_flight+1
> on every ACK. A short Web response often runs out of new data to send
> and its pipe reduces to zero by the end of recovery when all its packets
> are drained from the network. Subsequent HTTP responses using the same
> connection will have to slow start to raise cwnd to ssthresh. PRR on
> the other hand aims for the cwnd to be as close as possible to ssthresh
> by the end of recovery.
> 
> A description of PRR and a discussion of its performance can be found at
> the following links:
> - IETF Draft:
>     http://tools.ietf.org/html/draft-mathis-tcpm-proportional-rate-reduction-01
> - IETF Slides:
>     http://www.ietf.org/proceedings/80/slides/tcpm-6.pdf
>     http://tools.ietf.org/agenda/81/slides/tcpm-2.pdf
> - Paper to appear in Internet Measurements Conference (IMC) 2011:
>     Improving TCP Loss Recovery
>     Nandita Dukkipati, Matt Mathis, Yuchung Cheng
> 
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
>  include/linux/tcp.h   |    4 +++
>  net/ipv4/tcp_input.c  |   63 ++++++++++++++++++++++++++++++++++++++++++++----
>  net/ipv4/tcp_output.c |    7 ++++-
>  3 files changed, 67 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 531ede8..dda4f2e1 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -379,6 +379,10 @@ struct tcp_sock {
>  	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
>  	u32	snd_cwnd_used;
>  	u32	snd_cwnd_stamp;
> +	u32	prr_cwnd;	/* Congestion window at start of Recovery. */
> +	u32	prr_delivered;	/* Number of newly delivered packets to
> +				 * receiver in Recovery. */
> +	u32	prr_out;	/* Total number of pkts sent during Recovery. */
>  
>   	u32	rcv_wnd;	/* Current receiver window		*/
>  	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ea0d218..601eff0 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2830,9 +2830,14 @@ static int tcp_try_undo_loss(struct sock *sk)
>  static inline void tcp_complete_cwr(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	/* Do not moderate cwnd if it's already undone in cwr or recovery */
> -	if (tp->undo_marker && tp->snd_cwnd > tp->snd_ssthresh) {
> -		tp->snd_cwnd = tp->snd_ssthresh;
> +
> +	/* Do not moderate cwnd if it's already undone in cwr or recovery. */
> +	if (tp->undo_marker) {
> +
> +		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR)
> +			tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
> +		else /* PRR */
> +			tp->snd_cwnd = tp->snd_ssthresh;
>  		tp->snd_cwnd_stamp = tcp_time_stamp;
>  	}
>  	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
> @@ -2950,6 +2955,39 @@ void tcp_simple_retransmit(struct sock *sk)
>  }
>  EXPORT_SYMBOL(tcp_simple_retransmit);
>  
> +/* This function implements the PRR algorithm, specifcally the PRR-SSRB
> + * (proportional rate reduction with slow start reduction bound) as described in
> + * http://www.ietf.org/id/draft-mathis-tcpm-proportional-rate-reduction-01.txt.
> + * It computes the number of packets to send (sndcnt) based on packets newly
> + * delivered:
> + *   1) If the packets in flight is larger than ssthresh, PRR spreads the
> + *	cwnd reductions across a full RTT.
> + *   2) If packets in flight is lower than ssthresh (such as due to excess
> + *	losses and/or application stalls), do not perform any further cwnd
> + *	reductions, but instead slow start up to ssthresh.
> + */
> +static void tcp_update_cwnd_in_recovery(struct sock *sk, int pkts_delivered,
> +					int fast_rexmit, int flag)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	int sndcnt = 0;
> +	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
> +
> +	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> +		if (WARN_ON(!tp->prr_cwnd))
> +			tp->prr_cwnd = 1;

Thanks, this made me to smile when I realized what kind of positive feedback
loop it would cause in a heavily congested environment :-). ...Perhaps any
value below 2 * tp->snd_ssthresh isn't that safe safety relief valve here.
...Of course this condition isn't ever hit with the current code base so 
no real harm being done regardless of the value.

> +		sndcnt = DIV_ROUND_UP(tp->prr_delivered * tp->snd_ssthresh,
> +				      tp->prr_cwnd) - tp->prr_out;

What about very large windows ...overflow?

Due to not having lower bound here, the resulting window can end up below
snd_ssthresh in one step if prr_delivered suddently jumps to a value that
is above prr_cnwd?

Also, snd_ssthresh and prr_cwnd are essentially constants over the
whole recovery and yet divide is needed whole the time. ...And in practically
all cases the proportion will be 0.5 (except for the odd number produced
off-by-one thing)?

> +	} else {
> +		sndcnt = min_t(int, delta,
> +			       max_t(int, tp->prr_delivered - tp->prr_out,
> +				     pkts_delivered) + 1);
> +	}
> +
> +	sndcnt = max(sndcnt, (fast_rexmit ? 1 : 0));
> +	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
> +}
> +
>  /* Process an event, which can update packets-in-flight not trivially.
>   * Main goal of this function is to calculate new estimate for left_out,
>   * taking into account both packets sitting in receiver's buffer and
> @@ -2961,7 +2999,8 @@ EXPORT_SYMBOL(tcp_simple_retransmit);
>   * It does _not_ decide what to send, it is made in function
>   * tcp_xmit_retransmit_queue().
>   */
> -static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
> +static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
> +				  int pkts_delivered, int flag)
>  {
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	struct tcp_sock *tp = tcp_sk(sk);
> @@ -3111,13 +3150,17 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
>  
>  		tp->bytes_acked = 0;
>  		tp->snd_cwnd_cnt = 0;
> +		tp->prr_cwnd = tp->snd_cwnd;

prior_cwnd would make this variable about 1000 times easier to read
without requiring some background.

While at it, I realized that there is some restore window place in the 
generic code that assumes "prior_cwnd == 2 * tp->snd_ssthresh" which is 
not true with every single cc module.

> +		tp->prr_delivered = 0;
> +		tp->prr_out = 0;
>  		tcp_set_ca_state(sk, TCP_CA_Recovery);
>  		fast_rexmit = 1;
>  	}
>  
>  	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
>  		tcp_update_scoreboard(sk, fast_rexmit);
> -	tcp_cwnd_down(sk, flag);
> +	tp->prr_delivered += pkts_delivered;

...Is here a bug in the calculation if the recovery was triggered with
_a cumulative ACK_ that had enough SACK blocks?

> +	tcp_update_cwnd_in_recovery(sk, pkts_delivered, fast_rexmit, flag);
>  	tcp_xmit_retransmit_queue(sk);
>  }
>  
> @@ -3632,6 +3675,11 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
>  	u32 prior_in_flight;
>  	u32 prior_fackets;
>  	int prior_packets;
> +	int prior_sacked = tp->sacked_out;
> +	/* pkts_delivered is number of packets newly cumulatively acked or
> +	 * sacked on this ACK.
> +	 */
> +	int pkts_delivered = 0;

If you need a comment like that on variable declaration, maybe its name
could be more obvious, pkts_acked_sacked ?

>  	int frto_cwnd = 0;
>  
>  	/* If the ack is older than previous acks
> @@ -3703,6 +3751,9 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
>  	/* See if we can take anything off of the retransmit queue. */
>  	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
> +	pkts_delivered = (prior_packets - prior_sacked) -
> +			 (tp->packets_out - tp->sacked_out);
> +
>  	if (tp->frto_counter)
>  		frto_cwnd = tcp_process_frto(sk, flag);
>  	/* Guarantee sacktag reordering detection against wrap-arounds */
> @@ -3715,7 +3766,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
>  		    tcp_may_raise_cwnd(sk, flag))
>  			tcp_cong_avoid(sk, ack, prior_in_flight);
>  		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out,
> -				      flag);
> +				      pkts_delivered, flag);
>  	} else {
>  		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
>  			tcp_cong_avoid(sk, ack, prior_in_flight);
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 882e0b0..ca50408 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1796,11 +1796,13 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>  		tcp_event_new_data_sent(sk, skb);
>  
>  		tcp_minshall_update(tp, mss_now, skb);
> -		sent_pkts++;
> +		sent_pkts += tcp_skb_pcount(skb);
>  
>  		if (push_one)
>  			break;
>  	}
> +	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Recovery)
> +		tp->prr_out += sent_pkts;

Is there some harm done if you get rid of the conditionality?

>  	if (likely(sent_pkts)) {
>  		tcp_cwnd_validate(sk);
> @@ -2294,6 +2296,9 @@ begin_fwd:
>  			return;
>  		NET_INC_STATS_BH(sock_net(sk), mib_idx);
>  
> +		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Recovery)
> +			tp->prr_out += tcp_skb_pcount(skb);
> +

...same here?

>  		if (skb == tcp_write_queue_head(sk))
>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>  						  inet_csk(sk)->icsk_rto,

Besides the points above, I'm not convinced that we really need all the
across-packet state that is present, some relevant values should be
available before we do any ACK processing (in-flight, cwnd, and more
importantly, the difference between them). ...But I haven't yet
convinced myself of anything particular.

-- 
 i.
