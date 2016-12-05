From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] Revert "dctcp: update cwnd on congestion event"
Date: Tue,  6 Dec 2016 00:23:00 +0100
Message-ID: <1480980180-23349-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Neal Cardwell <ncardwell@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:40014 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753380AbcLEXWo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 18:22:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neal Cardwell says:
 If I am reading the code correctly, then I would have two concerns:
 1) Has that been tested? That seems like an extremely dramatic
    decrease in cwnd. For example, if the cwnd is 80, and there are 40
    ACKs, and half the ACKs are ECE marked, then my back-of-the-envelope
    calculations seem to suggest that after just 11 ACKs the cwnd would be
    down to a minimal value of 2 [..]
 2) That seems to contradict another passage in the draft [..] where it
    sazs:
       Just as specified in [RFC3168], DCTCP does not react to congestion
       indications more than once for every window of data.

Neal is right.  Fortunately we don't have to complicate this by testing
vs. current rtt estimate, we can just revert the patch.

Normal stack already handles this for us: receiving ACKs with ECE
set causes a call to tcp_enter_cwr(), from there on the ssthresh gets
adjusted and prr will take care of cwnd adjustment.

Fixes: 4780566784b396 ("dctcp: update cwnd on congestion event")
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_dctcp.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index bde22ebb92a8..5f5e5936760e 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -188,8 +188,8 @@ static void dctcp_ce_state_1_to_0(struct sock *sk)
 
 static void dctcp_update_alpha(struct sock *sk, u32 flags)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct dctcp *ca = inet_csk_ca(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
 	u32 acked_bytes = tp->snd_una - ca->prior_snd_una;
 
 	/* If ack did not advance snd_una, count dupack as MSS size.
@@ -229,13 +229,6 @@ static void dctcp_update_alpha(struct sock *sk, u32 flags)
 		WRITE_ONCE(ca->dctcp_alpha, alpha);
 		dctcp_reset(tp, ca);
 	}
-
-	if (flags & CA_ACK_ECE) {
-		unsigned int cwnd = dctcp_ssthresh(sk);
-
-		if (cwnd != tp->snd_cwnd)
-			tp->snd_cwnd = cwnd;
-	}
 }
 
 static void dctcp_state(struct sock *sk, u8 new_state)
-- 
2.7.3
