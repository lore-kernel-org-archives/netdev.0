From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 2/4] [RFC] Add c/r support for connected INET sockets
Date: Tue, 20 Oct 2009 14:06:41 -0700
Message-ID: <1256072803-3518-3-git-send-email-danms@us.ibm.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org, Oren Laadan <orenl@librato.com>,
	John Dykstra <jdykstra72@gmail.com>
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:60599 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbZJTVEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 17:04:35 -0400
In-Reply-To: <1256072803-3518-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic support for C/R of open INET sockets.  I think that
all the important bits of the TCP and ICSK socket structures is saved,
but I think there is still some additional IPv6 stuff that needs to be
handled.

With this patch applied, the following script can be used to demonstrate
the functionality:

  https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html

It shows that this enables migration of a sendmail process with open
connections from one machine to another without dropping.

We still need comments from the netdev people about what sort of sanity
checking we need to do on the values in the ckpt_hdr_socket_inet
structure on restart.

Note that this still doesn't address lingering sockets yet.

Changes in v2:
 - Restore saddr, rcv_saddr, daddr, sport, and dport from the sockaddr
   structure instead of saving them separately
 - Fix 'sock' naming in sock_cptrst()
 - Don't take the queue lock before skb_queue_tail() since it is
   done for us
 - Allow "listen only" restore behavior if RESTART_SOCK_LISTENONLY
   flag is specified on sys_restart()
 - Pull the implementation of the list of listening sockets back into
   this patch
 - Fix dangling printk
 - Add some comments around the parent/child restore logic

Cc: netdev@vger.kernel.org
Cc: Oren Laadan <orenl@librato.com>
Cc: John Dykstra <jdykstra72@gmail.com>
Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 checkpoint/sys.c                 |    4 +
 include/linux/checkpoint.h       |    5 +-
 include/linux/checkpoint_hdr.h   |   97 ++++++++++++++
 include/linux/checkpoint_types.h |    2 +
 net/checkpoint.c                 |   23 ++--
 net/ipv4/checkpoint.c            |  263 +++++++++++++++++++++++++++++++++++++-
 6 files changed, 379 insertions(+), 15 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..df00973 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -221,6 +221,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	kfree(ctx->pids_arr);
 
+	sock_listening_list_free(&ctx->listen_sockets);
+
 	kfree(ctx);
 }
 
@@ -249,6 +251,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	spin_lock_init(&ctx->lock);
 #endif
 
+	INIT_LIST_HEAD(&ctx->listen_sockets);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1da0b04..73d1677 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -19,6 +19,7 @@
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
 #define RESTART_GHOST		0x4
+#define RESTART_SOCK_LISTENONLY 0x8
 
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
@@ -48,7 +49,8 @@
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
-	 RESTART_GHOST)
+	 RESTART_GHOST | \
+	 RESTART_SOCK_LISTENONLY)
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -102,6 +104,7 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct sockaddr *rem, unsigned *rem_len);
 void sock_restore_header_info(struct sk_buff *skb,
 			      struct ckpt_hdr_socket_buffer *h);
+void sock_listening_list_free(struct list_head *head);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3e6cab1..0c10657 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -20,6 +20,7 @@
 #include <linux/socket.h>
 #include <linux/un.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #else
 #include <sys/socket.h>
 #include <sys/un.h>
