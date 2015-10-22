From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 18:39:34 +0100
Message-ID: <56291F56.2080906@oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <201510220615.t9M6FL2d017592@room101.nl.oracle.com> <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com> <5628CF79.2000507@oracle.com> <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com> <5628E142.7050600@oracle.com> <20151022170548.GR22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Casper.Dik@oracle.com,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34857 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965425AbbJVRju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:39:50 -0400
In-Reply-To: <20151022170548.GR22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 18:05, Al Viro wrote:

> Oh, for...  Right in this thread an example of complete BS has been quoted
> from POSIX close(2).  The part about closing a file when the last descriptor
> gets closed.  _Nothing_ is POSIX-compliant in that respect (nor should
> it be).

That's not exactly what it says, we've already discussed, for example in 
the case of pending async IO on a filehandle.

> Semantics around the distinction between file descriptors and
> <barf> file descriptions is underspecified, not to mention being very poorly
> written.

I agree that part could do with some polishing.

> You want to add something along the lines of "if any action by another thread
> changes the mapping from file descriptors to file descriptions for any
> file descriptor passed to syscall, such and such things should happen" - go
> ahead and specify what should happen.  As it is, I don't see anything of
> that sort in e.g. accept(2).  And no,
> 	[EBADF]
> 	    The socket argument is not a valid file descriptor.
> in there is nowhere near being unambiguous enough - everyone agrees that
> argument should be a valid descriptor at the time of call, but I would be
> very surprised to find _any_ implementation (including Solaris one)
> recheck that upon exit to userland.

The scenario I described previously, where dup2() is used to modify a fd 
that's being used in accept, result in the accept call terminating in 
the same way as if close had been called on it - Casper gave details 
earlier.

> For more bullshit from the same source (issue 7, close(2)):
> 	If fildes refers to a socket, close() shall cause the socket to be
> 	destroyed. If the socket is in connection-mode, and the SO_LINGER
> 	option is set for the socket with non-zero linger time, and the socket
> 	has untransmitted data, then close() shall block for up to the current
> 	linger interval until all data is transmitted.
> I challenge you to find *any* implementation that would have
> 	fd = socket(...);
> 	close(dup(fd));
> do what this wonder of technical prose clearly requests.  In the same text we
> also have
> 	When all file descriptors associated with a pipe or FIFO special file
> 	are closed, any data remaining in the pipe or FIFO shall be discarded.
> as well as explicit (and underspecified, but perhaps they do it elsewhere)
> "last close" in parts related to sockets and ptys.

Yes, Casper has just reported that to TOG, see 
http://thread.gmane.org/gmane.comp.standards.posix.austin.general/11573. 
Our assessment is that sockets should behave the same way as plain 
files, i.e. 'last close'.

> And that is not to mention the dup2(2) wording in there:
> 	If fildes2 is already a valid open file descriptor, it shall be
> 	closed first
> which is (a) inviting misinterpretation that would make the damn thing
> non-atomic (the only mentioning of atomicity is in non-normative sections)

I've already explained why I believe atomic behaviour of dup2() is 
required by POSIX. If you feel it's not clear then we can ask POSIX for 
clarification.

> and (b) says fsck-all about the effects of closing descriptor.  The latter
> is a problem, since nothing in close(2) bothers making a distinction between
> the effects specific to particular syscall and those common to all ways of
> closing a descriptor.  And no, it's not a nitpicking - consider e.g. the
> parts concerning the order of events triggered by close(2) (such and such
> should be completed before close(2) returns); should it be taken as "same
> events should be completed before newfd is associated with the file description
> refered to by oldfd"?  It _is_ user-visible, since close(2) removes fcntl
> locks.  Sure, there is (otherwise unexplained)
> 	The dup2() function is not intended for use in critical regions
> 	as a synchronization mechanism.
> down in informative sections, so one can infer that event order here isn't
> to be relied upon.  With no way to guess whether the event order concerning
> e.g. effect on ongoing accept(newfd) is any different in that respect.

I think "it shall be closed first" makes it pretty clear that what is 
expected is the same behaviour as any direct invocation of close, and 
that has to happen before the reassignment. What makes you believe 
that's isn't the case?

> The entire area in Issue 7 stinks.  It might make sense to try and fix it
> up, but let's not pretend that what's in there right now does specify the
> semantics in this kind of situations.

Sorry, I disagree.

> I'm not saying that Solaris approach yields an inherently bad semantics or
> that it's impossible to implement without high scalability price and/or
> high memory footprint.  But waving the flag of POSIX compliance when you
> are actually talking about the ways your implementation plugs the holes in
> a badly incomplete spec...

Personally I believe the spec is clear enough to allow an unambiguous 
interpretation of the required behavior in this area. If you think there 
are areas where the Solaris behaviour is in disagreement with the spec 
then I'd be interested to hear them.

-- 
Alan Burlison
--
