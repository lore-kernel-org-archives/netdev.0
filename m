From: Bruce "Brutus" Curtis <brutus@google.com>
Subject: [RFC][PATCH] net-tcp: TCP/IP stack bypass for loopback connections.
Date: Tue, 22 Nov 2011 16:09:33 -0800
Message-ID: <20111220193614.0733F160AA8@brutus.mtv.corp.google.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:54321 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab1LTTgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 14:36:15 -0500
Received: by ghrr15 with SMTP id r15so615331ghr.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 11:36:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP/IP loopback socket pair stack bypass, based on an idea by, and
rough upstream patch from, David Miller <davem@davemloft.net> called
"friends", the data structure modifcations and connection scheme are
reused with new dedicated code for the data path.

A new sysctl, net.ipv4.tcp_friends, is added:
  0: disable friends and use the stock data path.
  1: enable friends and bypass the stack data path, the default.

Note, when friends is enabled any loopback interpose, e.g. tcpdump,
will only see the TCP/IP packets during connection establishment and
finish, all data bypasses the stack and instead is delivered to the
destination socket directly.

Testing on a Westmere 3.2 GHz CPU based system, netperf results for
a single connection show increased TCP_STREAM throughput, increased
TCP_RR and TCP_CRR transaction rate for most message sizes vs baseline
and comparable to AF_UNIX.

TCP_RR:

netperf  Baseline  AF_UNIX      Friends
-r N,N   Trans./S  Trans./S     Trans./S
   64    120415    255529 212%  279107 232% 109%
   1K    112217    242684 216%  268292 239% 111%
   8K     79352    184050 232%  196160 247% 107%
  32K     40156     66678 166%   65389 163%  98%
  64K     24876     44071 177%   36450 147%  83%
 128K     13805     22745 165%   17408 126%  77%
 256K      8325     11811 142%   10190 122%  86%
 512K      4859      6268 129%    5683 117%  91%
   1M      2610      3234 124%    3152 121%  97%
  16M        88       128 145%     128 145% 100%

TCP_CRR:

netperf  Baseline  AF_UNIX      Friends
  -r N   Trans./S  Trans./S     Trans./S
   64     32943         -        44720 136%
   1K     32172         -        43759 136%
   8K     27991         -        39313 140%
  32K     19316         -        25297 131%
  64K     12801         -        17915 140%
 128K      3710*        -         6996  *
 256K         4*        -         6166  *
 512K         4*        -         4186  *
   1M         2*        -         2838  *
  16M        49*        -          131  *

TCP_STREAM:

netperf  Baseline  AF_UNIX      Friends
-m/-M N  Mbits/S   Mbits/S      Mbits/S
   64      2399      1064  44%    1646  69% 155%
   1K     14412     15310 106%   15554 108% 102%
   8K     27468     58198 212%   52320 190%  90%
  32K     37382     67252 180%   64611 173%  96%
  64K     40949     64505 158%   66874 163% 104%
 128K     38149     54670 143%   59852 157% 109%
 256K     39660     53474 135%   57464 145% 107%
 512K     40975     53506 131%   58050 142% 108%
   1M     40541     54017 133%   57193 141% 106%
  16M     27539     38515 140%   35270 128%  92%

Note, "-" denotes test not supported for transport.

Note, "*" denotes test results reported without statistical confidence.

Testing with multiple netperf instances:

N copies of: netperf -l 100 -t TCP_STREAM
             netperf -l 100 -t STREAM_STREAM -- -s 51882 -m 16384 -M 87380
             netperf -l 100 -t TCP_STREAM

            Baseline         AF_UNIX          Friends
   N   Mbits/S   %CPU   Mbits/S   %CPU   Mbits/S   %CPU
   1     27799    167     52715    196     52958    202
   2     59777    291    111137    388    111116    402
  10    102822   1674    149151   1997    154970   1896
  20     79894   2224    146425   2392    152906   2388
 100     75611   2225     80926   2399     92491   2399
 200     79623   2230    125498   2400    110742   2400
1000     86717   2236    108066   2400    111225   2400

Signed-off-by: Bruce Curtis <brutus@google.com>
---
 include/linux/skbuff.h          |    2 +
 include/net/request_sock.h      |    1 +
 include/net/sock.h              |    2 +
 include/net/tcp.h               |   48 +++
 net/core/skbuff.c               |    1 +
 net/ipv4/Makefile               |    2 +-
 net/ipv4/inet_connection_sock.c |    7 +-
 net/ipv4/sysctl_net_ipv4.c      |   10 +
 net/ipv4/tcp.c                  |   27 +-
 net/ipv4/tcp_friend.c           |  841 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c            |    9 +-
 net/ipv4/tcp_ipv4.c             |    1 +
 net/ipv4/tcp_minisocks.c        |    5 +
 net/ipv4/tcp_output.c           |   17 +-
 net/ipv6/tcp_ipv6.c             |    1 +
 15 files changed, 962 insertions(+), 12 deletions(-)
 create mode 100644 net/ipv4/tcp_friend.c

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a6b352..2777e0d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -319,6 +319,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@_skb_refdst: destination entry (with norefcount bit)
  *	@sp: the security path, used for xfrm
