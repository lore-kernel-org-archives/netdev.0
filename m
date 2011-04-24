From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] af_unix: Only allow recv on connected seqpacket sockets.
Date: Sun, 24 Apr 2011 04:54:57 -0700
Message-ID: <m1sjt7sw32.fsf_-_@fess.ebiederm.org>
References: <BANLkTi=zSJAXYa8Vo8rZKgs9C-AfbjjEpA@mail.gmail.com>
	<m1zkngse02.fsf@fess.ebiederm.org>
	<BANLkTimrOs2T_bnbSJDgppAAh_MUWt_erg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>, Dan Aloni <dan@aloni.org>,
	stable@kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40718 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756598Ab1DXLzD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 07:55:03 -0400
In-Reply-To: <BANLkTimrOs2T_bnbSJDgppAAh_MUWt_erg@mail.gmail.com> (Dan Aloni's
	message of "Sun, 24 Apr 2011 09:36:13 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes the following oops discovered by Dan Aloni:
> Anyway, the following is the output of the Oops that I got on the
> Ubuntu kernel on which I first detected the problem
> (2.6.37-12-generic). The Oops that followed will be more useful, I
> guess.

>[ 5594.669852] BUG: unable to handle kernel NULL pointer dereference
> at =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null)
> [ 5594.681606] IP: [<ffffffff81550b7b>] unix_dgram_recvmsg+0x1fb/0x42=
0
> [ 5594.687576] PGD 2a05d067 PUD 2b951067 PMD 0
> [ 5594.693720] Oops: 0002 [#1] SMP
> [ 5594.699888] last sysfs file:

The bug was that unix domain sockets use a pseduo packet for
connecting and accept uses that psudo packet to get the socket.
In the buggy seqpacket case we were allowing unconnected
sockets to call recvmsg and try to receive the pseudo packet.

That is always wrong and as of commit 7361c36c5 the pseudo
packet had become enough different from a normal packet
that the kernel started oopsing.

Do for seqpacket_recv what was done for seqpacket_send in 2.5
and only allow it on connected seqpacket sockets.

Cc: stable@kernel.org
Tested-by: Dan Aloni <dan@aloni.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/unix/af_unix.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3a43a83..b1d75be 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -524,6 +524,8 @@ static int unix_dgram_connect(struct socket *, stru=
ct sockaddr *,
 			      int, int);
 static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
 				  struct msghdr *, size_t);
+static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
+				  struct msghdr *, size_t, int);
=20
 static const struct proto_ops unix_stream_ops =3D {
 	.family =3D	PF_UNIX,
@@ -583,7 +585,7 @@ static const struct proto_ops unix_seqpacket_ops =3D=
 {
 	.setsockopt =3D	sock_no_setsockopt,
 	.getsockopt =3D	sock_no_getsockopt,
 	.sendmsg =3D	unix_seqpacket_sendmsg,
-	.recvmsg =3D	unix_dgram_recvmsg,
+	.recvmsg =3D	unix_seqpacket_recvmsg,
 	.mmap =3D		sock_no_mmap,
 	.sendpage =3D	sock_no_sendpage,
 };
@@ -1699,6 +1701,18 @@ static int unix_seqpacket_sendmsg(struct kiocb *=
kiocb, struct socket *sock,
 	return unix_dgram_sendmsg(kiocb, sock, msg, len);
 }
=20
+static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *s=
ock,
+			      struct msghdr *msg, size_t size,
+			      int flags)
+{
+	struct sock *sk =3D sock->sk;
+
+	if (sk->sk_state !=3D TCP_ESTABLISHED)
+		return -ENOTCONN;
+
+	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
+}
+
 static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
 {
 	struct unix_sock *u =3D unix_sk(sk);
--=20
1.6.5.2.143.g8cc62

