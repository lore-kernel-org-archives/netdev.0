From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 21:13:22 +1100
Message-ID: <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, ptesarik@suse.cz
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42335 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752308AbYLQKN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 05:13:28 -0500
In-Reply-To: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> This is certainly nice and possible but as mention earlier, the harder 
> problem is that the urg_ptr is only 16-bits so there will be still be 
> problem if the urgent seq-64k mark is within a super-skb as tail segments 
> need urg while the head ones won't. I think we would need out-of-band 
> means to communicate the extra bit (17th) from tcp if we want to solve 
> that one. It would be rather easy to change TCP to only do splitting for 
> that particular skb though and keep everything else intact.

I think you've got it the wrong way around.  The test for setting
urg_ptr is:

        if (unlikely(tcp_urg_mode(tp) &&
                     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {

So if this is true for the super-packet, then by definition it is
also true for the first packet.  In fact, it will be true for the
first n packets where

	tcb->seq + n * mss + 1 <= tp->snd_up

The only time when this will fall apart is if we had super-packets
bigger than 64K.  Fortunately or unfortunately that is a long way
off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
