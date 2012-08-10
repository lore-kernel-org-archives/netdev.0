From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Subject: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu,  9 Aug 2012 17:52:38 -0700
Message-ID: <1344559958-29162-1-git-send-email-brutus@google.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	"Bruce \"Brutus\" Curtis" <brutus@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f202.google.com ([74.125.82.202]:51086 "EHLO
	mail-we0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab2HJAws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 20:52:48 -0400
Received: by weyr1 with SMTP id r1so47322wey.1
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 17:52:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Bruce \"Brutus\" Curtis" <brutus@google.com>

TCP/IP loopback socket pair stack bypass, based on an idea by, and
rough upstream patch from, David Miller <davem@davemloft.net> called
"friends", the data structure modifcations and connection scheme are
reused with extensive data-path changes.

A new sysctl, net.ipv4.tcp_friends, is added:
  0: disable friends and use the stock data path.
  1: enable friends and bypass the stack data path, the default.

Note, when friends is enabled any loopback interpose, e.g. tcpdump,
will only see the TCP/IP packets during connection establishment and
finish, all data bypasses the stack and instead is delivered to the
destination socket directly.

Testing done on a 4 socket 2.2GHz "Quad-Core AMD Opteron(tm) Processor
8354 CPU" based system, netperf results for a single connection show
increased TCP_STREAM throughput, increased TCP_RR and TCP_CRR transaction
rate for most message sizes vs baseline and comparable to AF_UNIX.

Significant increase (up to 4.88x) in aggregate throughput for multiple
netperf runs (STREAM 32KB I/O x N) is seen.

Some results:

Default netperf: netperf
		 netperf -t STREAM_STREAM
		 netperf -t STREAM_STREAM -- -s 51882 -m 16384 -M 87380
		 netperf

	 Baseline  AF_UNIX      AF_UNIX           Friends
	 Mbits/S   Mbits/S      Mbits/S           Mbits/S
           7152       669   7%    9322 130% 1393%  10642 149% 1591% 114%

Note, for the AF_UNIX (STREAM_STREAM) test 2 results are listed, 1st
with no options but as the defaults for AF_UNIX sockets are much lower
performaning a 2nd set of runs with a socket buffer size and send/recv
buffer sizes equivalent to AF_INET (TCP_STREAM) are done.

Note, all subsequent AF_UNIX (STREAM_STREAM, STREAM_RR) tests are done
with "-s 51882" such that the same total effective socket buffering is
used as for the AF_INET runs defaults (16384+87380/2).


STREAM 32KB I/O x N: netperf -l 100 -t TCP_STREAM -- -m 32K -M 32K
		     netperf -l 100 -t STREAM_STREAM -- -s 51882 -m 32K -M 3
		     netperf -l 100 -t TCP_STREAM -- -m 32K -M 32K

	  Baseline  AF_UNIX      Friends
   N  COC Mbits/S   Mbits/S      Mbits/S
   1   -    9054      8753  97%   10697 118% 122%
   2   -   18671     16097  86%   19280 103% 120%
  16   2   72033    289222 402%  351253 488% 121%
  32   4   64789    215364 332%  256848 396% 119%
 256  32   71660     99081 138%  239952 335% 242%
 512  64   80243     93453 116%  230425 287% 247%
1600 200  112352    251095 223%  373718 333% 149%

COC = Cpu Over Commit ratio (16 core platform)


STREAM: netperf -l 100 -t TCP_STREAM
	netperf -l 100 -t STREAM_STREAM -- -s 51882 -m 32K -M 32K
	netperf -l 100 -t TCP_STREAM

netperf  Baseline  AF_UNIX      Friends
-m/-M N  Mbits/S   Mbits/S      Mbits/S
  64        860       430  50%     533  62% 124%
  1K       4599      4296  93%    5111 111% 119%
  8K       5957      7663 129%    9738 163% 127%
 32K       8355      9255 111%   11004 132% 119%
 64K       9188      9498 103%   11094 121% 117%
128K       9240      9799 106%   12959 140% 132%
256K       9987     10351 104%   13940 140% 135%
512K      10326     10032  97%   13492 131% 134%
  1M       8825      9492 108%   12393 140% 131%
 16M       7240      9229 127%   11214 155% 122%


RR: netperf -l 100 -t TCP_RR
    netperf -l 100 -t STREAM_RR -- -s 51882 -m 16384 -M 87380
    netperf -l 100 -t TCP_RR

netperf  Baseline  AF_UNIX      Friends
-r N,N   Trans./S  Trans./S     Trans./S
  64      46928     87522 187%   84995 181%  97%
  1K      43646     85426 196%   82056 188%  96%
  8K      26492     29943 113%   30875 117% 103%
 32K      10933     12080 110%   13103 120% 108%
 64K       7048      6274  89%    7069 100% 113%
128K       4374      3275  75%    3633  83% 111%
256K       2393      1889  79%    2120  89% 112%
512K        995      1060 107%    1165 117% 110%
  1M        414       505 122%     499 121%  99%
 16M       26.1      33.1 127%    32.6 125%  98%


CRR: netperf -l 100 -t TCP_CRR
     netperf -l 100 -t TCP_CRR

netperf  Baseline  AF_UNIX      Friends
  -r N   Trans./S  Trans./S     Trans./S
  64      16167         -        18647 115%   -
  1K      14834         -        18274 123%   -
  8K      11880         -        14719 124%   -
 32K       7247         -         8956 124%   -
 64K       4456         -         5595 126%   -
128K       2344         -         3144 134%   -
256K       1286         -         1962 153%   -
512K        626         -         1047 167%   -
  1M        361         -          459 127%   -
 16M       27.4         -         32.2 118%   -

Note, "-" denotes test not supported for transport.


SPLICE 32KB I/O:

Source
 Sink   Baseline  Friends
 FSFS   Mbits/S   Mbits/S
 ----     9300      9686 104%
 Z---     8656      9670 112%
 --N-     9636     10704 111%
 Z-N-     8200      8017  98%
 -S--    20480     30101 147%
 ZS--     8834      9221 104%
 -SN-    20198     32122 159%
 ZSN-     8557      9267 108%
 ---S     8874      9805 110%
 Z--S     8088      9487 117%
 --NS    12881     11265  87%
 Z-NS    10700      8147  76%
 -S-S    14964     21975 147%
 ZS-S     8261      8809 107%
 -SNS    17394     29366 169%
 ZSNS    11456     10674  93%

Note, "Z" source File /dev/zero, "-" source user memory
      "N" sink File /dev/null, "-" sink user memory
      "S" Splice on, "-" Splice off

Signed-off-by: Bruce \"Brutus\" Curtis <brutus@google.com>
---
 Documentation/networking/ip-sysctl.txt |    8 +
 include/linux/skbuff.h                 |    2 +
 include/net/request_sock.h             |    1 +
 include/net/sock.h                     |   32 ++-
 include/net/tcp.h                      |    3 +-
 net/core/skbuff.c                      |    1 +
 net/core/sock.c                        |    1 +
 net/core/stream.c                      |   36 +++
 net/ipv4/inet_connection_sock.c        |   20 ++
 net/ipv4/sysctl_net_ipv4.c             |    7 +
 net/ipv4/tcp.c                         |  500 +++++++++++++++++++++++++++----
 net/ipv4/tcp_input.c                   |   22 ++-
 net/ipv4/tcp_ipv4.c                    |    2 +
 net/ipv4/tcp_minisocks.c               |    5 +
 net/ipv4/tcp_output.c                  |   18 +-
 net/ipv6/tcp_ipv6.c                    |    1 +
 16 files changed, 584 insertions(+), 75 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ca447b3..8344c05 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -214,6 +214,14 @@ tcp_fack - BOOLEAN
 	Enable FACK congestion avoidance and fast retransmission.
 	The value is not used, if tcp_sack is not enabled.
 
+tcp_friends - BOOLEAN
+	If set, TCP loopback socket pair stack bypass is enabled such
+	that all data sent will be directly queued to the receiver's
+	socket for receive. Note, normal connection establishment and
+	finish is used to make friends so any loopback interpose, e.g.
+	tcpdump, will see these TCP segements but no data segments.
+	Default: 1
+
 tcp_fin_timeout - INTEGER
 	Time to hold socket in state FIN-WAIT-2, if it was closed
 	by our side. Peer can be broken and never close its side,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b33a3a1..a2e86a6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -332,6 +332,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@_skb_refdst: destination entry (with norefcount bit)
  *	@sp: the security path, used for xfrm
+ *	@friend: loopback friend socket
  *	@len: Length of actual data
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
@@ -407,6 +408,7 @@ struct sk_buff {
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
 #endif
+	struct sock		*friend;
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 4c0766e..2c74420 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -63,6 +63,7 @@ struct request_sock {
 	unsigned long			expires;
 	const struct request_sock_ops	*rsk_ops;
 	struct sock			*sk;
+	struct sock			*friend;
 	u32				secid;
 	u32				peer_secid;
 };
diff --git a/include/net/sock.h b/include/net/sock.h
index 72132ae..0913dff 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -197,6 +197,7 @@ struct cg_proto;
   *	@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
   *	@sk_lock:	synchronizer
   *	@sk_rcvbuf: size of receive buffer in bytes
+  *	@sk_friend: loopback friend socket
   *	@sk_wq: sock wait queue and async head
   *	@sk_rx_dst: receive input route used by early tcp demux
   *	@sk_dst_cache: destination cache
@@ -287,6 +288,14 @@ struct sock {
 	socket_lock_t		sk_lock;
 	struct sk_buff_head	sk_receive_queue;
 	/*
+	 * If socket has a friend (sk_friend != NULL) then a send skb is
+	 * enqueued directly to the friend's sk_receive_queue such that:
+	 *
+	 *        sk_sndbuf -> sk_sndbuf + sk_friend->sk_rcvbuf
+	 *   sk_wmem_queued -> sk_friend->sk_rmem_alloc
+	 */
+	struct sock		*sk_friend;
+	/*
 	 * The backlog queue is special, it is always used with
 	 * the per-socket spinlock held and requires low latency
 	 * access. Therefore we special case it's implementation.
@@ -696,24 +705,40 @@ static inline bool sk_acceptq_is_full(const struct sock *sk)
 	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
 }
 
+static inline int sk_wmem_queued_get(const struct sock *sk)
+{
+	if (sk->sk_friend)
+		return atomic_read(&sk->sk_friend->sk_rmem_alloc);
+	else
+		return sk->sk_wmem_queued;
+}
+
+static inline int sk_sndbuf_get(const struct sock *sk)
+{
+	if (sk->sk_friend)
+		return sk->sk_sndbuf + sk->sk_friend->sk_rcvbuf;
+	else
+		return sk->sk_sndbuf;
+}
+
 /*
  * Compute minimal free write space needed to queue new packets.
  */
 static inline int sk_stream_min_wspace(const struct sock *sk)
 {
-	return sk->sk_wmem_queued >> 1;
+	return sk_wmem_queued_get(sk) >> 1;
 }
 
 static inline int sk_stream_wspace(const struct sock *sk)
 {
-	return sk->sk_sndbuf - sk->sk_wmem_queued;
+	return sk_sndbuf_get(sk) - sk_wmem_queued_get(sk);
 }
 
 extern void sk_stream_write_space(struct sock *sk);
 
 static inline bool sk_stream_memory_free(const struct sock *sk)
 {
-	return sk->sk_wmem_queued < sk->sk_sndbuf;
+	return sk_wmem_queued_get(sk) < sk_sndbuf_get(sk);
 }
 
 /* OOB backlog add */
@@ -822,6 +847,7 @@ static inline void sock_rps_reset_rxhash(struct sock *sk)
 	})
 
 extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
+extern int sk_stream_wait_friend(struct sock *sk, long *timeo_p);
 extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
 extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
 extern int sk_stream_error(struct sock *sk, int flags, int err);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e19124b..baa981b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -266,6 +266,7 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
+extern int sysctl_tcp_friends;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -1011,7 +1012,7 @@ static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (sysctl_tcp_low_latency || !tp->ucopy.task)
+	if (sysctl_tcp_low_latency || !tp->ucopy.task || sk->sk_friend)
 		return false;
 
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fe00d12..7cb73e6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -703,6 +703,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
+	new->friend		= old->friend;
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->csum		= old->csum;
 	new->local_df		= old->local_df;
diff --git a/net/core/sock.c b/net/core/sock.c
index 8f67ced..8d0707f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2134,6 +2134,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 #ifdef CONFIG_NET_DMA
 	skb_queue_head_init(&sk->sk_async_wait_queue);
 #endif
+	sk->sk_friend		=	NULL;
 
 	sk->sk_send_head	=	NULL;
 
diff --git a/net/core/stream.c b/net/core/stream.c
index f5df85d..85e5b03 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -83,6 +83,42 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 EXPORT_SYMBOL(sk_stream_wait_connect);
 
 /**
+ * sk_stream_wait_friend - Wait for a socket to make friends
+ * @sk: sock to wait on
+ * @timeo_p: for how long to wait
+ *
+ * Must be called with the socket locked.
+ */
+int sk_stream_wait_friend(struct sock *sk, long *timeo_p)
+{
+	struct task_struct *tsk = current;
+	DEFINE_WAIT(wait);
+	int done;
+
+	do {
+		int err = sock_error(sk);
+		if (err)
+			return err;
+		if (!sk->sk_friend)
+			return -EBADFD;
+		if (!*timeo_p)
+			return -EAGAIN;
+		if (signal_pending(tsk))
+			return sock_intr_errno(*timeo_p);
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		sk->sk_write_pending++;
+		done = sk_wait_event(sk, timeo_p,
+				     !sk->sk_err &&
+				     sk->sk_friend->sk_friend);
+		finish_wait(sk_sleep(sk), &wait);
+		sk->sk_write_pending--;
+	} while (!done);
+	return 0;
+}
+EXPORT_SYMBOL(sk_stream_wait_friend);
+
+/**
  * sk_stream_closing - Return 1 if we still have things to send in our buffers.
  * @sk: socket to verify
  */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index db0cf17..6b4c26c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -623,6 +623,26 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 	if (newsk != NULL) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 
+		if (req->friend) {
+			/*
+			 * Make friends with the requestor but the ACK of
+			 * the request is already in-flight so the race is
+			 * on to make friends before the ACK is processed.
+			 * If the requestor's sk_friend value is != NULL
+			 * then the requestor has already processed the
+			 * ACK so indicate state change to wake'm up.
+			 */
+			struct sock *was;
+
+			sock_hold(req->friend);
+			newsk->sk_friend = req->friend;
+			sock_hold(newsk);
+			was = xchg(&req->friend->sk_friend, newsk);
+			/* If requester already connect()ed, maybe sleeping */
+			if (was && !sock_flag(req->friend, SOCK_DEAD))
+				sk->sk_state_change(req->friend);
+		}
+
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1b5ce96..dd3936f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -737,6 +737,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "tcp_friends",
+		.data		= &sysctl_tcp_friends,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2109ff4..6dc267c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -310,6 +310,38 @@ struct tcp_splice_state {
 };
 
 /*
+ * Friends? If not a friend return 0, else if friend is also a friend
+ * return 1, else wait for friend to be ready and return 1 if friends
+ * else -errno. In all cases if *friendp != NULL return friend pointer
+ * else NULL.
+ */
+static inline int tcp_friends(struct sock *sk, struct sock **friendp,
+			      long *timeo)
+{
+	struct sock *friend = sk->sk_friend;
+	int ret = 0;
+
+	if (!friend)
+		goto out;
+	if (unlikely(!friend->sk_friend)) {
+		/* Friendship not complete, wait? */
+		if (!timeo) {
+			ret = -EAGAIN;
+			goto out;
+		}
+		ret = sk_stream_wait_friend(sk, timeo);
+		if (ret != 0)
+			goto out;
+		friend = sk->sk_friend;
+	}
+	ret = 1;
+out:
+	if (friendp)
+		*friendp = friend;
+	return ret;
+}
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the __sk_mem_schedule() is of this nature: accounting
@@ -589,6 +621,73 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 }
 EXPORT_SYMBOL(tcp_ioctl);
 
