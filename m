From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: [PATCH] tcp: Fix tcp_prequeue() to get correct rto_min value
Date: Sun, 3 May 2009 09:35:47 +0900
Message-ID: <20090503003547.GA14015@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:53614 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbZECAku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 20:40:50 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2349140rvb.1
        for <netdev@vger.kernel.org>; Sat, 02 May 2009 17:40:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_prequeue() refers to the constant value (TCP_RTO_MIN) regardless of
the actual value might be tuned. The following patches fix this and make
tcp_prequeue get the actual value returns from tcp_rto_min().

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

---
 include/net/tcp.h    |   14 +++++++++++++-
 net/ipv4/tcp_input.c |   10 ----------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b55b489..a54d139 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -41,6 +41,7 @@
 #include <net/ip.h>
 #include <net/tcp_states.h>
 #include <net/inet_ecn.h>
+#include <net/dst.h>
 
 #include <linux/seq_file.h>
 
@@ -543,6 +544,17 @@ static inline void tcp_fast_path_check(struct sock *sk)
 		tcp_fast_path_on(tp);
 }
 
+/* Compute the actual rto_min value */
+static inline u32 tcp_rto_min(struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_get(sk);
+	u32 rto_min = TCP_RTO_MIN;
+
+	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
+		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
+	return rto_min;
+}
+
 /* Compute the actual receive window we are currently advertising.
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
@@ -908,7 +920,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 			wake_up_interruptible(sk->sk_sleep);
 			if (!inet_csk_ack_scheduled(sk))
 				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						          (3 * TCP_RTO_MIN) / 4,
+						          (3 * tcp_rto_min(sk)) / 4,
 							  TCP_RTO_MAX);
 		}
 		return 1;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c96a6bb..eec3e6f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -597,16 +597,6 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 		tcp_grow_window(sk, skb);
 }
 
-static u32 tcp_rto_min(struct sock *sk)
-{
-	struct dst_entry *dst = __sk_dst_get(sk);
-	u32 rto_min = TCP_RTO_MIN;
-
-	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
-	return rto_min;
-}
-
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
-- 
1.6.2.2

