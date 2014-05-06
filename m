From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Tue,  6 May 2014 21:05:24 +0300
Message-ID: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42253 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbaEFSFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 14:05:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP was designed to be extensible with the help of TCP
options. However, even though theoretically a new TCP extension could
be orthogonal with respect to the core TCP stack, the current
implementation for handling TCP options makes it hard to create
modular TCP extensions.

When adding a new TCP option modifications in several core TCP
functions are required (tcp_options_write, tcp_established_options,
tcp_syn_options, tcp_syn_ack_options). More importantly, options are
passed via the tcp_skb_cb whose space is limited and currently only 4
bytes are available.

Extending the skb dynamically to store the options does not fully
solve the issue, as the TCP option space is limited in the TCP header
itself and when other options are set by the core TCP stack
(e.g. SACK) we might not have enough space. In this case, ideally we
should send the option in the next packet.

This patch tries to address this issue by creating a mechanism that
allows scheduling TCP options to be sent either with a SYN packet or
with a packet with a specific sequence number (or a later packet if
there is not enough space in the TCP header).

The options can be scheduled reliably and in that case retransmissions
of a packet initially sent with a scheduled option will include the
option in the retransmitted packets.

In certain cases we may not have space in the header and run out of
packets to be sent. To avoid blocking until more data can be sent,
duplicate ACKs may be requested when scheduling options.

This mechanism can be used to implement TCP extensions such as
MultiPath TCP [1] in a modular fashion, which would otherwise require
intrusive changes in the TCP stack [2]. We plan to use it to implement
an MPTCP layer that sits on top of TCP and thus avoid most of the
changes in the existing TCP code.

Pardon the rough patch, but I hope it is enough to get some feedback
on the overall approach.

