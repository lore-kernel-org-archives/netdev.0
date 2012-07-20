From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 17:02:33 +0200
Message-ID: <1342796553.2626.7389.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46092 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab2GTPCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:02:39 -0400
Received: by bkwj10 with SMTP id j10so3469902bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 08:02:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start()

Problem is this RFC 3465 statement is not correctly coded, as
the while () loop increases snd_cwnd one by one.

Add a new variable to avoid this off-by one error.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: John Heffner <johnwheffner@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---
v2: added John suggestion

 net/ipv4/tcp_cong.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 04dbd7a..4d4db16 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -307,6 +307,7 @@ EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
 void tcp_slow_start(struct tcp_sock *tp)
 {
 	int cnt; /* increase in packets */
+	unsigned int delta = 0;
 
 	/* RFC3465: ABC Slow start
 	 * Increase only after a full MSS of bytes is acked
@@ -333,9 +334,9 @@ void tcp_slow_start(struct tcp_sock *tp)
 	tp->snd_cwnd_cnt += cnt;
 	while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
 		tp->snd_cwnd_cnt -= tp->snd_cwnd;
-		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-			tp->snd_cwnd++;
+		delta++;
 	}
+	tp->snd_cwnd = min(tp->snd_cwnd + delta, tp->snd_cwnd_clamp);
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
