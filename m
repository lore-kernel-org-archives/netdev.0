From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 3/3] tcp: a small refactor of RACK loss detection
Date: Wed,  4 Oct 2017 13:00:00 -0700
Message-ID: <20171004200000.39257-4-ycheng@google.com>
References: <20171004200000.39257-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:47748 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdJDUAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 16:00:25 -0400
Received: by mail-pg0-f54.google.com with SMTP id r25so4676049pgn.4
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 13:00:25 -0700 (PDT)
In-Reply-To: <20171004200000.39257-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the RACK loop to improve readability and speed up the checks.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_recovery.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index 8aa56caefde8..cda6074a429a 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -61,32 +61,28 @@ static void tcp_rack_detect_loss(struct sock *sk, u32 *reo_timeout)
 	list_for_each_entry_safe(skb, n, &tp->tsorted_sent_queue,
 				 tcp_tsorted_anchor) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
+		s32 remaining;
 
-		if (tcp_rack_sent_after(tp->rack.mstamp, skb->skb_mstamp,
-					tp->rack.end_seq, scb->end_seq)) {
-			/* Step 3 in draft-cheng-tcpm-rack-00.txt:
-			 * A packet is lost if its elapsed time is beyond
-			 * the recent RTT plus the reordering window.
-			 */
-			u32 elapsed = tcp_stamp_us_delta(tp->tcp_mstamp,
-							 skb->skb_mstamp);
-			s32 remaining = tp->rack.rtt_us + reo_wnd - elapsed;
-
-			if (remaining < 0) {
-				tcp_rack_mark_skb_lost(sk, skb);
-				list_del_init(&skb->tcp_tsorted_anchor);
-				continue;
-			}
-
-			/* Skip ones marked lost but not yet retransmitted */
-			if ((scb->sacked & TCPCB_LOST) &&
-			    !(scb->sacked & TCPCB_SACKED_RETRANS))
-				continue;
+		/* Skip ones marked lost but not yet retransmitted */
+		if ((scb->sacked & TCPCB_LOST) &&
+		    !(scb->sacked & TCPCB_SACKED_RETRANS))
+			continue;
 
+		if (!tcp_rack_sent_after(tp->rack.mstamp, skb->skb_mstamp,
+					 tp->rack.end_seq, scb->end_seq))
+			break;
+
+		/* A packet is lost if it has not been s/acked beyond
+		 * the recent RTT plus the reordering window.
+		 */
+		remaining = tp->rack.rtt_us + reo_wnd -
+			    tcp_stamp_us_delta(tp->tcp_mstamp, skb->skb_mstamp);
+		if (remaining < 0) {
+			tcp_rack_mark_skb_lost(sk, skb);
+			list_del_init(&skb->tcp_tsorted_anchor);
+		} else {
 			/* Record maximum wait time (+1 to avoid 0) */
 			*reo_timeout = max_t(u32, *reo_timeout, 1 + remaining);
-		} else {
-			break;
 		}
 	}
 }
-- 
2.14.2.920.gcf0c67979c-goog
