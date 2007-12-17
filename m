From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/5] [CCID3]: Use a function to update p_inv, and p is never used
Date: Mon, 17 Dec 2007 13:00:15 -0200
Message-ID: <1197903619-12301-2-git-send-email-acme@redhat.com>
References: <1197903619-12301-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:35151 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757346AbXLQPA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 10:00:28 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1903486rvb.1
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 07:00:27 -0800 (PST)
In-Reply-To: <1197903619-12301-1-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This patch
 1) concentrates previously scattered computation of p_inv into one function;
 2) removes the `p' element of the CCID3 RX sock (it is redundant);
 3) makes the tfrc_rx_info structure standalone, only used on demand.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   11 ++++++++---
 net/dccp/ccids/ccid3.h |    8 ++++----
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 876c747..90e0454 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -917,6 +917,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
 	const struct ccid3_hc_rx_sock *hcrx;
+	struct tfrc_rx_info rx_info;
 	const void *val;
 
 	/* Listen socks doesn't have a private CCID block */
@@ -926,10 +927,14 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	hcrx = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
-		if (len < sizeof(hcrx->ccid3hcrx_tfrc))
+		if (len < sizeof(rx_info))
 			return -EINVAL;
-		len = sizeof(hcrx->ccid3hcrx_tfrc);
-		val = &hcrx->ccid3hcrx_tfrc;
+		rx_info.tfrcrx_x_recv = hcrx->ccid3hcrx_x_recv;
+		rx_info.tfrcrx_rtt    = hcrx->ccid3hcrx_rtt;
+		rx_info.tfrcrx_p      = hcrx->ccid3hcrx_pinv == 0 ? ~0U :
+					   scaled_div(1, hcrx->ccid3hcrx_pinv);
+		len = sizeof(rx_info);
+		val = &rx_info;
 		break;
 	default:
 		return -ENOPROTOOPT;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index e9f6ff4..49ca32b 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -139,6 +139,8 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
@@ -147,13 +149,11 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct ccid3_hc_rx_sock {
-	struct tfrc_rx_info		ccid3hcrx_tfrc;
-#define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
-#define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
-#define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
 	u8				ccid3hcrx_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
+	u32				ccid3hcrx_x_recv;
+	u32				ccid3hcrx_rtt;
 	ktime_t				ccid3hcrx_tstamp_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct tfrc_loss_hist		ccid3hcrx_li_hist;
-- 
1.5.3.6

