From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v4 4/7] tcp: input header length, prediction, and timestamp
 bugs
Date: Sat, 23 Jan 2010 01:02:06 -0500
Message-ID: <4B5A90DE.5030708@gmail.com>
References: <4B5A88C4.7050205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080302080607070006070604"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753794Ab0AWGCO@vger.kernel.org>
In-Reply-To: <4B5A88C4.7050205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080302080607070006070604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Fix incorrect header prediction flags documentation.

Relieve register pressure in (the i386) fast path by accessing skb->len
directly, instead of carrying a rarely used len parameter.

Eliminate unused len parameters in two other functions.

Don't use output calculated tp->tcp_header_len for input decisions.
While the output header is usually the same as the input (same options
in both directions), that's a poor assumption. In particular, Sack will
be different. Newer options are not guaranteed.

Moreover, in the fast path, that only saved a shift or two. The other
efficiencies in this patch more than make up the difference.

Instead, use tp->rx_opt.tstamp_ok to accurately predict header length.

Likewise, use tp->rx_opt.tstamp_ok for received MSS calculations.

Don't use "sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED" to guess that
the timestamp is present. This may have been OK in the days with fewer
possible options, but various combinations of newer options may yield
the same header length. (This bug is in 3 places.)

Instead, use tp->rx_opt.saw_tstamp to determine a timestamp is present.

There's no need to test buffer length against header length, already
checked by tcp_v[4,6]_rcv(). Straighten code for minor efficiency gain.

Stand-alone patch, originally developed for TCPCT.

Requires:
   net: tcp_header_len_th and tcp_option_len_th
   tcp: harmonize tcp_vx_rcv header length assumptions

Signed-off-by: William.Allen.Simpson@gmail.com
CC: Andi Kleen <andi@firstfloor.org>
---
  include/linux/tcp.h      |    6 ++-
  include/net/tcp.h        |   15 +++++--
  net/ipv4/tcp_input.c     |   94 ++++++++++++++++++----------------------------
  net/ipv4/tcp_ipv4.c      |    4 +-
  net/ipv4/tcp_minisocks.c |    3 +-
  net/ipv4/tcp_probe.c     |    2 +-
  net/ipv6/tcp_ipv6.c      |    4 +-
  7 files changed, 58 insertions(+), 70 deletions(-)

--------------080302080607070006070604
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2d4+2.6.33-rc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+2d4+2.6.33-rc5.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 74728f7..2987ee8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -301,7 +301,11 @@ struct tcp_sock {
 
 /*
  *	Header prediction flags
- *	0x5?10 << 16 + snd_wnd in net byte order
+ *	S << 28 + TCP_FLAG_ACK + snd_wnd, in net byte order
+ *		(PSH flag is ignored)
+ *		S is 5 (no options), or 8 (timestamp aligned)
+ *	otherwise, 0 to turn it off -- for instance, when there are
+ *	holes in receive space.
  */
 	__be32	pred_flags;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..6b0d7e9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -310,13 +310,11 @@ extern int			tcp_ioctl(struct sock *sk,
 
 extern int			tcp_rcv_state_process(struct sock *sk, 
 						      struct sk_buff *skb,
-						      struct tcphdr *th,
-						      unsigned len);
+						      struct tcphdr *th);
 
 extern int			tcp_rcv_established(struct sock *sk, 
 						    struct sk_buff *skb,
-						    struct tcphdr *th, 
-						    unsigned len);
+						    struct tcphdr *th);
 
 extern void			tcp_rcv_space_adjust(struct sock *sk);
 
@@ -533,9 +531,16 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 	return (tp->srtt >> 3) + tp->rttvar;
 }
 
+static inline u16 __tcp_fast_path_header_length(const struct tcp_sock *tp)
+{
+	return tp->rx_opt.tstamp_ok
+		? sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED
+		: sizeof(struct tcphdr);
+}
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
-	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
+	tp->pred_flags = htonl((__tcp_fast_path_header_length(tp) << (28 - 2)) |
 			       ntohl(TCP_FLAG_ACK) |
 			       snd_wnd);
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28e0296..8e0f6ae 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -152,7 +152,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 			 * tcp header plus fixed timestamp option length.
 			 * Resulting "len" is MSS free of SACK jitter.
 			 */
-			len -= tcp_sk(sk)->tcp_header_len;
+			len -= __tcp_fast_path_header_length(tcp_sk(sk));
 			icsk->icsk_ack.last_seg_size = len;
 			if (len == lss) {
 				icsk->icsk_ack.rcv_mss = len;
@@ -5206,7 +5206,7 @@ discard:
  *	tcp_data_queue when everything is OK.
  */
 int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			struct tcphdr *th, unsigned len)
+			struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int res;
@@ -5225,31 +5225,15 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	 *	extra cost of the net_bh soft interrupt processing...
 	 *	We do checksum and copy also but from device to kernel.
 	 */
