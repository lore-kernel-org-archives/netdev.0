From: Fan Du <fan.du@intel.com>
Subject: [PATCHv2 net-next] ipv4: Namespecify TCP PMTU mechanism
Date: Tue, 10 Feb 2015 09:53:16 +0800
Message-ID: <1423533196-22166-1-git-send-email-fan.du@intel.com>
References: <1423471498-22442-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62144 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759522AbbBJB5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 20:57:35 -0500
In-Reply-To: <1423471498-22442-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packetization Layer Path MTU Discovery works separately beside
Path MTU Discovery at IP level, different net namespace has
various requirements on which one to chose, e.g., a virutalized
container instance would require TCP PMTU to probe an usable
effective mtu for underlying tunnel, while the host would
employ classical ICMP based PMTU to function.

Hence making TCP PMTU mechanism per net namespace to decouple
two functionality. Furthermore the probe base MSS should also
be configured separately for each namespace.

Signed-off-by: Fan Du <fan.du@intel.com>
---
Changelog:
v2:
  - Respin with latest net-next
  - Remove rebundant <net/sock.h> including

---
 include/net/netns/ipv4.h   |    2 ++
 include/net/tcp.h          |    2 --
 net/ipv4/sysctl_net_ipv4.c |   28 ++++++++++++++--------------
 net/ipv4/tcp_ipv4.c        |    1 +
 net/ipv4/tcp_output.c      |    8 +++-----
 net/ipv4/tcp_timer.c       |    7 +++++--
 6 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e0bdcb1..dbe2254 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -82,6 +82,8 @@ struct netns_ipv4 {
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
+	int sysctl_tcp_mtu_probing;
+	int sysctl_tcp_base_mss;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index da4196fb..8d6b983 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -262,8 +262,6 @@ extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
-extern int sysctl_tcp_mtu_probing;
-extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 82601a6..d151539 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -604,20 +604,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_tcp_congestion_control,
 	},
 	{
-		.procname	= "tcp_mtu_probing",
-		.data		= &sysctl_tcp_mtu_probing,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "tcp_base_mss",
-		.data		= &sysctl_tcp_base_mss,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "tcp_workaround_signed_windows",
 		.data		= &sysctl_tcp_workaround_signed_windows,
 		.maxlen		= sizeof(int),
@@ -883,6 +869,20 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_mtu_probing",
+		.data		= &init_net.ipv4.sysctl_tcp_mtu_probing,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "tcp_base_mss",
+		.data		= &init_net.ipv4.sysctl_tcp_base_mss,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 67bc95f..5a2dfed 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2459,6 +2459,7 @@ static int __net_init tcp_sk_init(struct net *net)
 		*per_cpu_ptr(net->ipv4.tcp_sk, cpu) = sk;
 	}
 	net->ipv4.sysctl_tcp_ecn = 2;
+	net->ipv4.sysctl_tcp_base_mss = TCP_BASE_MSS;
 	return 0;
 
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4fcc9a7..a2a796c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,9 +59,6 @@ int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
  */
 int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 
-int sysctl_tcp_mtu_probing __read_mostly = 0;
-int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
-
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
@@ -1350,11 +1347,12 @@ void tcp_mtup_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct net *net = sock_net(sk);
 
-	icsk->icsk_mtup.enabled = sysctl_tcp_mtu_probing > 1;
+	icsk->icsk_mtup.enabled = net->ipv4.sysctl_tcp_mtu_probing > 1;
 	icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp + sizeof(struct tcphdr) +
 			       icsk->icsk_af_ops->net_header_len;
-	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, sysctl_tcp_base_mss);
+	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
 	icsk->icsk_mtup.probe_size = 0;
 }
 EXPORT_SYMBOL(tcp_mtup_init);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 1829c7f..0732b78 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -101,17 +101,20 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
 
 static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 {
+	struct net *net = sock_net(sk);
+
 	/* Black hole detection */
-	if (sysctl_tcp_mtu_probing) {
+	if (net->ipv4.sysctl_tcp_mtu_probing) {
 		if (!icsk->icsk_mtup.enabled) {
 			icsk->icsk_mtup.enabled = 1;
 			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		} else {
+			struct net *net = sock_net(sk);
 			struct tcp_sock *tp = tcp_sk(sk);
 			int mss;
 
 			mss = tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_low) >> 1;
-			mss = min(sysctl_tcp_base_mss, mss);
+			mss = min(net->ipv4.sysctl_tcp_base_mss, mss);
 			mss = max(mss, 68 - tp->tcp_header_len);
 			icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
 			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
-- 
1.7.9.5
