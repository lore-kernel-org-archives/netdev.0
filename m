From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp-tso: fix faulty logic in tcp_tso_should_defer
Date: Thu, 04 Aug 2016 07:37:01 +0200
Message-ID: <1470289021.13693.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <75F60345-2612-4EF8-A7C3-8F0E1E6215B3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	=?UTF-8?Q?=E9=AB=98=E6=98=8C=E5=88=A9?= <xiaosuo@gmail.com>,
	netdev@vger.kernel.org
To: Liang Ge <lungothrin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33537 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbcHDGra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 02:47:30 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so40704566wme.0
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 23:47:29 -0700 (PDT)
In-Reply-To: <75F60345-2612-4EF8-A7C3-8F0E1E6215B3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-04 at 12:01 +0800, Liang Ge wrote:
> code does not match comment
> 
> 	head = tcp_write_queue_head(sk);
> 	skb_mstamp_get(&now);
> 	age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
> 	/* If next ACK is likely to come too late (half srtt), do not defer */
> 	if (age < (tp->srtt_us >> 4))
> 		goto send_now;
> 
> This bug will cause TSO packets being transmitted too early, and force
> software to tear them apart.

What do you mean by 'tear them apart' ?

TSO auto defer is an optimization. No packet can be dropped because of
the choice made here.

> 
> When ack clocking is likely to broke, this check will try to push out
> some EXTRA probe the first chance possible. Some transmission has
> already happened due to Eric's work.

I can not parse the changelog really. 

> 
> This patch fix the check.
> ---
>  net/ipv4/tcp_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b26aa87..7082964 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1833,7 +1833,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
>  	skb_mstamp_get(&now);
>  	age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
>  	/* If next ACK is likely to come too late (half srtt), do not defer */
> -	if (age < (tp->srtt_us >> 4))
> +	if (age > (tp->srtt_us >> 4))
>  		goto send_now;
>  
>  	/* Ok, it looks like it is advisable to defer. */


I have no idea what precise problem you have with this code, but your
patch is breaking the logic.


This was properly explained in 50c8339e9299aaf09e48c8f94de39baec638c874
changelog :

    This patch implements an heuristic based on age of first
    skb in write queue : If it was sent very recently (less than half srtt),
    we can predict that no ACK packet will come in less than half rtt,
    so deferring might cause an under utilization of our window.
    
