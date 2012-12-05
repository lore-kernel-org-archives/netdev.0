From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH 1/3] Bruce's orignal tcp friend V3
Date: Wed,  5 Dec 2012 10:54:17 +0800
Message-ID: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1354674153.git.wpan@redhat.com>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
 <cover.1354674151.git.wpan@redhat.com>
Cc: brutus@google.com, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab2LECy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 21:54:27 -0500
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
References: <cover.1354674151.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://patchwork.ozlabs.org/patch/184523/

Rebase on top of commit 03f52a0a5542(ip6mr: Add sizeof verification to
MRT6_ASSERT and MT6_PIM).

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 Documentation/networking/ip-sysctl.txt |    8 +
 include/linux/skbuff.h                 |    2 +
 include/net/request_sock.h             |    1 +
 include/net/sock.h                     |   32 ++-
 include/net/tcp.h                      |   13 +-
 net/core/skbuff.c                      |    1 +
 net/core/sock.c                        |    1 +
 net/core/stream.c                      |   36 ++
 net/ipv4/inet_connection_sock.c        |   20 +
 net/ipv4/sysctl_net_ipv4.c             |    7 +
 net/ipv4/tcp.c                         |  604 +++++++++++++++++++++++++++-----
 net/ipv4/tcp_input.c                   |   22 +-
 net/ipv4/tcp_ipv4.c                    |    2 +
 net/ipv4/tcp_minisocks.c               |    4 +
 net/ipv4/tcp_output.c                  |   16 +-
 net/ipv6/tcp_ipv6.c                    |    1 +
 16 files changed, 679 insertions(+), 91 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 98ac0d7..152f488 100644
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
index f2af494..c890f65 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -334,6 +334,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@_skb_refdst: destination entry (with norefcount bit)
  *	@sp: the security path, used for xfrm
+ *	@friend: loopback friend socket
  *	@len: Length of actual data
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
@@ -409,6 +410,7 @@ struct sk_buff {
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
 #endif
+	struct sock		*friend;
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index a51dbd1..c6dfa26 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -66,6 +66,7 @@ struct request_sock {
 	unsigned long			expires;
 	const struct request_sock_ops	*rsk_ops;
 	struct sock			*sk;
+	struct sock			*friend;
 	u32				secid;
 	u32				peer_secid;
 };
diff --git a/include/net/sock.h b/include/net/sock.h
index c945fba..778d8dd 100644
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
@@ -286,6 +287,14 @@ struct sock {
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
@@ -703,24 +712,40 @@ static inline bool sk_acceptq_is_full(const struct sock *sk)
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
@@ -829,6 +854,7 @@ static inline void sock_rps_reset_rxhash(struct sock *sk)
 	})
 
 extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
+extern int sk_stream_wait_friend(struct sock *sk, long *timeo_p);
 extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
 extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
 extern int sk_stream_error(struct sock *sk, int flags, int err);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3202bde..5f82770 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,6 +292,7 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
+extern int sysctl_tcp_friends;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -687,6 +688,15 @@ void tcp_send_window_probe(struct sock *sk);
 #define TCPHDR_ECE 0x40
 #define TCPHDR_CWR 0x80
 
+/* If skb_get_friend() != NULL, TCP friends per packet state.
+ */
+struct friend_skb_parm {
+	bool	tail_inuse;		/* In use by skb_get_friend() send while */
+					/* on sk_receive_queue for tail put */
+};
+
+#define TCP_FRIEND_CB(tcb) (&(tcb)->header.hf)
+
 /* This is what the send packet queuing engine uses to pass
  * TCP per-packet control information to the transmission code.
  * We also store the host-order sequence numbers in here too.
@@ -699,6 +709,7 @@ struct tcp_skb_cb {
 #if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
+		struct friend_skb_parm	hf;
 	} header;	/* For incoming frames		*/
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
@@ -1041,7 +1052,7 @@ static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (sysctl_tcp_low_latency || !tp->ucopy.task)
+	if (sysctl_tcp_low_latency || !tp->ucopy.task || sk->sk_friend)
 		return false;
 
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 880722e2..665826a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -690,6 +690,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
+	new->friend		= old->friend;
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->csum		= old->csum;
 	new->local_df		= old->local_df;
