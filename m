From: Lennert Buytenhek <buytenh@gnu.org>
Subject: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 04:32:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107093207.GA30666@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(please CC on replies, I am not on this list)

Hi,

This patch gives userland the ability to decide whether to react
with an incoming TCP SYN with a SYN-ACK or a RST.  It was hacked
up after Linux Kongress 2001 and has been sitting on my patch
pile since april this year or something.

The basic idea is this:
- Put the listening TCP socket in TCP_CONFIRM_CONNECT mode.
- Sockets returned from accept() on this socket after this will be
  sockets in the SYN_RECV state instead of the ESTABLISHED state
  (unless syncookies had to be used).  By writing to the socket,
  you cause a SYN-ACK to be sent, and by immediately closing the
  socket you cause a RST to be sent.

There are two issues left, AFAICS:
- SYN_RECV sockets currently don't time out for some reason
- it deadlocks instantly on SMP

It's against 2.4.18.  Could someone have a look at it please?  I
unfortunately haven't had any time at all lately, so I would be
really happy if someone else could take this over.  (Well, I can
dream, can't I?)


cheers,
Lennert



--- linux-2.4.18-11umpr/include/linux/tcp.h.orig	Thu Nov 22 20:47:11 2001
+++ linux-2.4.18-11umpr/include/linux/tcp.h	Thu Apr 18 19:33:19 2002
@@ -127,6 +127,7 @@
 #define TCP_WINDOW_CLAMP	10	/* Bound advertised window */
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
+#define TCP_CONFIRM_CONNECT	13	/* Let user control connection acceptance */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
--- linux-2.4.18-11umpr/include/net/sock.h.orig	Fri Dec 21 18:42:04 2001
+++ linux-2.4.18-11umpr/include/net/sock.h	Thu Apr 18 19:37:52 2002
@@ -302,6 +302,7 @@
 	__u8	reordering;	/* Packet reordering metric.		*/
 	__u8	queue_shrunk;	/* Write queue has been shrunk recently.*/
 	__u8	defer_accept;	/* User waits for some data after accept() */
+	__u8	confirm_connect;/* User wants control over conn. acceptance */
 
 /* RTT measurement */
 	__u8	backoff;	/* backoff				*/
@@ -411,6 +412,11 @@
 	struct open_request	*accept_queue;
 	struct open_request	*accept_queue_tail;
 
+	/* Our corresponding open_request if this socket is unconfirmed
+	 * (i.e. if we haven't sent SYN-ACK or RST yet)
+	 */
+	struct open_request	*unconfirmed_openreq;
+
 	int			write_pending;	/* A write to socket waits to start. */
 
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
--- linux-2.4.18-11umpr/include/net/tcp.h.orig	Thu Nov 22 20:47:22 2001
+++ linux-2.4.18-11umpr/include/net/tcp.h	Fri Apr 19 10:42:51 2002
@@ -505,7 +505,8 @@
 		sack_ok : 1,
 		wscale_ok : 1,
 		ecn_ok : 1,
-		acked : 1;
+		acked : 1,
+		unconfirmed : 1;
 	/* The following two fields can be easily recomputed I think -AK */
 	__u32			window_clamp;	/* window clamp at creation time */
 	__u32			rcv_wnd;	/* rcv_wnd offered first time */
@@ -533,6 +534,17 @@
 	tcp_openreq_fastfree(req);
 }
 
+static inline int tcp_is_unconfirmed(struct tcp_opt *tp)
+{
+	struct open_request *req;
+
+	req = tp->unconfirmed_openreq;
+	if (req != NULL && req->unconfirmed)
+		return 1;
+
+	return 0;
+}
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define TCP_INET_FAMILY(fam) ((fam) == AF_INET)
 #else
@@ -1661,6 +1673,7 @@
 	req->acked = 0;
 	req->ecn_ok = 0;
 	req->rmt_port = skb->h.th->source;
+	req->unconfirmed = 0;
 }
 
 #define TCP_MEM_QUANTUM	((int)PAGE_SIZE)
--- linux-2.4.18-11umpr/net/ipv4/tcp.c.orig	Fri Dec 21 18:42:05 2001
+++ linux-2.4.18-11umpr/net/ipv4/tcp.c	Fri Apr 19 20:50:29 2002
@@ -204,6 +204,7 @@
  *		Andi Kleen 	:	Make poll agree with SIGIO
  *	Salvatore Sanfilippo	:	Support SO_LINGER with linger == 1 and
  *					lingertime == 0 (RFC 793 ABORT Call)
+ *	Lennert Buytenhek	:	Explicit connection confirmation
  *					
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -366,6 +367,15 @@
 	return sk->tp_pinfo.af_tcp.accept_queue ? (POLLIN | POLLRDNORM) : 0;
 }
 
