From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 03/15] tcp: Namespace-ify sysctl_tcp_thin_linear_timeouts
Date: Thu, 26 Oct 2017 21:54:58 -0700
Message-ID: <20171027045510.5827-4-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:49958 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdJ0EzW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:22 -0400
Received: by mail-io0-f193.google.com with SMTP id n137so10140526iod.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:22 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note that sysctl_tcp_thin_dupack was not used, I deleted it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  2 --
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_timer.c       |  4 +---
 4 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d6ed718075d44cfc0e60995c1e938d588ad261a8..2a9f37b39c45fe451e45025790a4e5c45ece5cbc 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -130,6 +130,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_timestamps;
 	int sysctl_tcp_early_retrans;
 	int sysctl_tcp_recovery;
+	int sysctl_tcp_thin_linear_timeouts;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c7f51534fc44c61a95225e0adc0a1200ea5c0c1c..063a7a48b7fe23092023d053e26a967389628cdc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -263,8 +263,6 @@ extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
-extern int sysctl_tcp_thin_linear_timeouts;
-extern int sysctl_tcp_thin_dupack;
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 78019adcae875a438264ee47723670f6b54cacf9..12003214f4d80b38d5f754ddd91be8a990168ade 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -620,13 +620,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler   = proc_allowed_congestion_control,
 	},
-	{
-		.procname       = "tcp_thin_linear_timeouts",
-		.data           = &sysctl_tcp_thin_linear_timeouts,
-		.maxlen         = sizeof(int),
-		.mode           = 0644,
-		.proc_handler   = proc_dointvec
-	},
 	{
 		.procname	= "tcp_min_tso_segs",
 		.data		= &sysctl_tcp_min_tso_segs,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname       = "tcp_thin_linear_timeouts",
+		.data           = &init_net.ipv4.sysctl_tcp_thin_linear_timeouts,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 804a8d34ce86cc17472c918c00c25de88b85184f..035a1ef1f2d8462c1d19f364b599ffac538ef688 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,8 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_thin_linear_timeouts __read_mostly;
-
 /**
  *  tcp_write_err() - close socket and save error info
  *  @sk:  The socket the error has appeared on.
@@ -522,7 +520,7 @@ void tcp_retransmit_timer(struct sock *sk)
 	 * linear-timeout retransmissions into a black hole
 	 */
 	if (sk->sk_state == TCP_ESTABLISHED &&
-	    (tp->thin_lto || sysctl_tcp_thin_linear_timeouts) &&
+	    (tp->thin_lto || net->ipv4.sysctl_tcp_thin_linear_timeouts) &&
 	    tcp_stream_is_thin(tp) &&
 	    icsk->icsk_retransmits <= TCP_THIN_LINEAR_RETRIES) {
 		icsk->icsk_backoff = 0;
-- 
2.15.0.rc2.357.g7e34df9404-goog
