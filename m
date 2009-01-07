From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][TCP]: simplify tcp_mark_lost_retrans()
Date: Wed, 7 Jan 2009 12:41:20 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901071229160.27307@wrl-59.cs.helsinki.fi>
References: <alpine.DEB.2.00.0901071009000.6102@rhea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46303 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbZAGKlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 05:41:22 -0500
In-Reply-To: <alpine.DEB.2.00.0901071009000.6102@rhea>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Jan 2009, Arnd Hannemann wrote:

> I noticed

Good that somebody else is looking TCP code besides me... :-)

> that in tcp_mark_lost_retrans the for-loop is only entered
> if tcp_is_fack(tp) evaluates to true:
> 
>           if (!tcp_is_fack(tp) || !tp->retrans_out ||
>               !after(received_upto, tp->lost_retrans_low) ||
>               icsk->icsk_ca_state != TCP_CA_Recovery)
>                   return;
> 
> Therefore the following check in the for-loop seems to be redundant,
> because it always evaluates to true:
> 
>                      (tcp_is_fack(tp) ||
>                       !before(received_upto,
>                               ack_seq + tp->reordering * tp->mss_cache))
> 
> Did I miss something?

It was just a left over from the RFC3517 SACK addition which added that 
!tcp_is_fack(tp) there above. ...It would have been nice to have similar 
lost rexmit feature without FACK as well but calculating that wasn't 
trivial (or I didn't find that too trivial) and could end up being 
extremely expensive in case of large holes. (So I also left it there as 
sort of reminder).

On the second thought, it would be possible to count skbs we pass while 
walking from the beginning and use that a remaining_sacked counter 
to get rid of all heurestics too and base the counting only on sacked 
stuff which aligns with the spirit of rfc3517 much better than 
sacked+holes used by fack.

> Best regards,
> Arnd Hannemann
> 
> From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> 
> Because the for loop is only executed for FACK-enabled flows remove
> redundant checks within the loop.
> 
> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 99b7ecb..cd8b4bd 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1178,10 +1178,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
>    		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
>    			continue;
> 
> -		if (after(received_upto, ack_seq) &&
> -		    (tcp_is_fack(tp) ||
> -		     !before(received_upto,
> -			     ack_seq + tp->reordering * tp->mss_cache))) {
> +		if (after(received_upto, ack_seq)) {
>    			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
>    			tp->retrans_out -= tcp_skb_pcount(skb);


-- 
 i.