diff --git a/net/core/sock.c b/net/core/sock.c
index a692ef4..a8f59a9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2225,6 +2225,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
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
index 2026542..ce4b79b 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -659,6 +659,26 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
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
index d84400b..4ca53db 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -796,6 +796,13 @@ static struct ctl_table ipv4_table[] = {
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
index e6eace1..4327deb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -310,6 +310,56 @@ struct tcp_splice_state {
 };
 
 /*
+ * Validate friendp, if not a friend return 0, else if friend is also a
+ * friend return 1, else friendp points to a listen()er so wait for our
+ * friend to be ready then update friendp with pointer to the real friend
+ * and return 1, else an error has occurred so return a -errno.
+ */
+static inline int tcp_friend_validate(struct sock *sk, struct sock **friendp,
+			      long *timeo)
+{
+	struct sock *friend = *friendp;
+
+	if (!friend)
+		return 0;
+	if (unlikely(!friend->sk_friend)) {
+		/* Friendship not complete, wait? */
+		int err;
+
+		if (!timeo)
+			return -EAGAIN;
+		err = sk_stream_wait_friend(sk, timeo);
+		if (err < 0)
+			return err;
+		*friendp = sk->sk_friend;
+	}
+	return 1;
+}
+
+static inline int tcp_friend_send_lock(struct sock *friend)
+{
+	int err = 0;
+
+	spin_lock_bh(&friend->sk_lock.slock);
+	if (unlikely(friend->sk_shutdown & RCV_SHUTDOWN)) {
+		spin_unlock_bh(&friend->sk_lock.slock);
+		err = -ECONNRESET;
+	}
+
+	return err;
+}
+
+static inline void tcp_friend_recv_lock(struct sock *friend)
+{
+	spin_lock_bh(&friend->sk_lock.slock);
+}
+
+static void tcp_friend_unlock(struct sock *friend)
+{
+	spin_unlock_bh(&friend->sk_lock.slock);
+}
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the __sk_mem_schedule() is of this nature: accounting
@@ -589,6 +639,76 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 }
 EXPORT_SYMBOL(tcp_ioctl);
 
