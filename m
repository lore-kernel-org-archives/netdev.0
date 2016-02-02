From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel@gmail.com>
Subject: [PATCH v3 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Tue,  2 Feb 2016 20:23:15 +0100
Message-ID: <1454440995-18457-3-git-send-email-bro.devel+kernel@gmail.com>
References: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?q?P=C3=A5l=20Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=
	<bro.devel+kernel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:35958 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbcBBTYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:24:09 -0500
Received: by mail-lb0-f193.google.com with SMTP id zr1so4105023lbb.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:24:08 -0800 (PST)
In-Reply-To: <1454440995-18457-1-git-send-email-bro.devel+kernel@gmail.com>
In-Reply-To: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDB is a mechanism that enables a TCP sender to bundle redundant
(already sent) data with TCP packets containing new data. By bundling
(retransmitting) already sent data with each TCP packet containing new
data, the connection will be more resistant to sporadic packet loss
which reduces the application layer latency significantly in congested
scenarios.

The main functionality added:

  o Loss detection of hidden loss events: When bundling redundant data
    with each packet, packet loss can be hidden from the TCP engine due
    to lack of dupACKs. This is because the loss is "repaired" by the
    redundant data in the packet coming after the lost packet. Based on
    incoming ACKs, such hidden loss events are detected, and CWR state
    is entered.

  o When packets are scheduled for transmission, RDB replaces the SKB t=
o
    be sent with a modified SKB containing the redundant data of
    previously sent data segments from the TCP output queue.

  o RDB will only be used for streams classified as thin by the functio=
n
    tcp_stream_is_thin_dpifl(). This enforces a lower bound on the ITT
    for streams that may benefit from RDB, controlled by the sysctl
    variable tcp_thin_dpifl_itt_lower_bound.

RDB is enabled on a connection with the socket option TCP_RDB, or on al=
l
new connections by setting the sysctl variable tcp_rdb=3D1.

Cc: Andreas Petlund <apetlund@simula.no>
Cc: Carsten Griwodz <griff@simula.no>
Cc: P=C3=A5l Halvorsen <paalh@simula.no>
Cc: Jonas Markussen <jonassm@ifi.uio.no>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |  15 ++
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |   3 +-
 include/net/tcp.h                      |  14 ++
 include/uapi/linux/tcp.h               |   1 +
 net/core/skbuff.c                      |   3 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/sysctl_net_ipv4.c             |  26 ++++
 net/ipv4/tcp.c                         |  14 +-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_output.c                  |  11 +-
 net/ipv4/tcp_rdb.c                     | 273 +++++++++++++++++++++++++=
++++++++
 12 files changed, 359 insertions(+), 8 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index eb42853..14f960d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -716,6 +716,21 @@ tcp_thin_dpifl_itt_lower_bound - INTEGER
 	calculated, which is used to classify whether a stream is thin.
 	Default: 10000
=20
+tcp_rdb - BOOLEAN
+	Enable RDB for all new TCP connections.
+	Default: 0
+
+tcp_rdb_max_bytes - INTEGER
+	Enable restriction on how many bytes an RDB packet can contain.
+	This is the total amount of payload including the new unsent data.
+	Default: 0
+
+tcp_rdb_max_packets - INTEGER
+	Enable restriction on how many previous packets in the output queue
+	RDB may include data from. A value of 1 will restrict bundling to
+	only the data from the last packet that was sent.
+	Default: 1
+
 tcp_limit_output_bytes - INTEGER
 	Controls TCP Small Queue limit per tcp socket.
 	TCP bulk sender tends to increase packets in flight until it
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11f935c..eb81877 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2914,6 +2914,7 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, st=
ruct iov_iter *frm);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned i=
nt flags);
+void copy_skb_header(struct sk_buff *new, const struct sk_buff *old);
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int=
 len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, =
int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u=
8 *to,
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b386361..da6dae8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -202,9 +202,10 @@ struct tcp_sock {
 	} rack;
 	u16	advmss;		/* Advertised MSS			*/
 	u8	unused;
-	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
+	u8	nonagle     : 3,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
+		rdb         : 1,/* Redundant Data Bundling enabled      */
 		repair      : 1,
 		frto        : 1;/* F-RTO (RFC5682) activated in CA_Loss */
 	u8	repair_queue;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2d86bd7..bc6e81b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -274,6 +274,9 @@ extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_thin_dpifl_itt_lower_bound;
