From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: Re: [PATCH] proportional share accept()
Date: Mon, 1 Mar 2004 02:11:11 -0800 (Pacific Standard Time)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.WNT.4.44.0403010135240.1688-100000@w-vkashyap95.des.sequent.com>
References: <20040229220513.68eed11f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ronghua Zhang <rz5b@cs.virginia.edu>, <shemminger@osdl.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040229220513.68eed11f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Feb 2004, David S. Miller wrote:

> On Thu, 26 Feb 2004 17:08:23 -0500 (EST)
> Ronghua Zhang <rz5b@cs.virginia.edu> wrote:
>
> > www.cs.virginia.edu/~rz5b/research/kernel-qos.htm
>
> I looked at this, it's basically netfilter TCP port rewriting
> which knows about per-socket quotas and limits.
>
> You could write this as a 10 line netfilter module, with zero
> modifications to any of the core net/ipv4 TCP code at all.
> And that's how I'd like to see something like this done.


Multiple sockets can be forwarded the requests either at an alternative port
or address using netfilter. However one has to now mangle the data packets
too since the client is still talking to the advertised port (and
address).

I've modified the earlier post to remove the sysctl and removed the use of
STFQ/virtual clock and instead used 'weighted round robin' in
tcp_accept().  The solution is very much per socket.

The default is to have only one queue that is active. If the shares (simple
ratios) are set then the packets are accept()ed in a WRR fashion.  Since
all work is done in context of a single socket no additional locks have to
be held. If the shares are unset then the processing reverts to single
queue mode.

The per queue backlog is to avoid lower priority requests from filling up
the synq and thereby blocking the higher priority requests. Also the
iptables' MARK target is quite lightweight.

Vivek


-----------------------------------------------------------------------------

diff -urN linux-2.6.3_old/include/linux/tcp.h linux-2.6.3/include/linux/tcp.h
--- linux-2.6.3_old/include/linux/tcp.h	2004-02-17 19:57:52.000000000 -0800
+++ linux-2.6.3/include/linux/tcp.h	2004-02-29 22:01:11.000000000 -0800
@@ -128,6 +128,10 @@
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */

+#ifdef CONFIG_ACCEPT_QUEUES
+#define TCP_ACCEPTQ_SHARE	13	/* Set accept queue share */
+#endif
+
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
 #define TCPI_OPT_WSCALE		4
@@ -185,6 +189,18 @@
 	__u32	tcpi_reordering;
 };

+#ifdef CONFIG_ACCEPT_QUEUES
+
+#define NUM_ACCEPT_QUEUES	8 	/* Must be power of 2 */
+
+struct tcp_acceptq_info {
+	unsigned char acceptq_shares;
+	unsigned long acceptq_wait_time;
+	unsigned int acceptq_qcount;
+	unsigned int acceptq_count;
+};
+#endif
+
 #ifdef __KERNEL__

 #include <linux/config.h>
@@ -362,8 +378,9 @@

 	/* FIFO of established children */
 	struct open_request	*accept_queue;
-	struct open_request	*accept_queue_tail;
-
+#ifndef CONFIG_ACCEPT_QUEUES
+	struct open_request     *accept_queue_tail;
+#endif
 	int			write_pending;	/* A write to socket waits to start. */

 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
@@ -388,6 +405,22 @@
                 __u32    rtt;
                 __u32    rtt_min;          /* minimum observed RTT */
         } westwood;
+
+#ifdef CONFIG_ACCEPT_QUEUES
+	/* move to listen opt... */
+	char		class_index;
+	struct {
+		struct open_request     *aq_head;
+		struct open_request     *aq_tail;
+		unsigned int		 aq_cnt;
+		unsigned int		 aq_ratio;
+		unsigned int             aq_count;
+		unsigned int             aq_qcount;
+		unsigned int             aq_backlog;
+		unsigned int             aq_wait_time;
+		int			 aq_valid;
+	} acceptq[NUM_ACCEPT_QUEUES];
+#endif
 };

 /* WARNING: don't change the layout of the members in tcp_sock! */
