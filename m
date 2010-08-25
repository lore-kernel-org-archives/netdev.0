From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 12:49:37 -0700
Message-ID: <4C7573D1.9070400@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <1282762851-3612-2-git-send-email-greearb@candelatech.com> <201008252124.09917.arnd@arndb.de> <4C756EAF.9090704@candelatech.com> <20100825193800.GA9118@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34144 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab0HYTtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:49:46 -0400
In-Reply-To: <20100825193800.GA9118@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2010 12:38 PM, Hagen Paul Pfeifer wrote:
> * Ben Greear | 2010-08-25 12:27:43 [-0700]:
>
>>> I suppose we need to do something in macvtap to handle this as
>>> well, right? A guest trying to send a frame through qemu
>>> or vhost net into macvtap needs to be prevented from sending
>>> more when we get into this path. Right now, we just ignore
>>> the return value of macvlan_start_xmit.
>>
>> I have a similar, though slightly more complex, patch for 802.1q
>> vlans, but I haven't looked at macvtap at all.
>>
>> If these two patches are accepted, I'll post the .1q patch as well.
>
> I do not completely understand the benefit for macvlan. I think this BUSY logic
> shifts functionality and make upper level code more complicated (e.g. handle
> NET_XMIT_SUCCESS and skb bookkeeping). At the end it boils down to two
> scenarios:

Code that is calling hard_start_xmit already has to know how to deal
with the NETDEV_TX_BUSY return code, this just allows mac-vlans to return that
code instead of always dropping in overload scenarios.

This *should* allow backpressure up to user-space socket buffers to fill up
and provide indication that they should slow down transmitting (and
perhaps sleep a bit) instead of continually doing work to send packets
that are being dropped.

> a) the congestion is temporary
> b) the congestion is for a longer period
>
> For a), a increased link queue length can bridge a longer period too. There is
> no need to shift the logic in the upper layer. For b): at the end the upper
> layer must also drop skb's - there is no alternative. Or require qemu other,
> special handling? (e.g. sleep until the queue is free again).

For b, the thing generating packets can back off.  I'm not 100% sure the
back-pressure logic goes all the way up the stack properly, but there
is no fundamental reason it couldn't, and this macvlan patch just
makes it work a small bit better.

If something was trying to take a pkt out of a queue for xmit,
and it got the NETDEV_TX_BUSY when it tried to send, it could simply
poke that skb back into the queue and return EBUSY or whatever to
the calling code.

> For case a) the shift in the upper layers _can_ be superior because it can
> dynamically increase the skb buffer, whatever. But why not implementing a more
> clever, dynamic fifo. E.g. pfifo_dynamic (not really serious)? Is this
> functionality qemu centric or are there any other use cases?

I don't use it with qemu.  I primarily wrote this to make pktgen able to
back off when sending pkts on mac-vlans.  High-speed user-space senders
should also benefit.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

