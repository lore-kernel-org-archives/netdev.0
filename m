From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/3 net-next] tcp: refactor CA_Loss state processing
Date: Wed,  6 Mar 2013 12:52:09 -0800
Message-ID: <1362603130-16501-2-git-send-email-ycheng@google.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
Cc: ilpo.jarvinen@cs.helsinki.fi, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:61782 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3CFUwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:52:21 -0500
Received: by mail-ye0-f201.google.com with SMTP id m12so914126yen.2
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 12:52:21 -0800 (PST)
In-Reply-To: <1362603130-16501-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate all of TCP CA_Loss state processing in
tcp_fastretrans_alert() into a new function called tcp_process_loss().
This is to prepare the new F-RTO implementation in the next patch.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9933b6b..07a05e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2662,6 +2662,30 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 	tcp_set_ca_state(sk, TCP_CA_Recovery);
 }
 
+/* Process an ACK in CA_Loss state. Move to CA_Open if lost data are
+ * recovered or spurious. Otherwise retransmits more on partial ACKs.
+ */
+static void tcp_process_loss(struct sock *sk, int flag)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (!before(tp->snd_una, tp->high_seq)) {
+		icsk->icsk_retransmits = 0;
+		tcp_try_undo_recovery(sk);
+		return;
+	}
+
+	if (flag & FLAG_DATA_ACKED)
+		icsk->icsk_retransmits = 0;
+	if (tcp_is_reno(tp) && flag & FLAG_SND_UNA_ADVANCED)
+		tcp_reset_reno_sack(tp);
+	if (tcp_try_undo_loss(sk))
+		return;
+	tcp_moderate_cwnd(tp);
+	tcp_xmit_retransmit_queue(sk);
+}
+
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_out,
  * taking into account both packets sitting in receiver's buffer and
@@ -2708,12 +2732,6 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 		tp->retrans_stamp = 0;
 	} else if (!before(tp->snd_una, tp->high_seq)) {
 		switch (icsk->icsk_ca_state) {
-		case TCP_CA_Loss:
-			icsk->icsk_retransmits = 0;
-			if (tcp_try_undo_recovery(sk))
-				return;
-			break;
-
 		case TCP_CA_CWR:
 			/* CWR is to be held something *above* high_seq
 			 * is ACKed for CWR bit to reach receiver. */
@@ -2744,18 +2762,10 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 		newly_acked_sacked = pkts_acked + tp->sacked_out - prior_sacked;
 		break;
 	case TCP_CA_Loss:
-		if (flag & FLAG_DATA_ACKED)
-			icsk->icsk_retransmits = 0;
-		if (tcp_is_reno(tp) && flag & FLAG_SND_UNA_ADVANCED)
-			tcp_reset_reno_sack(tp);
-		if (!tcp_try_undo_loss(sk)) {
-			tcp_moderate_cwnd(tp);
-			tcp_xmit_retransmit_queue(sk);
-			return;
-		}
+		tcp_process_loss(sk, flag);
 		if (icsk->icsk_ca_state != TCP_CA_Open)
 			return;
-		/* Loss is undone; fall through to processing in Open state. */
+		/* Fall through to processing in Open state. */
 	default:
 		if (tcp_is_reno(tp)) {
 			if (flag & FLAG_SND_UNA_ADVANCED)
-- 
1.8.1.3