-
-	tp->rx_opt.saw_tstamp = 0;
-
-	/*	pred_flags is 0xS?10 << 16 + snd_wnd
-	 *	if header_prediction is to be made
-	 *	'S' will always be tp->tcp_header_len >> 2
-	 *	'?' will be 0 for the fast path, otherwise pred_flags is 0 to
-	 *  turn it off	(when there are holes in the receive
-	 *	 space for instance)
-	 *	PSH flag is ignored.
-	 */
-
 	if ((tcp_flag_word(th) & TCP_HP_BITS) == tp->pred_flags &&
 	    TCP_SKB_CB(skb)->seq == tp->rcv_nxt &&
 	    !after(TCP_SKB_CB(skb)->ack_seq, tp->snd_nxt)) {
-		int tcp_header_len = tp->tcp_header_len;
-
-		/* Timestamp header prediction: tcp_header_len
-		 * is automatically equal to th->doff*4 due to pred_flags
-		 * match.
-		 */
+		int tcp_header_len = tcp_header_len_th(th);
 
-		/* Check timestamp */
-		if (tcp_header_len == sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) {
-			/* No? Slow path! */
+		/* Timestamp header prediction */
+		if (tcp_header_len != sizeof(*th) + TCPOLEN_TSTAMP_ALIGNED) {
+			tp->rx_opt.saw_tstamp = 0; /* false */
+		} else {
 			if (!tcp_parse_aligned_timestamp(tp, th))
 				goto slow_path;
 
@@ -5264,35 +5248,12 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 */
 		}
 
-		if (len <= tcp_header_len) {
-			/* Bulk data transfer: sender */
-			if (len == tcp_header_len) {
-				/* Predicted packet is in window by definition.
-				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
-				 * Hence, check seq<=rcv_wup reduces to:
-				 */
-				if (tcp_header_len ==
-				    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
-				    tp->rcv_nxt == tp->rcv_wup)
-					tcp_store_ts_recent(tp);
-
-				/* We know that such packets are checksummed
-				 * on entry.
-				 */
-				tcp_ack(sk, skb, 0);
-				__kfree_skb(skb);
-				tcp_data_snd_check(sk);
-				return 0;
-			} else { /* Header too small */
-				TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
-				goto discard;
-			}
-		} else {
+		if (tcp_header_len < skb->len) {
 			int eaten = 0;
 			int copied_early = 0;
 
 			if (tp->copied_seq == tp->rcv_nxt &&
-			    len - tcp_header_len <= tp->ucopy.len) {
+			    skb->len - tcp_header_len <= tp->ucopy.len) {
 #ifdef CONFIG_NET_DMA
 				if (tcp_dma_try_early_copy(sk, skb, tcp_header_len)) {
 					copied_early = 1;
@@ -5311,9 +5272,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 					 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 					 * Hence, check seq<=rcv_wup reduces to:
 					 */
-					if (tcp_header_len ==
-					    (sizeof(struct tcphdr) +
-					     TCPOLEN_TSTAMP_ALIGNED) &&
+					if (tp->rx_opt.saw_tstamp &&
 					    tp->rcv_nxt == tp->rcv_wup)
 						tcp_store_ts_recent(tp);
 
@@ -5334,8 +5293,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 				 * Hence, check seq<=rcv_wup reduces to:
 				 */
-				if (tcp_header_len ==
-				    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
+				if (tp->rx_opt.saw_tstamp &&
 				    tp->rcv_nxt == tp->rcv_wup)
 					tcp_store_ts_recent(tp);
 
@@ -5376,11 +5334,33 @@ no_ack:
 			else
 				sk->sk_data_ready(sk, 0);
 			return 0;
+		} else {
+			/* Bulk data transfer: sender
+			 *
+			 * tcp_header_len > skb->len never happens,
+			 * already checked by tcp_v[4,6]_rcv()
+			 *
+			 * Predicted packet is in window by definition.
+			 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
+			 * Hence, check seq<=rcv_wup reduces to:
+			 */
+			if (tp->rx_opt.saw_tstamp &&
+			    tp->rcv_nxt == tp->rcv_wup)
+				tcp_store_ts_recent(tp);
+
+			/* We know that such packets are checksummed
+			 * on entry.
+			 */
+			tcp_ack(sk, skb, 0);
+			__kfree_skb(skb);
+			tcp_data_snd_check(sk);
+			return 0;
 		}
 	}
 
 slow_path:
-	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
+	/* Assumes header and options unchanged since checksum_init() */
+	if (tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
 
 	/*
@@ -5416,7 +5396,7 @@ discard:
 }
 
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
-					 struct tcphdr *th, unsigned len)
+					 struct tcphdr *th)
 {
 	u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5693,7 +5673,7 @@ reset_and_undo:
  */
 
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  struct tcphdr *th, unsigned len)
+			  struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5740,7 +5720,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 
 	case TCP_SYN_SENT:
-		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
+		queued = tcp_rcv_synsent_state_process(sk, skb, th);
 		if (queued >= 0)
 			return queued;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0a76e41..f999e06 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1551,7 +1551,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
+		if (tcp_rcv_established(sk, skb, tcp_hdr(skb))) {
 			rsk = sk;
 			goto reset;
 		}
@@ -1578,7 +1578,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	TCP_CHECK_TIMER(sk);
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
+	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb))) {
 		rsk = sk;
 		goto reset;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f206ee5..37b7536 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -718,8 +718,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	int state = child->sk_state;
 
 	if (!sock_owned_by_user(child)) {
-		ret = tcp_rcv_state_process(child, skb, tcp_hdr(skb),
-					    skb->len);
+		ret = tcp_rcv_state_process(child, skb, tcp_hdr(skb));
 		/* Wakeup parent, send SIGIO */
 		if (state == TCP_SYN_RECV && child->sk_state != state)
 			parent->sk_data_ready(parent, 0);
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index bb110c5..7bcd3ba 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -88,7 +88,7 @@ static inline int tcp_probe_avail(void)
  * Note: arguments must match tcp_rcv_established()!
  */
 static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			       struct tcphdr *th, unsigned len)
+			       struct tcphdr *th)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b76939a..3d08a4d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1586,7 +1586,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
+		if (tcp_rcv_established(sk, skb, tcp_hdr(skb)))
 			goto reset;
 		TCP_CHECK_TIMER(sk);
 		if (opt_skb)
@@ -1618,7 +1618,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	TCP_CHECK_TIMER(sk);
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
+	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb)))
 		goto reset;
 	TCP_CHECK_TIMER(sk);
 	if (opt_skb)
-- 
1.6.3.3


--------------080302080607070006070604--
