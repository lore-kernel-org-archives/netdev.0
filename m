From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net] tcp: Fix integer-overflows in TCP veno
Date: Fri, 25 Jul 2014 14:02:50 +0200
Message-ID: <20140725120250.GC28724@cpaasch-mac>
References: <1406064838-21782-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34406 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaGYMDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 08:03:01 -0400
Content-Disposition: inline
In-Reply-To: <1406064838-21782-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 22/07/14 - 23:33:58, Christoph Paasch wrote:
> In veno we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. However, we first
> need to cast the cwnd so that actually 64-bit arithmetic is done.
> 
> A first attempt at fixing 76f1017757aa0 ([TCP]: TCP Veno congestion
> control) was made by 159131149c2 (tcp: Overflow bug in Vegas), but it
> failed to add the required cast in tcp_veno_cong_avoid().
> 
> Fixes: 76f1017757aa0 ([TCP]: TCP Veno congestion control)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/tcp_veno.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

I see you marked this one also as "Changes Requested" on patchwork.

But the story here is a bit different than for vegas, because in veno the
do_div is already present. Do you want me to remove the do_div for -net
and try to do a similar calculation as in vegas?

Because, my proposed veno-patch already fixes the overflow-issues in veno,
while a modification to the do_div would be more of a (small) performance
improvement.


Cheers,
Christoph

> 
> diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
> index 27b9825753d1..8276977d2c85 100644
> --- a/net/ipv4/tcp_veno.c
> +++ b/net/ipv4/tcp_veno.c
> @@ -144,7 +144,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
>  
>  		rtt = veno->minrtt;
>  
> -		target_cwnd = (tp->snd_cwnd * veno->basertt);
> +		target_cwnd = (u64)tp->snd_cwnd * veno->basertt;
>  		target_cwnd <<= V_PARAM_SHIFT;
>  		do_div(target_cwnd, rtt);
>  
> -- 
> 1.9.3
> 