+static inline struct sk_buff *tcp_friend_tail(struct sock *sk, int *copy)
+{
+	struct sock	*friend = sk->sk_friend;
+	struct sk_buff	*skb = NULL;
+	int		sz = 0;
+
+	if (skb_peek_tail(&friend->sk_receive_queue)) {
+		spin_lock_bh(&friend->sk_lock.slock);
+		skb = skb_peek_tail(&friend->sk_receive_queue);
+		if (skb && skb->friend) {
+			if (!*copy)
+				sz = skb_tailroom(skb);
+			else
+				sz = *copy - skb->len;
+		}
+		if (!skb || sz <= 0)
+			spin_unlock_bh(&friend->sk_lock.slock);
+	}
+
+	*copy = sz;
+	return skb;
+}
+
+static inline void tcp_friend_seq(struct sock *sk, int copy, int charge)
+{
+	struct sock	*friend = sk->sk_friend;
+	struct tcp_sock *tp = tcp_sk(friend);
+
+	if (charge) {
+		sk_mem_charge(friend, charge);
+		atomic_add(charge, &friend->sk_rmem_alloc);
+	}
+	tp->rcv_nxt += copy;
+	tp->rcv_wup += copy;
+	spin_unlock_bh(&friend->sk_lock.slock);
+
+	friend->sk_data_ready(friend, copy);
+
+	tp = tcp_sk(sk);
+	tp->snd_nxt += copy;
+	tp->pushed_seq += copy;
+	tp->snd_una += copy;
+	tp->snd_up += copy;
+}
+
+static inline int tcp_friend_push(struct sock *sk, struct sk_buff *skb)
+{
+	struct sock	*friend = sk->sk_friend;
+	int		ret = 0;
+
+	if (friend->sk_shutdown & RCV_SHUTDOWN) {
+		__kfree_skb(skb);
+		return -ECONNRESET;
+	}
+
+	spin_lock_bh(&friend->sk_lock.slock);
+	skb->friend = sk;
+	skb_set_owner_r(skb, friend);
+	__skb_queue_tail(&friend->sk_receive_queue, skb);
+	if (!sk_rmem_schedule(friend, skb, skb->truesize))
+		ret = 1;
+
+	tcp_friend_seq(sk, skb->len, 0);
+
+	return ret;
+}
+
 static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
