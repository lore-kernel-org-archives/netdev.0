From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Thu, 17 Mar 2011 01:06:29 -0700
Message-ID: <1300349189-2731-1-git-send-email-hkchu@google.com>
Cc: Jerry Chu <hkchu@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:19694 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab1CQIGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:06:44 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p2H86gN6015885
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 01:06:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch add a number of very useful counters/stats (defined in
tcp_stats.h) to help diagnosing TCP related problems.

create_time     - when the connection was created (in jiffies)
total_inbytes   - total inbytes as consumed by the receiving apps.
total_outbytes  - total outbytes sent down from the transmitting apps.

total_outdatasegs - total data carrying segments sent so far, including
		retransmitted ones.

total_xmit      - total accumulated time (usecs) when the connection
		has something to send.

total_retrans_time - total time (usecs, accumulated) the connection
		spends trying to recover lost packets. For each
		loss event the time is measured from the lost packet
		was first sent till the retransmitted packet was
		eventually ack'ed.

total_cwnd_limit - total time (usecs, excluding time spent on loss
    		recovery) the xmit is stopped due to cwnd limited

total_swnd_limit - total time (usecs) theconnection is swnd limited

The following two counters are for listeners only:

accepted_reqs   - total # of accepted connection requests.
listen_drops    - total # of dropped SYN reqs (SYN cookies excluded) due
    		to listener's queue overflow.

total_retrans_time/total_retrans ratio gives a rough picture of how
quickly in average the connection can recover from a pkt loss. E.g.,
when the network is more congested, or the traffic contains mainly
smaller RPC where tail drop often requires RTO to recover,
the total_retrans_time/total_retrans ratio tends to be higher.

Currently the new counters/stats are exported through /proc/net/tcp.
Some simple, abbreviated field names have been added to the output of
/proc/net/tcp in order to allow backward/forward compatibility in the
future. Obviously the new counters/stats can also be easily exported
through other APIs.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 include/linux/ktime.h    |    3 ++
 include/linux/tcp.h      |    1 +
 include/net/tcp_stats.h  |   65 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c           |   30 ++++++++++++++++++---
 net/ipv4/tcp_input.c     |   13 +++++++++
 net/ipv4/tcp_ipv4.c      |   41 ++++++++++++++++++++++++++---
 net/ipv4/tcp_minisocks.c |    9 ++++++
 net/ipv4/tcp_output.c    |   47 +++++++++++++++++++++++++++++++--
 net/ipv6/tcp_ipv6.c      |    8 +++++
 9 files changed, 206 insertions(+), 11 deletions(-)
 create mode 100644 include/net/tcp_stats.h

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index e1ceaa9..e60e758 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -333,6 +333,9 @@ extern void ktime_get_ts(struct timespec *ts);
 /* Get the real (wall-) time in timespec format: */
 #define ktime_get_real_ts(ts)	getnstimeofday(ts)
 
