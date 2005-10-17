From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Mon, 17 Oct 2005 09:49:19 +0900 (JST)
Message-ID: <20051017.094919.56989341.yoshfuji@linux-ipv6.org>
References: <4352EEC8.9000602@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <4352EEC8.9000602@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <4352EEC8.9000602@trash.net> (at Mon, 17 Oct 2005 02:22:32 +0200), Patrick McHardy <kaber@trash.net> says:

> [NETFILTER]: Make IPsec input processing symetrical to output

I think this comment is not appropriate.
 1. They are not "NETFILTER" but rather "CORE" IPv4/6 stack.
 2. There are several known bad side effects.
    They should be described.

:
> diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> --- a/net/ipv6/xfrm6_input.c
> +++ b/net/ipv6/xfrm6_input.c
> @@ -121,16 +121,21 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
>  	skb->sp->len += xfrm_nr;
>  	skb->ip_summed = CHECKSUM_NONE;
>  
> -	if (decaps) {
> -		if (!(skb->dev->flags&IFF_LOOPBACK)) {
> -			dst_release(skb->dst);
> -			skb->dst = NULL;
> -		}
> -		netif_rx(skb);
> -		return -1;
> -	} else {
> -		return 1;
> +	if (!decaps) {
> +		if (skb_cloned(skb) &&
> +		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
> +			goto drop;
> +		/* FIXME: Jumbo payload option */
> +		skb->nh.ipv6h->payload_len = htons(skb->len);
> +		__skb_push(skb, skb->data - skb->nh.raw);
>  	}
> +	if (!(skb->dev->flags&IFF_LOOPBACK)) {
> +		dst_release(skb->dst);
> +		skb->dst = NULL;
> +	}
> +	nf_reset(skb);
> +	netif_rx(skb);
> +	return -1;
>  
>  drop_unlock:
>  	spin_unlock(&x->lock);

I diagree.
Stack should process the packet just once if it is of transport mode.
(It is okay to process one twice if it is of tunnel mode.)

--yoshfuji
