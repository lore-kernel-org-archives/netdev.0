From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] dctcp: update cwnd on congestion event
Date: Mon, 14 Nov 2016 16:42:01 +0100
Message-ID: <1479138121-32294-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Lawrence Brakmo <brakmo@fb.com>,
        Andrew Shewmaker <agshew@gmail.com>,
        Glenn Judd <glenn.judd@morganstanley.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38458 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933349AbcKNPmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:42:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

draft-ietf-tcpm-dctcp-02 says:

... when the sender receives an indication of congestion
(ECE), the sender SHOULD update cwnd as follows:

         cwnd = cwnd * (1 - DCTCP.Alpha / 2)

So, lets do this and reduce cwnd more smoothly (and faster), as per
current congestion estimate.

Cc: Lawrence Brakmo <brakmo@fb.com>
Cc: Andrew Shewmaker <agshew@gmail.com>
Cc: Glenn Judd <glenn.judd@morganstanley.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index ab37c6775630..51139175bf61 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -188,8 +188,8 @@ static void dctcp_ce_state_1_to_0(struct sock *sk)
 
 static void dctcp_update_alpha(struct sock *sk, u32 flags)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
 	struct dctcp *ca = inet_csk_ca(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	u32 acked_bytes = tp->snd_una - ca->prior_snd_una;
 
 	/* If ack did not advance snd_una, count dupack as MSS size.
@@ -229,6 +229,13 @@ static void dctcp_update_alpha(struct sock *sk, u32 flags)
 		WRITE_ONCE(ca->dctcp_alpha, alpha);
 		dctcp_reset(tp, ca);
 	}
+
+	if (flags & CA_ACK_ECE) {
+		unsigned int cwnd = dctcp_ssthresh(sk);
+
+		if (cwnd != tp->snd_cwnd)
+			tp->snd_cwnd = cwnd;
+	}
 }
 
 static void dctcp_state(struct sock *sk, u8 new_state)
-- 
2.7.3
