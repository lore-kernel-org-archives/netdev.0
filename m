From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tcp: avoid a possible divide by zero
Date: Tue, 07 Dec 2010 21:32:43 +0000
Message-ID: <1291757563.21627.15.camel@bwh-desktop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291738321.2695.338.camel@edumazet-laptop>
	 <1291755776.21627.13.camel@bwh-desktop>
	 <1291757288.5324.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Martin Steigerwald <Martin@lichtvoll.de>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab0LGVcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 16:32:46 -0500
In-Reply-To: <1291757288.5324.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-07 at 22:28 +0100, Eric Dumazet wrote:
[...]
> Thanks
> 
> Great, I feel we are going to fix all sysctls, one by one then :(
> 
> lkml removed from Cc
> 
> 
> [PATCH] tcp: avoid a possible divide by zero
> 
> sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs in
> tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
> reading sysctl_tcp_tso_win_divisor once.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/tcp_output.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 05b1ecf..0281223 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1513,6 +1513,7 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	const struct inet_connection_sock *icsk = inet_csk(sk);
>  	u32 send_win, cong_win, limit, in_flight;
> +	int win_divisor;
>  
>  	if (TCP_SKB_CB(skb)->flags & TCPHDR_FIN)
>  		goto send_now;
> @@ -1544,13 +1545,14 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
>  	if ((skb != tcp_write_queue_tail(sk)) && (limit >= skb->len))
>  		goto send_now;
>  
> -	if (sysctl_tcp_tso_win_divisor) {
> +	win_divisor = sysctl_tcp_tso_win_divisor;

You need to use ACCESS_ONCE(sysctl_tcp_tso_win_divisor).  Otherwise the
compiler may eliminate the local variable and read the global twice.

Ben.

> +	if (win_divisor) {
>  		u32 chunk = min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);
>  
>  		/* If at least some fraction of a window is available,
>  		 * just use it.
>  		 */
> -		chunk /= sysctl_tcp_tso_win_divisor;
> +		chunk /= win_divisor;
>  		if (limit >= chunk)
>  			goto send_now;
>  	} else {
> 
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

