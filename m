From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] tbf scheduler: TSO support (update 2)
Date: Thu, 17 May 2007 23:55:30 +1000
Message-ID: <20070517135530.GA4381@gondor.apana.org.au>
References: <20070514.012125.105712952.taka@valinux.co.jp> <E1HnTfk-0004z5-00@gondolin.me.apana.org.au> <20070515.203953.03891900.taka@valinux.co.jp> <20070515.204148.114469367.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, linux-net@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3062 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755257AbXEQN4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 09:56:35 -0400
Content-Disposition: inline
In-Reply-To: <20070515.204148.114469367.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 08:41:48PM +0900, Hirokazu Takahashi wrote:
>  
> @@ -924,7 +926,9 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
>  				cl->xstats.borrows += skb->len;
>  #endif
>  			}
> -			q->tx_len = skb->len;
> +			q->tx_segs = skb_shinfo(skb)->gso_segs ? :
> +			  skb_shinfo(skb)->gso_size ? skb->len/skb_shinfo(skb)->gso_size + 1 : 1;
> +			q->tx_len = (skb->len - 1)/q->tx_segs + 1;

This isn't safe for Xen (and potentially other virtualisation
environments) since qdisc code runs before dev_hard_start_xmit
which is where we verify the sanity of gso_segs.  So you could
be using some arbitrary value from an untrusted source.

If you really want to use it, you should test for SKB_GSO_DODGY
on the packet which will be set if gso_segs can't be trusted.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
