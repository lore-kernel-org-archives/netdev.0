From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Mon, 16 Jun 2008 12:03:43 +0200
Message-ID: <48563A7F.50309@trash.net>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbYFPKDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 06:03:49 -0400
In-Reply-To: <485634D1.2010603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-6-16 17:27:
>> Wang Chen wrote:
>>> -    if (dev->flags & IFF_ALLMULTI)
>>> -        dev_set_allmulti(real_dev, 1);
>>> +    /* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
>>> +       is important. Some (broken) drivers set IFF_PROMISC, when
>>> +       IFF_ALLMULTI is requested not asking us and not reporting.
>>> +     */
>>>      if (dev->flags & IFF_PROMISC)
>>>          dev_set_promiscuity(real_dev, 1);
>>> +    if (dev->flags & IFF_ALLMULTI)
>>> +        dev_set_allmulti(real_dev, 1);
>>
>> What exactly is the problem here? The VLAN code is obviously not
>> one of the broken drivers, so why should it care what other drivers
>> do?
>>
> 
> I think the problem is that allmulti is not valid if promis is not on.

No, PROMISC is a superset of ALLMULTI.

> And about the comment, I copy it from dev_change_flags() and think
> it seems suit for here.
> Did I misunderstand this comment?

I think it refers to broken behaviour by drivers that set
IFF_PROMISC themselves when asked to disable multicast
filtering by setting IFF_ALLMULTI. This would cause the
test for changed flags in dev_set_promiscuity to return zero
and not program the device for promiscous mode properly.

There are a few examples of this in the tree. But calling
dev_set_promiscuity() before dev_set_allmulti() only helps
in the dev_change_flags() case since its the only function
that might change both flags at once. In all other cases it
depends on the caller.

So for the dev_change_flags() case VLAN already uses the
"proper" ordering, the other cases might be broken with
or without your patch.

I'd suggest to fix the drivers instead, perhaps start by
adding a warning to dev_change_flags() that is triggered
by the driver changing the flags itself.
