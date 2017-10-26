From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/15] tcp: Namespace-ify sysctl_tcp_fack
Date: Thu, 26 Oct 2017 16:35:20 -0700
Message-ID: <20171026233526.6155-10-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:49693 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932396AbdJZXfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:54 -0400
Received: by mail-pf0-f194.google.com with SMTP id i5so3609372pfe.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:54 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  2 +-
 net/ipv4/tcp_input.c       |  3 +--
 net/ipv4/tcp_minisocks.c   |  2 +-
 6 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 3875fdf6b18653477408beb25176eac849e65ba4..f0e792beeea974b0850090d7624a3d7490124067 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -136,6 +136,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_stdurg;
 	int sysctl_tcp_rfc1337;
 	int sysctl_tcp_abort_on_overflow;
+	int sysctl_tcp_fack;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e28471ce52bd815346676931075588d59306a441..38504d5ab109454219ac9570c3b11e02733384c1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -241,7 +241,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_max_orphans;
-extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_max_reordering;
 extern int sysctl_tcp_dsack;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index ffd1fd769bba7c3524aa6dfac734e1de0cad1506..1f23be13ce7be8b2a12b82aada36c6351fdfb70a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -414,13 +414,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.procname	= "tcp_fack",
-		.data		= &sysctl_tcp_fack,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_max_reordering",
 		.data		= &sysctl_tcp_max_reordering,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_fack",
+		.data		= &init_net.ipv4.sysctl_tcp_fack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8f36277e82e9dbea750ce66b73018a81b30b5156..4a777ba113b9afe118e3020da65878d85848e1cb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2511,7 +2511,7 @@ static int tcp_repair_options_est(struct sock *sk,
 				return -EINVAL;
 
 			tp->rx_opt.sack_ok |= TCP_SACK_SEEN;
-			if (sysctl_tcp_fack)
+			if (sock_net(sk)->ipv4.sysctl_tcp_fack)
 				tcp_enable_fack(tp);
 			break;
 		case TCPOPT_TIMESTAMP:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d2d3f62387a98d7f955f8c9e27320b9722035b2a..8941fc32072b69fedcb01afbe837f4d7791dd28d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,7 +77,6 @@
 #include <linux/errqueue.h>
 #include <trace/events/tcp.h>
 
-int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
@@ -5690,7 +5689,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			tp->tcp_header_len = sizeof(struct tcphdr);
 		}
 
-		if (tcp_is_sack(tp) && sysctl_tcp_fack)
+		if (tcp_is_sack(tp) && sock_net(sk)->ipv4.sysctl_tcp_fack)
 			tcp_enable_fack(tp);
 
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a79a89fdb558a5d66ec5241fdb8bfcab196c744d..eba61f77bc36e4f49580d15840c15af565b8b479 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -491,7 +491,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->rx_opt.tstamp_ok = ireq->tstamp_ok;
 		if ((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
-			if (sysctl_tcp_fack)
+			if (sock_net(sk)->ipv4.sysctl_tcp_fack)
 				tcp_enable_fack(newtp);
 		}
 		newtp->window_clamp = req->rsk_window_clamp;
-- 
2.15.0.rc2.357.g7e34df9404-goog
