From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 07:40:41 +0200
Message-ID: <1342762841.2626.5633.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	John Heffner <johnwheffner@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35141 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab2GTFkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 01:40:49 -0400
Received: by weyx8 with SMTP id x8so2301051wey.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 22:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start()

Problem is this RFC 3465 statement is not correctly coded, as
the while () loop increases snd_cwnd one by one.

So to reach the "cwnd += 2" goal, we need to use "cnt = 2*cnt + 1"

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: John Heffner <johnwheffner@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/tcp_cong.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 04dbd7a..486379a 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -306,7 +306,7 @@ EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
  */
 void tcp_slow_start(struct tcp_sock *tp)
 {
-	int cnt; /* increase in packets */
+	unsigned int cnt; /* increase in packets */
 
 	/* RFC3465: ABC Slow start
 	 * Increase only after a full MSS of bytes is acked
@@ -318,16 +318,19 @@ void tcp_slow_start(struct tcp_sock *tp)
 	if (sysctl_tcp_abc && tp->bytes_acked < tp->mss_cache)
 		return;
 
-	if (sysctl_tcp_max_ssthresh > 0 && tp->snd_cwnd > sysctl_tcp_max_ssthresh)
+	cnt = tp->snd_cwnd;			/* exponential increase */
+	if (sysctl_tcp_max_ssthresh > 0 &&
+	    tp->snd_cwnd > sysctl_tcp_max_ssthresh)
 		cnt = sysctl_tcp_max_ssthresh >> 1;	/* limited slow start */
-	else
-		cnt = tp->snd_cwnd;			/* exponential increase */
 
 	/* RFC3465: ABC
 	 * We MAY increase by 2 if discovered delayed ack
+	 * The "+ 1" in the expression is needed if we want to increase
+	 * cwnd by 2, because the way is coded the following loop.
 	 */
 	if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache)
-		cnt <<= 1;
+		cnt = 2*cnt + 1;
+
 	tp->bytes_acked = 0;
 
 	tp->snd_cwnd_cnt += cnt;