+static void tcp_confirm(struct sock *sk)
+{
+	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
+	struct open_request *req = tp->unconfirmed_openreq;
+
+	req->unconfirmed = 0;
+	req->class->rtx_syn_ack(sk, req, NULL);
+}
+
 /*
  *	Wait for a TCP event.
  *
@@ -650,6 +660,9 @@
 	struct task_struct *tsk = current;
 	DECLARE_WAITQUEUE(wait, tsk);
 
+	if (tcp_is_unconfirmed(tp))
+		tcp_confirm(sk);
+
 	while((1 << sk->state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)) {
 		if(sk->err)
 			return sock_error(sk);
@@ -1814,7 +1827,7 @@
 void tcp_close(struct sock *sk, long timeout)
 {
 	struct sk_buff *skb;
-	int data_was_unread = 0;
+	int should_send_rst = 0;
 
 	lock_sock(sk);
 	sk->shutdown = SHUTDOWN_MASK;
@@ -1834,12 +1847,19 @@
 	 */
 	while((skb=__skb_dequeue(&sk->receive_queue))!=NULL) {
 		u32 len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq - skb->h.th->fin;
-		data_was_unread += len;
+		should_send_rst += len;
 		__kfree_skb(skb);
 	}
 
 	tcp_mem_reclaim(sk);
 
+	if (sk->tp_pinfo.af_tcp.unconfirmed_openreq != NULL) {
+		if (tcp_is_unconfirmed(&(sk->tp_pinfo.af_tcp)))
+			should_send_rst = 1;
+		tcp_openreq_free(sk->tp_pinfo.af_tcp.unconfirmed_openreq);
+		sk->tp_pinfo.af_tcp.unconfirmed_openreq = NULL;
+	}
+
 	/* As outlined in draft-ietf-tcpimpl-prob-03.txt, section
 	 * 3.10, we send a RST here because data was lost.  To
 	 * witness the awful effects of the old behavior of always
@@ -1849,7 +1869,7 @@
 	 * the FTP client, wheee...  Note: timeout is always zero
 	 * in such a case.
 	 */
-	if(data_was_unread != 0) {
+	if(should_send_rst) {
 		/* Unread data was tossed, zap the connection. */
 		NET_INC_STATS_USER(TCPAbortOnClose);
 		tcp_set_state(sk, TCP_CLOSE);
@@ -2026,6 +2046,11 @@
 #endif
 	}
 
+	if (tp->unconfirmed_openreq) {
+		tcp_openreq_free(tp->unconfirmed_openreq);
+		tp->unconfirmed_openreq = NULL;
+	}
+
 	sk->shutdown = 0;
 	sk->done = 0;
 	tp->srtt = 0;
@@ -2139,8 +2164,10 @@
 
  	newsk = req->sk;
 	tcp_acceptq_removed(sk);
-	tcp_openreq_fastfree(req);
-	BUG_TRAP(newsk->state != TCP_SYN_RECV);
+	if (newsk->tp_pinfo.af_tcp.unconfirmed_openreq == NULL)
+		tcp_openreq_fastfree(req);
+	BUG_TRAP(newsk->tp_pinfo.af_tcp.unconfirmed_openreq ||
+		 newsk->state != TCP_SYN_RECV);
 	release_sock(sk);
 	return newsk;
 
@@ -2305,6 +2332,10 @@
 		}
 		break;
 
+	case TCP_CONFIRM_CONNECT:
+		tp->confirm_connect = !!val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2429,6 +2460,9 @@
 	case TCP_QUICKACK:
 		val = !tp->ack.pingpong;
 		break;