@@ -605,8 +704,12 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
-	skb->csum    = 0;
 	tcb->seq     = tcb->end_seq = tp->write_seq;
+	if (sk->sk_friend) {
+		skb->friend = sk->sk_friend;
+		return;
+	}
+	skb->csum    = 0;
 	tcb->tcp_flags = TCPHDR_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
@@ -758,6 +861,21 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 }
 EXPORT_SYMBOL(tcp_splice_read);
 
+static inline struct sk_buff *tcp_friend_alloc_skb(struct sock *sk, int size)
+{
+	struct sk_buff *skb;
+
+	skb = alloc_skb(size, sk->sk_allocation);
+	if (skb)
+		skb->avail_size = skb_tailroom(skb);
+	else {
+		sk->sk_prot->enter_memory_pressure(sk);
+		sk_stream_moderate_sndbuf(sk);
+	}
+
+	return skb;
+}
+
 struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 {
 	struct sk_buff *skb;
@@ -821,13 +939,47 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	return max(xmit_size_goal, mss_now);
 }
 
+static unsigned int tcp_friend_xmit_size_goal(struct sock *sk, int size_goal)
+{
+	u32 tmp = SKB_TRUESIZE(size_goal);
+
+	/*
+	 * If goal is zero (for non linear) or truesize of goal >= largest
+	 * skb return largest, else for tail fill find smallest order that
+	 * fits 8 or more truesized, else use requested truesize.
+	 */
+	if (size_goal == 0 || tmp >= SKB_MAX_ORDER(0, 3))
+		tmp = SKB_MAX_ORDER(0, 3);
+	else if (tmp <= (SKB_MAX_ORDER(0, 0) >> 3))
+		tmp = SKB_MAX_ORDER(0, 0);
+	else if (tmp <= (SKB_MAX_ORDER(0, 1) >> 3))
+		tmp = SKB_MAX_ORDER(0, 1);
+	else if (tmp <= (SKB_MAX_ORDER(0, 2) >> 3))
+		tmp = SKB_MAX_ORDER(0, 2);
+	else if (tmp <= (SKB_MAX_ORDER(0, 3) >> 3))
+		tmp = SKB_MAX_ORDER(0, 3);
+
+	/* At least 2 truesized in sk_buf */
+	if (tmp > (sk_sndbuf_get(sk) >> 1))
+		tmp = (sk_sndbuf_get(sk) >> 1) - SKB_TRUESIZE(0);
+
+	return tmp;
+}
+
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 {
 	int mss_now;
+	int tmp;
 
-	mss_now = tcp_current_mss(sk);
-	*size_goal = tcp_xmit_size_goal(sk, mss_now, !(flags & MSG_OOB));
+	if (sk->sk_friend) {
+		mss_now = tcp_friend_xmit_size_goal(sk, *size_goal);
+		tmp = mss_now;
+	} else {
+		mss_now = tcp_current_mss(sk);
+		tmp = tcp_xmit_size_goal(sk, mss_now, !(flags & MSG_OOB));
+	}
 
+	*size_goal = tmp;
 	return mss_now;
 }
 
