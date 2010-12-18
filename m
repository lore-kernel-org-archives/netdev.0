From: Nandita Dukkipati <nanditad@google.com>
Subject: [PATCH 1/1] TCP: increase default initial receive window.
Date: Fri, 17 Dec 2010 19:20:51 -0800
Message-ID: <1292642451-892-1-git-send-email-nanditad@google.com>
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:19796 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab0LRDVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 22:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the default initial receive window to 10 mss
(defined constant). The default window is limited to the maximum
of 10*1460 and 2*mss (when mss > 1460).

Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 include/net/tcp.h     |    3 +++
 net/ipv4/tcp_output.c |   11 ++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2ab6c9c..6c25ba8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -60,6 +60,9 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
  */
 #define MAX_TCP_WINDOW		32767U
 
+/* Offer an initial receive window of 10 mss. */
+#define TCP_DEFAULT_INIT_RCVWND	10
+
 /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
 #define TCP_MIN_MSS		88U
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2d39066..dc7c096 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -228,10 +228,15 @@ void tcp_select_initial_window(int __space, __u32 mss,
 		}
 	}
 
-	/* Set initial window to value enough for senders, following RFC5681. */
+	/* Set initial window to a value enough for senders starting with
+	 * initial congestion window of TCP_DEFAULT_INIT_RCVWND. Place
+	 * a limit on the initial window when mss is larger than 1460.
+	 */
 	if (mss > (1 << *rcv_wscale)) {
-		int init_cwnd = rfc3390_bytes_to_packets(mss);
-
+		int init_cwnd = TCP_DEFAULT_INIT_RCVWND;
+		if (mss > 1460)
+			init_cwnd =
+			max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
 		/* when initializing use the value from init_rcv_wnd
 		 * rather than the default from above
 		 */
-- 
1.7.3.1

