From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [patch] abstract out socket lock.users access
Date: Mon, 7 Oct 2002 17:55:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007175551.B30693@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Dave et al,

The patch below abstracts out accesses of the socket lock users count access 
and replaces it with a macro, is_sock_locked(sk).  It also changes 
sk->lock.users into a .owner field that stores a pointer to the current 
iocb that owns the lock.  This is useful for aio as the userland side of a 
socket lock may need to be held until an operation that would have blocked 
is retried.  Comments?

		-ben

:r ~/patches/v2.5/v2.5.41-net-is_locked.diff
diff -urN v2.5.41/include/net/sock.h linux.net-aio.00/include/net/sock.h
--- v2.5.41/include/net/sock.h	Tue Oct  1 13:25:11 2002
+++ linux.net-aio.00/include/net/sock.h	Mon Oct  7 17:27:07 2002
@@ -70,15 +70,16 @@
  * between user contexts and software interrupt processing, whereas the
  * mini-semaphore synchronizes multiple users amongst themselves.
  */
+struct sock_iocb;
 typedef struct {
 	spinlock_t		slock;
-	unsigned int		users;
+	struct sock_iocb	*owner;
 	wait_queue_head_t	wq;
 } socket_lock_t;
 
 #define sock_lock_init(__sk) \
 do {	spin_lock_init(&((__sk)->lock.slock)); \
-	(__sk)->lock.users = 0; \
+	(__sk)->lock.owner = NULL; \
 	init_waitqueue_head(&((__sk)->lock.wq)); \
 } while(0)
 
@@ -306,22 +307,35 @@
  * Since ~2.3.5 it is also exclusive sleep lock serializing
  * accesses from user process context.
  */
+extern int __async_lock_sock(struct sock_iocb *, struct sock *, struct list_head *);
 extern void __lock_sock(struct sock *sk);
 extern void __release_sock(struct sock *sk);
+#define sock_is_locked(sk)	(NULL != (sk)->lock.owner)
 #define lock_sock(__sk) \
 do {	might_sleep(); \
 	spin_lock_bh(&((__sk)->lock.slock)); \
-	if ((__sk)->lock.users != 0) \
+	if ((__sk)->lock.owner != NULL) \
 		__lock_sock(__sk); \
-	(__sk)->lock.users = 1; \
+	(__sk)->lock.owner = (void *)1; \
 	spin_unlock_bh(&((__sk)->lock.slock)); \
 } while(0)
 
+#define async_lock_sock(iocb, __sk, list) \
+({	int ret = 0; \
+	spin_lock_bh(&((__sk)->lock.slock)); \
+	if ((__sk)->lock.owner != NULL) \
+		ret = __async_lock_sock((iocb), (__sk), (list)); \
+	else \
+		(__sk)->lock.owner = (iocb); \
+	spin_unlock_bh(&((__sk)->lock.slock)); \
+	ret; \
+})
+
 #define release_sock(__sk) \
 do {	spin_lock_bh(&((__sk)->lock.slock)); \
 	if ((__sk)->backlog.tail != NULL) \
 		__release_sock(__sk); \
-	(__sk)->lock.users = 0; \
+	(__sk)->lock.owner = NULL; \
         if (waitqueue_active(&((__sk)->lock.wq))) wake_up(&((__sk)->lock.wq)); \
 	spin_unlock_bh(&((__sk)->lock.slock)); \
 } while(0)
