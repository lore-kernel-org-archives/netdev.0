From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next v2 2/5] tcp: fix the timid additive increase on stretch ACKs
Date: Wed, 28 Jan 2015 20:01:36 -0500
Message-ID: <1422493299-22114-3-git-send-email-ncardwell@google.com>
References: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:60428 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbA2BHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:07:18 -0500
Received: by mail-yk0-f169.google.com with SMTP id 200so10938253ykr.0
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:07:18 -0800 (PST)
In-Reply-To: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_cong_avoid_ai() was too timid (snd_cwnd increased too slowly) on
"stretch ACKs" -- cases where the receiver ACKed more than 1 packet in
a single ACK. For example, suppose w is 10 and we get a stretch ACK
for 20 packets, so acked is 20. We ought to increase snd_cwnd by 2
(since acked/w = 20/10 = 2), but instead we were only increasing cwnd
by 1. This patch fixes that behavior.

Reported-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 60bc170..389fe7a 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -373,16 +373,19 @@ u32 tcp_slow_start(struct tcp_sock *tp, u32 acked)
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
-/* In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd (or alternative w) */
+/* In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd (or alternative w),
+ * for every packet that was ACKed.
+ */
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked)
 {
+	tp->snd_cwnd_cnt += acked;
 	if (tp->snd_cwnd_cnt >= w) {
-		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-			tp->snd_cwnd++;
-		tp->snd_cwnd_cnt = 0;
-	} else {
-		tp->snd_cwnd_cnt += acked;
+		u32 delta = tp->snd_cwnd_cnt / w;
+
+		tp->snd_cwnd_cnt -= delta * w;
+		tp->snd_cwnd += delta;
 	}
+	tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_cwnd_clamp);
 }
 EXPORT_SYMBOL_GPL(tcp_cong_avoid_ai);
 
-- 
2.2.0.rc0.207.ga3a616c
