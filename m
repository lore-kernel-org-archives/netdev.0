From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 01:48:32 +0100
Message-ID: <45664160.6060504@cosmosbay.com>
References: <11641265982190@2ka.mipt.ru> <456621AC.7000009@redhat.com> <45662522.9090101@garzik.org> <45663298.7000108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:16513 "EHLO
	gw1.cosmosbay.com") by vger.kernel.org with ESMTP id S1757527AbWKXAtG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 19:49:06 -0500
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <45663298.7000108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Drepper a =C3=A9crit :
>=20
> You create worker threads to handle to work for the entire program. L=
ook=20
> at something like a web server.  When creating several queues, how do=
=20
> you distribute all the connections to the different queues?  To ensur=
e=20
> every connection is handled as quickly as possible you stuff them all=
 in=20
> the same queue and then have all threads use this one queue. Whenever=
 an=20
> event is posted a thread is woken.  _One_ thread.  If two events are=20
> posted, two threads are woken.  In this situation we have a few atomi=
c=20
> ops at userlevel to make sure that the two threads don't pick the sam=
e=20
> event but that's all there is wrt "fighting".
>=20
> The alternative is the sorry state we have now.  In nscd, for instanc=
e,=20
> we have one single thread waiting for incoming connections and it the=
n=20
> has to wake up a worker thread to handle the processing.  This is don=
e=20
> because we cannot "park" all threads in the accept() call since when =
a=20
> new connection is announced _all_ the threads are woken.  With the ne=
w=20
> event handling this wouldn't be the case, one thread only is woken an=
d=20
> we don't have to wake worker threads.  All threads can be worker thre=
ads.

Having one specialized thread handling the distribution of work to work=
er=20
threads is better most of the time. This thread can be a worker thread =
by=20
itself (to avoid context switchs), but can decide to wake up 'slave thr=
eads'=20
if he believes it has too (for example if he can notice that a *lot* of=
=20
requests are pending)

This is because with moderate load, it's better to have only one CPU ru=
nning=20
80% of its time, keeping its cache hot, than 'distribute' the work on f=
our=20
CPU, that would be used 25% of their time, but with lot of cache line p=
ing=20
pongs and poor cache reuse.

If you let 'kevent'/'dumb kernel dispatcher'/'futex'/'whatever' decide =
to wake=20
up one thread for each new event, you *may* have lower performance, bec=
ause of=20
higher system overhead (system means : system scheduler/internals, but =
also=20
bus trafic)
  Only the application writer can have a clue of average use of its wor=
ker=20
threads, and can decide to dynamically adjust parameters if needed to h=
andle=20
load spikes.

SMP machines are nice, but for many workloads, it's better to avoid spr=
eading=20
a working set on several CPUS that fight for common resources (memory).


Back to 'kevent':
-----------------
I think that having a syscall to commit events should not be mandatory.=
 A=20
syscall is needed only to wait for new events if the ring is empty. But=
 then=20
maybe we dont need yet a new syscall to perform a wait :
We already have nice synchronisations primitives (futex for example).

User program should be able to update a 'uidx' in user space (using ato=
mic ops=20
only if multi-threaded), and could just use futex infrastructure if rin=
g=20
buffer is empty (uidx =3D=3D kidx) , and call FUTEX_WAIT( &kidx, curren=
t value =3D uidx)

I think I already gave my opinion on a ring buffer, but let just rephra=
se it :

One part should be read/write for application (to be able to change uid=
x)
(or User app just give at init time to kernel the address of a futex in=
 its vm=20
space)

One part could be read only for application (but could be read/write : =
we dont=20
care if user application is stupid) : kernel writes its kidx (or a copy=
 of it)=20
and events.

=46or best performance, uidx and kidx should be on different cache line=
s (basic=20
isolation of producer / consumer)

When kernel wants to queue a new event in a ring buffer it can :

See if user program did consume some events since last invocation (kern=
el=20
fetches uidx and compare it with its own uidx value : no syscall needed=
)
Check if a slot is available in ring buffer.
Copy the event in ring buffer, perform a memory barrier, then increment=
 kidx.
call futex_wake(&kidx, 1 thread)

User application is free to have one thread/process or several=20
threads/processes waiting for new events (or even no thread at all :) )

Eric

