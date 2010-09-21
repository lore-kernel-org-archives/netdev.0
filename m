From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/5] dccp tfrc/ccid-3: computing the loss rate from the Loss Event Rate
Date: Tue, 21 Sep 2010 12:28:57 +0200
Message-ID: <1285064938-5933-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <miscellaneous_dccp_ccid_fixes>
 <1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1285064938-5933-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1285064938-5933-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1285064938-5933-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64858 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752393Ab0IUK3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 06:29:16 -0400
In-Reply-To: <1285064938-5933-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a function to take care of the following, separate cases occurring in
the computation of the Loss Rate p:

 * 1/(2^32-1) is mapped into 0% as per RFC 4342, 8.5;
 * 1/0        is mapped into 100%, the maximum;
 * to avoid that p = 1/x is rounded down to 0 when x is very large, since this
   means accidentally re-entering slow-start indicated by p == 0, the minimum
   resolution value of p is now returned instead;
 * a bug in ccid3_hc_rx_getsockopt is fixed: 1/0 was mapped into ~0U.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |    9 ++++-----
 net/dccp/ccids/lib/tfrc.h          |    1 +
 net/dccp/ccids/lib/tfrc_equation.c |   14 ++++++++++++++
 3 files changed, 19 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -400,10 +400,10 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->ccid3or_loss_event_rate;
-	if (pinv == ~0U || pinv == 0)	       /* see RFC 4342, 8.5   */
+	if (pinv == 0)
 		hc->tx_p = 0;
-	else				       /* can not exceed 100% */
-		hc->tx_p = scaled_div(1, pinv);
+	else
+		hc->tx_p = tfrc_invert_loss_event_rate(pinv);
 
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
@@ -834,8 +834,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 			return -EINVAL;
 		rx_info.tfrcrx_x_recv = hc->rx_x_recv;
 		rx_info.tfrcrx_rtt    = hc->rx_rtt;
-		rx_info.tfrcrx_p      = hc->rx_pinv == 0 ? ~0U :
-					   scaled_div(1, hc->rx_pinv);
+		rx_info.tfrcrx_p      = tfrc_invert_loss_event_rate(hc->rx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -57,6 +57,7 @@ static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
 
 extern u32  tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32  tfrc_calc_x_reverse_lookup(u32 fvalue);
+extern u32  tfrc_invert_loss_event_rate(u32 loss_event_rate);
 
 extern int  tfrc_tx_packet_history_init(void);
 extern void tfrc_tx_packet_history_exit(void);
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -687,3 +687,17 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
 	index = tfrc_binsearch(fvalue, 0);
 	return (index + 1) * 1000000 / TFRC_CALC_X_ARRSIZE;
 }
+
+/**
+ * tfrc_invert_loss_event_rate  -  Compute p so that 10^6 corresponds to 100%
+ * When @loss_event_rate is large, there is a chance that p is truncated to 0.
+ * To avoid re-entering slow-start in that case, we set p = TFRC_SMALLEST_P > 0.
+ */
+u32 tfrc_invert_loss_event_rate(u32 loss_event_rate)
+{
+	if (loss_event_rate == UINT_MAX)		/* see RFC 4342, 8.5 */
+		return 0;
+	if (unlikely(loss_event_rate == 0))		/* map 1/0 into 100% */
+		return 1000000;
+	return max_t(u32, scaled_div(1, loss_event_rate), TFRC_SMALLEST_P);
+}
