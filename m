From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 18:05:48 +0100
Message-ID: <20151022170548.GR22011@ZenIV.linux.org.uk>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
 <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
 <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
 <5628CF79.2000507@oracle.com>
 <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
 <5628E142.7050600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Casper.Dik@oracle.com,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37404 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbbJVRFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:05:55 -0400
Content-Disposition: inline
In-Reply-To: <5628E142.7050600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 02:14:42PM +0100, Alan Burlison wrote:

> The issues I hit were in the context of application porting, where
> the APIs in question are covered by POSIX. The Linux manpages for
> open(), close(), socket(), dup2() and shutdown() all claim
> POSIX.1-2001 conformance. If performance is the most important
> concern then it's a valid decision to prioritise that over POSIX
> conformance, you simply can't continue to claim that the relevant
> Linux APIs are fully POSIX conformant, so I believe at the minimum
> the Linux manpages need modifying.

Oh, for...  Right in this thread an example of complete BS has been quoted
from POSIX close(2).  The part about closing a file when the last descriptor
gets closed.  _Nothing_ is POSIX-compliant in that respect (nor should
it be).  Semantics around the distinction between file descriptors and
<barf> file descriptions is underspecified, not to mention being very poorly
written.

You want to add something along the lines of "if any action by another thread
changes the mapping from file descriptors to file descriptions for any
file descriptor passed to syscall, such and such things should happen" - go
ahead and specify what should happen.  As it is, I don't see anything of
that sort in e.g. accept(2).  And no,
	[EBADF]
	    The socket argument is not a valid file descriptor.
in there is nowhere near being unambiguous enough - everyone agrees that
argument should be a valid descriptor at the time of call, but I would be
very surprised to find _any_ implementation (including Solaris one)
recheck that upon exit to userland.

For more bullshit from the same source (issue 7, close(2)):
	If fildes refers to a socket, close() shall cause the socket to be
	destroyed. If the socket is in connection-mode, and the SO_LINGER
	option is set for the socket with non-zero linger time, and the socket
	has untransmitted data, then close() shall block for up to the current
	linger interval until all data is transmitted.
I challenge you to find *any* implementation that would have
	fd = socket(...);
	close(dup(fd));
do what this wonder of technical prose clearly requests.  In the same text we
also have
	When all file descriptors associated with a pipe or FIFO special file
	are closed, any data remaining in the pipe or FIFO shall be discarded.
as well as explicit (and underspecified, but perhaps they do it elsewhere)
"last close" in parts related to sockets and ptys.

And that is not to mention the dup2(2) wording in there:
	If fildes2 is already a valid open file descriptor, it shall be
	closed first
which is (a) inviting misinterpretation that would make the damn thing
non-atomic (the only mentioning of atomicity is in non-normative sections)
and (b) says fsck-all about the effects of closing descriptor.  The latter
is a problem, since nothing in close(2) bothers making a distinction between
the effects specific to particular syscall and those common to all ways of
closing a descriptor.  And no, it's not a nitpicking - consider e.g. the
parts concerning the order of events triggered by close(2) (such and such
should be completed before close(2) returns); should it be taken as "same
events should be completed before newfd is associated with the file description
refered to by oldfd"?  It _is_ user-visible, since close(2) removes fcntl
locks.  Sure, there is (otherwise unexplained)
	The dup2() function is not intended for use in critical regions
	as a synchronization mechanism.
down in informative sections, so one can infer that event order here isn't
to be relied upon.  With no way to guess whether the event order concerning
e.g. effect on ongoing accept(newfd) is any different in that respect.

The entire area in Issue 7 stinks.  It might make sense to try and fix it
up, but let's not pretend that what's in there right now does specify the
semantics in this kind of situations.

I'm not saying that Solaris approach yields an inherently bad semantics or
that it's impossible to implement without high scalability price and/or
high memory footprint.  But waving the flag of POSIX compliance when you
are actually talking about the ways your implementation plugs the holes in
a badly incomplete spec...

Not to contribute to pissing contest, but IIRC Solaris wasn't even the first
kernel having to deal with the possibility of descriptor table getting changed
by another thread under ongoing syscall.  Which was completely outside of
POSIX scope, not that Plan 9 folks gave a damn.  For Linux that can of worms
had opened in 1.3.22 (Sep 1995), for OpenBSD - next January, a month later
followed by FreeBSD (ab, said to be based on OpenBSD variant) and in Jan 1998
by NetBSD (said to be partially based on FreeBSD one).  All of those had been
more or less inspired by Plan 9 approach (in case of *BSD the original
implementation was by Ron Minnich).  Not sure when Plan 9 has implemented
their variant; it was definitely there by the beginning of 1993 (going by
the date on Release 1 rfork(2)).  That would be what, around the time of
Solaris 2.1?
