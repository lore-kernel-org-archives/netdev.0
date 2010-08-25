From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC] netns: introduce NETREG_NETNS_MOVING reg_state
Date: Wed, 25 Aug 2010 10:39:01 -0700
Message-ID: <m139u2fv7u.fsf@fess.ebiederm.org>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
	<4C73FAB8.1090402@free.fr> <m1tymjg6w8.fsf@fess.ebiederm.org>
	<20100825115213.GB235835@jupiter.n2.diac24.net>
	<4C751484.8030004@free.fr>
	<20100825135254.GC235835@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33272 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab0HYRjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 13:39:09 -0400
In-Reply-To: <20100825135254.GC235835@jupiter.n2.diac24.net> (David
	Lamparter's message of "Wed, 25 Aug 2010 15:52:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter <equinox@diac24.net> writes:

> On Wed, Aug 25, 2010 at 03:03:00PM +0200, Daniel Lezcano wrote:
>> > Please note that i'm quite unsure about the correctness of this
>> > patch due to me not having much experience in this kind of
>> > modification...
>> >
>> > In particular, the following might get broken by the new reg_state:
>> > drivers/net/ixgbe/ixgbe_main.c (hot-unplug)
>> > drivers/net/wimax/i2400m/driver.c (device reset)
>> >    
>> 
>> IMHO, that should be ok. NETREG_NETNS_MOVING is a transient state where 
>> the network device is not registered and not in the netdev list.
>> 
>> I think you should take care of this kind of comparison:
>> 
>> net/core/net-sysfs.c
>> 
>> static inline int dev_isalive(const struct net_device *dev)
>> {
>>          return dev->reg_state <= NETREG_REGISTERED;
>> }
>> 
>> Not sure having NETREG_NETNS_MOVING < NETREG_REGISTERED is right.
>
> I can't say I fully understand the code and all of its implications, but
> I think all of the attributes sysfs provides access to can theoretically
> be safely accessed while the device is moving.
>
>> > What could be done, alternatively, is split the notification:
>> >   * NETDEV_UNREGISTER - now changed to mean "logical unregister"
>> >   * NETDEV_UNREGISTER_PHYSICAL - _not_ sent by netns move, means
>> >      "the device is going for good"
>> >    
>> 
>> Maybe I miss something but that will have a big impact to all the 
>> network stacks no ?
>
> No; since NETDEV_UNREGISTER is still sent in all places where it is
> currently sent, none of the stacks would require changing. However,
> users of the actual, physical device (independent of its network
> namespace) would need changing to NETDEV_UNREGISTER_PHYSICAL, which is a
> new notification that is only sent if the device really disappears.
>
> TBH, I'm not quite sure which is the better solution here;
> NETDEV_UNREGISTER_PHYSICAL or NETREG_NETNS_MOVING...
> ... or the initial one?

Before we get too far down any of these paths, what is it that caused
you to notice that moving the physical device broke the connection to
the vlan and macvlan devices?

I just want to understand this case a little better before we walk down
any of these paths.

Eric