+#define ktime_since(a)		ktime_to_us(ktime_sub(ktime_get(), (a)))
+#define ktime_zero(a)		ktime_equal((a), ktime_set(0, 0))
+
 static inline ktime_t ns_to_ktime(u64 ns)
 {
 	static const ktime_t ktime_zero = { .tv64 = 0 };
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..ea5cb5d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -460,6 +460,7 @@ struct tcp_sock {
 	 * contains related tcp_cookie_transactions fields.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+	struct tcp_stats	*conn_stats;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/tcp_stats.h b/include/net/tcp_stats.h
new file mode 100644
index 0000000..f17cdac
--- /dev/null
+++ b/include/net/tcp_stats.h
@@ -0,0 +1,65 @@
+#ifndef	_TCP_STATS_H_
+#define	_TCP_STATS_H_
+
+#include <linux/types.h>
+#include <linux/ktime.h>
+
+/*
+ * The following is a list of per connection counters/stats:
+ *
+ * create_time - when the connection was created (in jiffies)
+ * total_inbytes - total inbytes as consumed by the receiving apps.
+ * total_outbytes - total outbytes sent down from the transmitting apps.
+ * total_outdatasegs - total data carrying segments sent so far,
+ *		including retransmitted ones.
+ * total_xmit - total accumulated time (usecs) when the connection has
+		something to send.
+ * total_retrans_time - total time (usecs, accumulated) the connection
+ *		spends trying to recover lost packets. For each	loss
+ *		event the time is measured from the lost packet was
+ *		first sent till the retransmitted packet was eventually
+ *		ack'ed.
+ * total_cwnd_limit - total time (usecs, excluding time spent on loss
+ *		recovery) the xmit is stopped due to cwnd limited
+ * total_swnd_limit - total time (usecs) theconnection is swnd limited
+ *
+ * The following two counters are for listeners only:
+ * accepted_reqs - total # of accepted connection requests.
+ * listen_drops - total # of dropped SYN reqs (SYN cookies excluded) due
+ *		to listener's queue overflow.
+ */
+
+#define	create_time		conn_stats->ts_create_time
+#define	total_inbytes		conn_stats->ts_total_inbytes
+#define	total_outbytes		conn_stats->ts_total_outbytes
+#define	total_outdatasegs	conn_stats->ts_total_outdatasegs
+#define	start_xmit		conn_stats->ts_start_xmit
+#define	total_xmit		conn_stats->ts_total_xmit
+#define	start_cwnd_limit	conn_stats->ts_start_cwnd_limit
+#define	total_cwnd_limit	conn_stats->ts_total_cwnd_limit
+#define	start_swnd_limit	conn_stats->ts_start_swnd_limit
+#define	total_swnd_limit	conn_stats->ts_total_swnd_limit
+#define	start_retrans		conn_stats->ts_start_retrans
+#define	total_retrans_time	conn_stats->ts_total_retrans_time
+#define	accepted_reqs		conn_stats->ts_total_inbytes
+#define	listen_drops		conn_stats->ts_total_outbytes
+/* # of dropped SYN reqs (SYN cookies excluded) due to q/q0 overflow */
+
+struct tcp_stats {
+	u64	ts_create_time;		/* in jiffies */
+	u64	ts_total_inbytes;
+	u64	ts_total_outbytes;
+	u64	ts_total_outdatasegs;
+	ktime_t	ts_start_xmit;
+	u64	ts_total_xmit;		/* in usecs */
+	ktime_t	ts_start_swnd_limit;
+	u64	ts_total_swnd_limit;	/* in usecs */
+	ktime_t	ts_start_cwnd_limit;
+	u64	ts_total_cwnd_limit;	/* in usecs */
+	ktime_t	ts_start_retrans;
+	u64	ts_total_retrans_time;	/* in usecs */
+};
+
+extern struct kmem_cache *tcp_statsp;
+
+#endif /* _TCP_STATS_H_ */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b22d450..9d0d582 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -273,6 +273,7 @@
 #include <net/ip.h>
 #include <net/netdma.h>
 #include <net/sock.h>
+#include <net/tcp_stats.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -317,6 +318,10 @@ struct tcp_splice_state {
 int tcp_memory_pressure __read_mostly;
 EXPORT_SYMBOL(tcp_memory_pressure);
 
+/* Memory cache for TCP stats structure */
+struct kmem_cache *tcp_statsp __read_mostly;
+EXPORT_SYMBOL(tcp_statsp);
+
 void tcp_enter_memory_pressure(struct sock *sk)
 {
 	if (!tcp_memory_pressure) {
@@ -543,6 +548,12 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	tcb->flags   = TCPHDR_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
+
+	if (sk->sk_write_queue.qlen == 0) {
+		WARN_ON(!ktime_zero(tp->start_xmit));
+		tp->start_xmit = ktime_get();
+	}
+
 	tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
@@ -860,8 +871,10 @@ wait_for_memory:
 	}
 
 out:
-	if (copied)
+	if (copied) {
 		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tp->total_outbytes += copied;
+	}
 	return copied;
 
 do_error:
@@ -1108,8 +1121,10 @@ wait_for_memory:
 	}
 
 out:
-	if (copied)
+	if (copied) {
 		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tp->total_outbytes += copied;
+	}
 	release_sock(sk);
 	return copied;
 
@@ -1387,8 +1402,10 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	tcp_rcv_space_adjust(sk);
 
 	/* Clean up data we have read: This will do ACK frames. */
-	if (copied > 0)
+	if (copied > 0) {
+		tp->total_inbytes += copied;
 		tcp_cleanup_rbuf(sk, copied);
+	}
 	return copied;
 }
 EXPORT_SYMBOL(tcp_read_sock);
@@ -1768,7 +1785,8 @@ skip_copy:
 
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
-
+	if (copied > 0)
+		tp->total_inbytes += copied;
 	release_sock(sk);
 	return copied;
 
@@ -2101,6 +2119,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	inet_csk_delack_init(sk);
 	tcp_init_send_head(sk);
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
+	memset(tp->conn_stats, 0, sizeof(struct tcp_stats));
+	tp->create_time = get_jiffies_64();
 	__sk_dst_reset(sk);
 
 	WARN_ON(inet->inet_num && !icsk->icsk_bind_hash);
@@ -3314,4 +3334,6 @@ void __init tcp_init(void)
 	tcp_secret_primary = &tcp_secret_one;
 	tcp_secret_retiring = &tcp_secret_two;
 	tcp_secret_secondary = &tcp_secret_two;
+	tcp_statsp = kmem_cache_create("tcp_stats_cache",
+		sizeof(struct tcp_stats), 0,  SLAB_HWCACHE_ALIGN, NULL);
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index da782e7..fa3d8e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,6 +72,7 @@
 #include <linux/ipsec.h>
 #include <asm/unaligned.h>
 #include <net/netdma.h>
+#include <net/tcp_stats.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
@@ -3688,9 +3689,21 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	if (!prior_packets)
 		goto no_queue;
 
+	if (!ktime_zero(tp->start_retrans) &&
+	    !before(tp->snd_una, tp->high_seq)) {
+		tp->total_retrans_time += ktime_since(tp->start_retrans);
+		tp->start_retrans = net_invalid_timestamp();
+	}
+
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
 
+	if (sk->sk_write_queue.qlen == 0 &&
+	    !ktime_zero(tp->start_xmit)) {
+		tp->total_xmit += ktime_since(tp->start_xmit);
+		tp->start_xmit = net_invalid_timestamp();
+	}
+
 	if (tp->frto_counter)
 		frto_cwnd = tcp_process_frto(sk, flag);
 	/* Guarantee sacktag reordering detection against wrap-arounds */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f7e6c2c..bb14df2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -72,6 +72,7 @@
 #include <net/timewait_sock.h>
 #include <net/xfrm.h>
 #include <net/netdma.h>
+#include <net/tcp_stats.h>
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
@@ -1391,6 +1392,8 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	if (!want_cookie)
+		tp->listen_drops++;
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
@@ -1582,6 +1585,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 				rsk = nsk;
 				goto reset;
 			}