+/*
+ * Friend receive_queue tail skb space? If true, set tail_inuse.
+ * Else if RCV_SHUTDOWN, return *copy = -ECONNRESET.
+ */
+static inline struct sk_buff *tcp_friend_tail(struct sock *friend, int *copy)
+{
+	struct sk_buff	*skb = NULL;
+	int		sz = 0;
+
+	if (skb_peek_tail(&friend->sk_receive_queue)) {
+		sz = tcp_friend_send_lock(friend);
+		if (!sz) {
+			skb = skb_peek_tail(&friend->sk_receive_queue);
+			if (skb && skb->friend) {
+				if (!*copy)
+					sz = skb_tailroom(skb);
+				else {
+					sz = *copy - skb->len;
+					if (sz < 0)
+						sz = 0;
+				}
+				if (sz > 0)
+					TCP_FRIEND_CB(TCP_SKB_CB(skb))->
+							tail_inuse = true;
+			}
+			tcp_friend_unlock(friend);
+		}
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
+	tcp_friend_unlock(friend);
+
+	tp = tcp_sk(sk);
+	tp->snd_nxt += copy;
+	tp->pushed_seq += copy;
+	tp->snd_una += copy;
+	tp->snd_up += copy;
+}
+
+static inline bool tcp_friend_push(struct sock *sk, struct sk_buff *skb)
+{
+	struct sock	*friend = sk->sk_friend;
+	int		wait = false;
+
+	skb_set_owner_r(skb, friend);
+	__skb_queue_tail(&friend->sk_receive_queue, skb);
+	if (!sk_rmem_schedule(friend, skb, skb->truesize))
+		wait = true;
+
+	tcp_friend_seq(sk, skb->len, 0);
+	if (skb == skb_peek(&friend->sk_receive_queue))
+		friend->sk_data_ready(friend, 0);
+
+	return wait;
+}
+
 static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
@@ -605,8 +725,13 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
-	skb->csum    = 0;
 	tcb->seq     = tcb->end_seq = tp->write_seq;
+	if (sk->sk_friend) {
+		skb->friend = sk;
+		TCP_FRIEND_CB(tcb)->tail_inuse = false;
+		return;
+	}
+	skb->csum    = 0;
 	tcb->tcp_flags = TCPHDR_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
@@ -626,7 +751,10 @@ static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
 static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 			    int nonagle)
 {
-	if (tcp_send_head(sk)) {
+	if (sk->sk_friend) {
+		if (skb_peek(&sk->sk_friend->sk_receive_queue))
+			sk->sk_friend->sk_data_ready(sk->sk_friend, 0);
+	} else if (tcp_send_head(sk)) {
 		struct tcp_sock *tp = tcp_sk(sk);
 
 		if (!(flags & MSG_MORE) || forced_push(tp))
@@ -758,6 +886,21 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
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
@@ -821,12 +964,53 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	return max(xmit_size_goal, mss_now);
 }
 
+static unsigned int tcp_friend_xmit_size_goal(struct sock *sk, int size_goal)
+{
+	u32 size = SKB_DATA_ALIGN(size_goal);
+	u32 overhead = sizeof(struct skb_shared_info) + sizeof(struct sk_buff);
+
+	/*
+	 * If alloc >= largest skb use largest order, else check
+	 * for optimal tail fill size, else use largest order.
+	 */
+	if (size >= SKB_MAX_ORDER(0, 4))
+		size = SKB_MAX_ORDER(0, 4);
+	else if (size <= (SKB_MAX_ORDER(0, 0) >> 3))
+		size = SKB_MAX_ORDER(0, 0);
+	else if (size <= (SKB_MAX_ORDER(0, 1) >> 3))
+		size = SKB_MAX_ORDER(0, 1);
+	else if (size <= (SKB_MAX_ORDER(0, 0) >> 1))
+		size = SKB_MAX_ORDER(0, 0);
+	else if (size <= (SKB_MAX_ORDER(0, 1) >> 1))
+		size = SKB_MAX_ORDER(0, 1);
+	else if (size <= (SKB_MAX_ORDER(0, 2) >> 1))
+		size = SKB_MAX_ORDER(0, 2);
+	else if (size <= (SKB_MAX_ORDER(0, 3) >> 1))
+		size = SKB_MAX_ORDER(0, 3);
+	else
+		size = SKB_MAX_ORDER(0, 4);
+
+	/* At least 2 true sized in sk_buf */
+	if (size + overhead > (sk_sndbuf_get(sk) >> 1))
+		size = (sk_sndbuf_get(sk) >> 1) - overhead;
+
+	return size;
+}
+
 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 {
 	int mss_now;
+	int tmp;
+
+	if (sk->sk_friend) {
+		mss_now = tcp_friend_xmit_size_goal(sk, *size_goal);
+		tmp = mss_now;
+	} else {
+		mss_now = tcp_current_mss(sk);
+		tmp = tcp_xmit_size_goal(sk, mss_now, !(flags & MSG_OOB));
+	}
 
-	mss_now = tcp_current_mss(sk);
-	*size_goal = tcp_xmit_size_goal(sk, mss_now, !(flags & MSG_OOB));
+	*size_goal = tmp;
 
 	return mss_now;
 }
@@ -834,8 +1018,9 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
 			 size_t psize, int flags)
 {
+	struct sock *friend = sk->sk_friend;
 	struct tcp_sock *tp = tcp_sk(sk);
-	int mss_now, size_goal;
+	int mss_now, size_goal = psize;
 	int err;
 	ssize_t copied;
 	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
@@ -850,6 +1035,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 			goto out_err;
 	}
 
+	err = tcp_friend_validate(sk, &friend, &timeo);
+	if (err < 0)
+		goto out_err;
+
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
@@ -860,25 +1049,47 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 		goto out_err;
 
 	while (psize > 0) {
-		struct sk_buff *skb = tcp_write_queue_tail(sk);
+		struct sk_buff *skb;
+		struct tcp_skb_cb *tcb;
 		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (friend) {
+			copy = size_goal;
+			skb = tcp_friend_tail(friend, &copy);
+			if (copy < 0) {
+				sk->sk_err = -copy;
+				err = -EPIPE;
+				goto out_err;
+			}
+		} else if (!tcp_send_head(sk)) {
+			skb = NULL;
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
+			if (friend)
+				skb = tcp_friend_alloc_skb(sk, 0);
+			else
+				skb = sk_stream_alloc_skb(sk, 0,
+							  sk->sk_allocation);
 			if (!skb)
 				goto wait_for_memory;
 
 			skb_entail(sk, skb);
 			copy = size_goal;
 		}
+		tcb = TCP_SKB_CB(skb);
 
 		if (copy > size)
 			copy = size;
@@ -886,10 +1097,14 @@ new_segment:
 		i = skb_shinfo(skb)->nr_frags;
 		can_coalesce = skb_can_coalesce(skb, i, page, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
-			tcp_mark_push(tp, skb);
+			if (friend) {
+				if (TCP_FRIEND_CB(tcb)->tail_inuse)
+					TCP_FRIEND_CB(tcb)->tail_inuse = false;
+			} else
+				tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
-		if (!sk_wmem_schedule(sk, copy))
+		if (!friend && !sk_wmem_schedule(sk, copy))
 			goto wait_for_memory;
 
 		if (can_coalesce) {
@@ -902,19 +1117,41 @@ new_segment:
 		skb->len += copy;
 		skb->data_len += copy;
 		skb->truesize += copy;
-		sk->sk_wmem_queued += copy;
-		sk_mem_charge(sk, copy);
-		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
-		TCP_SKB_CB(skb)->end_seq += copy;
-		skb_shinfo(skb)->gso_segs = 0;
-
-		if (!copied)
-			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
 
 		copied += copy;
 		poffset += copy;
-		if (!(psize -= copy))
+		psize -= copy;
+
+		if (friend) {
+			err = tcp_friend_send_lock(friend);
+			if (err) {
+				sk->sk_err = -err;
+				err = -EPIPE;
+				goto out_err;
+			}
+			tcb->end_seq += copy;
+			if (TCP_FRIEND_CB(tcb)->tail_inuse) {
+				TCP_FRIEND_CB(tcb)->tail_inuse = false;
+				tcp_friend_seq(sk, copy, copy);
+			} else {
+				if (tcp_friend_push(sk, skb))
+					goto wait_for_sndbuf;
+			}
+			if (!psize)
+				goto out;
+			continue;
+		}
+
+		tcb->end_seq += copy;
+		skb_shinfo(skb)->gso_segs = 0;
+		sk->sk_wmem_queued += copy;
+		sk_mem_charge(sk, copy);
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		if (copied == copy)
+			tcb->tcp_flags &= ~TCPHDR_PSH;
+
+		if (!psize)
 			goto out;
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
@@ -935,7 +1172,8 @@ wait_for_memory:
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
 
-		mss_now = tcp_send_mss(sk, &size_goal, flags);
+		if (!friend)
+			mss_now = tcp_send_mss(sk, &size_goal, flags);
 	}
 
 out:
@@ -1026,10 +1264,12 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
 	struct iovec *iov;
+	struct sock *friend = sk->sk_friend;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
+	struct tcp_skb_cb *tcb;
 	int iovlen, flags, err, copied = 0;
-	int mss_now = 0, size_goal, copied_syn = 0, offset = 0;
+	int mss_now = 0, size_goal = size, copied_syn = 0, offset = 0;
 	bool sg;
 	long timeo;
 
@@ -1057,6 +1297,10 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			goto do_error;
 	}
 
+	err = tcp_friend_validate(sk, &friend, &timeo);
+	if (err < 0)
+		goto out;
+
 	if (unlikely(tp->repair)) {
 		if (tp->repair_queue == TCP_RECV_QUEUE) {
 			copied = tcp_send_rcvq(sk, msg, size);
@@ -1105,24 +1349,38 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			int copy = 0;
 			int max = size_goal;
 
-			skb = tcp_write_queue_tail(sk);
-			if (tcp_send_head(sk)) {
-				if (skb->ip_summed == CHECKSUM_NONE)
-					max = mss_now;
-				copy = max - skb->len;
+			if (friend) {
+				skb = tcp_friend_tail(friend, &copy);
+				if (copy < 0) {
+					sk->sk_err = -copy;
+					err = -EPIPE;
+					goto out_err;
+				}
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
 
@@ -1136,6 +1394,7 @@ new_segment:
 				copy = size_goal;
 				max = size_goal;
 			}
+			tcb = TCP_SKB_CB(skb);
 
 			/* Try to append data to the end of skb. */
 			if (copy > seglen)
@@ -1153,6 +1412,8 @@ new_segment:
 				int i = skb_shinfo(skb)->nr_frags;
 				struct page_frag *pfrag = sk_page_frag(sk);
 
+				BUG_ON(friend);
+
 				if (!sk_page_frag_refill(sk, pfrag))
 					goto wait_for_memory;
 
@@ -1188,16 +1449,37 @@ new_segment:
 				pfrag->offset += copy;
 			}
 
-			if (!copied)
-				TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
-
 			tp->write_seq += copy;
-			TCP_SKB_CB(skb)->end_seq += copy;
-			skb_shinfo(skb)->gso_segs = 0;
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			seglen -= copy;
+
+			if (friend) {
+				err = tcp_friend_send_lock(friend);
+				if (err) {
+					sk->sk_err = -err;
+					err = -EPIPE;
+					goto out_err;
+				}
+				tcb->end_seq += copy;
+				if (TCP_FRIEND_CB(tcb)->tail_inuse) {
+					TCP_FRIEND_CB(tcb)->tail_inuse = false;
+					tcp_friend_seq(sk, copy, 0);
+				} else {
+					if (tcp_friend_push(sk, skb))
+						goto wait_for_sndbuf;
+				}
+				continue;
+			}
+
+			tcb->end_seq += copy;
+			skb_shinfo(skb)->gso_segs = 0;
+
+			if (copied == copy)
+				tcb->tcp_flags &= ~TCPHDR_PSH;
+
+			if (seglen == 0 && iovlen == 0)
 				goto out;
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
@@ -1219,7 +1501,8 @@ wait_for_memory:
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
 
-			mss_now = tcp_send_mss(sk, &size_goal, flags);
+			if (!friend)
+				mss_now = tcp_send_mss(sk, &size_goal, flags);
 		}
 	}
 
@@ -1230,7 +1513,12 @@ out:
 	return copied + copied_syn;
 
 do_fault:
-	if (!skb->len) {
+	if (skb->friend) {
+		if (TCP_FRIEND_CB(tcb)->tail_inuse)
+			TCP_FRIEND_CB(tcb)->tail_inuse = false;
+		else
+			__kfree_skb(skb);
+	} else if (!skb->len) {
 		tcp_unlink_write_queue(skb, sk);
 		/* It is the one place in all of TCP, except connection
 		 * reset, where we can be unlinking the send_head.
@@ -1249,6 +1537,13 @@ out_err:
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
@@ -1327,7 +1622,12 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
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
@@ -1431,17 +1731,27 @@ static void tcp_service_net_dma(struct sock *sk, bool wait)
 }
 #endif
 
-static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
+static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off,
+					   size_t *len)
 {
 	struct sk_buff *skb;
 	u32 offset;
+	size_t avail;
 
 	skb_queue_walk(&sk->sk_receive_queue, skb) {
-		offset = seq - TCP_SKB_CB(skb)->seq;
-		if (tcp_hdr(skb)->syn)
-			offset--;
-		if (offset < skb->len || tcp_hdr(skb)->fin) {
+		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
+
+		offset = seq - tcb->seq;
+		if (skb->friend)
+			avail = (u32)(tcb->end_seq - seq);
+		else {
+			if (tcp_hdr(skb)->syn)
+				offset--;
+			avail = skb->len - offset;
+		}
+		if (avail > 0 || (!skb->friend && tcp_hdr(skb)->fin)) {
 			*off = offset;
+			*len = avail;
 			return skb;
 		}
 	}
@@ -1467,15 +1777,23 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	u32 seq = tp->copied_seq;
 	u32 offset;
 	int copied = 0;
+	size_t len;
+	int err;
+	struct sock *friend = sk->sk_friend;
+	long timeo = sock_rcvtimeo(sk, false);
 
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
-	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
-		if (offset < skb->len) {
-			int used;
-			size_t len;
+	err = tcp_friend_validate(sk, &friend, &timeo);
+	if (err < 0)
+		return err;
+	if (friend)
+		tcp_friend_recv_lock(sk);
 
-			len = skb->len - offset;
+	while ((skb = tcp_recv_skb(sk, seq, &offset, &len)) != NULL) {
+		if (len > 0) {
+			int used;
+	again:
 			/* Stop reading if we hit a patch of urgent data */
 			if (tp->urg_data) {
 				u32 urg_offset = tp->urg_seq - seq;
@@ -1484,6 +1802,10 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				if (!len)
 					break;
 			}
+
+			if (friend)
+				tcp_friend_unlock(sk);
+
 			used = recv_actor(desc, skb, offset, len);
 			if (used < 0) {
 				if (!copied)
@@ -1494,33 +1816,65 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
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
+
+			if (friend)
+				tcp_friend_recv_lock(sk);
+			if (skb->friend) {
+				len = (u32)(TCP_SKB_CB(skb)->end_seq - seq);
+				if (len > 0) {
+					/*
+					 * Friend did an skb_put() while we
+					 * were away so process the same skb.
+					 */
+					if (!desc->count)
+						break;
+					tp->copied_seq = seq;
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
+				skb = tcp_recv_skb(sk, seq-1, &offset, &len);
+				if (!skb || (offset+1 != skb->len))
+					break;
+			}
 		}
-		if (tcp_hdr(skb)->fin) {
+		if (!skb->friend && tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, false);
 			++seq;
 			break;
 		}
-		sk_eat_skb(sk, skb, false);
+		if (skb->friend) {
+			if (!TCP_FRIEND_CB(TCP_SKB_CB(skb))->tail_inuse) {
+				__skb_unlink(skb, &sk->sk_receive_queue);
+				__kfree_skb(skb);
+				tcp_friend_write_space(sk);
+			}
+			tcp_friend_unlock(sk);
+			tcp_friend_recv_lock(sk);
+		} else
+			sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
 			break;
 		tp->copied_seq = seq;
 	}
 	tp->copied_seq = seq;
 
-	tcp_rcv_space_adjust(sk);
+	if (friend) {
+		tcp_friend_unlock(sk);
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
@@ -1536,6 +1890,7 @@ EXPORT_SYMBOL(tcp_read_sock);
 int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int nonblock, int flags, int *addr_len)
 {
+	struct sock *friend = sk->sk_friend;
 	struct tcp_sock *tp = tcp_sk(sk);
 	int copied = 0;
 	u32 peek_seq;
@@ -1548,6 +1903,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	bool copied_early = false;
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
+	bool locked = false;
 
 	lock_sock(sk);
 
@@ -1557,6 +1913,10 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	timeo = sock_rcvtimeo(sk, nonblock);
 
+	err = tcp_friend_validate(sk, &friend, &timeo);
+	if (err < 0)
+		goto out;
+
 	/* Urgent data needs to be handled specially. */
 	if (flags & MSG_OOB)
 		goto recv_urg;
@@ -1595,7 +1955,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-		    !sysctl_tcp_low_latency &&
+		    !sysctl_tcp_low_latency && !friend &&
 		    net_dma_find_channel()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
@@ -1606,7 +1966,10 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 #endif
 
+	err = 0;
+
 	do {
+		struct tcp_skb_cb *tcb;
 		u32 offset;
 
 		/* Are we at urgent data? Stop if we have read anything or have SIGURG pending. */
@@ -1614,37 +1977,77 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (copied)
 				break;
 			if (signal_pending(current)) {
-				copied = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+				err = timeo ? sock_intr_errno(timeo) : -EAGAIN;
 				break;
 			}
 		}
 
-		/* Next get a buffer. */
+		/*
+		 * Next get a buffer. Note, for friends sendmsg() queues
+		 * data directly to our sk_receive_queue by holding our
+		 * slock and either tail queuing a new skb or adding new
+		 * data to the tail skb. In the later case tail_inuse is
+		 * set, slock dropped, copyin, skb->len updated, re-hold
+		 * slock, end_seq updated, so we can only use the bytes
+		 * from *seq to end_seq!
+		 */
+		if (friend && !locked) {
+			tcp_friend_recv_lock(sk);
+			locked = true;
+		}
 
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
+			tcb = TCP_SKB_CB(skb);
+			offset = *seq - tcb->seq;
+			if (friend) {
+				if (skb->friend) {
+					used = (u32)(tcb->end_seq - *seq);
+					if (used > 0) {
+						tcp_friend_unlock(sk);
+						locked = false;
+						/* Can use it all */
+						goto found_ok_skb;
+					}
+					/* No data to copyout */
+					if (flags & MSG_PEEK)
+						continue;
+					if (!TCP_FRIEND_CB(tcb)->tail_inuse)
+						goto unlink;
+					break;
+				}
+				tcp_friend_unlock(sk);
+				locked = false;
+			}
+
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
-			if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
+			if (WARN(before(*seq, tcb->seq),
 				 "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
-				 *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
-				 flags))
+				 *seq, tcb->seq, tp->rcv_nxt, flags))
 				break;
 
-			offset = *seq - TCP_SKB_CB(skb)->seq;
 			if (tcp_hdr(skb)->syn)
 				offset--;
-			if (offset < skb->len)
+			if (offset < skb->len) {
+				/* Ok so how much can we use? */
+				used = skb->len - offset;
 				goto found_ok_skb;
+			}
 			if (tcp_hdr(skb)->fin)
 				goto found_fin_ok;
 			WARN(!(flags & MSG_PEEK),
 			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
-			     *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt, flags);
+			     *seq, tcb->seq, tp->rcv_nxt, flags);
 		}
 
 		/* Well, if we have backlog, try to process it now yet. */
 
+		if (friend && locked) {
+			tcp_friend_unlock(sk);
+			locked = false;
+		}
+
 		if (copied >= target && !sk->sk_backlog.tail)
 			break;
 
@@ -1691,7 +2094,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		tcp_cleanup_rbuf(sk, copied);
 
-		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
+		if (!sysctl_tcp_low_latency && !friend &&
+		    tp->ucopy.task == user_recv) {
 			/* Install new reader */
 			if (!user_recv && !(flags & (MSG_TRUNC | MSG_PEEK))) {
 				user_recv = current;
@@ -1791,8 +2195,6 @@ do_prequeue:
 		continue;
 
 	found_ok_skb:
-		/* Ok so how much can we use? */
-		used = skb->len - offset;
 		if (len < used)
 			used = len;
 
@@ -1849,7 +2251,7 @@ do_prequeue:
 				if (err) {
 					/* Exception. Bailout! */
 					if (!copied)
-						copied = -EFAULT;
+						copied = err;
 					break;
 				}
 			}
@@ -1858,6 +2260,7 @@ do_prequeue:
 		*seq += used;
 		copied += used;
 		len -= used;
+		offset += used;
 
 		tcp_rcv_space_adjust(sk);
 
@@ -1866,10 +2269,43 @@ skip_copy:
 			tp->urg_data = 0;
 			tcp_fast_path_check(sk);
 		}
-		if (used + offset < skb->len)
+
+		if (skb->friend) {
+			tcp_friend_recv_lock(sk);
+			locked = true;
+			used = (u32)(tcb->end_seq - *seq);
+			if (used) {
+				/*
+				 * Friend did an skb_put() while we were away
+				 * so if more to do process the same skb.
+				 */
+				if (len > 0) {
+					tcp_friend_unlock(sk);
+					locked = false;
+					goto found_ok_skb;
+				}
+				continue;
+			}
+			if (TCP_FRIEND_CB(tcb)->tail_inuse) {
+				/* Give sendmsg a chance */
+				tcp_friend_unlock(sk);
+				locked = false;
+				continue;
+			}
+			if (!(flags & MSG_PEEK)) {
+		unlink:
+				__skb_unlink(skb, &sk->sk_receive_queue);
+				__kfree_skb(skb);
+				tcp_friend_unlock(sk);
+				locked = false;
+				tcp_friend_write_space(sk);
+			}
 			continue;
+		}
 
-		if (tcp_hdr(skb)->fin)
+		if (offset < skb->len)
+			continue;
+		else if (tcp_hdr(skb)->fin)
 			goto found_fin_ok;
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, copied_early);
@@ -1887,6 +2323,9 @@ skip_copy:
 		break;
 	} while (len > 0);
 
