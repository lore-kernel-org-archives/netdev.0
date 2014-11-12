From: Ulf samuelsson <netdev@emagii.com>
Subject: Re: How to make stack send broadcast ARP request when entry is STALE?
Date: Wed, 12 Nov 2014 09:46:50 +0100
Message-ID: <DDC2A17E-E6C7-4F78-B93D-77D199F411AE@emagii.com>
References: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com> <545C96D6.5020204@hp.com> <3A67CF46-0BC1-4BAA-818A-0B656C6B46B6@emagii.com> <54614198.7010306@hp.com> <C8A75CC5-18FA-4D2D-9259-74254D808107@emagii.com> <54623AF6.9020403@hp.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out12.han.skanova.net ([195.67.226.212]:45700 "EHLO
	smtp-out12.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751102AbaKLIq5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 03:46:57 -0500
In-Reply-To: <54623AF6.9020403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 11 nov 2014 kl. 17:36 skrev Brian Haley <brian.haley@hp.com>:
> 
>> On 11/11/2014 05:08 AM, Ulf samuelsson wrote:
>> If I set ucast_solicit to '0', then I always send broadcast, which is not desirable.
> 
> That seems to contradict your statement:
> 
> "The HP router is configured by a customer, and they intentionally limit replies
> to broadcast, and that is how they want it."
> 

The equipment is beeing used in multiple locations, and this is but one.
Normally you want to follow IPv6 rules which says

* Start w broadcast
* Once reply arrives, start using unicast
* If unicast fails for 'ucast_probes', send up to 'mcast_probes' packets before FAIL.
* A reply to a broadcast packet will make the kernel revert to unicast


> So I'm not understanding your question.
> 
> The best way forward would be for you to send a patch out that gets your desired
> behaviour, and let others give feedback on it.
> 
> -Brian



Best Regards
Ulf Samuelsson



> 
>> In the PROBE state of the ARP state machine, "probes" count from 0 .. ucast_probes.
>> 
>> I can see the following arguments for letting "probes" count from 
>> 
>>   0.. (ucast_probes + app_probes + mcast_probes)
>> 
>> 
>> A: This is how the IPv6 is doing it. 
>>     It is not standardized in IPv4, but why should the IPv4 have a different behaviour?
>> 
>> B: If you do not send out broadcast if unicast fails, then a broadcast will be sent out 
>>     anyway, once the ARP entry is removed by the garbage collector.
>>     You get an annoyingly long delay before that happens.
>> 
>> C: If a large data centre does not want broadcasts to be sent out, 
>>     then they can set mcast_probes to 0, in which case no broadcasts will be sent
>>     out in PROBE state.
>> 
>> D:  When in other states, the counter runs until it a reply is had, or the counter wraps around.
>>      It is sending broadcast all the time.
>> 
>> 
>> Best Regards
>> Ulf Samuelsson
>> ulf@emagii.com
>> +46  (722) 427 437
>> 
>> 
>>>> 10 nov 2014 kl. 23:52 skrev Brian Haley <brian.haley@hp.com>:
>>>> 
>>>> On 11/07/2014 05:11 AM, Ulf samuelsson wrote:
>>>> The HP router is configured by a customer, and they intentionally limit replies
>>>> to broadcast, and that is how they want it.
>>> 
>>> So this is the crux of the problem - the customer has configured the router so
>>> that it doesn't play well with most modern network stacks that try and use
>>> unicast so they don't send unnecessary broadcast packets.  I don't know why I
>>> thought this was something wrong with the router software.
>>> 
>>> Did you try this?
>>> 
>>> $ sudo sysctl net.ipv4.neigh.eth0.ucast_solicit=0
>>> 
>>> It works for me.
>>> 
>>> And they really should re-think their decision on that configuration setting.
>>> 
>>> -Brian
>>> 
>>> 
>>>> In the previous version of the build system, the Interpeak stack was used
>>>> and this would in PROBE state send unicast ARP request, and if that failed
>>>> send broadcast ARP.
>>>> 
>>>> The native linux stack, when in PROBE state sends only unicast until it decides
>>>> that it should enter FAILED state.
>>>> 
>>>> The 'mcast_probes' variable seems to be totally ignored, except the first  time,
>>>> so I do not see why it is there.
>>>> 
>>>> Best Regards
>>>> Ulf Samuelsson
>>>> ulf@emagii.com
>>>> +46  (722) 427 437
>>>> 
>>>> 
>>>>>> 7 nov 2014 kl. 10:54 skrev Brian Haley <brian.haley@hp.com>:
>>>>>> 
>>>>>> On 11/05/2014 07:48 AM, Ulf samuelsson wrote:
>>>>>> Have a problem with an HP router at a certain location, which
>>>>>> is configured to only answer to broadcast ARP requests.
>>>>>> That cannot be changed.
>>>>> 
>>>>> Sorry to hear about the problem, but my only suggestions would be to try the latest firmware and/or put a call in to support.  I don't happen work in the division that makes routers...
>>>>> 
>>>>>> The first ARP request the kernel sends out, is a broadcast request,
>>>>>> which is fine, but after the reply, the kernel sends unicast requests,
>>>>>> which will not get any replies.
>>>>> 
>>>>> You might be able to hack this by inserting an ebtables rule - check the dnat target section of the man page - don't know the exact syntax but it would probably end in '-j dnat --to-destination ff:ff:ff:ff:ff:ff'
>>>>> 
>>>>> -Brian
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