+			tcp_sk(sk)->accepted_reqs++;
 			return 0;
 		}
 	} else
@@ -1830,6 +1834,13 @@ static int tcp_v4_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->conn_stats = kmem_cache_alloc(tcp_statsp, GFP_KERNEL);
+	if (tp->conn_stats == NULL)
+		return -1;
+
+	memset(tp->conn_stats, 0, sizeof(struct tcp_stats));
+	tp->create_time = get_jiffies_64();
+
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
@@ -1937,7 +1948,10 @@ void tcp_v4_destroy_sock(struct sock *sk)
 			 tcp_cookie_values_release);
 		tp->cookie_values = NULL;
 	}
-
+	if (tp->conn_stats) {
+		kmem_cache_free(tcp_statsp, tp->conn_stats);
+		tp->conn_stats = NULL;
+	}
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
@@ -2390,6 +2404,8 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 	__u16 destp = ntohs(inet->inet_dport);
 	__u16 srcp = ntohs(inet->inet_sport);
 	int rx_queue;
+	int len1;
+	unsigned long elapsed;
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
 		timer_active	= 1;
@@ -2413,8 +2429,10 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		 */
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
+	elapsed = (unsigned long)(get_jiffies_64() - tp->create_time);
+
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d %u %n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2430,7 +2448,20 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
 		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+		jiffies_to_msecs(elapsed)/1000,
 		len);
+
+	if (sk->sk_state == TCP_LISTEN)
+		seq_printf(f, "%llu %llu%n", tp->accepted_reqs,
+			tp->listen_drops, &len1);
+	else
+		seq_printf(f, "%llu %llu %llu %llu %llu/%u %llu %llu%n",
+			tp->total_inbytes, tp->total_outbytes,
+			tp->total_outdatasegs, tp->total_xmit/1000,
+			tp->total_retrans_time/1000, tp->total_retrans,
+			tp->total_swnd_limit/1000, tp->total_cwnd_limit/1000,
+			&len1);
+	*len += len1;
 }
 
 static void get_timewait4_sock(struct inet_timewait_sock *tw,
@@ -2455,7 +2486,7 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 		atomic_read(&tw->tw_refcnt), tw, len);
 }
 
-#define TMPSZ 150
+#define TMPSZ 160
 
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
@@ -2466,7 +2497,9 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "%-*s\n", TMPSZ - 1,
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+			   "inode - "
+			   "elps ib ob odsg xmt_bz rtrns_tm/rtrns "
+			   "swn_lmt cwn_lmt");
 		goto out;
 	}
 	st = seq->private;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 80b1f80..abc6e23 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -26,6 +26,7 @@
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
+#include <net/tcp_stats.h>
 
 int sysctl_tcp_syncookies __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_syncookies);
