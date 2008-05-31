From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 15:18:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu>
 <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu>
 <20080530181839.GA31915@elte.hu> <20080531060947.GA26441@elte.hu>
 <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1046607125-1212235549=:2329"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754024AbYEaMTT@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0805311506080.2329@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1046607125-1212235549=:2329
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805311506081.2329@wrl-59.cs.helsinki.fi>

On Sat, 31 May 2008, Ilpo Järvinen wrote:

> On Sat, 31 May 2008, Ingo Molnar wrote:
> 
> > ok, once i added back the localhost distcc component and the hung kernel 
> > build + stuck TCP socket bug happened again overnight:
> > 
> >  Active Internet connections (w/o servers)
> >  Proto Recv-Q Send-Q Local Address               Foreign Address             State
> >  tcp    72187      0 10.0.1.14:3632              10.0.1.14:47910             ESTABLISHED
> >  tcp        0 174464 10.0.1.14:47910             10.0.1.14:3632              ESTABLISHED
> > 
> > so it seems distcc over localhost was the aspect that made it fail.
> > 
> > _Perhaps_ what matters is to have the new post-rc3 TCP code on _both_ 
> > sides of the connection. But that is just a theory - it could be timing, 
> > etc.
> 
> Btw, does your distcc perhaps happen enable TCP_DEFER_ACCEPT (there were
> some post 2.6.25 changes into it)?

Hmm, if so, please try this revert below (I hope I got everything that is 
related there, gitk is currently broken for me so that viewing many 
commits quickly is a pain, so I might have accidently missed something)...

-- 
 i.

--
[PATCH] tcp: Reverts DEFER_ACCEPT modifications

Reverts these commits:
 [TCP]: TCP_DEFER_ACCEPT updates - defer timeout conflicts with max_t
 [TCP]: TCP_DEFER_ACCEPT updates - dont retxmt synack
 [TCP]: TCP_DEFER_ACCEPT updates - process as established
 tcp: Fix slab corruption with ipv6 and tcp6fuzz

..., ie.,
 539fae89bebd16ebeafd57a87169bc56eb530d76,
 e4c78840284f3f51b1896cf3936d60a6033c4d2c,
 ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 and
 9ae27e0adbf471c7a6b80102e38e1d5a346b3b38.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h             |    7 ------
 include/net/request_sock.h      |    4 +-
 include/net/tcp.h               |    1 -
 net/ipv4/inet_connection_sock.c |   11 +++++++--
 net/ipv4/tcp.c                  |   18 +++++++++------
 net/ipv4/tcp_input.c            |   45 ---------------------------------------
 net/ipv4/tcp_ipv4.c             |    8 -------
 net/ipv4/tcp_minisocks.c        |   32 ++++++++++-----------------
 net/ipv4/tcp_timer.c            |    5 ----
 9 files changed, 33 insertions(+), 98 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 18e62e3..b31b6b7 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -239,11 +239,6 @@ static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
 	return (struct tcp_request_sock *)req;
 }
 
-struct tcp_deferred_accept_info {
-	struct sock *listen_sk;
-	struct request_sock *request;
-};
-
 struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
@@ -379,8 +374,6 @@ struct tcp_sock {
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 	int			linger2;
 
-	struct tcp_deferred_accept_info defer_tcp_accept;
-
 	unsigned long last_synq_overflow; 
 
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
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..981d5ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -139,7 +139,6 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define MAX_TCP_KEEPINTVL	32767
 #define MAX_TCP_KEEPCNT		127
 #define MAX_TCP_SYNCNT		127
-#define MAX_TCP_ACCEPT_DEFERRED 65535
 
 #define TCP_SYNQ_INTERVAL	(HZ/5)	/* Period of SYNACK timer */
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 828ea21..ec83448 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -419,7 +419,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 	struct inet_connection_sock *icsk = inet_csk(parent);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	struct listen_sock *lopt = queue->listen_opt;
-	int thresh = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
+	int max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
+	int thresh = max_retries;
 	unsigned long now = jiffies;
 	struct request_sock **reqp, *req;
 	int i, budget;
@@ -455,6 +456,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		}
 	}
 
+	if (queue->rskq_defer_accept)
+		max_retries = queue->rskq_defer_accept;
+
 	budget = 2 * (lopt->nr_table_entries / (timeout / interval));
 	i = lopt->clock_hand;
 
