From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 04:49:50 +0100
Message-ID: <20151021034950.GL22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46283 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbbJUDtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 23:49:55 -0400
Content-Disposition: inline
In-Reply-To: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 06:45:32PM -0700, Eric Dumazet wrote:
> On Tue, 2015-10-20 at 02:12 +0100, Alan Burlison wrote:
>=20
> > Another problem is that if I call close() on a Linux socket that's =
in=20
> > accept() the accept call just sits there until there's an incoming=20
> > connection, which succeeds even though the socket is supposed to be=
=20
> > closed, but then an immediately following accept() on the same sock=
et=20
> > fails.=20
>=20
> This is exactly what the comment I pasted documents.
>=20
> On linux, doing close(listener) on one thread does _not_ wakeup other
> threads doing accept(listener)
>=20
> So I guess allowing shutdown(listener) was a way to somehow propagate
> some info on the threads stuck in accept()
>=20
> This is a VFS issue, and a long standing one.
>=20
> Think of all cases like dup() and fd passing games, and the close(fd)
> being able to signal out of band info is racy.
>=20
> close() is literally removing one ref count on a file.

> Expecting it doing some kind of magical cleanup of a socket is not
> reasonable/practical.
>=20
> On a multi threaded program, each thread doing an accept() increased =
the
> refcount on the file.

Refcount is an implementation detail, of course.  However, in any Unix =
I know
of, there are two separate notions - descriptor losing connection to op=
ened
file (be it from close(), exit(), execve(), dup2(), etc.) and opened fi=
le
getting closed.

The latter cannot happen while there are descriptors connected to the
file in question, of course.  However, that is not the only thing
that might prevent an opened file from getting closed - e.g. sending an
SCM_RIGHTS datagram with attached descriptor connected to the opened fi=
le
in question *at* *the* *moment* *of* *sendmsg(2)* will carry said opene=
d
file until it is successfully received or discarded (in the former case
recepient will get a new descriptor refering to that opened file, of co=
urse).
Having the original descriptor closed right after sendmsg(2) does *not*
do anything to opened file.  On any Unix that implements descriptor-pas=
sing.

There's going to be a notion of "last close"; that's what this refcount=
 is
about and _that_ is more than implementation detail.

The real question is what kind of semantics would one want in the follo=
wing
situations:

1)
// fd is a socket
fcntl(fd, F_SETFD, FD_CLOEXEC);
fork();
in parent: accept(fd);
in child: execve()

2)
// fd is a socket, 1 is /dev/null
fork();
in parent: accept(fd);
in child: dup2(1, fd);

3)
// fd is a socket
fd2 =3D dup(fd);
in thread A: accept(fd);
in thread B: close(fd);

4)
// fd is a socket, 1 is /dev/null
fd2 =3D dup(fd);
in thread A: accept(fd);
in thread B: dup2(1, fd);

5)
// fd is a socket, 1 is /dev/null
fd2 =3D dup(fd);
in thread A: accept(fd);
in thread B: close(fd2);

6)
// fd is a socket
in thread A: accept(fd);
in thread B: close(fd);

In other words, is that destruction of
	* any descriptor refering to this socket [utterly insane for obvious
reasons]
	* the last descriptor refering to this socket (modulo descriptor
passing, etc.) [a bitch to implement, unless we treat a syscall in prog=
ress
as keeping the opened file open], or
	* _the_ descriptor used to issue accept(2) [a bitch to implement,
with a lot of fun races in an already race-prone area]?
Additional question is whether it's
	* just a magical behaviour of close(2) [ugly], or
	* something that happens when descriptor gets dissociated from
opened file [obviously more consistent]?

BTW, for real fun, consider this:
7)
// fd is a socket
fd2 =3D dup(fd);
in thread A: accept(fd);
in thread B: accept(fd);
in thread C: accept(fd2);
in thread D: close(fd);

Which threads (if any), should get hit where it hurts?

I honestly don't know what Solaris does; AFAICS, FreeBSD behaves like L=
inux
these days.  NetBSD plays really weird games in their fd_close(); what
they are trying to achieve is at least sane - in (7) they'd hit A and B=
 with
EBADF and C would restart and continue waiting, in (3,4,6) A gets EBADF=
,
in (1,2,5) accept() is unaffected.  The problem is that their solution =
is
racy - they have a separate refcount on _descriptor_, plus a file metho=
d
(->fo_restart) for triggering an equivalent of signal interrupting anyt=
hing
that might be blocked on that sucker, with syscall restart (and subsequ=
ent
EBADF on attempt to refetch the sucker.  Racy if we reopen or are doing=
 dup2()
in the first place - these restarts might get CPU just after we return =
from
dup2() and pick the *new* descriptor just fine.  It might be possible t=
o fix
their approach (having
        if (__predict_false(ff->ff_file =3D=3D NULL)) {
                /*
                 * Another user of the file is already closing, and is
                 * waiting for other users of the file to drain.  Relea=
se
                 * our reference, and wake up the closer.
                 */
                atomic_dec_uint(&ff->ff_refcnt);
                cv_broadcast(&ff->ff_closing);
path in fd_close() mark the thread as "don't bother restarting, just bu=
gger
off" might be workable), but... it's still pretty costly.  They
pay with memory footprint (at least 32 bits per descriptor, and that's
leaving aside the fun issues with what to wait on) and the only thing t=
hat
might be saving them from cacheline ping-pong from hell is that their
struct fdfile is really=A0fat - there's a lot more than just an extra
u32 in there.

I have no idea what semantics does Solaris have in that area and how ra=
cy
their descriptor table handling is.  And no, I'm not going to RTFS thei=
r
kernel, CDDL being what it is.  I *do* know that Linux and all *BSD ker=
nels
had pretty severe races in that area.  Quite a few of those, and a lot =
more
painful than the one RTFS(NetBSD) seems to have caught just now.  So I =
would
seriously recommend the folks who are free to RTFS(Solaris) to review t=
hat
area.  Carefully.  There tend to be dragons.

_IF_ somebody can come up with clean semantics and tolerable approach t=
o
implementing it, I'd be glad to see that.  What we do is "syscall
in progress keeps the file it operates upon open, no matter what happen=
s to
descriptors".  AFAICS, what NetBSD tries to implement is also reasonabl=
y
clean wrt semantics ("detaching an opened file from a descriptor that
is being operated upon by some syscalls triggers restart or failure of =
all
syscalls operating on the opened file in question and waits for them
to bugger off", but their implementation appears to be both racy and fa=
r too
heavyweight, with no obvious solutions to the latter.

Come to think of that, restart-based solutions have an obvious problem =
-
if we were talking about restart due to signal, the userland code could
(and would have to) block those, just to avoid this kind of issues with
the wrong descriptor picked on restart.  But there's no way to block _t=
hat_,
so if you have two descriptors refering to the same socket and 4 thread=
s doing
A: sleeps in accept(fd1)
B: sleeps in accept(fd2)
C: close(fd1)
D: (with all precautions re signals taken by the whole thing) dup2(fd3,=
 fd2)
you can end up with C coming first, kicking A and B (as operating on th=
at
socket) with A legitimately failing and B going into restart.  And losi=
ng
CPU to D, which does that dup2(), so when B regains CPU it's operating =
on
the socket it never intended to.  So this approach seems to be broken, =
no
matter what...