+ *	@friend: loopback friend socket
  *	@len: Length of actual data
  *	@data_len: Data length
  *	@mac_len: Length of link layer header
@@ -391,6 +392,7 @@ struct sk_buff {
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
index 5ac682f..2dd0179 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -218,6 +218,7 @@ struct sock_common {
   *	@sk_rxhash: flow hash received from netif layer
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
+  *	@sk_friend: private area, net family specific, when have a friend
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
   *	@sk_socket: Identd and reporting IO signals
@@ -326,6 +327,7 @@ struct sock {
 	long			sk_rcvtimeo;
 	long			sk_sndtimeo;
 	void			*sk_protinfo;
+	void			*sk_friend;
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	struct socket		*sk_socket;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e147f42..2549025 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1558,6 +1558,54 @@ static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
 	return (struct tcp_extend_values *)rvp;
 }
 
+/*
+ * For TCP a struct sock sk_friend member has 1 of 5 values:
+ *
+ * 1) NULL on initialization, no friend
+ * 2) dummy address &tcp_friend_CONNECTING on connect() return before accept()
+ * 3) a valid struct tcp_friend address once a friend has been made.
+ * 4) dummy address &tcp_friend_EARLYCLOSE on close() of connect()ed before
+ *    accept()
+ * 5) dummy address &tcp_friend_CLOSED on close() to denote no longer a friend,
+ *    this is used during connection teardown to skip TCP_TIME_WAIT
+ */
+extern unsigned tcp_friend_connecting;
+extern unsigned tcp_friend_earlyclose;
+extern unsigned tcp_friend_closed;
+
+#define tcp_friend_CONNECTING ((void *)&tcp_friend_connecting)
+#define tcp_friend_EARLYCLOSE ((void *)&tcp_friend_earlyclose)
+#define tcp_friend_CLOSED ((void *)&tcp_friend_closed)
+
+static inline int tcp_had_friend(struct sock *sk)
+{
+	if (sk->sk_friend == tcp_friend_CLOSED ||
+	   sk->sk_friend == tcp_friend_EARLYCLOSE)
+		return 1;
+	return 0;
+}
+
+static inline int tcp_has_friend(struct sock *sk)
+{
+	if (sk->sk_friend && !tcp_had_friend(sk))
+		return 1;
+	return 0;
+}
+
+#define tcp_sk_friend(__sk) ((struct tcp_friend *)(__sk)->sk_friend)
+
+extern int tcp_friend_sendmsg(struct kiocb *iocb, struct sock *sk,
+			      struct msghdr *msg, size_t size, long *timeop);
+extern int tcp_friend_recvmsg(struct kiocb *iocb, struct sock *sk,
+			      struct msghdr *msg, size_t len, int nonblock,
+			      int flags);
+extern void tcp_friend_connect(struct sock *sk, struct sock *other);
+extern void tcp_friend_shutdown(struct sock *sk, int how);
+extern void tcp_friend_close(struct sock *sk);
+
+extern void tcp_v4_init(void);
+extern void tcp_init(void);
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca4db40..2fc779d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -545,6 +545,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
+	new->friend		= old->friend;
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->csum		= old->csum;
 	new->local_df		= old->local_df;
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f2dc69c..919264d 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -7,7 +7,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
-	     tcp_minisocks.o tcp_cong.o \
+	     tcp_minisocks.o tcp_cong.o tcp_friend.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c14d88a..e65e905 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -466,9 +466,9 @@ void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
-/* Only thing we need from tcp.h */
+/* Only things we need from tcp.h */
 extern int sysctl_tcp_synack_retries;
-
+extern void tcp_friend_connect(struct sock *sk, struct sock *other);
 
 /* Decide when to expire the request and when to resend SYN-ACK */
 static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
@@ -596,6 +596,9 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 	if (newsk != NULL) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 
+		if (req->friend)
+			tcp_friend_connect(newsk, req->friend);
+
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 69fd720..c90cbce 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -35,6 +35,9 @@ static int ip_ttl_max = 255;
 static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 
+/* Loopback bypass */
+int sysctl_tcp_friends = 1;
+
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
 {
@@ -721,6 +724,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_ping_group_range,
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
index 34f5db1..9caa2dd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -935,6 +935,16 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	/* This should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
+	err = -EPIPE;
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		goto out_err;
+
+	if (tcp_has_friend(sk)) {
+		err = tcp_friend_sendmsg(iocb, sk, msg, size, &timeo);
+		release_sock(sk);
+		return err;
+	}
+
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 
 	/* Ok commence sending. */
@@ -942,10 +952,6 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	iov = msg->msg_iov;
 	copied = 0;
 
-	err = -EPIPE;
-	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
-		goto out_err;
-
 	sg = sk->sk_route_caps & NETIF_F_SG;
 
 	while (--iovlen >= 0) {
@@ -1427,6 +1433,12 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (flags & MSG_OOB)
 		goto recv_urg;
 
+	if (tcp_has_friend(sk)) {
+		err = tcp_friend_recvmsg(iocb, sk, msg, len, nonblock, flags);
+		release_sock(sk);
+		return err;
+	}
+
 	seq = &tp->copied_seq;
 	if (flags & MSG_PEEK) {
 		peek_seq = tp->copied_seq;
@@ -1855,6 +1867,9 @@ static int tcp_close_state(struct sock *sk)
 
 void tcp_shutdown(struct sock *sk, int how)
 {
+	if (tcp_has_friend(sk))
+		tcp_friend_shutdown(sk, how);
+
 	/*	We need to grab some memory, and put together a FIN,
 	 *	and then put it into the queue to be sent.
 	 *		Tim MacKenzie(tym@dibbler.cs.monash.edu.au) 4 Dec '92.
@@ -1880,8 +1895,12 @@ void tcp_close(struct sock *sk, long timeout)
 	int state;
 
 	lock_sock(sk);
+
 	sk->sk_shutdown = SHUTDOWN_MASK;
 
+	if (tcp_has_friend(sk))
+		tcp_friend_close(sk);
+
 	if (sk->sk_state == TCP_LISTEN) {
 		tcp_set_state(sk, TCP_CLOSE);
 
diff --git a/net/ipv4/tcp_friend.c b/net/ipv4/tcp_friend.c
new file mode 100644
index 0000000..617cc59
--- /dev/null
+++ b/net/ipv4/tcp_friend.c
@@ -0,0 +1,841 @@
+/* net/ipv4/tcp_friend.c
+ *
+ * TCP/IP loopback socket pair stack bypass, based on an idea by, and
+ * rough patch from, David Miller <davem@davemloft.net> called "friends"
+ * but with code for a dedicated data path for maximum performance.
+ *
+ * Authors:     Bruce "Brutus" Curtis, <brutus@google.com>
+ *
+ * Copyright (C) 2011 Google Incorporated
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/poll.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/skbuff.h>
+#include <linux/scatterlist.h>
+#include <linux/splice.h>
+#include <linux/net.h>
+#include <linux/socket.h>
+#include <linux/random.h>
+#include <linux/bootmem.h>
+#include <linux/highmem.h>
+#include <linux/swap.h>
+#include <linux/cache.h>
+#include <linux/err.h>
+#include <linux/crypto.h>
+#include <linux/time.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+
+#include <net/icmp.h>
+#include <net/tcp.h>
+#include <net/xfrm.h>
+#include <net/ip.h>
+#include <net/netdma.h>
+#include <net/sock.h>
+
+#include <asm/ioctls.h>
+
+/*
+ * Dummy struct tcp_friend stubs, see "include/net/tcp.h" for details.
+ */
+unsigned tcp_friend_connecting;
+unsigned tcp_friend_earlyclose;
+unsigned tcp_friend_closed;
+
+/**
+ * enum tcp_friend_mode - friend sendmsg() -> recvmsg() mode.
+ * @DATA_BYPASS:	in stack data bypass
+ * @DATA_HIWAT:		filled sk_buff, is waiting / will wait
+ * @SHUTDOWN:		other_sk SEND_SHUTDOWN
+ */
+enum tcp_friend_mode {
+	DATA_BYPASS,
+	DATA_HIWAT,
+	SHUTDOWN
+};
+
+/**
+ * struct tcp_friend - sendmsg() -> recvmsg() state, one for each friend.
+ * @other_sk:		other sock bypassed to
+ * @other_tf:		other sock's struct tcp_friend
+ * @mode:		mode of sendmsg() -> recvmsg()
+ * @send_tail:		last sendmsg() tail fill message size
+ * @send_pend:		have sendmsg() -> recvmsg() data pending
+ * @have_rspace:	have recv space for sendmsg() -> recvmsg()
+ * @using_seq:		one shared by both friends *use_seq value
+ * @use_seq:		use full TCP sequence state
+ * @ref:		count of pointers to
+ * @lock:		spinlock for exclusive access to
+ */
+struct tcp_friend {
+	struct sock		*other_sk;
+	struct tcp_friend	*other_tf;
+	enum tcp_friend_mode	mode;
+	int			send_tail;
+	int			send_pend;
+	int			have_rspace;
+	atomic_t		using_seq;
+	atomic_t		*use_seq;
+	int			ref;
+	spinlock_t		lock;
+};
+
+/*
+ * Called when sk_friend == CONNECTING to handle connect()/{send,recv}msg()
+ * race with accept(), wait for accept() to finish.
+ */
+static int tcp_friend_wait_connect(struct sock *sk, long *timeo_p)
+{
+	int done;
+
+	DEFINE_WAIT(wait);
+
+	/* Wait for friends to be made */
+	do {
+		if (!*timeo_p)
+			return -EAGAIN;
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo_p);
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		done = sk_wait_event(sk, timeo_p,
+				(tcp_sk_friend(sk) != tcp_friend_CONNECTING));
+		finish_wait(sk_sleep(sk), &wait);
+	} while (!done);
+
+	if (tcp_had_friend(sk)) {
+		/* While waiting, closed */
+		return -EPIPE;
+	}
+
+	return 0;
+}
+
+static inline void tcp_friend_have_rspace(struct tcp_friend *tf, int true)
+{
+	struct sock	*osk = tf->other_sk;
+
+	if (true) {
+		if (!tf->have_rspace) {
+			tf->have_rspace = 1;
+			/* Ready for send(), rm back-pressure */
+			osk->sk_wmem_queued -= osk->sk_sndbuf;
+		}
+	} else {
+		if (tf->have_rspace) {
+			tf->have_rspace = 0;
+			/* No more send() please, back-pressure */
+			osk->sk_wmem_queued += osk->sk_sndbuf;
+		}
+	}
+}
+
+static void tcp_friend_space_wait(struct sock *sk, spinlock_t *lock,
+				  long *timeo_p)
+{
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+
+	spin_unlock(lock);
+	release_sock(sk);
+	*timeo_p = schedule_timeout(*timeo_p);
+	lock_sock(sk);
+	spin_lock(lock);
+	/* sk_write_space() clears SOCK_NOSPACE */
+
+	finish_wait(sk_sleep(sk), &wait);
+}
+
+static inline void tcp_friend_send_seq(struct sock *osk,
+				       struct tcp_friend *otf,
+				       int len)
+{
+	struct tcp_sock	*otp = tcp_sk(osk);
+
+	if (!atomic_read(otf->use_seq)) {
+		otp->rcv_nxt += len;
+	} else {
+		local_bh_disable();
+
+		bh_lock_sock(osk);
+		otp->rcv_nxt += len;
+		otp->rcv_wup += len;
+		bh_unlock_sock(osk);
+
+		osk = otf->other_sk;
+		otp = tcp_sk(osk);
+		bh_lock_sock(osk);
+		otp->snd_nxt += len;
+		otp->write_seq += len;
+		otp->pushed_seq += len;
+		otp->snd_una += len;
+		otp->snd_up += len;
+		bh_unlock_sock(osk);
+
+		local_bh_enable();
+	}
+}
+
+/*
+ * tcp_friend_sendmsg() - friends interpose on tcp_sendmsg().
+ */
+int tcp_friend_sendmsg(struct kiocb *iocb, struct sock *sk,
+		       struct msghdr *msg, size_t size, long *timeo_p)
+{
+	struct tcp_friend	*tf = tcp_sk_friend(sk);
+	struct tcp_friend	*otf;
+	struct sock		*osk;
+	int			len;
+	int			chunk;
+	int			istail;
+	int			usetail;
+	int			sk_buff;
+	struct sk_buff		*skb = NULL;
+	int			sent = 0;
+	int			err = 0;
+
+	if (tf == tcp_friend_CONNECTING) {
+		err = tcp_friend_wait_connect(sk, timeo_p);
+		if (err)
+			goto ret_err;
+		tf = tcp_sk_friend(sk);
+	}
+	otf = tf->other_tf;
+	osk = tf->other_sk;
+	sk_buff = sk->sk_sndbuf + osk->sk_rcvbuf;
+
+	/* Fit at least 2 (truesize) chunks in an empty sk_buff */
+	chunk = sk_buff >> 1;
+	len = SKB_DATA_ALIGN(chunk);
+	chunk -= len - chunk;
+	chunk -= sizeof(struct skb_shared_info);
+	len = SKB_MAX_ORDER(sizeof(struct skb_shared_info), 2);
+	if (chunk > len)
+		chunk = len;
+	chunk -= sizeof(struct sk_buff);
+
+	/* For message sizes < 1/2 of a chunk use tail fill */
+	if (size < (chunk >> 1))
+		usetail = 1;
+	else
+		usetail = 0;
+
+	spin_lock(&otf->lock);
+	otf->send_pend = size;
+	while (size) {
+		if (osk->sk_shutdown & RCV_SHUTDOWN) {
+			sk->sk_err = ECONNRESET;
+			break;
+		}
+
+		if (usetail) {
+			/*
+			 * Do tail fill, if last skb has enough tailroom use
+			 * it, else set alloc len to chunk then as long as a
+			 * a recvmsg() is pending subsequent sendmsg() calls
+			 * can simply tail fill it.
+			 */
+			skb = skb_peek_tail(&osk->sk_receive_queue);
+			if (skb) {
+				if (skb_tailroom(skb) >= size) {
+					otf->send_tail = size;
+					istail = 1;
+					len = size;
+				} else {
+					skb = NULL;
+					istail = 0;
+					len = chunk;
+				}
+			} else {
+				istail = 0;
+				len = chunk;
+			}
+		} else {
+			/* Allocate at most one chunk at a time */
+			otf->send_tail = 0;
+			skb = NULL;
+			istail = 0;
+			len = min_t(int, size, chunk);
+		}
+
+		if (!skb) {
+			if (otf->mode == DATA_HIWAT) {
+				if ((sk->sk_shutdown & SEND_SHUTDOWN) ||
+				   sk->sk_err) {
+					err = -EPIPE;
+					goto out;
+				}
+				if (!(*timeo_p)) {
+					err = -EAGAIN;
+					goto out;
+				}
+
+				if (signal_pending(current))
+					goto out_sig;
+
+				tcp_friend_space_wait(sk, &otf->lock, timeo_p);
+				continue;
+			}
+			spin_unlock(&otf->lock);
+
+			skb = alloc_skb(len, sk->sk_allocation);
+			if (!skb) {
+				err = -ENOBUFS;
+				spin_lock(&otf->lock);
+				goto out;
+			}
+			skb->friend = sk;
+
+			if (usetail && len > size) {
+				/* For tail fill, alloc len > messages size */
+				len = size;
+			}
+		}
+
+		err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+
+		if (!istail)
+			spin_lock(&otf->lock);
+
+		if (err) {
+			if (istail)
+				skb_trim(skb, skb->len - len);
+			else
+				__kfree_skb(skb);
+			goto out;
+		}
+
+		if (osk->sk_shutdown & RCV_SHUTDOWN) {
+			if (!istail)
+				__kfree_skb(skb);
+			err = -EPIPE;
+			goto out;
+		}
+
+		if (!istail) {
+			int used;
+
+			if (!sk_rmem_schedule(osk, skb->truesize)) {
+				__kfree_skb(skb);
+				atomic_inc(&osk->sk_drops);
+				err = -ENOBUFS;
+				goto out;
+			}
+			skb_set_owner_r(skb, osk);
+			__skb_queue_tail(&osk->sk_receive_queue, skb);
+
+			/* Data ready if used > 75% of sk_buff */
+			used = atomic_read(&osk->sk_rmem_alloc);
+			if (used > ((sk_buff >> 1) + (sk_buff >> 2))) {
+				if (used >= sk_buff)
+					otf->mode = DATA_HIWAT;
+
+				tcp_friend_have_rspace(otf, 0);
+				if (size)
+					osk->sk_data_ready(osk, 0);
+			}
+		}
+
+		tcp_friend_send_seq(osk, otf, len);
+		sent += len;
+		size -= len;
+	}
+
+	if (skb && (msg->msg_flags & MSG_OOB)) {
+		/*
+		 * Out-of-Order-Byte message so move last byte of last skb
+		 * to TCP's urgent data. Note, in the case of SOCK_URGINLINE
+		 * our recvmsg() handles reading of, else tcp_recvmsg() will.
+		 */
+		struct tcp_sock	*otp = tcp_sk(osk);
+		u8		tmp;
+
+		otp->urg_seq = otp->rcv_nxt - 1;
+		if (skb_copy_bits(skb, skb->len - 1, &tmp, 1))
+			BUG();
+		__skb_trim(skb, skb->len - 1);
+		otp->urg_data = TCP_URG_VALID | tmp;
+
+		sk_send_sigurg(osk);
+	}
+out:
+	otf->send_pend = 0;
+	osk->sk_data_ready(osk, 0);
+	spin_unlock(&otf->lock);
+	if (sent || !err)
+		return sent;
+ret_err:
+	err = sk_stream_error(sk, msg->msg_flags, err);
+	return err;
+
+out_sig:
+	err = sock_intr_errno(*timeo_p);
+	goto out;
+}
+
+static void tcp_friend_data_wait(struct sock *sk, spinlock_t *lock,
+				 long *timeo_p)
+{
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+
+	spin_unlock(lock);
+	release_sock(sk);
+	*timeo_p = schedule_timeout(*timeo_p);
+	lock_sock(sk);
+	spin_lock(lock);
+
+	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	finish_wait(sk_sleep(sk), &wait);
+}
+
+static int tcp_friend_urg_out(struct sock *sk, struct msghdr *msg, int flags)
+{
+	struct tcp_friend	*tf = tcp_sk_friend(sk);
+	struct tcp_sock		*tp = tcp_sk(sk);
+	int			copied;
+
+	if (sock_flag(sk, SOCK_URGINLINE)) {
+		if (!(flags & MSG_TRUNC)) {
+			u8	urg_c = tp->urg_data;
+
+			spin_unlock(&tf->lock);
+			if (memcpy_toiovec(msg->msg_iov, &urg_c, 1))
+				return 0;
+			spin_lock(&tf->lock);
+		}
+		copied = 1;
+	} else
+		copied = -1;
+
+	if (!(flags & MSG_PEEK))
+		tp->urg_data = 0;
+
+	return copied;
+}
+
+/*
+ * tcp_friend_recvmsg() - friends interpose on tcp_recvmsg().
+ */
+int tcp_friend_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t size, int nonblock, int flags)
+{
+	struct tcp_friend	*tf = tcp_sk_friend(sk);
+	struct tcp_sock		*tp = tcp_sk(sk);
+	struct sock		*osk;
+	struct sk_buff		*skb;
+	int			len;
+	int			target;
+	int			urg_offset = -1;
+	int			copied = 0;
+	int			err = 0;
+	long			timeo = sock_rcvtimeo(sk, nonblock);
+	u32			*seq;
+	u32			peek_seq;
+	int			peek_copied;
+
+	if (tf == tcp_friend_CONNECTING) {
+		err = tcp_friend_wait_connect(sk, &timeo);
+		if (err)
+			return sk_stream_error(sk, msg->msg_flags, err);
+		tf = tcp_sk_friend(sk);
+	}
+	osk = tf->other_sk;
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
+
+	seq = &tp->copied_seq;
+	if (flags & MSG_PEEK) {
+		peek_seq = *seq;
+		seq = &peek_seq;
+		peek_copied = 0;
+	}
+
+	spin_lock(&tf->lock);
+	skb = skb_peek(&sk->sk_receive_queue);
+	while (size && urg_offset != 0) {
+		if (skb && !skb->friend) {
+			/* Got a FIN via the stack from the other */
+			BUG_ON(skb->len);
+			BUG_ON(!tcp_hdr(skb)->fin);
+			atomic_dec(tf->use_seq);
+			tp->copied_seq++;
+			__skb_unlink(skb, &sk->sk_receive_queue);
+			kfree_skb(skb);
+			break;
+		}
+
+		/* If urgent data calc urgent data offset */
+		if (tp->urg_data)
+			urg_offset = tp->urg_seq - *seq;
+
+		/* No skb or empty tail skb (for sender tail fill)? */
+		if (!skb || (skb_queue_is_last(&sk->sk_receive_queue, skb) &&
+		    !skb->len)) {
+			/* No sender active and have enough data? */
+			if (!tf->send_pend && copied >= target)
+				break;
+			if (sock_flag(sk, SOCK_DONE))
+				break;
+
+			err = sock_error(sk);
+			if (err || (osk->sk_shutdown & SEND_SHUTDOWN) ||
+			    (sk->sk_shutdown & RCV_SHUTDOWN))
+				break;
+
+			if (!timeo) {
+				err = -EAGAIN;
+				break;
+			}
+			tcp_friend_data_wait(sk, &tf->lock, &timeo);
+
+			if (signal_pending(current)) {
+				err = sock_intr_errno(timeo);
+				break;
+			}
+			skb = skb_peek(&sk->sk_receive_queue);
+			continue;
+		}
+
+		len = min_t(unsigned int, skb->len, size);
+
+		if (!len)
+			goto skip;
+
+		if (urg_offset == 0) {
+			/* At urgent byte, consume and optionally copyout */
+			len = tcp_friend_urg_out(sk, msg, flags);
+			if (len == 0) {
+				/* On error, returns with spin_unlock() !!! */
+				err = -EFAULT;
+				goto out;
+			}
+			if (len > 0) {
+				copied++;
+				size--;
+			}
+			(*seq)++;
+			urg_offset = -1;
+			continue;
+		} else if (urg_offset != -1 && urg_offset < len) {
+			/* Have an urgent byte in skb, copyout up-to */
+			len = urg_offset;
+		}
+
+		if (!(flags & MSG_TRUNC)) {
+			spin_unlock(&tf->lock);
+			if (memcpy_toiovec(msg->msg_iov, skb->data, len)) {
+				err = -EFAULT;
+				goto out;
+			}
+			spin_lock(&tf->lock);
+		}
+		*seq += len;
+		copied += len;
+		size -= len;
+		if (urg_offset != -1)
+			urg_offset -= len;
+
+		if (!(flags & MSG_PEEK)) {
+			skb_pull(skb, len);
+			/*
+			 * If skb is empty and, no more to recv or last send
+			 * message not tail filled or not last skb on queue
+			 * or not likely enough tail room in skb for next
+			 * send message tail fill, then unlink and free, if
+			 * more to recv get next skb (if any), and last if
+			 * queued data size <= 1/2 of sk_buff have send space.
+			 *
+			 * Else, more to copyout or leave the empty skb on
+			 * queue for the next sendmsg() to use for tail fill.
+			 */
+			if (!skb->len && (!size || !tf->send_tail ||
+			    !skb_queue_is_last(&sk->sk_receive_queue, skb) ||
+			    skb_tailroom(skb) < tf->send_tail)) {
+skip:
+				__skb_unlink(skb, &sk->sk_receive_queue);
+				__kfree_skb(skb);
+
+				if (size)
+					skb = skb_peek(&sk->sk_receive_queue);
+
+				/* Write space if used <= 25% of sk_buff */
+				if (!(osk->sk_shutdown & SEND_SHUTDOWN) &&
+				    atomic_read(&sk->sk_rmem_alloc) <=
+				    ((osk->sk_sndbuf + sk->sk_rcvbuf) >> 2)) {
+
+					if (tf->mode == DATA_HIWAT)
+						tf->mode = DATA_BYPASS;
+
+					tcp_friend_have_rspace(tf, 1);
+					osk->sk_write_space(osk);
+				}
+			}
+		} else {
+			if ((copied - peek_copied) < skb->len)
+				continue;
+			if (skb_queue_is_last(&sk->sk_receive_queue, skb))
+				break;
+			peek_copied = copied;
+			skb = skb_queue_next(&sk->sk_receive_queue, skb);
+		}
+	}
+	/*
+	 * If empty skb on tail of queue (see tail fill comment above) then
+	 * need to clean it up before returning so unlink and free it.
+	 */
+	skb = skb_peek_tail(&sk->sk_receive_queue);
+	if (skb && !skb->len) {
+		__skb_unlink(skb, &sk->sk_receive_queue);
+		__kfree_skb(skb);
+	}
+	spin_unlock(&tf->lock);
+
+out:
+	return copied ? : err;
+}
+
+static inline void tcp_friend_release(struct tcp_friend *tf)
+{
+	spin_lock(&tf->lock);
+	if (tf->ref == 1) {
+		sock_put(tf->other_sk);
+		kfree(tf);
+	} else {
+		tf->ref--;
+		spin_unlock(&tf->lock);
+	}
+}
+
+static inline struct tcp_friend *tcp_friend_hold(struct sock *sk,
+						 struct sock *osk,
+						 struct tcp_friend *otf)
+{
+	struct tcp_friend	*tf;
+	u64			was;
+
+	tf = kmalloc(sizeof(*tf), GFP_ATOMIC);
+	if (!tf)
+		return NULL;
+
+	tf->mode = DATA_BYPASS;
+	sock_hold(osk);
+	tf->other_sk = osk;
+	if (otf) {
+		otf->ref++;
+		tf->other_tf = otf;
+		tf->use_seq = &otf->using_seq;
+		tf->ref = 2;
+		otf->other_tf = tf;
+	} else {
+		tf->other_tf = NULL;
+		tf->use_seq = &tf->using_seq;
+		atomic_set(tf->use_seq, 0);
+		tf->ref = 1;
+	}
+	tf->send_tail = 0;
+	tf->send_pend = 0;
+	tf->have_rspace = 1;
+	spin_lock_init(&tf->lock);
+
+	was = atomic_long_xchg(&sk->sk_friend, (u64)tf);
+	if (was == (u64)tcp_friend_CONNECTING) {
+		/* sk_friend was CONNECTING may be in wait_connect() */
+		bh_lock_sock(sk);
+		sk->sk_state_change(sk);
+		bh_unlock_sock(sk);
+	} else if (was == (u64)tcp_friend_EARLYCLOSE) {
+		/* Close race, closed already, abort */
+		tf->ref--;
+		tcp_friend_release(tf);
+		otf->ref--;
+		tf = NULL;
+	}
+
+	return tf;
+}
+
+/*
+ * tcp_friend_connect() - called in one of two ways; 1) called from the
+ * listen()er context with a new *sk to be returned as the accept() socket
+ * and *req socket from connect(), 2) called from the connect()ing context
+ * with it's *sk socket and a NULL *req.
+ *
+ * For 1) put a friend_hold() on *sk and *req to make friends.
+ *
+ * For 2) if called before 1) attempt to set sk_friend to CONNECTING if NULL
+ * as a sendmsg()/recvmsg() barrier.
+ */
+void tcp_friend_connect(struct sock *sk, struct sock *req)
+{
+	struct tcp_friend	*tf;
+	struct tcp_friend	*otf;
+
+	if (!req) {
+		/* Case 2), atomically swap CONNECTING if NULL */
+		atomic_long_cmpxchg(&sk->sk_friend, 0,
+				    (u64)tcp_friend_CONNECTING);
+		return;
+	}
+
+	tf = tcp_friend_hold(sk, req, NULL);
+	if (!tf)
+		return;
+
+	otf = tcp_friend_hold(req, sk, tf);
+	if (!otf) {
+		sk->sk_friend = NULL;
+		req->sk_friend = NULL;
+		tcp_friend_release(tf);
+		return;
+	}
+}
+
+static void tcp_friend_use_seq(struct sock *sk, struct sock *osk)
+{
+	struct tcp_sock		*tp = tcp_sk(sk);
+	struct tcp_sock		*otp = tcp_sk(osk);
+
+	/*
+	 * Note, during data bypass mode only rcv_nxt and copied_seq
+	 * values are maintained, now sk <> osk control segments need
+	 * to flow so need to reinitialize all sk/osk values.
+	 *
+	 * Note, any recvmsg(osk) drain and sendmsg(osk) -> recvmsg(sk)
+	 * data will maintain all TCP sequence values.
+	 */
+
+	/* Our sequence values */
+	tp->rcv_wup = tp->rcv_nxt;
+
+	tp->snd_nxt = otp->rcv_nxt;
+	tp->write_seq = otp->rcv_nxt;
+	tp->pushed_seq = otp->rcv_nxt;
+	tp->snd_una = otp->rcv_nxt;
+	tp->snd_up = otp->rcv_nxt;
+
+	/* Other's sequence values */
+	otp->rcv_wup = otp->rcv_nxt;
+
+	otp->snd_nxt = tp->rcv_nxt;
+	otp->write_seq = tp->rcv_nxt;
+	otp->pushed_seq = tp->rcv_nxt;
+	otp->snd_una = tp->rcv_nxt;
+	otp->snd_up = tp->rcv_nxt;
+}
+
+
+/*
+ * On close()/shutdown() called when sk_friend == CONNECTING, need to
+ * handle possile connect()/close() race with accept(), try to atomically
+ * mark sk_friend with EARLYCLOSE, if successful return NULL as accept()
+ * never completed, else accept() completed so return tf.
+ */
+static struct tcp_friend *tcp_friend_close_connect(struct sock *sk)
+{
+	struct  tcp_friend *tf;
+	tf = (struct tcp_friend *)atomic_long_cmpxchg(&sk->sk_friend,
+		(u64)tcp_friend_CONNECTING, (u64)tcp_friend_EARLYCLOSE);
+	if (tf == tcp_friend_CONNECTING)
+		return NULL;
+
+	return tf;
+}
+
+/*
+ * tcp_friend_shutdown() - friends shim on tcp_shutdown().
+ */
+void tcp_friend_shutdown(struct sock *sk, int how)
+{
+	struct tcp_friend	*tf = tcp_sk_friend(sk);
+	struct tcp_friend	*otf;
+	struct sock		*osk;
+
+	if (tf == tcp_friend_CONNECTING) {
+		tf = tcp_friend_close_connect(sk);
+		if (!tf)
+			return;
+	}
+	otf = tf->other_tf;
+	osk = tf->other_sk;
+
+	if (how & RCV_SHUTDOWN) {
+		struct sk_buff		*skb, *tmp;
+
+		spin_lock(&tf->lock);
+		skb_queue_walk_safe(&sk->sk_receive_queue, skb, tmp) {
+			if (skb->friend) {
+				__skb_unlink(skb, &sk->sk_receive_queue);
+				__kfree_skb(skb);
+			}
+		}
+		if (tf->mode == DATA_HIWAT)
+			tf->mode = DATA_BYPASS;
+		osk->sk_write_space(osk);
+		spin_unlock(&tf->lock);
+	}
+
+	if (how & SEND_SHUTDOWN) {
+		spin_lock(&otf->lock);
+		if (otf->mode != SHUTDOWN) {
+			otf->mode = SHUTDOWN;
+			if (atomic_inc_return(tf->use_seq) == 1) {
+				/*
+				 * 1st friend to shutdown so switch to
+				 * updating full TCP sequence state.
+				 */
+				spin_lock(&tf->lock);
+				tcp_friend_use_seq(sk, osk);
+				spin_unlock(&tf->lock);
+			}
+		}
+
+		tcp_friend_have_rspace(otf, 1);
+		osk->sk_data_ready(osk, 0);
+		spin_unlock(&otf->lock);
+	}
+}
+
+/*
+ * tcp_friend_close() - friends shim on tcp_close().
+ */
+void tcp_friend_close(struct sock *sk)
+{
+	struct tcp_friend	*tf = tcp_sk_friend(sk);
+	struct tcp_friend	*otf;
+
+	if (tf == tcp_friend_CONNECTING) {
+		tf = tcp_friend_close_connect(sk);
+		if (!tf)
+			return;
+	}
+	otf = tf->other_tf;
+
+	tcp_friend_shutdown(sk, SHUTDOWN_MASK);
+
+	/* Release other's ref on us */
+	tcp_friend_release(otf);
+
+	/* Relase our ref on other */
+	tcp_friend_release(tf);
+
+	sk->sk_friend = tcp_friend_CLOSED;
+}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..7918056 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4686,7 +4686,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 restart:
 	end_of_skbs = true;
 	skb_queue_walk_from_safe(list, skb, n) {
-		if (skb == tail)
+		if (skb == tail || skb->friend)
 			break;
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
@@ -5641,6 +5641,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			}
 		}
 
+		if (skb->friend)
+			tcp_friend_connect(sk, NULL);
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5673,9 +5676,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
 		}
 
-		if (sk->sk_write_pending ||
+		if (!skb->friend && (sk->sk_write_pending ||
 		    icsk->icsk_accept_queue.rskq_defer_accept ||
-		    icsk->icsk_ack.pingpong) {
+		    icsk->icsk_ack.pingpong)) {
 			/* Save one ACK. Data will be ready after
 			 * several ticks, if write_pending is set.
 			 *
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ea10ee..f2430d8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1291,6 +1291,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
+	req->friend = skb->friend;
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 85a2fbe..5d57255 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -318,6 +318,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	int recycle_ok = 0;
 
+	if (tcp_had_friend(sk)) {
+		tcp_done(sk);
+		return;
+	}
+
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 980b98f..0e2a68e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -782,6 +782,8 @@ static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
 	return size;
 }
 
+extern int sysctl_tcp_friends;
+
 /* This routine actually transmits TCP packets queued in by
  * tcp_do_sendmsg().  This is used by both the initial
  * transmission and possible later retransmissions.
@@ -828,9 +830,14 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
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
@@ -2468,6 +2475,12 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
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
index c8683fc..44ede0a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1194,6 +1194,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 #endif
 
+	req->friend = skb->friend;
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-- 
1.7.3.1
