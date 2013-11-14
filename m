From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel
 > 3.10
Date: Thu, 14 Nov 2013 09:41:59 -0500
Message-ID: <5284E137.5010201@gmail.com>
References: <52838590.5070806@profihost.ag> <20131113141244.GM19702@redhat.com> <52838AC8.8070005@profihost.ag> <52839540.6020908@gmail.com> <5283980D.7020508@profihost.ag> <20131113162136.GP19702@redhat.com> <5283B500.9040408@gmail.com> <5283DC91.1010402@profihost.ag> <52843EEA.3020905@redhat.com> <20131114115451.GT19702@redhat.com> <5284DDCE.4090901@gmail.com> <5284DE65.40105@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Veaceslav Falico <vfalico@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:59899 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748Ab3KNOmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:42:03 -0500
Received: by mail-qe0-f51.google.com with SMTP id t7so1273328qeb.24
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:42:02 -0800 (PST)
In-Reply-To: <5284DE65.40105@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 09:29 AM, Stefan Priebe - Profihost AG wrote:
> Am 14.11.2013 15:27, schrieb Vlad Yasevich:
>> On 11/14/2013 06:54 AM, Veaceslav Falico wrote:
>>> On Wed, Nov 13, 2013 at 10:09:30PM -0500, Vlad Yasevich wrote:
>>>> Can you try out attached patch please.  I ran it in my environment and
>>>> always get promisc link when attaching devices to the bridge.
>>>
>>> It's interesting, actually, why do we need to check for IFF_UP at all
>>> when
>>> changing flags.
>>>
>>> The addition of IFF_UP goes up to:
>>>
>>> commit b6c40d68ff6498b7f63ddf97cf0aa818d748dee7
>>> Author: Patrick McHardy <kaber@trash.net>
>>> Date:   Tue Oct 7 15:26:48 2008 -0700
>>>
>>>       net: only invoke dev->change_rx_flags when device is UP
>>>
>>>       Jesper Dangaard Brouer <hawk@comx.dk> reported a bug when setting a
>>> VLAN
>>>       device down that is in promiscous mode:
>>>
>>>       When the VLAN device is set down, the promiscous count on the real
>>>       device is decremented by one by vlan_dev_stop(). When removing the
>>>       promiscous flag from the VLAN device afterwards, the promiscous
>>>       count on the real device is decremented a second time by the
>>>       vlan_change_rx_flags() callback.
>>>
>>> ... snip ...
>>>
>>
>> This was applied in 2.6.27 timeframe.
>>
>>> However, I'm not sure that this is still needed, cause:
>>>
>>> commit deede2fabe24e00bd7e246eb81cd5767dc6fcfc7
>>> Author: Matthijs Kooijman <matthijs@stdin.nl>
>>> Date:   Mon Oct 31 04:53:13 2011 +0000
>>>
>>>       vlan: Don't propagate flag changes on down interfaces.
>>>
>>>       When (de)configuring a vlan interface, the IFF_ALLMULTI ans
>>> IFF_PROMISC
>>>       flags are cleared or set on the underlying interface. So, if these
>>> flags
>>>       are changed on a vlan interface that is not up, the flags underlying
>>>       interface might be set or cleared twice.
>>>
>>>       Only propagating flag changes when a device is up makes sure this
>>> does
>>>       not happen. It also makes sure that an underlying device is not
>>> set to
>>>       promiscuous or allmulti mode for a vlan device that is down.
>>>
>>> ... snip ...
>>>
>>
>> And this in 3.2.  So how did this work for Stefan in 3.9?  Unless there
>> is something in Ubuntu that changed how the stacked interfaces are
>> configured and is keeping interfaces down longer then it used to.
>
> Stop here ;-) in 3.9 it was the other way round.
>
> This one worked:
>> eth2
>>       \
>>        -- bond1 -- vmbr1
>>       /              \
>> eth3                 \ vmbr1.3000
>>                             \ ---- tap114i1
>

How are you attaching tap to the vlan device?  Or is it attached to
vmbr1?

> this one did not:
>> eth2
>>       \
>>        -- bond1 -- vmbr1
>>       /     \
>> eth3        ----- bond1.3000 --- vmbr1v3000
>>                                       \ ---- tap114i1
>
> Now with the patch - the 2nd one works the first one does not.

Ok, in this case, you have a VLAN (bond1.3000) configured on top of
bond interface.  That vlan is then attached to the bridge (vmbr1v3000).
The tap interface for your VM (tap114i1) is also attached to the same
bridge.  In this case, VM will receive only traffic for VLAN 3000 and
it we receive it untagged.

I guess I'd like to understand what you are trying to achieve.

Thanks working with us on this.
-vlad

>
> Stefan
>
>>> which fixed completely the initial issue with vlans.
>>>
>>> Maybe we should just remove the IFF_UP check in dev_change_rx_flags(),
>>> and
>>> let the drivers using it handle its own logic, as vlan does?
>>>
>>
>> This should work, but this might regress a few drivers.  Looking through
>> the callers of dev_set_promiscuity at least DSA driver suffers
>> the same fate as VLAN.
>>
>> -vlad
>>
>>> Something like this:
>>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 8ffc52e..9615cd7 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -4995,7 +4995,7 @@ static void dev_change_rx_flags(struct net_device
>>> *dev, int flags)
>>>    {
>>>        const struct net_device_ops *ops = dev->netdev_ops;
>>>
>>> -    if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
>>> +    if (ops->ndo_change_rx_flags)
>>>            ops->ndo_change_rx_flags(dev, flags);
>>>    }
>>>
>>>
>>>>
>>>> Thanks
>>>> -vlad
>>
