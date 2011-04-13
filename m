From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 12:09:29 -0700 (PDT)
Message-ID: <20110413.120929.28806842.davem@davemloft.net>
References: <20110412.161744.27803776.davem@davemloft.net>
	<1302663327.2811.55.camel@edumazet-laptop>
	<1302663608.2811.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751511Ab1DMTKF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:10:05 -0400
In-Reply-To: <1302663608.2811.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Apr 2011 05:00:08 +0200

> Le mercredi 13 avril 2011 =E0 04:55 +0200, Eric Dumazet a =E9crit :
>=20
>> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the pa=
tch,
>> and eventually work on SO_REUSEPORT on net-next-2.6
>>=20
>> What do you think ?
>>=20
>=20
> Sorry, I should have mentioned commit id : c191a836a908d1dd6
> (tcp: disallow bind() to reuse addr/port)

I'm commiting the revert as follows to net-2.6, and will queue
it up for -stable as well:

--------------------
Revert "tcp: disallow bind() to reuse addr/port"

This reverts commit c191a836a908d1dd6b40c503741f91b914de3348.

It causes known regressions for programs that expect to be able to use
SO_REUSEADDR to shutdown a socket, then successfully rebind another
socket to the same ID.

Programs such as haproxy and amavisd expect this to work.

This should fix kernel bugzilla 32832.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_connection_sock.c  |    5 ++---
 net/ipv6/inet6_connection_sock.c |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 6c0b7f4..38f23e7 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -73,7 +73,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
 			if (!reuse || !sk2->sk_reuse ||
-			    ((1 << sk2->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))) {
+			    sk2->sk_state =3D=3D TCP_LISTEN) {
 				const __be32 sk2_rcv_saddr =3D sk_rcv_saddr(sk2);
 				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
 				    sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
@@ -122,8 +122,7 @@ again:
 					    (tb->num_owners < smallest_size || smallest_size =3D=3D -1)) =
{
 						smallest_size =3D tb->num_owners;
 						smallest_rover =3D rover;
-						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1 &&
-						    !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+						if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) {
 							spin_unlock(&head->lock);
 							snum =3D smallest_rover;
 							goto have_snum;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index 1660546..f2c5b0f 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -44,7 +44,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
 		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     ((1 << sk2->sk_state) & (TCPF_LISTEN | TCPF_CLOSE))) &&
+		     sk2->sk_state =3D=3D TCP_LISTEN) &&
 		     ipv6_rcv_saddr_equal(sk, sk2))
 			break;
 	}
--=20
1.7.4.3

