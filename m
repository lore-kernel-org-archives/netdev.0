From: Nandita Dukkipati <nanditad@google.com>
Subject: [PATCH v2 1/1] TCP: increase default initial receive window.
Date: Mon, 20 Dec 2010 16:15:56 -0800
Message-ID: <1292890556-29904-1-git-send-email-nanditad@google.com>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Nandita Dukkipati <nanditad@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:6539 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844Ab0LUAQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 19:16:08 -0500
In-Reply-To: <1292642451-892-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the default initial receive window to 10 mss
(defined constant). The default window is limited to the maximum
of 10*1460 and 2*mss (when mss > 1460).

draft-ietf-tcpm-initcwnd-00 is a proposal to the IETF that recommends
increasing TCP's initial congestion window to 10 mss or about 15KB.
Leading up to this proposal were several large-scale live Internet
experiments with an initial congestion window of 10 mss (IW10), where
we showed that the average latency of HTTP responses improved by
approximately 10%. This was accompanied by a slight increase in
retransmission rate (0.5%), most of which is coming from applications
opening multiple simultaneous connections. To understand the extreme
worst case scenarios, and fairness issues (IW10 versus IW3), we further
conducted controlled testbed experiments. We came away finding minimal
negative impact even under low link bandwidths (dial-ups) and small
buffers.  These results are extremely encouraging to adopting IW10.

However, an initial congestion window of 10 mss is useless unless a TCP
receiver advertises an initial receive window of at least 10 mss.
Fortunately, in the large-scale Internet experiments we found that most
widely used operating systems advertised large initial receive windows
of 64KB, allowing us to experiment with a wide range of initial
congestion windows. Linux systems were among the few exceptions that
advertised a small receive window of 6KB. The purpose of this patch is
to fix this shortcoming.

References:
1. A comprehensive list of all IW10 references to date.
http://code.google.com/speed/protocols/tcpm-IW10.html

2. Paper describing results from large-scale Internet experiments with IW10.
http://ccr.sigcomm.org/drupal/?q=node/621

3. Controlled testbed experiments under worst case scenarios and a
fairness study.
http://www.ietf.org/proceedings/79/slides/tcpm-0.pdf

4. Raw test data from testbed experiments (Linux senders/receivers)
with initial congestion and receive windows of both 10 mss.
http://research.csc.ncsu.edu/netsrv/?q=content/iw10

5. Internet-Draft. Increasing TCP's Initial Window.
https://datatracker.ietf.org/doc/draft-ietf-tcpm-initcwnd/

Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
Changelog since v1:
- A longer and better commit message.

 include/net/tcp.h     |    3 +++
 net/ipv4/tcp_output.c |   11 ++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b448030..38509f0 100644
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

