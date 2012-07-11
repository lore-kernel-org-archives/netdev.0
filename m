From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 17:50:31 +0200
Message-ID: <1342021831.3265.8174.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ncardwell@google.com, mattmathis@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

This introduce TSQ (TCP Small Queues)

TSQ goal is to reduce number of TCP packets in xmit queues (qdisc &
device queues), to reduce RTT and cwnd bias, part of the bufferbloat
problem.

sk->sk_wmem_alloc not allowed to grow above a given limit,
allowing no more than ~128KB [1] per tcp socket in qdisc/dev layers at a
given time.

TSO packets are sized/capped to half the limit, so that we have two
TSO packets in flight, allowing better bandwidth use.

As a side effect, setting the limit to 40000 automatically reduces the
standard gso max limit (65536) to 40000/2 : It can help to reduce
latencies of high prio packets, having smaller TSO packets.

This means we divert sock_wfree() to a tcp_wfree() handler, to
queue/send following frames when skb_orphan() [2] is called for the
already queued skbs.

Results on my dev machines (tg3/ixgbe nics) are really impressive,
using standard pfifo_fast, and with or without TSO/GSO.

Without reduction of nominal bandwidth, we have reduction of buffering
per bulk sender :
< 1ms on Gbit (instead of 50ms with TSO)
< 8ms on 100Mbit (instead of 132 ms)

I no longer have 4 MBytes backlogged in qdisc by a single netperf
session, and both side socket autotuning no longer use 4 Mbytes.

As skb destructor cannot restart xmit itself ( as qdisc lock might be
taken at this point ), we delegate the work to a tasklet. We use one
tasklest per cpu for performance reasons.

If tasklet finds a socket owned by the user, it sets TSQ_OWNED flag.
This flag is tested in a new protocol method called from release_sock(),
to eventually send new segments.

[1] New /proc/sys/net/ipv4/tcp_limit_output_bytes tunable
[2] skb_orphan() is usually called at TX completion time,
  but some drivers call it in their start_xmit() handler.
  These drivers should at least use BQL, or else a single TCP
  session can still fill the whole NIC TX ring, since TSQ will
  have no effect.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Tom Herbert <therbert@google.com>
Cc: Matt Mathis <mattmathis@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
---
 Documentation/networking/ip-sysctl.txt |   14 ++
 include/linux/tcp.h                    |    9 +
 include/net/sock.h                     |    2 
 include/net/tcp.h                      |    4 
 net/core/sock.c                        |    4 
 net/ipv4/sysctl_net_ipv4.c             |    7 +
 net/ipv4/tcp.c                         |    6 
 net/ipv4/tcp_ipv4.c                    |    1 
 net/ipv4/tcp_minisocks.c               |    1 
 net/ipv4/tcp_output.c                  |  154 ++++++++++++++++++++++-
 net/ipv6/tcp_ipv6.c                    |    1 
 11 files changed, 202 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 47b6c79..e20c17a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -551,6 +551,20 @@ tcp_thin_dupack - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
 
