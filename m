From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Tue, 19 Aug 2008 09:36:49 -0400
Message-ID: <48AACC71.5090701@hp.com>
References: <48A911AD.7060102@cn.fujitsu.com>	<48A9799B.4040409@hp.com> <20080818.223857.125980599.davem@davemloft.net> <48AA6800.1020506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:1212 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbYHSNgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:36:52 -0400
In-Reply-To: <48AA6800.1020506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> David Miller wrote:
>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Date: Mon, 18 Aug 2008 09:31:07 -0400
>>
>>> I don't think that's correct at all.  The code path shows here is
>>> when there are no received options and no sticky options set.  In
>>> such case, we shouldn't be returning multicast or bound interfaces.
>>> We should be returning 0.
> 
> I use setsockopt() to set the bounded interface of the socket, and 
> then I get receiving interface index while no message is received through
> the above socket,shoudn't the bounded interface be returned?

One of the problems is that we don't seem to support the sticky IPV6_PKTINFO
option as specified in rfc3542.

The setting of SO_BINDTODEVICE should not impact the return of the sticky option
values when they are not set.  A return of 0 in the sticky options means that
that value has not been specified.  If you return anything else, you give
the illusion that a sticky option was set.

> 
>>> Additionally the address returned is completely bogus as well. We
>>> are returning the address our peer instead of the one of our own
>>> addresses.
> 
> If message is received,the address returned is what the received
> message refered to, otherwise the address returned is what I used setsockopt()
> to set before.

We are returning np->daddr, which is the peer address.

The expected value is "destination of the received packet".  In the worst case,
it should be the locally bound address.  In the correct case, it should be the
address set in the sticky options if such is set.  It really should be 0::0, if there
are no sticky options and no packets have been received.

-vlad

> 
>> Yang, please fix this up, thank you.
>>
>>
> 
> Seems that I misunderstood the RFC?
> 

