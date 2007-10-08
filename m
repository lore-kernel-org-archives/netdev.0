From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NET] IPv6 oops bisected
Date: Mon, 08 Oct 2007 10:02:22 -0600
Message-ID: <m13awld27l.fsf@ebiederm.dsl.xmission.com>
References: <20071008061942.GA842@gondor.apana.org.au>
	<20071007.232302.78733656.davem@davemloft.net> <4709CF6F.60102@sw.ru>
	<20071007.234606.111182047.davem@davemloft.net>
	<4709D58F.2030802@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Pavel Emelyanov <xemul@openvz.org>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40952 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbXJHQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 12:05:41 -0400
In-Reply-To: <4709D58F.2030802@sw.ru> (Denis V. Lunev's message of "Mon, 08
	Oct 2007 11:00:31 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@sw.ru> writes:

> David Miller wrote:
>> From: "Denis V. Lunev" <den@sw.ru>
>> Date: Mon, 08 Oct 2007 10:34:23 +0400
>> 
>>> OK. I am installing Fedora 7 right now...
>> 
>> You don't need to install Fedora, just read the code! :-)
>> 
>> The bug is obvious and it's been explained thoroughly in this
>> thread.
>> 
>> When 'dev' is NULL in ip6_route_add() we need to figure out what
>> namespace and/or loopback device you want to use.
>> 
>> There is no reason to do an entire dist install to work on fixing this
>> bug, yikes!
>
> I do understand the conditions when the bug happens. Its completely
> clear :) Though I do not understand how to trigger it from command line
> to test that the problem is resolved. Jeff was not kind enough to give
> exact command line :(
>
> The unfortunate thing with this place is that original Eric's code is
> also broken here. I was too optimistic working on the original patchset.
> In other way, but broken :(
>
> So, I must stop and think...

Denis. My original patch was fine.  That patch trivially replaced
loopback_dev with init_net.loopback_dev.   That only works for the
initial network namespace.  But until you allow multiple instances of
the network namespace into the ipv6 code the network namespace must
be init_net.

I agree hard coded the init_net.loopback_dev is not where we want to
end up but it does make a good intermediate step.  To allow simple and
stupid intermediate steps is why my original patchset very carefully
filtered every code path into the other layers of the network stack.

At a quick skim through that portion of the code. When we fully convert
it we want to add a network namespace parameter to struct fib6_config,
populate struct fib6_config from the socket that user space is using
to communicate with us.  Then in rt6_route_add and it's friends we
will have the information we need.

Further for the lower layers like ip6_fib.c struct flowi and struct
nl_info will also contain a network namespace parameter.  Which I
think is sufficient to get the network namespace information where
we need it for ipv6 routing.

So Denis do you think you could retry your original patch very
carefully one subsystem at a time instead of all across the entire
tree?

Eric
