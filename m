From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Resend: [PATCH] TCP Early Retransmit: reduce required dupacks
 for triggering fast retrans
Date: Wed, 23 Sep 2009 12:58:15 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909231232050.13543@wel-95.cs.helsinki.fi>
References: <fab65f44d75b.4ab891f2@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Christian Samsel <Christian.Samsel@rwth-aachen.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55460 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbZIWJ6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 05:58:12 -0400
In-Reply-To: <fab65f44d75b.4ab891f2@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Sep 2009, Christian Samsel wrote:

> This patch implements draft-ietf-tcpm-early-rexmt. The early retransmit 
> mechanism allows the transport to reduce the number of duplicate
> acknowledgments required to trigger a fast retransmission in case we
> don't expect enough dupacks, (e.g. because there are not enough
> packets inflight and nothing to send). This allows the transport to use
> fast retransmit to recover packet losses that would otherwise require
> a lengthy retransmission timeout.
> 
> See: http://tools.ietf.org/html/draft-ietf-tcpm-early-rexmt-01
> 
> Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>
> 
> ---
>  net/ipv4/tcp_input.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index af6d6fa..c0cc4fd 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2913,6 +2913,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
>   int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
>                                      (tcp_fackets_out(tp) > tp->reordering));
>   int fast_rexmit = 0, mib_idx;
> + u32 in_flight;
>  
>   if (WARN_ON(!tp->packets_out && tp->sacked_out))
>           tp->sacked_out = 0;
> @@ -3062,6 +3063,21 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
>   if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
>           tcp_update_scoreboard(sk, fast_rexmit);
>   tcp_cwnd_down(sk, flag);
> +       
> +
> + /* draft-ietf-tcpm-early-rexmt: lowers dup ack threshold to prevent rto
> +         * in case we don't expect enough dup ack. if number of outstanding
> +         * packets is less than four and there is either no unsent data ready
> +         * for transmission or the advertised window does not permit new
> +         * segments.
> +         */
> + in_flight = tcp_packets_in_flight(tp);
> + if ( in_flight < 4 && (skb_queue_empty(&sk->sk_write_queue) ||
> +         tcp_may_send_now(sk) == 0) )
> +         tp->reordering = in_flight - 1;
> + else if (tp->reordering != sysctl_tcp_reordering)
> +         tp->reordering = sysctl_tcp_reordering;
> +
>   tcp_xmit_retransmit_queue(sk);
>  }

This is entirely flawed approach, I'd recommend you start from the 
scratch, almost nothing of this current one is worth keeping (expect 
parts of the comment). ...It will just not work for many cases, however, 
it's nice that you tried nevertheless.

First, the right place to change is in tcp_time_to_recover(). Another 
thing you need is to add a min() into tcp_update_scoreboard. Also, I don't 
think you should be touching tp->reordering at all to artificially lower 
the threshold for a period, just calculate the artificial value on the 
fly. And skb_queue_empty is not doing what you want, in fact I'm unsure 
what you want it to do in the first place? Instead of four, use 
tp->reordering. (I could have coded all that in couple of minutes, in fact 
in less than writing this mail but it's more useful that you go to those 
places, learn and code that instead :-)).

With all the cases that I know to not work with this _submitted_ version, 
I doubt that this is well tested, if any at all. ...I hope you're not 
submitting somebody elses work without understanding at all what the code 
does and what it doesn't...?

Also, before starting, please go through what is written in 
Documentation/CodingStyle.

-- 
 i.
