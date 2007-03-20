From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 20/31] [CCID3]: Remove race condition and update t_ipi when `s' changes
Date: Tue, 20 Mar 2007 20:15:41 -0300
Message-ID: <20070320231541.GI17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:39497 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbXCTXPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:15:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66936wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:15:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This:

 1. removes a race condition in the access to the scheduled send time t_nom which
    results from allowing asynchronous r/w access to t_nom without locks;

 2. updates the inter-packet interval t_ipi = s/X when `s' changes, following a
    suggestion by Ian McDonald.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   35 ++++++++++++-----------------------
 1 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 26ab73d..95eca99 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -82,20 +82,14 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 }
 
 /*
- * Recalculate scheduled nominal send time t_nom, inter-packet interval
- * t_ipi, and delta value. Should be called after each change to X.
+ * Recalculate t_ipi and delta (should be called whenever X changes)
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
-	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
 	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
 					   hctx->ccid3hctx_x >> 6);
 
-	/* Update nominal send time with regard to the new t_ipi */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
@@ -119,8 +113,6 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
  *       fine-grained resolution of sending rates. This requires scaling by 2^6
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
- * If X has changed, we also update the scheduled send time t_now,
- * the inter-packet interval t_ipi, and the delta value.
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -151,7 +143,7 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
 			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
 
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_interval(hctx);
 	}
 }
 
@@ -161,14 +153,12 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	hctx->ccid3hctx_s = hctx->ccid3hctx_s == 0 ? len :
-			    (9 * hctx->ccid3hctx_s + len) / 10;
-	/*
-	 * Note: We could do a potential optimisation here - when `s' changes,
-	 *	 recalculate sending rate and consequently t_ipi, t_delta, and
-	 *	 t_now. This is however non-standard, and the benefits are not
-	 *	 clear, so it is currently left out.
-	 */
+	const u16 old_s = hctx->ccid3hctx_s;
+
+	hctx->ccid3hctx_s = old_s == 0 ? len : (9 * old_s + len) / 10;
+
+	if (hctx->ccid3hctx_s != old_s)
+		ccid3_update_send_interval(hctx);
 }
 
 /*
@@ -228,7 +218,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_interval(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -334,8 +324,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
 		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+		hctx->ccid3hctx_x = hctx->ccid3hctx_s = skb->len;
 		hctx->ccid3hctx_x <<= 6;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
@@ -484,7 +473,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
-			ccid3_update_send_time(hctx);
+			ccid3_update_send_interval(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
-- 
1.5.0.3

