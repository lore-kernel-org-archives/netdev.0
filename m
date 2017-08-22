From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH net-next 1/2] tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE to TCP recvmsg
Date: Tue, 22 Aug 2017 13:27:02 -0400
Message-ID: <20170822172703.31703-2-maloneykernel@gmail.com>
References: <20170822172703.31703-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:37873 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHVR1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:27:19 -0400
Received: by mail-yw0-f193.google.com with SMTP id s143so12156786ywg.4
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:27:19 -0700 (PDT)
In-Reply-To: <20170822172703.31703-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

When SOF_TIMESTAMPING_RX_SOFTWARE is enabled for tcp sockets, return the
timestamp corresponding to the highest sequence number data returned.

Previously the skb->tstamp is overwritten when a TCP packet is placed
in the out of order queue.  While the packet is in the ooo queue, save the
timestamp in the TCB_SKB_CB.  This space is shared with the gso_*
options which are only used on the tx path, and a previously unused 4
byte hole.

When skbs are coalesced either in the sk_receive_queue or the
out_of_order_queue always choose the timestamp of the appended skb to
maintain the invariant of returning the timestamp of the last byte in
the recvmsg buffer.

Signed-off-by: Mike Maloney <maloney@google.com>
---
 include/net/tcp.h    |  9 +++++++-
 net/ipv4/tcp.c       | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c | 35 +++++++++++++++++++++++++----
 net/ipv4/tcp_ipv4.c  |  2 ++
 net/ipv6/tcp_ipv6.c  |  2 ++
 5 files changed, 106 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index afdab3781425..f26d20e9760d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -774,6 +774,12 @@ struct tcp_skb_cb {
 			u16	tcp_gso_segs;
 			u16	tcp_gso_size;
 		};
+
+		/* Used to stash the receive timestamp while this skb is in the
+		 * out of order queue, as skb->tstamp is overwritten by the
+		 * rbnode.
+		 */
+		ktime_t		swtstamp;
 	};
 	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
 
@@ -790,7 +796,8 @@ struct tcp_skb_cb {
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
 			eor:1,		/* Is skb MSG_EOR marked? */
-			unused:6;
+			has_rxtstamp:1,	/* SKB has a RX timestamp	*/
+			unused:5;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d25e3bcca66b..4c58c7b2d8ed 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -269,6 +269,7 @@
 #include <linux/err.h>
 #include <linux/time.h>
 #include <linux/slab.h>
+#include <linux/errqueue.h>
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
@@ -1695,6 +1696,59 @@ int tcp_peek_len(struct socket *sock)
 }
 EXPORT_SYMBOL(tcp_peek_len);
 
+static void tcp_update_recv_tstamps(struct sk_buff *skb,
+				    struct scm_timestamping *tss)
+{
+	if (skb->tstamp)
+		tss->ts[0] = ktime_to_timespec(skb->tstamp);
+	else
+		tss->ts[0] = (struct timespec) {0};
+
+	if (skb_hwtstamps(skb)->hwtstamp)
+		tss->ts[2] = ktime_to_timespec(skb_hwtstamps(skb)->hwtstamp);
+	else
+		tss->ts[2] = (struct timespec) {0};
+}
+
+/* Similar to __sock_recv_timestamp, but does not require an skb */
+void tcp_recv_timestamp(struct msghdr *msg, const struct sock *sk,
+			struct scm_timestamping *tss)
+{
+	struct timeval tv;
+	bool has_timestamping = false;
+
+	if (tss->ts[0].tv_sec || tss->ts[0].tv_nsec) {
+		if (sock_flag(sk, SOCK_RCVTSTAMP)) {
+			if (sock_flag(sk, SOCK_RCVTSTAMPNS)) {
+				put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
+					 sizeof(tss->ts[0]), &tss->ts[0]);
+			} else {
+				tv.tv_sec = tss->ts[0].tv_sec;
+				tv.tv_usec = tss->ts[0].tv_nsec / 1000;
+
+				put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
+					 sizeof(tv), &tv);
+			}
+		}
+
+		if (sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE)
+			has_timestamping = true;
+		else
+			tss->ts[0] = (struct timespec) {0};
+	}
+
+	if (tss->ts[2].tv_sec || tss->ts[2].tv_nsec) {
+		if (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)
+			has_timestamping = true;
+		else
+			tss->ts[2] = (struct timespec) {0};
+	}
+
+	if (has_timestamping)
+		put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING,
+			 sizeof(*tss), tss);
+}
+
 /*
  *	This routine copies from a sock struct into the user buffer.
  *
@@ -1716,6 +1770,8 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 	long timeo;
 	struct sk_buff *skb, *last;
 	u32 urg_hole = 0;
+	struct scm_timestamping tss;
+	bool has_tss = false;
 
 	if (unlikely(flags & MSG_ERRQUEUE))
 		return inet_recv_error(sk, msg, len, addr_len);
@@ -1911,6 +1967,10 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 		if (used + offset < skb->len)
 			continue;
 
+		if (TCP_SKB_CB(skb)->has_rxtstamp) {
+			tcp_update_recv_tstamps(skb, &tss);
+			has_tss = true;
+		}
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			goto found_fin_ok;
 		if (!(flags & MSG_PEEK))
@@ -1929,6 +1989,9 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 	 * on connected socket. I was just happy when found this 8) --ANK
 	 */
 
