From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 15:45:28 -0800
Message-ID: <45663298.7000108@redhat.com>
References: <11641265982190@2ka.mipt.ru> <456621AC.7000009@redhat.com> <45662522.9090101@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40655 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757504AbWKWXqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 18:46:10 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45662522.9090101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Considering current designs, it seems more likely that a single threa=
d=20
> polls for socket activity, then dispatches work.  How often do you=20
> really see in userland multiple threads polling the same set of fds,=20
> then fighting to decide who will handle raised events?
>=20
> More likely, you will see "prefork" (start N threads, each with its o=
wn=20
> ring) or a worker pool (single thread receives events, then dispatche=
s=20
> to multiple threads for execution) or even one-thread-per-fd (single=20
> thread receives events, then starts new thread for handling).

No, absolutely not.  This is exactly not what should/is/will happen.

You create worker threads to handle to work for the entire program.=20
Look at something like a web server.  When creating several queues, how=
=20
do you distribute all the connections to the different queues?  To=20
ensure every connection is handled as quickly as possible you stuff the=
m=20
all in the same queue and then have all threads use this one queue.=20
Whenever an event is posted a thread is woken.  _One_ thread.  If two=20
events are posted, two threads are woken.  In this situation we have a=20
few atomic ops at userlevel to make sure that the two threads don't pic=
k=20
the same event but that's all there is wrt "fighting".

The alternative is the sorry state we have now.  In nscd, for instance,=
=20
we have one single thread waiting for incoming connections and it then=20
has to wake up a worker thread to handle the processing.  This is done=20
because we cannot "park" all threads in the accept() call since when a=20
new connection is announced _all_ the threads are woken.  With the new=20
event handling this wouldn't be the case, one thread only is woken and=20
we don't have to wake worker threads.  All threads can be worker thread=
s.


> If you have multiple threads accessing the same ring -- a poor design=
=20
> choice

To the contrary.  It is the perfect means to distribute the workload to=
=20
multiple threads.  Beside, how would you implement asynchronous filling=
=20
of the ring buffer to avoid unnecessary syscalls if you have many=20
different queues?


> -- I would think the burden should be on the application, to=20
> provide proper synchronization.

Sure, as much as possible.  But there is no reason to design the commit=
=20
interface in the way which requires expensive synchronization when ther=
e=20
is another design which can do exactly the same work but does not=20
require synchronization.  The currently proposed kevent_commit and my=20
proposed variant are functionally equivalent.


> If the desire is to have the kernel distributes events directly to=20
> multiple threads, then the app should dup(2) the fd to be watched, an=
d=20
> create a ring buffer for each separate thread.

And how would you synchronize the file descriptor use across the=20
threads?  The event would be sent to all the event queues so that you=20
would a) unnecessarily wake all threads and b) have all but one thread=20
see the operation (say, read or write on a socket) fail with=20
EWOULDBLOCK.  That's just silly, we can have that today and continue to=
=20
waste precious CPU cycles.

If you say that you post exactly one event per file description (not=20
handle) then what do you do if the programmer wants the opposite?  And=20
again, what do you do for asynchronous ring buffer filling.  Which queu=
e=20
do you pick?  Pick the wrong one and the event might be in the ring=20
buffer for a long time which another thread handling another queue is r=
eady.

Using a single central queue is the perfect means to distribute the loa=
d=20
to a number of threads.  Nobody is forcing you to do it, you're free to=
=20
use separate queues if you want.  But the model should not enforce this=
=2E


Overall, I cannot see at all where your problem is.  I agree that the=20
synchronization of the access to the ring buffer must be done at=20
userlevel.  This is why the uidx exposure isn't needed.  The wakeup in=20
any case has to take threads into account.  The only change I proposed=20
to enable better multi-thread handling is the revised commit interface=20
and this change in no way hinders single-threaded users.  The interface=
=20
is not hindered in any way or form by the use of threads.

Oh, and when I say "threads" I should have said "threads or processes".=
=20
  The whole also applies to multi-process applications.  They can share=
=20
event queues by placing them in shared memory.  And I hope that everyon=
e=20
agrees that programs have to go into the direction of having more than=20
one execution context to take advantage of increased CPU power in=20
future.  CMP is only becoming more and more important.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
