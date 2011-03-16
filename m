From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH][v3] dev : fix mtu check when TSO is enabled
Date: Wed, 16 Mar 2011 14:56:09 +0100
Message-ID: <4D80C179.8000900@free.fr>
References: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr>	<20110314.165929.232913682.davem@davemloft.net>	<4D7F7054.70409@free.fr> <20110315111756.64b5f4b1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kaber@trash.net, nightnord@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:51681 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1CPN4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 09:56:19 -0400
In-Reply-To: <20110315111756.64b5f4b1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/2011 07:17 PM, Stephen Hemminger wrote:
> On Tue, 15 Mar 2011 14:57:40 +0100
> Daniel Lezcano<daniel.lezcano@free.fr>  wrote:
>
>> On 03/15/2011 12:59 AM, David Miller wrote:
>>> From: Daniel Lezcano<daniel.lezcano@free.fr>
>>> Date: Mon, 14 Mar 2011 21:39:50 +0100
>>>
>>>> +	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
>>>> +	if (skb->len<   len)
>>>> +		return true;
>>> This is not a correct translation of the original test:
>>>
>>>> -		     (skb->len>   (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {
>>> You need to use "<=" in your version, which currently rejects all
>>> full sized frames. :-)
>> Right, thanks.
>>
>>>> +
>>>> +	/* if TSO is enabled, we don't care about the length as the packet
>>>> +	 * could be forwarded without being segmented before
>>>> +	 */
>>>> +	if (skb->dev&&   skb->dev->features&   NETIF_F_TSO)
>>>> +		return true;
>>> I am trying to understand why you aren't simply checking also if this
>>> is a segmented frame?  Perhaps skb_is_gso()&&   device has NETIF_F_TSO
>>> set?
>> Maybe I am misunderstanding but the packet was forwarded by another device.
>> In our case from macvlan:
>>
>> macvlan_start_xmit
>>       macvlan_queue_xmit
>>           dest->forward
>>               dev_skb_forward
>>
>> When we reached dev_skb_forward, that means we passed through
>> dev_hard_start_xmit where the packet was already segmented so we should
>> exit at the first test (skb->len<  len). I don't see the point of adding
>> the skb_is_gso.
>> But maybe I am missing something, can you explain ?
> The macvlan device only has one downstream device (slave).
> If kernel is working properly, macvlan device should have a subset
> of the features of the underlying device

Right, dev->features = lowerdev->features & MACVLAN_FEATURES

> and macvlan device should
> have same MTU as underlying device.

Right,

...

  if (!tb[IFLA_MTU])
         dev->mtu = lowerdev->mtu;

...
> If the feature/MTU flags
> were correct, then the path calling macvlan should be respecting
> the MTU.

But if the TSO is enabled on the macvlan (inherited from eg e1000), the 
packet won't be fragmented to the mtu size no ?




