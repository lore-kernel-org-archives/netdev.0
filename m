From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP slow start: comments and cleanup
Date: Wed, 16 May 2007 14:57:00 -0700
Message-ID: <20070516145700.7f524114@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:48668 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760059AbXEPV6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 17:58:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add more comments to describe our version of tcp_slow_start().

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/ipv4/tcp_cong.c |   40 ++++++++++++++++++++++------------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 86b2653..bd74e43 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -276,30 +276,34 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 
 
 /*
- * Slow start (exponential increase) with
- * RFC3742 Limited Slow Start (fast linear increase) support.
+ * Slow start is used when congestion window is less than slow start
+ * threshold. This version implements the basic RFC2581 version
+ * and optionally supports: 
+ * 	RFC3742 Limited Slow Start  	  - growth limited to max_ssthresh
+ *	RFC3465 Appropriate Byte Counting - growth limited by bytes acknowledged
  */
 void tcp_slow_start(struct tcp_sock *tp)
 {
-	int cnt = 0;
-
-	if (sysctl_tcp_abc) {
-		/* RFC3465: Slow Start
-		 * TCP sender SHOULD increase cwnd by the number of
-		 * previously unacknowledged bytes ACKed by each incoming
-		 * acknowledgment, provided the increase is not more than L
-		 */
-		if (tp->bytes_acked < tp->mss_cache)
-			return;
-	}
+	int cnt; /* increase in packets */
+
+	/* RFC3465: ABC Slow start
+	 * Increase only after a full MSS of bytes is acked
+	 *
+	 * TCP sender SHOULD increase cwnd by the number of
+	 * previously unacknowledged bytes ACKed by each incoming
+	 * acknowledgment, provided the increase is not more than L
+	 */
+	if (sysctl_tcp_abc && tp->bytes_acked < tp->mss_cache)
+		return;
 
-	if (sysctl_tcp_max_ssthresh > 0 &&
-	    tp->snd_cwnd > sysctl_tcp_max_ssthresh)
-		cnt += sysctl_tcp_max_ssthresh>>1;
+	if (sysctl_tcp_max_ssthresh > 0 && tp->snd_cwnd > sysctl_tcp_max_ssthresh)
+		cnt = sysctl_tcp_max_ssthresh >> 1;	/* limited slow start */
 	else
-		cnt += tp->snd_cwnd;
+		cnt = tp->snd_cwnd;			/* exponential increase */
 
-	/* RFC3465: We MAY increase by 2 if discovered delayed ack */
+	/* RFC3465: ABC
+	 * We MAY increase by 2 if discovered delayed ack 
+	 */
 	if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache)
 		cnt <<= 1;
 	tp->bytes_acked = 0;
-- 
1.4.4.2

