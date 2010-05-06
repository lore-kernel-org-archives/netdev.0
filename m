From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Thu, 06 May 2010 01:06:51 -0700 (PDT)
Message-ID: <20100506.010651.173849727.davem@davemloft.net>
References: <1271775421.7895.19.camel@edumazet-laptop>
	<20100420.144106.118596093.davem@davemloft.net>
	<g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, xiaosuo@gmail.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751171Ab0EFIGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:06:44 -0400
In-Reply-To: <g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 21 Apr 2010 12:12:41 -0700

> On Tue, Apr 20, 2010 at 2:41 PM, David Miller <davem@davemloft.net> wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 20 Apr 2010 16:57:01 +0200
>>
>>> I know many applications using TCP on loopback, they are real :)
>>
>> This is all true and I support your hashing patch and all of that.
>>
>> But if we really want TCP over loopback to go fast, there are much
>> better ways to do this.
>>
>> Eric, do you remember that "TCP friends" rough patch I sent you last
>> year that essentailly made TCP sockets over loopback behave like
>> AF_UNIX ones and just queue the SKBs directly to the destination
>> socket without doing any protocol work?
>>
> This is sounds very interesting!  Could you post a patch? :-)

I was finally able to unearth a copy, it's completely raw, it's at least
a year old, and it's not fully implemented at all.

But you asked for it :-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 299ec4b..7f855d3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -206,6 +206,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@mac_header: Link layer header
  *	@dst: destination entry
  *	@sp: the security path, used for xfrm
+ *	@friend: loopback friend socket
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@len: Length of actual data
  *	@data_len: Data length
@@ -262,6 +263,7 @@ struct sk_buff {
 		struct  rtable		*rtable;
 	};
 	struct	sec_path	*sp;
