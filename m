From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 1 May 2008 19:02:53 +0800
Message-ID: <20080501110253.GC7490@gondor.apana.org.au>
References: <20080501.024320.212547875.davem@davemloft.net> <E1JrW9h-0001tI-00@gondolin.me.apana.org.au> <20080501.034950.261408566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080501.034950.261408566.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 01, 2008 at 03:49:50AM -0700, David Miller wrote:
>
> Once that is cured, I think we can detect this better, by adding a
> carefully constructed assertion to pskb_expand_head().  Basically, the
> idea is, if "nhead" or "ntail" are non-zero, and there is a socket
> still attached to the SKB, print a warning message.
> 
> Something like:
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 4fe605f..9bfca08 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -699,6 +699,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  	if (skb_shared(skb))
>  		BUG();
>  
> +	if (unlikely((nhead || ntail) && skb->sk)) {
> +		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
> +		       "with socket attached\n",
> +		       nhead, ntail);
> +	}

This could actually work :) I was worried about tunnelling doing
a genuine expansion on such a packet but it turns that it does a
skb_clone first.  So perhaps we should just require that if a
packet is to be expanded while attached to a socket then it must
be cloned first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
