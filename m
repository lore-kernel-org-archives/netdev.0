From: Fan Du <fan.du@intel.com>
Subject: [PATCHv2 net-next 2/4] ipv4: Use binary search to choose tcp PMTU probe_size
Date: Thu, 26 Feb 2015 11:49:24 +0800
Message-ID: <1424922566-6787-3-git-send-email-fan.du@intel.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
 <1424922566-6787-1-git-send-email-fan.du@intel.com>
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41797 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769AbbBZDyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 22:54:11 -0500
In-Reply-To: <1424922566-6787-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current probe_size is chosen by doubling mss_cache,
the initial mss base is 512 Bytes, as a result the
converged probe_size will only be 1024 Bytes, there
is still big gap between 1024 and common 1500 bytes
of mtu.

Use binary search to choose probe_size in a fine
granularity manner, an optimal mss will be found
to boost performance as its maxmium.

In addition, introduce a sysctl_tcp_probe_threshold
to control when probing will stop in respect to
the width of search range.

Test env:
Docker instance with vxlan encapuslation(82599EB)
iperf -c 10.0.0.24  -t 60

before this patch:
1.26 Gbits/sec

After this patch: increase 26%
1.59 Gbits/sec

Signed-off-by: Fan Du <fan.du@intel.com>
---
v2:
  - Use sysctl_tcp_probe_threshold to control when probing
    will stop wrt interval between search high and search low.
---
 include/net/netns/ipv4.h   |    1 +
 include/net/tcp.h          |    3 +++
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 net/ipv4/tcp_ipv4.c        |    1 +
 net/ipv4/tcp_output.c      |   14 +++++++++++---
 5 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index dbe2254..25200d4 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -84,6 +84,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_fwmark_accept;
 	int sysctl_tcp_mtu_probing;
 	int sysctl_tcp_base_mss;
+	int sysctl_tcp_probe_threshold;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7b57e5b..d269c91 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -67,6 +67,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* The least MTU to use for probing */
 #define TCP_BASE_MSS		1024
 
+/* Specify interval when tcp mtu probing will stop */
+#define TCP_PROBE_THRESHOLD	8
+
 /* After receiving this amount of duplicate ACKs fast retransmit starts. */
 #define TCP_FASTRETRANS_THRESH 3
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d151539..d3c09c1 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -883,6 +883,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_probe_threshold",
+		.data		= &init_net.ipv4.sysctl_tcp_probe_threshold,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a2dfed..35790d9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2460,6 +2460,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	}
 	net->ipv4.sysctl_tcp_ecn = 2;
 	net->ipv4.sysctl_tcp_base_mss = TCP_BASE_MSS;
+	net->ipv4.sysctl_tcp_probe_threshold = TCP_PROBE_THRESHOLD;
 	return 0;
 
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a2a796c..c418829 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1837,11 +1837,13 @@ static int tcp_mtu_probe(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sk_buff *skb, *nskb, *next;
+	struct net *net = sock_net(sk);
 	int len;
 	int probe_size;
 	int size_needed;
 	int copy;
 	int mss_now;
+	int interval;
 
 	/* Not currently probing/verifying,
 	 * not in recovery,
@@ -1854,11 +1856,17 @@ static int tcp_mtu_probe(struct sock *sk)
 	    tp->rx_opt.num_sacks || tp->rx_opt.dsack)
 		return -1;
 
-	/* Very simple search strategy: just double the MSS. */
+	/* Use binary search for probe_size bewteen tcp_mss_base,
+	 * and current mss_clamp. if (search_high - search_low)
+	 * smaller than a threshold, backoff from probing.
+	 */
 	mss_now = tcp_current_mss(sk);
-	probe_size = 2 * tp->mss_cache;
+	probe_size = (icsk->icsk_mtup.search_high +
+		      icsk->icsk_mtup.search_low) >> 1;
 	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
-	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
+	interval = icsk->icsk_mtup.search_high - icsk->icsk_mtup.search_low;
+	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
+	    interval < net->ipv4.sysctl_tcp_probe_threshold) {
 		/* TODO: set timer for probe_converge_event */
 		return -1;
 	}
-- 
1.7.1