@@ -838,6 +990,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	int mss_now, size_goal;
 	int err;
 	ssize_t copied;
+	struct sock *friend;
+	bool friend_tail = false;
 	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
 
 	/* Wait for a connection to finish. */
@@ -845,6 +999,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
 			goto out_err;
 
+	err = tcp_friends(sk, &friend, &timeo);
+	if (err < 0)
+		goto out_err;
+
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -855,19 +1013,40 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 		goto out_err;
 
 	while (psize > 0) {
-		struct sk_buff *skb = tcp_write_queue_tail(sk);
+		struct sk_buff *skb;
 		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (sk->sk_friend) {
+			if (sk->sk_friend->sk_shutdown & RCV_SHUTDOWN) {
+				sk->sk_err = ECONNRESET;
+				err = -EPIPE;
+				goto out_err;
+			}
+			copy = size_goal;
+			skb = tcp_friend_tail(sk, &copy);
+			if (copy > 0)
+				friend_tail = true;
+		} else if (!tcp_send_head(sk)) {
+			copy = 0;
+		} else {
+			skb = tcp_write_queue_tail(sk);
+			copy = size_goal - skb->len;
+		}
+
+		if (copy <= 0) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
+			if (sk->sk_friend)
+				skb = tcp_friend_alloc_skb(sk, 0);
+			else
+				skb = sk_stream_alloc_skb(sk, 0,
+							  sk->sk_allocation);
 			if (!skb)
 				goto wait_for_memory;
 
@@ -881,10 +1060,16 @@ new_segment:
 		i = skb_shinfo(skb)->nr_frags;
 		can_coalesce = skb_can_coalesce(skb, i, page, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
-			tcp_mark_push(tp, skb);
+			if (friend) {
+				if (friend_tail) {
+					tcp_friend_seq(sk, 0, 0);
+					friend_tail = false;
+				}
+			} else
+				tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_wmem_schedule(sk, copy))
+		if (!friend && !sk_wmem_schedule(sk, copy))
 			goto wait_for_memory;
 
 		if (can_coalesce) {
@@ -897,19 +1082,40 @@ new_segment:
 		skb->len += copy;
 		skb->data_len += copy;
 		skb->truesize += copy;
-		sk->sk_wmem_queued += copy;
-		sk_mem_charge(sk, copy);
-		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
 		skb_shinfo(skb)->gso_segs = 0;
 
-		if (!copied)
-			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
-
 		copied += copy;
 		poffset += copy;
-		if (!(psize -= copy))
+		psize -= copy;
+
+		if (friend) {
+			if (friend_tail) {
+				tcp_friend_seq(sk, copy, copy);
+				friend_tail = false;
+			} else {
+				err = tcp_friend_push(sk, skb);
+				if (err < 0) {
+					sk->sk_err = -err;
+					goto out_err;
+				}
+				if (err > 0)
+					goto wait_for_sndbuf;
+			}
+			if (!psize)
+				goto out;
+			continue;
+		}
+
+		sk->sk_wmem_queued += copy;
+		sk_mem_charge(sk, copy);
+		skb->ip_summed = CHECKSUM_PARTIAL;
+
+		if (copied == copy)
+			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
+
+		if (!psize)
 			goto out;
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
@@ -930,6 +1136,7 @@ wait_for_memory:
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
 
+		size_goal = -mss_now;
 		mss_now = tcp_send_mss(sk, &size_goal, flags);
 	}
 
@@ -1024,8 +1231,9 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int iovlen, flags, err, copied = 0;
-	int mss_now = 0, size_goal, copied_syn = 0, offset = 0;
-	bool sg;
+	int mss_now = 0, size_goal = size, copied_syn = 0, offset = 0;
+	struct sock *friend;
+	bool sg, friend_tail = false;
 	long timeo;
 
 	lock_sock(sk);
@@ -1047,6 +1255,10 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
 			goto do_error;
 
+	err = tcp_friends(sk, &friend, &timeo);
+	if (err < 0)
+		goto out;
+
 	if (unlikely(tp->repair)) {
 		if (tp->repair_queue == TCP_RECV_QUEUE) {
 			copied = tcp_send_rcvq(sk, msg, size);
@@ -1095,24 +1307,40 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			int copy = 0;
 			int max = size_goal;
 
-			skb = tcp_write_queue_tail(sk);
-			if (tcp_send_head(sk)) {
-				if (skb->ip_summed == CHECKSUM_NONE)
-					max = mss_now;
-				copy = max - skb->len;
+			if (friend) {
+				if (friend->sk_shutdown & RCV_SHUTDOWN) {
+					sk->sk_err = ECONNRESET;
+					err = -EPIPE;
+					goto out_err;
+				}
+				skb = tcp_friend_tail(sk, &copy);
+				if (copy)
+					friend_tail = true;
+			} else {
+				skb = tcp_write_queue_tail(sk);
+				if (tcp_send_head(sk)) {
+					if (skb->ip_summed == CHECKSUM_NONE)
+						max = mss_now;
+					copy = max - skb->len;
+				}
 			}
 
 			if (copy <= 0) {
 new_segment:
-				/* Allocate new segment. If the interface is SG,
-				 * allocate skb fitting to single page.
-				 */
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
 
-				skb = sk_stream_alloc_skb(sk,
-							  select_size(sk, sg),
-							  sk->sk_allocation);
+				if (friend)
+					skb = tcp_friend_alloc_skb(sk, max);
+				else {
+					/* Allocate new segment. If the
+					 * interface is SG, allocate skb
+					 * fitting to single page.
+					 */
+					skb = sk_stream_alloc_skb(sk,
+							select_size(sk, sg),
+							sk->sk_allocation);
+				}
 				if (!skb)
 					goto wait_for_memory;
 
@@ -1144,6 +1372,8 @@ new_segment:
 				struct page *page = sk->sk_sndmsg_page;
 				int off;
 
+				BUG_ON(friend);
+
 				if (page && page_count(page) == 1)
 					sk->sk_sndmsg_off = 0;
 
@@ -1213,16 +1443,34 @@ new_segment:
 				sk->sk_sndmsg_off = off + copy;
 			}
 
-			if (!copied)
-				TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
-
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
 			skb_shinfo(skb)->gso_segs = 0;
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			seglen -= copy;
+
+			if (friend) {
+				if (friend_tail) {
+					tcp_friend_seq(sk, copy, 0);
+					friend_tail = false;
+				} else {
+					err = tcp_friend_push(sk, skb);
+					if (err < 0) {
+						sk->sk_err = -err;
+						goto out_err;
+					}
+					if (err > 0)
+						goto wait_for_sndbuf;
+				}
+				continue;
+			}
+
+			if (copied == copy)
+				TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
+
+			if (seglen == 0 && iovlen == 0)
 				goto out;
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
@@ -1244,6 +1492,7 @@ wait_for_memory:
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
 
+			size_goal = -mss_now;
 			mss_now = tcp_send_mss(sk, &size_goal, flags);
 		}
 	}
@@ -1255,13 +1504,19 @@ out:
 	return copied + copied_syn;
 
 do_fault:
-	if (!skb->len) {
-		tcp_unlink_write_queue(skb, sk);
-		/* It is the one place in all of TCP, except connection
-		 * reset, where we can be unlinking the send_head.
-		 */
-		tcp_check_send_head(sk, skb);
-		sk_wmem_free_skb(sk, skb);
+	if (friend_tail)
+		spin_unlock_bh(&friend->sk_lock.slock);
+	else if (!skb->len) {
+		if (friend)
+			__kfree_skb(skb);
+		else {
+			tcp_unlink_write_queue(skb, sk);
+			/* It is the one place in all of TCP, except connection
+			 * reset, where we can be unlinking the send_head.
+			 */
+			tcp_check_send_head(sk, skb);
+			sk_wmem_free_skb(sk, skb);
+		}
 	}
 
 do_error:
@@ -1274,6 +1529,13 @@ out_err:
 }
 EXPORT_SYMBOL(tcp_sendmsg);
 
+static inline void tcp_friend_write_space(struct sock *sk)
+{
+	/* Queued data below 1/4th of sndbuf? */
+	if ((sk_sndbuf_get(sk) >> 2) > sk_wmem_queued_get(sk))
+		sk->sk_friend->sk_write_space(sk->sk_friend);
+}
+
 /*
  *	Handle reading urgent data. BSD has very simple semantics for
  *	this, no blocking and very strange errors 8)
@@ -1352,7 +1614,12 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool time_to_ack = false;
 
-	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
+	struct sk_buff *skb;
+
+	if (sk->sk_friend)
+		return;
+
+	skb = skb_peek(&sk->sk_receive_queue);
 
 	WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
 	     "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
@@ -1463,9 +1730,9 @@ static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 
 	skb_queue_walk(&sk->sk_receive_queue, skb) {
 		offset = seq - TCP_SKB_CB(skb)->seq;
-		if (tcp_hdr(skb)->syn)
+		if (!skb->friend && tcp_hdr(skb)->syn)
 			offset--;
-		if (offset < skb->len || tcp_hdr(skb)->fin) {
+		if (offset < skb->len || (!skb->friend && tcp_hdr(skb)->fin)) {
 			*off = offset;
 			return skb;
 		}
@@ -1492,14 +1759,27 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	u32 seq = tp->copied_seq;
 	u32 offset;
 	int copied = 0;
+	struct sock *friend = sk->sk_friend;
 
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
+
+	if (friend) {
+		int err;
+		long timeo = sock_rcvtimeo(sk, false);
+
+		err = tcp_friends(sk, &friend, &timeo);
+		if (err < 0)
+			return err;
+		spin_lock_bh(&sk->sk_lock.slock);
+	}
+
 	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
 		if (offset < skb->len) {
 			int used;
 			size_t len;
 
+	again:
 			len = skb->len - offset;
 			/* Stop reading if we hit a patch of urgent data */
 			if (tp->urg_data) {
@@ -1509,7 +1789,13 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				if (!len)
 					break;
 			}
+			if (sk->sk_friend)
+				spin_unlock_bh(&sk->sk_lock.slock);
+
 			used = recv_actor(desc, skb, offset, len);
+
+			if (sk->sk_friend)
+				spin_lock_bh(&sk->sk_lock.slock);
 			if (used < 0) {
 				if (!copied)
 					copied = used;
@@ -1519,17 +1805,31 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				copied += used;
 				offset += used;
 			}
-			/*
-			 * If recv_actor drops the lock (e.g. TCP splice
-			 * receive) the skb pointer might be invalid when
-			 * getting here: tcp_collapse might have deleted it
-			 * while aggregating skbs from the socket queue.
-			 */
-			skb = tcp_recv_skb(sk, seq-1, &offset);
-			if (!skb || (offset+1 != skb->len))
-				break;
+			if (skb->friend) {
+				if (offset < skb->len) {
+					/*
+					 * Friend did an skb_put() while we
+					 * were away so process the same skb.
+					 */
+					tp->copied_seq = seq;
+					if (!desc->count)
+						break;
+					goto again;
+				}
+			} else {
+				/*
+				 * If recv_actor drops the lock (e.g. TCP
+				 * splice receive) the skb pointer might be
+				 * invalid when getting here: tcp_collapse
+				 * might have deleted it while aggregating
+				 * skbs from the socket queue.
+				 */
+				skb = tcp_recv_skb(sk, seq-1, &offset);
+				if (!skb || (offset+1 != skb->len))
+					break;
+			}
 		}
-		if (tcp_hdr(skb)->fin) {
+		if (!skb->friend && tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, false);
 			++seq;
 			break;
@@ -1541,11 +1841,16 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	}
 	tp->copied_seq = seq;
 
-	tcp_rcv_space_adjust(sk);
+	if (sk->sk_friend) {
+		spin_unlock_bh(&sk->sk_lock.slock);
+		tcp_friend_write_space(sk);
+	} else {
+		tcp_rcv_space_adjust(sk);
 
-	/* Clean up data we have read: This will do ACK frames. */
-	if (copied > 0)
-		tcp_cleanup_rbuf(sk, copied);
+		/* Clean up data we have read: This will do ACK frames. */
+		if (copied > 0)
+			tcp_cleanup_rbuf(sk, copied);
+	}
 	return copied;
 }
 EXPORT_SYMBOL(tcp_read_sock);
