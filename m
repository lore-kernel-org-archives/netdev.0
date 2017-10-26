From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/15] tcp: Namespace-ify sysctl_tcp_rfc1337
Date: Thu, 26 Oct 2017 16:35:18 -0700
Message-ID: <20171026233526.6155-8-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:55095 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932381AbdJZXfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:50 -0400
Received: by mail-pg0-f66.google.com with SMTP id l24so3878914pgu.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:49 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  1 -
 net/ipv4/tcp_minisocks.c   |  2 +-
 5 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ffa2cf3dc747ca9443df3927dc7928c18357f872..968edce38eb5d3399724b3142277eab44f19f2fb 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -134,6 +134,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_slow_start_after_idle;
 	int sysctl_tcp_retrans_collapse;
 	int sysctl_tcp_stdurg;
+	int sysctl_tcp_rfc1337;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0cf9de8506916c67369ce78833207ba648f34a10..7f88987bc62dd76206c15eb91f2990d4469e5421 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_rfc1337;
 extern int sysctl_tcp_abort_on_overflow;
 extern int sysctl_tcp_max_orphans;
 extern int sysctl_tcp_fack;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a34bb75815c15afc077ba7ff36939b5abc9229f6..832e554235df37770809541ad8f9f1ca2f201739 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -400,13 +400,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_rfc1337",
-		.data		= &sysctl_tcp_rfc1337,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_rfc1337",
+		.data		= &init_net.ipv4.sysctl_tcp_rfc1337,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6c3655b538f6b2315af7dc611acc574f7489bde6..d2d3f62387a98d7f955f8c9e27320b9722035b2a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -87,7 +87,6 @@ EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
 
-int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a952357054f4ddfbb98746ebcf323d1c45f7e951..2abaa4c1fe0108f2645d8e783ae6b48e87a82fb3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -180,7 +180,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			 * Oh well... nobody has a sufficient solution to this
 			 * protocol bug yet.
 			 */
-			if (sysctl_tcp_rfc1337 == 0) {
+			if (twsk_net(tw)->ipv4.sysctl_tcp_rfc1337 == 0) {
 kill:
 				inet_twsk_deschedule_put(tw);
 				return TCP_TW_SUCCESS;
-- 
2.15.0.rc2.357.g7e34df9404-goog
