From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 06/15] tcp: Namespace-ify sysctl_tcp_stdurg
Date: Thu, 26 Oct 2017 21:55:01 -0700
Message-ID: <20171027045510.5827-7-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46670 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJ0Ez2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:28 -0400
Received: by mail-io0-f193.google.com with SMTP id 101so10132041ioj.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:28 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
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
index 33cc86355b8ff9b506d21ad46cfc01b3916f5b61..cf3fac7008d791f2a01e4df9178164769a861c60 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -243,7 +243,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
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
index 5b2272dbf6a9a507d62d8ee594fab53284b22a6d..14b06963c102dc8c747050448e504fc2e75a4eb4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -89,7 +89,6 @@ EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
 
-int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
@@ -5123,7 +5122,7 @@ static void tcp_check_urg(struct sock *sk, const struct tcphdr *th)
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 ptr = ntohs(th->urg_ptr);
 
-	if (ptr && !sysctl_tcp_stdurg)
+	if (ptr && !sock_net(sk)->ipv4.sysctl_tcp_stdurg)
 		ptr--;
 	ptr += ntohl(th->seq);
 
-- 
2.15.0.rc2.357.g7e34df9404-goog
