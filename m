From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 17:50:33 +0900 (JST)
Message-ID: <20051121.175033.87771604.yoshfuji@linux-ipv6.org>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<438185ED.3050005@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kazunori@miyazawa.org, kaber@trash.net
In-Reply-To: <438185ED.3050005@miyazawa.org>
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

Hello.

In article <438185ED.3050005@miyazawa.org> (at Mon, 21 Nov 2005 17:31:41 +0900), Kazunori Miyazawa <kazunori@miyazawa.org> says:

> Your ip_xfrm_transport_hook is a good idea, I think.
> 
> We could call ip6_rcv_finish if the netfilter changed the addresses
> or otherwise we can continue the loop to avoid the cost in a similar
> way because we can know the change with checking skb->dst.

Well, I agree.

In article <20051120163135.16666.76993.sendpatchset@localhost.localdomain> (at Sun, 20 Nov 2005 17:31:36 +0100), Patrick McHardy <kaber@trash.net> says:

> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
> index b93e7cd..3c39296 100644
> --- a/net/ipv4/netfilter.c
> +++ b/net/ipv4/netfilter.c
> @@ -105,6 +105,26 @@ int ip_dst_output(struct sk_buff *skb)
>  	return dst_output(skb);
>  }
>  EXPORT_SYMBOL(ip_dst_output);
> +
> +/*
> + * okfn for transport mode xfrm_input.c hook. Basically a copy of
> + * ip_rcv_finish without statistics and option parsing.
> + */
> +int ip_xfrm_transport_hook(struct sk_buff *skb)
> +{
> +	struct iphdr *iph = skb->nh.iph;
> +
> +	if (likely(skb->dst == NULL)) {
> +		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
> +		                         skb->dev);
> +		if (unlikely(err))
> +			goto drop;
> +	}
> +	return dst_input(skb);
> +drop:
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
>  #endif /* CONFIG_XFRM */
>  
:
> @@ -129,7 +133,16 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
>  		netif_rx(skb);
>  		return -1;
>  	} else {
> +#ifdef CONFIG_NETFILTER
> +		skb->nh.ipv6h->payload_len = htons(skb->len);
> +		__skb_push(skb, skb->data - skb->nh.raw);
> +
> +		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
> +		        ip6_rcv_finish);
> +		return -1;
> +#else
>  		return 1;
> +#endif
>  	}
>  

Probably, we can do similarly for ipv6; e.g.:

int ip6_xfrm_transport_hook(struct sk_buff *skb)
{
#if 0 /* We NEVER support NAT. :-) */
     if (likely(skb->dst == NULL)) {
            int err = ip6_route_input()
            if (unlikely(err))
                     goto drop;
     }
#endif
     __skb_pull(skb, skb->h.raw - skb->nh.raw);
     return NET_RX_SUCCESS;
drop:
     kfree_skb(skb);
     return NET_RX_DROP;
}

:

      } else {
#ifdef CONFIG_NETFILTER
             skb->nh.ipv6h->payload_len = htons(skb->len);
	     skb->h.raw = skb->data;
             __skb_push(skb, skb->data - skb->nh.raw);

             if (NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
                         ip6_xfrm_transport_hook) == NET_RX_DROP)
                 return -1;
#endif
             return 1;
      }

Then, we can continue parsing extension headers, I think.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
