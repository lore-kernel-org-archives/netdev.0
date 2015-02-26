From: Fan Du <fan.du@intel.com>
Subject: [PATCHv2 net-next 4/4] ipv4: Create probe timer for tcp PMTU as per RFC4821
Date: Thu, 26 Feb 2015 11:49:26 +0800
Message-ID: <1424922566-6787-5-git-send-email-fan.du@intel.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
 <1424922566-6787-1-git-send-email-fan.du@intel.com>
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41796 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbbBZDyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 22:54:13 -0500
In-Reply-To: <1424922566-6787-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
be armed once probing has converged. Once this timer expired,
probing again to take advantage of any path PMTU change. The
recommended probing interval is 10 minutes per RFC1981. Probing
interval could be sysctled by sysctl_tcp_probe_interval.

Eric suggested to implement pseudo timer based on 32bits jiffies
tcp_time_stamp instead of using classic timer for such rare event.

Signed-off-by: Fan Du <fan.du@intel.com>
---
v2:
   - Create a pseudo timer based on 32bits jiffies tcp_time_stamp
     to control when to reprobing as suggested by Eric.
---
 include/net/inet_connection_sock.h |    2 +
 include/net/netns/ipv4.h           |    1 +
 include/net/tcp.h                  |    3 ++
 net/ipv4/sysctl_net_ipv4.c         |    7 ++++++
 net/ipv4/tcp_ipv4.c                |    1 +
 net/ipv4/tcp_output.c              |   38 ++++++++++++++++++++++++++++++++++-
 6 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 5976bde..b9a6b0a 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -126,6 +126,8 @@ struct inet_connection_sock {
 
 		/* Information on the current probe. */
 		int		  probe_size;
+
+		u32		  probe_timestamp;
 	} icsk_mtup;
 	u32			  icsk_ca_priv[16];
 	u32			  icsk_user_timeout;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 25200d4..18ebc99 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -85,6 +85,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_mtu_probing;
 	int sysctl_tcp_base_mss;
 	int sysctl_tcp_probe_threshold;
+	u32 sysctl_tcp_probe_interval;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d269c91..dd6adbc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -67,6 +67,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* The least MTU to use for probing */
 #define TCP_BASE_MSS		1024
 
+/* probing interval, default to 10 minutes as per RFC4821 */
+#define TCP_PROBE_INTERVAL	600
+
 /* Specify interval when tcp mtu probing will stop */
 #define TCP_PROBE_THRESHOLD	8
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d3c09c1..fdf8991 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -890,6 +890,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_probe_interval",
+		.data		= &init_net.ipv4.sysctl_tcp_probe_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 35790d9..f0c6fc3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2461,6 +2461,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_ecn = 2;
 	net->ipv4.sysctl_tcp_base_mss = TCP_BASE_MSS;
 	net->ipv4.sysctl_tcp_probe_threshold = TCP_PROBE_THRESHOLD;
+	net->ipv4.sysctl_tcp_probe_interval = TCP_PROBE_INTERVAL;
 	return 0;
 
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c418829..0e9ee6a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1354,6 +1354,8 @@ void tcp_mtup_init(struct sock *sk)
 			       icsk->icsk_af_ops->net_header_len;
 	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
 	icsk->icsk_mtup.probe_size = 0;
+	if (icsk->icsk_mtup.enabled)
+		icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
 }
 EXPORT_SYMBOL(tcp_mtup_init);
 
@@ -1823,6 +1825,35 @@ send_now:
 	return false;
 }
 
+static inline void tcp_mtu_check_reprobe(struct sock *sk)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct net *net = sock_net(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	u32 delta;
+	u32 now = tcp_time_stamp;
+	u32 interval = net->ipv4.sysctl_tcp_probe_interval;
+
+	if (likely(now > icsk->icsk_mtup.probe_timestamp))
+		delta = now - icsk->icsk_mtup.probe_timestamp;
+	else
+		delta = now + (U32_MAX - icsk->icsk_mtup.probe_timestamp);
+	if (unlikely(jiffies_to_msecs(delta) >= interval * MSEC_PER_SC)) {
+		int mss = tcp_current_mss(sk);
+
+		/* Update current search range */
+		icsk->icsk_mtup.search_high = tp->rx_opt.mss_clamp +
+			sizeof(struct tcphdr) +
+			icsk->icsk_af_ops->net_header_len;
+		icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
+		icsk->icsk_mtup.probe_size = 0;
+
+		/* Update probe time stamp */
+		icsk->icsk_mtup.probe_timestamp = now;
+	}
+}
+
 /* Create a new MTU probe if we are ready.
  * MTU probe is regularly attempting to increase the path MTU by
  * deliberately sending larger packets.  This discovers routing
@@ -1866,8 +1897,11 @@ static int tcp_mtu_probe(struct sock *sk)
 	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
-	    interval < net->ipv4.sysctl_tcp_probe_threshold) {
-		/* TODO: set timer for probe_converge_event */
+		interval < net->ipv4.sysctl_tcp_probe_threshold) {
+		/* Check whether enough time has elaplased for
+		 * another round of probing.
+		 */
+		tcp_mtu_check_reprobe(sk);
 		return -1;
 	}
 
-- 
1.7.1
