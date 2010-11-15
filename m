From: Jeff Garzik <jeff@garzik.org>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 16:03:49 -0500
Message-ID: <4CE1A035.6080307@garzik.org>
References: <4CE18CEA.5080502@garzik.org> <1289852326.2586.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36841 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933601Ab0KOVDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:03:55 -0500
Received: by vws13 with SMTP id 13so1929530vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:03:54 -0800 (PST)
In-Reply-To: <1289852326.2586.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 03:18 PM, Ben Hutchings wrote:
> On Mon, 2010-11-15 at 14:41 -0500, Jeff Garzik wrote:
>> Thanks for accepting ethtool maintainership.
>>
>> There are two key unresolved issues with ethtool that are worth noting
>> to the next maintainer.  Both of these come from years of user and
>> customer complaints.
>>
>> 1) ethtool command line interface.
>>
>> For 1,001 minor reasons of user taste and expectation, people tend to
>> complain about the command line interface.  Due to script usage it is
>> set in stone, and has been since before my tenure.  But users
>> continually request something more flexible, often, in particular,
>> wanting to set multiple settings in one execution, or wanting to apply
>> the same setting to multiple interface in one execution.
>>
>> Obviously one can script this, but, it is probably the #1 user request.
>
> Thinking further along those lines, it would be useful to have ethtool
> API bindings for Perl/Python/whatever, though those belong outside of
> the current ethtool package.  I tried doing that for use in my own
> scripts and it looks reasonably practical, though I'm not volunteering
> to maintain such bindings.

I agree.  FWIW, python-ethtool exists out there in the wild.

There is 
git://git.kernel.org/pub/scm/linux/kernel/git/acme/python-ethtool.git
but I'm pretty sure acme handed off maintainership to someone else.  If 
you have the energy, integrating that into the official ethtool package 
would probably be welcomed by all parties.


>> My thought was to create "nictool", a new tool with more flexible
>> command line interface, using the same old ethtool ioctls currently in
>> use today.  ('nictool' also solves a minor naming complaint from
>> wireless and other people, who use ethtool on non-ethernet network
>> interfaces)
>
> I agree, some of the ethtool operations are very Ethernet-specific but
> enough of them are applicable to other media that this makes sense.
>
> I've recently been looking at FreeBSD where the sort of configuration we
> do through ethtool is invoked through ifconfig, but then ifconfig is
> effectively deprecated on Linux...

FreeBSD is back in the stone ages, when it comes to this sort of thing, IMO.

Though, I do understand users' desire for a single tool that configures 
both generic network interface parameters and hardware-specific, 
vendor-specific interface parameters.


>> 2) multiple settings and the ethtool kernel interface
>>
>> Another common complaint is related to multiple settings, and associated
>> hardware NIC resets.
>>
>> Many ethtool driver implementations look like this:
>>
>> 	ethtool_op_do_something()
>> 		stop RX/TX
>> 		apply settings
>> 		perform full NIC reset, consuming much time
>> 		start RX/TX
>>
>> The problem arises when the user wishes to change multiple hardware
>> attributes at the same time.  A user wishing to change 4 attributes
>> could wind up with 4 ethtool(1) invocations, with 4 accompanying
>> hardware NIC resets.  Time consuming, inefficient, and unnecessary.
>
> Right.  In fact the begin() and complete() operations look like they
> were meant to support this sort of optimisation.  Is that the case?

Somewhat...

->begin() and ->complete() were initially for reducing internal code 
duplication.  You would put stop-RXTX in begin(), and 
nic-reset/start-RXTX in complete().

Fundamentally, the ioctl interface itself is still fine-grained.  You 
don't have ETHTOOL_BEGIN and ETHTOOL_COMPLETE ioctls.  And even if you 
did, such operations would be fundamentally race-prone.

AFAICS, the only race-free way to implement would be to have userspace 
issue a single ioctl that contains a list of operations to perform. eg.

A new ETHTOOL_MULTI_OP ioctl would contain
	op SSET + payload
	op SSG + payload
	op SGSO + payload

and the kernel would handle that internally by calling
	->begin()
	->set_settings()
	->set_sg()
	->set_gso()
	->complete()

So the kernel API is largely already there, while the userspace ABI 
constrains us mightily.

	Jeff



