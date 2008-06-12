From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Thu, 12 Jun 2008 16:32:12 -0700 (PDT)
Message-ID: <20080612.163212.148965080.davem@davemloft.net>
References: <200806111658.41182.vgusev@openvz.org>
	<20080611135718.GA26914@ms2.inr.ac.ru>
	<20080611.165255.242691774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vgusev@openvz.org, mcmanus@ducksong.com, xemul@openvz.org,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi, mingo@elte.hu,
	linux-kernel@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754467AbYFLXcM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 19:32:12 -0400
In-Reply-To: <20080611.165255.242691774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Wed, 11 Jun 2008 16:52:55 -0700 (PDT)

> More and more, the arguments are mounting to completely revert the
> established code path changes, and frankly that is likely what I am
> going to do by the end of today.

Here is the revert patch I intend to send to Linus:

tcp: Revert 'process defer accept as established' changes.

This reverts two changesets, ec3c0982a2dd1e671bad8e9d26c28dcba0039d87
("[TCP]: TCP_DEFER_ACCEPT updates - process as established") and
the follow-on bug fix 9ae27e0adbf471c7a6b80102e38e1d5a346b3b38
("tcp: Fix slab corruption with ipv6 and tcp6fuzz").

This change causes several problems, first reported by Ingo Molnar
as a distcc-over-loopback regression where connections were getting
stuck.

Ilpo J=E4rvinen first spotted the locking problems.  The new function
added by this code, tcp_defer_accept_check(), only has the
child socket locked, yet it is modifying state of the parent
listening socket.

=46ixing that is non-trivial at best, because we can't simply just grab
the parent listening socket lock at this point, because it would
create an ABBA deadlock.  The normal ordering is parent listening
socket --> child socket, but this code path would require the
reverse lock ordering.

Next is a problem noticed by Vitaliy Gusev, he noted:

----------------------------------------
>--- a/net/ipv4/tcp_timer.c
>+++ b/net/ipv4/tcp_timer.c
>@@ -481,6 +481,11 @@ static void tcp_keepalive_timer (unsigned long da=
ta)
> 		goto death;
> 	}
>
>+	if (tp->defer_tcp_accept.request && sk->sk_state =3D=3D TCP_ESTABLIS=
HED) {
>+		tcp_send_active_reset(sk, GFP_ATOMIC);
>+		goto death;

Here socket sk is not attached to listening socket's request queue. tcp=
_done()
will not call inet_csk_destroy_sock() (and tcp_v4_destroy_sock() which =
should
release this sk) as socket is not DEAD. Therefore socket sk will be los=
t for
freeing.
----------------------------------------

=46inally, Alexey Kuznetsov argues that there might not even be any
real value or advantage to these new semantics even if we fix all
of the bugs:

----------------------------------------
Hiding from accept() sockets with only out-of-order data only
is the only thing which is impossible with old approach. Is this really
so valuable? My opinion: no, this is nothing but a new loophole
to consume memory without control.
----------------------------------------

So revert this thing for now.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/tcp.h             |    7 ------
 include/net/request_sock.h      |    4 +-
 include/net/tcp.h               |    1 -
 net/ipv4/inet_connection_sock.c |   11 +++++++--
 net/ipv4/tcp.c                  |   18 +++++++++------
 net/ipv4/tcp_input.c            |   45 -------------------------------=
--------
 net/ipv4/tcp_ipv4.c             |    8 -------
 net/ipv4/tcp_minisocks.c        |   32 ++++++++++-----------------
 net/ipv4/tcp_timer.c            |    5 ----
 9 files changed, 33 insertions(+), 98 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 18e62e3..b31b6b7 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -239,11 +239,6 @@ static inline struct tcp_request_sock *tcp_rsk(con=
st struct request_sock *req)
 	return (struct tcp_request_sock *)req;
 }
=20
-struct tcp_deferred_accept_info {
-	struct sock *listen_sk;
-	struct request_sock *request;
-};
-
 struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
@@ -379,8 +374,6 @@ struct tcp_sock {
 	unsigned int		keepalive_intvl;  /* time interval between keep alive p=
robes */
 	int			linger2;
=20
-	struct tcp_deferred_accept_info defer_tcp_accept;
-
 	unsigned long last_synq_overflow;=20
=20
 	u32	tso_deferred;
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index b220b5f..0c96e7b 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -115,8 +115,8 @@ struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
 	rwlock_t		syn_wait_lock;
-	u16			rskq_defer_accept;
-	/* 2 bytes hole, try to pack */
+	u8			rskq_defer_accept;
+	/* 3 bytes hole, try to pack */
 	struct listen_sock	*listen_opt;
 };
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d448310..cf54034 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -139,7 +139,6 @@ extern void tcp_time_wait(struct sock *sk, int stat=
e, int timeo);
 #define MAX_TCP_KEEPINTVL	32767
 #define MAX_TCP_KEEPCNT		127
 #define MAX_TCP_SYNCNT		127
