From: chavey@google.com
Subject: [PATCH] Add rtnetlink init_rcvwnd to set the TCP initial receive window
Date: Tue, 15 Dec 2009 13:15:28 -0800
Message-ID: <pvm1viwx7kf.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-239-44-51.google.com ([216.239.44.51]:40430 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760766AbZLOVPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 16:15:37 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id nBFLFZbH016829
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 13:15:36 -0800
Received: from fxm9 (fxm9.prod.google.com [10.184.13.9])
	by kpbe14.cbf.corp.google.com with ESMTP id nBFLFQnT002105
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 13:15:34 -0800
Received: by fxm9 with SMTP id 9so351391fxm.10
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 13:15:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add rtnetlink init_rcvwnd to set the TCP initial receive window size
advertised by passive and active TCP connections.
The current Linux TCP implementation limits the advertised TCP initial
receive window to the one prescribed by slow start. For short lived
TCP connections used for transaction type of traffic (i.e. http
requests), bounding the advertised TCP initial receive window results
in increased latency to complete the transaction.
Support for setting initial congestion window is already supported
using rtnetlink init_cwnd, but the feature is useless without the
ability to set a larger TCP initial receive window.
The rtnetlink init_rcvwnd allows increasing the TCP initial receive
window, allowing TCP connection to advertise larger TCP receive window
than the ones bounded by slow start.

Signed-off-by: Laurent Chavey <chavey@google.com>
---
 include/linux/rtnetlink.h |    2 ++
 include/net/dst.h         |    2 --
 include/net/tcp.h         |    3 ++-
 net/ipv4/syncookies.c     |    3 ++-
 net/ipv4/tcp_output.c     |   17 +++++++++++++----
 net/ipv6/syncookies.c     |    3 ++-
 6 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index adf2068..db6f614 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -371,6 +371,8 @@ enum
 #define RTAX_FEATURES RTAX_FEATURES
 	RTAX_RTO_MIN,
 #define RTAX_RTO_MIN RTAX_RTO_MIN
+	RTAX_INITRWND,
+#define RTAX_INITRWND RTAX_INITRWND
 	__RTAX_MAX
 };
 
diff --git a/include/net/dst.h b/include/net/dst.h
index 5a900dd..6ef812a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -84,8 +84,6 @@ struct dst_entry
 	 * (L1_CACHE_SIZE would be too much)
 	 */
 #ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[2];
-#else
 	long			__pad_to_align_refcnt[1];
 #endif
 	/*
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..6f95d32 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -972,7 +972,8 @@ static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 /* Determine a window scaling and initial window to offer. */
 extern void tcp_select_initial_window(int __space, __u32 mss,
 				      __u32 *rcv_wnd, __u32 *window_clamp,
-				      int wscale_ok, __u8 *rcv_wscale);
+				      int wscale_ok, __u8 *rcv_wscale,
+				      __u32 init_rcv_wnd);
 
 static inline int tcp_win_from_space(int space)
 {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a6e0e07..d43173c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -356,7 +356,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  ireq->wscale_ok, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale,
+				  dst_metric(&rt->u.dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale  = rcv_wscale;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..ee42c75 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -179,7 +179,8 @@ static inline void tcp_event_ack_sent(struct sock *sk, unsigned int pkts)
  */
 void tcp_select_initial_window(int __space, __u32 mss,
 			       __u32 *rcv_wnd, __u32 *window_clamp,
-			       int wscale_ok, __u8 *rcv_wscale)
+			       int wscale_ok, __u8 *rcv_wscale,
+			       __u32 init_rcv_wnd)
 {
 	unsigned int space = (__space < 0 ? 0 : __space);
 
@@ -228,7 +229,13 @@ void tcp_select_initial_window(int __space, __u32 mss,
 			init_cwnd = 2;
 		else if (mss > 1460)
 			init_cwnd = 3;
-		if (*rcv_wnd > init_cwnd * mss)
+		/* when initializing use the value from init_rcv_wnd
+		 * rather than the default from above
+		 */
+		if (init_rcv_wnd &&
+		    (*rcv_wnd > init_rcv_wnd * mss))
+			*rcv_wnd = init_rcv_wnd * mss;
+		else if (*rcv_wnd > init_cwnd * mss)
 			*rcv_wnd = init_cwnd * mss;
 	}
 
@@ -2254,7 +2261,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 			&req->rcv_wnd,
 			&req->window_clamp,
 			ireq->wscale_ok,
-			&rcv_wscale);
+			&rcv_wscale,
+			dst_metric(dst, RTAX_INITRWND));
 		ireq->rcv_wscale = rcv_wscale;
 	}
 
@@ -2342,7 +2350,8 @@ static void tcp_connect_init(struct sock *sk)
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
 				  sysctl_tcp_window_scaling,
-				  &rcv_wscale);
+				  &rcv_wscale,
+				  dst_metric(dst, RTAX_INITRWND));
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6b6ae91..c8982aa 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -267,7 +267,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  ireq->wscale_ok, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale,
+				  dst_metric(dst, RTAX_INITRWND));
 
 	ireq->rcv_wscale = rcv_wscale;
 
