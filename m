From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Tue, 11 Jan 2011 12:14:22 +0100
Message-ID: <1294744462.2927.53.camel@edumazet-laptop>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
	 <AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
	 <1294140172.3579.81.camel@edumazet-laptop>
	 <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Baluta <daniel.baluta@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46944 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab1AKLO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 06:14:27 -0500
Received: by wyb28 with SMTP id 28so20340719wyb.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 03:14:26 -0800 (PST)
In-Reply-To: <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 11:00 +0200, Daniel Baluta a =C3=A9c=
rit :

> Going back to my first email, are there any follow ups on your
> "tcp: bind() fix when many ports are bound" patch. I've searched
> netdev archives but no luck. I might have missed something.
>=20
> I really appreciate your help.
>=20

I believe following patch should solve the problem.

Thanks for reminding us this issue !

I checked FreeBSD : It doesnt allow two sockets (in CLOSE state) bound
on same addr/port, even if both have REUSEADDR set



[PATCH] tcp: disallow bind() to reuse addr/port

inet_csk_bind_conflict() logic currently disallows a bind() if
it finds a friend socket (a socket bound on same address/port)
satisfying a set of conditions :

1) Current (to be bound) socket doesnt have sk_reuse set
OR
2) other socket doesnt have sk_reuse set
OR
3) other socket is in LISTEN state

We should add the CLOSE state in the 3) condition, in order to avoid tw=
o
REUSEADDR sockets in CLOSE state with same local address/port, since
this can deny further operations.

Note : a prior patch tried to address the problem in a different (and
buggy) way. (commit fda48a0d7a8412ced tcp: bind() fix when many ports
are bound).

Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
Reported-by: Daniel Baluta <daniel.baluta@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inet_connection_sock.c  |    5 +++--
 net/ipv6/inet6_connection_sock.c |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 25e3181..9f6d585 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -73,7 +73,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
 			if (!reuse || !sk2->sk_reuse ||
-			    sk2->sk_state =3D=3D TCP_LISTEN) {
+			    ((1 << sk2->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))) {
 				const __be32 sk2_rcv_saddr =3D sk_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
 				    sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
@@ -122,7 +122,8 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size =3D=3D -1)) =
{
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
+						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&=20
+						    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
 							spin_unlock(&head->lock);
 							snum =3D smallest_rover;
 							goto have_snum;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index e46305d..d144e62 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -44,7 +44,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
 		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     sk2->sk_state =3D=3D TCP_LISTEN) &&
+		     ((1 << sk2->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))) &&
 		     ipv6_rcv_saddr_equal(sk, sk2))
 			break;
 	}


