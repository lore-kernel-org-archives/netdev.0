From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Tue, 08 Mar 2011 15:41:52 +0100
Message-ID: <4D764030.8020202@trash.net>
References: <20110221150710.GA5651@nord.niifaq.ru>	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>	 <4D6A6A5F.4030707@free.fr> <1298836236.8726.109.camel@edumazet-laptop>	 <4D6AB578.3010704@free.fr> <1298879114.8726.131.camel@edumazet-laptop> <4D6CF4A8.6000205@free.fr> <4D6D2402.6020705@trash.net> <4D6D515A.8060707@free.fr> <4D6E23F3.4010402@trash.net> <4D6E6A55.6000607@free.fr> <4D6E8686.3000109@trash.net> <4D6E8D80.3090907@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59804 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab1CHOly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 09:41:54 -0500
In-Reply-To: <4D6E8D80.3090907@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.03.2011 19:33, schrieb Daniel Lezcano:
> On 03/02/2011 07:03 PM, Patrick McHardy wrote:
>> Am 02.03.2011 17:03, schrieb Daniel Lezcano:
>>> On 03/02/2011 12:03 PM, Patrick McHardy wrote:
>>>> Am 01.03.2011 21:04, schrieb Daniel Lezcano:
>>>>> On 03/01/2011 05:51 PM, Patrick McHardy wrote:
>>>>>>> Patrick, do you have any suggestions to fix this ?
>>>>>> Since the frames are only looped back locally, I suppose the easiest
>>>>>> fix would be to mark them with CHECKSUM_UNNECESSARY. Alternatively
>>>>>> we need to complete the checksum manually, similar to what
>>>>>> dev_hard_start_xmit() does.
>>>>> That sounds very simple to fix, maybe too much simple :)
>>>>>
>>>>> I did the following change:
>>>>>
>>>>> --- linux-next.orig/drivers/net/macvlan.c
>>>>> +++ linux-next/drivers/net/macvlan.c
>>>>> @@ -222,6 +222,7 @@ static int macvlan_queue_xmit(struct sk_
>>>>>
>>>>>           if (vlan->mode == MACVLAN_MODE_BRIDGE) {
>>>>>                   const struct ethhdr *eth = (void *)skb->data;
>>>>> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
>>>>>
>>>>>                   /* send to other bridge ports directly */
>>>>>                   if (is_multicast_ether_addr(eth->h_dest)) {
>>>>>
>>>>>
>>>>> and that fixed the problem. Do you think it is acceptable ?
>>>> The only problem I see is if the packets are bridged to a
>>>> different networking device (or redirected using the mirred
>>>> action), in this case the checksum will not be completed.
>>>> This would be a very strange setup though and probably wouldn't
>>>> be using dummy as lower device, so I'm not sure we have to
>>>> worry about this case.
>>> I am not sure to get it, do you say the patch is correct ?
>> Its correct with a short-coming that doesn't seem to matter.
>>
>>> If my understanding is correct, the packet will be flagged
>>> CHECKSUM_UNNECESSARY only for the macvlan devices, right ?
>> Only for packets bridged between macvlan devices. A setup like
>> the following would cause problems:
>>
>>                          br0
>>                           |
>>                     .----------.
>>                     |          |
>> macvlan0    macvlan1    eth0
>>     |               |
>>      -------.-------
>>      dummy0
>>
>> In this case packets sent from macvlan0 will show up on
>> eth0 with incorrect setups. However this setup doesn't
>> seem realistic to me, you would simply use eth0 instead
>> of dummy0.
> 
> Ok, I understand. thanks for the clarification.
> 
>>> By the way, this problem occurs for any lower device with offloading
>>> capabilities with a macvlan port in bridge mode.
>> True. This doesn't affect outgoing packets since their checksum
>> will be completed in dev_hard_start_xmit(), but it affects
>> packets bridged between macvlans.
> 
> One last question. In the case of broadcast packets with maclvan in
> bridge mode.
> We will have the packets going through each macvlan port and also to the
> lower-device, right ?
> For the latter, don't we have a problem if the packet is flagged
> CHECKSUM_UNNECESSARY ?
> 
> Shouldn't we restore the ip_summed field before sending through
> dev_queue_xmit ?

Yes, that seems correct in order to have dev_hard_start_xmit() complete
the checksum if necessary.
