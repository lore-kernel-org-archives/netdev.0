From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 17:29:31 +0100
Message-ID: <4381F5EB.7050705@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>	<438185ED.3050005@miyazawa.org>
	<20051121.175033.87771604.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kazunori@miyazawa.org, davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20051121.175033.87771604.yoshfuji@linux-ipv6.org>
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

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> Hello.
> 
> In article <438185ED.3050005@miyazawa.org> (at Mon, 21 Nov 2005 17:31:41 +0900), Kazunori Miyazawa <kazunori@miyazawa.org> says:
> 
> 
>>Your ip_xfrm_transport_hook is a good idea, I think.
>>
>>We could call ip6_rcv_finish if the netfilter changed the addresses
>>or otherwise we can continue the loop to avoid the cost in a similar
>>way because we can know the change with checking skb->dst.
> 
> 
> Well, I agree.
> 
> Probably, we can do similarly for ipv6; e.g.:
> 
> int ip6_xfrm_transport_hook(struct sk_buff *skb)
> {
> #if 0 /* We NEVER support NAT. :-) */
>      if (likely(skb->dst == NULL)) {
>             int err = ip6_route_input()
>             if (unlikely(err))
>                      goto drop;
>      }
> #endif
>      __skb_pull(skb, skb->h.raw - skb->nh.raw);
>      return NET_RX_SUCCESS;
> drop:
>      kfree_skb(skb);
>      return NET_RX_DROP;
> }
> 
> :
> 
>       } else {
> #ifdef CONFIG_NETFILTER
>              skb->nh.ipv6h->payload_len = htons(skb->len);
> 	     skb->h.raw = skb->data;
>              __skb_push(skb, skb->data - skb->nh.raw);
> 
>              if (NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
>                          ip6_xfrm_transport_hook) == NET_RX_DROP)
>                  return -1;
> #endif
>              return 1;
>       }
> 
> Then, we can continue parsing extension headers, I think.

Is it the rerouting you're concerned about? It will usually not
happen because skb->dst is not NULL. Its needed for NFQUEUE,
packets can be changes in userspace and need rerouting afterwards.
In any case there would still be one path on which extension
headers would be parsed twice, so I'm going to look into different
ways to fix that.
