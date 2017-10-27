From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 09/15] tcp: Namespace-ify sysctl_tcp_fack
Date: Thu, 26 Oct 2017 21:55:04 -0700
Message-ID: <20171027045510.5827-10-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44548 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJ0Eze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:34 -0400
Received: by mail-io0-f194.google.com with SMTP id m16so10138451iod.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:34 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
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
index 7331281a229289f130ad7b5c5ddec1eba1ea2747..e7b15e9f6e288908bf58a28fe24554630c1e0710 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
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
index f6e1c00e300eeedcfe2ff0f4f2a4e1d997cd315d..c7c983f0f817c639e68f6fb1a70916cb604de90b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2517,7 +2517,7 @@ static int tcp_repair_options_est(struct sock *sk,
 				return -EINVAL;
 
 			tp->rx_opt.sack_ok |= TCP_SACK_SEEN;
-			if (sysctl_tcp_fack)
+			if (sock_net(sk)->ipv4.sysctl_tcp_fack)
 				tcp_enable_fack(tp);
 			break;
 		case TCPOPT_TIMESTAMP:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 64fde81b0eb70feccffd18a703e2b604e306ea65..c5b94460793f9693719b38978c123209e2b6ec0f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -79,7 +79,6 @@
 #include <linux/unaligned/access_ok.h>
 #include <linux/static_key.h>
 
-int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
@@ -5720,7 +5719,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			tp->tcp_header_len = sizeof(struct tcphdr);
 		}
 
-		if (tcp_is_sack(tp) && sysctl_tcp_fack)
+		if (tcp_is_sack(tp) && sock_net(sk)->ipv4.sysctl_tcp_fack)
 			tcp_enable_fack(tp);
 
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3674d63170b293778d32abd34aa32043c001aa82..3270ab8416ce8691cbb1c3a25533142fe1029bed 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -510,7 +510,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->rx_opt.tstamp_ok = ireq->tstamp_ok;
 		if ((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
-			if (sysctl_tcp_fack)
+			if (sock_net(sk)->ipv4.sysctl_tcp_fack)
 				tcp_enable_fack(newtp);
 		}
 		newtp->window_clamp = req->rsk_window_clamp;
-- 
2.15.0.rc2.357.g7e34df9404-goog