@@ -1573,6 +1878,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	bool copied_early = false;
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
+	int skb_len;
+	struct sock *friend;
+	bool locked = false;
 
 	lock_sock(sk);
 
@@ -1582,6 +1890,10 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	timeo = sock_rcvtimeo(sk, nonblock);
 
+	err = tcp_friends(sk, &friend, &timeo);
+	if (err < 0)
+		goto out;
+
 	/* Urgent data needs to be handled specially. */
 	if (flags & MSG_OOB)
 		goto recv_urg;
@@ -1620,7 +1932,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-		    !sysctl_tcp_low_latency &&
+		    !sysctl_tcp_low_latency && !friends &&
 		    net_dma_find_channel()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
@@ -1644,9 +1956,30 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			}
 		}
 
-		/* Next get a buffer. */
+		/*
+		 * Next get a buffer. Note, for socket friends a sk_friend
+		 * sendmsg() can either skb_queue_tail() a new skb directly
+		 * or skb_put() to the tail skb while holding sk_lock.slock.
+		 */
+		if (friend && !locked) {
+			spin_lock_bh(&sk->sk_lock.slock);
+			locked = true;
+		}
 
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
+			offset = *seq - TCP_SKB_CB(skb)->seq;
+			skb_len = skb->len;
+			if (friend) {
+				spin_unlock_bh(&sk->sk_lock.slock);
+				locked = false;
+				if (skb->friend) {
+					if (offset < skb_len)
+						goto found_ok_skb;
+					BUG_ON(!(flags & MSG_PEEK));
+					break;
+				}
+			}
+
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
@@ -1656,10 +1989,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				 flags))
 				break;
 
