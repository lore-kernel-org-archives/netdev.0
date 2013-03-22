From: Paul Moore <paul@paul-moore.com>
Subject: Re: NULL pointer deref, selinux_socket_unix_may_send+0x34/0x90
Date: Fri, 22 Mar 2013 11:24:59 -0400
Message-ID: <2355680.noQDWa4NlY@sifl>
References: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart1815390.Zqp6h8ycja"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, eparis@redhat.com, sds@tycho.nsa.gov
To: =?utf-8?B?SsOhbiBTdGFuxI1law==?= <jan.stancek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:56209 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933109Ab3CVPZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:25:03 -0400
Received: by mail-ve0-f178.google.com with SMTP id db10so3400324veb.37
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 08:25:02 -0700 (PDT)
In-Reply-To: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart1815390.Zqp6h8ycja
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

On Thursday, March 21, 2013 11:19:22 PM J=C3=A1n Stan=C4=8Dek wrote:
> Hi,
>=20
> I'm occasionally seeing a panic early after system booted and while
> systemd is starting other services.
>=20
> I made a reproducer which is quite reliable on my system (32 CPU Inte=
l)
> and can usually trigger this issue within a minute or two. I can repr=
oduce
> this issue with 3.9.0-rc3 as root or unprivileged user (see call trac=
e
> below).
>=20
> I'm attaching my reproducer and (experimental) patch, which fixes the=

> issue for me.

Hi Jan,

I've heard some similar reports over the past few years but I've never =
been=20
able to reproduce the problem and the reporters have never show enough=20=

interest to be able to help me diagnose the problem.  Your information =
about=20
the size of the machine and the reproducer may help, thank you!

I'll try your reproducer but since I don't happen to have a machine han=
dy that=20
is the same size as yours would you mind trying the attached (also past=
ed=20
inline for others to comment on) patch?  I can't promise it will solve =
your=20
problem but it was the best idea I could come up with a few years ago w=
hen I=20
first became aware of the problem.  I think you are right in that there=
 is a=20
race condition somewhere with the AF_UNIX sockets shutting down, I'm ju=
st not=20
yet certain where it is ...

Thanks again.

net: fix some potential race issues in the AF_UNIX code

From: Paul Moore <pmoore@redhat.com>

At least one user had reported some odd behavior with UNIX sockets whic=
h
could be attributed to some _possible_ race conditions in
unix_release_sock().

Reported-by: Konstantin Boyandin <konstantin@boyandin.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/unix/af_unix.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..886b8da 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -408,8 +408,10 @@ static int unix_release_sock(struct sock *sk, int=20=

embrion)
 =09skpair =3D unix_peer(sk);
=20
 =09if (skpair !=3D NULL) {
-=09=09if (sk->sk_type =3D=3D SOCK_STREAM || sk->sk_type =3D=3D SOCK_SE=
QPACKET) {
-=09=09=09unix_state_lock(skpair);
+=09=09unix_state_lock(skpair);
+=09=09if (unix_our_peer(sk, skpair) &&
+=09=09    (sk->sk_type =3D=3D SOCK_STREAM ||
+=09=09     sk->sk_type =3D=3D SOCK_SEQPACKET)) {
 =09=09=09/* No more writes */
 =09=09=09skpair->sk_shutdown =3D SHUTDOWN_MASK;
 =09=09=09if (!skb_queue_empty(&sk->sk_receive_queue) || embrion)
@@ -417,9 +419,10 @@ static int unix_release_sock(struct sock *sk, int=20=

embrion)
 =09=09=09unix_state_unlock(skpair);
 =09=09=09skpair->sk_state_change(skpair);
 =09=09=09sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
-=09=09}
-=09=09sock_put(skpair); /* It may now die */
+=09=09} else
+=09=09=09unix_state_unlock(skpair);
 =09=09unix_peer(sk) =3D NULL;
+=09=09sock_put(skpair); /* It may now die */
 =09}
=20
 =09/* Try to flush out this socket. Throw out buffers at least */


--=20
paul moore
www.paul-moore.com

--nextPart1815390.Zqp6h8ycja
Content-Disposition: attachment; filename="unix-race_fix.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="ISO-8859-1"; name="unix-race_fix.patch"

net: fix some potential race issues in the AF_UNIX code

From: Paul Moore <pmoore@redhat.com>

At least one user had reported some odd behavior with UNIX sockets which
could be attributed to some _possible_ race conditions in
unix_release_sock().

Reported-by: Konstantin Boyandin <konstantin@boyandin.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/unix/af_unix.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..886b8da 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -408,8 +408,10 @@ static int unix_release_sock(struct sock *sk, int embrion)
 	skpair = unix_peer(sk);
 
 	if (skpair != NULL) {
-		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
-			unix_state_lock(skpair);
+		unix_state_lock(skpair);
+		if (unix_our_peer(sk, skpair) &&
+		    (sk->sk_type == SOCK_STREAM ||
+		     sk->sk_type == SOCK_SEQPACKET)) {
 			/* No more writes */
 			skpair->sk_shutdown = SHUTDOWN_MASK;
 			if (!skb_queue_empty(&sk->sk_receive_queue) || embrion)
@@ -417,9 +419,10 @@ static int unix_release_sock(struct sock *sk, int embrion)
 			unix_state_unlock(skpair);
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
-		}
-		sock_put(skpair); /* It may now die */
+		} else
+			unix_state_unlock(skpair);
 		unix_peer(sk) = NULL;
+		sock_put(skpair); /* It may now die */
 	}
 
 	/* Try to flush out this socket. Throw out buffers at least */

--nextPart1815390.Zqp6h8ycja--
