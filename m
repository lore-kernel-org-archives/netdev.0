From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 09:44:18 +0200
Message-ID: <20150827074418.GL2228@nanopsycho.orion>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <55DEBDF4.8030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37463 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbbH0HoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:44:21 -0400
Received: by widdq5 with SMTP id dq5so36061669wid.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:44:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55DEBDF4.8030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 09:36:20AM CEST, john.fastabend@gmail.com wrote:
>On 15-08-27 12:16 AM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>> 
>> In the switchdev model, we use netdevs to represent switchdev ports, but we
>> have no representation for the switch itself.  So, introduce a new switchdev
>> device class so we can define semantics and programming interfaces for the
>> switch itself.  Switchdev device class isn't tied to any particular bus.
>> 
>> This patch set is just the skeleton to get us started.  It adds the sysfs
>> object registration for the new class and defines a class-level attr "foo".
>> With the new class, we could hook PM functions, for example, to handle power
>> transitions at the switch level.  I registered rocker and get:
>> 
>>    $ ls /sys/class/switchdev/5254001235010000/
>>    foo  power  subsystem  uevent
>> 
>> So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
>> we can build on top of this.  It's not really rtnl.  Maybe genl would work?
>> What ever it is, we'd need to teach iproute2 about a new 'switch' command.
>> 
>> Netlink API would allow us to represent switch-wide objects such as registers,
>> tables, stats, firmware, and maybe even control.  I think with with netlink
>> TLVs, we can create a framework for these objects but still allow the switch
>> driver provide switch-specific info.  For example, a table object:
>> 
>
>Hi Scott,
>
>I was going to take the flow-api presented in Feb and submitted
>to netdev and get it up to date. I started doing this today should be
>ready end of week.
>
>> [TABLES]
>> 	[TABLE]
>> 		[FIELDS]
>> 			[FIELD]
>> 				[ID, TYPE]
>> 		[DATA]
>> 			[ID, VALUE]
>> 
>
>The structure I used previously which looks like your prototype I think,
>
> (https://github.com/jrfastab/rocker-net-next/blob/master/include/uapi/linux/if_flow.h)
>
> * [NFL_TABLE_IDENTIFIER_TYPE]
> * [NFL_TABLE_IDENTIFIER]
> * [NFL_TABLE_TABLES]
> *     [NFL_TABLE]
> *	 [NFL_TABLE_ATTR_NAME]
> *	 [NFL_TABLE_ATTR_UID]
> *	 [NFL_TABLE_ATTR_SOURCE]
> *	 [NFL_TABLE_ATTR_APPLY]
> *	 [NFL_TABLE_ATTR_SIZE]
> *	 [NFL_TABLE_ATTR_MATCHES]
> *	   [NFL_FIELD_REF]
> *	     [NFL_FIELD_REF_INSTANCE]
> *	     [NFL_FIELD_REF_HEADER]
> *	     [NFL_FIELD_REF_FIELD]
> *	     [NFL_FIELD_REF_MASK]
> *	     [NFL_FIELD_REF_TYPE]
> *	   [...]
> *	 [NFL_TABLE_ATTR_ACTIONS]
> *	     [NFL_ACTION_ATTR_UID]
> *	     [...]
> *     [NFL_TABLE]
> *       [...]
> *
>
>This is well-typed per Dave's comment. And because its Netlink based it
>can be easily extended as needed. The above gives basic information on
>the table. Sure it could stand to have some other entries in it but I
>never needed them for my capabilities/resource discovery. We could argue
>about removing some if they are too specific to my use cases.

I guess you are talking about read-only interface right?
