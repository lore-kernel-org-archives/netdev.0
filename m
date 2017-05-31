From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: disallow cwnd undo when switching congestion control
Date: Wed, 31 May 2017 11:21:27 -0700
Message-ID: <20170531182127.161289-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35896 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdEaSWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:22:06 -0400
Received: by mail-pf0-f174.google.com with SMTP id m17so14333121pfg.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:22:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the sender switches its congestion control during loss
recovery, if the recovery is spurious then it may incorrectly
revert cwnd and ssthresh to the older values set by a previous
congestion control. Consider a congestion control (like BBR)
that does not use ssthresh and keeps it infinite: the connection
may incorrectly revert cwnd to an infinite value when switching
from BBR to another congestion control.

This patch fixes it by disallowing such cwnd undo operation
upon switching congestion control.  Note that undo_marker
is not reset s.t. the packets that were incorrectly marked
lost would be corrected. We only avoid undoing the cwnd in
tcp_undo_cwnd_reduction().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cong.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 6e3c512054a6..324c9bcc5456 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -180,6 +180,7 @@ void tcp_init_congestion_control(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
+	tcp_sk(sk)->prior_ssthresh = 0;
 	if (icsk->icsk_ca_ops->init)
 		icsk->icsk_ca_ops->init(sk);
 	if (tcp_ca_needs_ecn(sk))
-- 
2.13.0.219.gdb65acc882-goog
