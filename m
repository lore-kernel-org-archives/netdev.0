From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Mon, 16 May 2005 09:20:20 +1000
Message-ID: <20050515232020.GA19859@gondor.apana.org.au>
References: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au> <20050515104016.GA24344@gondor.apana.org.au> <20050515114121.GA4830@gondor.apana.org.au> <20050515.152441.106262257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050515.152441.106262257.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2005 at 03:24:41PM -0700, David S. Miller wrote:
>
> > So let's go the other way and make this an invariant:
> > 
> > 	For any skb on a frag_list, skb->sk must be NULL.
> > 
> > That is, the socket ownership always belongs to the head skb.
> > It turns out that the implementation is actually pretty simple.
> 
> Yes, I was just about to inform you that when SKBs are
> free'd up, only the head SKB's sk gets the destructor run
> on it.

Dave, I'm actually agreeing with you :) My patch does these two things:

1) Do what you did below for IPv4 to IPv6 as well.
2) Do what the comment (the one that you removed below) said and actually
   undo the truesize aggregation on the fast path in ip*_fragment.

I presume you won't have any problems with 1) since that's exactly
the same as your patch below except that it's for IPv6.

2) is needed because on the fast path the frag_list is unraveled so it
no longer makes sense to have the wmem all accounted to the head skb.
Please note that we only undo the attribution if the frag is not shared.
So the problem that your patch is meant fix won't occur here.

> @@ -1113,12 +1109,10 @@
>  		tail_skb = &(tmp_skb->next);
>  		skb->len += tmp_skb->len;
>  		skb->data_len += tmp_skb->len;
> -#if 0 /* Logically correct, but useless work, ip_fragment() will have to undo */
>  		skb->truesize += tmp_skb->truesize;
>  		__sock_put(tmp_skb->sk);
>  		tmp_skb->destructor = NULL;
>  		tmp_skb->sk = NULL;
> -#endif

All I'm saying is that if we remove the #if 0 then we should do as it
suggests and undo this accounting in ip_fragment.

BTW, I missed the netfilter defrag code in my patch.  I'll send an
updated version soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
