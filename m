From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] tcp: eliminate negative reordering in tcp_clean_rtx_queue
Date: Mon, 15 May 2017 17:05:47 -0400
Message-ID: <20170515210547.125052-1-soheil.kdev@gmail.com>
Cc: ilpo.jarvinen@helsinki.fi,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33560 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756248AbdEOVFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:05:51 -0400
Received: by mail-qt0-f195.google.com with SMTP id a46so17859269qte.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 14:05:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

tcp_ack() can call tcp_fragment() which may dededuct the
value tp->fackets_out when MSS changes. When prior_fackets
is larger than tp->fackets_out, tcp_clean_rtx_queue() can
invoke tcp_update_reordering() with negative values. This
results in absurd tp->reodering values higher than
sysctl_tcp_max_reordering.

Note that tcp_update_reordering indeeds sets tp->reordering
to min(sysctl_tcp_max_reordering, metric), but because
the comparison is signed, a negative metric always wins.

Fixes: c7caf8d3ed7a ("[TCP]: Fix reord detection due to snd_una covered holes")
Reported-by: Rebecca Isaacs <risaacs@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9739962bfb3f..f27dff64e59e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3190,7 +3190,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			int delta;
 
 			/* Non-retransmitted hole got filled? That's reordering */
-			if (reord < prior_fackets)
+			if (reord < prior_fackets && reord <= tp->fackets_out)
 				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
 
 			delta = tcp_is_fack(tp) ? pkts_acked :
-- 
2.13.0.rc2.291.g57267f2277-goog
