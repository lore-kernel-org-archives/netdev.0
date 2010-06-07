From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Mon, 07 Jun 2010 16:13:37 -0700
Message-ID: <4C0D7D21.2030507@intel.com>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net> <20100607145910.2458ac87@nehalam> <4C0D7312.1020300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36185 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab0FGXMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 19:12:52 -0400
In-Reply-To: <4C0D7312.1020300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend wrote:
> Stephen Hemminger wrote:
>> On Mon, 7 Jun 2010 22:36:11 +0200
>> Peter Lieven <pl@dlh.net> wrote:
>>
>>> Hi,
>>>
>>> i today tried out 2.6.32-rc2 and I see a lot of warning messages like this:
>>>
>>> Jun  7 22:33:15 172.21.55.20 kernel: [ 3012.575884] br141 received packet on queue 4, but number of RX queues is 1
>>>
>>> The host is a SMP system with 8 cores, so I think there is expected to be one rx queue per CPU, but it seems
>>> the bridge iface has only one.
>>>
>> The bridge interface has no queues. It doesn't queue any packets. 
>> The test in receive packet path is not appropriate in this case.
>> Not sure what the right fix is. Pretending the bridge device has
>> multiple queues (num_queues == NUM_CPUS) is a possibility but
>> seems like overhead without real increase in parallelism.
>>
>>
>>
> 
> There is always a possibility that the underlying device sets the 
> queue_mapping to be greater then num_cpus.  Also I suspect the same 
> issue exists with bonding devices.  Maybe something like the following 
> is worth while? compile tested only,
> 
> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
> 
> recv path reassigns skb->dev without sanity checking the
> queue_mapping field.  This can result in the queue_mapping
> field being set incorrectly if the new dev supports less
> queues then the underlying device.
> 
> This patch just resets the queue_mapping to 0 which should
> resolve this issue?  Any thoughts?
> 
> The same issue could happen on bonding devices as well.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>   net/8021q/vlan_core.c |    6 ++++++
>   1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index bd537fc..ad309f8 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct 
> vlan_group *grp,
>   	if (!skb->dev)
>   		goto drop;
> 
> +	if (unlikely(skb->queue_mapping >= skb->dev->real_num_tx_queues))
> +		skb_set_queue_mapping(skb, 0);
> +

Actually this should be dev->num_rx_queues not real_num_tx_queues.

>   	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
> 
>   drop:
> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struct 
> vlan_group *grp,
>   	if (!skb->dev)
>   		goto drop;
> 
> +	if (unlikely(skb->queue_mapping >= skb->dev->real_num_tx_queues))
> +		skb_set_queue_mapping(skb, 0);
> +

same here.

>   	for (p = napi->gro_list; p; p = p->next) {
>   		NAPI_GRO_CB(p)->same_flow =
>   			p->dev == skb->dev && !compare_ether_header(
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

