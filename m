From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Thu, 23 Jul 2015 08:01:48 -0700
Message-ID: <55B101DC.6040609@cumulusnetworks.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34956 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbbGWPBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 11:01:50 -0400
Received: by pdrg1 with SMTP id g1so158396148pdr.2
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 08:01:50 -0700 (PDT)
In-Reply-To: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/15, 7:22 AM, Nicolas Dichtel wrote:
> This patch takes advantage of the newly added lwtunnel framework to
> allow the user to set routes that points to a peer netns.
>
> Packets are injected to the peer netns via the loopback device. It works
> only when the output device is 'lo'.
>
> Example:
> ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   drivers/net/loopback.c        | 16 +++++++++++++
>   include/net/lwtunnel.h        | 23 +++++++++++++++++++
>   include/uapi/linux/lwtunnel.h |  1 +
>   net/core/net_namespace.c      | 52 +++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 92 insertions(+)
>
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index c76283c2f84a..758d02f592f9 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -57,6 +57,7 @@
>   #include <linux/percpu.h>
>   #include <net/net_namespace.h>
>   #include <linux/u64_stats_sync.h>
> +#include <net/lwtunnel.h>
>   
>   struct pcpu_lstats {
>   	u64			packets;
> @@ -71,9 +72,23 @@ struct pcpu_lstats {
>   static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>   				 struct net_device *dev)
>   {
> +	int nsid = skb_lwt_netns_info(skb);
>   	struct pcpu_lstats *lb_stats;
>   	int len;
>   
> +	if (nsid >= 0) {
> +		struct net *peernet = get_net_ns_by_id(dev_net(dev), nsid);
> +
> +		if (!peernet) {
> +			kfree_skb(skb);
> +			goto end;
> +		}
> +
> +		dev_forward_skb(peernet->loopback_dev, skb);
> +		put_net(peernet);
> +		goto end;
> +	}
> +
>   	skb_orphan(skb);
>   
>   	/* Before queueing this packet to netif_rx(),
> @@ -94,6 +109,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>   		u64_stats_update_end(&lb_stats->syncp);
>   	}
>   
> +end:
>   	return NETDEV_TX_OK;
>   }
>   
> diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
> index 918e03c1dafa..cc05ce3c1aae 100644
> --- a/include/net/lwtunnel.h
> +++ b/include/net/lwtunnel.h
> @@ -5,7 +5,9 @@
>   #include <linux/netdevice.h>
>   #include <linux/skbuff.h>
>   #include <linux/types.h>
> +#include <linux/net_namespace.h>
>   #include <net/route.h>
> +#include <net/ip6_fib.h>
>   
>   #define LWTUNNEL_HASH_BITS   7
>   #define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
> @@ -141,4 +143,25 @@ static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
>   
>   #endif
>   
> +static inline u32 *lwt_netns_info(struct lwtunnel_state *lwtstate)
> +{
> +	return (u32 *)lwtstate->data;
> +}
> +
> +static inline int skb_lwt_netns_info(struct sk_buff *skb)
> +{
> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		struct rtable *rt = (struct rtable *)skb_dst(skb);
> +
> +		if (rt && rt->rt_lwtstate)
> +			return *lwt_netns_info(rt->rt_lwtstate);
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
> +
> +		if (rt6 && rt6->rt6i_lwtstate)
> +			return *lwt_netns_info(rt6->rt6i_lwtstate);
> +	}
> +
> +	return NETNSA_NSID_NOT_ASSIGNED;
> +}
>   #endif /* __NET_LWTUNNEL_H */
since these apis' don't have to be netns specific,
Can they just be named lwtunnel_get_state_data and skb_lwtunnel_state ?

and seems like they should be declared for both CONFIG_LWTUNNEL 'y' and 'n'.

Thanks,
Roopa
