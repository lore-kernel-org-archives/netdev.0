From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/8] ipv4: Add GRO infrastructure
Date: Fri, 12 Dec 2008 22:55:40 +0000
Message-ID: <1229122540.3051.78.camel@achroite>
References: <20081212053116.GA2927@gondor.apana.org.au>
	 <E1LB0cy-0000rD-Pr@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:45574 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515AbYLLWzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 17:55:46 -0500
In-Reply-To: <E1LB0cy-0000rD-Pr@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
[...]
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 1aa2dc9..260f081 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -94,6 +94,7 @@
>  #include <linux/igmp.h>
>  #include <linux/inetdevice.h>
>  #include <linux/netdevice.h>
> +#include <net/checksum.h>
>  #include <net/ip.h>
>  #include <net/protocol.h>
>  #include <net/arp.h>
> @@ -1245,6 +1246,99 @@ out:
>  	return segs;
>  }
>  
> +static struct sk_buff **inet_gro_receive(struct sk_buff **head,
> +					 struct sk_buff *skb)
> +{
> +	struct net_protocol *ops;
> +	struct sk_buff **pp = NULL;
> +	struct sk_buff *p;
> +	struct iphdr *iph;
> +	int flush = 1;
> +	int proto;
> +	int id;
> +
> +	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
> +		goto out;
> +
> +	iph = ip_hdr(skb);
> +	proto = iph->protocol & (MAX_INET_PROTOS - 1);
> +
> +	rcu_read_lock();
> +	ops = rcu_dereference(inet_protos[proto]);
> +	if (!ops || !ops->gro_receive)
> +		goto out_unlock;
> +
> +	if (iph->version != 4 || iph->ihl != 5)
> +		goto out_unlock;
> +
> +	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> +		goto out_unlock;

Don't we also need to check that skb->len >= iph->ihl * 4?

> +	flush = ntohs(iph->tot_len) != skb->len ||
> +		iph->frag_off != htons(IP_DF);
> +	id = ntohs(iph->id);
> +
> +	for (p = *head; p; p = p->next) {
> +		struct iphdr *iph2;
> +
> +		if (!NAPI_GRO_CB(p)->same_flow)
> +			continue;
> +
> +		iph2 = ip_hdr(p);
> +
> +		if (iph->protocol != iph2->protocol ||
> +		    memcmp(&iph->saddr, &iph2->saddr, 8)) {
> +			NAPI_GRO_CB(p)->same_flow = 0;
> +			continue;
> +		}
> +
> +		/* All fields must match except length and checksum. */
> +		NAPI_GRO_CB(p)->flush |=
> +			memcmp(&iph->frag_off, &iph2->frag_off, 4) ||

This covers frag_off, ttl and protocol.  But frag_off and protocol have
already been covered, and tos seems to have been missed.

> +			(u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
> +		NAPI_GRO_CB(p)->flush |= flush;
> +	}
> +
> +	NAPI_GRO_CB(skb)->flush |= flush;
> +	__skb_pull(skb, sizeof(*iph));
> +	skb_reset_transport_header(skb);
> +
> +	pp = ops->gro_receive(head, skb);
> +
> +out_unlock:
> +	rcu_read_unlock();
> +
> +out:
> +	NAPI_GRO_CB(skb)->flush |= flush;
> +
> +	return pp;
> +}
[...]

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

