From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 08:43:00 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Attached is a patch for an application to selectively provide a 
faster response and connection rate to favoured clients. 

The single accept queue in the socket is modified to be multiple
queues with a weight assigned to each queue. The accept()ance of 
connections is scheduled in proportion of the weights assigned to the
queues.

The incoming connection requests are associated with queues using
iptables MARK target rules(using the client's src/dest ip address).
The MARK used is the index of the relevant queue. The proportions on
the queues can be modified by the application to suit the
requirements using a socket option.

The results of an example run are on http://ckrm.sourceforge.net.

Thanks
	Vivek

-----------------------------------------------------------------------------

diff -urN linux-2.6.3_old/include/linux/sysctl.h linux-2.6.3/include/linux/sysctl.h
--- linux-2.6.3_old/include/linux/sysctl.h	2004-02-17 19:58:10.000000000 -0800
+++ linux-2.6.3/include/linux/sysctl.h	2004-02-23 
17:49:49.000000000 -0800
@@ -312,6 +312,7 @@
 	NET_TCP_LOW_LATENCY=93,
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
 	NET_TCP_WESTWOOD=95,
+	NET_TCP_ACCEPTQ_SHARE=96,
 };
 
 enum {
diff -urN linux-2.6.3_old/include/linux/tcp.h linux-2.6.3/include/linux/tcp.h
--- linux-2.6.3_old/include/linux/tcp.h	2004-02-17 19:57:52.000000000 -0800
+++ linux-2.6.3/include/linux/tcp.h	2004-02-24 15:34:35.000000000 -0800
@@ -20,6 +20,8 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
 
+#define NUM_ACCEPT_QUEUES	8
+
 struct tcphdr {
 	__u16	source;
 	__u16	dest;
@@ -127,6 +129,7 @@
 #define TCP_WINDOW_CLAMP	10	/* Bound advertised window */
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
+#define TCP_ACCEPTQ_SHARE	13	/* Set accept queue share */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -185,6 +188,13 @@
 	__u32	tcpi_reordering;
 };
 
+struct tcp_acceptq_info {
+	unsigned char acceptq_shares;
+	unsigned long acceptq_wait_time;
+	unsigned int acceptq_count;
+	unsigned int acceptq_qcount;
+};
+
 #ifdef __KERNEL__
 
 #include <linux/config.h>
@@ -362,7 +372,6 @@
 
 	/* FIFO of established children */
 	struct open_request	*accept_queue;
-	struct open_request	*accept_queue_tail;
 
 	int			write_pending;	/* A write to socket waits to start. */
 
@@ -388,6 +397,20 @@
                 __u32    rtt;
                 __u32    rtt_min;          /* minimum observed RTT */
         } westwood;
+
+	char 		acceptq_max_class;
+	unsigned long	acceptq_share_clock;
+	struct {
+		struct open_request     *aq_head;
+		struct open_request     *aq_tail;
+		unsigned int		 aq_weight;
+		unsigned int 		 aq_finish_ticket;
+		unsigned int             aq_wait_time;
+		unsigned int             aq_count;
+		unsigned int             aq_qcount;
+		unsigned int             aq_backlog;
+	} acceptq[NUM_ACCEPT_QUEUES];
+
 };
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
diff -urN linux-2.6.3_old/include/net/tcp.h linux-2.6.3/include/net/tcp.h
--- linux-2.6.3_old/include/net/tcp.h	2004-02-17 19:57:16.000000000 -0800
+++ linux-2.6.3/include/net/tcp.h	2004-02-24 15:23:18.000000000 -0800
@@ -580,6 +580,7 @@
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_acceptq_share[NUM_ACCEPT_QUEUES];
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -639,6 +640,9 @@
 		struct tcp_v6_open_req v6_req;
 #endif
 	} af;
+	unsigned int acceptq_start_ticket;
+	unsigned long acceptq_time_stamp;
+	int	      acceptq_class;
 };
 
 /* SLAB cache for open requests. */
@@ -1688,43 +1692,28 @@
 	return tcp_win_from_space(sk->sk_rcvbuf); 
 }
 
-static inline void tcp_acceptq_removed(struct sock *sk)
+static inline void tcp_acceptq_removed(struct sock *sk, int class)
 {
-	sk->sk_ack_backlog--;
+	tcp_sk(sk)->acceptq[class].aq_backlog--;
 }
 
-static inline void tcp_acceptq_added(struct sock *sk)
+static inline void tcp_acceptq_added(struct sock *sk, int class)
 {
-	sk->sk_ack_backlog++;
+	tcp_sk(sk)->acceptq[class].aq_backlog++;
 }
 