diff -urN linux-2.6.3_old/include/net/tcp.h linux-2.6.3/include/net/tcp.h
--- linux-2.6.3_old/include/net/tcp.h	2004-02-17 19:57:16.000000000 -0800
+++ linux-2.6.3/include/net/tcp.h	2004-02-29 21:32:44.000000000 -0800
@@ -639,6 +639,10 @@
 		struct tcp_v6_open_req v6_req;
 #endif
 	} af;
+#ifdef CONFIG_ACCEPT_QUEUES
+	unsigned long acceptq_time_stamp;
+	int	      acceptq_class;
+#endif
 };

 /* SLAB cache for open requests. */
@@ -1688,6 +1692,69 @@
 	return tcp_win_from_space(sk->sk_rcvbuf);
 }

+#ifdef CONFIG_ACCEPT_QUEUES
+static inline void tcp_acceptq_removed(struct sock *sk, int class)
+{
+	tcp_sk(sk)->acceptq[class].aq_backlog--;
+}
+
+static inline void tcp_acceptq_added(struct sock *sk, int class)
+{
+	tcp_sk(sk)->acceptq[class].aq_backlog++;
+}
+
+static inline int tcp_acceptq_is_full(struct sock *sk, int class)
+{
+	return tcp_sk(sk)->acceptq[class].aq_backlog >
+		sk->sk_max_ack_backlog;
+}
+
+static inline void tcp_set_acceptq(struct tcp_opt *tp, struct open_request *req)
+{
+	int class = req->acceptq_class;
+	int prev_class;
+
+	if (!tp->acceptq[class].aq_ratio) {
+		req->acceptq_class = 0;
+		class = 0;
+	}
+
+	tp->acceptq[class].aq_qcount++;
+	req->acceptq_time_stamp = jiffies;
+
+	if (tp->acceptq[class].aq_tail) {
+		req->dl_next = tp->acceptq[class].aq_tail->dl_next;
+		tp->acceptq[class].aq_tail->dl_next = req;
+		tp->acceptq[class].aq_tail = req;
+	} else { /* if first request in the class */
+		tp->acceptq[class].aq_head = req;
+		tp->acceptq[class].aq_tail = req;
+
+		prev_class = class - 1;
+		while (prev_class >= 0) {
+			if (tp->acceptq[prev_class].aq_tail)
+				break;
+			prev_class--;
+		}
+		if (prev_class < 0) {
+			req->dl_next = tp->accept_queue;
+			tp->accept_queue = req;
+		}
+		else {
+			req->dl_next = tp->acceptq[prev_class].aq_tail->dl_next;
+			tp->acceptq[prev_class].aq_tail->dl_next = req;
+		}
+	}
+}
+static inline void tcp_acceptq_queue(struct sock *sk, struct open_request *req,
+					 struct sock *child)
+{
+	tcp_set_acceptq(tcp_sk(sk),req);
+	req->sk = child;
+	tcp_acceptq_added(sk,req->acceptq_class);
+}
+
+#else
 static inline void tcp_acceptq_removed(struct sock *sk)
 {
 	sk->sk_ack_backlog--;
@@ -1720,16 +1787,55 @@
 	req->dl_next = NULL;
 }

+#endif
+
 struct tcp_listen_opt
 {
 	u8			max_qlen_log;	/* log_2 of maximal queued SYNs */
 	int			qlen;
+#ifdef CONFIG_ACCEPT_QUEUES
+	int			qlen_young[NUM_ACCEPT_QUEUES];
+#else
 	int			qlen_young;
+#endif
 	int			clock_hand;
 	u32			hash_rnd;
 	struct open_request	*syn_table[TCP_SYNQ_HSIZE];
 };

