From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] geneve: break dependency to network drivers
Date: Wed, 6 Jan 2016 21:25:17 +0100
Message-ID: <568D782D.4000602@stressinduktion.org>
References: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
 <1452094903-12934-3-git-send-email-hannes@stressinduktion.org>
 <CAEh+42j2w6t7+WNN9y0k6M5Ld+14B2txCkfLw6zwrR04+i8Xqw@mail.gmail.com>
 <568D6188.4090705@stressinduktion.org>
 <CAEh+42iA+ReWfxLHHXOx5cYCDhrFyRkFwvPqrMfbGj+UK-nxYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60564 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003AbcAFUZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:25:21 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id DB75821BE7
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 15:25:20 -0500 (EST)
In-Reply-To: <CAEh+42iA+ReWfxLHHXOx5cYCDhrFyRkFwvPqrMfbGj+UK-nxYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

hmpf, I saw your mail too late and send out another series just now.

On 06.01.2016 20:52, Jesse Gross wrote:
> On Wed, Jan 6, 2016 at 10:48 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 06.01.2016 19:00, Jesse Gross wrote:
>>>
>>> On Wed, Jan 6, 2016 at 7:41 AM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>>
>>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>>> index 24b077a32c1c9c..548925d1571cb1 100644
>>>> --- a/drivers/net/geneve.c
>>>> +++ b/drivers/net/geneve.c
>>>> +static int geneve_notifier(struct notifier_block *unused,
>>>> +                          unsigned long event, void *ptr)
>>>> +{
>>>> +       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>>>> +
>>>> +       switch (event) {
>>>> +       case NETDEV_REFRESH_OFFLOAD_VXLAN:
>>>> +               geneve_notify_refresh_netdev(dev);
>>>
>>>
>>> Presumably this should be NETDEV_REFRESH_OFFLOAD_GENEVE, not VXLAN.
>>> However, rather than having a notifier for each protocol, it seems
>>> like it might be cleaner to just have a single one that triggers for
>>> all protocols and drivers that don't have the corresponding NDO
>>> wouldn't get called, similar to what happens when the port gets added
>>> in the first place.
>>
>>
>> Ah, thanks for noticing the typo.
>>
>> The reason why I went with several types is that I didn't want to change the
>> behavior and wasn't sure if driver tested with reoccurring offload refreshes
>> to the driver. What you described was my first patch but because I couldn't
>> see if that works for all drivers I went this way.
>
> Hmm, I see what you mean but I think it should be safe. All drivers
> that have both Geneve and VXLAN offloads make calls to refresh them
> back to back, which is a pattern that I would expect to continue. In
> that case, having a single notifier that triggers multiple protocols
> would have the same effect and is simpler.

My new series adds a new netdev_notifier which is atomic and can deal 
with non locked rtnl events. I thought maybe it would be useful for 
future callbacks, too. I am currently looking into ptp and reduce the 
dependency there, if possible.

>>>> diff --git a/include/net/geneve.h b/include/net/geneve.h
>>>> index e6c23dc765f7ec..36245115143652 100644
>>>> --- a/include/net/geneve.h
>>>> +++ b/include/net/geneve.h
>>>
>>> [...]
>>>>
>>>>    static inline void geneve_get_rx_port(struct net_device *netdev)
>>>>    {
>>>> +       call_netdevice_notifiers(NETDEV_REFRESH_OFFLOAD_GENEVE, netdev);
>>>>    }
>>>
>>>
>>> Unfortunately, I don't think that we can assume that RTNL is held
>>> here. It actually is for the drivers that implement Geneve at this
>>> point but not in all cases for VXLAN. For example, ixgbe refreshes the
>>> offloads in a service task in addition to when it is opened. There's
>>> only a couple instances of things like this, so I guess it's probably
>>> not too hard to through and make sure that we hold RTNL in those
>>> cases.
>>
>>
>> Hmm, I am tempted to switch over to the netevent atomic notifier chain and
>> install those events there. It does not need rtnl lock at all, so we can
>> preserve the current semantics. What do you think?
>
> I think that holding RTNL while we do these updates is actually the
> right thing to do. The current situation of having calls from
> different protocols protected by different locks is not really a great
> model given that at the driver level these are usually shared data
> structures. RTNL is already held in the majority of cases already, so
> I think it is better to just convert the rest.

The refreshes from each module are completely synchronous and don't get 
interleaved, so as long as the driver is correctly handling the locking 
internally rtnl lock shouldn't be needed. But as I don't know too much 
about driver developing I can revisit this.

As a advantage I see that the driver developers don't need to worry 
about the rtnl lock at all when adding new events. Is this realistic?

Thanks,
Hannes
