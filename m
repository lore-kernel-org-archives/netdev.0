From: Joe Perches <joe@perches.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Tue, 03 Jun 2008 16:54:01 -0700
Message-ID: <1212537241.6980.12.camel@localhost>
References: <20080603094057.GA29480@elte.hu>
	 <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
	 <20080603.150344.145518113.davem@davemloft.net>
	 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	mcmanus@ducksong.com, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2085 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbYFCX5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:57:14 -0400
In-Reply-To: <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-04 at 02:22 +0300, Ilpo J=C3=A4rvinen wrote:
> But here's somewhat more likely explanation... Only compile tested...
> It probably needs some commenting from people who understand locking=20
> variants & details (I don't).
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c9454f0..d21d2b9 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4562,6 +4562,7 @@ static int tcp_defer_accept_check(struct sock *=
sk)
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> =20
>  	if (tp->defer_tcp_accept.request) {
> +		struct sock *listen_sk =3D tp->defer_tcp_accept.listen_sk;

Not commenting on the locking, but I think the code
would be clearer if tp->defer_tcp_accept was used in
a temporary instead.

Perhaps:

 net/ipv4/tcp_input.c |   33 ++++++++++++++++-----------------
 1 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b54d9d3..f846e11 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4535,18 +4535,18 @@ static void tcp_urg(struct sock *sk, struct sk_=
buff *skb, struct tcphdr *th)
 static int tcp_defer_accept_check(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-
-	if (tp->defer_tcp_accept.request) {
-		int queued_data =3D  tp->rcv_nxt - tp->copied_seq;
-		int hasfin =3D  !skb_queue_empty(&sk->sk_receive_queue) ?
+	struct tcp_deferred_accept_info *tdai =3D &tp->defer_tcp_accept;
+	if (tdai->request) {
+		int queued_data =3D tp->rcv_nxt - tp->copied_seq;
+		int hasfin =3D !skb_queue_empty(&sk->sk_receive_queue) ?
 			tcp_hdr((struct sk_buff *)
 				sk->sk_receive_queue.prev)->fin : 0;
=20
 		if (queued_data && hasfin)
 			queued_data--;
=20
-		if (queued_data &&
-		    tp->defer_tcp_accept.listen_sk->sk_state =3D=3D TCP_LISTEN) {
+		bh_lock_sock(tdai->listen_sk);
+		if (queued_data && tdai->listen_sk->sk_state =3D=3D TCP_LISTEN) {
 			if (sock_flag(sk, SOCK_KEEPOPEN)) {
 				inet_csk_reset_keepalive_timer(sk,
 							       keepalive_time_when(tp));
@@ -4554,23 +4554,22 @@ static int tcp_defer_accept_check(struct sock *=
sk)
 				inet_csk_delete_keepalive_timer(sk);
 			}
=20
-			inet_csk_reqsk_queue_add(
-				tp->defer_tcp_accept.listen_sk,
-				tp->defer_tcp_accept.request,
-				sk);
+			inet_csk_reqsk_queue_add(tdai->listen_sk,
+						 tdai->request,
+						 sk);
=20
-			tp->defer_tcp_accept.listen_sk->sk_data_ready(
-				tp->defer_tcp_accept.listen_sk, 0);
+			tdai->listen_sk->sk_data_ready(tdai->listen_sk, 0);
=20
-			sock_put(tp->defer_tcp_accept.listen_sk);
+			sock_put(tdai->listen_sk);
 			sock_put(sk);
-			tp->defer_tcp_accept.listen_sk =3D NULL;
-			tp->defer_tcp_accept.request =3D NULL;
-		} else if (hasfin ||
-			   tp->defer_tcp_accept.listen_sk->sk_state !=3D TCP_LISTEN) {
+			tdai->listen_sk =3D NULL;
+			tdai->request =3D NULL;
+		} else if (hasfin || tdai->listen_sk->sk_state !=3D TCP_LISTEN) {
+			bh_unlock_sock(tdai->listen_sk);
 			tcp_reset(sk);
 			return -1;
 		}
+		bh_unlock_sock(tdai->listen_sk);
 	}
 	return 0;
 }


