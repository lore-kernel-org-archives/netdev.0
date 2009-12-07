From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCHv3 2/2] tcp: Stalling connections: Move timeout calculation
 routine
Date: Mon, 07 Dec 2009 17:06:16 +0100
Message-ID: <4B1D27F8.2000603@tvk.rwth-aachen.de>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
 <4B1CE45A.9010908@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:61886 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934630AbZLGQGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 11:06:11 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00LABI2CX820@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 17:06:17 +0100 (CET)
In-reply-to: <4B1CE45A.9010908@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves retransmits_timed_out() from include/net/tcp.h
to tcp_timer.c, where it is used.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h    |   28 ----------------------------
 net/ipv4/tcp_timer.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 842ac4d..ffab98a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1259,34 +1259,6 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
-/* This function calculates a "timeout" which is equivalent to the timeout of a
- * TCP connection after "boundary" unsucessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN.
- */
-static inline bool retransmits_timed_out(struct sock *sk,
-					 unsigned int boundary)
-{
-	unsigned int timeout, linear_backoff_thresh;
-	unsigned int start_ts;
-
-	if (!inet_csk(sk)->icsk_retransmits)
-		return false;
-
-	if (unlikely(!tcp_sk(sk)->retrans_stamp))
-		start_ts = TCP_SKB_CB(tcp_write_queue_head(sk))->when;
-	else
-		start_ts = tcp_sk(sk)->retrans_stamp;
-
-	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
-
-	if (boundary <= linear_backoff_thresh)
-		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
-	else
-		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
-			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
-
-	return (tcp_time_stamp - start_ts) >= timeout;
-}
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cdb2ca7..dfa0c37 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -132,6 +132,35 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 	}
 }
 
+/* This function calculates a "timeout" which is equivalent to the timeout of a
+ * TCP connection after "boundary" unsucessful, exponentially backed-off
+ * retransmissions with an initial RTO of TCP_RTO_MIN.
+ */
+static bool retransmits_timed_out(struct sock *sk,
+				  unsigned int boundary)
+{
+	unsigned int timeout, linear_backoff_thresh;
+	unsigned int start_ts;
+
+	if (!inet_csk(sk)->icsk_retransmits)
+		return false;
+
+	if (unlikely(!tcp_sk(sk)->retrans_stamp))
+		start_ts = TCP_SKB_CB(tcp_write_queue_head(sk))->when;
+	else
+		start_ts = tcp_sk(sk)->retrans_stamp;
+
+	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+
+	if (boundary <= linear_backoff_thresh)
+		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
+	else
+		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
+			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+
+	return (tcp_time_stamp - start_ts) >= timeout;
+}
+
 /* A write timeout has occurred. Process the after effects. */
 static int tcp_write_timeout(struct sock *sk)
 {
-- 
1.6.4.4