-static inline int tcp_acceptq_is_full(struct sock *sk)
+static inline int tcp_acceptq_is_full(struct sock *sk, int class)
 {
-	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
+	return tcp_sk(sk)->acceptq[class].aq_backlog >
+		sk->sk_max_ack_backlog;
 }
 
-static inline void tcp_acceptq_queue(struct sock *sk, struct open_request *req,
-					 struct sock *child)
-{
-	struct tcp_opt *tp = tcp_sk(sk);
-
-	req->sk = child;
-	tcp_acceptq_added(sk);
-
-	if (!tp->accept_queue_tail) {
-		tp->accept_queue = req;
-	} else {
-		tp->accept_queue_tail->dl_next = req;
-	}
-	tp->accept_queue_tail = req;
-	req->dl_next = NULL;
-}
 
 struct tcp_listen_opt
 {
 	u8			max_qlen_log;	/* log_2 of maximal queued SYNs */
 	int			qlen;
-	int			qlen_young;
+	int			qlen_young[NUM_ACCEPT_QUEUES];
 	int			clock_hand;
 	u32			hash_rnd;
 	struct open_request	*syn_table[TCP_SYNQ_HSIZE];
@@ -1738,16 +1727,16 @@
 	if (--lopt->qlen == 0)
 		tcp_delete_keepalive_timer(sk);
 	if (req->retrans == 0)
-		lopt->qlen_young--;
+		lopt->qlen_young[req->acceptq_class]--;
 }
 
-static inline void tcp_synq_added(struct sock *sk)
+static inline void tcp_synq_added(struct sock *sk, struct open_request *req)
 {
 	struct tcp_listen_opt *lopt = tcp_sk(sk)->listen_opt;
 
 	if (lopt->qlen++ == 0)
 		tcp_reset_keepalive_timer(sk, TCP_TIMEOUT_INIT);
-	lopt->qlen_young++;
+	lopt->qlen_young[req->acceptq_class]++;
 }
 
 static inline int tcp_synq_len(struct sock *sk)
@@ -1755,9 +1744,9 @@
 	return tcp_sk(sk)->listen_opt->qlen;
 }
 
-static inline int tcp_synq_young(struct sock *sk)
+static inline int tcp_synq_young(struct sock *sk, int class)
 {
-	return tcp_sk(sk)->listen_opt->qlen_young;
+	return tcp_sk(sk)->listen_opt->qlen_young[class];
 }
 
 static inline int tcp_synq_is_full(struct sock *sk)
@@ -1796,6 +1785,12 @@
 	req->acked = 0;
 	req->ecn_ok = 0;
 	req->rmt_port = skb->h.th->source;
+	req->acceptq_start_ticket = 0;
+	req->acceptq_time_stamp = 0;
+	if (tp->acceptq_max_class)
+		req->acceptq_class = (skb->nfmark <= 0) ? 0 :
+			((skb->nfmark > NUM_ACCEPT_QUEUES) ?
+			 0: skb->nfmark);
 }
 
 #define TCP_MEM_QUANTUM	((int)PAGE_SIZE)
diff -urN linux-2.6.3_old/net/ipv4/sysctl_net_ipv4.c linux-2.6.3/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.3_old/net/ipv4/sysctl_net_ipv4.c	2004-02-17 19:58:50.000000000 -0800
+++ linux-2.6.3/net/ipv4/sysctl_net_ipv4.c	2004-02-22 07:46:27.000000000 -0800
@@ -592,6 +592,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+        {
+                .ctl_name       = NET_TCP_ACCEPTQ_SHARE,
+                .procname       = "tcp_acceptq_share",
+                .data           = &sysctl_tcp_acceptq_share,
+                .maxlen         = sizeof(sysctl_tcp_acceptq_share),
+                .mode           = 0644,
+                .proc_handler   = &proc_dointvec
+	        },
 	{ .ctl_name = 0 }
 };
 
diff -urN linux-2.6.3_old/net/ipv4/tcp.c linux-2.6.3/net/ipv4/tcp.c
--- linux-2.6.3_old/net/ipv4/tcp.c	2004-02-17 19:57:21.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp.c	2004-02-25 00:25:52.000000000 -0800
@@ -280,6 +280,12 @@
 int sysctl_tcp_wmem[3] = { 4 * 1024, 16 * 1024, 128 * 1024 };
 int sysctl_tcp_rmem[3] = { 4 * 1024, 87380, 87380 * 2 };
 
