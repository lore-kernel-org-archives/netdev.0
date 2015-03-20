From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 10:11:24 -0700
Message-ID: <550C54BC.4040509@intel.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com, davem@davemloft.net, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbbCTRLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 13:11:42 -0400
In-Reply-To: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 09:58 AM, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
> there is a need to not re-forward frames that have already been
> forwarded in hardware.
> 
> Typically these are broadcast or multicast frames forwarded by the
> hardware to multiple destination ports including sending a copy of
> the packet to the cpu (kernel e.g. an arp broadcast).
> The bridge driver will try to forward the packet again, resulting in
> two copies of the same packet.
> 
> These packets can also come up to the kernel for logging when they hit
> a LOG acl rule in hardware. In such cases, you do want the packet
> to go through the bridge netfilter hooks. Hence, this patch adds the
> required checks just before the packet is being xmited.
> 
> v2:
> 	- Add a new hw_fwded flag in skbuff to indicate that the packet
> 	is already hardware forwarded. Switch driver will set this flag.
> 	I have been trying to avoid having this flag in the skb
> 	and thats why this patch has been in my tree for long. Cant think
> 	of other better alternatives. Suggestions are welcome. I have put
> 	this under CONFIG_NET_SWITCHDEV to minimize the impact.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> ---

Interesting. I completely avoid this problem by not instantiating a
software bridge ;) When these pkts come up the stack I either use a
raw socket to capture them, put a 'tc' ingress rule to do something,
or have OVS handle them in some special way. It seems to me that this
is where the sw/hw model starts to break when you have these magic
bits to handle the packets differently.

How do you know to set the skb bit? Do you have some indicator in the
descriptor? I don't have any good way to learn this on my hardware. But
I can assume if it reached the CPU it was because of some explicit rule.
 
>  include/linux/skbuff.h  |    7 +++++--
>  net/bridge/br_forward.c |   11 +++++++++++
>  2 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index bba1330..1973b5c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -560,8 +560,11 @@ struct sk_buff {
>  				fclone:2,
>  				peeked:1,
>  				head_frag:1,
> -				xmit_more:1;
> -	/* one bit hole */
> +				xmit_more:1,
> +#ifdef CONFIG_NET_SWITCHDEV
> +				hw_fwded:1;
> +#endif
> +	/* one bit hole if CONFIG_NET_SWITCHDEV not defined */
>  	kmemcheck_bitfield_end(flags1);
>  
>  	/* fields enclosed in headers_start/headers_end are copied
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index 3304a54..b60b96e 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -37,6 +37,17 @@ static inline int should_deliver(const struct net_bridge_port *p,
>  
>  int br_dev_queue_push_xmit(struct sk_buff *skb)
>  {
> +
> +#ifdef CONFIG_NET_SWITCHDEV
> +	/* If skb is already hw forwarded and the port being forwarded
> +	 * to is a switch port, dont reforward
> +	 */
> +	if (skb->hw_fwded && (skb->dev->features & NETIF_F_HW_SWITCH_OFFLOAD)) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +#endif
>  	if (!is_skb_forwardable(skb->dev, skb)) {
>  		kfree_skb(skb);
>  	} else {
> 
