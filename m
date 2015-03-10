From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 1/2] tcp: fix tcp_cong_avoid_ai() credit accumulation bug with decreases in w
Date: Tue, 10 Mar 2015 17:17:03 -0400
Message-ID: <1426022224-28793-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:40017 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbCJVRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 17:17:10 -0400
Received: by ykq142 with SMTP id 142so2046002ykq.7
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 14:17:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent change to tcp_cong_avoid_ai() to handle stretch ACKs
introduced a bug where snd_cwnd_cnt could accumulate a very large
value while w was large, and then if w was reduced snd_cwnd could be
incremented by a large delta, leading to a large burst and high packet
loss. This was tickled when CUBIC's bictcp_update() sets "ca->cnt =
100 * cwnd".

This bug crept in while preparing the upstream version of
814d488c6126.

Testing: This patch has been tested in datacenter netperf transfers
and live youtube.com and google.com servers.

Fixes: 814d488c6126 ("tcp: fix the timid additive increase on stretch ACKs")
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index d694088..62856e1 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -378,6 +378,12 @@ EXPORT_SYMBOL_GPL(tcp_slow_start);
  */
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked)
 {
+	/* If credits accumulated at a higher w, apply them gently now. */
+	if (tp->snd_cwnd_cnt >= w) {
+		tp->snd_cwnd_cnt = 0;
+		tp->snd_cwnd++;
+	}
+
 	tp->snd_cwnd_cnt += acked;
 	if (tp->snd_cwnd_cnt >= w) {
 		u32 delta = tp->snd_cwnd_cnt / w;
-- 
2.2.0.rc0.207.ga3a616c