+#ifdef CONFIG_ACCEPT_QUEUES
+static inline void
+tcp_synq_removed(struct sock *sk, struct open_request *req)
+{
+	struct tcp_listen_opt *lopt = tcp_sk(sk)->listen_opt;
+
+	if (--lopt->qlen == 0)
+		tcp_delete_keepalive_timer(sk);
+	if (req->retrans == 0)
+		lopt->qlen_young[req->acceptq_class]--;
+}
+
+static inline void tcp_synq_added(struct sock *sk, struct open_request *req)
+{
+	struct tcp_listen_opt *lopt = tcp_sk(sk)->listen_opt;
+
+	if (lopt->qlen++ == 0)
+		tcp_reset_keepalive_timer(sk, TCP_TIMEOUT_INIT);
+	lopt->qlen_young[req->acceptq_class]++;
+}
+
+static inline int tcp_synq_len(struct sock *sk)
+{
+	return tcp_sk(sk)->listen_opt->qlen;
+}
+
+static inline int tcp_synq_young(struct sock *sk, int class)
+{
+	return tcp_sk(sk)->listen_opt->qlen_young[class];
+}
+
+#else
+
 static inline void
 tcp_synq_removed(struct sock *sk, struct open_request *req)
 {
@@ -1759,6 +1865,7 @@
 {
 	return tcp_sk(sk)->listen_opt->qlen_young;
 }
+#endif

 static inline int tcp_synq_is_full(struct sock *sk)
 {
diff -urN linux-2.6.3_old/net/ipv4/Kconfig linux-2.6.3/net/ipv4/Kconfig
--- linux-2.6.3_old/net/ipv4/Kconfig	2004-02-17 19:59:05.000000000 -0800
+++ linux-2.6.3/net/ipv4/Kconfig	2004-02-29 13:41:58.000000000 -0800
@@ -379,5 +379,28 @@

 	  If unsure, say Y.

+config ACCEPT_QUEUES
+	bool "IP: TCP Multiple accept queues support"
+	depends on INET && NETFILTER
+	---help---
+	  Support multiple accept queues per listening socket. If you say Y
+	  here, multiple accept queues will be configured per listening
+	  socket.
+
+	  Each queue is mapped to a priority class. Incoming connection
+	  requests can be classified (see iptables(8), MARK target), depending
+	  on the packet's src/dest address or other parameters, into one of
+	  the priority classes. The requests are then queued to the relevant
+	  accept queue.
+
+	  Each of the queues can be assigned a weight. The accept()ance
+	  of packets is then scheduled in accordance with the weight
+	  assigned to the priority class.
+
+	  Be sure to enable "Network packet filtering" if you wish
+	  to use this feature.
+
+	  If unsure, say N.
+
 source "net/ipv4/ipvs/Kconfig"

diff -urN linux-2.6.3_old/net/ipv4/tcp.c linux-2.6.3/net/ipv4/tcp.c
--- linux-2.6.3_old/net/ipv4/tcp.c	2004-02-17 19:57:21.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp.c	2004-03-01 00:47:47.000000000 -0800
@@ -534,13 +534,34 @@

 int tcp_listen_start(struct sock *sk)
 {
+#ifdef CONFIG_ACCEPT_QUEUES
+	int i = 0;
+#endif
 	struct inet_opt *inet = inet_sk(sk);
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_listen_opt *lopt;

 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
-	tp->accept_queue = tp->accept_queue_tail = NULL;
+	tp->accept_queue = NULL;
+#ifdef CONFIG_ACCEPT_QUEUES
+	tp->class_index = 0;
+	for (i=0; i < NUM_ACCEPT_QUEUES; i++) {
+		tp->acceptq[i].aq_tail = NULL;
+		tp->acceptq[i].aq_head = NULL;
+		tp->acceptq[i].aq_wait_time = 0;
+		tp->acceptq[i].aq_qcount = 0;
+		tp->acceptq[i].aq_count = 0;
+		if (i == 0) {
+			tp->acceptq[i].aq_valid = 1;
+			tp->acceptq[i].aq_ratio = 1;
+		}
+		else {
+			tp->acceptq[i].aq_valid = 0;
+			tp->acceptq[i].aq_ratio = 0;
+		}
+	}
+#endif
 	tp->syn_wait_lock = RW_LOCK_UNLOCKED;
 	tcp_delack_init(tp);

@@ -600,7 +621,13 @@
 	write_lock_bh(&tp->syn_wait_lock);
 	tp->listen_opt = NULL;
 	write_unlock_bh(&tp->syn_wait_lock);
-	tp->accept_queue = tp->accept_queue_tail = NULL;
+#ifdef CONFIG_ACCEPT_QUEUES
+	for (i = 0; i < NUM_ACCEPT_QUEUES; i++)
+		tp->acceptq[i].aq_head = tp->acceptq[i].aq_tail = NULL;
+#else
+	tp->accept_queue_tail = NULL;
+#endif
+	tp->accept_queue = NULL;

 	if (lopt->qlen) {
 		for (i = 0; i < TCP_SYNQ_HSIZE; i++) {
@@ -646,7 +673,11 @@
 		local_bh_enable();
 		sock_put(child);

+#ifdef CONFIG_ACCEPT_QUEUES
+		tcp_acceptq_removed(sk, req->acceptq_class);
+#else
 		tcp_acceptq_removed(sk);
+#endif
 		tcp_openreq_fastfree(req);
 	}
 	BUG_TRAP(!sk->sk_ack_backlog);
@@ -2230,6 +2261,10 @@
 	struct open_request *req;
 	struct sock *newsk;
 	int error;
+#ifdef CONFIG_ACCEPT_QUEUES
+	int prev_class = 0;
+	int first;
+#endif

 	lock_sock(sk);

@@ -2243,7 +2278,6 @@
 	/* Find already established connection */
 	if (!tp->accept_queue) {
 		long timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
-
 		/* If this is a non blocking socket don't sleep */
 		error = -EAGAIN;
 		if (!timeo)
@@ -2254,12 +2288,46 @@
 			goto out;
 	}

+#ifndef CONFIG_ACCEPT_QUEUES
 	req = tp->accept_queue;
 	if ((tp->accept_queue = req->dl_next) == NULL)
 		tp->accept_queue_tail = NULL;

- 	newsk = req->sk;
 	tcp_acceptq_removed(sk);
+#else
+	first = tp->class_index;
+	/* We should always have  request queued here. The accept_queue
+	 * is already checked for NULL above.
+	 */
+	while(!tp->acceptq[first].aq_head) {
+		tp->acceptq[first].aq_cnt = 0;
+		first = ++first & ~NUM_ACCEPT_QUEUES;
+	}
+        req = tp->acceptq[first].aq_head;
+	tp->acceptq[first].aq_qcount--;
+	tp->acceptq[first].aq_count++;
+	tp->acceptq[first].aq_wait_time+=(jiffies - req->acceptq_time_stamp);
+
+	for (prev_class= first-1 ; prev_class >=0; prev_class--)
+		if (tp->acceptq[prev_class].aq_tail)
+			break;
+	if (prev_class>=0)
+		tp->acceptq[prev_class].aq_tail->dl_next = req->dl_next;
+	else
+		tp->accept_queue = req->dl_next;
+
+	if (req == tp->acceptq[first].aq_tail)
+		tp->acceptq[first].aq_head = tp->acceptq[first].aq_tail = NULL;
+	else
+		tp->acceptq[first].aq_head = req->dl_next;
+
+	if((++(tp->acceptq[first].aq_cnt)) >= tp->acceptq[first].aq_ratio){
+		tp->acceptq[first].aq_cnt = 0;
+		tp->class_index = ++first & ~NUM_ACCEPT_QUEUES;
+	}
+	tcp_acceptq_removed(sk, req->acceptq_class);
+#endif
+ 	newsk = req->sk;
 	tcp_openreq_fastfree(req);
 	BUG_TRAP(newsk->sk_state != TCP_SYN_RECV);
 	release_sock(sk);
@@ -2429,6 +2497,49 @@
 			}
 		}
 		break;
+
+#ifdef CONFIG_ACCEPT_QUEUES
+	case TCP_ACCEPTQ_SHARE:
+		{
+			char share_wt[NUM_ACCEPT_QUEUES];
+			int i,j;
+
+			if (sk->sk_state != TCP_LISTEN)
+				return -EOPNOTSUPP;
+
+			if (copy_from_user(share_wt,optval, optlen)) {
+				err = -EFAULT;
+				break;
+			}
+			j = 0;
+			for (i = 0; i < NUM_ACCEPT_QUEUES; i++) {
+				if (share_wt[i]) {
+					if (!j)
+						j = share_wt[i];
+					else if (share_wt[i] < j) {
+						j = share_wt[i];
+					}
+					tp->acceptq[i].aq_valid = 1;
+				}
+				else
+					tp->acceptq[i].aq_valid = 0;
+
+			}
+			if (j == 0) {
+				/* Class 0 is always valid. If nothing is
+				 * specified set class 0 as 1.
+				 */
+				share_wt[0] = 1;
+				tp->acceptq[0].aq_valid = 1;
+				j = 1;
+			}
+			for (i=0; i < NUM_ACCEPT_QUEUES; i++)  {
+				tp->acceptq[i].aq_ratio = share_wt[i]/j;
+				tp->acceptq[i].aq_cnt = 0;
+			}
+		}
+		break;
+#endif

 	default:
 		err = -ENOPROTOOPT;
@@ -2555,6 +2666,41 @@
 	case TCP_QUICKACK:
 		val = !tp->ack.pingpong;
 		break;
+
+#ifdef CONFIG_ACCEPT_QUEUES
+	case TCP_ACCEPTQ_SHARE: {
+		struct tcp_acceptq_info tinfo[NUM_ACCEPT_QUEUES];
+		int i;
+
+		if (sk->sk_state != TCP_LISTEN)
+			return -EOPNOTSUPP;
+
+		if (get_user(len, optlen))
+			return -EFAULT;
+
+		memset(tinfo, 0, sizeof(tinfo));
+
+		for(i=0; i < NUM_ACCEPT_QUEUES; i++) {
+			tinfo[i].acceptq_wait_time =
+				tp->acceptq[i].aq_wait_time/(HZ/USER_HZ);
+			tinfo[i].acceptq_qcount = tp->acceptq[i].aq_qcount;
+			tinfo[i].acceptq_count = tp->acceptq[i].aq_count;
+			if (tp->acceptq[i].aq_valid)
+				tinfo[i].acceptq_shares=tp->acceptq[i].aq_ratio;
+			else
+				tinfo[i].acceptq_shares = 0;
+		}
+
+		len = min_t(unsigned int, len, sizeof(tinfo));
+		if (put_user(len, optlen))
+			return -EFAULT;
+
+		if (copy_to_user(optval, (char *)tinfo, len))
+			return -EFAULT;
+
+		return 0;
+	}
+#endif
 	default:
 		return -ENOPROTOOPT;
 	};
diff -urN linux-2.6.3_old/net/ipv4/tcp_ipv4.c linux-2.6.3/net/ipv4/tcp_ipv4.c
--- linux-2.6.3_old/net/ipv4/tcp_ipv4.c	2004-02-17 19:57:22.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_ipv4.c	2004-02-29 23:59:09.000000000 -0800
@@ -916,7 +916,11 @@
 	lopt->syn_table[h] = req;
 	write_unlock(&tp->syn_wait_lock);

+#ifdef CONFIG_ACCEPT_QUEUES
+	tcp_synq_added(sk, req);
+#else
 	tcp_synq_added(sk);
+#endif
 }


