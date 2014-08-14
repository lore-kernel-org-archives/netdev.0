From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix ssthresh and undo for consecutive short FRTO episodes
Date: Thu, 14 Aug 2014 16:13:07 -0400
Message-ID: <1408047187-983-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:38944 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbaHNUVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 16:21:16 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so196418yhl.3
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 13:21:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix TCP FRTO logic so that it always notices when snd_una advances,
indicating that any RTO after that point will be a new and distinct
loss episode.

Previously there was a very specific sequence that could cause FRTO to
fail to notice a new loss episode had started:

(1) RTO timer fires, enter FRTO and retransmit packet 1 in write queue
(2) receiver ACKs packet 1
(3) FRTO sends 2 more packets
(4) RTO timer fires again (should start a new loss episode)

The problem was in step (3) above, where tcp_process_loss() returned
early (in the spot marked "Step 2.b"), so that it never got to the
logic to clear icsk_retransmits. Thus icsk_retransmits stayed
non-zero. Thus in step (4) tcp_enter_loss() would see the non-zero
icsk_retransmits, decide that this RTO is not a new episode, and
decide not to cut ssthresh and remember the current cwnd and ssthresh
for undo.

There were two main consequences to the bug that we have
observed. First, ssthresh was not decreased in step (4). Second, when
there was a series of such FRTO (1-4) sequences that happened to be
followed by an FRTO undo, we would restore the cwnd and ssthresh from
before the entire series started (instead of the cwnd and ssthresh
from before the most recent RTO). This could result in cwnd and
ssthresh being restored to values much bigger than the proper values.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Fixes: e33099f96d99c ("tcp: implement RFC5682 F-RTO")
---
 net/ipv4/tcp_input.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1a8e89f..148d968 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2687,7 +2687,6 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
  */
 static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 {
-	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool recovered = !before(tp->snd_una, tp->high_seq);
 
@@ -2713,12 +2712,9 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 
 	if (recovered) {
 		/* F-RTO RFC5682 sec 3.1 step 2.a and 1st part of step 3.a */
-		icsk->icsk_retransmits = 0;
 		tcp_try_undo_recovery(sk);
 		return;
 	}
-	if (flag & FLAG_DATA_ACKED)
-		icsk->icsk_retransmits = 0;
 	if (tcp_is_reno(tp)) {
 		/* A Reno DUPACK means new data in F-RTO step 2.b above are
 		 * delivered. Lower inflight to clock out (re)tranmissions.
@@ -3405,8 +3401,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)
 		tcp_rearm_rto(sk);
 
-	if (after(ack, prior_snd_una))
+	if (after(ack, prior_snd_una)) {
 		flag |= FLAG_SND_UNA_ADVANCED;
+		icsk->icsk_retransmits = 0;
+	}
 
 	prior_fackets = tp->fackets_out;
 
-- 
2.1.0.rc2.206.gedb03e5
