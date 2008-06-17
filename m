From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Tue, 17 Jun 2008 09:42:57 +0800
Message-ID: <485716A1.8030401@cn.fujitsu.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51783 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbYFQBqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 21:46:45 -0400
In-Reply-To: <48563A7F.50309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-16 18:03:
> Wang Chen wrote:
>> Patrick McHardy said the following on 2008-6-16 17:27:
>>> Wang Chen wrote:
>>>> -    if (dev->flags & IFF_ALLMULTI)
>>>> -        dev_set_allmulti(real_dev, 1);
>>>> +    /* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
>>>> +       is important. Some (broken) drivers set IFF_PROMISC, when
>>>> +       IFF_ALLMULTI is requested not asking us and not reporting.
>>>> +     */
>>>>      if (dev->flags & IFF_PROMISC)
>>>>          dev_set_promiscuity(real_dev, 1);
>>>> +    if (dev->flags & IFF_ALLMULTI)
>>>> +        dev_set_allmulti(real_dev, 1);
>>>
>>> What exactly is the problem here? The VLAN code is obviously not
>>> one of the broken drivers, so why should it care what other drivers
>>> do?
>>>
>>
>> I think the problem is that allmulti is not valid if promis is not on.
> 
> No, PROMISC is a superset of ALLMULTI.
> 
>> And about the comment, I copy it from dev_change_flags() and think
>> it seems suit for here.
>> Did I misunderstand this comment?
> 
> I think it refers to broken behaviour by drivers that set
> IFF_PROMISC themselves when asked to disable multicast
> filtering by setting IFF_ALLMULTI. This would cause the
> test for changed flags in dev_set_promiscuity to return zero
> and not program the device for promiscous mode properly.
> 

Do you mean things like that in do_mc32_set_multicast_list()?

> There are a few examples of this in the tree. But calling
> dev_set_promiscuity() before dev_set_allmulti() only helps
> in the dev_change_flags() case since its the only function
> that might change both flags at once. In all other cases it
> depends on the caller.
> 
> So for the dev_change_flags() case VLAN already uses the
> "proper" ordering, the other cases might be broken with
> or without your patch.
> 

Is there any other case might be broken?

> I'd suggest to fix the drivers instead, perhaps start by
> adding a warning to dev_change_flags() that is triggered
> by the driver changing the flags itself.
> 

In some driver's code of *_set_multicast_list(), IFF_PROMISC
will be set if IFF_ALLMULTI is set.
And there is comment about the necessity for setting IFF_PROMISC.
/*
 *	We must make the kernel realise we had to move
 *	into promisc mode or we start all out war on
 *	the cable. If it was a promisc request the
 *	flag is already set. If not we assert it.
 */
So, I doubt about fixing the drivers.

