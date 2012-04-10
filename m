From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT sample
Date: Tue, 10 Apr 2012 13:59:20 -0400
Message-ID: <1334080760-968-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:52320 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438Ab2DJR72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 13:59:28 -0400
Received: by yhgm50 with SMTP id m50so9900yhg.1
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 10:59:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a code path in tcp_rcv_rtt_update() that was comparing scaled and
unscaled RTT samples.

The intent in the code was to only use the 'm' measurement if it was a
new minimum.  However, since 'm' had not yet been shifted left 3 bits
but 'new_sample' had, this comparison would nearly always succeed,
leading us to erroneously set our receive-side RTT estimate to the 'm'
sample when that sample could be nearly 8x too high to use.

The overall effect is to often cause the receive-side RTT estimate to
be significantly too large (up to 40% too large for brief periods in
my tests).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..e7b54d2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -474,8 +474,11 @@ static void tcp_rcv_rtt_update(struct tcp_sock *tp, u32 sample, int win_dep)
 		if (!win_dep) {
 			m -= (new_sample >> 3);
 			new_sample += m;
-		} else if (m < new_sample)
-			new_sample = m << 3;
+		} else {
+			m <<= 3;
+			if (m < new_sample)
+				new_sample = m;
+		}
 	} else {
 		/* No previous measure. */
 		new_sample = m << 3;
-- 
1.7.7.3
