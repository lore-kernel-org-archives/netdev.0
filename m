From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 1/2] mactap: Fix checksum errors for non-gso packets in
 bridge mode
Date: Thu, 24 Apr 2014 10:05:20 -0400
Message-ID: <53591A20.6080009@redhat.com>
References: <1398271901-32534-1-git-send-email-vyasevic@redhat.com> <1398271901-32534-2-git-send-email-vyasevic@redhat.com> <20140423192022.GA28446@redhat.com> <53581700.9010205@redhat.com> <20140423201050.GC28446@redhat.com> <535822DE.5020704@redhat.com> <20140424072611.GA31483@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel.lezcano@free.fr,
	nightnord@gmail.com, kaber@trash.net, eric.dumazet@gmail.com,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787AbaDXOFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 10:05:30 -0400
In-Reply-To: <20140424072611.GA31483@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 03:26 AM, Michael S. Tsirkin wrote:
> On Wed, Apr 23, 2014 at 04:30:22PM -0400, Vlad Yasevich wrote:
>> On 04/23/2014 04:10 PM, Michael S. Tsirkin wrote:
>>> On Wed, Apr 23, 2014 at 03:39:44PM -0400, Vlad Yasevich wrote:
>>>> On 04/23/2014 03:20 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Apr 23, 2014 at 12:51:40PM -0400, Vlad Yasevich wrote:
>>>>>> The following is a problematic configuration:
>>>>>>
>>>>>>  VM1: virtio-net device connected to macvtap0@eth0
>>>>>>  VM2: e1000 device connect to macvtap1@eth0
>>>>>>
>>>>>> The problem is is that virtio-net supports checksum offloading
>>>>>> and thus sends the packets to the host with CHECKSUM_PARTIAL set.
>>>>>> On the other hand, e1000 does not support any acceleration.
>>>>>>
>>>>>> For small TCP packets (and this includes the 3-way handshake),
>>>>>> e1000 ends up receiving packets that only have a partial checksum
>>>>>> set.  This causes TCP to fail checksum validation and to drop
>>>>>> packets.  As a result tcp connections can not be established.
>>>>>>
>>>>>> Commit 3e4f8b787370978733ca6cae452720a4f0c296b8
>>>>>> 	macvtap: Perform GSO on forwarding path.
>>>>>> fixes this issue for large packets wthat will end up undergoing GSO.
>>>>>> This commit adds a check for the non-GSO case and attempts to
>>>>>> compute the checksum for partially checksummed packets in the
>>>>>> non-GSO case.
>>>>>>
>>>>>> CC: Daniel Lezcano <daniel.lezcano@free.fr>
>>>>>> CC: Patrick McHardy <kaber@trash.net>
>>>>>> CC: Andrian Nord <nightnord@gmail.com>
>>>>>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>>>>>> CC: Michael S. Tsirkin <mst@redhat.com>
>>>>>> CC: Jason Wang <jasowang@redhat.com>
>>>>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>>>>> ---
>>>>>>  drivers/net/macvtap.c | 7 +++++++
>>>>>>  1 file changed, 7 insertions(+)
>>>>>>
>>>>>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>>>> index ff111a8..ba91084 100644
>>>>>> --- a/drivers/net/macvtap.c
>>>>>> +++ b/drivers/net/macvtap.c
>>>>>> @@ -322,6 +322,13 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
>>>>>>  			segs = nskb;
>>>>>>  		}
>>>>>>  	} else {
>>>>>> +		/* If we receive a partial checksum and the tap side
>>>>>> +		 * doesn't support checksum offload, compute the checksum.
>>>>>> +		 */
>>>>>> +		if (skb->ip_summed == CHECKSUM_PARTIAL &&
>>>>>> +		    !(features & NETIF_F_ALL_CSUM) &&
>>>>>> +		    skb_checksum_help(skb))
>>>>>> +			goto drop;
>>>>>
>>>>> Hmm confused by NETIF_F_ALL_CSUM here.
>>>>>
>>>>> features come from here:
>>>>>                 feature_mask = NETIF_F_HW_CSUM;
>>>>>
>>>>>                 if (arg & (TUN_F_TSO4 | TUN_F_TSO6)) {
>>>>>                         if (arg & TUN_F_TSO_ECN)
>>>>>                                 feature_mask |= NETIF_F_TSO_ECN;
>>>>>                         if (arg & TUN_F_TSO4)
>>>>>                                 feature_mask |= NETIF_F_TSO;
>>>>>                         if (arg & TUN_F_TSO6)
>>>>>                                 feature_mask |= NETIF_F_TSO6;
>>>>>                 }
>>>>>
>>>>>                 if (arg & TUN_F_UFO)
>>>>>                         feature_mask |= NETIF_F_UFO;
>>>>>
>>>>>
>>>>> okay so why not just check that NETIF_F_HW_CSUM is set?
>>>>
>>>> We can do that, but it doesn't make much difference.
>>>
>>> Seems cleaner to test a single bit otherwise one is left
>>> wondering what happens if only one bit matches.
>>
>> I can certainly do a single test, but if we ever change it,
>> this will be another palace that would have to change.
> 
> Hmm change what exactly? Add support for selectively
> disabling checksum for specific protocols?

Yes.  Right now, we kind-of lump them all together, but there
are some protocols that are not accounted for in HW_CSUM.

For instance, I am looking to add SCTP checksum offload.  It
would be very useful if the host has SCTP-capable nic.

> 
>> The above is also what dev_start_hard_xmit() does.
> 
> Yes and I was wondering about that too, but check it out: that one
> calls: netif_skb_dev_features which in turn calls harmonize_features.
> And there we have:
>         if (skb->ip_summed != CHECKSUM_NONE &&
>             !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
>                 features &= ~NETIF_F_ALL_CSUM;
>         } else if (illegal_highdma(dev, skb)) {
>                 features &= ~NETIF_F_SG;
>         }       
> 
> So NETIF_F_HW_CSUM is tested because it's cleared by a per-protocol
> handling here which is not there in your patch.
> 
> Your patch is still correct - the reason harmonize_features is not
> necessary is because tap either sets HW_CSUM or nothing,
> can_checksum_protocol is always true or always false. But since we rely
> on this anyway, isn't it better to make this explicit?
> 
> Alternatively let's clarify the comment here:
> 
>>>>>> +		/* If we receive a partial checksum and the tap side
>>>>>> +		 * doesn't support checksum offload, compute the checksum.
> 
> Add:
> 
>        +                 * Note: it doesn't matter which checksum feature to
>        +                 * check, we either support them all or none.
> 
>>>>>> +		 */
> 
> Fine?

Looks good to me.  I'll update and re-submit.

Thanks
-vlad

> 
>>>
>>>>>
>>>>> Also does it matter whether specific offloads are enabled?
>>>>>
>>>>
>>>> No it doesn't matter at all.  The packet is not a GSO packet
>>>> so no other acceleration is used.
>>>
>>> Hmm how do we know it's not a gso packet?
>>> All I see is need_gso test which means it needs segmentation.
>>
>> Part of netif_needs_gso() is a test for skb_is_gso().  So it
>> it's gso and doesn't need segmentation (meaning the guest can
>> receive large packets), then partial checksum is OK.
> 
> That is correct- thanks for the clarification.
> 
> 
>>>
>>>
>>>> Also, other offloads are dependent on checksum.
>>>>
>>>> -vlad
>>>
>>> Right so what if checksum is on, but segmentation is off?
>>> Not the case with e1000 today but can be with other userspace.
>>>
>>
>> In this case, the skb will be in need to segmentation and will take
>> a different branch.
>>
>> -vlad
>>>
>>>>>
>>>>>>  		skb_queue_tail(&q->sk.sk_receive_queue, skb);
>>>>>>  	}
>>>>>>  
>>>>>> -- 
>>>>>> 1.9.0
