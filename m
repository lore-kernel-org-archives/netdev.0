From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/9] [TCP]: Cleanup tcp_tso_acked and tcp_clean_rtx_queue
Date: Thu, 20 Sep 2007 15:17:48 +0300
Message-ID: <11902906721671-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi> <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51979 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbXITMRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:55 -0400
In-Reply-To: <1190290672770-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implements following cleanups:
- Comment re-placement (CodingStyle)
- tcp_tso_acked() local (wrapper-like) variable removal
  (readability)
- __-types removed (IMHO they make local variables jumpy looking
  and just was space)
- acked -> flag (naming conventions elsewhere in TCP code)
- linebreak adjustments (readability)
- nested if()s combined (reduced indentation)
- clarifying newlines added

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   66 ++++++++++++++++++++++--------------------=
-------
 1 files changed, 30 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d340fd5..74accb0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2528,55 +2528,49 @@ static void tcp_rearm_rto(struct sock *sk)
 	}
 }
=20
+/* If we get here, the whole TSO packet has not been acked. */
 static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
-	__u32 seq =3D tp->snd_una;
-	__u32 packets_acked;
+	u32 packets_acked;
=20
-	/* If we get here, the whole TSO packet has not been
-	 * acked.
-	 */
-	BUG_ON(!after(scb->end_seq, seq));
+	BUG_ON(!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una));
=20
 	packets_acked =3D tcp_skb_pcount(skb);
-	if (tcp_trim_head(sk, skb, seq - scb->seq))
+	if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
 		return 0;
 	packets_acked -=3D tcp_skb_pcount(skb);
=20
 	if (packets_acked) {
 		BUG_ON(tcp_skb_pcount(skb) =3D=3D 0);
-		BUG_ON(!before(scb->seq, scb->end_seq));
+		BUG_ON(!before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq));
 	}
=20
 	return packets_acked;
 }
=20
-/* Remove acknowledged frames from the retransmission queue. */
-static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
+/* Remove acknowledged frames from the retransmission queue. If our pa=
cket
+ * is before the ack sequence we can discard it as it's confirmed to h=
ave
+ * arrived at the other end.
+ */
+static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct sk_buff *skb;
-	__u32 now =3D tcp_time_stamp;
+	u32 now =3D tcp_time_stamp;
 	int fully_acked =3D 1;
-	int acked =3D 0;
+	int flag =3D 0;
 	int prior_packets =3D tp->packets_out;
-	__s32 seq_rtt =3D -1;
+	s32 seq_rtt =3D -1;
 	ktime_t last_ackt =3D net_invalid_timestamp();
=20
-	while ((skb =3D tcp_write_queue_head(sk)) &&
-	       skb !=3D tcp_send_head(sk)) {
+	while ((skb =3D tcp_write_queue_head(sk)) && skb !=3D tcp_send_head(s=
k)) {
 		struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
 		u32 end_seq;
 		u32 packets_acked;
-		__u8 sacked =3D scb->sacked;
+		u8 sacked =3D scb->sacked;
=20
-		/* If our packet is before the ack sequence we can
-		 * discard it as it's confirmed to have arrived at
-		 * the other end.
-		 */
 		if (after(scb->end_seq, tp->snd_una)) {
 			if (tcp_skb_pcount(skb) =3D=3D 1 ||
 			    !after(tp->snd_una, scb->seq))
@@ -2601,38 +2595,38 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 __s32 *seq_rtt_p)
 		 * quickly.  This is severely frowned upon behavior.
 		 */
 		if (!(scb->flags & TCPCB_FLAG_SYN)) {
-			acked |=3D FLAG_DATA_ACKED;
+			flag |=3D FLAG_DATA_ACKED;
 		} else {
-			acked |=3D FLAG_SYN_ACKED;
+			flag |=3D FLAG_SYN_ACKED;
 			tp->retrans_stamp =3D 0;
 		}
=20
 		/* MTU probing checks */
-		if (fully_acked && icsk->icsk_mtup.probe_size) {
-			if (!after(tp->mtu_probe.probe_seq_end, TCP_SKB_CB(skb)->end_seq)) =
{
-				tcp_mtup_probe_success(sk, skb);
-			}
+		if (fully_acked && icsk->icsk_mtup.probe_size &&
+		    !after(tp->mtu_probe.probe_seq_end, scb->end_seq)) {
+			tcp_mtup_probe_success(sk, skb);
 		}
=20
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
 				if (sacked & TCPCB_SACKED_RETRANS)
 					tp->retrans_out -=3D packets_acked;
-				acked |=3D FLAG_RETRANS_DATA_ACKED;
+				flag |=3D FLAG_RETRANS_DATA_ACKED;
 				seq_rtt =3D -1;
 			} else if (seq_rtt < 0) {
 				seq_rtt =3D now - scb->when;
 				if (fully_acked)
 					last_ackt =3D skb->tstamp;
 			}
+
 			if (sacked & TCPCB_SACKED_ACKED)
 				tp->sacked_out -=3D packets_acked;
 			if (sacked & TCPCB_LOST)
 				tp->lost_out -=3D packets_acked;
-			if (sacked & TCPCB_URG) {
-				if (tp->urg_mode && !before(end_seq, tp->snd_up))
-					tp->urg_mode =3D 0;
-			}
+
+			if ((sacked & TCPCB_URG) && tp->urg_mode &&
+			    !before(end_seq, tp->snd_up))
+				tp->urg_mode =3D 0;
 		} else if (seq_rtt < 0) {
 			seq_rtt =3D now - scb->when;
 			if (fully_acked)
@@ -2648,12 +2642,12 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 __s32 *seq_rtt_p)
 		tcp_clear_all_retrans_hints(tp);
 	}
=20
-	if (acked&FLAG_ACKED) {
+	if (flag & FLAG_ACKED) {
 		u32 pkts_acked =3D prior_packets - tp->packets_out;
 		const struct tcp_congestion_ops *ca_ops
 			=3D inet_csk(sk)->icsk_ca_ops;
=20
-		tcp_ack_update_rtt(sk, acked, seq_rtt);
+		tcp_ack_update_rtt(sk, flag, seq_rtt);
 		tcp_rearm_rto(sk);
=20
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
@@ -2664,7 +2658,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 			s32 rtt_us =3D -1;
=20
 			/* Is the ACK triggering packet unambiguous? */
-			if (!(acked & FLAG_RETRANS_DATA_ACKED)) {
+			if (!(flag & FLAG_RETRANS_DATA_ACKED)) {
 				/* High resolution needed and available? */
 				if (ca_ops->flags & TCP_CONG_RTT_STAMP &&
 				    !ktime_equal(last_ackt,
@@ -2703,7 +2697,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 	}
 #endif
 	*seq_rtt_p =3D seq_rtt;
-	return acked;
+	return flag;
 }
=20
 static void tcp_ack_probe(struct sock *sk)
--=20
1.5.0.6

