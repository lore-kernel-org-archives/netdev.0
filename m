From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 07/15] tcp: Namespace-ify sysctl_tcp_rfc1337
Date: Thu, 26 Oct 2017 21:55:02 -0700
Message-ID: <20171027045510.5827-8-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44541 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdJ0Eza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:30 -0400
Received: by mail-io0-f194.google.com with SMTP id m16so10138229iod.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:30 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
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
index cf3fac7008d791f2a01e4df9178164769a861c60..2aea2b3373b38dde9aabf869931448e9ecd38649 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -243,7 +243,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
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
index 14b06963c102dc8c747050448e504fc2e75a4eb4..64fde81b0eb70feccffd18a703e2b604e306ea65 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -89,7 +89,6 @@ EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
 
-int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 056009f1c14f13ac4af987d0a7451f32dbde0023..11836667763cf9a32c673086b6dc2d759833c856 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -181,7 +181,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
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