@@ -1413,6 +1417,9 @@
 	__u32 daddr = skb->nh.iph->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
+#ifdef CONFIG_ACCEPT_QUEUES
+	int class = 0;
+#endif
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1437,12 +1444,32 @@
 		goto drop;
 	}

+#ifdef CONFIG_ACCEPT_QUEUES
+	class = (skb->nfmark <= 0) ? 0 :
+		((skb->nfmark > NUM_ACCEPT_QUEUES) ? NUM_ACCEPT_QUEUES:
+		 skb->nfmark);
+	/*
+	 * Accept only if the class has shares set or if the default class
+	 * i.e. class 0 has shares
+	 */
+	if (!(tcp_sk(sk)->acceptq[class].aq_valid)) {
+		if (tcp_sk(sk)->acceptq[0].aq_valid)
+			class = 0;
+		else
+			goto drop;
+	}
+#endif
+
 	/* Accept backlog is full. If we have already queued enough
 	 * of warm entries in syn queue, drop request. It is better than
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
+#ifdef CONFIG_ACCEPT_QUEUES
+	if (tcp_acceptq_is_full(sk, class) && tcp_synq_young(sk, class) > 1)
+#else
 	if (tcp_acceptq_is_full(sk) && tcp_synq_young(sk) > 1)
+#endif
 		goto drop;

 	req = tcp_openreq_alloc();
@@ -1472,7 +1499,10 @@
 	tp.tstamp_ok = tp.saw_tstamp;

 	tcp_openreq_init(req, &tp, skb);
-
+#ifdef CONFIG_ACCEPT_QUEUES
+	req->acceptq_class = class;
+	req->acceptq_time_stamp = jiffies;
+#endif
 	req->af.v4_req.loc_addr = daddr;
 	req->af.v4_req.rmt_addr = saddr;
 	req->af.v4_req.opt = tcp_v4_save_options(sk, skb);
@@ -1567,7 +1597,11 @@
 	struct tcp_opt *newtp;
 	struct sock *newsk;

+#ifdef CONFIG_ACCEPT_QUEUES
+	if (tcp_acceptq_is_full(sk, req->acceptq_class))
+#else
 	if (tcp_acceptq_is_full(sk))
+#endif
 		goto exit_overflow;

 	if (!dst && (dst = tcp_v4_route_req(sk, req)) == NULL)
diff -urN linux-2.6.3_old/net/ipv4/tcp_minisocks.c linux-2.6.3/net/ipv4/tcp_minisocks.c
--- linux-2.6.3_old/net/ipv4/tcp_minisocks.c	2004-02-17 19:58:56.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_minisocks.c	2004-02-29 21:49:34.000000000 -0800
@@ -779,7 +779,14 @@
 		newtp->num_sacks = 0;
 		newtp->urg_data = 0;
 		newtp->listen_opt = NULL;
+#ifdef CONFIG_ACCEPT_QUEUES
+		newtp->accept_queue = NULL;
+		memset(newtp->acceptq, 0,sizeof(newtp->acceptq));
+		newtp->class_index = 0;
+
+#else
 		newtp->accept_queue = newtp->accept_queue_tail = NULL;
+#endif
 		/* Deinitialize syn_wait_lock to trap illegal accesses. */
 		memset(&newtp->syn_wait_lock, 0, sizeof(newtp->syn_wait_lock));