diff -urN v2.5.41/include/net/tcp.h linux.net-aio.00/include/net/tcp.h
--- v2.5.41/include/net/tcp.h	Tue Sep 17 18:05:36 2002
+++ linux.net-aio.00/include/net/tcp.h	Mon Oct  7 17:20:05 2002
@@ -1348,7 +1348,7 @@
 		if (tp->ucopy.memory > sk->rcvbuf) {
 			struct sk_buff *skb1;
 
-			if (sk->lock.users) BUG();
+			if (sock_is_locked(sk)) BUG();
 
 			while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
 				sk->backlog_rcv(sk, skb1);
diff -urN v2.5.41/net/core/sock.c linux.net-aio.00/net/core/sock.c
--- v2.5.41/net/core/sock.c	Tue Sep 17 18:05:38 2002
+++ linux.net-aio.00/net/core/sock.c	Mon Oct  7 17:20:05 2002
@@ -861,7 +861,7 @@
 		spin_unlock_bh(&sk->lock.slock);
 		schedule();
 		spin_lock_bh(&sk->lock.slock);
-		if(!sk->lock.users)
+		if(!sock_is_locked(sk))
 			break;
 	}
 	current->state = TASK_RUNNING;
diff -urN v2.5.41/net/decnet/dn_nsp_in.c linux.net-aio.00/net/decnet/dn_nsp_in.c
--- v2.5.41/net/decnet/dn_nsp_in.c	Thu Jun  6 00:35:20 2002
+++ linux.net-aio.00/net/decnet/dn_nsp_in.c	Mon Oct  7 17:32:49 2002
@@ -800,8 +800,8 @@
 			printk(KERN_DEBUG "NSP: 0x%02x 0x%02x 0x%04x 0x%04x %d\n",
 				(int)cb->rt_flags, (int)cb->nsp_flags, 
 				(int)cb->src_port, (int)cb->dst_port, 
-				(int)sk->lock.users);
-		if (sk->lock.users == 0)
+				(int)is_sock_locked(sk));
+		if (!is_sock_locked(sk))
 			ret = dn_nsp_backlog_rcv(sk, skb);
 		else
 			sk_add_backlog(sk, skb);
diff -urN v2.5.41/net/decnet/dn_timer.c linux.net-aio.00/net/decnet/dn_timer.c
--- v2.5.41/net/decnet/dn_timer.c	Mon Jan 22 16:32:10 2001
+++ linux.net-aio.00/net/decnet/dn_timer.c	Mon Oct  7 17:33:38 2002
@@ -57,7 +57,7 @@
 	sock_hold(sk);
 	bh_lock_sock(sk);
 
