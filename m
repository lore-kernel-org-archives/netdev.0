From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Sun, 27 Apr 2008 12:48:26 -0400
Message-ID: <1209314906.29301.148.camel@tng>
References: <20080424142727.GA24025@alice>
	 <20080424211320.GA13695@2ka.mipt.ru> <20080425125230.GA12343@alice>
	 <20080425130946.GA1019@2ka.mipt.ru>  <20080426160519.GA5697@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <snakebyte@gmx.de>, netdev@vger.kernel.org,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:47926 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbYD0QsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 12:48:05 -0400
In-Reply-To: <20080426160519.GA5697@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-04-26 at 20:05 +0400, Evgeniy Polyakov wrote:

> > tcp_v6_do_rcv()->tcp_rcv_established(), the latter goes to step5, where
> > eventually skb can be freed via tcp_data_queue() (drop: label), then if
> > check for tcp_defer_accept_check() returns true and thus
> > tcp_rcv_established() returns -1, which forces tcp_v6_do_rcv() to jump
> > to reset: label, which in turn will pass through discard: label and free
> > the same skb again.
> >  

yep. That buggy test was logic from a different strategy long
discarded.. the skb is always queued/dropped independently of
defer_accept_check() and as such it shouldn't impact the return value of
rcv_established.

I was able to reproduce by forcing the fuzzer to play with DEFER_ACCEPT
100% of the time, and with the patch tests out fine as do the original
defer_accept tests.

Sorry for the bug, and thanks Evgeniy for fixing it and Eric for finding
it.

Acked-By: Patrick McManus <mcmanus@ducksong.com>

> 
> Please test. This bug affects both ipv6 and ipv4 code actually.
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ac9b848..0298f80 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4925,8 +4925,7 @@ step5:
>  	tcp_data_snd_check(sk);
>  	tcp_ack_snd_check(sk);
>  
> -	if (tcp_defer_accept_check(sk))
> -		return -1;
> +	tcp_defer_accept_check(sk);
>  	return 0;
>  
>  csum_error:
> 
> 

