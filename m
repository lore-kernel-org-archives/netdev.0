From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Tue, 17 Jun 2008 22:52:04 -0400
Message-ID: <48587854.8050400@pobox.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38702 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755785AbYFRCwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 22:52:22 -0400
In-Reply-To: <48587295.40705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-6-17 21:06:
>> Wang Chen wrote:
>>> Patrick McHardy said the following on 2008-6-16 18:03:
>>>> Wang Chen wrote:
>>>>> And about the comment, I copy it from dev_change_flags() and think
>>>>> it seems suit for here.
>>>>> Did I misunderstand this comment?
>>>> I think it refers to broken behaviour by drivers that set
>>>> IFF_PROMISC themselves when asked to disable multicast
>>>> filtering by setting IFF_ALLMULTI. This would cause the
>>>> test for changed flags in dev_set_promiscuity to return zero
>>>> and not program the device for promiscous mode properly.
>>>>
>>> Do you mean things like that in do_mc32_set_multicast_list()?
>> Yes.
>>
>>>> There are a few examples of this in the tree. But calling
>>>> dev_set_promiscuity() before dev_set_allmulti() only helps
>>>> in the dev_change_flags() case since its the only function
>>>> that might change both flags at once. In all other cases it
>>>> depends on the caller.
>>>>
>>>> So for the dev_change_flags() case VLAN already uses the
>>>> "proper" ordering, the other cases might be broken with
>>>> or without your patch.
>>>>
>>> Is there any other case might be broken?
>> If that ordering is really required, yes:
>>
>> - ip link set dev eth0 allmulticast on
>>
>> <sets allmulticast *and* promisous with broken driver>
>>
>> - ip link set dev eth0 promisc on
>>
>> <no change>
>>
>> So the only thing fixed by this workaround is of both are
>> enabled in a single command - something that doesn't even
>> make much sense since promisc will receive all multicast
>> frames anyway.
>>
>>>> I'd suggest to fix the drivers instead, perhaps start by
>>>> adding a warning to dev_change_flags() that is triggered
>>>> by the driver changing the flags itself.
>>>>
>>> In some driver's code of *_set_multicast_list(), IFF_PROMISC
>>> will be set if IFF_ALLMULTI is set.
>>> And there is comment about the necessity for setting IFF_PROMISC.
>>> /*
>>>  *    We must make the kernel realise we had to move
>>>  *    into promisc mode or we start all out war on
>>>  *    the cable. If it was a promisc request the
>>>  *    flag is already set. If not we assert it.
>>>  */
>>> So, I doubt about fixing the drivers.
>>
>> I have no idea what this comment is trying to say. Drivers
>> shouldn't change dev->flags.
>>
> 
> Yes.
> Maybe we should ask the authors about why they let driver to
> change the dev->flags.
> Fox example, about 3c527.
> Alan,
> Can you explain why do_mc32_set_multicast_list() change flag
> to IFF_PROMISC when IFF_ALLMULTI is set?
> 
> Jeff,
> Any suggestion about this?
> netdevice uses promiscuity as refcnt, and if driver set IFF_PROMISC
> but don't change promiscuity will break the refcnt.

Drivers should not be setting IFF_* flags in set_multicast_list().

The normal logic is that a driver interprets the request implied in 
set_multicast_list ("promisc, all-multi, or select multi?"), and then 
programs the hardware based on that.

On some hardware, IFF_ALLMULTI requires that the hardware receive all 
packets (promisc).  Even for that case, the driver should -not- be 
setting the IFF_PROMISC flag.  It should be aware of its own hardware 
programming state through some other method.

	Jeff




