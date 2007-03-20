From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 26/31] [CCID3]: Wrap computation of RFC3390-initial rate into separate function
Date: Tue, 20 Mar 2007 20:17:35 -0300
Message-ID: <20070320231735.GO17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933859AbXCTXRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:17:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:17:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CCID 3 and TFRC specs (RFC 4342, RFC 3448, draft-3448bis) make frequent
reference to the computation of the RFC-3390 initial sending rate:

  1. Initial sending rate when RTT is known (RFC 4342, p. 6)
  2. Response to Idle/Application-Limited periods (RFC 4342, 5.1)

This warrants putting the code into its own function, for later code reuse.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index dc6e418..8d33a09 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -82,6 +82,21 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 }
 
 /*
+ * Compute the initial sending rate X_init according to RFC 3390:
+ *	w_init   =    min(4 * MSS, max(2 * MSS, 4380 bytes))
+ *	X_init   =    w_init / RTT
+ * For consistency with other parts of the code, X_init is scaled by 2^6.
+ */
+static inline u64 rfc3390_initial_rate(struct sock *sk)
+{
+	const struct dccp_sock *dp = dccp_sk(sk);
+	const __u32 w_init = min(4 * dp->dccps_mss_cache,
+				 max(2 * dp->dccps_mss_cache, 4380U));
+
+	return scaled_div(w_init << 6, ccid3_hc_tx_sk(sk)->ccid3hctx_rtt);
+}
+
+/*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
 static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
@@ -469,20 +484,16 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 */
-			__u32 w_init = min(4 * dp->dccps_mss_cache,
-					   max(2 * dp->dccps_mss_cache, 4380U));
 			hctx->ccid3hctx_rtt  = r_sample;
-			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
-			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
+			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
-				       dp->dccps_mss_cache,
-				       w_init,
-				       (int)r_sample,
+				       dp->dccps_mss_cache, (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-- 
1.5.0.3