+	case TCP_CONFIRM_CONNECT:
+		val = tp->confirm_connect || tcp_is_unconfirmed(tp);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	};
--- linux-2.4.18-11umpr/net/ipv4/tcp_input.c.orig	Mon Feb 25 20:38:14 2002
+++ linux-2.4.18-11umpr/net/ipv4/tcp_input.c	Fri Apr 19 10:52:27 2002
@@ -3749,6 +3749,11 @@
 		switch(sk->state) {
 		case TCP_SYN_RECV:
 			if (acceptable) {
+				if (tp->unconfirmed_openreq != NULL) {
+					tcp_openreq_free(tp->unconfirmed_openreq);
+					tp->unconfirmed_openreq = NULL;
+				}
+
 				tp->copied_seq = tp->rcv_nxt;
 				mb();
 				tcp_set_state(sk, TCP_ESTABLISHED);
--- linux-2.4.18-11umpr/net/ipv4/tcp_minisocks.c.orig	Mon Oct  1 18:19:57 2001
+++ linux-2.4.18-11umpr/net/ipv4/tcp_minisocks.c	Fri Apr 19 10:24:22 2002
@@ -696,6 +696,7 @@
 		tcp_init_wl(newtp, req->snt_isn, req->rcv_isn);
 
 		newtp->retransmits = 0;
+		newtp->confirm_connect = 0;
 		newtp->backoff = 0;
 		newtp->srtt = 0;
 		newtp->mdev = TCP_TIMEOUT_INIT;
@@ -839,7 +840,8 @@
 		 * Enforce "SYN-ACK" according to figure 8, figure 6
 		 * of RFC793, fixed by RFC1122.
 		 */
-		req->class->rtx_syn_ack(sk, req, NULL);
+		if (!req->unconfirmed)
+			req->class->rtx_syn_ack(sk, req, NULL);
 		return NULL;
 	}
 
@@ -864,7 +866,7 @@
 	if (paws_reject || !tcp_in_window(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq,
 					  req->rcv_isn+1, req->rcv_isn+1+req->rcv_wnd)) {
 		/* Out of window: send ACK and drop. */
-		if (!(flg & TCP_FLAG_RST))
+		if (!req->unconfirmed && !(flg & TCP_FLAG_RST))
 			req->class->send_ack(skb, req);
 		if (paws_reject)
 			NET_INC_STATS_BH(PAWSEstabRejected);
@@ -907,6 +909,12 @@
 		return NULL;
 	}
 
+	/* @@@ If we are in SYN_RECV and haven't confirmed/rejected
+	 * the connection yet, this ACK is acking a never-sent packet.
+	 */
+	if (tcp_is_unconfirmed(tp))
+		return NULL;
+
 	/* OK, ACK is valid, create big socket and
 	 * feed this segment to it. It will repeat all
 	 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
--- linux-2.4.18-11umpr/net/ipv4/tcp_ipv4.c.orig	Mon Feb 25 20:38:14 2002
+++ linux-2.4.18-11umpr/net/ipv4/tcp_ipv4.c	Fri Apr 19 18:56:45 2002
@@ -1270,12 +1270,14 @@
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_opt *master_tp = &(sk->tp_pinfo.af_tcp);
 	struct tcp_opt tp;
 	struct open_request *req;
 	__u32 saddr = skb->nh.iph->saddr;
 	__u32 daddr = skb->nh.iph->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
+	int dont_confirm = 0;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1312,6 +1314,9 @@
 	if (req == NULL)
 		goto drop;
 
+	if (!want_cookie && master_tp->confirm_connect)
+		dont_confirm = 1;
+
 	tcp_clear_options(&tp);
 	tp.mss_clamp = 536;
 	tp.user_mss = sk->tp_pinfo.af_tcp.user_mss;
@@ -1396,11 +1401,31 @@
 	}
 	req->snt_isn = isn;
 
-	if (tcp_v4_send_synack(sk, req, dst))
+	if (!dont_confirm && tcp_v4_send_synack(sk, req, dst))
 		goto drop_and_free;
 
 	if (want_cookie) {
 	   	tcp_openreq_free(req); 
+	} else if (dont_confirm) {
+		struct sock *child;
+		__u8 rcv_wscale;
+
+		req->window_clamp = dst?dst->window:0;
+		tcp_select_initial_window(tcp_full_space(sk), req->mss,
+				&req->rcv_wnd, &req->window_clamp,
+				0, &rcv_wscale);
+		req->rcv_wscale = rcv_wscale;
+
+		child = tcp_v4_syn_recv_sock(sk, skb, req, NULL);
+		if (child != NULL) {
+			req->unconfirmed = 1;
+			child->tp_pinfo.af_tcp.unconfirmed_openreq = req;
+			tcp_acceptq_queue(sk, req, child);
+			sk->data_ready(sk, 0);
+			sock_put(child);
+		} else {
+			tcp_openreq_free(req);
+		}
 	} else {
 		tcp_v4_synq_add(sk, req);
 	}
--- linux-2.4.18-11umpr/net/ipv4/tcp_timer.c.orig	Mon Oct  1 18:19:57 2001
+++ linux-2.4.18-11umpr/net/ipv4/tcp_timer.c	Thu Apr 18 19:49:06 2002
@@ -512,7 +512,8 @@
 			if ((long)(now - req->expires) >= 0) {
 				if ((req->retrans < thresh ||
 				     (req->acked && req->retrans < max_retries))
-				    && !req->class->rtx_syn_ack(sk, req, NULL)) {
+				    && (req->unconfirmed ||
+					!req->class->rtx_syn_ack(sk, req, NULL))) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
--- linux-2.4.18-11umpr/net/ipv4/af_inet.c.orig	Fri Dec 21 18:42:05 2001
+++ linux-2.4.18-11umpr/net/ipv4/af_inet.c	Wed Apr 17 20:45:06 2002
@@ -693,7 +693,7 @@
 
 	lock_sock(sk2);
 
-	BUG_TRAP((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE));
+	BUG_TRAP((1<<sk2->state)&(TCPF_SYN_RECV|TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE));
 
 	sock_graft(sk2, newsock);
 
