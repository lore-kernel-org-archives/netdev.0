From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH] tcp: input header length, prediction, and timestamp bugs
Date: Fri, 15 Jan 2010 09:16:27 -0500
Message-ID: <4B5078BB.40306@gmail.com>
References: <4B49C2D0.1070704@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020106090607040600050909"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:47877 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757525Ab0AOOQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 09:16:36 -0500
In-Reply-To: <4B49C2D0.1070704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020106090607040600050909
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
the same header length.

Instead, use tp->rx_opt.saw_tstamp to determine a timestamp is present.
(This bug is in 3 places.)

There's no need to test buffer length against header length, already
checked by tcp_v[4,6]_rcv(). Straighten code for minor efficiency gain.

Don't overload tp->tcp_header_len by temporarily storing predicted
header length. It's wiped later by the output code, and very confusing.

Instead, the simpler __tcp_fast_path_header_length() can also be used
for the same purpose, at the cost of a branch, but the substantial
savings of removing the extra store and re-load.

Finally, don't use TCPOLEN_MD5SIG_ALIGNED in the tcp_minisock.c
last_seg_size calculations. It's not used in all other places, and may
result in a too short estimate.

Instead, use the same calculations as tp->advmss in tcp_input.c.

Stand-alone patch, originally developed for TCPCT.

Requires:
   net: tcp_header_len_th and tcp_option_len_th
   tcp: harmonize tcp_vx_rcv header length assumptions

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h      |    6 ++-
  include/net/tcp.h        |    9 ++++-
  net/ipv4/tcp_input.c     |   92 ++++++++++++++++------------------------------
  net/ipv4/tcp_minisocks.c |   10 ++---
  4 files changed, 49 insertions(+), 68 deletions(-)

--------------020106090607040600050909
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+4v1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+4v1.patch"

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
index 28e0296..3378883 100644
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
+			 * len < tcp_header_len never happens,
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
@@ -5502,12 +5482,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		if (tp->rx_opt.saw_tstamp) {
 			tp->rx_opt.tstamp_ok	   = 1;
-			tp->tcp_header_len =
-				sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED;
 			tp->advmss	    -= TCPOLEN_TSTAMP_ALIGNED;
 			tcp_store_ts_recent(tp);
-		} else {
-			tp->tcp_header_len = sizeof(struct tcphdr);
 		}
 
 		if (tcp_is_sack(tp) && sysctl_tcp_fack)
@@ -5632,10 +5608,6 @@ discard:
 		if (tp->rx_opt.saw_tstamp) {
 			tp->rx_opt.tstamp_ok = 1;
 			tcp_store_ts_recent(tp);
-			tp->tcp_header_len =
-				sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED;
-		} else {
-			tp->tcp_header_len = sizeof(struct tcphdr);
 		}
 
 		tp->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f206ee5..d57a7da 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,6 +387,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *newtp = tcp_sk(newsk);
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
+		int lss = skb->len - sizeof(struct tcphdr);
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
@@ -490,18 +491,15 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		if (newtp->rx_opt.tstamp_ok) {
 			newtp->rx_opt.ts_recent = req->ts_recent;
 			newtp->rx_opt.ts_recent_stamp = get_seconds();
-			newtp->tcp_header_len = sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED;
+			lss -= TCPOLEN_TSTAMP_ALIGNED;
 		} else {
 			newtp->rx_opt.ts_recent_stamp = 0;
-			newtp->tcp_header_len = sizeof(struct tcphdr);
 		}
 #ifdef CONFIG_TCP_MD5SIG
 		newtp->md5sig_info = NULL;	/*XXX*/
-		if (newtp->af_specific->md5_lookup(sk, newsk))
-			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
 #endif
-		if (skb->len >= TCP_MSS_DEFAULT + newtp->tcp_header_len)
-			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
+		if (lss >= TCP_MSS_DEFAULT)
+			newicsk->icsk_ack.last_seg_size = lss;
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 
-- 
1.6.3.3


--------------020106090607040600050909--
