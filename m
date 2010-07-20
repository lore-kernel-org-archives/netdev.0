From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Tue, 20 Jul 2010 11:41:45 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007201133500.14034@wel-95.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C4467E0.9080907@kernel.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-55551381-1279615305=:14034"
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C4467E0.9080907@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-55551381-1279615305=:14034
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 19 Jul 2010, Tejun Heo wrote:

> Hello,
> 
> On 07/16/2010 02:02 PM, Ilpo Järvinen wrote:
> > Besides, Tejun has also found that it's hint->next ptr which is NULL in 
> > his case so this won't solve his case anyway. Tejun, can you confirm 
> > whether it was retransmit_skb_hint->next being NULL on _entry time_ to 
> > tcp_xmit_retransmit_queue() or later on in the loop after the updates done 
> > by the loop itself to the hint (or that your testing didn't conclude 
> > either)?
> 
> Sorry about the delay.  I was traveling last week.  Unfortunately, I
> don't know whether ->next was NULL on entry or not.  I hacked up the
> following ugly patch for the next test run.  It should have everything
> which has come up till now + list and hint sanity checking before
> starting processing them.  I'm planning on deploying it w/ crashdump
> enabled in several days.  If I've missed something, please let me
> know.

One thing that complicates things further is the fact that the write queue 
can change beneath us (ie., in tcp_retrans_try_collapse and tcp_fragment).
I've read them multiple times through and always found them innocent so 
this might be just for-the-record type of a note (at least I hope so).

-- 
 i.

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b4ed957..1c8b1e0 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2190,6 +2190,53 @@ static int tcp_can_forward_retransmit(struct sock *sk)
>  	return 1;
>  }
> 
> +static void print_queue(struct sock *sk, struct sk_buff *old, struct sk_buff *hole)
> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	struct sk_buff *skb, *prev;
> +	bool do_panic = false;
> +
> +	skb = tcp_write_queue_head(sk);
> +	prev = (struct sk_buff *)(&sk->sk_write_queue);
> +
> +	if (skb == NULL) {
> +		printk("XXX NULL head, pkts %u\n", tp->packets_out);
> +		do_panic = true;
> +	}
> +
> +	printk("XXX head %p tail %p sendhead %p oldhint %p now %p hole %p high %u\n",
> +	       tcp_write_queue_head(sk), tcp_write_queue_tail(sk),
> +	       tcp_send_head(sk), old, tp->retransmit_skb_hint, hole,
> +	       tp->retransmit_high);
> +
> +	while (skb) {
> +		printk("XXX skb %p (%u-%u) next %p prev %p sacked %u\n",
> +		       skb, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
> +		       skb->next, skb->prev, TCP_SKB_CB(skb)->sacked);
> +		if (prev != skb->prev) {
> +			printk("XXX Inconsistent prev\n");
> +			do_panic = true;
> +		}
> +
> +		if (skb == tcp_write_queue_tail(sk)) {
> +			if (skb->next != (struct sk_buff *)(&sk->sk_write_queue)) {
> +				printk("XXX Improper next at tail\n");
> +				do_panic = true;
> +			}
> +			break;
> +		}
> +
> +		prev = skb;
> +		skb = skb->next;
> +	}
> +	if (!skb) {
> +		printk("XXX Encountered unexpected NULL\n");
> +		do_panic = true;
> +	}
> +	if (do_panic)
> +		panic("XXX panicking");
> +}
> +
>  /* This gets called after a retransmit timeout, and the initially
>   * retransmitted data is acknowledged.  It tries to continue
>   * resending the rest of the retransmit queue, until either
> @@ -2198,19 +2245,53 @@ static int tcp_can_forward_retransmit(struct sock *sk)
>   * based retransmit packet might feed us FACK information again.
>   * If so, we use it to avoid unnecessarily retransmissions.
>   */
> +static unsigned int caught_it;
> +
>  void tcp_xmit_retransmit_queue(struct sock *sk)
>  {
>  	const struct inet_connection_sock *icsk = inet_csk(sk);
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	struct sk_buff *skb;
> +	struct sk_buff *skb, *prev;
>  	struct sk_buff *hole = NULL;
> +	struct sk_buff *old = tp->retransmit_skb_hint;
>  	u32 last_lost;
>  	int mib_idx;
>  	int fwd_rexmitting = 0;
> +	bool saw_hint = false;
> +
> +	if (!tp->packets_out) {
> +		if (net_ratelimit())
> +			printk("XXX !tp->packets_out, retransmit_skb_hint=%p, write_queue_head=%p\n",
> +			       tp->retransmit_skb_hint, tcp_write_queue_head(sk));
> +		return;
> +	}
> 
>  	if (!tp->lost_out)
>  		tp->retransmit_high = tp->snd_una;
> 
> +	for (skb = tcp_write_queue_head(sk),
> +	     prev = (struct sk_buff *)&sk->sk_write_queue;
> +	     skb != (struct sk_buff *)&sk->sk_write_queue;
> +	     prev = skb, skb = skb->next) {
> +		if (prev != skb->prev) {
> +			printk("XXX sanity check: prev corrupt\n");
> +			print_queue(sk, old, hole);
> +		}
> +		if (skb == tp->retransmit_skb_hint)
> +			saw_hint = true;
> +		if (skb == tcp_write_queue_tail(sk) &&
> +		    skb->next != (struct sk_buff *)(&sk->sk_write_queue)) {
> +			printk("XXX sanity check: end corrupt\n");
> +			print_queue(sk, old, hole);
> +		}
> +	}
> +	if (tp->retransmit_skb_hint && !saw_hint) {
> +		printk("XXX sanity check: retransmit_skb_hint=%p is not on list, claring hint\n",
> +		       tp->retransmit_skb_hint);
> +		print_queue(sk, old, hole);
> +		tp->retransmit_skb_hint = NULL;
> +	}
> +
>  	if (tp->retransmit_skb_hint) {
>  		skb = tp->retransmit_skb_hint;
>  		last_lost = TCP_SKB_CB(skb)->end_seq;
> @@ -2218,7 +2299,17 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
>  			last_lost = tp->retransmit_high;
>  	} else {
>  		skb = tcp_write_queue_head(sk);
> -		last_lost = tp->snd_una;
> +		if (skb)
> +			last_lost = tp->snd_una;
> +	}
> +
> +checknull:
> +	if (skb == NULL) {
> +		print_queue(sk, old, hole);
> +		caught_it++;
> +		if (net_ratelimit())
> +			printk("XXX Errors caught so far %u\n", caught_it);
> +		return;
>  	}
> 
>  	tcp_for_write_queue_from(skb, sk) {
> @@ -2261,7 +2352,7 @@ begin_fwd:
>  		} else if (!(sacked & TCPCB_LOST)) {
>  			if (hole == NULL && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
>  				hole = skb;
> -			continue;
> +			goto cont;
> 
>  		} else {
>  			last_lost = TCP_SKB_CB(skb)->end_seq;
> @@ -2272,7 +2363,7 @@ begin_fwd:
>  		}
> 
>  		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
> -			continue;
> +			goto cont;
> 
>  		if (tcp_retransmit_skb(sk, skb))
>  			return;
> @@ -2282,6 +2373,9 @@ begin_fwd:
>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>  						  inet_csk(sk)->icsk_rto,
>  						  TCP_RTO_MAX);
> +cont:
> +		skb = skb->next;
> +		goto checknull;
>  	}
>  }
> 
> 
--8323329-55551381-1279615305=:14034--
