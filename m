From: Richard Guy Briggs <rgb@tricolour.ca>
Subject: Re: [PATCH] xfrm: fix state migration replay sequence numbers
Date: Thu, 18 May 2017 11:55:14 -0400
Message-ID: <20170518155514.GA17152@tricolour.ca>
References: <20170518143953.GA64905@AntonyAntony.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Antony Antony <antony@phenome.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toccata2.tricolour.ca ([204.225.221.17]:37800 "EHLO
        toccata2.tricolour.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755189AbdERQFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 12:05:39 -0400
Content-Disposition: inline
In-Reply-To: <20170518143953.GA64905@AntonyAntony.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-18 16:39, Antony Antony wrote:
> During xfrm migration replay and preplay sequence numbers are not 
> copied from the previous state. 
> 
> Here is tcpdump output showing the problem.
> 10.0.10.46 is running vanilla kernel, IKE/IPsec responder.
> After the migration it sent wrong sequence number, reset to 1.
> The migration is from 10.0.0.52 to 10.0.0.53.
> 
> IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7cf), length 136
> IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7cf), length 136
> IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d0), length 136
> IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7d0), length 136
> 
> IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
> IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]
> IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
> IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]
> 
> IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d1), length 136
> 
> NOTE: next sequence is wrong 0x1
> 
> IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x1), length 136
> IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d2), length 136
> IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x2), length 136
> 
> The attached patch fix it by copying replay and preplay.
> 
> regards,
> -antony
> 
> Antony Antony (1):
>   xfrm: fix state migration replay sequence numbers
> 
>  net/xfrm/xfrm_state.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> -- 
> 2.9.3
> 

> >From 1241e8b4c38ad2bf7399599165f763af38aba8d9 Mon Sep 17 00:00:00 2001
> From: Antony Antony <antony@phenome.org>
> Date: Thu, 18 May 2017 12:19:32 +0200
> Subject: [PATCH] xfrm: fix state migration copy replay sequence numbers
> To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Richard Guy Briggs <rgb@tricolour.ca>
> 
> During xfrm migration copy replay and preplay sequence numbers
> from the previous state.
> 
> Signed-off-by: Antony Antony <antony@phenome.org>
> ---
>  net/xfrm/xfrm_state.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index fc3c5aa..2e291bc 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1383,6 +1383,8 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig)
>  	x->curlft.add_time = orig->curlft.add_time;
>  	x->km.state = orig->km.state;
>  	x->km.seq = orig->km.seq;
> +	x->replay = orig->replay;
> +	x->preplay = orig->preplay;
>  
>  	return x;
>  
> -- 
> 2.9.3

This looks reasonable to me.  With a bit more out-of-band information from
Antony and Paul Wouters we have:

https://tools.ietf.org/html/rfc4555#section-3.5

so while it is not explicit about what is to be copied, it only indicates that
the IPsec SA is to be updated with the new address whereas this implementation
creates a new IPsec SA and copies over the values, missing some.

(Note: using "git format-patch --cover-letter --cc ... -o <dir>" and "git
send-email --to ... <dir>" work really well together.)

Reviewed-by: Richard Guy Briggs <rgb@tricolour.ca>




	slainte mhath, RGB
