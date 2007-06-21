From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Thu, 21 Jun 2007 09:18:38 -0600
Message-ID: <m17ipxfi9d.fsf@ebiederm.dsl.xmission.com>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
	<20070607.184731.10907840.davem@davemloft.net>
	<E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:55793 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbXFUPYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:24:45 -0400
In-Reply-To: <E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu> (Miklos Szeredi's
	message of "Mon, 11 Jun 2007 11:57:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Miklos Szeredi <miklos@szeredi.hu> writes:

> [CC'd Al Viro and Alan Cox, restored patch]
>
>> > There are races involving the garbage collector, that can throw away
>> > perfectly good packets with AF_UNIX sockets in them.
>> > 
>> > The problems arise when a socket goes from installed to in-flight or
>> > vice versa during garbage collection.  Since gc is done with a
>> > spinlock held, this only shows up on SMP.
>> > 
>> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
>> 
>> I'm going to hold off on this one for now.
>> 
>> Holding all of the read locks kind of defeats the purpose of using
>> the per-socket lock.
>> 
>> Can't you just lock purely around the receive queue operation?
>
> That's already protected by the receive queue spinlock.  The race
> however happens _between_ pushing the root set and marking of the
> in-flight but reachable sockets.
>
> If in that space any of the AF_UNIX sockets goes from in-flight to
> installed into a file descriptor, the garbage collector can miss it.
> If we want to protect against this using unix_sk(s)->readlock, then we
> have to hold all of them for the duration of the marking.
>
> Al, Alan, you have more experience with this piece of code.  Do you
> have better ideas about how to fix this?

I haven't looked at the code closely enough to be confident of
changing something in this area.  However the classic solution to this
kind of gc problem is to mark things that are manipulated during
garbage collection as dirty (not orphaned).

It should be possible to fix this problem by simply changing gc_tree
when we perform a problematic manipulation of a passed socket, such
as installing a passed socket into the file descriptors of a process.

Essentially the idea is moving the current code in the direction of
an incremental gc algorithm.


If I understand the race properly.  What happens is that we dequeue
a socket (which has packets in it passing sockets) before the
garbage collector gets to it.  Therefore the garbage collector
never processes that socket.  So it sounds like we just
need to call maybe_unmark_and_push or possibly just wait for
the garbage collector to complete when we do that and the packet
we have pulled out 



So just looking at this quickly.  It looks like we need to hold
the u->readlock mutex in garbage.c while looking at the receive
queue.  Otherwise we may be processing a packet and have
the file descriptors in limbo.  Either that or we need
to slightly extend the scope of the receive queue lock on the
receive side.

Additionally we need to modify unix_notinflight to mark the sockets
as inuse, or to at least wait for the garbage collection to complete.
While being very careful to not add a deadlock scenario.

The require changes to fix this without adding heavy handed locking
look a bit nasty to make.

I half suspect switching to one of the simpler incremental garbage
collection algorithms might not be equally easy to implement and
give us more performance at the same time.  Having a garbage collector
that can block has advantages.

The practical problem is you can't modify the list of pushed object
aka gc_tree without holding a lock.  And we never drop the
unix_table_lock.


Anyway hopefully that is enough fodder for someone to come up with
a light weight fix for this problem.

Eric