+tcp_limit_output_bytes - INTEGER
+	Controls TCP Small Queue limit per tcp socket.
+	TCP bulk sender tends to increase packets in flight until it
+	gets losses notifications. With SNDBUF autotuning, this can
+	result in a large amount of packets queued in qdisc/device
+	on the local machine, hurting latency of other flows, for
+	typical pfifo_fast qdiscs.
+	tcp_limit_output_bytes limits the number of bytes on qdisc
+	or device to reduce artificial RTT/cwnd and reduce bufferbloat.
+	Note: For GSO/TSO enabled flows, we try to have at least two
+	packets in flight. Reducing tcp_limit_output_bytes might also
+	reduce the size of individual GSO packet (64KB being the max)
+	Default: 131072
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2de9cf4..1888169 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -339,6 +339,9 @@ struct tcp_sock {
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
+	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
+	unsigned long	tsq_flags;
+
 	/* Data for direct copy to user */
 	struct {
 		struct sk_buff_head	prequeue;
@@ -494,6 +497,12 @@ struct tcp_sock {
 	struct tcp_cookie_values  *cookie_values;
 };
 
+enum tsq_flags {
+	TSQ_THROTTLED,
+	TSQ_QUEUED,
+	TSQ_OWNED, /* tcp_tasklet_func() found socket was locked */
+};
+
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 {
 	return (struct tcp_sock *)sk;
diff --git a/include/net/sock.h b/include/net/sock.h
index 640432a..eefce84 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -858,6 +858,8 @@ struct proto {
 	int			(*backlog_rcv) (struct sock *sk,
 						struct sk_buff *skb);
 
+	void		(*release_cb)(struct sock *sk);
+
 	/* Keeping track of sk's, looking them up, and port selection methods. */
 	void			(*hash)(struct sock *sk);
 	void			(*unhash)(struct sock *sk);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3618fef..439984b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -253,6 +253,7 @@ extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
+extern int sysctl_tcp_limit_output_bytes;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -321,6 +322,8 @@ extern struct proto tcp_prot;
 
 extern void tcp_init_mem(struct net *net);
 
+extern void tcp_tasklet_init(void);
+
 extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
@@ -334,6 +337,7 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
 extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags);
+extern void tcp_release_cb(struct sock *sk);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 const struct tcphdr *th, unsigned int len);
diff --git a/net/core/sock.c b/net/core/sock.c
index 929bdcc..24039ac 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2159,6 +2159,10 @@ void release_sock(struct sock *sk)
 	spin_lock_bh(&sk->sk_lock.slock);
 	if (sk->sk_backlog.tail)
 		__release_sock(sk);
+
+	if (sk->sk_prot->release_cb)
+		sk->sk_prot->release_cb(sk);
+
 	sk->sk_lock.owned = 0;
 	if (waitqueue_active(&sk->sk_lock.wq))
 		wake_up(&sk->sk_lock.wq);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 12aa0c5..70730f7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -598,6 +598,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_limit_output_bytes",
+		.data		= &sysctl_tcp_limit_output_bytes,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_NET_DMA
 	{
 		.procname	= "tcp_dma_copybreak",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d902da9..4252cd8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -376,6 +376,7 @@ void tcp_init_sock(struct sock *sk)
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
+	INIT_LIST_HEAD(&tp->tsq_node);
 
 	icsk->icsk_rto = TCP_TIMEOUT_INIT;
 	tp->mdev = TCP_TIMEOUT_INIT;
@@ -796,6 +797,10 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				  inet_csk(sk)->icsk_ext_hdr_len -
 				  tp->tcp_header_len);
 
+		/* TSQ : try to have two TSO segments in flight */
+		xmit_size_goal = min_t(u32, xmit_size_goal,
+				       sysctl_tcp_limit_output_bytes >> 1);
+
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 
 		/* We try hard to avoid divides here */
@@ -3574,4 +3579,5 @@ void __init tcp_init(void)
 	tcp_secret_primary = &tcp_secret_one;
 	tcp_secret_retiring = &tcp_secret_two;
 	tcp_secret_secondary = &tcp_secret_two;
+	tcp_tasklet_init();
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ddefd39..01545a3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2588,6 +2588,7 @@ struct proto tcp_prot = {
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v4_do_rcv,
+	.release_cb		= tcp_release_cb,
 	.hash			= inet_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6560886..c66f2ed 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -424,6 +424,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
 		tcp_prequeue_init(newtp);
+		INIT_LIST_HEAD(&newtp->tsq_node);
 
 		tcp_init_wl(newtp, treq->rcv_isn);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c465d3e..03854ab 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -50,6 +50,9 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 
+/* Default TSQ limit of two TSO segments */
+int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
+
 /* This limits the percentage of the congestion window which we
  * will allow a single TSO frame to consume.  Building TSO frames
  * which are too large can cause TCP streams to be bursty.
@@ -65,6 +68,8 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
+			   int push_one, gfp_t gfp);
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -783,6 +788,140 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 	return size;
 }
 
+
+/* TCP SMALL QUEUES (TSQ)
+ *
+ * TSQ goal is to keep small amount of skbs per tcp flow in tx queues (qdisc+dev)
+ * to reduce RTT and bufferbloat.
+ * We do this using a special skb destructor (tcp_wfree).
+ *
+ * Its important tcp_wfree() can be replaced by sock_wfree() in the event skb
+ * needs to be reallocated in a driver.
+ * The invariant being skb->truesize substracted from sk->sk_wmem_alloc
+ *
+ * Since transmit from skb destructor is forbidden, we use a tasklet
+ * to process all sockets that eventually need to send more skbs.
+ * We use one tasklet per cpu, with its own queue of sockets.
+ */
+struct tsq_tasklet {
+	struct tasklet_struct	tasklet;
+	struct list_head	head; /* queue of tcp sockets */
+};
+static DEFINE_PER_CPU(struct tsq_tasklet, tsq_tasklet);
+
+/*
+ * One tasklest per cpu tries to send more skbs.
+ * We run in tasklet context but need to disable irqs when
+ * transfering tsq->head because tcp_wfree() might
+ * interrupt us (non NAPI drivers)
+ */
+static void tcp_tasklet_func(unsigned long data)
+{
+	struct tsq_tasklet *tsq = (struct tsq_tasklet *)data;
+	LIST_HEAD(list);
+	unsigned long flags;
+	struct list_head *q, *n;
+	struct tcp_sock *tp;
+	struct sock *sk;
+
+	local_irq_save(flags);
+	list_splice_init(&tsq->head, &list);
+	local_irq_restore(flags);
+
+	list_for_each_safe(q, n, &list) {
+		tp = list_entry(q, struct tcp_sock, tsq_node);
+		list_del(&tp->tsq_node);
+
+		sk = (struct sock *)tp;
+		bh_lock_sock(sk);
+
+		if (!sock_owned_by_user(sk)) {
+			if ((1 << sk->sk_state) &
+			    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
+			     TCPF_CLOSING | TCPF_CLOSE_WAIT))
+				tcp_write_xmit(sk,
+					       tcp_current_mss(sk),
+					       0, 0,
+					       GFP_ATOMIC);
+		} else {
+			/* defer the work to tcp_release_cb() */
+			set_bit(TSQ_OWNED, &tp->tsq_flags);
+		}
+		bh_unlock_sock(sk);
+
+		clear_bit(TSQ_QUEUED, &tp->tsq_flags);
+		sk_free(sk);
+	}
+}
+
+/**
+ * tcp_release_cb - tcp release_sock() callback
+ * @sk: socket
+ *
+ * called from release_sock() to perform protocol dependent
+ * actions before socket release.
+ */
+void tcp_release_cb(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (test_and_clear_bit(TSQ_OWNED, &tp->tsq_flags)) {
+		if ((1 << sk->sk_state) &
+		    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
+		     TCPF_CLOSING | TCPF_CLOSE_WAIT))
+			tcp_write_xmit(sk,
+				       tcp_current_mss(sk),
+				       0, 0,
+				       GFP_ATOMIC);
+	}
+}
+EXPORT_SYMBOL(tcp_release_cb);
+
+void __init tcp_tasklet_init(void)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct tsq_tasklet *tsq = &per_cpu(tsq_tasklet, i);
+
+		INIT_LIST_HEAD(&tsq->head);
+		tasklet_init(&tsq->tasklet,
+			     tcp_tasklet_func,
+			     (unsigned long)tsq);
+	}
+}
+
+/*
+ * Write buffer destructor automatically called from kfree_skb.
+ * We cant xmit new skbs from this context, as we might already
+ * hold qdisc lock.
+ */
+void tcp_wfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (test_and_clear_bit(TSQ_THROTTLED, &tp->tsq_flags) &&
+	    !test_and_set_bit(TSQ_QUEUED, &tp->tsq_flags)) {
+		unsigned long flags;
+		struct tsq_tasklet *tsq;
+
+		/* Keep a ref on socket.
+		 * This last ref will be released in tcp_tasklet_func()
+		 */
+		atomic_sub(skb->truesize - 1, &sk->sk_wmem_alloc);
+
+		/* queue this socket to tasklet queue */
+		local_irq_save(flags);
+		tsq = &__get_cpu_var(tsq_tasklet);
+		list_add(&tp->tsq_node, &tsq->head);
+		tasklet_schedule(&tsq->tasklet);
+		local_irq_restore(flags);
+	} else {
+		sock_wfree(skb);
+	}
+}
+
 /* This routine actually transmits TCP packets queued in by
  * tcp_do_sendmsg().  This is used by both the initial
  * transmission and possible later retransmissions.
@@ -844,7 +983,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
-	skb_set_owner_w(skb, sk);
+
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
+			  tcp_wfree : sock_wfree;
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	/* Build TCP header and checksum it. */
 	th = tcp_hdr(skb);
@@ -1780,6 +1924,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
+
 		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
 		BUG_ON(!tso_segs);
 
@@ -1800,6 +1945,13 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
+		/* TSQ : sk_wmem_alloc accounts skb truesize,
+		 * including skb overhead. But thats OK.
+		 */
+		if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
+			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
+			break;
+		}
 		limit = mss_now;
 		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 61175cb..70458a9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1970,6 +1970,7 @@ struct proto tcpv6_prot = {
 	.sendmsg		= tcp_sendmsg,
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
+	.release_cb		= tcp_release_cb,
 	.hash			= tcp_v6_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
