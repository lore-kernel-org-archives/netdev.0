From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] [PATCH 4/4] net: Make the loopback device per network namespace
Date: Thu, 27 Sep 2007 10:48:14 -0600
Message-ID: <m1ejgkkqb5.fsf@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
	<m17imdrn8r.fsf_-_@ebiederm.dsl.xmission.com> <46FB9EB1.5070908@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:45119 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756820AbXI0QtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 12:49:09 -0400
In-Reply-To: <46FB9EB1.5070908@sw.ru> (Denis V. Lunev's message of "Thu, 27
	Sep 2007 16:14:41 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@sw.ru> writes:

> Eric W. Biederman wrote:
>> This patch makes loopback_dev per network namespace.  Adding
>> code to create a different loopback device for each network
>> namespace and adding the code to free a loopback device
>> when a network namespace exits.
>> 
>> This patch modifies all users the loopback_dev so they
>> access it as init_net.loopback_dev, keeping all of the
>> code compiling and working.  A later pass will be needed to
>> update the users to use something other than the initial network
>> namespace.
>
> A pity that an important bit of explanation is missed. The
> initialization of loopback_dev is moved from a chain of devices
> (init_module) to a subsystem initialization to keep proper order, i.e.
> we must be sure that the initialization order is correct.

That didn't happen in the patch you mentioned.  That happened
when we started dynamically allocating the loopback device.
That was the patch Daniel sent out a bit ago.

There are certainly some ordering issues and it may have helped
to talk about them.  But they are because things assume the
loopback device is present.  We have various bits of code that
is around such as the dst_ifdown case that assumes if another
network device is present the loopback device is present.  To
fulfill that assumption I guess that means we have both an
initialization order dependency and a destruction order dependency.

The fact we were using module_init before actually appears to
me to have been racy, but we got away with it because the actual
data structure was statically allocated.

Since it appears that for a dynamically allocated loopback
registering it first and unregistering it last is necessary
for routing.   It is likely worth looking at this a little
more closely and making a guarantee.  So we can make it easier
for networking layers like ipv6, that want to memorize which
device is the loopback device.

Eric
