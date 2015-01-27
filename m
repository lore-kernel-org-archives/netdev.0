From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 3/5] tcp: fix stretch ACK bugs in Reno
Date: Tue, 27 Jan 2015 15:34:41 -0500
Message-ID: <1422390883-15603-4-git-send-email-ncardwell@google.com>
References: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:50965 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759979AbbA0UfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:35:04 -0500
Received: by mail-yk0-f169.google.com with SMTP id 200so7298005ykr.0
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:35:04 -0800 (PST)
In-Reply-To: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Reno to properly handle stretch ACKs in additive increase mode
by passing in the count of ACKed packets to tcp_cong_avoid_ai().

In addition, if snd_cwnd crosses snd_ssthresh during slow start
processing, and we then exit slow start mode, we need to carry over
any remaining "credit" for packets ACKed and apply that to additive
increase by passing this remaining "acked" count to
tcp_cong_avoid_ai().

Reported-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index ec78f56..319718d 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -404,11 +404,13 @@ void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		return;
 
 	/* In "safe" area, increase. */
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
-		tcp_slow_start(tp, acked);
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		acked = tcp_slow_start(tp, acked);
+		if (!acked)
+			return;
+	}
 	/* In dangerous area, increase slowly. */
-	else
-		tcp_cong_avoid_ai(tp, tp->snd_cwnd, 1);
+	tcp_cong_avoid_ai(tp, tp->snd_cwnd, acked);
 }
 EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
 
-- 
2.2.0.rc0.207.ga3a616c
