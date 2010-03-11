From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v6 4/7] tcp: input header length, prediction, and timestamp
 bugs
Date: Thu, 11 Mar 2010 07:24:56 -0500
Message-ID: <4B98E118.2030207@gmail.com>
References: <4B98D592.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050306000706000208060708"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B98D592.6040301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050306000706000208060708
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
Reviewed-by: Andi Kleen <andi@firstfloor.org>
---
  include/linux/tcp.h      |    6 ++-
  include/net/tcp.h        |   18 ++++++--
  net/ipv4/tcp_input.c     |   96 +++++++++++++++++++---------------------------
  net/ipv4/tcp_ipv4.c      |    4 +-
  net/ipv4/tcp_minisocks.c |    3 +-
  net/ipv4/tcp_probe.c     |    2 +-
  net/ipv6/tcp_ipv6.c      |    4 +-
  7 files changed, 63 insertions(+), 70 deletions(-)

--------------050306000706000208060708
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2d6+2.6.34-rc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="len_th+2d6+2.6.34-rc1.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 854ad65..a97ca8f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -303,7 +303,11 @@ struct tcp_sock {
 
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
index 56f0aec..ff2f1c3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -315,13 +315,11 @@ extern int			tcp_ioctl(struct sock *sk,
 
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
 
@@ -540,9 +538,19 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 	return (tp->srtt >> 3) + tp->rttvar;
 }
 
+static inline u8 __tcp_fast_path_header_length(const struct tcp_sock *tp)
+{
+	return tp->rx_opt.tstamp_ok
+		? sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED
+		: sizeof(struct tcphdr);
+}
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
-	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
+	/* See linux/tcp.h for pred_flags details.
+	 * 'S' (doff) is 32-bit words, convert from bytes: 26 = 28 - 2.
+	 */
+	tp->pred_flags = htonl((__tcp_fast_path_header_length(tp) << 26) |
 			       ntohl(TCP_FLAG_ACK) |
 			       snd_wnd);
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 788851c..5541d08 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -154,7 +154,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 			 * tcp header plus fixed timestamp option length.
 			 * Resulting "len" is MSS free of SACK jitter.
 			 */
-			len -= tcp_sk(sk)->tcp_header_len;
+			len -= __tcp_fast_path_header_length(tcp_sk(sk));
 			icsk->icsk_ack.last_seg_size = len;
 			if (len == lss) {
 				icsk->icsk_ack.rcv_mss = len;
@@ -5218,7 +5218,7 @@ discard:
  *	tcp_data_queue when everything is OK.
  */
 int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			struct tcphdr *th, unsigned len)
+			struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int res;
@@ -5236,32 +5236,18 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	 *	Our current scheme is not silly either but we take the
 	 *	extra cost of the net_bh soft interrupt processing...
 	 *	We do checksum and copy also but from device to kernel.
+	 *
+	 *	See linux/tcp.h and net/tcp.h for pred_flags details.
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
 
@@ -5276,35 +5262,12 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
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
@@ -5323,9 +5286,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 					 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 					 * Hence, check seq<=rcv_wup reduces to:
 					 */
-					if (tcp_header_len ==
-					    (sizeof(struct tcphdr) +
-					     TCPOLEN_TSTAMP_ALIGNED) &&
+					if (tp->rx_opt.saw_tstamp &&
 					    tp->rcv_nxt == tp->rcv_wup)
 						tcp_store_ts_recent(tp);
 
@@ -5346,8 +5307,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
 				 * Hence, check seq<=rcv_wup reduces to:
 				 */
-				if (tcp_header_len ==
-				    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
+				if (tp->rx_opt.saw_tstamp &&
 				    tp->rcv_nxt == tp->rcv_wup)
 					tcp_store_ts_recent(tp);
 
@@ -5388,11 +5348,33 @@ no_ack:
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
+	/* Assumes skb->len includes header and options */
+	if (tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
 
 	/*
@@ -5428,7 +5410,7 @@ discard:
 }
 
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
-					 struct tcphdr *th, unsigned len)
+					 struct tcphdr *th)
 {
 	u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5705,7 +5687,7 @@ reset_and_undo:
  */
 
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  struct tcphdr *th, unsigned len)
+			  struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5752,7 +5734,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 
 	case TCP_SYN_SENT:
-		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
+		queued = tcp_rcv_synsent_state_process(sk, skb, th);
 		if (queued >= 0)
 			return queued;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c206024..1860590 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1553,7 +1553,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
+		if (tcp_rcv_established(sk, skb, tcp_hdr(skb))) {
 			rsk = sk;
 			goto reset;
 		}
@@ -1580,7 +1580,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
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
index 9bc805d..de2a32e 100644
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
index 04814bf..39e0d89 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1594,7 +1594,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
+		if (tcp_rcv_established(sk, skb, tcp_hdr(skb)))
 			goto reset;
 		TCP_CHECK_TIMER(sk);
 		if (opt_skb)
@@ -1626,7 +1626,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	TCP_CHECK_TIMER(sk);
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
+	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb)))
 		goto reset;
 	TCP_CHECK_TIMER(sk);
 	if (opt_skb)
-- 
1.6.3.3


--------------050306000706000208060708--