-#define MAX_TCP_ACCEPT_DEFERRED 65535
=20
 #define TCP_SYNQ_INTERVAL	(HZ/5)	/* Period of SYNACK timer */
=20
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 828ea21..045e799 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -419,7 +419,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent=
,
 	struct inet_connection_sock *icsk =3D inet_csk(parent);
 	struct request_sock_queue *queue =3D &icsk->icsk_accept_queue;
 	struct listen_sock *lopt =3D queue->listen_opt;
-	int thresh =3D icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
+	int max_retries =3D icsk->icsk_syn_retries ? : sysctl_tcp_synack_retr=
ies;
+	int thresh =3D max_retries;
 	unsigned long now =3D jiffies;
 	struct request_sock **reqp, *req;
 	int i, budget;
@@ -455,6 +456,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent=
,
 		}
 	}
=20
+	if (queue->rskq_defer_accept)
+		max_retries =3D queue->rskq_defer_accept;
+
 	budget =3D 2 * (lopt->nr_table_entries / (timeout / interval));
 	i =3D lopt->clock_hand;
=20
@@ -462,8 +466,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent=
,
 		reqp=3D&lopt->syn_table[i];
 		while ((req =3D *reqp) !=3D NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if (req->retrans < thresh &&
-				    !req->rsk_ops->rtx_syn_ack(parent, req)) {
+				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))=
 &&
+				    (inet_rsk(req)->acked ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req))) {
 					unsigned long timeo;
=20
 					if (req->retrans++ =3D=3D 0)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab66683..fc54a48 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2112,12 +2112,15 @@ static int do_tcp_setsockopt(struct sock *sk, i=
nt level,
 		break;
=20
 	case TCP_DEFER_ACCEPT:
-		if (val < 0) {
-			err =3D -EINVAL;
-		} else {
-			if (val > MAX_TCP_ACCEPT_DEFERRED)
-				val =3D MAX_TCP_ACCEPT_DEFERRED;
-			icsk->icsk_accept_queue.rskq_defer_accept =3D val;
+		icsk->icsk_accept_queue.rskq_defer_accept =3D 0;
+		if (val > 0) {
+			/* Translate value in seconds to number of
+			 * retransmits */
+			while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
+			       val > ((TCP_TIMEOUT_INIT / HZ) <<
+				       icsk->icsk_accept_queue.rskq_defer_accept))
+				icsk->icsk_accept_queue.rskq_defer_accept++;
+			icsk->icsk_accept_queue.rskq_defer_accept++;
 		}
 		break;
=20
@@ -2299,7 +2302,8 @@ static int do_tcp_getsockopt(struct sock *sk, int=
 level,
 			val =3D (val ? : sysctl_tcp_fin_timeout) / HZ;
 		break;
 	case TCP_DEFER_ACCEPT:
-		val =3D icsk->icsk_accept_queue.rskq_defer_accept;
+		val =3D !icsk->icsk_accept_queue.rskq_defer_accept ? 0 :
+			((TCP_TIMEOUT_INIT / HZ) << (icsk->icsk_accept_queue.rskq_defer_acc=
ept - 1));
 		break;
 	case TCP_WINDOW_CLAMP:
 		val =3D tp->window_clamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eba873e..cad73b7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4541,49 +4541,6 @@ static void tcp_urg(struct sock *sk, struct sk_b=
uff *skb, struct tcphdr *th)
 	}
 }
=20
-static int tcp_defer_accept_check(struct sock *sk)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
-	if (tp->defer_tcp_accept.request) {
-		int queued_data =3D  tp->rcv_nxt - tp->copied_seq;
-		int hasfin =3D  !skb_queue_empty(&sk->sk_receive_queue) ?
-			tcp_hdr((struct sk_buff *)
-				sk->sk_receive_queue.prev)->fin : 0;
-
-		if (queued_data && hasfin)
-			queued_data--;
-
-		if (queued_data &&
-		    tp->defer_tcp_accept.listen_sk->sk_state =3D=3D TCP_LISTEN) {
-			if (sock_flag(sk, SOCK_KEEPOPEN)) {
-				inet_csk_reset_keepalive_timer(sk,
-							       keepalive_time_when(tp));
-			} else {
-				inet_csk_delete_keepalive_timer(sk);
-			}
-
-			inet_csk_reqsk_queue_add(
-				tp->defer_tcp_accept.listen_sk,
-				tp->defer_tcp_accept.request,
-				sk);
-
-			tp->defer_tcp_accept.listen_sk->sk_data_ready(
-				tp->defer_tcp_accept.listen_sk, 0);
-
-			sock_put(tp->defer_tcp_accept.listen_sk);
-			sock_put(sk);
-			tp->defer_tcp_accept.listen_sk =3D NULL;
-			tp->defer_tcp_accept.request =3D NULL;
-		} else if (hasfin ||
-			   tp->defer_tcp_accept.listen_sk->sk_state !=3D TCP_LISTEN) {
-			tcp_reset(sk);
-			return -1;
-		}
-	}
-	return 0;
-}
-
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int=
 hlen)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -4944,8 +4901,6 @@ step5:
