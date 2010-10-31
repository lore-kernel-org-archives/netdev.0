From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for EPOLLOUT
 event
Date: Sun, 31 Oct 2010 16:36:23 +0100
Message-ID: <1288539383.2660.38.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <20101030123403.5e01540d@chocolatine.cbg.collabora.co.uk>
	 <1288443217.2680.962.camel@edumazet-laptop>
	 <1288444678.2680.966.camel@edumazet-laptop>
	 <20101030224703.065e70f6@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Davide Libenzi <davidel@xmailserver.org>
To: Alban Crequy <alban.crequy@collabora.co.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030Ab0JaPga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 11:36:30 -0400
Received: by wyf28 with SMTP id 28so4696012wyf.19
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 08:36:28 -0700 (PDT)
In-Reply-To: <20101030224703.065e70f6@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 30 octobre 2010 =C3=A0 22:47 +0100, Alban Crequy a =C3=A9crit=
 :
> Le Sat, 30 Oct 2010 15:17:58 +0200,
> Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :
>=20
> > > Problem is the peer_wait, that epoll doesnt seem to be plugged in=
to.
> > >=20
> > > Bug is in unix_dgram_poll()
> > >=20
> > > It calls sock_poll_wait( ... &unix_sk(other)->peer_wait,) only if
> > > socket is 'writable'. Its a clear bug
>=20
> Yes, it looks weird...
>=20
> > > Try this patch please ?
>=20
> I will be away from computer and I will continue to work on this from
> the 20th of November.

OK, no problem. I tried it and it solves the problem. Here is an
official patch submission.

David, for your convenience, I cooked a patch serie for the 2 patches
against af_unix unix_dgram_poll().

The third patch (af_unix: unix_write_space() use keyed wakeups)) can be
applied as is.

Thanks !

[PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for EPOLLOUT event

Alban Crequy reported a problem with connected dgram af_unix sockets an=
d
provided a test program. epoll() would miss to send an EPOLLOUT event
when a thread unqueues a packet from the other peer, making its receive
queue not full.

This is because unix_dgram_poll() fails to call sock_poll_wait(file,
&unix_sk(other)->peer_wait, wait);
if the socket is not writeable at the time epoll_ctl(ADD) is called.=20

We must call sock_poll_wait(), regardless of 'writable' status, so that
epoll can be notified later of states changes.

Misc: avoids testing twice (sk->sk_shutdown & RCV_SHUTDOWN)

Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
Cc: Davide Libenzi <davidel@xmailserver.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/unix/af_unix.c |   24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0ebc777..7375131 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2072,13 +2072,12 @@ static unsigned int unix_dgram_poll(struct file=
 *file, struct socket *sock,
 	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |=3D POLLERR;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
-		mask |=3D POLLRDHUP;
+		mask |=3D POLLRDHUP | POLLIN | POLLRDNORM;
 	if (sk->sk_shutdown =3D=3D SHUTDOWN_MASK)
 		mask |=3D POLLHUP;
=20
 	/* readable? */
-	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sk->sk_shutdown & RCV_SHUTDOWN))
+	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |=3D POLLIN | POLLRDNORM;
=20
 	/* Connection-based need to check for termination and startup */
@@ -2090,20 +2089,15 @@ static unsigned int unix_dgram_poll(struct file=
 *file, struct socket *sock,
 			return mask;
 	}
=20
-	/* writable? */
 	writable =3D unix_writable(sk);
-	if (writable) {
-		other =3D unix_peer_get(sk);
-		if (other) {
-			if (unix_peer(other) !=3D sk) {
-				sock_poll_wait(file, &unix_sk(other)->peer_wait,
-					  wait);
-				if (unix_recvq_full(other))
-					writable =3D 0;
-			}
-
-			sock_put(other);
+	other =3D unix_peer_get(sk);
+	if (other) {
+		if (unix_peer(other) !=3D sk) {
+			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
+			if (unix_recvq_full(other))
+				writable =3D 0;
 		}
+		sock_put(other);
 	}
=20
 	if (writable)