+extern int sysctl_tcp_rdb;
+extern int sysctl_tcp_rdb_max_bytes;
+extern int sysctl_tcp_rdb_max_packets;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
@@ -547,6 +550,8 @@ void __tcp_push_pending_frames(struct sock *sk, uns=
igned int cur_mss,
 bool tcp_may_send_now(struct sock *sk);
 int __tcp_retransmit_skb(struct sock *, struct sk_buff *);
 int tcp_retransmit_skb(struct sock *, struct sk_buff *);
+int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_i=
t,
+		     gfp_t gfp_mask);
 void tcp_retransmit_timer(struct sock *sk);
 void tcp_xmit_retransmit_queue(struct sock *);
 void tcp_simple_retransmit(struct sock *);
@@ -572,6 +577,11 @@ void tcp_synack_rtt_meas(struct sock *sk, struct r=
equest_sock *req);
 void tcp_reset(struct sock *sk);
 void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_bu=
ff *skb);
=20
+/* tcp_rdb.c */
+void rdb_ack_event(struct sock *sk, u32 flags);
+int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_skb,
+			 unsigned int mss_now, gfp_t gfp_mask);
+
 /* tcp_timer.c */
 void tcp_init_xmit_timers(struct sock *);
 static inline void tcp_clear_xmit_timers(struct sock *sk)
