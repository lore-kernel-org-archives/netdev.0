From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 1/2] RTO connection timeout: coding style fixes and comments
Date: Tue, 01 Sep 2009 22:24:00 +0200
Message-ID: <4A9D82E0.1050200@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54517 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753892AbZIAUX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 16:23:59 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KPB0097C7BWNDB0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 01 Sep 2009 22:24:00 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n81KO0ql004335	for
 <netdev@vger.kernel.org>; Tue, 01 Sep 2009 22:24:00 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch affects the retransmits_timed_out() function.

Changes:
1) Variables have more meaningful names
2) retransmits_timed_out() has an introductionary comment.
3) Small coding style changes.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e531949..df50bc4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1252,22 +1252,27 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
+/* This function calculates a "timeout" which is equivalent to the timeout of a
+ * TCP connection after "boundary" unsucessful, exponentially backed-off
+ * retransmissions with an initial RTO of TCP_RTO_MIN.
+ */
 static inline bool retransmits_timed_out(const struct sock *sk,
 					 unsigned int boundary)
 {
-	int limit, K;
+	unsigned int timeout, linear_backoff_thresh;
+
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
 
-	K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
 
-	if (boundary <= K)
-		limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
+	if (boundary <= linear_backoff_thresh)
+		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
 	else
-		limit = ((2 << K) - 1) * TCP_RTO_MIN +
-			(boundary - K) * TCP_RTO_MAX;
+		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
+			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
 
-	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= limit;
+	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= timeout;
 }
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
-- 
1.6.3.3


