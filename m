From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH] [TCP]: Move clearing of the prior_ssthresh due to ECE
 earlier
Date: Thu, 1 Mar 2007 19:55:41 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703011948330.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2021755102-1172771741=:19465"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43527 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965464AbXCARzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 12:55:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2021755102-1172771741=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Previously the prior_ssthresh was only used in the undo functions
that were called by fastretrans_alert. FRTO processing, however,
happens before that and one of the responses is doing undo too.

I think that after this patch, FRTO should be ECN-safe; only the
undo_cwr response is a suspect anyway. The possible cases:

    1)  Pre-RTO ECE: FRTO is not setting prior_ssthresh in
        CA_CWR at all, therefore it correctly remains cleared
        and ssthresh is the already reduced one

    2a) Post-RTO ECE, before deciding ACK: prior_ssthresh is
        cleared, so no undoing for ssthresh will occur

    2b) Post-RTO ECE, deciding ACK: this patch changes this case
        equal to 2a

    3)  Between two RTOs: prior_ssthresh is cleared like in 2a
        or the reduced value is used like in 1

Deciding ACK is the one after which FRTO declared RTO as
spurious.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

This problem could be solved locally in the undo_cwr response of
FRTO by falling back to ratehalving response when FLAG_ECE is
enabled. If it's more preferrable way, just ping me to get a
patch. I'm not absolutely sure that this does not break anything
even though I couldn't find any using prior_ssthresh between
the new and the old place (seen more than once already within
years that things are not always as simple as they seem).


 net/ipv4/tcp_input.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dc221a3..b0c9dfb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2080,15 +2080,11 @@ tcp_fastretrans_alert(struct sock *sk, u
 		tp->fackets_out = 0;
 
 	/* Now state machine starts.
-	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
-	if (flag&FLAG_ECE)
-		tp->prior_ssthresh = 0;
-
-	/* B. In all the states check for reneging SACKs. */
+	 * A. In all the states check for reneging SACKs. */
 	if (tp->sacked_out && tcp_check_sack_reneging(sk))
 		return;
 
-	/* C. Process data loss notification, provided it is valid. */
+	/* B. Process data loss notification, provided it is valid. */
 	if ((flag&FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
@@ -2097,10 +2093,10 @@ tcp_fastretrans_alert(struct sock *sk, u
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
-	/* D. Synchronize left_out to current state. */
+	/* C. Synchronize left_out to current state. */
 	tcp_sync_left_out(tp);
 
-	/* E. Check state exit conditions. State can be terminated
+	/* D. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
 	if (icsk->icsk_ca_state == TCP_CA_Open) {
 		BUG_TRAP(tp->retrans_out == 0);
@@ -2143,7 +2139,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		}
 	}
 
-	/* F. Process state. */
+	/* E. Process state. */
 	switch (icsk->icsk_ca_state) {
 	case TCP_CA_Recovery:
 		if (prior_snd_una == tp->snd_una) {
@@ -2742,8 +2738,11 @@ static int tcp_ack(struct sock *sk, stru
 		if (TCP_SKB_CB(skb)->sacked)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
 
-		if (TCP_ECN_rcv_ecn_echo(tp, skb->h.th))
+		if (TCP_ECN_rcv_ecn_echo(tp, skb->h.th)) {
 			flag |= FLAG_ECE;
+			/* ECE, prohibit cwnd undoing, reduction is required */
+			tp->prior_ssthresh = 0;
+		}
 
 		tcp_ca_event(sk, CA_EVENT_SLOW_ACK);
 	}
-- 
1.4.2
---696243703-2021755102-1172771741=:19465--
