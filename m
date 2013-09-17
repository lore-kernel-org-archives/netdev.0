From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix RTO calculated from cached RTT
Date: Mon, 16 Sep 2013 21:44:20 -0400
Message-ID: <1379382260-29303-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:37381 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3IQBte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:49:34 -0400
Received: by mail-qa0-f73.google.com with SMTP id cm18so333466qab.2
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 18:49:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1b7fdd2ab5852 ("tcp: do not use cached RTT for RTT estimation")
did not correctly account for the fact that crtt is the RTT shifted
left 3 bits. Fix the calculation to consistently reflect this fact.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_metrics.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4a22f3e..52f3c6b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -502,7 +502,9 @@ reset:
 	 * ACKs, wait for troubles.
 	 */
 	if (crtt > tp->srtt) {
-		inet_csk(sk)->icsk_rto = crtt + max(crtt >> 2, tcp_rto_min(sk));
+		/* Set RTO like tcp_rtt_estimator(), but from cached RTT. */
+		crtt >>= 3;
+		inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));
 	} else if (tp->srtt == 0) {
 		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
 		 * 3WHS. This is most likely due to retransmission,
-- 
1.8.4