-			offset = *seq - TCP_SKB_CB(skb)->seq;
 			if (tcp_hdr(skb)->syn)
 				offset--;
-			if (offset < skb->len)
+			if (offset < skb_len)
 				goto found_ok_skb;
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
@@ -1670,6 +2002,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		/* Well, if we have backlog, try to process it now yet. */
 
+		if (friend && locked) {
+			spin_unlock_bh(&sk->sk_lock.slock);
+			locked = false;
+		}
+
 		if (copied >= target && !sk->sk_backlog.tail)
 			break;
 
@@ -1716,7 +2053,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		tcp_cleanup_rbuf(sk, copied);
 
-		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
+		if (!sysctl_tcp_low_latency && !friend &&
+		    tp->ucopy.task == user_recv) {
 			/* Install new reader */
 			if (!user_recv && !(flags & (MSG_TRUNC | MSG_PEEK))) {
 				user_recv = current;
@@ -1811,7 +2149,7 @@ do_prequeue:
 
 	found_ok_skb:
 		/* Ok so how much can we use? */
-		used = skb->len - offset;
+		used = skb_len - offset;
 		if (len < used)
 			used = len;
 
@@ -1857,7 +2195,7 @@ do_prequeue:
 
 				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
 
-				if ((offset + used) == skb->len)
+				if ((offset + used) == skb_len)
 					copied_early = true;
 
 			} else
@@ -1877,6 +2215,7 @@ do_prequeue:
 		*seq += used;
 		copied += used;
 		len -= used;
+		offset += used;
 
 		tcp_rcv_space_adjust(sk);
 
@@ -1885,11 +2224,36 @@ skip_copy:
 			tp->urg_data = 0;
 			tcp_fast_path_check(sk);
 		}