@@ -770,6 +780,7 @@ struct tcp_skb_cb {
 	union {
 		struct {
 			/* There is space for up to 20 bytes */
+			__u32 rdb_start_seq; /* Start seq of rdb data bundled */
 		} tx;   /* only used for outgoing skbs */
 		union {
 			struct inet_skb_parm	h4;
@@ -1501,6 +1512,9 @@ static inline struct sk_buff *tcp_write_queue_pre=
v(const struct sock *sk,
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
=20
+#define tcp_for_write_queue_reverse_from_safe(skb, tmp, sk)		\
+	skb_queue_reverse_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
+
 static inline struct sk_buff *tcp_send_head(const struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 65a77b0..ae0fba3 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -115,6 +115,7 @@ enum {
 #define TCP_CC_INFO		26	/* Get Congestion Control (optional) info */
 #define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
 #define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection *=
/
+#define TCP_RDB			29	/* Enable RDB mechanism */
=20
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b2df375..d23058b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -978,7 +978,7 @@ static void skb_headers_offset_update(struct sk_buf=
f *skb, int off)
 	skb->inner_mac_header +=3D off;
 }
=20
-static void copy_skb_header(struct sk_buff *new, const struct sk_buff =
*old)
+void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	__copy_skb_header(new, old);
=20
@@ -986,6 +986,7 @@ static void copy_skb_header(struct sk_buff *new, co=
nst struct sk_buff *old)
 	skb_shinfo(new)->gso_segs =3D skb_shinfo(old)->gso_segs;
 	skb_shinfo(new)->gso_type =3D skb_shinfo(old)->gso_type;
 }
+EXPORT_SYMBOL(copy_skb_header);
=20
 static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
 {
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 62c049b..3c55ba9 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -12,7 +12,8 @@ obj-y     :=3D route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o \
+	     tcp_rdb.o
=20
 obj-$(CONFIG_NET_IP_TUNNEL) +=3D ip_tunnel.o
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_ipv4.o
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6014bc4..f7c9b1e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -696,6 +696,32 @@ static struct ctl_table ipv4_table[] =3D {
 		.extra1		=3D &tcp_thin_dpifl_itt_lower_bound_min,
 	},
 	{
+		.procname	=3D "tcp_rdb",
+		.data		=3D &sysctl_tcp_rdb,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+		.extra2		=3D &one,
+	},
+	{
+		.procname	=3D "tcp_rdb_max_bytes",
+		.data		=3D &sysctl_tcp_rdb_max_bytes,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.proc_handler	=3D &proc_dointvec,
+		.extra1		=3D &zero,
+	},
+	{
+		.procname	=3D "tcp_rdb_max_packets",
+		.data		=3D &sysctl_tcp_rdb_max_packets,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D &proc_dointvec_minmax,
+		.extra1		=3D &zero,
+	},
+	{
 		.procname	=3D "tcp_early_retrans",
 		.data		=3D &sysctl_tcp_early_retrans,
 		.maxlen		=3D sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 16087fe..ea9d6ef 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -290,6 +290,8 @@ int sysctl_tcp_autocorking __read_mostly =3D 1;
=20
 int sysctl_tcp_thin_dpifl_itt_lower_bound __read_mostly =3D TCP_THIN_D=
PIFL_ITT_LOWER_BOUND_MIN;
=20
+int sysctl_tcp_rdb __read_mostly;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
=20
@@ -409,6 +411,7 @@ void tcp_init_sock(struct sock *sk)
 	u64_stats_init(&tp->syncp);
=20
 	tp->reordering =3D sysctl_tcp_reordering;
+	tp->rdb =3D sysctl_tcp_rdb;
 	tcp_enable_early_retrans(tp);
 	tcp_assign_congestion_control(sk);
=20
@@ -2409,6 +2412,13 @@ static int do_tcp_setsockopt(struct sock *sk, in=
t level,
 		}
 		break;
=20
+	case TCP_RDB:
+		if (val < 0 || val > 1)
+			err =3D -EINVAL;
+		else
+			tp->rdb =3D val;
+		break;
+
 	case TCP_REPAIR:
 		if (!tcp_can_repair_sock(sk))
 			err =3D -EPERM;
@@ -2832,7 +2842,9 @@ static int do_tcp_getsockopt(struct sock *sk, int=
 level,
 	case TCP_THIN_DUPACK:
 		val =3D tp->thin_dupack;
 		break;
-
+	case TCP_RDB:
+		val =3D tp->rdb;
+		break;
 	case TCP_REPAIR:
 		val =3D tp->repair;
 		break;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1c2a734..1fda930 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3504,6 +3504,9 @@ static inline void tcp_in_ack_event(struct sock *=
sk, u32 flags)
=20
 	if (icsk->icsk_ca_ops->in_ack_event)
 		icsk->icsk_ca_ops->in_ack_event(sk, flags);
+
+	if (unlikely(tcp_sk(sk)->rdb))
+		rdb_ack_event(sk, flags);
 }
=20
 /* This routine deals with incoming acks, but not outgoing ones. */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fda379c..e24ab6a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -900,8 +900,8 @@ out:
  * We are working here with either a clone of the original
  * SKB, or a fresh unique copy made by the retransmit engine.
  */
-static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int =
clone_it,
-			    gfp_t gfp_mask)
+int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_i=
t,
+		     gfp_t gfp_mask)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct inet_sock *inet;
@@ -2113,9 +2113,12 @@ static bool tcp_write_xmit(struct sock *sk, unsi=
gned int mss_now, int nonagle,
 				break;
 		}
=20
-		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
+		if (unlikely(tcp_sk(sk)->rdb)) {
+			if (tcp_transmit_rdb_skb(sk, skb, mss_now, gfp))
+				break;
+		} else if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp))) {
 			break;
-
+		}
 repair:
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
diff --git a/net/ipv4/tcp_rdb.c b/net/ipv4/tcp_rdb.c
new file mode 100644
index 0000000..50439eb
--- /dev/null
+++ b/net/ipv4/tcp_rdb.c
@@ -0,0 +1,273 @@
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+
+int sysctl_tcp_rdb_max_bytes __read_mostly;
+int sysctl_tcp_rdb_max_packets __read_mostly =3D 1;
+
+/**
+ * rdb_check_rtx_queue_loss() - perform loss detection by analysing ac=
ks.
+ * @sk: socket.
+ *
+ * Return: The number of packets that are presumed to be lost.
+ */
+static unsigned int rdb_check_rtx_queue_loss(struct sock *sk)
+{
+	struct sk_buff *skb, *tmp;
+	struct tcp_skb_cb *scb;
+	u32 seq_acked =3D tcp_sk(sk)->snd_una;
+	unsigned int packets_lost =3D 0;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		scb =3D TCP_SKB_CB(skb);
+		/* The ACK acknowledges parts of the data in this SKB.
+		 * Can be caused by:
+		 * - TSO: We abort as RDB is not used on SKBs split across
+		 *        multiple packets on lower layers as these are greater
+		 *        than one MSS.
+		 * - Retrans collapse: We've had a retrans, so loss has already
+		 *                     been detected.
+		 */
+		if (after(scb->end_seq, seq_acked)) {
+			break;
+		/* The ACKed packet */
+		} else if (scb->end_seq =3D=3D seq_acked) {
+			/* This SKB was sent with no RDB data, or no prior
+			 * unacked SKBs in output queue, so break here.
+			 */
+			if (scb->tx.rdb_start_seq =3D=3D scb->seq ||
+			    skb_queue_is_first(&sk->sk_write_queue, skb))
+				break;
+			/* Find number of prior SKBs who's data was bundled in
+			 * this (ACKed) SKB. We presume any redundant data
+			 * covering previous SKB's are due to loss. (An
+			 * exception would be reordering).
+			 */
+			skb =3D skb->prev;
+			tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
+				if (!before(TCP_SKB_CB(skb)->seq, scb->tx.rdb_start_seq))
+					packets_lost++;
+				else
+					break;
+			}
+			break;
+		}
+	}
+	return packets_lost;
+}
+
+/**
+ * rdb_ack_event() - initiate loss detection
+ * @sk: socket
+ * @flags: flags
+ */
+void rdb_ack_event(struct sock *sk, u32 flags)
+{
+	if (rdb_check_rtx_queue_loss(sk))
+		tcp_enter_cwr(sk);
+}
+
+/**
+ * skb_append_data() - copy data from an SKB to the end of another
+ * @from_skb: the SKB to copy data from
+ * @to_skb: the SKB to copy data to
+ *
+ * Return: 0 on success, else error
+ */
+static int skb_append_data(struct sk_buff *from_skb, struct sk_buff *t=
o_skb)
+{
+	/* Copy the linear data and the data from the frags into the linear p=
age
+	 * buffer of to_skb.
+	 */
+	if (WARN_ON(skb_copy_bits(from_skb, 0,
+				  skb_put(to_skb, from_skb->len),
+				  from_skb->len))) {
+		goto fault;
+	}
+
+	TCP_SKB_CB(to_skb)->end_seq =3D TCP_SKB_CB(from_skb)->end_seq;
+
+	if (from_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		to_skb->ip_summed =3D CHECKSUM_PARTIAL;
+
+	if (to_skb->ip_summed !=3D CHECKSUM_PARTIAL)
+		to_skb->csum =3D csum_block_add(to_skb->csum, from_skb->csum,
+					      to_skb->len);
+	return 0;
+fault:
+	return -EFAULT;
+}
+
+/**
+ * rdb_build_skb() - build the new RDB SKB and copies all the data int=
o the
+ *                   linear page buffer.
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @first_skb: the first SKB in the output queue to be bundled
+ * @bytes_in_rdb_skb: the total number of data bytes for the new rdb_s=
kb
+ *                    (NEW + Redundant)
+ * @gfp_mask: gfp_t allocation
+ *
+ * Return: A new SKB containing redundant data, or NULL if memory allo=
cation
+ *         failed
+ */
+static struct sk_buff *rdb_build_skb(const struct sock *sk,
+				     struct sk_buff *xmit_skb,
+				     struct sk_buff *first_skb,
+				     u32 bytes_in_rdb_skb,
+				     gfp_t gfp_mask)
+{
+	struct sk_buff *rdb_skb, *tmp_skb;
+
+	rdb_skb =3D sk_stream_alloc_skb((struct sock *)sk,
+				      (int)bytes_in_rdb_skb,
+				      gfp_mask, true);
+	if (!rdb_skb)
+		return NULL;
+	copy_skb_header(rdb_skb, xmit_skb);
+	rdb_skb->ip_summed =3D xmit_skb->ip_summed;
+
+	TCP_SKB_CB(rdb_skb)->seq =3D TCP_SKB_CB(first_skb)->seq;
+	TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq =3D TCP_SKB_CB(rdb_skb)->seq;
+
+	tmp_skb =3D first_skb;
+
+	tcp_for_write_queue_from(tmp_skb, sk) {
+		/* Copy data from tmp_skb to rdb_skb */
+		if (skb_append_data(tmp_skb, rdb_skb))
+			return NULL;
+		/* We are at the last skb that should be included (The unsent
+		 * one)
+		 */
+		if (tmp_skb =3D=3D xmit_skb)
+			break;
+	}
+	return rdb_skb;
+}
+
+/**
+ * rdb_can_bundle_test() - test if redundant data can be bundled
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @mss_now: current mss value
+ * @bytes_in_rdb_skb: store the total number of payload bytes in the
+ *                    RDB SKB if bundling can be performed.
+ * @skbs_to_bundle_count: the total number of SKBs to be in the bundle
+ *
+ * Traverse the output queue and check if any un-acked data may be
+ * bundled.
+ *
+ * Return: The first SKB to be in the bundle, or NULL if no bundling
+ */
+static struct sk_buff *rdb_can_bundle_test(const struct sock *sk,
+					   struct sk_buff *xmit_skb,
+					   unsigned int mss_now,
+					   u32 *bytes_in_rdb_skb,
+					   u32 *skbs_to_bundle_count)
+{
+	struct sk_buff *first_to_bundle =3D NULL;
+	struct sk_buff *tmp, *skb =3D xmit_skb->prev;
+	u32 skbs_in_bundle_count =3D 1; /* 1 to account for current skb */
+	u32 byte_count =3D xmit_skb->len;
+
+	/* We start at the skb before xmit_skb, and go backwards in the list.=
*/
+	tcp_for_write_queue_reverse_from_safe(skb, tmp, sk) {
+		/* Not enough room to bundle data from this SKB */
+		if ((byte_count + skb->len) > mss_now)
+			break;
+
+		if (sysctl_tcp_rdb_max_bytes &&
+		    ((byte_count + skb->len) > sysctl_tcp_rdb_max_bytes))
+			break;
+
+		if (sysctl_tcp_rdb_max_packets &&
+		    (skbs_in_bundle_count > sysctl_tcp_rdb_max_packets))
+			break;
+
+		byte_count +=3D skb->len;
+		skbs_in_bundle_count++;
+		first_to_bundle =3D skb;
+	}
+	*bytes_in_rdb_skb =3D byte_count;
+	*skbs_to_bundle_count =3D skbs_in_bundle_count;
+	return first_to_bundle;
+}
+
+/**
+ * create_rdb_skb() - try to create an RDB SKB
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @mss_now: current mss value
+ * @bytes_in_rdb_skb: store the total number of payload bytes in the
+ *                    RDB SKB if bundling can be performed.
+ * @gfp_mask: gfp_t allocation
+ *
+ * Return: A new SKB containing redundant data, or NULL if no bundling=
 could be
+ *         performed
+ */
+struct sk_buff *create_rdb_skb(const struct sock *sk, struct sk_buff *=
xmit_skb,
+			       unsigned int mss_now, u32 *bytes_in_rdb_skb,
+			       gfp_t gfp_mask)
+{
+	u32 skb_in_bundle_count;
+	struct sk_buff *first_to_bundle;
+
+	if (skb_queue_is_first(&sk->sk_write_queue, xmit_skb))
+		return NULL;
+
+	/* No bundling on FIN packet */
+	if (TCP_SKB_CB(xmit_skb)->tcp_flags & TCPHDR_FIN)
+		return NULL;
+
+	/* Find number of (previous) SKBs to get data from */
+	first_to_bundle =3D rdb_can_bundle_test(sk, xmit_skb, mss_now,
+					       bytes_in_rdb_skb,
+					       &skb_in_bundle_count);
+	if (!first_to_bundle)
+		return NULL;
+
+	/* Create an SKB that contains the data from 'skb_in_bundle_count'
+	 * SKBs.
+	 */
+	return rdb_build_skb(sk, xmit_skb, first_to_bundle,
+			     *bytes_in_rdb_skb, gfp_mask);
+}
+
+/**
+ * tcp_transmit_rdb_skb() - try to create and send an RDB packet
+ * @sk: socket
+ * @xmit_skb: the SKB processed for transmission by the output engine
+ * @mss_now: current mss value
+ * @gfp_mask: gfp_t allocation
+ *
+ * Return: 0 if successfully sent packet, else error
+ */
+int tcp_transmit_rdb_skb(struct sock *sk, struct sk_buff *xmit_skb,
+			 unsigned int mss_now, gfp_t gfp_mask)
+{
+	struct sk_buff *rdb_skb =3D NULL;
+	u32 bytes_in_rdb_skb =3D 0; /* May be used for statistical purposes *=
/
+
+	/* How we detect that RDB was used. When equal, no RDB data was sent =
*/
+	TCP_SKB_CB(xmit_skb)->tx.rdb_start_seq =3D TCP_SKB_CB(xmit_skb)->seq;
+
+	if (tcp_stream_is_thin_dpifl(tcp_sk(sk))) {
+		rdb_skb =3D create_rdb_skb(sk, xmit_skb, mss_now,
+					 &bytes_in_rdb_skb, gfp_mask);
+		if (!rdb_skb)
+			goto xmit_default;
+
+		/* Set tstamp for SKB in output queue, because tcp_transmit_skb
+		 * will do this for the rdb_skb and not the SKB in the output
+		 * queue (xmit_skb).
+		 */
+		skb_mstamp_get(&xmit_skb->skb_mstamp);
+		rdb_skb->skb_mstamp =3D xmit_skb->skb_mstamp;
+		return tcp_transmit_skb(sk, rdb_skb, 0, gfp_mask);
+	}
+xmit_default:
+	/* Transmit the unmodified SKB from output queue */
+	return tcp_transmit_skb(sk, xmit_skb, 1, gfp_mask);
+}
--=20
1.9.1
