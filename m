From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: [PATCH 1/2] tcp: Fix tcp_prequeue() to get correct rto_min value
Date: Sat, 2 May 2009 16:41:58 +0900
Message-ID: <20090502074158.GB13165@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:2523 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbZEBHrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 03:47:13 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2135499rvb.1
        for <netdev@vger.kernel.org>; Sat, 02 May 2009 00:47:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_prequeue() refers to the constant value (TCP_RTO_MIN) regardless of
the actual value. The following patches fix this and make tcp_prequeue
get the correct value returns from tcp_rto_min().

The first patch moves the definition of tcp_rto_min() to the header
file to make tcp_prequeue() can call it.

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

---
 include/net/tcp.h    |   12 ++++++++++++
 net/ipv4/tcp_input.c |   10 ----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b55b489..284cc68 100644
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

