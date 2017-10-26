From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/15] tcp: Namespace-ify sysctl_tcp_abort_on_overflow
Date: Thu, 26 Oct 2017 16:35:19 -0700
Message-ID: <20171026233526.6155-9-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:57155 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932442AbdJZXfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:52 -0400
Received: by mail-pg0-f66.google.com with SMTP id m18so3876262pgd.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:52 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_minisocks.c   |  4 +---
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 968edce38eb5d3399724b3142277eab44f19f2fb..3875fdf6b18653477408beb25176eac849e65ba4 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -135,6 +135,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_retrans_collapse;
 	int sysctl_tcp_stdurg;
 	int sysctl_tcp_rfc1337;
+	int sysctl_tcp_abort_on_overflow;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7f88987bc62dd76206c15eb91f2990d4469e5421..e28471ce52bd815346676931075588d59306a441 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_abort_on_overflow;
 extern int sysctl_tcp_max_orphans;
 extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 832e554235df37770809541ad8f9f1ca2f201739..ffd1fd769bba7c3524aa6dfac734e1de0cad1506 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -393,13 +393,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_abort_on_overflow",
-		.data		= &sysctl_tcp_abort_on_overflow,
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
+		.procname	= "tcp_abort_on_overflow",
+		.data		= &init_net.ipv4.sysctl_tcp_abort_on_overflow,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2abaa4c1fe0108f2645d8e783ae6b48e87a82fb3..a79a89fdb558a5d66ec5241fdb8bfcab196c744d 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -28,8 +28,6 @@
 #include <net/xfrm.h>
 #include <net/busy_poll.h>
 
-int sysctl_tcp_abort_on_overflow __read_mostly;
-
 static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
@@ -764,7 +762,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	return inet_csk_complete_hashdance(sk, child, req, own_req);
 
 listen_overflow:
-	if (!sysctl_tcp_abort_on_overflow) {
+	if (!sock_net(sk)->ipv4.sysctl_tcp_abort_on_overflow) {
 		inet_rsk(req)->acked = 1;
 		return NULL;
 	}
-- 
2.15.0.rc2.357.g7e34df9404-goog
