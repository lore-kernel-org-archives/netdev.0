From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Regression on behavior of EPOLLET | EPOLLIN for AF_UNIX
 sockets in 3.2
Date: Fri, 27 Jan 2012 20:44:55 +0100
Message-ID: <1327693495.3159.10.camel@edumazet-laptop>
References: <CAKDKvuzH14AZjDG3WSdrf5VtmiUgG0Y+EaC83qqSd0VFKzyitg@mail.gmail.com>
	 <1327686822.3159.3.camel@edumazet-laptop> <4F22EA24.3030901@parallels.com>
	 <1327690506.3159.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Mathewson <nickm@freehaven.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Moiseytsev <himeraster@gmail.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327690506.3159.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 27 janvier 2012 =C3=A0 19:55 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 27 janvier 2012 =C3=A0 22:17 +0400, Glauber Costa a =C3=A9=
crit :
> > On 01/27/2012 09:53 PM, Eric Dumazet wrote:
> > > Le vendredi 27 janvier 2012 =C3=A0 12:05 -0500, Nick Mathewson a =
=C3=A9crit :
> > >> [1.] One line summary of the problem:
> > >>
> > >
> > > Hi
> > >
> > > Probably coming from commit 0884d7aa24e15e72b3c07f7da910a13bb7df3=
592
> > > (AF_UNIX: Fix poll blocking problem when reading from a stream so=
cket)
> > >
> > > When we requeue skb because not completely eaten, we call again
> > >
> > > sk->sk_data_ready(sk, skb->len);
> > >
> > For the record, I just confirmed this to be the case.
>=20
> A fix would be to change unix_poll() and not call sk_data_ready() whe=
n
> skb is requeued.
>=20
> if (!skb_queue_empty(&sk->sk_receive_queue))
> 	mask |=3D POLLIN | POLLRDNORM;
>=20
> Might be tricky if we want to keep unix_poll() lockless, but quite
> possible.
>=20
> Or... not dequeue skb from sk_received_queue unless fully consumed.
>=20

I am testing following patch :

 net/unix/af_unix.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aad8fb6..6eca195 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1918,7 +1918,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb=
, struct socket *sock,
 		struct sk_buff *skb;
=20
 		unix_state_lock(sk);
-		skb =3D skb_dequeue(&sk->sk_receive_queue);
+		skb =3D skb_peek(&sk->sk_receive_queue);
 		if (skb =3D=3D NULL) {
 			unix_sk(sk)->recursion_level =3D 0;
 			if (copied >=3D target)
@@ -1959,8 +1959,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb=
, struct socket *sock,
 			/* Never glue messages from different writers */
 			if ((UNIXCB(skb).pid  !=3D siocb->scm->pid) ||
 			    (UNIXCB(skb).cred !=3D siocb->scm->cred)) {
-				skb_queue_head(&sk->sk_receive_queue, skb);
-				sk->sk_data_ready(sk, skb->len);
 				break;
 			}
 		} else {
@@ -1977,8 +1975,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb=
, struct socket *sock,
=20
 		chunk =3D min_t(unsigned int, skb->len, size);
 		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
-			skb_queue_head(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
 			if (copied =3D=3D 0)
 				copied =3D -EFAULT;
 			break;
@@ -1993,13 +1989,10 @@ static int unix_stream_recvmsg(struct kiocb *io=
cb, struct socket *sock,
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
=20
-			/* put the skb back if we didn't use it up.. */
-			if (skb->len) {
-				skb_queue_head(&sk->sk_receive_queue, skb);
-				sk->sk_data_ready(sk, skb->len);
+			if (skb->len)
 				break;
-			}
-
+		=09
+			skb_unlink(skb, &sk->sk_receive_queue);
 			consume_skb(skb);
=20
 			if (siocb->scm->fp)
@@ -2010,9 +2003,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb=
, struct socket *sock,
 			if (UNIXCB(skb).fp)
 				siocb->scm->fp =3D scm_fp_dup(UNIXCB(skb).fp);
=20
-			/* put message back and return */
-			skb_queue_head(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
 			break;
 		}
 	} while (size);