-	if (sk->lock.users != 0) {
+	if (is_sock_locked(sk)) {
 		sk->timer.expires = jiffies + HZ / 10;
 		add_timer(&sk->timer);
 		goto out;
@@ -115,7 +115,7 @@
 	struct dn_scp *scp = DN_SK(sk);
 
 	bh_lock_sock(sk);
-	if (sk->lock.users != 0) {
+	if (is_sock_locked(sk)) {
 		scp->delack_timer.expires = jiffies + HZ / 20;
 		add_timer(&scp->delack_timer);
 		goto out;
diff -urN v2.5.41/net/ipv4/tcp.c linux.net-aio.00/net/ipv4/tcp.c
--- v2.5.41/net/ipv4/tcp.c	Tue Sep  3 19:47:24 2002
+++ linux.net-aio.00/net/ipv4/tcp.c	Mon Oct  7 17:20:05 2002
@@ -623,7 +623,7 @@
 
 		local_bh_disable();
 		bh_lock_sock(child);
-		BUG_TRAP(!child->lock.users);
+		BUG_TRAP(!sock_is_locked(child));
 		sock_hold(child);
 
 		tcp_disconnect(child, O_NONBLOCK);
@@ -2019,7 +2019,7 @@
 	 */
 	local_bh_disable();
 	bh_lock_sock(sk);
-	BUG_TRAP(!sk->lock.users);
+	BUG_TRAP(!sock_is_locked(sk));
 
 	sock_hold(sk);
 	sock_orphan(sk);
diff -urN v2.5.41/net/ipv4/tcp_input.c linux.net-aio.00/net/ipv4/tcp_input.c
--- v2.5.41/net/ipv4/tcp_input.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/ipv4/tcp_input.c	Mon Oct  7 17:20:05 2002
@@ -2570,7 +2570,7 @@
 		/* Ok. In sequence. In window. */
 		if (tp->ucopy.task == current &&
 		    tp->copied_seq == tp->rcv_nxt && tp->ucopy.len &&
-		    sk->lock.users && !tp->urg_data) {
+		    sock_is_locked(sk) && !tp->urg_data) {
 			int chunk = min_t(unsigned int, skb->len,
 							tp->ucopy.len);
 
@@ -3190,7 +3190,7 @@
 {
 	int result;
 
-	if (sk->lock.users) {
+	if (sock_is_locked(sk)) {
 		local_bh_enable();
 		result = __tcp_checksum_complete(skb);
 		local_bh_disable();
@@ -3324,7 +3324,7 @@
 			if (tp->ucopy.task == current &&
 			    tp->copied_seq == tp->rcv_nxt &&
 			    len - tcp_header_len <= tp->ucopy.len &&
-			    sk->lock.users) {
+			    sock_is_locked(sk)) {
 				__set_current_state(TASK_RUNNING);
 
 				if (!tcp_copy_to_iovec(sk, skb, tcp_header_len)) {
@@ -3864,7 +3864,7 @@
 					tmo = tcp_fin_time(tp);
 					if (tmo > TCP_TIMEWAIT_LEN) {
 						tcp_reset_keepalive_timer(sk, tmo - TCP_TIMEWAIT_LEN);
-					} else if (th->fin || sk->lock.users) {
+					} else if (th->fin || sock_is_locked(sk)) {
 						/* Bad case. We could lose such FIN otherwise.
 						 * It is not a big problem, but it looks confusing
 						 * and not so rare event. We still can lose it now,
diff -urN v2.5.41/net/ipv4/tcp_ipv4.c linux.net-aio.00/net/ipv4/tcp_ipv4.c
--- v2.5.41/net/ipv4/tcp_ipv4.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/ipv4/tcp_ipv4.c	Mon Oct  7 17:20:05 2002
@@ -1003,7 +1003,7 @@
 	/* If too many ICMPs get dropped on busy
 	 * servers this needs to be solved differently.
 	 */
-	if (sk->lock.users)
+	if (sock_is_locked(sk))
 		NET_INC_STATS_BH(LockDroppedIcmps);
 
 	if (sk->state == TCP_CLOSE)
@@ -1022,7 +1022,7 @@
 		/* This is deprecated, but if someone generated it,
 		 * we have no reasons to ignore it.
 		 */
-		if (!sk->lock.users)
+		if (!sock_is_locked(sk))
 			tcp_enter_cwr(tp);
 		goto out;
 	case ICMP_PARAMETERPROB:
@@ -1033,7 +1033,7 @@
 			goto out;
 
 		if (code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
-			if (!sk->lock.users)
+			if (!sock_is_locked(sk))
 				do_pmtu_discovery(sk, iph, info);
 			goto out;
 		}
@@ -1050,7 +1050,7 @@
 	switch (sk->state) {
 		struct open_request *req, **prev;
 	case TCP_LISTEN:
-		if (sk->lock.users)
+		if (sock_is_locked(sk))
 			goto out;
 
 		req = tcp_v4_search_req(tp, &prev, th->dest,
@@ -1081,7 +1081,7 @@
 	case TCP_SYN_RECV:  /* Cannot happen.
 			       It can f.e. if SYNs crossed.
 			     */
-		if (!sk->lock.users) {
+		if (!sock_is_locked(sk)) {
 			TCP_INC_STATS_BH(TcpAttemptFails);
 			sk->err = err;
 
@@ -1111,7 +1111,7 @@
 	 */
 
 	inet = inet_sk(sk);
-	if (!sk->lock.users && inet->recverr) {
+	if (!sock_is_locked(sk) && inet->recverr) {
 		sk->err = err;
 		sk->error_report(sk);
 	} else	{ /* Only an error on timeout */
@@ -1778,7 +1778,7 @@
 
 	bh_lock_sock(sk);
 	ret = 0;
-	if (!sk->lock.users) {
+	if (!sock_is_locked(sk)) {
 		if (!tcp_prequeue(sk, skb))
 			ret = tcp_v4_do_rcv(sk, skb);
 	} else
diff -urN v2.5.41/net/ipv4/tcp_minisocks.c linux.net-aio.00/net/ipv4/tcp_minisocks.c
--- v2.5.41/net/ipv4/tcp_minisocks.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/ipv4/tcp_minisocks.c	Mon Oct  7 17:20:05 2002
@@ -989,7 +989,7 @@
 	int ret = 0;
 	int state = child->state;
 
-	if (child->lock.users == 0) {
+	if (!sock_is_locked(child)) {
 		ret = tcp_rcv_state_process(child, skb, skb->h.th, skb->len);
 
 		/* Wakeup parent, send SIGIO */
diff -urN v2.5.41/net/ipv4/tcp_timer.c linux.net-aio.00/net/ipv4/tcp_timer.c
--- v2.5.41/net/ipv4/tcp_timer.c	Thu Jun  6 00:35:29 2002
+++ linux.net-aio.00/net/ipv4/tcp_timer.c	Mon Oct  7 17:20:05 2002
@@ -213,7 +213,7 @@
 	struct tcp_opt *tp = tcp_sk(sk);
 
 	bh_lock_sock(sk);
-	if (sk->lock.users) {
+	if (sock_is_locked(sk)) {
 		/* Try again later. */
 		tp->ack.blocked = 1;
 		NET_INC_STATS_BH(DelayedACKLocked);
@@ -421,7 +421,7 @@
 	int event;
 
 	bh_lock_sock(sk);
-	if (sk->lock.users) {
+	if (sock_is_locked(sk)) {
 		/* Try again later */
 		if (!mod_timer(&tp->retransmit_timer, jiffies + (HZ/20)))
 			sock_hold(sk);
@@ -581,7 +581,7 @@
 
 	/* Only process if socket is not in use. */
 	bh_lock_sock(sk);
-	if (sk->lock.users) {
+	if (sock_is_locked(sk)) {
 		/* Try again later. */ 
 		tcp_reset_keepalive_timer (sk, HZ/20);
 		goto out;
diff -urN v2.5.41/net/ipv6/tcp_ipv6.c linux.net-aio.00/net/ipv6/tcp_ipv6.c
--- v2.5.41/net/ipv6/tcp_ipv6.c	Tue Sep  3 19:47:24 2002
+++ linux.net-aio.00/net/ipv6/tcp_ipv6.c	Mon Oct  7 17:35:17 2002
@@ -731,7 +731,7 @@
 	}
 
 	bh_lock_sock(sk);
-	if (sk->lock.users)
+	if (is_sock_locked(sk))
 		NET_INC_STATS_BH(LockDroppedIcmps);
 
 	if (sk->state == TCP_CLOSE)
@@ -749,7 +749,7 @@
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
-		if (sk->lock.users)
+		if (is_sock_locked(sk))
 			goto out;
 		if ((1<<sk->state)&(TCPF_LISTEN|TCPF_CLOSE))
 			goto out;
@@ -792,7 +792,7 @@
 	switch (sk->state) {
 		struct open_request *req, **prev;
 	case TCP_LISTEN:
-		if (sk->lock.users)
+		if (is_sock_locked(sk))
 			goto out;
 
 		req = tcp_v6_search_req(tp, &prev, th->dest, &hdr->daddr,
@@ -816,7 +816,7 @@
 	case TCP_SYN_SENT:
 	case TCP_SYN_RECV:  /* Cannot happen.
 			       It can, it SYNs are crossed. --ANK */ 
-		if (sk->lock.users == 0) {
+		if (!is_sock_locked(sk)) {
 			TCP_INC_STATS_BH(TcpAttemptFails);
 			sk->err = err;
 			sk->error_report(sk);		/* Wake people up to see the error (see connect in sock.c) */
@@ -828,7 +828,7 @@
 		goto out;
 	}
 
-	if (sk->lock.users == 0 && np->recverr) {
+	if (!is_sock_locked(sk) && np->recverr) {
 		sk->err = err;
 		sk->error_report(sk);
 	} else {
@@ -1622,7 +1622,7 @@
 
 	bh_lock_sock(sk);
 	ret = 0;
-	if (!sk->lock.users) {
+	if (!is_sock_locked(sk)) {
 		if (!tcp_prequeue(sk, skb))
 			ret = tcp_v6_do_rcv(sk, skb);
 	} else
diff -urN v2.5.41/net/llc/llc_c_ac.c linux.net-aio.00/net/llc/llc_c_ac.c
--- v2.5.41/net/llc/llc_c_ac.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/llc/llc_c_ac.c	Mon Oct  7 17:35:35 2002
@@ -1489,7 +1489,7 @@
 		       __FUNCTION__);
 		kfree_skb(skb);
 	} else {
-		if (!sk->lock.users)
+		if (!is_sock_locked(sk))
 			llc_conn_state_process(sk, skb);
 		else {
 			llc_set_backlog_type(skb, LLC_EVENT);
diff -urN v2.5.41/net/llc/llc_mac.c linux.net-aio.00/net/llc/llc_mac.c
--- v2.5.41/net/llc/llc_mac.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/llc/llc_mac.c	Mon Oct  7 17:35:55 2002
@@ -140,7 +140,7 @@
 		} else
 			skb->sk = sk;
 		bh_lock_sock(sk);
-		if (!sk->lock.users) {
+		if (!is_sock_locked(sk)) {
 			/* rc = */ llc_conn_rcv(sk, skb);
 			rc = 0;
 		} else {
diff -urN v2.5.41/net/llc/llc_proc.c linux.net-aio.00/net/llc/llc_proc.c
--- v2.5.41/net/llc/llc_proc.c	Mon Oct  7 17:19:22 2002
+++ linux.net-aio.00/net/llc/llc_proc.c	Mon Oct  7 17:36:15 2002
@@ -182,7 +182,7 @@
 		   timer_pending(&llc->pf_cycle_timer.timer),
 		   timer_pending(&llc->rej_sent_timer.timer),
 		   timer_pending(&llc->busy_state_timer.timer),
-		   !!sk->backlog.tail, sk->lock.users);
+		   !!sk->backlog.tail, is_sock_locked(sk));
 out:
 	return 0;
 }
diff -urN v2.5.41/net/x25/x25_dev.c linux.net-aio.00/net/x25/x25_dev.c
--- v2.5.41/net/x25/x25_dev.c	Tue Oct  1 13:25:11 2002
+++ linux.net-aio.00/net/x25/x25_dev.c	Mon Oct  7 17:36:32 2002
@@ -70,7 +70,7 @@
 
 		skb->h.raw = skb->data;
 		bh_lock_sock(sk);
-		if (!sk->lock.users) {
+		if (!is_sock_locked(sk)) {
 			queued = x25_process_rx_frame(sk, skb);
 		} else {
 			sk_add_backlog(sk, skb);
diff -urN v2.5.41/net/x25/x25_timer.c linux.net-aio.00/net/x25/x25_timer.c
--- v2.5.41/net/x25/x25_timer.c	Tue Oct  1 13:25:11 2002
+++ linux.net-aio.00/net/x25/x25_timer.c	Mon Oct  7 17:36:55 2002
@@ -131,7 +131,7 @@
 	struct sock *sk = (struct sock *)param;
 
         bh_lock_sock(sk);
-        if (sk->lock.users) /* can currently only occur in state 3 */ 
+        if (is_sock_locked(sk)) /* can currently only occur in state 3 */ 
 		goto restart_heartbeat;
 
 	switch (x25_sk(sk)->state) {
@@ -193,7 +193,7 @@
 	struct sock *sk = (struct sock *)param;
 
 	bh_lock_sock(sk);
-	if (sk->lock.users) { /* can currently only occur in state 3 */
+	if (is_sock_locked(sk)) { /* can currently only occur in state 3 */
 		if (x25_sk(sk)->state == X25_STATE_3)
 			x25_start_t2timer(sk);
 	} else
