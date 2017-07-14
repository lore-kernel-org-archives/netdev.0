From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 4/5] tcp_bbr: remove sk_pacing_rate=0 transient during init
Date: Fri, 14 Jul 2017 17:49:24 -0400
Message-ID: <20170714214925.30720-4-ncardwell@google.com>
References: <20170714214925.30720-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33471 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdGNVtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 17:49:47 -0400
Received: by mail-qk0-f182.google.com with SMTP id a66so71982990qkb.0
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 14:49:47 -0700 (PDT)
In-Reply-To: <20170714214925.30720-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a corner case noticed by Eric Dumazet, where BBR's setting
sk->sk_pacing_rate to 0 during initialization could theoretically
cause packets in the sending host to hang if there were packets "in
flight" in the pacing infrastructure at the time the BBR congestion
control state is initialized. This could occur if the pacing
infrastructure happened to race with bbr_init() in a way such that the
pacer read the 0 rather than the immediately following non-zero pacing
rate.

Fixes: 0f8782ea1497 ("tcp_bbr: add BBR congestion control")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_bbr.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 3276140c2506..42e0017f2ebc 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -837,7 +837,6 @@ static void bbr_init(struct sock *sk)
 
 	minmax_reset(&bbr->bw, bbr->rtt_cnt, 0);  /* init max bw to 0 */
 
-	sk->sk_pacing_rate = 0;		/* force an update of sk_pacing_rate */
 	bbr_init_pacing_rate_from_rtt(sk);
 
 	bbr->restore_cwnd = 0;
-- 
2.13.2.932.g7449e964c-goog
