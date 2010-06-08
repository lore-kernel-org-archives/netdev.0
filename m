From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 08 Jun 2010 17:58:41 -0600
Message-ID: <4C0ED931.6030402@canonical.com>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>	<20100607145910.2458ac87@nehalam>	<4C0D7312.1020300@intel.com>	<1276006721.2486.141.camel@edumazet-laptop> <AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020004000901060203030506"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:3011 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925Ab0FHX6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 19:58:47 -0400
In-Reply-To: <AANLkTiluIibUglhf28JAeSLzBC0E1Zw0STPoqFTbXcev@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020004000901060203030506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

On 06/08/2010 05:00 PM, Tom Herbert wrote:
> How about only checking against dev->num_rx_queues when that value is
> greater than one.  Since bonding device is calling alloc_netdev, it is
> not going to set the queue mapping, but dev->num_rx_queues will be one
> in that case (this handles any intermediate driver that does do
> multiple queues).
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6f330ce..30ab66d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2270,7 +2270,7 @@ static int get_rps_cpu(struct net_device *dev,
> struct sk_buff *skb,
>                  u16 v16[2];
>          } ports;
>
> -       if (skb_rx_queue_recorded(skb)) {
> +       if (skb_rx_queue_recorded(skb)&&  dev->num_rx_queues>  1) {
>                  u16 index = skb_get_rx_queue(skb);
>                  if (unlikely(index>= dev->num_rx_queues)) {
>                          if (net_ratelimit()) {
>
>
> On Tue, Jun 8, 2010 at 7:18 AM, Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>> Le lundi 07 juin 2010 à 15:30 -0700, John Fastabend a écrit :
>>
>>> There is always a possibility that the underlying device sets the
>>> queue_mapping to be greater then num_cpus.  Also I suspect the same
>>> issue exists with bonding devices.  Maybe something like the following
>>> is worth while? compile tested only,
>>>
>>> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
>>>
>>> recv path reassigns skb->dev without sanity checking the
>>> queue_mapping field.  This can result in the queue_mapping
>>> field being set incorrectly if the new dev supports less
>>> queues then the underlying device.
>>>
>>> This patch just resets the queue_mapping to 0 which should
>>> resolve this issue?  Any thoughts?
>>>
>>> The same issue could happen on bonding devices as well.
>>>
>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>> ---
>>>
>>>    net/8021q/vlan_core.c |    6 ++++++
>>>    1 files changed, 6 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>>> index bd537fc..ad309f8 100644
>>> --- a/net/8021q/vlan_core.c
>>> +++ b/net/8021q/vlan_core.c
>>> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct
>>> vlan_group *grp,
>>>        if (!skb->dev)
>>>                goto drop;
>>>
>>> +     if (unlikely(skb->queue_mapping>= skb->dev->real_num_tx_queues))
>>> +             skb_set_queue_mapping(skb, 0);
>>> +
>>>        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>>>
>>>    drop:
>>> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struct
>>> vlan_group *grp,
>>>        if (!skb->dev)
>>>                goto drop;
>>>
>>> +     if (unlikely(skb->queue_mapping>= skb->dev->real_num_tx_queues))
>>> +             skb_set_queue_mapping(skb, 0);
>>> +
>>>        for (p = napi->gro_list; p; p = p->next) {
>>>                NAPI_GRO_CB(p)->same_flow =
>>>                        p->dev == skb->dev&&  !compare_ether_header(
>>> --
>>
>> Only a workaround, added in hot path in a otherwise 'good' driver
>> (multiqueue enabled and ready)
>>
>> eth0  ------->  bond / bridge --------->  vlan.id
>> (nbtxq=8)      (ntxbq=1)        (nbtxq=X)
>>
>> X is capped to 1 because of bond/bridge, while bond has no "queue"
>> (LLTX driver)
>>
>> Solutions :
>>
>> 1) queue_mapping could be silently tested in get_rps_cpu()...
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 6f330ce..3a3f7f6 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2272,14 +2272,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
>>
>>         if (skb_rx_queue_recorded(skb)) {
>>                 u16 index = skb_get_rx_queue(skb);
>> -               if (unlikely(index>= dev->num_rx_queues)) {
>> -                       if (net_ratelimit()) {
>> -                               pr_warning("%s received packet on queue "
>> -                                       "%u, but number of RX queues is %u\n",
>> -                                       dev->name, index, dev->num_rx_queues);
>> -                       }
>> -                       goto done;
>> -               }
>> +               if (WARN_ONCE(index>= dev->num_rx_queues,
>> +                               KERN_WARNING "%s received packet on queue %u, "
>> +                               "but number of RX queues is %u\n",
>> +                               dev->name, index, dev->num_rx_queues))
>> +                       index %= dev->num_rx_queues;
>>                 rxqueue = dev->_rx + index;
>>         } else
>>                 rxqueue = dev->_rx;
>>
>>
>>
>> 2) bond/bridge should setup more queues, just in case.
>>    We probably need to be able to make things more dynamic,
>>    (propagate nbtxq between layers) but not for 2.6.35
>>
>>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 5e12462..ce813dd 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *name)
>>
>>         rtnl_lock();
>>
>> -       bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
>> -                               bond_setup);
>> +       bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
>> +                                  bond_setup, max(64, nr_cpu_ids));
>>         if (!bond_dev) {
>>                 pr_err("%s: eek! can't alloc netdev!\n", name);
>>                 rtnl_unlock();
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Huh, so you guys are looking at the same issue (only my issue is RPS). 
See http://marc.info/?l=linux-netdev&m=127603240621028&w=2. I'm in favor 
of dropping the warning when no queues have been allocated.

How about this (see attached).

rtg

-- 
Tim Gardner tim.gardner@canonical.com

--------------020004000901060203030506
Content-Type: text/x-patch;
 name="0001-net-Print-num_rx_queues-warning-only-when-there-are-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-net-Print-num_rx_queues-warning-only-when-there-are-.pa";
 filename*1="tch"

>From 391b0140b5c7e410d55258a8a2541bddf84d8d0e Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Tue, 8 Jun 2010 17:51:27 -0600
Subject: [PATCH] net: Print num_rx_queues warning only when there are allocated queues

Most users of skb_record_rx_queue() do not use alloc_netdev_mq() for
network device initialization, so don't print a warning about num_rx_queues
overflow in get_rps_cpu() unless they have actually been allocated.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d03470f..0852608 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2253,7 +2253,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
-			if (net_ratelimit()) {
+			if (dev->num_rx_queues > 1 && net_ratelimit()) {
 				pr_warning("%s received packet on queue "
 					"%u, but number of RX queues is %u\n",
 					dev->name, index, dev->num_rx_queues);
-- 
1.7.0.4


--------------020004000901060203030506--
