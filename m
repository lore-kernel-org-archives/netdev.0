From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track skb->dev
Date: Sat, 12 Jan 2013 19:40:33 +0100
Message-ID: <50F1AE21.90701@hartkopp.net>
References: <50F1699E.1000200@hartkopp.net> <20130112181307.GA1567@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:22353 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3ALSkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 13:40:36 -0500
In-Reply-To: <20130112181307.GA1567@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jiri,

On 12.01.2013 19:13, Jiri Pirko wrote:

> Sat, Jan 12, 2013 at 02:48:14PM CET, socketcan@hartkopp.net wrote:
>> Hello Dave,
>>
>> in your below patch from 23 Jul 2012 you removed the check for an already set
>> value of skb_iif in net/core/dev.c
>>
>> I'm currently working on a solution to prevent some routed CAN frames to be
>> sent back onto the originating network device.
> 
> Hm, I'm not sure where exactly you want to use this information, but
> can_rcv() can get it from orig_dev->ifindex


No - it's not in can_rcv() ...

Depending on the filter lists in can_rcv() the received skb is passed to the
function can_can_gw_rcv() in net/can/gw.c.

An there i wanted to add this code to omit sending the CAN frame on the
originating interface:

@@ .. @@ static void can_can_gw_rcv(struct sk_buff *skb, void *data

        if (!(gwj->dst.dev->flags & IFF_UP)) {
                gwj->dropped_frames++;
                return;
        }

+       /* is sending the skb back to the incoming interface allowed? */
+       if (!(gwj->flags & CGW_FLAGS_CAN_IIF_TX_OK) &&
+           skb->skb_iif == gwj->dst.dev->ifindex)
+               return;
+
        /*
         * clone the given skb, which has not been done in can_rcv()
         *

This works fine, when the patch from Dave is reverted.

I did not find any good solution to preserve the originating netdev over
several netif_receive_skb() calls - but this skb_iif which has been made
unusable ...

(..)

>>
>> To me it is not clear why skb_iff is needed anyway as the value should
>> always be available via skb->dev->ifindex, right?
>>
>> But if skb_iff has any right to exist it should contain the first incoming
>> interface on the host IMO.
>>
>> Please correct my if i'm wrong and/or tell me what your commit message means
>> in respect to my request and why skb->dev->ifindex is not used instead of
>> skb_iif. I feel somehow lost about the skb_iif intention ...
> 
> I believe that skb_iif should be removed.


AFAICS skb->skb_iif is used as some kind of cached variable for the original
skb->dev->ifindex - or is it really possible that skb->skb_iif is set while
skb->dev->ifindex is not accessible?

Btw. i my case skb_iif would make sense though.

Regards,
Oliver

>>
>> ---
>>
>>
>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=b68581778cd0051a3fb9a2b614dee7eccb5127ff
>>
>> net: Make skb->skb_iif always track skb->dev
>>
>> Make it follow device decapsulation, from things such as VLAN and
>> bonding.
>>
>> The stuff that actually cares about pre-demuxed device pointers, is
>> handled by the "orig_dev" variable in __netif_receive_skb().  And
>> the only consumer of that is the po->origdev feature of AF_PACKET
>> sockets.
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index cca02ae..0ebaea1 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3173,8 +3173,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
>> 	if (netpoll_receive_skb(skb))
>> 		return NET_RX_DROP;
>>
>> -	if (!skb->skb_iif)
>> -		skb->skb_iif = skb->dev->ifindex;
>> 	orig_dev = skb->dev;
>>
>> 	skb_reset_network_header(skb);
>> @@ -3186,6 +3184,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
>> 	rcu_read_lock();
>>
>> another_round:
>> +	skb->skb_iif = skb->dev->ifindex;
>>
>> 	__this_cpu_inc(softnet_data.processed);
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
