From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2] tcp: input header length, prediction, and timestamp bugs
Date: Fri, 15 Jan 2010 14:20:28 -0500
Message-ID: <4B50BFFC.8010108@gmail.com>
References: <4B49C2D0.1070704@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804030308080208070204"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:34417 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0AOTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 14:20:35 -0500
In-Reply-To: <4B49C2D0.1070704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040804030308080208070204
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Fix incorrect header prediction flags documentation.

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
the same header length.  (This bug is in 3 places.)

Instead, use tp->rx_opt.saw_tstamp to determine a timestamp is present.

There's no need to test buffer length against header length, already
checked by tcp_v[4,6]_rcv(). Straighten code for minor efficiency gain.

Stand-alone patch, originally developed for TCPCT.

Requires:
   net: tcp_header_len_th and tcp_option_len_th
   tcp: harmonize tcp_vx_rcv header length assumptions

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h  |    6 +++-
  include/net/tcp.h    |    9 +++++-
  net/ipv4/tcp_input.c |   84 +++++++++++++++++++-------------------------------
  3 files changed, 45 insertions(+), 54 deletions(-)

--------------040804030308080208070204
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+4v2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+4v2.patch"

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
index 34f5cc2..30817b1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -533,9 +533,16 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
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
index 28e0296..0aa2254 100644
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
 
@@ -5264,30 +5248,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
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
+		if (tcp_header_len < len) {
 			int eaten = 0;
 			int copied_early = 0;
 
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
+			 * tcp_header_len > len never happens,
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
-- 
1.6.3.3


--------------040804030308080208070204--