+	struct sock		*friend;
 
 	/*
 	 * This is the control buffer. It is free to use for every
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index b220b5f..52b2f7a 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -53,6 +53,7 @@ struct request_sock {
 	unsigned long			expires;
 	const struct request_sock_ops	*rsk_ops;
 	struct sock			*sk;
+	struct sock			*friend;
 	u32				secid;
 	u32				peer_secid;
 };
diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..3e86190 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -137,6 +137,7 @@ struct sock_common {
   *	@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
   *	@sk_lock:	synchronizer
   *	@sk_rcvbuf: size of receive buffer in bytes
+  *	@sk_friend: loopback friend socket
   *	@sk_sleep: sock wait queue
   *	@sk_dst_cache: destination cache
   *	@sk_dst_lock: destination cache lock
@@ -227,6 +228,7 @@ struct sock {
 		struct sk_buff *head;
 		struct sk_buff *tail;
 	} sk_backlog;
+	struct sock		*sk_friend;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
 	struct xfrm_policy	*sk_policy[2];
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4fe605f..0eef90a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -435,6 +435,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_INET
 	new->sp			= secpath_get(old->sp);
 #endif
+	new->friend		= old->friend;
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->csum_start		= old->csum_start;
 	new->csum_offset	= old->csum_offset;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 828ea21..375dc2e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -503,6 +503,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 	if (newsk != NULL) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 
+		newsk->sk_friend = req->friend;
+
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 58ac838..042ee1d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -474,7 +474,8 @@ static inline int forced_push(struct tcp_sock *tp)
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
 
-static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
+static inline void skb_entail(struct sock *sk, struct sk_buff *skb,
+			      struct sk_buff_head *friend_queue)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
@@ -484,7 +485,10 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	tcb->flags   = TCPCB_FLAG_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
-	tcp_add_write_queue_tail(sk, skb);
+	if (sk->sk_friend)
+		__skb_queue_tail(friend_queue, skb);
+	else
+		tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
 	if (tp->nonagle & TCP_NAGLE_PUSH)
@@ -501,7 +505,7 @@ static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
 }
 
 static inline void tcp_push(struct sock *sk, int flags, int mss_now,
-			    int nonagle)
+			    int nonagle, struct sk_buff_head *friend_queue)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -512,6 +516,19 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 		tcp_mark_urg(tp, flags, skb);
 		__tcp_push_pending_frames(sk, mss_now,
 					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
+	} else if (sk->sk_friend) {
+		struct sock *friend = sk->sk_friend;
+		struct sk_buff *skb;
+		unsigned int len;
+
+		spin_lock_bh(&friend->sk_lock.slock);
+		len = 0;
+		while ((skb = __skb_dequeue(friend_queue)) != NULL) {
+			len += skb->len;
+			__skb_queue_tail(&sk->sk_receive_queue, skb);
+		}
+		sk->sk_data_ready(friend, len);
+		spin_unlock_bh(&friend->sk_lock.slock);
 	}
 }
 
@@ -658,6 +675,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 			 size_t psize, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff_head friend_queue;
 	int mss_now, size_goal;
 	int err;
 	ssize_t copied;
@@ -674,6 +692,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	size_goal = tp->xmit_size_goal;
 	copied = 0;
 
+	skb_queue_head_init(&friend_queue);
+
 	err = -EPIPE;
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto do_error;
@@ -694,7 +714,7 @@ new_segment:
 			if (!skb)
 				goto wait_for_memory;
 
-			skb_entail(sk, skb);
+			skb_entail(sk, skb, &friend_queue);
 			copy = size_goal;
 		}
 
@@ -749,7 +769,8 @@ wait_for_sndbuf:
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 		if (copied)
-			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH,
+				 &friend_queue);
 
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
@@ -760,7 +781,7 @@ wait_for_memory:
 
 out:
 	if (copied)
-		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle, &friend_queue);
 	return copied;
 
 do_error:
@@ -817,6 +838,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct sock *sk = sock->sk;
 	struct iovec *iov;
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff_head friend_queue;
 	struct sk_buff *skb;
 	int iovlen, flags;
 	int mss_now, size_goal;
@@ -849,6 +871,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto do_error;
 
+	skb_queue_head_init(&friend_queue);
 	while (--iovlen >= 0) {
 		int seglen = iov->iov_len;
 		unsigned char __user *from = iov->iov_base;
@@ -881,7 +904,7 @@ new_segment:
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
 					skb->ip_summed = CHECKSUM_PARTIAL;
 
-				skb_entail(sk, skb);
+				skb_entail(sk, skb, &friend_queue);
 				copy = size_goal;
 			}
 
@@ -995,7 +1018,8 @@ wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 			if (copied)
-				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+				tcp_push(sk, flags & ~MSG_MORE, mss_now,
+					 TCP_NAGLE_PUSH, &friend_queue);
 
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
@@ -1007,7 +1031,7 @@ wait_for_memory:
 
 out:
 	if (copied)
-		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle, &friend_queue);
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return copied;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cdc051b..eb6f914 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4998,6 +4998,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 *    state to ESTABLISHED..."
 		 */
 
+		sk->sk_friend = skb->friend;
 		TCP_ECN_rcv_synack(tp, th);
 
 		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7766151..4d91ff4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1289,6 +1289,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!req)
 		goto drop;
 
+	req->friend = skb->friend;
 #ifdef CONFIG_TCP_MD5SIG
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index debf235..a4d4c14 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -577,6 +577,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
+		skb->friend = sk;
 		tcp_syn_build_options((__be32 *)(th + 1),
 				      tcp_advertise_mss(sk),
 				      (sysctl_flags & SYSCTL_FLAG_TSTAMPS),
@@ -1006,6 +1007,8 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 		xmit_size_goal -= (xmit_size_goal % mss_now);
 	}
+	if (sk->sk_friend)
+		xmit_size_goal = ~(u16)0;
 	tp->xmit_size_goal = xmit_size_goal;
 
 	return mss_now;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..c79d3ea 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1280,6 +1280,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (req == NULL)
 		goto drop;
 
+	req->friend = skb->friend;
 #ifdef CONFIG_TCP_MD5SIG
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 #endif
