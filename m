From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp_bbr: add a state transition diagram and accompanying comment
Date: Thu, 27 Oct 2016 13:26:37 -0400
Message-ID: <1477589197-18123-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35526 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbcJ0R0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:26:55 -0400
Received: by mail-qk0-f182.google.com with SMTP id z190so55268621qkc.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:26:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the possible state transitions for a BBR flow, and also add a
prose summary of the state machine, covering the life of a typical BBR
flow.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_bbr.c | 32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 0ea66c2..b89bce4 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -14,6 +14,36 @@
  * observed, or adjust the sending rate if it estimates there is a
  * traffic policer, in order to keep the drop rate reasonable.
  *
+ * Here is a state transition diagram for BBR:
+ *
+ *             |
+ *             V
+ *    +---> STARTUP  ----+
+ *    |        |         |
+ *    |        V         |
+ *    |      DRAIN   ----+
+ *    |        |         |
+ *    |        V         |
+ *    +---> PROBE_BW ----+
+ *    |      ^    |      |
+ *    |      |    |      |
+ *    |      +----+      |
+ *    |                  |
+ *    +---- PROBE_RTT <--+
+ *
+ * A BBR flow starts in STARTUP, and ramps up its sending rate quickly.
+ * When it estimates the pipe is full, it enters DRAIN to drain the queue.
+ * In steady state a BBR flow only uses PROBE_BW and PROBE_RTT.
+ * A long-lived BBR flow spends the vast majority of its time remaining
+ * (repeatedly) in PROBE_BW, fully probing and utilizing the pipe's bandwidth
+ * in a fair manner, with a small, bounded queue. *If* a flow has been
+ * continuously sending for the entire min_rtt window, and hasn't seen an RTT
+ * sample that matches or decreases its min_rtt estimate for 10 seconds, then
+ * it briefly enters PROBE_RTT to cut inflight to a minimum value to re-probe
+ * the path's two-way propagation delay (min_rtt). When exiting PROBE_RTT, if
+ * we estimated that we reached the full bw of the pipe then we enter PROBE_BW;
+ * otherwise we enter STARTUP to try to fill the pipe.
+ *
  * BBR is described in detail in:
  *   "BBR: Congestion-Based Congestion Control",
  *   Neal Cardwell, Yuchung Cheng, C. Stephen Gunn, Soheil Hassas Yeganeh,
@@ -51,7 +81,7 @@ enum bbr_mode {
 	BBR_STARTUP,	/* ramp up sending rate rapidly to fill pipe */
 	BBR_DRAIN,	/* drain any queue created during startup */
 	BBR_PROBE_BW,	/* discover, share bw: pace around estimated bw */
-	BBR_PROBE_RTT,	/* cut cwnd to min to probe min_rtt */
+	BBR_PROBE_RTT,	/* cut inflight to min to probe min_rtt */
 };
 
 /* BBR congestion control block */
-- 
2.8.0.rc3.226.g39d4020
