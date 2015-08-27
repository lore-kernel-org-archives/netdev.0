From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 00:36:20 -0700
Message-ID: <55DEBDF4.8030301@gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, davem@davemloft.net, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36315 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbH0HfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:35:02 -0400
Received: by obkg7 with SMTP id g7so9333533obk.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:35:01 -0700 (PDT)
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-08-27 12:16 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> In the switchdev model, we use netdevs to represent switchdev ports, but we
> have no representation for the switch itself.  So, introduce a new switchdev
> device class so we can define semantics and programming interfaces for the
> switch itself.  Switchdev device class isn't tied to any particular bus.
> 
> This patch set is just the skeleton to get us started.  It adds the sysfs
> object registration for the new class and defines a class-level attr "foo".
> With the new class, we could hook PM functions, for example, to handle power
> transitions at the switch level.  I registered rocker and get:
> 
>    $ ls /sys/class/switchdev/5254001235010000/
>    foo  power  subsystem  uevent
> 
> So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
> we can build on top of this.  It's not really rtnl.  Maybe genl would work?
> What ever it is, we'd need to teach iproute2 about a new 'switch' command.
> 
> Netlink API would allow us to represent switch-wide objects such as registers,
> tables, stats, firmware, and maybe even control.  I think with with netlink
> TLVs, we can create a framework for these objects but still allow the switch
> driver provide switch-specific info.  For example, a table object:
> 

Hi Scott,

I was going to take the flow-api presented in Feb and submitted
to netdev and get it up to date. I started doing this today should be
ready end of week.

> [TABLES]
> 	[TABLE]
> 		[FIELDS]
> 			[FIELD]
> 				[ID, TYPE]
> 		[DATA]
> 			[ID, VALUE]
> 

The structure I used previously which looks like your prototype I think,

 (https://github.com/jrfastab/rocker-net-next/blob/master/include/uapi/linux/if_flow.h)

 * [NFL_TABLE_IDENTIFIER_TYPE]
 * [NFL_TABLE_IDENTIFIER]
 * [NFL_TABLE_TABLES]
 *     [NFL_TABLE]
 *	 [NFL_TABLE_ATTR_NAME]
 *	 [NFL_TABLE_ATTR_UID]
 *	 [NFL_TABLE_ATTR_SOURCE]
 *	 [NFL_TABLE_ATTR_APPLY]
 *	 [NFL_TABLE_ATTR_SIZE]
 *	 [NFL_TABLE_ATTR_MATCHES]
 *	   [NFL_FIELD_REF]
 *	     [NFL_FIELD_REF_INSTANCE]
 *	     [NFL_FIELD_REF_HEADER]
 *	     [NFL_FIELD_REF_FIELD]
 *	     [NFL_FIELD_REF_MASK]
 *	     [NFL_FIELD_REF_TYPE]
 *	   [...]
 *	 [NFL_TABLE_ATTR_ACTIONS]
 *	     [NFL_ACTION_ATTR_UID]
 *	     [...]
 *     [NFL_TABLE]
 *       [...]
 *

This is well-typed per Dave's comment. And because its Netlink based it
can be easily extended as needed. The above gives basic information on
the table. Sure it could stand to have some other entries in it but I
never needed them for my capabilities/resource discovery. We could argue
about removing some if they are too specific to my use cases.

> Maybe iproute2 has pretty-printers for specific switches like ethtool has for
> reg dumps.
> 
> I don't know about how this overlaps with DSA platform_class.  Florian?
> 
> Comments?

A few other interesting (at least to me) structures you can find in the
if_flow.h header file give how the tables in the hardware are put
together. I found this really useful when trying to sort out where my
various ACLs/nexthop entries/etc were in the hardware order. This is
important to know for many cases. This is NFL_TABLE_GRAPH.

Also I found being able to "know' what headers the hardware supports
to be very useful. For example I want/need to know if QinQ will work.
Or VXLAN/NSH, Geneve, etc. This is NFL_HEADER_GRAPH.

Sure if_flow.h is a poor name and FlowAPI is probably not really great.
But both those names come from how I model the hardware as match action
tables. I can change those names to switchdev_resources or
switchdev_info if folks want.

My point is the interface is generic and provides a common interface for
most hardware I've seen to date. Certainly curious if there is hardware
it doesn't map to. Although tables and pipelines seems fairly universal
for a large set of devices to me. Further it can be extended as needed.

I'll drop the set_rule/del_rule parts to be merged with ebpf/tc/qdisc.

.John


> 
> 
> Scott Feldman (2):
>   switchdev: create new switchdev device class
>   rocker: register each switch as a switchdev
> 
>  drivers/net/ethernet/rocker/rocker.c |   23 ++++++++++
>  include/net/switchdev.h              |   16 +++++++
>  net/switchdev/switchdev.c            |   76 ++++++++++++++++++++++++++++++++++
>  3 files changed, 115 insertions(+)
> 