@@ -433,6 +434,14 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
+		newtp->conn_stats = kmem_cache_alloc(tcp_statsp, GFP_ATOMIC);
+		if (newtp->conn_stats == NULL) {
+			sock_put(newsk);
+			return NULL;
+		}
+		memset(newtp->conn_stats, 0, sizeof(struct tcp_stats));
+		newtp->create_time = get_jiffies_64();
+
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
 		 * copy any s_data_payload stored at the original socket.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dfa5beb..ec846d3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -35,6 +35,7 @@
  */
 
 #include <net/tcp.h>
+#include <net/tcp_stats.h>
 
 #include <linux/compiler.h>
 #include <linux/gfp.h>
@@ -826,6 +827,21 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
+	if (!ktime_zero(tp->start_cwnd_limit) ||
+	    !ktime_zero(tp->start_swnd_limit)) {
+		/* update total_xmit periodically */
+		WARN_ON(ktime_zero(tp->start_xmit));
+		tp->total_xmit += ktime_since(tp->start_xmit);
+		tp->start_xmit = ktime_get();
+	}
+	if (!ktime_zero(tp->start_cwnd_limit)) {
+		tp->total_cwnd_limit += ktime_since(tp->start_cwnd_limit);
+		tp->start_cwnd_limit = net_invalid_timestamp();
+	} else if (!ktime_zero(tp->start_swnd_limit)) {
+		tp->total_swnd_limit += ktime_since(tp->start_swnd_limit);
+		tp->start_swnd_limit = net_invalid_timestamp();
+	}
+
 	if (unlikely(tcb->flags & TCPHDR_SYN))
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
 	else
@@ -892,8 +908,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (likely(tcb->flags & TCPHDR_ACK))
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
 
-	if (skb->len != tcp_header_size)
+	if (skb->len != tcp_header_size) {
 		tcp_event_data_sent(tp, skb, sk);
+		tp->total_outdatasegs += tcp_skb_pcount(skb);
+	}
 
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
@@ -903,6 +921,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (likely(err <= 0))
 		return err;
 
+	if (ktime_zero(tp->start_retrans))
+		tp->start_retrans = ktime_get();
+
 	tcp_enter_cwr(sk, 1);
 
 	return net_xmit_eval(err);
@@ -1759,11 +1780,19 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		BUG_ON(!tso_segs);
 
 		cwnd_quota = tcp_cwnd_test(tp, skb);
-		if (!cwnd_quota)
+		if (!cwnd_quota) {
+			if (ktime_zero(tp->start_cwnd_limit) &&
+			    inet_csk(sk)->icsk_ca_state == TCP_CA_Open)
+				tp->start_cwnd_limit = ktime_get();
 			break;
+		}
 
-		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
+		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now))) {
+			if (ktime_zero(tp->start_swnd_limit) &&
+			    inet_csk(sk)->icsk_ca_state == TCP_CA_Open)
+				tp->start_swnd_limit = ktime_get();
 			break;
+		}
 
 		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
@@ -2134,6 +2163,18 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
+	if (ktime_zero(tp->start_retrans)) {
+		unsigned int since_last = jiffies_to_usecs(tcp_time_stamp
+		    - TCP_SKB_CB(skb)->when);
+
+		tp->start_cwnd_limit = net_invalid_timestamp();
+		tp->start_swnd_limit = net_invalid_timestamp();
+		/* Stop counting cwnd/swnd_limit when we get into retrans */
+		tp->start_retrans = ktime_get();
+		tp->start_retrans = ktime_sub_us(tp->start_retrans,
+		    since_last);
+	}
+
 	/* Make a copy, if the first transmission SKB clone we made
 	 * is still in somebody's hands, else make a clone.
 	 */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b0c186..30db33a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -61,6 +61,7 @@
 #include <net/timewait_sock.h>
 #include <net/netdma.h>
 #include <net/inet_common.h>
+#include <net/tcp_stats.h>
 
 #include <asm/uaccess.h>
 
@@ -1950,6 +1951,13 @@ static int tcp_v6_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->conn_stats = kmem_cache_alloc(tcp_statsp, GFP_KERNEL);
+	if (tp->conn_stats == NULL)
+		return -1;
+
+	memset(tp->conn_stats, 0, sizeof(struct tcp_stats));
+	tp->create_time = get_jiffies_64();
+
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
-- 
1.7.3.1

