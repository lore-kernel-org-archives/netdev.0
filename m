From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Mon, 21 Apr 2008 13:43:31 +0200
Message-ID: <480C7DE3.5020301@firstfloor.org>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>	<20080420.230356.238029889.davem@davemloft.net>	<87y7777ahj.fsf@basil.nowhere.org> <20080421.035939.37324583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: juhlenko@akamai.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49363 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbYDULnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:43:33 -0400
In-Reply-To: <20080421.035939.37324583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon, 21 Apr 2008 12:44:56 +0200
> 
>> David Miller <davem@davemloft.net> writes:
>>
>>> Moving the timestamp up to a higher level takes away some of the
>>> frequent use cases of timestamps, which is to detect things like the
>>> fact that it is taking a long time for packets to get from the
>>> top-level packet receive down to the actual protocol processing.
>> Is that really a frequent use case? It sounds more like a specialized
>> debugging situation. Most users are not network stack hackers :)
> 
> Ask a financial service industry shop what the implications of
> inaccurate transaction timestamps can be.  It possible for it to be
> measured in the millions if not billions of euros.

Are you sure they don't just need end2end timestamps as in from sendmsg
to recvmsg()? Imagine the packet is stuck for some time in the
kernel for whatever reason and you only process it later in user space
wouldn't you consider that older time stamp "inaccurate" too? I would,
unless I was debugging the network stack.

It is hard to imagine they really care about excluding one set of queues
(kernel queue) and not other queues (nic rx/tx queues, switch queues
etc.) for their time stamps as you imply.

>> But if you are willing to give away some of the guarantees of standard
>> gettimeofday (like global non monotonicity between CPUs) then you
>> could actually still use TSC even on those systems. And I don't
>> think global non monotonicity is really needed for a packet
>> time stamp ...
> 
> So if tcpdump gets resceduled on another cpu, or the multiqueue flow
> hashing algorithm changes, the appearance of the ordering of packets
> changes.

If that is the problem you could always cut off some lower bits in the
time stamp and put a sequence counter in there. Ok not serious. It would
probably still work for most people though.

> No thanks.
> 
> Nobody wants half-working timestamps. 

I'm not so sure. When I was still working on this I had some
conversation with various application people about this, and when
prodded they generally were supportive of the relaxed time stamp idea
when presented with the alternatives (either slow timers or relaxed timers)

Very few applications really need the full time stamp guarantees.
For your debugging example relaxed time stamps would work great I would
think.

But yes as always when changing some existing semantics it is hard to be
sure it won't be a problem for somebody. The only really safe way
is to use different interfaces but that circumvents Jason's idea
of fixing the existing binaries.

> That's why it's such an
> enormous issue that x86 screwed this up so badly for such a long
> period of time.

Well pretty much all older CPUs (x86 and non x86) with aggressive power
saving have broken internal timers. the one usually comes with the
other.  Only recently have hardware people learned to avoid that.

-Andi