=20
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
-
-	tcp_defer_accept_check(sk);
 	return 0;
=20
 csum_error:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4f8485c..97a2300 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1918,14 +1918,6 @@ int tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page =3D NULL;
 	}
=20
-	if (tp->defer_tcp_accept.request) {
-		reqsk_free(tp->defer_tcp_accept.request);
-		sock_put(tp->defer_tcp_accept.listen_sk);
-		sock_put(sk);
-		tp->defer_tcp_accept.listen_sk =3D NULL;
-		tp->defer_tcp_accept.request =3D NULL;
-	}
-
 	atomic_dec(&tcp_sockets_allocated);
=20
 	return 0;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 019c8c1..8245247 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -571,8 +571,10 @@ struct sock *tcp_check_req(struct sock *sk,struct =
sk_buff *skb,
 	   does sequence test, SYN is truncated, and thus we consider
 	   it a bare ACK.
=20
-	   Both ends (listening sockets) accept the new incoming
-	   connection and try to talk to each other. 8-)
+	   If icsk->icsk_accept_queue.rskq_defer_accept, we silently drop thi=
s
+	   bare ACK.  Otherwise, we create an established connection.  Both
+	   ends (listening sockets) accept the new incoming connection and tr=
y
+	   to talk to each other. 8-)
=20
 	   Note: This case is both harmless, and rare.  Possibility is about =
the
 	   same as us discovering intelligent life on another plant tomorrow.
@@ -640,6 +642,13 @@ struct sock *tcp_check_req(struct sock *sk,struct =
sk_buff *skb,
 		if (!(flg & TCP_FLAG_ACK))
 			return NULL;
=20
+		/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
+		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+		    TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) {
+			inet_rsk(req)->acked =3D 1;
+			return NULL;
+		}
+
 		/* OK, ACK is valid, create big socket and
 		 * feed this segment to it. It will repeat all
 		 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
@@ -678,24 +687,7 @@ struct sock *tcp_check_req(struct sock *sk,struct =
sk_buff *skb,
 		inet_csk_reqsk_queue_unlink(sk, req, prev);
 		inet_csk_reqsk_queue_removed(sk, req);
=20
-		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-		    TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) {
-
-			/* the accept queue handling is done is est recv slow
-			 * path so lets make sure to start there
-			 */
-			tcp_sk(child)->pred_flags =3D 0;
-			sock_hold(sk);
-			sock_hold(child);
-			tcp_sk(child)->defer_tcp_accept.listen_sk =3D sk;
-			tcp_sk(child)->defer_tcp_accept.request =3D req;
-
-			inet_csk_reset_keepalive_timer(child,
-						       inet_csk(sk)->icsk_accept_queue.rskq_defer_accept * HZ);
-		} else {
-			inet_csk_reqsk_queue_add(sk, req, child);
-		}
-
+		inet_csk_reqsk_queue_add(sk, req, child);
 		return child;
=20
 	listen_overflow:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4de68cf..63ed9d6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -489,11 +489,6 @@ static void tcp_keepalive_timer (unsigned long dat=
a)
 		goto death;
 	}
=20
-	if (tp->defer_tcp_accept.request && sk->sk_state =3D=3D TCP_ESTABLISH=
ED) {
-		tcp_send_active_reset(sk, GFP_ATOMIC);
-		goto death;
-	}
-
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20
--=20
1.5.5.1.308.g1fbb5