+	if (friend && locked)
+		tcp_friend_unlock(sk);
+
 	if (user_recv) {
 		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 			int chunk;
@@ -2065,6 +2504,9 @@ void tcp_close(struct sock *sk, long timeout)
 		goto adjudge_to_death;
 	}
 
+	if (sk->sk_friend)
+		sock_put(sk->sk_friend);
+
 	/*  We need to flush the recv. buffs.  We do this only on the
 	 *  descriptor close, not protocol-sourced closes, because the
 	 *  reader process may not have drained the data yet!
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fc67831..9640a81 100644
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
 
@@ -4350,8 +4353,9 @@ static int tcp_prune_queue(struct sock *sk);
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
@@ -5722,6 +5726,16 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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
 
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
@@ -5797,9 +5811,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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
index 1ed2307..f494914 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1512,6 +1512,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
+	req->friend = skb->friend;
+
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f35f2df..36d832a 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -270,6 +270,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	bool recycle_ok = false;
 
+	if (sk->sk_friend)
+		goto out;
+
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
 
@@ -349,6 +352,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	}
 
 	tcp_update_metrics(sk);
+out:
 	tcp_done(sk);
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8ac0855..509c5e3 100644
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
 
@@ -1025,9 +1028,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN)) {
+		/* Only try to make friends if enabled */
+		if (sysctl_tcp_friends)
+			skb->friend = sk;
+
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
-	else
+	} else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
@@ -2725,6 +2732,11 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	}
 
 	memset(&opts, 0, sizeof(opts));
+
+	/* Only try to make friends if enabled */
+	if (sysctl_tcp_friends)
+		skb->friend = sk;
+
 #ifdef CONFIG_SYN_COOKIES
 	if (unlikely(req->cookie_ts))
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6565cf5..828d5f7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -969,6 +969,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 #endif
 
+	req->friend = skb->friend;
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-- 
1.7.4.4
