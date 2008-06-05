From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 00:13:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu>
 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-650765930-1212688853=:31672"
Cc: David Miller <davem@davemloft.net>, mcmanus@ducksong.com,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46133 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbYFEVOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 17:14:01 -0400
In-Reply-To: <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0806060004030.2522@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-650765930-1212688853=:31672
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806052355422.2522@wrl-59.cs.helsinki.fi>

On Thu, 5 Jun 2008, Ilpo Järvinen wrote:

> On Thu, 5 Jun 2008, Ingo Molnar wrote:
> 
> > 
> > * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > 
> > > [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
> > 
> > i unapplied the reverts then applied your fix, and got this hang after 
> > 1.5 hours of testing:
> > 
> >  titan:~> netstat -nt
> >  Active Internet connections (w/o servers)
> >  Proto Recv-Q Send-Q Local Address           Foreign Address   State
> >  tcp        0  65032 10.0.1.14:39454         10.0.1.19:3632    ESTABLISHED
> > 
> > 10.0.1.14 is this box, Core2Duo dual-core. 10.0.1.19 is another box with 
> > 16 CPUs.
> 
> Did 10.0.1.19 too have the fix (the receiving end is the important 
> one to have this fix)?

Since you're probably going to tell that it was, here's a try which just 
reverts the most questionable commit out of those three DA related 
changes that were included in the first revert you found to be working 
(the other two are quite useful fixes).

I'm out of new ideas what could be still wrong (I got confused and lost 
track number of times while I tried to verify socket locking today and 
probably don't have more time for that now)... Unless somebody else 
(Patrick?) comes up with something quickly, I propose you Ingo try if
this smaller revert is enough to solve it and we leave those two fixes 
there and postpone the rest. If it isn't enough then things would again 
get quite interesting but that's unlikely to happen.

-- 
 i.

--
[PATCH] tcp: revert DEFER_ACCEPT updates - process as established

Reverts "[TCP]: TCP_DEFER_ACCEPT updates - process as established"
(ec3c0982a2dd1e6) and a fix made into it ("tcp: Fix slab corruption
with ipv6 and tcp6fuzz"; 9ae27e0adbf471c7).

Ingo Molnar found out that TCP flows got stuck into ESTABLISHED
state without receiving process. I tried to fix the locking for
listen_sk:
  http://marc.info/?l=linux-kernel&m=121253537018216&w=2
...but Ingo's tests still got stuck TCP flow with that fix.

Two other DA related fixes which were among the reverted commits
in the first revert attempt are not reverted here.

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
index 9881295..07e79bd 100644
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
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 
-	struct tcp_deferred_accept_info defer_tcp_accept;
-
 	unsigned long last_synq_overflow; 
 
 /* Receiver side RTT estimation */
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
index 828ea21..045e799 100644
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
+				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
+				    (inet_rsk(req)->acked ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req))) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab66683..fc54a48 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2112,12 +2112,15 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
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
 
@@ -2299,7 +2302,8 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
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
index 1322fa1..fb1ab3f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4557,49 +4557,6 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
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
@@ -4974,8 +4931,6 @@ step5:
 
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
1.5.2.2
---696208474-650765930-1212688853=:31672--
