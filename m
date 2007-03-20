From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 31/31] [CCID3]: Use initial RTT sample from SYN exchange
Date: Tue, 20 Mar 2007 20:18:56 -0300
Message-ID: <20070320231856.GT17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933877AbXCTXTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:19:01 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:19:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch follows the following recommendation made in an erratum to RFC 4342:

  "Senders MAY additionally make use of other available RTT measurements,
   including those from the initial Request-Response packet exchange."

It implements larger initial windows with regard to this inital RTT measurement,
using the mechanism suggested in draft-ietf-dccp-rfc3448bis, section 4.2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index f4097dd..c3abd76 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -334,19 +334,30 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
 		hctx->ccid3hctx_last_win_count	 = 0;
 		hctx->ccid3hctx_t_last_win_count = now;
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-
-		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-		hctx->ccid3hctx_x = hctx->ccid3hctx_s = skb->len;
-		hctx->ccid3hctx_x <<= 6;
-
-		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
-		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
-		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
-		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
 
 		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
+
+		hctx->ccid3hctx_s = skb->len;
+
+		/*
+		 * Use initial RTT sample when available: recommended by erratum
+		 * to RFC 4342. This implements the initialisation procedure of
+		 * draft rfc3448bis, section 4.2. Remember, X is scaled by 2^6.
+		 */
+		if (dp->dccps_syn_rtt) {
+			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
+			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+			hctx->ccid3hctx_t_ld = now;
+		} else {
+			/* Sender does not have RTT sample: X = MSS/second */
+			hctx->ccid3hctx_x = dp->dccps_mss_cache;
+			hctx->ccid3hctx_x <<= 6;
+		}
+		ccid3_update_send_interval(hctx);
+
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-- 
1.5.0.3

