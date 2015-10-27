From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 23:17:02 +0000
Message-ID: <20151027231702.GA22011@ZenIV.linux.org.uk>
References: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
 <20151022215741.GW22011@ZenIV.linux.org.uk>
 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
 <20151024023054.GZ22011@ZenIV.linux.org.uk>
 <201510270908.t9R9873a001683@room101.nl.oracle.com>
 <562F577E.6000901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casper.Dik@oracle.com, David Miller <davem@davemloft.net>,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49484 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbJ0XRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 19:17:08 -0400
Content-Disposition: inline
In-Reply-To: <562F577E.6000901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 10:52:46AM +0000, Alan Burlison wrote:
> Unfortunately Hadoop isn't the only thing that pulls the shutdown()
> trick, so I don't think there's a simple fix for this, as discussed
> earlier in the thread. Having said that, if close() on Linux also
> did an implicit shutdown() it would mean that well-written
> applications that handled the scoping, sharing and reuse of FDs
> properly could just call close() and have it work the same way
> across *NIX platforms.

... except for all Linux, FreeBSD and OpenBSD versions out there, but
hey, who's counting those, right?  Not to mention the OSX behaviour -
I really have no idea what it does; the FreeBSD ancestry in its kernel
is distant enough for a lot of changes to have happened in that area.

So...  Which Unices other than Solaris and NetBSD actually behave that
way?  I.e. have close(fd) cancel accept(fd) another thread is sitting
in.  Note that NetBSD implementation has known races.  Linux, FreeBSD
and OpenBSD don't do that at all.

Frankly, as far as I'm concerned, the bottom line is
	* there are two variants of semantics in that area and there's not
much that could be done about that.
	* POSIX is vague enough for both variants to comply with it (it's
also very badly written in the area in question).
	* I don't see any way to implement something similar to Solaris
behaviour without a huge increase of memory footprint or massive cacheline
pingpong.  Solaris appears to go for memory footprint from hell - cacheline
per descriptor (instead of a pointer per descriptor).
	* the benefits of Solaris-style behaviour are not obvious - all things
equal it would be interesting, but the things are very much not equal.  What's
more, if your userland code is such that accept() argument could be closed by
another thread, the caller *cannot* do anything with said argument after
accept() returns, no matter which variant of semantics is used.
	* [Linux-specific aside] our __alloc_fd() can degrade quite badly
with some use patterns.  The cacheline pingpong in the bitmap is probably
inevitable, unless we accept considerably heavier memory footprint,
but we also have a case when alloc_fd() takes O(n) and it's _not_ hard
to trigger - close(3);open(...); will have the next open() after that
scanning the entire in-use bitmap.  I think I see a way to improve it
without slowing the normal case down, but I'll need to experiment a
bit before I post patches.  Anybody with examples of real-world loads
that make our descriptor allocator to degrade is very welcome to post
the reproducers...
