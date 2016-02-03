From: Nikolay Borisov <kernel@kyup.com>
Subject: [RESEND PATCH 5/9] ipv4: Namespaceify tcp_retries1 sysctl knob
Date: Wed,  3 Feb 2016 09:46:53 +0200
Message-ID: <1454485617-16541-6-git-send-email-kernel@kyup.com>
References: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Cc: edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 16 ++++++++--------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_timer.c       |  8 ++++----
 5 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index dff8879e02fe..250bd940eb94 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -99,6 +99,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_synack_retries;
 	int sysctl_tcp_syncookies;
 	int sysctl_tcp_reordering;
+	int sysctl_tcp_retries1;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 64d01d289441..60ee244772c9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
 extern int sysctl_tcp_fastopen;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 12d752e6380b..12216ec333b4 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -321,14 +321,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_retries1",
-		.data		= &sysctl_tcp_retries1,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra2		= &tcp_retr1_max
-	},
-	{
 		.procname	= "tcp_retries2",
 		.data		= &sysctl_tcp_retries2,
 		.maxlen		= sizeof(int),
@@ -950,6 +942,14 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_retries1",
+		.data		= &init_net.ipv4.sysctl_tcp_retries1,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra2		= &tcp_retr1_max
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 785bbebd6768..ea5ed84f4fb1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2385,6 +2385,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES;
 	net->ipv4.sysctl_tcp_syncookies = 0;
 	net->ipv4.sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
+	net->ipv4.sysctl_tcp_retries1 = TCP_RETR1;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ca25fdf0c525..6694e33149b9 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,7 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
@@ -171,7 +170,7 @@ static int tcp_write_timeout(struct sock *sk)
 		retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
 		syn_set = true;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
+		if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1, 0, 0)) {
 			/* Some middle-boxes may black-hole Fast Open _after_
 			 * the handshake. Therefore we conservatively disable
 			 * Fast Open on this path on recurring timeouts with
@@ -180,7 +179,7 @@ static int tcp_write_timeout(struct sock *sk)
 			if (tp->syn_data_acked &&
 			    tp->bytes_acked <= tp->rx_opt.mss_clamp) {
 				tcp_fastopen_cache_set(sk, 0, NULL, true, 0);
-				if (icsk->icsk_retransmits == sysctl_tcp_retries1)
+				if (icsk->icsk_retransmits == net->ipv4.sysctl_tcp_retries1)
 					NET_INC_STATS_BH(sock_net(sk),
 							 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
 			}
@@ -359,6 +358,7 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 void tcp_retransmit_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	if (tp->fastopen_rsk) {
@@ -489,7 +489,7 @@ out_reset_timer:
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
+	if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1 + 1, 0, 0))
 		__sk_dst_reset(sk);
 
 out:;
-- 
2.5.0