[1] http://tools.ietf.org/html/rfc6824
[2] https://github.com/multipath-tcp/mptcp
---
 include/linux/tcp.h   |   6 +++
 include/net/tcp.h     |  25 ++++++++++-
 net/ipv4/tcp.c        |  53 ++++++++++++++++++++++
 net/ipv4/tcp_input.c  |  15 +++++++
 net/ipv4/tcp_ipv4.c   |   2 +
 net/ipv4/tcp_output.c | 120 +++++++++++++++++++++++++++++++++++++++++++++++---
 6 files changed, 214 insertions(+), 7 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d686334..a06519c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -320,6 +320,12 @@ struct tcp_sock {
 	 * socket. Used to retransmit SYNACKs etc.
 	 */
 	struct request_sock *fastopen_rsk;
+
+	struct list_head sched_opts; 	/* Scheduled options (to be sent) */
+	struct list_head sent_opts;	/* Sent options (for retransmission) */
+	u32 req_dup_ack;		/* Trigger a dup-ack if critical options
+					 * were not sent due to not enough
+					 * space in the header*/
 };
 
 enum tsq_flags {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70e55d2..22c6721 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -725,7 +725,7 @@ struct tcp_skb_cb {
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
-	/* 1 byte hole */
+	__u8		retrans:1;	/* SKB is being retransmitted 	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 };
 
@@ -1600,6 +1600,29 @@ struct tcp_request_sock_ops {
 
 int tcpv4_offload_init(void);
 
+struct tcp_opt_buff {
+	struct list_head list;
+	__u32 seq;
+	__be32 data[MAX_TCP_OPTION_SPACE/sizeof(__be32)];
+	__u8 size;
+	__u8 flags;
+#define TOB_F_RELIABLE	0x01	/* This option must be retransmitted. */
+#define TOB_F_DUP_ACK	0x02	/* Allow triggering a dup-ack if all
+				 * data is gone but we didn't find
+				 * space for this option */
+#define TOB_F_NO_GSO	0x04	/* This option is not compatbile with GSO. */
+#define TOB_F_SYN	0x08	/* */
+#define TOB_USER_MASK	0x0F 	/* Mask for public flags */
+#define TOB_F_NOSPACE	0x10	/* Not enough space to send this option */
+};
+
+int __tcp_queue_opt(struct tcp_sock *tp, struct list_head *head,
+		    struct tcp_opt_buff *tob);
+
+int tcp_sched_opt(struct tcp_sock *tp, struct tcp_opt_buff *tob);
+void tcp_sched_opt_purge(struct tcp_sock *tp);
+
+
 void tcp_v4_init(void);
 void tcp_init(void);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8e8529d..1f78d91 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -417,6 +417,9 @@ void tcp_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
+	INIT_LIST_HEAD(&tp->sched_opts);
+	INIT_LIST_HEAD(&tp->sent_opts);
+
 	local_bh_disable();
 	sock_update_memcg(sk);
 	sk_sockets_allocated_inc(sk);
@@ -3060,6 +3063,56 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 #endif
 
+int __tcp_queue_opt(struct tcp_sock *tp, struct list_head *head,
+				  struct tcp_opt_buff *tob)
+{
+	struct tcp_opt_buff *i;
+
+	if (tob->flags & TOB_F_SYN) {
+		struct sock *sk = (struct sock *)tp;
+		if ((1 << sk->sk_state) & ~(TCPF_CLOSE | TCPF_LISTEN))
+			return -EINVAL;
+		list_add(&tob->list, head);
+		return 0;
+	} else {
+		if (before(tob->seq, tp->write_seq))
+			return -EINVAL;
+	}
+
+	list_for_each_entry_reverse(i, &tp->sched_opts, list) {
+		if (before(i->seq, tob->seq))
+			break;
+	}
+	list_add_tail(&tob->list, &i->list);
+	return 0;
+}
+
+int tcp_sched_opt(struct tcp_sock *tp, struct tcp_opt_buff *tob)
+{
+	tob->flags &= TOB_USER_MASK;
+	if (tob->size != ALIGN(tob->size, 4))
+		return -EINVAL;
+
+	return __tcp_queue_opt(tp, &tp->sched_opts, tob);
+}
+EXPORT_SYMBOL(tcp_sched_opt);
+
+
+void tcp_sched_opt_purge(struct tcp_sock *tp)
+{
+	struct tcp_opt_buff *tob, *tmp;
+
+	list_for_each_entry_safe(tob, tmp, &tp->sched_opts, list) {
+		list_del(&tob->list);
+		kfree(tob);
+	}
+	list_for_each_entry_safe(tob, tmp, &tp->sent_opts, list) {
+		list_del(&tob->list);
+		kfree(tob);
+	}
+}
+
+
 void tcp_done(struct sock *sk)
 {
 	struct request_sock *req = tcp_sk(sk)->fastopen_rsk;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c53b7f3..40d1436 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3015,6 +3015,19 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
 	return packets_acked;
 }
 
+static void tcp_clean_sent_opts(struct tcp_sock *tp)
+{
+	struct tcp_opt_buff *tob, *tmp;
+
+	list_for_each_entry_safe(tob, tmp, &tp->sent_opts, list) {
+		if (after(tob->seq, tp->snd_una))
+			break;
+
+		list_del(&tob->list);
+		kfree(tob);
+	}
+}
+
 /* Remove acknowledged frames from the retransmission queue. If our packet
  * is before the ack sequence we can discard it as it's confirmed to have
  * arrived at the other end.
@@ -3452,6 +3465,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, sack_rtt);
 	acked -= tp->packets_out;
 
+	tcp_clean_sent_opts(tp);
+
 	/* Advance cwnd if state allows */
 	if (tcp_may_raise_cwnd(sk, flag))
 		tcp_cong_avoid(sk, ack, acked, prior_in_flight);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 14bba8a..59271c8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2158,6 +2158,8 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	/* Cleanup up the write buffer. */
 	tcp_write_queue_purge(sk);
 
+	tcp_sched_opt_purge(tp);
+
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
 	__skb_queue_purge(&tp->out_of_order_queue);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6728546..c3680a5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -388,6 +388,7 @@ static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
+#define OPTION_SCHED_OPTIONS	(1 << 4)
 #define OPTION_FAST_OPEN_COOKIE	(1 << 8)
 
 struct tcp_out_options {
@@ -399,6 +400,7 @@ struct tcp_out_options {
 	__u8 *hash_location;	/* temporary pointer, overloaded */
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
 	struct tcp_fastopen_cookie *fastopen_cookie;	/* Fast open cookie */
+	struct list_head sched_opts;
 };
 
 /* Write previously computed TCP options to the packet.
@@ -498,6 +500,100 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		}
 		ptr += (foc->len + 3) >> 2;
 	}
+
+	if (unlikely(OPTION_SCHED_OPTIONS & options)) {
+		struct tcp_opt_buff *tob, *tmp;
+
+		list_for_each_entry_safe(tob, tmp, &opts->sched_opts, list) {
+
+			memcpy(ptr, tob->data, tob->size);
+			ptr += tob->size;
+
+			list_del(&tob->list);
+
+			if (tob->flags & TOB_F_RELIABLE)
+				__tcp_queue_opt(tp, &tp->sent_opts, tob);
+			else
+				kfree(tob);
+		}
+	}
+}
+
+static void __tcp_sched_options(struct tcp_sock *tp, struct sk_buff *skb,
+				struct tcp_out_options *options,
+				unsigned int *remaining,
+				struct list_head *queue)
+{
+	struct tcp_opt_buff *tob, *tmp;
+	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
+
+	list_for_each_entry_safe(tob, tmp, queue, list) {
+
+		if (tob->flags && TOB_F_SYN) {
+			if (!(tcb->tcp_flags & TCPHDR_SYN)) {
+				/* TODO signal error */
+				list_del(&tob->list);
+				kfree(tob);
+				continue;
+			}
+		} else {
+			if (before(tob->seq, tcb->seq)) {
+				continue;
+			}
+		}
+
+		if (*remaining == 0)
+			break;
+
+		if (skb_is_gso(skb) && (tob->flags & TOB_F_NO_GSO))
+			continue;
+
+		if (*remaining < tob->size) {
+			if (tob->flags && TOB_F_SYN) {
+				/* TODO signal error */
+				list_del(&tob->list);
+				kfree(tob);
+				continue;
+			}
+			if ((tob->flags & TOB_F_DUP_ACK) &&
+			    !(tob->flags & TOB_F_NOSPACE)) {
+				tp->req_dup_ack++;
+				tob->flags |= TOB_F_NOSPACE;
+			}
+			continue;
+		}
+
+		options->options |= OPTION_SCHED_OPTIONS;
+		*remaining -= tob->size;
+		tob->seq = tcb->seq;
+
+		list_del(&tob->list);
+		list_add_tail(&tob->list, &options->sched_opts);
+
+		if (tob->flags & TOB_F_NOSPACE) {
+			tob->flags &= ~TOB_F_NOSPACE;
+			tp->req_dup_ack--;
+		}
+	}
+
+}
+
+static void tcp_sched_options(struct tcp_sock *tp, struct sk_buff *skb,
+			      struct tcp_out_options *options,
+			      unsigned int *remaining)
+{
+	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
+
+	if (!skb)
+		return;
+
+	INIT_LIST_HEAD(&options->sched_opts);
+	if (tcb->retrans)
+		__tcp_sched_options(tp, skb, options, remaining,
+				    &tp->sent_opts);
+	else
+		__tcp_sched_options(tp, skb, options, remaining,
+				    &tp->sched_opts);
 }
 
 /* Compute TCP options for SYN packets. This is not the final
@@ -561,6 +657,8 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+	tcp_sched_options(tp, skb, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -622,6 +720,8 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		}
 	}
 
+	tcp_sched_options(tcp_sk(sk), skb, opts, &remaining);
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -634,7 +734,7 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 {
 	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned int size = 0;
+	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 	unsigned int eff_sacks;
 
 	opts->options = 0;
@@ -643,7 +743,7 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
 	if (unlikely(*md5)) {
 		opts->options |= OPTION_MD5;
-		size += TCPOLEN_MD5SIG_ALIGNED;
+		remaining -= TCPOLEN_MD5SIG_ALIGNED;
 	}
 #else
 	*md5 = NULL;
@@ -653,21 +753,22 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 		opts->options |= OPTION_TS;
 		opts->tsval = tcb ? tcb->when + tp->tsoffset : 0;
 		opts->tsecr = tp->rx_opt.ts_recent;
-		size += TCPOLEN_TSTAMP_ALIGNED;
+		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
 
 	eff_sacks = tp->rx_opt.num_sacks + tp->rx_opt.dsack;
 	if (unlikely(eff_sacks)) {
-		const unsigned int remaining = MAX_TCP_OPTION_SPACE - size;
 		opts->num_sack_blocks =
 			min_t(unsigned int, eff_sacks,
 			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
 			      TCPOLEN_SACK_PERBLOCK);
-		size += TCPOLEN_SACK_BASE_ALIGNED +
+		remaining -= TCPOLEN_SACK_BASE_ALIGNED +
 			opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
 	}
 
-	return size;
+	tcp_sched_options(tp, skb, opts, &remaining);
+
+	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
 
@@ -1912,6 +2013,12 @@ repair:
 			break;
 	}
 
+	/* Critical options were not sent because of not enough space
+	 * in the header. Force a dup-ack to allow the critical option
+	 * to get out. */
+	if (tp->req_dup_ack)
+		tcp_send_ack(sk);
+
 	if (likely(sent_pkts)) {
 		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += sent_pkts;
@@ -2357,6 +2464,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * is still in somebody's hands, else make a clone.
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->retrans = 1;
 
 	/* make sure skb->data is aligned on arches that require it
 	 * and check if ack-trimming & collapsing extended the headroom
-- 
1.8.3.2
