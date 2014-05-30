From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix cwnd undo on DSACK in F-RTO
Date: Fri, 30 May 2014 15:25:59 -0700
Message-ID: <1401488759-22637-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:56163 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934204AbaE3W0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:26:42 -0400
Received: by mail-yh0-f73.google.com with SMTP id f73so550175yha.2
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 15:26:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug is discovered by an recent F-RTO issue on tcpm list
https://www.ietf.org/mail-archive/web/tcpm/current/msg08794.html

The bug is that currently F-RTO does not use DSACK to undo cwnd in
certain cases: upon receiving an ACK after the RTO retransmission in
F-RTO, and the ACK has DSACK indicating the retransmission is spurious,
the sender only calls tcp_try_undo_loss() if some never retransmisted
data is sacked (FLAG_ORIG_DATA_SACKED).

The correct behavior is to unconditionally call tcp_try_undo_loss so
the DSACK information is used properly to undo the cwnd reduction.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6b46eb..3a26b3b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2684,13 +2684,12 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 	bool recovered = !before(tp->snd_una, tp->high_seq);
 
 	if (tp->frto) { /* F-RTO RFC5682 sec 3.1 (sack enhanced version). */
-		if (flag & FLAG_ORIG_SACK_ACKED) {
-			/* Step 3.b. A timeout is spurious if not all data are
-			 * lost, i.e., never-retransmitted data are (s)acked.
-			 */
-			tcp_try_undo_loss(sk, true);
+		/* Step 3.b. A timeout is spurious if not all data are
+		 * lost, i.e., never-retransmitted data are (s)acked.
+		 */
+		if (tcp_try_undo_loss(sk, flag & FLAG_ORIG_SACK_ACKED))
 			return;
-		}
+
 		if (after(tp->snd_nxt, tp->high_seq) &&
 		    (flag & FLAG_DATA_SACKED || is_dupack)) {
 			tp->frto = 0; /* Loss was real: 2nd part of step 3.a */
-- 
1.9.1.423.g4596e3a
