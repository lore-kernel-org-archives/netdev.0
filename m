From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] [PATCH 1/1] Dynamically allocate the loopback device
Date: Mon, 27 Aug 2007 06:12:14 -0600
Message-ID: <m1lkbx5g81.fsf@ebiederm.dsl.xmission.com>
References: <11879698031215-git-send-email-dlezcano@fr.ibm.com>
	<46CEFF83.3040003@gmail.com> <20070824104301.2f4ff34e@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <dlunev@gmail.com>, dlezcano@fr.ibm.com,
	davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51820 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938AbXH0MMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 08:12:47 -0400
In-Reply-To: <20070824104301.2f4ff34e@localhost> (Stephen Hemminger's message
	of "Fri, 24 Aug 2007 10:43:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> On Fri, 24 Aug 2007 19:55:47 +0400
> "Denis V. Lunev" <dlunev@gmail.com> wrote:
>
>> dlezcano@fr.ibm.com wrote:
>> > From: Daniel Lezcano <dlezcano@fr.ibm.com>
>> > 
>> > Doing this makes loopback.c a better example of how to do a
>> > simple network device, and it removes the special case
>> > single static allocation of a struct net_device, hopefully
>> > making maintenance easier.
>> > 
>> > Applies against net-2.6.24
>> > 
>> > Tested on i386, x86_64
>> > Compiled on ia64, sparc
>> 
>> I think that a small note, that initialization order is changed will be
>> good to record. After this, loopback MUST be allocated before any other
>> networking subsystem initialization. And this is an important change.
>> 
>> Regards,
>>     Den
>
> Yes, this code would break when other drivers are directly linked
> in. 

No. Other drivers don't care at all about the loopback device,
and it isn't a requirement that the loopback device be initialized
before other devices.

The requirement is that the loopback device is allocated before
we start using it.  Which means networking subsystems like
ipv4 and ipv6 care not other network drivers.  In practices this means
before we get very far into the ipv4 subsystem initialization as
ipv4 is always compiled in and is initialized early.

To get the initialization order correct I used fs_initcall instead of
module_init.

When I reflect on it.  I'm not really comfortable with the fact
that we currently start using the loopback device before we
finish initializing and register it.  Although it has worked
for over a decade so I guess early on we don't care about
much more then the address of the loopback device.

>From what I can tell the initialization order dependency seems much
less subtle and much more robust then separate rules for allocating
the loopback device.  We have had several patchs recently that
broke (including one merged upstream).  The only way I can see
to break an initialization order dependency is to go deliberately
messing around with initialization order.

Eric

p.s.  My apologies for the late reply some one dropped me off the cc.
And I have been under the weather all week.
