From: David Miller <davem@davemloft.net>
Subject: Killing sk->sk_callback_lock (was Re: [PATCH] net/core/sock.c
 remove extra wakeup)
Date: Wed, 11 Jun 2008 02:16:42 -0700 (PDT)
Message-ID: <20080611.021642.217166694.davem@davemloft.net>
References: <483F990C0200005A00038001@sinclair.provo.novell.com>
	<E1K6K60-00061s-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: GHaskins@novell.com, PMullaney@novell.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753526AbYFKJQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 05:16:43 -0400
In-Reply-To: <E1K6K60-00061s-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 11 Jun 2008 16:46:12 +1000

> Anyway, you've lost me with this scenario.  The patch is stopping
> wake-ups on the write path yet you're talking about the read path.
> So my question is why are you getting the extra wake-up on that
> write path when you receive a packet?

During a short discussion on IRC with Herbert I explained
that indeed it's the write wakeup path that's causing the
issue here and we both agreed that the cost is likely
simply from the sk->sk_callback_lock and not the wakeups
themselves.  Once the first wakeup happens, the wait
queues should be inactive and the task awake already.

The sk->sk_callback_lock is a pile of mud that has existed since
around 1999 when we initially SMP threaded the networking stack.
It's long overdue to kill this thing, because for the most part it
is superfluous.

So I just sat for a bit and compiled some notes about the situation
and how we can move forward on this.  If I get some energy I will
attack this task some time soon:

--------------------

Deletion of sk->sk_callback_lock.

This lock is overloaded tremendously to protect several aspects of
socket state, most of which is superfluous and can be eliminated.

One aspect protected by this lock is the parent socket to child sock
relationship.  It makes sure that both the waitqueue and socket
pointer are updated atomically wrt. threads executing the sock
callbacks such as sk->sk_write_space().

A seperate lock was needed for this because socket callbacks can be
invoked asynchronously in softirq context via kfree_skb() and
therefore the socket lock would not be suitable for this purpose.

Basically, for this usage, all the callback cares about is that the
sk->sk_socket and sk->sk_sleep point to stable items.  Fortunately we
can ensure this by simply never letting these two things point to
NULL.  Instead we can point them at dummy waitqueue and socket objects
when there is no real parent currently associated with the sock.

This would allow large amounts of callback code to run lockless.  For
example, sock_def_write_space() would most not need the
sk_callback_lock held.  The exception being sk_wake_async()
processing.

sk_wake_async() uses the callback lock to guard the state of the
socket's fasync list.  It is taken as a reader for scanners, and taken
as a writer for thread paths which add entries to the fasync list.

These locking schemes date back to 1999 as indicated by comments above
sock_fasync().

To be honest, fasync usage is rare.  It's a way to register processes
which will receive SIGIO signals during IO events.  The generic fasync
code fs/fcntl.c:kill_fasync() uses a global lock for list protection
and nobody has noticed.  But we should be careful for this observation
because the other uses of fasync handling are devices like input
(keyboards, mice) and TTY devices.

If the "fasync on sockets is rare" observation is accurate, we could
simply use fasync_helper() and kill_fasync() to implement the
necessary locking.

Also, fasync is how SIGURG is implemented, again another rarely used
feature of sockets.

The next layer of (mis-)use of the sk_callback_lock are mis-level
protocol layers that sit on top of real protocol stacks.  For example
sunrpc and iscsi.  These subsystems want to override the socket
callbacks so that they can do data-ready etc. processing directly or
with modified behavior.

Typically these code bases stack away the callbacks they override so
that when they are done with the socket they restore those pointers.
During this "callback pointer swap" they hold the sk_callback_lock,
which on the surface seems pretty pointless since this does not
protect other threads of execution from invoking these callbacks.

SUNRPC also seems to use the sk->sk_callback_lock to stabilize the
state of the sk->sk_user_data pointer in the XPRT socket layer.  It
also has an xprt->shutdown state which is tested additionally to the
NULL'ness of the sk->sk_user_data XPRT pointer.  A seperate
xprt->transport_lock synchornizes the processing of incoming packets
for a given XID session, so the sk_callback_lock isn't needed for that
purpose.

sock_orphan() and sock_graft(), in include/net/sock.h, are the main
transition points of the parent socket relationship state.
Unfortunately, not all protocols use these helper routines
consistently.  In particular the radio protocols (ax25, etc.), IPX,
ECONET, and some others do this work by hand and in particular without
holding the sk->sk_callback_lock.

This should be consolidated so that the protocols do this stuff
consistently.  It also points us to the crummy SOCK_DEAD state bit we
have.  Really, all of the things guarded by SOCK_DEAD are totally
harmless if we point sk->sk_socket and sk->sk_sleep to dummy objects
instead of NULL.  So, there is strong evidence that SOCK_DEAD could be
eliminated.

Also, this lack of consistent usage of sock_orphan() and sock_graft()
means that some protocols are not invoking security_sock_graft()
properly.

So likely the first task in all of this is to get the protocol
to use sock_orphan() and sock_graft() across the board without
any exceptions.

At this point we can build dummy socket and wait queue objects that
sock allocation and sock_orphan() can point to.  I believe at this
point that sk_callback_lock acquisition can be removed from
sock_orphan() and sock_graft().

Next, we convert the fasync bits to use the global fasync_lock
via the helper functions fasync_helper() and kill_fasync() in
fs/fcntl.c instead of the per-socket locking, by-hand list insertion,
and __kill_fasync() invocations the socket layer uses currently.

Now, it should be possible to entirely remove the sk_callback_lock
grabs in the sock callbacks.

The rest of the work is composed of walking over the socket
wrapping layers such as SUNRPC, OCFS, and ISCSI and auditing
their sk_callback_lock usage, trying to eliminate the lock as
much as possible.  The unconvertable parts are probably replacable
with subsystem local object locks.

It should be possible to delete sk->sk_callback_lock at that point.
Killing SOCK_DEAD could be a followon task.