+/*
+ *  By default all fall in class 0 with all time allocated to the given
+ *  class
+ */
+int sysctl_tcp_acceptq_share[NUM_ACCEPT_QUEUES] = { 100 };
+
 atomic_t tcp_memory_allocated;	/* Current allocated memory. */
 atomic_t tcp_sockets_allocated;	/* Current number of TCP sockets. */
 
@@ -534,13 +540,34 @@
 
 int tcp_listen_start(struct sock *sk)
 {
+	int i, j = 0;
 	struct inet_opt *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;
 
 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
-	tp->accept_queue = tp->accept_queue_tail = NULL;
+	tp->accept_queue = NULL;
+	tp->acceptq_max_class = 0;
+
+	for (i=0; i < NUM_ACCEPT_QUEUES; i++) {
+		tp->acceptq[i].aq_tail = NULL;
+		tp->acceptq[i].aq_head = NULL;
+		j += sysctl_tcp_acceptq_share[i];
+		if (j > 100)    /* ignore other values */
+			tp->acceptq[i].aq_weight = 0;
+		else { 
+			if (sysctl_tcp_acceptq_share[i]) { 
+				tp->acceptq[i].aq_weight = 
+					1000/sysctl_tcp_acceptq_share[i]; 
+				tp->acceptq_max_class = i; 
+			} 
+		} 
+		tp->acceptq[i].aq_wait_time = 0; 
+		tp->acceptq[i].aq_qcount = 0; 
+		tp->acceptq[i].aq_count = 0; 
+	}
+
 	tp->syn_wait_lock = RW_LOCK_UNLOCKED;
 	tcp_delack_init(tp);
 
@@ -600,7 +627,7 @@
 	write_lock_bh(&tp->syn_wait_lock);
 	tp->listen_opt = NULL;
 	write_unlock_bh(&tp->syn_wait_lock);
-	tp->accept_queue = tp->accept_queue_tail = NULL;
+	tp->accept_queue = NULL;
 
 	if (lopt->qlen) {
 		for (i = 0; i < TCP_SYNQ_HSIZE; i++) {
@@ -646,7 +673,7 @@
 		local_bh_enable();
 		sock_put(child);
 
-		tcp_acceptq_removed(sk);
+		tcp_acceptq_removed(sk, req->acceptq_class);
 		tcp_openreq_fastfree(req);
 	}
 	BUG_TRAP(!sk->sk_ack_backlog);
@@ -2221,6 +2248,62 @@
 }
 
 /*
+ *  This function will queue a new request into the accept queue.
+ */
+void tcp_acceptq_queue(struct sock *sk, struct open_request *req,
+			struct sock *child)
+{
+	struct tcp_opt *tp = tcp_sk(sk);
+	int class = req->acceptq_class;
+	int prev_class;
+
+	req->sk = child;
+	tcp_acceptq_added(sk,class);
+
+	if (!tp->acceptq[class].aq_weight) 
+		class = 0;
+
+	tp->acceptq[class].aq_qcount++;
+
+	if (!tp->acceptq[class].aq_tail) {
+		if (tp->acceptq[class].aq_finish_ticket<tp->acceptq_share_clock)
+		       	req->acceptq_start_ticket = tp->acceptq_share_clock;
+		else
+			req->acceptq_start_ticket = 
+					tp->acceptq[class].aq_finish_ticket;
+		tp->acceptq[class].aq_finish_ticket =req->acceptq_start_ticket +
+			tp->acceptq[class].aq_weight;
+
+		tp->acceptq[class].aq_head = req;
+		tp->acceptq[class].aq_tail = req;
+
+		prev_class = class - 1;
+		while (prev_class >= 0) {
+			if (tp->acceptq[prev_class].aq_tail)
+				break;
+			prev_class--;
+		}
+		if (prev_class >= 0) {
+			req->dl_next = 
+				tp->acceptq[prev_class].aq_tail->dl_next;
+			tp->acceptq[prev_class].aq_tail->dl_next = req;
+		} else {
+				req->dl_next = tp->accept_queue;
+				tp->accept_queue = req;
+			}
+	}
+	else {
+		req->acceptq_start_ticket = tp->acceptq[class].aq_finish_ticket;
+		tp->acceptq[class].aq_finish_ticket += 
+					tp->acceptq[class].aq_weight;
+		req->dl_next = tp->acceptq[class].aq_tail->dl_next;
+		tp->acceptq[class].aq_tail->dl_next = req;
+		tp->acceptq[class].aq_tail = req;
+	}
+	req->acceptq_time_stamp = jiffies;
+}
+
+/*
  *	This will accept the next outstanding connection.
  */
 
@@ -2230,6 +2313,8 @@
 	struct open_request *req;
 	struct sock *newsk;
 	int error;
+	int prev_class, i, first, min_class;
+	unsigned int min_st;
 
 	lock_sock(sk);
 
@@ -2244,6 +2329,10 @@
 	if (!tp->accept_queue) {
 		long timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
+		tp->acceptq_share_clock = 0;
+		for (i=0; i < NUM_ACCEPT_QUEUES; i++)
+			tp->acceptq[i].aq_finish_ticket = 0;
+
 		/* If this is a non blocking socket don't sleep */
 		error = -EAGAIN;
 		if (!timeo)
@@ -2254,12 +2343,44 @@
 			goto out;
 	}
 
-	req = tp->accept_queue;
-	if ((tp->accept_queue = req->dl_next) == NULL)
-		tp->accept_queue_tail = NULL;
+	first = 1;
+	for( i =0; i <= tp->acceptq_max_class; i++) {
+		if ((req = tp->acceptq[i].aq_head)) {
+			if (first) {
+				min_st = req->acceptq_start_ticket;
+				min_class = i;
+				first = 0;
+			}
+			else 
+				if (req->acceptq_start_ticket < min_st) {
+					min_st = req->acceptq_start_ticket;
+					min_class = i;
+				}
+		}
+	}
+
+        req = tp->acceptq[min_class].aq_head;
+	tp->acceptq[min_class].aq_count++;
+	tp->acceptq[min_class].aq_qcount--;
+	tp->acceptq_share_clock = req->acceptq_start_ticket;
+	tp->acceptq[min_class].aq_wait_time+=(jiffies- req->acceptq_time_stamp);
+
+	for (prev_class= min_class-1 ; prev_class >=0; prev_class--)
+		if (tp->acceptq[prev_class].aq_tail)
+			break;
+	if (prev_class>=0)
+		tp->acceptq[prev_class].aq_tail->dl_next = req->dl_next; 
+	else 
+		tp->accept_queue = req->dl_next;
+
+	if (req == tp->acceptq[min_class].aq_tail) 
+		tp->acceptq[min_class].aq_head = 
+			tp->acceptq[min_class].aq_tail = NULL;
+	else
+		tp->acceptq[min_class].aq_head = req->dl_next;
 
  	newsk = req->sk;
-	tcp_acceptq_removed(sk);
+	tcp_acceptq_removed(sk, req->acceptq_class);
 	tcp_openreq_fastfree(req);
 	BUG_TRAP(newsk->sk_state != TCP_SYN_RECV);
 	release_sock(sk);
@@ -2429,6 +2550,34 @@
 			}
 		}
 		break;
