From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 16:04:55 +0000
Message-ID: <5630F227.6080502@oracle.com>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk> <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk> <201510270908.t9R9873a001683@room101.nl.oracle.com> <562F577E.6000901@oracle.com> <20151027231702.GA22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, David Miller <davem@davemloft.net>,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33247 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbbJ1QFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 12:05:09 -0400
In-Reply-To: <20151027231702.GA22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 23:17, Al Viro wrote:

> Frankly, as far as I'm concerned, the bottom line is
> 	* there are two variants of semantics in that area and there's not
> much that could be done about that.

Yes, that seems to be the case.

> 	* POSIX is vague enough for both variants to comply with it (it's
> also very badly written in the area in question).

On that aspect I disagree, the POSIX semantics seem clear to me, and are 
different to the Linux behaviour.

> 	* I don't see any way to implement something similar to Solaris
> behaviour without a huge increase of memory footprint or massive cacheline
> pingpong.  Solaris appears to go for memory footprint from hell - cacheline
> per descriptor (instead of a pointer per descriptor).

Yes, that does seem to be the case. Thanks for the detailed explanation 
you've provided as to why that's so.

> 	* the benefits of Solaris-style behaviour are not obvious - all things
> equal it would be interesting, but the things are very much not equal.  What's
> more, if your userland code is such that accept() argument could be closed by
> another thread, the caller *cannot* do anything with said argument after
> accept() returns, no matter which variant of semantics is used.

Yes, irrespective of how you terminate the accept, once it returns with 
an error it's unsafe to use the FD, with the exception of failures such 
as EAGAIN, EINTR etc. However the shutdown() behaviour of Linux is not 
POSIX compliant and allowing an accept to continue of a FD that's been 
closed doesn't seem correct either.

> 	* [Linux-specific aside] our __alloc_fd() can degrade quite badly
> with some use patterns.  The cacheline pingpong in the bitmap is probably
> inevitable, unless we accept considerably heavier memory footprint,
> but we also have a case when alloc_fd() takes O(n) and it's _not_ hard
> to trigger - close(3);open(...); will have the next open() after that
> scanning the entire in-use bitmap.  I think I see a way to improve it
> without slowing the normal case down, but I'll need to experiment a
> bit before I post patches.  Anybody with examples of real-world loads
> that make our descriptor allocator to degrade is very welcome to post
> the reproducers...

It looks like the remaining discussion is going to be about Linux 
implementation details so I'll bow out at this point. Thanks again for 
all the helpful explanation.

-- 
Alan Burlison
--
