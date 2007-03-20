From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 29/31] [CCID3]: Use function for RTT sampling
Date: Tue, 20 Mar 2007 20:18:16 -0300
Message-ID: <20070320231816.GR17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933864AbXCTXSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:18:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:18:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This replaces the existing occurrences of RTT sampling with
the use of the new function dccp_sample_rtt.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   42 +++++++++++-------------------------------
 net/dccp/ccids/ccid3.h |   10 ----------
 2 files changed, 11 insertions(+), 41 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 35123c1..f4097dd 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -414,8 +414,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	struct dccp_tx_hist_entry *packet;
 	struct timeval now;
 	unsigned long t_nfb;
-	u32 pinv;
-	suseconds_t r_sample, t_elapsed;
+	u32 pinv, r_sample;
 
 	BUG_ON(hctx == NULL);
 
@@ -457,18 +456,10 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
 		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
-		r_sample  = timeval_delta(&now, &packet->dccphtx_tstamp);
-		t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
+		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
 
-		DCCP_BUG_ON(r_sample < 0);
-		if (unlikely(r_sample <= t_elapsed))
-			DCCP_WARN("WARNING: r_sample=%dus <= t_elapsed=%dus\n",
-				  (int)r_sample, (int)t_elapsed);
-		else
-			r_sample -= t_elapsed;
-		CCID3_RTT_SANITY_CHECK(r_sample);
-
-		/* Update RTT estimate by
+		/*
+		 * Update RTT estimate by
 		 * If (No feedback recv)
 		 *    R = R_sample;
 		 * Else
@@ -487,15 +478,15 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			ccid3_update_send_interval(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
-				       "R_sample=%dus, X=%u\n", dccp_role(sk),
+				       "R_sample=%uus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
-				       dp->dccps_mss_cache, (int)r_sample,
+				       dp->dccps_mss_cache, r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
 			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
-						   (u32)r_sample) / 10;
+						   r_sample) / 10;
 
 			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 			if (hctx->ccid3hctx_p > 0)
@@ -505,10 +496,10 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 						    hctx->ccid3hctx_p);
 			ccid3_hc_tx_update_x(sk, &now);
 
-			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%dus), s=%u, "
+			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
 				       dccp_role(sk),
-				       sk, hctx->ccid3hctx_rtt, (int)r_sample,
+				       sk, hctx->ccid3hctx_rtt, r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
 				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
@@ -1025,8 +1016,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u32 p_prev, rtt_prev;
-	suseconds_t r_sample, t_elapsed;
+	u32 p_prev, r_sample, rtt_prev;
 	int loss, payload_size;
 
 	BUG_ON(hcrx == NULL);
@@ -1042,17 +1032,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			break;
 		rtt_prev = hcrx->ccid3hcrx_rtt;
 		dccp_timestamp(sk, &now);
-		timeval_sub_usecs(&now, opt_recv->dccpor_timestamp_echo * 10);
-		r_sample = timeval_usecs(&now);
-		t_elapsed = opt_recv->dccpor_elapsed_time * 10;
-
-		DCCP_BUG_ON(r_sample < 0);
-		if (unlikely(r_sample <= t_elapsed))
-			DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
-				  (long)r_sample, (long)t_elapsed);
-		else
-			r_sample -= t_elapsed;
-		CCID3_RTT_SANITY_CHECK(r_sample);
+		r_sample = dccp_sample_rtt(sk, &now, NULL);
 
 		if (hcrx->ccid3hcrx_state == TFRC_RSTATE_NO_DATA)
 			hcrx->ccid3hcrx_rtt = r_sample;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 15776a8..8d31b38 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -51,16 +51,6 @@
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64
 
-/* What we think is a reasonable upper limit on RTT values */
-#define CCID3_SANE_RTT_MAX	   ((suseconds_t)(4 * USEC_PER_SEC))
-
-#define CCID3_RTT_SANITY_CHECK(rtt) 			do {		   \
-		if (rtt > CCID3_SANE_RTT_MAX) {				   \
-			DCCP_CRIT("RTT (%d) too large, substituting %d",   \
-				  (int)rtt, (int)CCID3_SANE_RTT_MAX);	   \
-			rtt = CCID3_SANE_RTT_MAX;			   \
-		} 					} while (0)
-
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
-- 
1.5.0.3

