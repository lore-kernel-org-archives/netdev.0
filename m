From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 18:03:33 +1000
Message-ID: <E1G5Ht7-00060p-00@gondolin.me.apana.org.au>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5135 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751502AbWGYIDy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 04:03:54 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060719145716.4cb9e7e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
>
> @@ -1593,12 +1594,19 @@ int ipmr_get_route(struct sk_buff *skb, 
>                        read_unlock(&mrt_lock);
>                        return -ENODEV;
>                }
> -               skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
> -               skb->nh.iph->ihl = sizeof(struct iphdr)>>2;
> -               skb->nh.iph->saddr = rt->rt_src;
> -               skb->nh.iph->daddr = rt->rt_dst;
> -               skb->nh.iph->version = 0;
> -               err = ipmr_cache_unresolved(vif, skb);
> +               
> +               iskb = alloc_skb(sizeof(struct iphdr), GFP_KERNEL);
> +               if (!iskb) {
> +                       read_unlock(&mrt_lock);
> +                       return -ENOMEM;
> +               }
> +               memset(iskb->data, 0, sizeof(struct iphdr));
> +               iskb->nh.raw = iskb->data;
> +               iskb->nh.iph->ihl = sizeof(struct iphdr)>>2;
> +               iskb->nh.iph->saddr = rt->rt_src;
> +               iskb->nh.iph->daddr = rt->rt_dst;
> +
> +               err = ipmr_cache_unresolved(vif, iskb);

I'm afraid this is still broken in a different way.

If ipmr_cache_unresolved queues the skb onto the unresolved list things
it's going to try to use the skb as a netlink skb instead :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
