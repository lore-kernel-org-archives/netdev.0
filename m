From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 2/2] tcp: restore 1.5x per RTT limit to CUBIC cwnd growth in congestion avoidance
Date: Tue, 10 Mar 2015 17:17:04 -0400
Message-ID: <1426022224-28793-2-git-send-email-ncardwell@google.com>
References: <1426022224-28793-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:42679 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbCJVRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 17:17:12 -0400
Received: by ykbq9 with SMTP id q9so2036435ykb.9
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 14:17:12 -0700 (PDT)
In-Reply-To: <1426022224-28793-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 814d488c6126 ("tcp: fix the timid additive increase on stretch
ACKs") fixed a bug where tcp_cong_avoid_ai() would either credit a
connection with an increase of snd_cwnd_cnt, or increase snd_cwnd, but
not both, resulting in cwnd increasing by 1 packet on at most every
alternate invocation of tcp_cong_avoid_ai().

Although the commit correctly implemented the CUBIC algorithm, which
can increase cwnd by as much as 1 packet per 1 packet ACKed (2x per
RTT), in practice that could be too aggressive: in tests on network
paths with small buffers, YouTube server retransmission rates nearly
doubled.

This commit restores CUBIC to a maximum cwnd growth rate of 1 packet
per 2 packets ACKed (1.5x per RTT). In YouTube tests this restored
retransmit rates to low levels.

Testing: This patch has been tested in datacenter netperf transfers
and live youtube.com and google.com servers.

Fixes: 9cd981dcf174 ("tcp: fix stretch ACK bugs in CUBIC")
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cubic.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 4b276d1..06d3d66 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -306,8 +306,10 @@ tcp_friendliness:
 		}
 	}
 
-	if (ca->cnt == 0)			/* cannot be zero */
-		ca->cnt = 1;
+	/* The maximum rate of cwnd increase CUBIC allows is 1 packet per
+	 * 2 packets ACKed, meaning cwnd grows at 1.5x per RTT.
+	 */
+	ca->cnt = max(ca->cnt, 2U);
 }
 
 static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
-- 
2.2.0.rc0.207.ga3a616c
