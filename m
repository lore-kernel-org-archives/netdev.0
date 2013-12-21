From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: mld: Prevent skb_over_panic with large MTUs
Date: Fri, 20 Dec 2013 17:24:58 -0800
Message-ID: <1387589098.19078.489.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387587610-31723-1-git-send-email-travisb@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Travis Brown <travisb@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:58853 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab3LUBZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 20:25:05 -0500
Received: by mail-yh0-f41.google.com with SMTP id f11so783294yha.0
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 17:25:01 -0800 (PST)
In-Reply-To: <1387587610-31723-1-git-send-email-travisb@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 17:00 -0800, Travis Brown wrote:
> MLD limits the maximum skb size to fit within a single page. Later
> code uses the device MTU, if available, to determine whether the skb
> has sufficient room for another field. On interfaces with MTUs larger
> than the page size, less the skb overhead, this can result in the skb
> being overrun and a skb_over_panic being generated.
> 
> Fix MLD in the same way IGMPv3 was fixed in the commit 57e1ab6e
> ("igmp: refine skb allocations"), by storing the requested packet size
> into skb->cb[0] and using that instead of the device MTU.
> 
> Signed-off-by: Travis Brown <travisb@aristanetworks.com>
> ---
>  net/ipv6/mcast.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index d18f9f9..3c6cbc3 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1522,6 +1522,7 @@ static void ip6_mc_hdr(struct sock *sk, struct sk_buff *skb,
>  	hdr->daddr = *daddr;
>  }
>  
> +#define mld_skb_size(skb) (*(unsigned int *)((skb)->cb))
>  static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
>  {
>  	struct net_device *dev = idev->dev;
> @@ -1531,6 +1532,7 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
>  	struct mld2_report *pmr;
>  	struct in6_addr addr_buf;
>  	const struct in6_addr *saddr;
> +	int skb_size;
>  	int hlen = LL_RESERVED_SPACE(dev);
>  	int tlen = dev->needed_tailroom;
>  	int err;
> @@ -1539,14 +1541,16 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, int size)
>  		     IPV6_TLV_PADN, 0 };
>  
>  	/* we assume size > sizeof(ra) here */
> -	size += hlen + tlen;
> +	skb_size = size + hlen + tlen;
>  	/* limit our allocations to order-0 page */
> -	size = min_t(int, size, SKB_MAX_ORDER(0, 0));
> -	skb = sock_alloc_send_skb(sk, size, 1, &err);
> +	skb_size = min_t(int, skb_size, SKB_MAX_ORDER(0, 0));
> +	skb = sock_alloc_send_skb(sk, skb_size, 1, &err);
>  
>  	if (!skb)
>  		return NULL;
>  
> +	mld_skb_size(skb) = size;
> +
>  	skb->priority = TC_PRIO_CONTROL;
>  	skb_reserve(skb, hlen);
>  
> @@ -1661,7 +1665,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>  	return skb;
>  }
>  
> -#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? (skb)->dev->mtu - (skb)->len : \
> +#define AVAILABLE(skb) ((skb) ? ((skb)->dev ? mld_skb_size(skb) - (skb)->len : \
>  	skb_tailroom(skb)) : 0)
>  

Not clear why this macro is like that....

It looks like it should really be 

#define AVAILABLE(skb) ((skb) ? (mld_skb_size(skb) - (skb)->len) : 0)

Or even better use skb_availroom() as we do in TCP stack...
(check sk_stream_alloc_skb())

Nice catch, thanks Travis !

Fixes: 72e09ad107e78 ("ipv6: avoid high order allocations")
