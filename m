From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: do not set rtt_min to 1
Date: Thu, 11 Feb 2016 08:58:18 -0800
Message-ID: <1455209898.22120.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35553 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcBKQ6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:58:22 -0500
Received: by mail-wm0-f46.google.com with SMTP id c200so82580263wme.0
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 08:58:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There are some cases where rtt_us derives from deltas of jiffies,
instead of using usec timestamps.

Since we want to track minimal rtt, better to assume a delta of 0 jiffie
might be in fact be very close to 1 jiffie.

It is kind of sad jiffies_to_usecs(1) calls a function instead of simply
using a constant.

Fixes: f672258391b42 ("tcp: track min RTT using windowed min-filter")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5ee6fe0d152d..e6e65f79ade8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2907,7 +2907,10 @@ static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
 {
 	const u32 now = tcp_time_stamp, wlen = sysctl_tcp_min_rtt_wlen * HZ;
 	struct rtt_meas *m = tcp_sk(sk)->rtt_min;
-	struct rtt_meas rttm = { .rtt = (rtt_us ? : 1), .ts = now };
+	struct rtt_meas rttm = {
+		.rtt = likely(rtt_us) ? rtt_us : jiffies_to_usecs(1),
+		.ts = now,
+	};
 	u32 elapsed;
 
 	/* Check if the new measurement updates the 1st, 2nd, or 3rd choices */