+		
+	case TCP_ACCEPTQ_SHARE:
+		{
+			char share_wt[NUM_ACCEPT_QUEUES];
+			int i, j = 0;
+
+			if (copy_from_user(share_wt,optval, optlen)) {
+				err = -EFAULT;
+				break;
+			}
+			for (i=0; i < NUM_ACCEPT_QUEUES; i++) 
+				j += share_wt[i];
+
+			if (!j || j > 100 )
+				err = -EINVAL;
+			else {
+				for (i=0; i < NUM_ACCEPT_QUEUES; i++) {
+				    if (share_wt[i]) {
+					tp->acceptq_max_class = i;
+					tp->acceptq[i].aq_weight = 
+							1000/ share_wt[i];
+					}
+					else
+						tp->acceptq[i].aq_weight = 0;
+				}
+			}
+		}
+		break;
 
 	default:
 		err = -ENOPROTOOPT;
@@ -2555,6 +2704,34 @@
 	case TCP_QUICKACK:
 		val = !tp->ack.pingpong;
 		break;
+
+	case TCP_ACCEPTQ_SHARE: {
+		struct tcp_acceptq_info tinfo[NUM_ACCEPT_QUEUES];
+		int i;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+		bzero(tinfo, sizeof(tinfo));
+		for(i=0; i < NUM_ACCEPT_QUEUES; i++) {
+			tinfo[i].acceptq_wait_time = 
+				tp->acceptq[i].aq_wait_time/(HZ/USER_HZ);
+			if (tp->acceptq[i].aq_weight)
+				tinfo[i].acceptq_shares = 
+					1000/ tp->acceptq[i].aq_weight;
+			else
+				tinfo[i].acceptq_shares = 0; 
+			tinfo[i].acceptq_qcount = tp->acceptq[i].aq_qcount;
+			tinfo[i].acceptq_count = tp->acceptq[i].aq_count;
+		}
+		len = min_t(unsigned int, len, sizeof(tinfo));
+		if (put_user(len, optlen)) 
+			return -EFAULT;
+			
+		if (copy_to_user(optval, (char *)tinfo, len))
+			return -EFAULT;
+		
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	};
diff -urN linux-2.6.3_old/net/ipv4/tcp_ipv4.c linux-2.6.3/net/ipv4/tcp_ipv4.c
--- linux-2.6.3_old/net/ipv4/tcp_ipv4.c	2004-02-17 19:57:22.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_ipv4.c	2004-02-23 17:59:38.000000000 -0800
@@ -916,7 +916,7 @@
 	lopt->syn_table[h] = req;
 	write_unlock(&tp->syn_wait_lock);
 
