From: David Miller <davem@davemloft.net>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 04 Jun 2008 11:24:26 -0700 (PDT)
Message-ID: <20080604.112426.62778239.davem@davemloft.net>
References: <20080603094057.GA29480@elte.hu>
	<Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
	<20080604072311.GA32491@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, rjw@sisk.pl,
	akpm@linux-foundation.org, johnpol@2ka.mipt.ru,
	mcmanus@ducksong.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbYFDSY1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 14:24:27 -0400
In-Reply-To: <20080604072311.GA32491@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ingo Molnar <mingo@elte.hu>
Date: Wed, 4 Jun 2008 09:23:11 +0200

> * Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>
> > ...I couldn't immediately find anything obviously wrong with those=20
> > changes but the patch below might be worth of a try (without the=20
> > revert of course). If it ever spits out that WARN_ON for you, we we=
re=20
> > playing with fire too much and it's better to return on the safe si=
de=20
> > there...
>=20
> i'll queue it up for testing, but no promises about speedy action her=
e -=20
> the test cycle is really long with this bug.

Ilpo posted another patch which fixes a locking bug in the
code, please test with that patch.  I include it below so
that you know exactly which one I am referring to.

The quicker you test this, the faster I can merge it to
Linus and get the bug fixed for good.

[PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk

It seems that replacement of DA code also moved parts outside
of appropriate locking. The Ingo's problem seems to come from
the fact that two flows could now race in
(inet_csk_)reqsk_queue_add corrupting the queue. ...This can
leave dangling socks around which won't resolve themselves
without stimuli from outside (e.g., external RST would help
I think).

Then some details I'm not too sure of:
I guess we want to put listen_sk->sk_state checking under the
lock as well. I've not evaluated if ->sk_data_ready too
requires locking but assumed it does.

I'm by no means familiar with all locking variants, requirements,
etc.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c9454f0..d21d2b9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4562,6 +4562,7 @@ static int tcp_defer_accept_check(struct sock *sk=
)
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	if (tp->defer_tcp_accept.request) {
+		struct sock *listen_sk =3D tp->defer_tcp_accept.listen_sk;
 		int queued_data =3D  tp->rcv_nxt - tp->copied_seq;
 		int hasfin =3D  !skb_queue_empty(&sk->sk_receive_queue) ?
 			tcp_hdr((struct sk_buff *)
@@ -4570,8 +4571,9 @@ static int tcp_defer_accept_check(struct sock *sk=
)
 		if (queued_data && hasfin)
 			queued_data--;
=20
-		if (queued_data &&
-		    tp->defer_tcp_accept.listen_sk->sk_state =3D=3D TCP_LISTEN) {
+		bh_lock_sock(listen_sk);
+
+		if (queued_data && listen_sk->sk_state =3D=3D TCP_LISTEN) {
 			if (sock_flag(sk, SOCK_KEEPOPEN)) {
 				inet_csk_reset_keepalive_timer(sk,
 							       keepalive_time_when(tp));
@@ -4579,23 +4581,24 @@ static int tcp_defer_accept_check(struct sock *=
sk)
 				inet_csk_delete_keepalive_timer(sk);
 			}
=20
-			inet_csk_reqsk_queue_add(
-				tp->defer_tcp_accept.listen_sk,
-				tp->defer_tcp_accept.request,
-				sk);
+			inet_csk_reqsk_queue_add(listen_sk,
+						 tp->defer_tcp_accept.request,
+						 sk);
=20
 			tp->defer_tcp_accept.listen_sk->sk_data_ready(
-				tp->defer_tcp_accept.listen_sk, 0);
+						listen_sk, 0);
=20
-			sock_put(tp->defer_tcp_accept.listen_sk);
+			sock_put(listen_sk);
 			sock_put(sk);
 			tp->defer_tcp_accept.listen_sk =3D NULL;
 			tp->defer_tcp_accept.request =3D NULL;
-		} else if (hasfin ||
-			   tp->defer_tcp_accept.listen_sk->sk_state !=3D TCP_LISTEN) {
+		} else if (hasfin || listen_sk->sk_state !=3D TCP_LISTEN) {
+			bh_unlock_sock(listen_sk);
 			tcp_reset(sk);
 			return -1;
 		}
+
+		bh_unlock_sock(listen_sk);
 	}
 	return 0;
 }
