From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Sat, 07 Jun 2014 19:58:25 -0700
Message-ID: <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
	 <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	nanditad@google.com, sergei.shtylyov@cogentembedded.com
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:49491 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbaFHC61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 22:58:27 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so4086419pbc.1
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 19:58:26 -0700 (PDT)
In-Reply-To: <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
> Fix to a problem observed when losing a FIN segment that does not
> contain data.  In such situations, TLP is unable to recover from
> *any* tail loss and instead adds at least PTO ms to the
> retransmission process, i.e., RTO = RTO + PTO.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  net/ipv4/tcp_output.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index d463c35..6573765 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>  	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>  		goto rearm_timer;
>  
> -	/* Probe with zero data doesn't trigger fast recovery. */
> -	if (skb->len > 0)
> +	/* Probe with zero data doesn't trigger fast recovery, if FIN
> +	 * flag is not set.
> +	 */
> +	if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
>  		err = __tcp_retransmit_skb(sk, skb);
>  
>  	/* Record snd_nxt for loss detection. */


You know, I believe the test was exactly to avoid sending data less FIN
packets.

If you write :

    if (A  || !A)

Better remove the condition, completely ;)


Nandita, why FIN packet wont trigger fast retransnmits ?

It sounds like if the timer is the issue you want to fix, you might
simply rearm a timer with RTO-PTO instead of RTO ?