-		if (used + offset < skb->len)
+
+		if (friend) {
+			spin_lock_bh(&sk->sk_lock.slock);
+			locked = true;
+			skb_len = skb->len;
+			if (offset < skb_len) {
+				if (skb->friend && len > 0) {
+					/*
+					 * Friend did an skb_put() while we
+					 * were away so process the same skb.
+					 */
+					spin_unlock_bh(&sk->sk_lock.slock);
+					locked = false;
+					goto found_ok_skb;
+				}
+				continue;
+			}
+			if (!(flags & MSG_PEEK)) {
+				__skb_unlink(skb, &sk->sk_receive_queue);
+				__kfree_skb(skb);
+				tcp_friend_write_space(sk);
+			}
 			continue;
+		}
 
-		if (tcp_hdr(skb)->fin)
+		if (offset < skb_len)
+			continue;
+		else if (tcp_hdr(skb)->fin)
 			goto found_fin_ok;
+
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, copied_early);
 			copied_early = false;
@@ -1906,6 +2270,9 @@ skip_copy:
 		break;
 	} while (len > 0);
 
+	if (friend && locked)
+		spin_unlock_bh(&sk->sk_lock.slock);
+
 	if (user_recv) {
 		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 			int chunk;
@@ -2084,6 +2451,9 @@ void tcp_close(struct sock *sk, long timeout)
 		goto adjudge_to_death;
 	}
 
