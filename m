From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/7] tcp: apply Kern's check on RTTs used for congestion control
Date: Fri, 16 Oct 2015 21:57:41 -0700
Message-ID: <1445057867-32257-2-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35037 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbbJQE6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:03 -0400
Received: by payp3 with SMTP id p3so7576570pay.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:03 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ca_seq_rtt_us does not use Kern's check. Fix that by
checking if any packet acked is a retransmit, for both RTT used
for RTT estimation and congestion control.

Fixes: 5b08e47ca ("tcp: prefer packet timing to TS-ECR for RTT")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3b35c3f..38743e5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2925,9 +2925,6 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 	 * Karn's algorithm forbids taking RTT if some retransmitted data
 	 * is acked (RFC6298).
 	 */
-	if (flag & FLAG_RETRANS_DATA_ACKED)
-		seq_rtt_us = -1L;
-
 	if (seq_rtt_us < 0)
 		seq_rtt_us = sack_rtt_us;
 
@@ -3169,7 +3166,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		flag |= FLAG_SACK_RENEGING;
 
 	skb_mstamp_get(&now);
-	if (likely(first_ackt.v64)) {
+	if (likely(first_ackt.v64) && !(flag & FLAG_RETRANS_DATA_ACKED)) {
 		seq_rtt_us = skb_mstamp_us_delta(&now, &first_ackt);
 		ca_rtt_us = skb_mstamp_us_delta(&now, &last_ackt);
 	}
-- 
2.6.0.rc2.230.g3dd15c0
