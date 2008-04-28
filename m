From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [PATCH] paccept, socket, socketpair w/flags
Date: Mon, 28 Apr 2008 08:13:31 -0700
Message-ID: <4815E99B.2010903@redhat.com>
References: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com>	 <517f3f820804280252h753c8cacv7fe9580f96dcf1ce@mail.gmail.com>	 <4815DB8B.7060606@redhat.com> <cfd18e0f0804280751x21833b51y4b1f6f7ce3201d0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Michael Kerrisk <mtk.manpages@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935532AbYD1POR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 11:14:17 -0400
In-Reply-To: <cfd18e0f0804280751x21833b51y4b1f6f7ce3201d0d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Michael Kerrisk wrote:
> You have said it would be cleaner to have new syscalls for socket()
> and socketpair().  I understand your reasoning for that to be that
> doing so is cleaner than overloading the type argument of the existin=
g
> versions of these syscalls.  I agree.  So, since you are adding new
> syscalls for all of the other interfaces, why not do it for these two
> syscalls also?

If the range of the existing parameter can indeed be restricted as
needed for the flags it is the better approach for programmers since al=
l
that is needed for a programmer to do is to write


   fd =3D socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, 0);
   if (fd =3D=3D -1 && errno =3D=3D EINVAL)
     {
       fd =3D socket(PF_INET, SOCK_STREAM, 0);
       if (fd !=3D -1)
         fcntl(fd, F_SETFD, FD_CLOEXEC);
     }

No autoconf code needed to detect the presence of a new function.  You
can even imagine that convenience libraries will do the above
automatically (not libc, though, where you want to recognize this
situation).


> Okay -- I see your point (and I didn't read your patches closely
> enough).  However, the rationale for the implementations proposed to
> date isn't very clear.  So far we have the following new flags:
>=20
> timerfd_create() -- TFD_CLOEXEC
> signalfd4() -- SFD_CLOEXEC
> eventfd2() -- EFD_CLOEXEC
> epoll_create2() -- EPOLL_CLOEXEC
> open() (and openat()), dup3() -- all use O_CLOEXEC
> socketpair(), socket(), paccept -- all use SOCK_CLOEXEC
> pipe2() -- to be determined

Use O_CLOEXEC, normal filesystem operation.

> inotify_init2() -- to be determined

New flag.


> It would help if you laid out your reasoning for creating distinct
> flags for some syscalls but not others.  For example, is the
> assumption here that socketpair(), socket(), and paccept() will alway=
s
> use the same set of flags?

Yes, they are all related interfaces.  Using the same name indicates
similarity.


And just to complicate things even more:

if we'd go with sys_indirect we can have single way to specify
close-on-exec for all syscalls.  That would be at the syscall level.  A=
t
the API level we'd still need separate names and possibly values.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIFemb2ijCOnn/RHQRAjNCAJ0QCvEJoynwbPveUZQqsyVnEAHtmgCZAe0R
jNlcvQFI06n2ckFhEqUcEbE=3D
=3DsJhN
-----END PGP SIGNATURE-----
