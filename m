From: Nikolay Borisov <kernel@kyup.com>
Subject: [RESEND PATCH 6/9] ipv4: Namespaceify tcp_retries2 sysctl knob
Date: Wed,  3 Feb 2016 09:46:54 +0200
Message-ID: <1454485617-16541-7-git-send-email-kernel@kyup.com>
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
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  3 ++-
 net/ipv4/tcp_timer.c       |  5 ++---
 6 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 250bd940eb94..3cb2073c55f5 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -100,6 +100,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_syncookies;
 	int sysctl_tcp_reordering;
 	int sysctl_tcp_retries1;
+	int sysctl_tcp_retries2;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 60ee244772c9..9b3aabbac85e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 12216ec333b4..39c302fda534 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -321,13 +321,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_retries2",
-		.data		= &sysctl_tcp_retries2,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra2		= &tcp_retr1_max
 	},
+	{
+		.procname	= "tcp_retries2",
+		.data		= &init_net.ipv4.sysctl_tcp_retries2,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ea5ed84f4fb1..3a2db4a7d651 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2386,6 +2386,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_syncookies = 0;
 	net->ipv4.sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
 	net->ipv4.sysctl_tcp_retries1 = TCP_RETR1;
+	net->ipv4.sysctl_tcp_retries2 = TCP_RETR2;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9bfc39ff2285..e997488b2f8f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3471,6 +3471,7 @@ void tcp_send_probe0(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	unsigned long probe_max;
 	int err;
 
@@ -3484,7 +3485,7 @@ void tcp_send_probe0(struct sock *sk)
 	}
 
 	if (err <= 0) {
-		if (icsk->icsk_backoff < sysctl_tcp_retries2)
+		if (icsk->icsk_backoff < net->ipv4.sysctl_tcp_retries2)
 			icsk->icsk_backoff++;
 		icsk->icsk_probes_out++;
 		probe_max = TCP_RTO_MAX;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 6694e33149b9..09f4e0297e56 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,7 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
@@ -189,7 +188,7 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 		}
 
-		retry_until = sysctl_tcp_retries2;
+		retry_until = net->ipv4.sysctl_tcp_retries2;
 		if (sock_flag(sk, SOCK_DEAD)) {
 			const bool alive = icsk->icsk_rto < TCP_RTO_MAX;
 
@@ -303,7 +302,7 @@ static void tcp_probe_timer(struct sock *sk)
 		 (s32)(tcp_time_stamp - start_ts) > icsk->icsk_user_timeout)
 		goto abort;
 
-	max_probes = sysctl_tcp_retries2;
+	max_probes = sock_net(sk)->ipv4.sysctl_tcp_retries2;
 	if (sock_flag(sk, SOCK_DEAD)) {
 		const bool alive = inet_csk_rto_backoff(icsk, TCP_RTO_MAX) < TCP_RTO_MAX;
 
-- 
2.5.0
