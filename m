From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/3] tcp: move tcp_update_cwnd_in_recovery
Date: Sun,  2 Sep 2012 20:38:03 -0700
Message-ID: <1346643484-12947-2-git-send-email-ycheng@google.com>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
Cc: mattmathis@google.com, edumazet@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:51420 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755830Ab2ICDiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:38:22 -0400
Received: by bkcjc3 with SMTP id jc3so244659bkc.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 20:38:20 -0700 (PDT)
In-Reply-To: <1346643484-12947-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare replacing rate halving with PRR algorithm in CWR state.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |   64 +++++++++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ab0c75..38589e4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2700,6 +2700,38 @@ static bool tcp_try_undo_loss(struct sock *sk)
 	return false;
 }
 
+/* This function implements the PRR algorithm, specifcally the PRR-SSRB
+ * (proportional rate reduction with slow start reduction bound) as described in
+ * http://www.ietf.org/id/draft-mathis-tcpm-proportional-rate-reduction-01.txt.
+ * It computes the number of packets to send (sndcnt) based on packets newly
+ * delivered:
+ *   1) If the packets in flight is larger than ssthresh, PRR spreads the
+ *	cwnd reductions across a full RTT.
+ *   2) If packets in flight is lower than ssthresh (such as due to excess
+ *	losses and/or application stalls), do not perform any further cwnd
+ *	reductions, but instead slow start up to ssthresh.
+ */
+static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
+					int fast_rexmit, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int sndcnt = 0;
+	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
+
+	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
+		u64 dividend = (u64)tp->snd_ssthresh * tp->prr_delivered +
+			       tp->prior_cwnd - 1;
+		sndcnt = div_u64(dividend, tp->prior_cwnd) - tp->prr_out;
+	} else {
+		sndcnt = min_t(int, delta,
+			       max_t(int, tp->prr_delivered - tp->prr_out,
+				     newly_acked_sacked) + 1);
+	}
+
+	sndcnt = max(sndcnt, (fast_rexmit ? 1 : 0));
+	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
+}
+
 static inline void tcp_complete_cwr(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2854,38 +2886,6 @@ void tcp_simple_retransmit(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_simple_retransmit);
 
-/* This function implements the PRR algorithm, specifcally the PRR-SSRB
- * (proportional rate reduction with slow start reduction bound) as described in
- * http://www.ietf.org/id/draft-mathis-tcpm-proportional-rate-reduction-01.txt.
- * It computes the number of packets to send (sndcnt) based on packets newly
- * delivered:
- *   1) If the packets in flight is larger than ssthresh, PRR spreads the
- *	cwnd reductions across a full RTT.
- *   2) If packets in flight is lower than ssthresh (such as due to excess
- *	losses and/or application stalls), do not perform any further cwnd
- *	reductions, but instead slow start up to ssthresh.
- */
-static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
-					int fast_rexmit, int flag)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int sndcnt = 0;
-	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
-
-	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
-		u64 dividend = (u64)tp->snd_ssthresh * tp->prr_delivered +
-			       tp->prior_cwnd - 1;
-		sndcnt = div_u64(dividend, tp->prior_cwnd) - tp->prr_out;
-	} else {
-		sndcnt = min_t(int, delta,
-			       max_t(int, tp->prr_delivered - tp->prr_out,
-				     newly_acked_sacked) + 1);
-	}
-
-	sndcnt = max(sndcnt, (fast_rexmit ? 1 : 0));
-	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
-}
-
 static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-- 
1.7.7.3