diff -urN linux-2.6.3_old/net/ipv4/tcp_timer.c linux-2.6.3/net/ipv4/tcp_timer.c
--- linux-2.6.3_old/net/ipv4/tcp_timer.c	2004-02-17 19:59:28.000000000 -0800
+++ linux-2.6.3/net/ipv4/tcp_timer.c	2004-02-27 17:38:55.000000000 -0800
@@ -498,7 +498,16 @@
 	 * ones are about to clog our table.
 	 */
 	if (lopt->qlen>>(lopt->max_qlen_log-1)) {
+#ifdef CONFIG_ACCEPT_QUEUES
+		int young = 0;
+
+		for(i=0; i < NUM_ACCEPT_QUEUES; i++)
+			young += lopt->qlen_young[i];
+
+		young <<= 1;
+#else
 		int young = (lopt->qlen_young<<1);
+#endif

 		while (thresh > 2) {
 			if (lopt->qlen < young)
@@ -524,9 +533,12 @@
 					unsigned long timeo;

 					if (req->retrans++ == 0)
-						lopt->qlen_young--;
-					timeo = min((TCP_TIMEOUT_INIT << req->retrans),
-						    TCP_RTO_MAX);
+#ifdef CONFIG_ACCEPT_QUEUES
+			         		lopt->qlen_young[req->acceptq_class]--;
+#else
+			         		lopt->qlen_young--;
+#endif
+					timeo = min((TCP_TIMEOUT_INIT << req->retrans), TCP_RTO_MAX);
 					req->expires = now + timeo;
 					reqp = &req->dl_next;
 					continue;
@@ -538,7 +550,11 @@
 				write_unlock(&tp->syn_wait_lock);
 				lopt->qlen--;
 				if (req->retrans == 0)
-					lopt->qlen_young--;
+#ifdef CONFIG_ACCEPT_QUEUES
+			         		lopt->qlen_young[req->acceptq_class]--;
+#else
+			         		lopt->qlen_young--;
+#endif
 				tcp_openreq_free(req);
 				continue;
 			}
