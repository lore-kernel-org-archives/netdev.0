From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [PATCH v2] net: handle error more gracefully in socketpair()
Date: Fri, 06 Dec 2013 11:10:55 +0100
Message-ID: <1386324655.18074.75.camel@localhost.localdomain>
References: <1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
	 <20131205.162333.1525865133149454763.davem@davemloft.net>
	 <1386285331.18074.47.camel@localhost.localdomain>
	 <20131205.194355.1677309681391704143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk, Yann Droneaud <ydroneaud@opteya.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131205.194355.1677309681391704143.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,=20

Le jeudi 05 d=C3=A9cembre 2013 =C3=A0 19:43 -0500, David Miller a =C3=A9=
crit :
> From: Yann Droneaud <ydroneaud@opteya.com>
> Date: Fri, 06 Dec 2013 00:15:31 +0100
>=20
> > AFAIK, using sys_close() seems to be the exception, and writing the=
 file
> > descriptor before installing it is the more or less the norm.
>=20
> What other system call in the kernel writes a file descriptor's value
> into the address space of a user process before the file descriptor
> is actually usable?
>=20

Some carefully chosen examples:

- recvmsg() through
  - netlink_recvmsg() / unix_dgram_recvmsg() / unix_stream_recvmsg()
  - scm_recv()
  - scm_detach_fds(), scm.c:280
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net=
/core/scm.c?id=3Dv3.13-rc2#n280
  - scm_detach_fds_compat(), compat.c:296
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net=
/compat.c?id=3Dv3.13-rc2#n296

- pipe() / pipe2(), pipe.c:969, through
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/=
pipe.c?id=3Dv3.13-rc2#n969
  - __do_pipe_flags, pipe.c:919
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/fs/=
pipe.c?id=3Dv3.13-rc2#n919


> That's really terrible semantically.

In fact, it's better:

1) get_unused_fd_flags() mark a file descriptor as 'reserved',
   so no other syscall would be able to allocate it.

   At this point, even if another userspace thread guess the correct
   file descriptor number, trying to use it will give it -EBADFD,
   since the file descriptor is not tied to a file (see __close_fd(),=20
   open.c:589 for example)

2) file descriptor is wrote in userspace memory, using=20
   put_user()/copy_to_user().

   At this point, the userspace (another thread) could potentially
   read the memory location and use the file descriptor, but here
   again, it will give -EBADFD for the very same reason.

3) fd_install() link the file descriptor to the file.

   Now, the userspace (another thread) could read the memory location
   and use the file descriptor even if the syscall which create it=20
   haven't return to the userspace caller yet.

If we arrange to put the call to fd_install() in the very last step
of the syscall, the window where the file descriptor is usable by
userspace but not yet validly returned to userspace is very tiny.

In the other hand, when writing the file descriptor in the last step,
eg. doing 1), 3) and 2), it makes possible for userspace to guess and
manipulate the file descriptor while the syscall is not near completion=
,
eg. kernel could have some things to do on the file, device, socket, ..=
=2E
before returning to userspace.
In such case, bad things might happen if another userspace thread is
trying to play a bad game with the file descriptor.
BTW I'm not aware of any security implication of this issue, but I thin=
k
it's better (safer) to have fd_install() being the very last step of a
syscall. It should be the default good habit when dealing with file
descriptor creation.

Regards.

--=20
Yann Droneaud
OPTEYA