@@ -569,6 +570,102 @@ struct ckpt_hdr_socket_unix {
 
 struct ckpt_hdr_socket_inet {
 	struct ckpt_hdr h;
+	__u32 daddr;
+	__u32 rcv_saddr;
+	__u32 saddr;
+	__u16 dport;
+	__u16 num;
+	__u16 sport;
+	__s16 uc_ttl;
+	__u16 cmsg_flags;
+
+	struct {
+		__u64 timeout;
+		__u32 ato;
+		__u32 lrcvtime;
+		__u16 last_seg_size;
+		__u16 rcv_mss;
+		__u8 pending;
+		__u8 quick;
+		__u8 pingpong;
+		__u8 blocked;
+	} icsk_ack __attribute__ ((aligned(8)));
+
+	/* FIXME: Skipped opt, tos, multicast, cork settings */
+
+	struct {
+		__u64 last_synq_overflow;
+
+		__u32 rcv_nxt;
+		__u32 copied_seq;
+		__u32 rcv_wup;
+		__u32 snd_nxt;
+		__u32 snd_una;
+		__u32 snd_sml;
+		__u32 rcv_tstamp;
+		__u32 lsndtime;
+
+		__u32 snd_wl1;
+		__u32 snd_wnd;
+		__u32 max_window;
+		__u32 mss_cache;
+		__u32 window_clamp;
+		__u32 rcv_ssthresh;
+		__u32 frto_highmark;
+
+		__u32 srtt;
+		__u32 mdev;
+		__u32 mdev_max;
+		__u32 rttvar;
+		__u32 rtt_seq;
+
+		__u32 packets_out;
+		__u32 retrans_out;
+
+		__u32 snd_up;
+		__u32 rcv_wnd;
+		__u32 write_seq;
+		__u32 pushed_seq;
+		__u32 lost_out;
+		__u32 sacked_out;
+		__u32 fackets_out;
+		__u32 tso_deferred;
+		__u32 bytes_acked;
+
+		__s32 lost_cnt_hint;
+		__u32 retransmit_high;
+
+		__u32 lost_retrans_low;
+
+		__u32 prior_ssthresh;
+		__u32 high_seq;
+
+		__u32 retrans_stamp;
+		__u32 undo_marker;
+		__s32 undo_retrans;
+		__u32 total_retrans;
+
+		__u32 urg_seq;
+		__u32 keepalive_time;
+		__u32 keepalive_intvl;
+
+		__u16 urg_data;
+		__u16 advmss;
+		__u8 frto_counter;
+		__u8 nonagle;
+
+		__u8 ecn_flags;
+		__u8 reordering;
+
+		__u8 keepalive_probes;
+	} tcp __attribute__ ((aligned(8)));
+
+	struct {
+		struct in6_addr saddr;
+		struct in6_addr rcv_saddr;
+		struct in6_addr daddr;
+	} inet6 __attribute__ ((aligned(8)));
+
 	__u32 laddr_len;
 	__u32 raddr_len;
 	struct sockaddr_in laddr;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index fa57cdc..91c141b 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -65,6 +65,8 @@ struct ckpt_ctx {
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
 
+	struct list_head listen_sockets;/* listening parent sockets */
+
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
 	int nr_tasks;                   /* size of tasks array */
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 5ed2724..3e7574d 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -122,6 +122,7 @@ void sock_restore_header_info(struct sk_buff *skb,
 
 static int __sock_write_buffers(struct ckpt_ctx *ctx,
 				struct sk_buff_head *queue,
+				uint16_t family,
 				int dst_objref)
 {
 	struct sk_buff *skb;
@@ -130,11 +131,7 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 		struct ckpt_hdr_socket_buffer *h;
 		int ret = 0;
 
-		/* FIXME: This could be a false positive for non-unix
-		 *        buffers, so add a type check here in the
-		 *        future
-		 */
-		if (UNIXCB(skb).fp) {
+		if ((family == AF_UNIX) && UNIXCB(skb).fp) {
 			ckpt_write_err(ctx, "TE", "af_unix: pass fd", -EBUSY);
 			return -EBUSY;
 		}
@@ -174,6 +171,7 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 
 static int sock_write_buffers(struct ckpt_ctx *ctx,
 			      struct sk_buff_head *queue,
+			      uint16_t family,
 			      int dst_objref)
 {
 	struct ckpt_hdr_socket_queue *h;
@@ -193,7 +191,7 @@ static int sock_write_buffers(struct ckpt_ctx *ctx,
 	h->skb_count = ret;
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (!ret)
-		ret = __sock_write_buffers(ctx, &tmpq, dst_objref);
+		ret = __sock_write_buffers(ctx, &tmpq, family, dst_objref);
 
  out:
 	ckpt_hdr_put(ctx, h);
@@ -215,12 +213,14 @@ int sock_deferred_write_buffers(void *data)
 		return dst_objref;
 	}
 
-	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue, dst_objref);
+	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue,
+				 dq->sk->sk_family, dst_objref);
 	ckpt_debug("write recv buffers: %i\n", ret);
 	if (ret < 0)
 		return ret;
 
-	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue, dst_objref);
+	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue,
+				 dq->sk->sk_family, dst_objref);
 	ckpt_debug("write send buffers: %i\n", ret);
 
 	return ret;
@@ -745,10 +745,9 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 		goto err;
 
 	if ((h->sock_common.family == AF_INET) &&
-	    (h->sock.state != TCP_LISTEN)) {
-		/* Temporary hack to enable restore of TCP_LISTEN sockets
-		 * while forcing anything else to a closed state
-		 */
+	    (h->sock.state != TCP_LISTEN) &&
+	    (ctx->uflags & RESTART_SOCK_LISTENONLY)) {
+		ckpt_debug("Forcing open socket closed\n");
 		sock->sk->sk_state = TCP_CLOSE;
 		sock->state = SS_UNCONNECTED;
 	}
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index 9cbbf5e..5913652 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -17,6 +17,7 @@
 #include <linux/deferqueue.h>
 #include <net/tcp_states.h>
 #include <net/tcp.h>
+#include <net/ipv6.h>
 
 struct dq_sock {
 	struct ckpt_ctx *ctx;
@@ -28,6 +29,233 @@ struct dq_buffers {
 	struct sock *sk;
 };
 
+struct listen_item {
+	struct sock *sk;
+	struct list_head list;
+};
+
+void sock_listening_list_free(struct list_head *head)
+{
+	struct listen_item *item, *tmp;
+
+	list_for_each_entry_safe(item, tmp, head, list) {
+		list_del(&item->list);
+		kfree(item);
+	}
+}
+
+static int sock_listening_list_add(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct listen_item *item;
+
+	item = kmalloc(sizeof(*item), GFP_KERNEL);
+	if (!item)
+		return -ENOMEM;
+
+	item->sk = sk;
+	list_add(&item->list, &ctx->listen_sockets);
+
+	return 0;
+}
+
+static struct sock *sock_get_parent(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct listen_item *item;
+
+	list_for_each_entry(item, &ctx->listen_sockets, list) {
+		if (inet_sk(sk)->sport == inet_sk(item->sk)->sport)
+			return item->sk;
+	}
+
+	return NULL;
+}
+
+static int sock_hash_parent(void *data)
+{
+	struct dq_sock *dq = (struct dq_sock *)data;
+	struct sock *parent;
+
+	ckpt_debug("INET post-restart hash\n");
+
+	dq->sk->sk_prot->hash(dq->sk);
+
+	/* If there is a listening socket with the same source port,
+	 * then become a child of that socket [we are the result of an
+	 * accept()].  Otherwise hash ourselves directly in [we are
+	 * the result of a connect()]
+	 */
+
+	parent = sock_get_parent(dq->ctx, dq->sk);
+	if (parent) {
+		inet_sk(dq->sk)->num = ntohs(inet_sk(dq->sk)->sport);
+		local_bh_disable();
+		__inet_inherit_port(parent, dq->sk);
+		local_bh_enable();
+	} else {
+		inet_sk(dq->sk)->num = 0;
+		inet_hash_connect(&tcp_death_row, dq->sk);
+		inet_sk(dq->sk)->num = ntohs(inet_sk(dq->sk)->sport);
+	}
+
+	return 0;
+}
+
+static int sock_defer_hash(struct ckpt_ctx *ctx, struct sock *sock)
+{
+	struct dq_sock dq;
+
+	dq.sk = sock;
+	dq.ctx = ctx;
+
+	return deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+			      sock_hash_parent, NULL);
+}
+
+static int sock_inet_tcp_cptrst(struct ckpt_ctx *ctx,
+				struct tcp_sock *sk,
+				struct ckpt_hdr_socket_inet *hh,
+				int op)
+{
+	CKPT_COPY(op, hh->tcp.rcv_nxt, sk->rcv_nxt);
+	CKPT_COPY(op, hh->tcp.copied_seq, sk->copied_seq);
+	CKPT_COPY(op, hh->tcp.rcv_wup, sk->rcv_wup);
+	CKPT_COPY(op, hh->tcp.snd_nxt, sk->snd_nxt);
+	CKPT_COPY(op, hh->tcp.snd_una, sk->snd_una);
+	CKPT_COPY(op, hh->tcp.snd_sml, sk->snd_sml);
+	CKPT_COPY(op, hh->tcp.rcv_tstamp, sk->rcv_tstamp);
+	CKPT_COPY(op, hh->tcp.lsndtime, sk->lsndtime);
+
+	CKPT_COPY(op, hh->tcp.snd_wl1, sk->snd_wl1);
+	CKPT_COPY(op, hh->tcp.snd_wnd, sk->snd_wnd);
+	CKPT_COPY(op, hh->tcp.max_window, sk->max_window);
+	CKPT_COPY(op, hh->tcp.mss_cache, sk->mss_cache);
+	CKPT_COPY(op, hh->tcp.window_clamp, sk->window_clamp);
+	CKPT_COPY(op, hh->tcp.rcv_ssthresh, sk->rcv_ssthresh);
+	CKPT_COPY(op, hh->tcp.frto_highmark, sk->frto_highmark);
+	CKPT_COPY(op, hh->tcp.advmss, sk->advmss);
+	CKPT_COPY(op, hh->tcp.frto_counter, sk->frto_counter);
+	CKPT_COPY(op, hh->tcp.nonagle, sk->nonagle);
+
+	CKPT_COPY(op, hh->tcp.srtt, sk->srtt);
+	CKPT_COPY(op, hh->tcp.mdev, sk->mdev);
+	CKPT_COPY(op, hh->tcp.mdev_max, sk->mdev_max);
+	CKPT_COPY(op, hh->tcp.rttvar, sk->rttvar);
+	CKPT_COPY(op, hh->tcp.rtt_seq, sk->rtt_seq);
+
+	CKPT_COPY(op, hh->tcp.packets_out, sk->packets_out);
+	CKPT_COPY(op, hh->tcp.retrans_out, sk->retrans_out);
+
+	CKPT_COPY(op, hh->tcp.urg_data, sk->urg_data);
+	CKPT_COPY(op, hh->tcp.ecn_flags, sk->ecn_flags);
+	CKPT_COPY(op, hh->tcp.reordering, sk->reordering);
+	CKPT_COPY(op, hh->tcp.snd_up, sk->snd_up);
+
+	CKPT_COPY(op, hh->tcp.keepalive_probes, sk->keepalive_probes);
+
+	CKPT_COPY(op, hh->tcp.rcv_wnd, sk->rcv_wnd);
+	CKPT_COPY(op, hh->tcp.write_seq, sk->write_seq);
+	CKPT_COPY(op, hh->tcp.pushed_seq, sk->pushed_seq);
+	CKPT_COPY(op, hh->tcp.lost_out, sk->lost_out);
+	CKPT_COPY(op, hh->tcp.sacked_out, sk->sacked_out);
+	CKPT_COPY(op, hh->tcp.fackets_out, sk->fackets_out);
+	CKPT_COPY(op, hh->tcp.tso_deferred, sk->tso_deferred);
+	CKPT_COPY(op, hh->tcp.bytes_acked, sk->bytes_acked);
+
+	CKPT_COPY(op, hh->tcp.lost_cnt_hint, sk->lost_cnt_hint);
+	CKPT_COPY(op, hh->tcp.retransmit_high, sk->retransmit_high);
+
+	CKPT_COPY(op, hh->tcp.lost_retrans_low, sk->lost_retrans_low);
+
+	CKPT_COPY(op, hh->tcp.prior_ssthresh, sk->prior_ssthresh);
+	CKPT_COPY(op, hh->tcp.high_seq, sk->high_seq);
+
+	CKPT_COPY(op, hh->tcp.retrans_stamp, sk->retrans_stamp);
+	CKPT_COPY(op, hh->tcp.undo_marker, sk->undo_marker);
+	CKPT_COPY(op, hh->tcp.undo_retrans, sk->undo_retrans);
+	CKPT_COPY(op, hh->tcp.total_retrans, sk->total_retrans);
+
+	CKPT_COPY(op, hh->tcp.urg_seq, sk->urg_seq);
+	CKPT_COPY(op, hh->tcp.keepalive_time, sk->keepalive_time);
+	CKPT_COPY(op, hh->tcp.keepalive_intvl, sk->keepalive_intvl);
+
+	return 0;
+}
+
+static int sock_inet_restore_addrs(struct inet_sock *inet,
+				   struct ckpt_hdr_socket_inet *hh)
+{
+	inet->daddr = hh->raddr.sin_addr.s_addr;
+	inet->saddr = hh->laddr.sin_addr.s_addr;
+	inet->rcv_saddr = inet->saddr;
+
+	inet->dport = hh->raddr.sin_port;
+	inet->sport = hh->laddr.sin_port;
+
+	return 0;
+}
+
+static int sock_inet_cptrst(struct ckpt_ctx *ctx,
+			    struct sock *sk,
+			    struct ckpt_hdr_socket_inet *hh,
+			    int op)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	int ret;
+
+	if (op == CKPT_CPT) {
+		CKPT_COPY(op, hh->daddr, inet->daddr);
+		CKPT_COPY(op, hh->rcv_saddr, inet->rcv_saddr);
+		CKPT_COPY(op, hh->dport, inet->dport);
+		CKPT_COPY(op, hh->saddr, inet->saddr);
+		CKPT_COPY(op, hh->sport, inet->sport);
+	} else {
+		ret = sock_inet_restore_addrs(inet, hh);
+		if (ret)
+			return ret;
+	}
+
+	CKPT_COPY(op, hh->num, inet->num);
+	CKPT_COPY(op, hh->uc_ttl, inet->uc_ttl);
+	CKPT_COPY(op, hh->cmsg_flags, inet->cmsg_flags);
+
+	CKPT_COPY(op, hh->icsk_ack.pending, icsk->icsk_ack.pending);
+	CKPT_COPY(op, hh->icsk_ack.quick, icsk->icsk_ack.quick);
+	CKPT_COPY(op, hh->icsk_ack.pingpong, icsk->icsk_ack.pingpong);
+	CKPT_COPY(op, hh->icsk_ack.blocked, icsk->icsk_ack.blocked);
+	CKPT_COPY(op, hh->icsk_ack.ato, icsk->icsk_ack.ato);
+	CKPT_COPY(op, hh->icsk_ack.timeout, icsk->icsk_ack.timeout);
+	CKPT_COPY(op, hh->icsk_ack.lrcvtime, icsk->icsk_ack.lrcvtime);
+	CKPT_COPY(op,
+		  hh->icsk_ack.last_seg_size, icsk->icsk_ack.last_seg_size);
+	CKPT_COPY(op, hh->icsk_ack.rcv_mss, icsk->icsk_ack.rcv_mss);
+
+	if (sk->sk_protocol == IPPROTO_TCP)
+		ret = sock_inet_tcp_cptrst(ctx, tcp_sk(sk), hh, op);
+	else if (sk->sk_protocol == IPPROTO_UDP)
+		ret = 0;
+	else {
+		ckpt_write_err(ctx, "T", "unknown socket protocol %d",
+			       sk->sk_protocol);
+		ret = -EINVAL;
+	}
+
+	if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *inet6 = inet6_sk(sk);
+		if (op == CKPT_CPT) {
+			ipv6_addr_copy(&hh->inet6.saddr, &inet6->saddr);
+			ipv6_addr_copy(&hh->inet6.rcv_saddr, &inet6->rcv_saddr);
+			ipv6_addr_copy(&hh->inet6.daddr, &inet6->daddr);
+		} else {
+			ipv6_addr_copy(&inet6->saddr, &hh->inet6.saddr);
+			ipv6_addr_copy(&inet6->rcv_saddr, &hh->inet6.rcv_saddr);
+			ipv6_addr_copy(&inet6->daddr, &hh->inet6.daddr);
+		}
+	}
+
+	return ret;
+}
+
 int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 {
 	struct ckpt_hdr_socket_inet *in;
@@ -43,6 +271,10 @@ int inet_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 	if (ret)
 		goto out;
 
+	ret = sock_inet_cptrst(ctx, sock->sk, in, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
  out:
 	ckpt_hdr_put(ctx, in);
@@ -87,9 +319,9 @@ static int inet_read_buffer(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
 	if (ret < 0)
 		goto out;
 
-	spin_lock(&queue->lock);
+	sock_restore_header_info(skb, h);
+
 	skb_queue_tail(queue, skb);
-	spin_unlock(&queue->lock);
  out:
 	ckpt_hdr_put(ctx, h);
 
@@ -209,8 +441,35 @@ int inet_restore(struct ckpt_ctx *ctx,
 			ckpt_debug("inet listen: %i\n", ret);
 			if (ret < 0)
 				goto out;
+
+			/* We are a listening socket, so add ourselves
+			 * to the list of parent sockets.  This will
+			 * allow our children to find us later and
+			 * link up
+			 */
+
+			ret = sock_listening_list_add(ctx, sock->sk);
+			if (ret < 0)
+				goto out;
 		}
 	} else {
+		ret = sock_inet_cptrst(ctx, sock->sk, in, CKPT_RST);
+		if (ret)
+			goto out;
+
+		if ((h->sock.state == TCP_ESTABLISHED) &&
+		    (h->sock.protocol == IPPROTO_TCP)) {
+			/* A connected socket that was spawned from an
+			 * accept() needs to be hashed with its parent
+			 * listening socket in order to receive
+			 * traffic on the original port.  Since we may
+			 * not have restarted the parent yet, we defer
+			 * this until later when we know we have all
+			 * the listening sockets accounted for.
+			 */
+			ret = sock_defer_hash(ctx, sock->sk);
+		}
+
 		if (!sock_flag(sock->sk, SOCK_DEAD))
 			ret = inet_defer_restore_buffers(ctx, sock->sk);
 	}
-- 
1.6.2.5

