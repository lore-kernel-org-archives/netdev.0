From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Sat, 23 Jun 2007 10:48:37 +0200
Message-ID: <E1I21IL-0004LH-00@dorka.pomaz.szeredi.hu>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
	<20070607.184731.10907840.davem@davemloft.net>
	<E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu> <m17ipxfi9d.fsf@ebiederm.dsl.xmission.com>
Cc: davem@davemloft.net, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:51487 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbXFWItQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 04:49:16 -0400
In-reply-to: <m17ipxfi9d.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric, thanks for looking at this.

> >> > There are races involving the garbage collector, that can throw away
> >> > perfectly good packets with AF_UNIX sockets in them.
> >> > 
> >> > The problems arise when a socket goes from installed to in-flight or
> >> > vice versa during garbage collection.  Since gc is done with a
> >> > spinlock held, this only shows up on SMP.
> >> > 
> >> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> >> 
> >> I'm going to hold off on this one for now.
> >> 
> >> Holding all of the read locks kind of defeats the purpose of using
> >> the per-socket lock.
> >> 
> >> Can't you just lock purely around the receive queue operation?
> >
> > That's already protected by the receive queue spinlock.  The race
> > however happens _between_ pushing the root set and marking of the
> > in-flight but reachable sockets.
> >
> > If in that space any of the AF_UNIX sockets goes from in-flight to
> > installed into a file descriptor, the garbage collector can miss it.
> > If we want to protect against this using unix_sk(s)->readlock, then we
> > have to hold all of them for the duration of the marking.
> >
> > Al, Alan, you have more experience with this piece of code.  Do you
> > have better ideas about how to fix this?
> 
> I haven't looked at the code closely enough to be confident of
> changing something in this area.  However the classic solution to this
> kind of gc problem is to mark things that are manipulated during
> garbage collection as dirty (not orphaned).
> 
> It should be possible to fix this problem by simply changing gc_tree
> when we perform a problematic manipulation of a passed socket, such
> as installing a passed socket into the file descriptors of a process.
> 
> Essentially the idea is moving the current code in the direction of
> an incremental gc algorithm.
> 
> 
> If I understand the race properly.  What happens is that we dequeue
> a socket (which has packets in it passing sockets) before the
> garbage collector gets to it.  Therefore the garbage collector
> never processes that socket.  So it sounds like we just
> need to call maybe_unmark_and_push or possibly just wait for
> the garbage collector to complete when we do that and the packet
> we have pulled out 

Right.  But the devil is in the details, and (as you correctly point
out later) to implement this, the whole locking scheme needs to be
overhauled.  Problems:

 - Using the queue lock to make the dequeue and the fd detach atomic
   wrt the GC is difficult, if not impossible: they are are far from
   each other with various magic in between.  It would need thorough
   understanding of these functions and _big_ changes to implement.

 - Sleeping on u->readlock in GC is currently not possible, since that
   could deadlock with unix_dgram_recvmsg().  That function could
   probably be modified to release u->readlock, while waiting for
   data, similarly to unix_stream_recvmsg() at the cost of some added
   complexity.

 - Sleeping on u->readlock is also impossible, because GC is holding
   unix_table_lock for the whole operation.  We could release
   unix_table_lock, but then would have to cope with sockets coming
   and going, making the current socket iterator unworkable.

So theoretically it's quite simple, but it needs big changes.  And
this wouldn't even solve all the problems with the GC, like being a
possible DoS vector.

Miklos
