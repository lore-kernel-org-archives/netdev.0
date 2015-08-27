From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 10:41:03 +0200
Message-ID: <20150827084103.GO2228@nanopsycho.orion>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <20150827072722.GJ2228@nanopsycho.orion>
 <CAE4R7bALm24BpczxWjB8V0gUKL+jeE8v4kkDVcegHxm8TYmTYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38418 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbH0IlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:41:06 -0400
Received: by wicgk12 with SMTP id gk12so1717749wic.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 01:41:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bALm24BpczxWjB8V0gUKL+jeE8v4kkDVcegHxm8TYmTYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 10:17:54AM CEST, sfeldma@gmail.com wrote:
>On Thu, Aug 27, 2015 at 12:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Aug 27, 2015 at 09:16:44AM CEST, sfeldma@gmail.com wrote:
>>>From: Scott Feldman <sfeldma@gmail.com>
>>>
>>>In the switchdev model, we use netdevs to represent switchdev ports, but we
>>>have no representation for the switch itself.  So, introduce a new switchdev
>>>device class so we can define semantics and programming interfaces for the
>>>switch itself.  Switchdev device class isn't tied to any particular bus.
>>>
>>>This patch set is just the skeleton to get us started.  It adds the sysfs
>>>object registration for the new class and defines a class-level attr "foo".
>>>With the new class, we could hook PM functions, for example, to handle power
>>>transitions at the switch level.  I registered rocker and get:
>>>
>>>   $ ls /sys/class/switchdev/5254001235010000/
>>>   foo  power  subsystem  uevent
>>
>> No, please avoid adding anything to sysfs. If we need to add anything,
>> lets make is accesible using Netlink only.
>
>I see no harm in using the device model to define and new device class
>which just so happens to show up in sysfs.  What sysfs attrs get
>exposed is where we can have some discussion/rules.
>
>>>So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
>>>we can build on top of this.  It's not really rtnl.  Maybe genl would work?
>>>What ever it is, we'd need to teach iproute2 about a new 'switch' command.
>>>
>>>Netlink API would allow us to represent switch-wide objects such as registers,
>>>tables, stats, firmware, and maybe even control.  I think with with netlink
>>>TLVs, we can create a framework for these objects but still allow the switch
>>>driver provide switch-specific info.  For example, a table object:
>>>
>>>[TABLES]
>>>       [TABLE]
>>>               [FIELDS]
>>>                       [FIELD]
>>>                               [ID, TYPE]
>>>               [DATA]
>>>                       [ID, VALUE]
>>
>> Alert! I feel that someone would like to abuse this iface for writing
>> configuration through. This should be read-only by design. I also think
>> that this should not be something switch-specific. I believe that NIC
>> drivers would benefit from this iface as well when they want to expose
>> something. I think we should use genl for this.
>
>Read-only is fine.  Look, I'm just trying to dump rocker internal
>tables in some format I can grep outside the kernel.  The tables are
>get big and complicated fast and printk doesn't cut it.   I can use
>degugfs privately, but I need to be able to dump same for field
>troubleshooting.   I can't use debugfs, so I want some kind of
>XML-like dump facility.  It's going to have device-specific data, so
>I'm looking for an XML-like way to represent this data in netlink.

Makes sense.


>
>>>
>>>Maybe iproute2 has pretty-printers for specific switches like ethtool has for
>>>reg dumps.
>>
>> I feel like a lot of what you described overlaps with existing
>> interfaces and tools. Why don't we just reuse that? For firmware for
>> example, just take one of the ports. Same for stats (I plan to expose my
>> mlxsw switch-wide stats in ethtool so they are accessible through every
>> port netdevice).
>
>Port-centric stats are fine for port netdevs, but I'd like switch-wide
>stats to show up elsewhere.

Think about tools, infrastructure, it would get unnecessary complex fast.
I think that if we can, we should use existing infra. So far we can.

>
>Thinking ahead: I'd like to put port into namespaces and I don't want
>to dump stats on a port and see stats on ports in other namespaces.

You would not see stats of other ports, never. You would just see
switch-wide stats.


>
>> I still do not see the need for new device class. I have strong feeling
>> that it should be avoided.
>
>Ok