-	tcp_synq_added(sk);
+	tcp_synq_added(sk, req);
 }
 
 
@@ -1413,6 +1413,7 @@
 	__u32 daddr = skb->nh.iph->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
+	int class = 0;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1437,12 +1438,17 @@
 		goto drop;
 	}
 
+	if (tcp_sk(sk)->acceptq_max_class)
+		class = (skb->nfmark <= 0) ? 0 :
+			((skb->nfmark > NUM_ACCEPT_QUEUES) ? NUM_ACCEPT_QUEUES:
+			 skb->nfmark);
+
 	/* Accept backlog is full. If we have already queued enough
 	 * of warm entries in syn queue, drop request. It is better than
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (tcp_acceptq_is_full(sk) && tcp_synq_young(sk) > 1)
+	if (tcp_acceptq_is_full(sk, class) && tcp_synq_young(sk, class) > 1)
 		goto drop;
 
 	req = tcp_openreq_alloc();
@@ -1567,7 +1573,7 @@
 	struct tcp_opt *newtp;
 	struct sock *newsk;
 
-	if (tcp_acceptq_is_full(sk))
+	if (tcp_acceptq_is_full(sk, req->acceptq_class))
 		goto exit_overflow;
 
 	if (!dst && (dst = tcp_v4_route_req(sk, req)) == NULL)
diff -urN linux-2.6.3_old/net/ipv4/tcp_minisocks.c linux-2.6.3/net/ipv4/tcp_minisocks.c
--- linux-2.6.3_old/net/ipv4/tcp_minisocks.c	2004-02-17 19:58:56.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_minisocks.c	2004-02-24 15:38:58.000000000 -0800
@@ -779,7 +779,9 @@
 		newtp->num_sacks = 0;
 		newtp->urg_data = 0;
 		newtp->listen_opt = NULL;
-		newtp->accept_queue = newtp->accept_queue_tail = NULL;
+		newtp->accept_queue = NULL;
+		memset(newtp->acceptq, 0,sizeof(newtp->acceptq));
+		newtp->acceptq_share_clock = newtp->acceptq_max_class = 0;
 		/* Deinitialize syn_wait_lock to trap illegal accesses. */
 		memset(&newtp->syn_wait_lock, 0, sizeof(newtp->syn_wait_lock));
 
diff -urN linux-2.6.3_old/net/ipv4/tcp_timer.c linux-2.6.3/net/ipv4/tcp_timer.c
--- linux-2.6.3_old/net/ipv4/tcp_timer.c	2004-02-17 19:59:28.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_timer.c	2004-02-24 19:50:51.000000000 -0800
@@ -498,7 +498,12 @@
 	 * ones are about to clog our table.
 	 */
 	if (lopt->qlen>>(lopt->max_qlen_log-1)) {
-		int young = (lopt->qlen_young<<1);
+		int young = 0;
+	       
+		for(i=0; i < NUM_ACCEPT_QUEUES; i++) 
+			young += lopt->qlen_young[i];
+		
+		young <<= 1;
 
 		while (thresh > 2) {
 			if (lopt->qlen < young)
@@ -524,9 +529,8 @@
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
-						lopt->qlen_young--;
-					timeo = min((TCP_TIMEOUT_INIT << req->retrans),
-						    TCP_RTO_MAX);
+			         		lopt->qlen_young[req->acceptq_class]--;
+					timeo = min((TCP_TIMEOUT_INIT << req->retrans), TCP_RTO_MAX);
 					req->expires = now + timeo;
 					reqp = &req->dl_next;
 					continue;
@@ -538,7 +542,7 @@
 				write_unlock(&tp->syn_wait_lock);
 				lopt->qlen--;
 				if (req->retrans == 0)
-					lopt->qlen_young--;
+					lopt->qlen_young[req->acceptq_class]--;
 				tcp_openreq_free(req);
 				continue;
 			}
