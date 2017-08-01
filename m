From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] tcp: enable xmit timer fix by having TLP use
 time when RTO should fire
Date: Tue, 01 Aug 2017 00:22:06 -0700
Message-ID: <1501572126.1876.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170801025814.31206-1-ncardwell@google.com>
         <20170801025814.31206-3-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34369 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdHAHWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 03:22:10 -0400
Received: by mail-wr0-f196.google.com with SMTP id o33so616458wrb.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 00:22:09 -0700 (PDT)
In-Reply-To: <20170801025814.31206-3-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 22:58 -0400, Neal Cardwell wrote:
> Have tcp_schedule_loss_probe() base the TLP scheduling decision based
> on when the RTO *should* fire. This is to enable the upcoming xmit
> timer fix in this series, where tcp_schedule_loss_probe() cannot
> assume that the last timer installed was an RTO timer (because we are
> no longer doing the "rearm RTO, rearm RTO, rearm TLP" dance on every
> ACK). So tcp_schedule_loss_probe() must independently figure out when
> an RTO would want to fire.
> 
> In the new TLP implementation following in this series, we cannot
> assume that icsk_timeout was set based on an RTO; after processing a
> cumulative ACK the icsk_timeout we see can be from a previous TLP or
> RTO. So we need to independently recalculate the RTO time (instead of
> reading it out of icsk_timeout). Removing this dependency on the
> nature of icsk_timeout makes things a little easier to reason about
> anyway.
> 
> Note that the old and new code should be equivalent, since they are
> both saying: "if the RTO is in the future, but at an earlier time than
> the normal TLP time, then set the TLP timer to fire when the RTO would
> have fired".
> 
> Fixes: 6ba8a3b19e76 ("tcp: Tail loss probe (TLP)")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
>  net/ipv4/tcp_output.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 2f1588bf73da..0ae6b5d176c0 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2377,8 +2377,8 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>  {
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	u32 timeout, tlp_time_stamp, rto_time_stamp;
>  	u32 rtt = usecs_to_jiffies(tp->srtt_us >> 3);
> +	u32 timeout, rto_delta_us;
>  
>  	/* No consecutive loss probes. */
>  	if (WARN_ON(icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)) {
> @@ -2418,13 +2418,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
>  	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
>  
>  	/* If RTO is shorter, just schedule TLP in its place. */

I have hard time to read this comment.

We are here trying to arm a timer based on TLP.

If RTO is shorter, we'll arm the timer based on RTO instead of TLP.

Is "If RTO is shorter, just schedule TLP in its place." really correct ?

I suggest we reword the comment or simply get rid of it now the code is
more obvious.

> -	tlp_time_stamp = tcp_jiffies32 + timeout;
> -	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
> -	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
> -		s32 delta = rto_time_stamp - tcp_jiffies32;
> -		if (delta > 0)
> -			timeout = delta;
> -	}
> +	rto_delta_us = tcp_rto_delta_us(sk);  /* How far in future is RTO? */
> +	if (rto_delta_us > 0)
> +		timeout = min_t(u32, timeout, usecs_to_jiffies(rto_delta_us));
>  
>  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_LOSS_PROBE, timeout,
>  				  TCP_RTO_MAX);

Acked-by: Eric Dumazet <edumazet@google.com>
