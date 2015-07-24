From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] route: allow to route in a peer netns via
 lwt framework
Date: Fri, 24 Jul 2015 17:39:57 +0200
Message-ID: <1437752397.20182.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55B1077F.1090501@6wind.com>
	 <1437747419-8442-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, tgraf@suug.ch
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38431 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbGXPkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 11:40:01 -0400
Received: by wibxm9 with SMTP id xm9so33329913wib.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 08:40:00 -0700 (PDT)
In-Reply-To: <1437747419-8442-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2015-07-24 at 16:16 +0200, Nicolas Dichtel wrote:
> This patch takes advantage of the newly added lwtunnel framework to
> allow the user to set routes that point to a peer netns.
> 
> Packets are injected to the peer netns via the loopback device. It works
> only when the output device is 'lo'.
> 
> Example:
> ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo
> 

Is this feature so badly wanted to add complexity on lo device ?

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: rework loopback handling part (update stats and call skb_dst_force())
>     fix ipv6 processing
>     check lwtunnel type before converting data to a nsid
> 
>  drivers/net/loopback.c        | 33 +++++++++++++++++++++------
>  include/net/lwtunnel.h        | 27 ++++++++++++++++++++++
>  include/uapi/linux/lwtunnel.h |  1 +
>  net/core/net_namespace.c      | 52 +++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/route.c              |  9 ++++++--
>  5 files changed, 113 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index c76283c2f84a..4358256ff94e 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -57,6 +57,7 @@
>  #include <linux/percpu.h>
>  #include <net/net_namespace.h>
>  #include <linux/u64_stats_sync.h>
> +#include <net/lwtunnel.h>
>  
>  struct pcpu_lstats {
>  	u64			packets;
> @@ -71,29 +72,47 @@ struct pcpu_lstats {
>  static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>  				 struct net_device *dev)
>  {
> +	int nsid = skb_lwt_netns_info(skb);
>  	struct pcpu_lstats *lb_stats;
> -	int len;
> -
> -	skb_orphan(skb);
> +	struct net *peernet = NULL;
> +	int len, ret;
>  
>  	/* Before queueing this packet to netif_rx(),
>  	 * make sure dst is refcounted.
>  	 */
>  	skb_dst_force(skb);
>  
> -	skb->protocol = eth_type_trans(skb, dev);
> +	if (nsid != NETNSA_NSID_NOT_ASSIGNED) {
> +		peernet = get_net_ns_by_id(dev_net(dev), nsid);
> +		if (!peernet) {
> +			kfree_skb(skb);
> +			goto end;
> +		}
> +
> +		/* it's OK to use per_cpu_ptr() because BHs are off */
> +		lb_stats = this_cpu_ptr(peernet->loopback_dev->lstats);
> +		ret = dev_forward_skb(peernet->loopback_dev, skb);
> +	} else {
> +		skb_orphan(skb);
>  
> -	/* it's OK to use per_cpu_ptr() because BHs are off */
> -	lb_stats = this_cpu_ptr(dev->lstats);
> +		skb->protocol = eth_type_trans(skb, dev);
> +
> +		/* it's OK to use per_cpu_ptr() because BHs are off */
> +		lb_stats = this_cpu_ptr(dev->lstats);
> +		ret = netif_rx(skb);
> +	}
>  
>  	len = skb->len;

<use after free error>  At this point you no longer can access skb

> -	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
> +	if (likely(ret == NET_RX_SUCCESS)) {
>  		u64_stats_update_begin(&lb_stats->syncp);
>  		lb_stats->bytes += len;
>  		lb_stats->packets++;
>  		u64_stats_update_end(&lb_stats->syncp);
>  	}
>  
> +end:
> +	if (peernet)
> +		put_net(peernet);
>  	return NETDEV_TX_OK;
>  }
>  