@@ -462,8 +466,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if (req->retrans < thresh &&
-				    !req->rsk_ops->rtx_syn_ack(parent, req)) {
+				if ((req->retrans < thresh ||
+				     (inet_rsk(req)->acked && req->retrans < max_retries))
+				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f886531..a0deead 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2105,12 +2105,15 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_DEFER_ACCEPT:
-		if (val < 0) {
-			err = -EINVAL;
-		} else {
-			if (val > MAX_TCP_ACCEPT_DEFERRED)
-				val = MAX_TCP_ACCEPT_DEFERRED;
-			icsk->icsk_accept_queue.rskq_defer_accept = val;
+		icsk->icsk_accept_queue.rskq_defer_accept = 0;
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
 
@@ -2292,7 +2295,8 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			val = (val ? : sysctl_tcp_fin_timeout) / HZ;
 		break;
 	case TCP_DEFER_ACCEPT:
-		val = icsk->icsk_accept_queue.rskq_defer_accept;
+		val = !icsk->icsk_accept_queue.rskq_defer_accept ? 0 :
+			((TCP_TIMEOUT_INIT / HZ) << (icsk->icsk_accept_queue.rskq_defer_accept - 1));
 		break;
 	case TCP_WINDOW_CLAMP:
 		val = tp->window_clamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b54d9d3..ddc2e89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4532,49 +4532,6 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 	}
 }
 
-static int tcp_defer_accept_check(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (tp->defer_tcp_accept.request) {
-		int queued_data =  tp->rcv_nxt - tp->copied_seq;
-		int hasfin =  !skb_queue_empty(&sk->sk_receive_queue) ?
-			tcp_hdr((struct sk_buff *)
-				sk->sk_receive_queue.prev)->fin : 0;
-
-		if (queued_data && hasfin)
-			queued_data--;
-
-		if (queued_data &&
-		    tp->defer_tcp_accept.listen_sk->sk_state == TCP_LISTEN) {
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
-			tp->defer_tcp_accept.listen_sk = NULL;
-			tp->defer_tcp_accept.request = NULL;
-		} else if (hasfin ||
-			   tp->defer_tcp_accept.listen_sk->sk_state != TCP_LISTEN) {
-			tcp_reset(sk);
-			return -1;
-		}
-	}
-	return 0;
-}
-
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4935,8 +4892,6 @@ step5:
 
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
-
-	tcp_defer_accept_check(sk);
 	return 0;
 
 csum_error:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..b698b5b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1918,14 +1918,6 @@ int tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
-	if (tp->defer_tcp_accept.request) {
-		reqsk_free(tp->defer_tcp_accept.request);
-		sock_put(tp->defer_tcp_accept.listen_sk);
-		sock_put(sk);
-		tp->defer_tcp_accept.listen_sk = NULL;
-		tp->defer_tcp_accept.request = NULL;
-	}
-
 	atomic_dec(&tcp_sockets_allocated);
 
 	return 0;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 019c8c1..8245247 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -571,8 +571,10 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	   does sequence test, SYN is truncated, and thus we consider
 	   it a bare ACK.
 
-	   Both ends (listening sockets) accept the new incoming
-	   connection and try to talk to each other. 8-)
+	   If icsk->icsk_accept_queue.rskq_defer_accept, we silently drop this
+	   bare ACK.  Otherwise, we create an established connection.  Both
+	   ends (listening sockets) accept the new incoming connection and try
+	   to talk to each other. 8-)
 
 	   Note: This case is both harmless, and rare.  Possibility is about the
 	   same as us discovering intelligent life on another plant tomorrow.
@@ -640,6 +642,13 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		if (!(flg & TCP_FLAG_ACK))
 			return NULL;
 
+		/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
+		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
+			inet_rsk(req)->acked = 1;
+			return NULL;
+		}
+
 		/* OK, ACK is valid, create big socket and
 		 * feed this segment to it. It will repeat all
 		 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
@@ -678,24 +687,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		inet_csk_reqsk_queue_unlink(sk, req, prev);
 		inet_csk_reqsk_queue_removed(sk, req);
 
-		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
-
-			/* the accept queue handling is done is est recv slow
-			 * path so lets make sure to start there
-			 */
-			tcp_sk(child)->pred_flags = 0;
-			sock_hold(sk);
-			sock_hold(child);
-			tcp_sk(child)->defer_tcp_accept.listen_sk = sk;
-			tcp_sk(child)->defer_tcp_accept.request = req;
-
-			inet_csk_reset_keepalive_timer(child,
-						       inet_csk(sk)->icsk_accept_queue.rskq_defer_accept * HZ);
-		} else {
-			inet_csk_reqsk_queue_add(sk, req, child);
-		}
-
+		inet_csk_reqsk_queue_add(sk, req, child);
 		return child;
 
 	listen_overflow:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4de68cf..63ed9d6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -489,11 +489,6 @@ static void tcp_keepalive_timer (unsigned long data)
 		goto death;
 	}
 
-	if (tp->defer_tcp_accept.request && sk->sk_state == TCP_ESTABLISHED) {
-		tcp_send_active_reset(sk, GFP_ATOMIC);
-		goto death;
-	}
-
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
 		goto out;
 
-- 
1.5.5.3

---696208474-1046607125-1212235549=:2329--
