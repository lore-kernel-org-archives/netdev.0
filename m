From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/15] tcp: Namespace-ify sysctl_tcp_thin_linear_timeouts
Date: Thu, 26 Oct 2017 16:35:14 -0700
Message-ID: <20171026233526.6155-4-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:56672 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932381AbdJZXfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id b85so3596882pfj.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:39 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
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
index 469b4954beee8571ba8d930e852db8b1fef5eed3..8ef12bfe1a3a7083f1bbc924bc43a022a4057768 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -260,8 +260,6 @@ extern int sysctl_tcp_moderate_rcvbuf;
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
