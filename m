From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track skb->dev
Date: Sat, 12 Jan 2013 21:14:25 +0100
Message-ID: <50F1C421.7080501@hartkopp.net>
References: <50F1699E.1000200@hartkopp.net> <20130112181307.GA1567@minipsycho.orion> <50F1AE21.90701@hartkopp.net> <20130112193728.GB1567@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:60030 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab3ALUO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 15:14:28 -0500
In-Reply-To: <20130112193728.GB1567@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2013 20:37, Jiri Pirko wrote:

> Sat, Jan 12, 2013 at 07:40:33PM CET, socketcan@hartkopp.net wrote:


>> An there i wanted to add this code to omit sending the CAN frame on the
>> originating interface:
>>
>> @@ .. @@ static void can_can_gw_rcv(struct sk_buff *skb, void *data
>>
>>        if (!(gwj->dst.dev->flags & IFF_UP)) {
>>                gwj->dropped_frames++;
>>                return;
>>        }
>>
>> +       /* is sending the skb back to the incoming interface allowed? */
>> +       if (!(gwj->flags & CGW_FLAGS_CAN_IIF_TX_OK) &&
>> +           skb->skb_iif == gwj->dst.dev->ifindex)
>> +               return;
>> +
>>        /*
>>         * clone the given skb, which has not been done in can_rcv()
>>         *
>>
>> This works fine, when the patch from Dave is reverted.
>>
>> I did not find any good solution to preserve the originating netdev over
>> several netif_receive_skb() calls - but this skb_iif which has been made
>> unusable ...
> 
> 
> 
> Well, look at struct receiver in net/can/af_can.h:
> 
> struct receiver {
>         struct hlist_node list;
>         struct rcu_head rcu;
>         canid_t can_id;
>         canid_t mask;
>         unsigned long matches;
>         void (*func)(struct sk_buff *, void *);
>         void *data;
>         char *ident;
> };
> 
> your can_can_gw_rcv() is callback registered as ->func here.
> This ->func is called from chain can_rcv->can_receive->can_rcv_filter->deliver
> 
> So just extend
> ->func to something like:
> 
>         void (*func)(struct sk_buff *, struct neti_device *orig_dev, void *);
> and pass the orig_dev all the way through the chain.
> 


Passing the information up to the can-gw once is not the problem.

But when this skb has to be routed to another CAN netdev it is cloned and goes
down from can_can_gw_rcv() to
-> can_send(cloned_skb) -> dev_queue_xmit(cloned_skb)

And when it has been sent successfully on the CAN bus the cloned_skb is echoed
back into the system via netif_rx_ni(cloned_skb).
(see http://lxr.linux.no/#linux+v3.7.2/Documentation/networking/can.txt#L177 )

This entire path - using dev_queue_xmit() / netif_rx_ni() - is reduced to a
skb structure and can not deal with any orig_dev pointer.

Therefore storing the first incoming interface in skb_iif is relevant for this
use-case.

Regards,
Oliver
