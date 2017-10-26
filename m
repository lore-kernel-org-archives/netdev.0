From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/15] tcp: Namespace-ify sysctl_tcp_stdurg
Date: Thu, 26 Oct 2017 16:35:17 -0700
Message-ID: <20171026233526.6155-7-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:51786 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932396AbdJZXfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:47 -0400
Received: by mail-pg0-f68.google.com with SMTP id p9so3884973pgc.8
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:47 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  3 +--
 4 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b28c172b10e497f235b51aae0fc2d3bbf7cc51f3..ffa2cf3dc747ca9443df3927dc7928c18357f872 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -133,6 +133,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_thin_linear_timeouts;
 	int sysctl_tcp_slow_start_after_idle;
 	int sysctl_tcp_retrans_collapse;
+	int sysctl_tcp_stdurg;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 085848e4de38058bb09f025387c713ade32b263e..0cf9de8506916c67369ce78833207ba648f34a10 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_stdurg;
 extern int sysctl_tcp_rfc1337;
 extern int sysctl_tcp_abort_on_overflow;
 extern int sysctl_tcp_max_orphans;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 533b92ad39dd0cada542028fe2f276d9eebcd2c8..a34bb75815c15afc077ba7ff36939b5abc9229f6 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -400,13 +400,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_stdurg",
-		.data		= &sysctl_tcp_stdurg,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_rfc1337",
 		.data		= &sysctl_tcp_rfc1337,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_stdurg",
+		.data		= &init_net.ipv4.sysctl_tcp_stdurg,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2cc56fd57b751dd6b457c15067aa9309683a04a8..6c3655b538f6b2315af7dc611acc574f7489bde6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -87,7 +87,6 @@ EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
 
-int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
@@ -5103,7 +5102,7 @@ static void tcp_check_urg(struct sock *sk, const struct tcphdr *th)
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 ptr = ntohs(th->urg_ptr);
 
-	if (ptr && !sysctl_tcp_stdurg)
+	if (ptr && !sock_net(sk)->ipv4.sysctl_tcp_stdurg)
 		ptr--;
 	ptr += ntohl(th->seq);
 
-- 
2.15.0.rc2.357.g7e34df9404-goog