+	if (has_tss)
+		tcp_recv_timestamp(msg, sk, &tss);
+
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ddc854728a60..66abcbf6f381 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4246,9 +4246,15 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	tp->rx_opt.num_sacks = num_sacks;
 }
 
+enum tcp_queue {
+	OOO_QUEUE,
+	RCV_QUEUE,
+};
+
 /**
  * tcp_try_coalesce - try to merge skb to prior one
  * @sk: socket
+ * @dest: destination queue
  * @to: prior buffer
  * @from: buffer to add in queue
  * @fragstolen: pointer to boolean
@@ -4260,6 +4266,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
  * Returns true if caller should free @from instead of queueing it
  */
 static bool tcp_try_coalesce(struct sock *sk,
+			     enum tcp_queue dest,
 			     struct sk_buff *to,
 			     struct sk_buff *from,
 			     bool *fragstolen)
@@ -4281,6 +4288,15 @@ static bool tcp_try_coalesce(struct sock *sk,
 	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
 	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
 	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
+
+	if (TCP_SKB_CB(from)->has_rxtstamp) {
+		TCP_SKB_CB(to)->has_rxtstamp = true;
+		if (dest == OOO_QUEUE)
+			TCP_SKB_CB(to)->swtstamp = TCP_SKB_CB(from)->swtstamp;
+		else
+			to->tstamp = from->tstamp;
+	}
+
 	return true;
 }
 
@@ -4315,6 +4331,9 @@ static void tcp_ofo_queue(struct sock *sk)
 		}
 		p = rb_next(p);
 		rb_erase(&skb->rbnode, &tp->out_of_order_queue);
+		/* Replace tstamp which was stomped by rbnode */
+		if (TCP_SKB_CB(skb)->has_rxtstamp)
+			skb->tstamp = TCP_SKB_CB(skb)->swtstamp;
 
 		if (unlikely(!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))) {
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
@@ -4326,7 +4345,8 @@ static void tcp_ofo_queue(struct sock *sk)
 			   TCP_SKB_CB(skb)->end_seq);
 
 		tail = skb_peek_tail(&sk->sk_receive_queue);
-		eaten = tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
+		eaten = tail && tcp_try_coalesce(sk, RCV_QUEUE,
+						 tail, skb, &fragstolen);
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		fin = TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN;
 		if (!eaten)
@@ -4380,6 +4400,10 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
+	/* Stash tstamp to avoid being stomped on by rbnode */
+	if (TCP_SKB_CB(skb)->has_rxtstamp)
+		TCP_SKB_CB(skb)->swtstamp = skb->tstamp;
+
 	inet_csk_schedule_ack(sk);
 
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
@@ -4405,7 +4429,8 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	/* In the typical case, we are adding an skb to the end of the list.
 	 * Use of ooo_last_skb avoids the O(Log(N)) rbtree lookup.
 	 */
-	if (tcp_try_coalesce(sk, tp->ooo_last_skb, skb, &fragstolen)) {
+	if (tcp_try_coalesce(sk, OOO_QUEUE, tp->ooo_last_skb,
+			     skb, &fragstolen)) {
 coalesce_done:
 		tcp_grow_window(sk, skb);
 		kfree_skb_partial(skb, fragstolen);
@@ -4455,7 +4480,8 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 				__kfree_skb(skb1);
 				goto merge_right;
 			}
-		} else if (tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
+		} else if (tcp_try_coalesce(sk, OOO_QUEUE, skb1,
+					    skb, &fragstolen)) {
 			goto coalesce_done;
 		}
 		p = &parent->rb_right;
@@ -4506,7 +4532,8 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
 
 	__skb_pull(skb, hdrlen);
 	eaten = (tail &&
-		 tcp_try_coalesce(sk, tail, skb, fragstolen)) ? 1 : 0;
+		 tcp_try_coalesce(sk, RCV_QUEUE, tail,
+				  skb, fragstolen)) ? 1 : 0;
 	tcp_rcv_nxt_update(tcp_sk(sk), TCP_SKB_CB(skb)->end_seq);
 	if (!eaten) {
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5af8b809dfbc..a63486afa7a7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1637,6 +1637,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
 	TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
 	TCP_SKB_CB(skb)->sacked	 = 0;
+	TCP_SKB_CB(skb)->has_rxtstamp =
+			skb->tstamp || skb_hwtstamps(skb)->hwtstamp;
 
 lookup:
 	sk = __inet_lookup_skb(&tcp_hashinfo, skb, __tcp_hdrlen(th), th->source,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d79a1af3252e..abba3bc2a3d9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1394,6 +1394,8 @@ static void tcp_v6_fill_cb(struct sk_buff *skb, const struct ipv6hdr *hdr,
 	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
 	TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
 	TCP_SKB_CB(skb)->sacked = 0;
+	TCP_SKB_CB(skb)->has_rxtstamp =
+			skb->tstamp || skb_hwtstamps(skb)->hwtstamp;
 }
 
 static int tcp_v6_rcv(struct sk_buff *skb)
-- 
2.14.1.480.gb18f417b89-goog