+	if (sk->sk_friend)
+		sock_put(sk->sk_friend);
+
 	/*  We need to flush the recv. buffs.  We do this only on the
 	 *  descriptor close, not protocol-sourced closes, because the
 	 *  reader process may not have drained the data yet!
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa2c2c2..557191f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -530,6 +530,9 @@ void tcp_rcv_space_adjust(struct sock *sk)
 	int time;
 	int space;
 
+	if (sk->sk_friend)
+		return;
+
 	if (tp->rcvq_space.time == 0)
 		goto new_measure;
 
@@ -4358,8 +4361,9 @@ static int tcp_prune_queue(struct sock *sk);
 static int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb,
 				 unsigned int size)
 {
-	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
-	    !sk_rmem_schedule(sk, skb, size)) {
+	if (!sk->sk_friend &&
+	    (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
+	    !sk_rmem_schedule(sk, skb, size))) {
 
 		if (tcp_prune_queue(sk) < 0)
 			return -1;
@@ -5742,6 +5746,16 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 *    state to ESTABLISHED..."
 		 */
 
+		if (skb->friend) {
+			/*
+			 * If friends haven't been made yet, our sk_friend
+			 * still == NULL, then update with the ACK's friend
+			 * value (the listen()er's sock addr) which is used
+			 * as a place holder.
+			 */
+			cmpxchg(&sk->sk_friend, NULL, skb->friend);
+		}
+
 		TCP_ECN_rcv_synack(tp, th);
 
 		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
@@ -5818,9 +5832,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		    tcp_rcv_fastopen_synack(sk, skb, &foc))
 			return -1;
 
-		if (sk->sk_write_pending ||
+		if (!skb->friend && (sk->sk_write_pending ||
 		    icsk->icsk_accept_queue.rskq_defer_accept ||
-		    icsk->icsk_ack.pingpong) {
+		    icsk->icsk_ack.pingpong)) {
 			/* Save one ACK. Data will be ready after
 			 * several ticks, if write_pending is set.
 			 *
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 42b2a6a..90f2419 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1314,6 +1314,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
+	req->friend = skb->friend;
+
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 232a90c..dcd2ffd 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -268,6 +268,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	bool recycle_ok = false;
 
+	if (sk->sk_friend) {
+		tcp_done(sk);
+		return;
+	}
+
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a7b3ec9..217ec9e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,6 +65,9 @@ int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+/* By default, TCP loopback bypass */
+int sysctl_tcp_friends __read_mostly = 1;
+
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
@@ -1012,9 +1015,14 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN)) {
+		if (sysctl_tcp_friends) {
+			/* Only try to make friends if enabled */
+			skb->friend = sk;
+		}
+
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
-	else
+	} else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
@@ -2707,6 +2715,12 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	}
 
 	memset(&opts, 0, sizeof(opts));
+
+	if (sysctl_tcp_friends) {
+		/* Only try to make friends if enabled */
+		skb->friend = sk;
+	}
+
 #ifdef CONFIG_SYN_COOKIES
 	if (unlikely(req->cookie_ts))
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c66b90f..bdffbb0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1037,6 +1037,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 #endif
 
+	req->friend = skb->friend;
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-- 
1.7.7.3
