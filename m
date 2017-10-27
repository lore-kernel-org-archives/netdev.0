From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/12] tcp: Namespace-ify sysctl_tcp_challenge_ack_limit
Date: Fri, 27 Oct 2017 07:47:26 -0700
Message-ID: <20171027144732.23885-7-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46305 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdJ0Orv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:51 -0400
Received: by mail-io0-f193.google.com with SMTP id 101so13221108ioj.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:51 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       | 14 ++++++--------
 net/ipv4/tcp_ipv4.c        |  2 ++
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e98f473bab13cd9b8ff5cc3a62a75134dd84371a..e9895d40868e609dc460755b13a85cdcc82c053e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -147,6 +147,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_tso_win_divisor;
 	int sysctl_tcp_workaround_signed_windows;
 	int sysctl_tcp_limit_output_bytes;
+	int sysctl_tcp_challenge_ack_limit;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 33f9d30a69050e4d3eaf4e1f4869d148442902fc..afc23596e9aa30fe6b4ed64049b3f55b6760be2b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_challenge_ack_limit;
 extern int sysctl_tcp_min_tso_segs;
 extern int sysctl_tcp_min_rtt_wlen;
 extern int sysctl_tcp_autocorking;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6caf5c40730fa10f14a35e1f3219a69f5365a2ce..e28b3b7a7bbc75d3eb20718caef18d03bea79f95 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -457,13 +457,6 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= TCP_CA_NAME_MAX,
 		.proc_handler	= proc_tcp_congestion_control,
 	},
-	{
-		.procname	= "tcp_challenge_ack_limit",
-		.data		= &sysctl_tcp_challenge_ack_limit,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 #ifdef CONFIG_NETLABEL
 	{
 		.procname	= "cipso_cache_enable",
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_challenge_ack_limit",
+		.data		= &init_net.ipv4.sysctl_tcp_challenge_ack_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ce481325115fe7cb8a3b007276f2ce2a519a7383..928048a4e2c5bf5f7875adfe019af88af8244533 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -79,9 +79,6 @@
 #include <linux/unaligned/access_ok.h>
 #include <linux/static_key.h>
 
-/* rfc5961 challenge ack rate limiting */
-int sysctl_tcp_challenge_ack_limit = 1000;
-
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
@@ -3443,10 +3440,11 @@ static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 	static u32 challenge_timestamp;
 	static unsigned int challenge_count;
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	u32 count, now;
 
 	/* First check our per-socket dupack rate limit. */
-	if (__tcp_oow_rate_limited(sock_net(sk),
+	if (__tcp_oow_rate_limited(net,
 				   LINUX_MIB_TCPACKSKIPPEDCHALLENGE,
 				   &tp->last_oow_ack_time))
 		return;
@@ -3454,16 +3452,16 @@ static void tcp_send_challenge_ack(struct sock *sk, const struct sk_buff *skb)
 	/* Then check host-wide RFC 5961 rate limit. */
 	now = jiffies / HZ;
 	if (now != challenge_timestamp) {
-		u32 half = (sysctl_tcp_challenge_ack_limit + 1) >> 1;
+		u32 ack_limit = net->ipv4.sysctl_tcp_challenge_ack_limit;
+		u32 half = (ack_limit + 1) >> 1;
 
 		challenge_timestamp = now;
-		WRITE_ONCE(challenge_count, half +
-			   prandom_u32_max(sysctl_tcp_challenge_ack_limit));
+		WRITE_ONCE(challenge_count, half + prandom_u32_max(ack_limit));
 	}
 	count = READ_ONCE(challenge_count);
 	if (count > 0) {
 		WRITE_ONCE(challenge_count, count - 1);
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
+		NET_INC_STATS(net, LINUX_MIB_TCPCHALLENGEACK);
 		tcp_send_ack(sk);
 	}
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 713b80261e4fdbafa9031a7e3bfc06f0700c2279..50ab3a3eced342846f57a93f0ec8c7d5ae0d7e32 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2501,6 +2501,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_tso_win_divisor = 3;
 	/* Default TSQ limit of four TSO segments */
 	net->ipv4.sysctl_tcp_limit_output_bytes = 262144;
+	/* rfc5961 challenge ack rate limiting */
+	net->ipv4.sysctl_tcp_challenge_ack_limit = 1000;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
