From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: fix rcv_ssthresh regression for medium-sized initial packets
Date: Tue, 23 Oct 2012 11:35:45 -0400
Message-ID: <1351006545-12556-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f202.google.com ([209.85.215.202]:39394 "EHLO
	mail-ea0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933030Ab2JWPfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 11:35:53 -0400
Received: by mail-ea0-f202.google.com with SMTP id q10so243546eaa.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 08:35:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent skb truesize fixes caused a slight regression in that
moderately-sized initial incoming packets (eg ~1000 bytes) can now
lead to smaller rcv_ssthresh increments than in 2.6.

The mitigation b49960a05e32121d ("tcp: change tcp_adv_win_scale and
tcp_rmem[2]") compensates for the truesize fixes by fixing the
ultimate value to which receive window converges. But this commit did
not mitigate the impact for the initial cwnd growth phase for
connetions with moderately-sized initial incoming packets. Such
connections still hit the __tcp_grow_window() code path, where the
increment to rcv_sssthresh was by rcv_mss, and not the generally
larger advmss.

We should not handicap this initial growth rate of the receive
window. That way short connections are not penalized in cases where
they wouldn't lead to receive buffer memory consumption issues.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
CC: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 60cf836..e5981a3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -316,7 +316,7 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 
 	while (tp->rcv_ssthresh <= window) {
 		if (truesize <= skb->len)
-			return 2 * inet_csk(sk)->icsk_ack.rcv_mss;
+			return 2 * tp->advmss;
 
 		truesize >>= 1;
 		window >>= 1;
-- 
1.7.7.3
