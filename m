From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 3/3] ipv4: Create probe timer for tcp PMTU as per RFC4821
Date: Fri, 13 Feb 2015 16:16:45 +0800
Message-ID: <1423815405-32644-4-git-send-email-fan.du@intel.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
Cc: netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7254 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbbBMIVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 03:21:23 -0500
In-Reply-To: <1423815405-32644-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
be armed once probing has converged. Once this timer expired,
probing again to take advantage of any path PMTU change. The
recommended probing interval is 10 minutes per RFC1981.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/net/inet_connection_sock.h |    2 ++
 include/net/netns/ipv4.h           |    1 +
 include/net/tcp.h                  |    3 +++
 net/ipv4/sysctl_net_ipv4.c         |    7 +++++++
 net/ipv4/tcp.c                     |    2 ++
 net/ipv4/tcp_ipv4.c                |    1 +
 net/ipv4/tcp_output.c              |   23 ++++++++++++++++++++++-
 7 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 3d0932e..e78e5ab 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -126,6 +126,8 @@ struct inet_connection_sock {
 
 		int		  search_high_sav;
 		int		  search_low_sav;
+
+		struct timer_list probe_timer;
 
 		/* Information on the current probe. */
 		int		  probe_size;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index dbe2254..bb2c2d1 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -84,6 +84,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_fwmark_accept;
 	int sysctl_tcp_mtu_probing;
 	int sysctl_tcp_base_mss;
+	u32 sysctl_tcp_probe_interval;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7b57e5b..16fa2e6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -67,6 +67,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* The least MTU to use for probing */
 #define TCP_BASE_MSS		1024
 
+/* probing interval, default to 10 minutes as per RFC4821 */
+#define TCP_PROBE_INTERVAL	600
+
 /* After receiving this amount of duplicate ACKs fast retransmit starts. */
 #define TCP_FASTRETRANS_THRESH 3
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d151539..4fa5d31 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -883,6 +883,13 @@ static struct ctl_table ipv4_net_table[] = {
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
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d72a0f..46413ee 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1986,6 +1986,7 @@ void tcp_close(struct sock *sk, long timeout)
 	struct sk_buff *skb;
 	int data_was_unread = 0;
 	int state;
+	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	lock_sock(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
@@ -2149,6 +2150,7 @@ adjudge_to_death:
 	/* Otherwise, socket is reprieved until protocol close. */
 
 out:
+	del_timer(&icsk->icsk_mtup.probe_timer);
 	bh_unlock_sock(sk);
 	local_bh_enable();
 	sock_put(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a2dfed..3cc71b3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2460,6 +2460,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	}
 	net->ipv4.sysctl_tcp_ecn = 2;
 	net->ipv4.sysctl_tcp_base_mss = TCP_BASE_MSS;
+	net->ipv4.sysctl_tcp_probe_interval = TCP_PROBE_INTERVAL;
 	return 0;
 
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0a60deb..461b4a4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1342,6 +1342,18 @@ int tcp_mss_to_mtu(struct sock *sk, int mss)
 	return mtu;
 }
 
+static void icsk_mtup_probe_timer(unsigned long arg)
+{
+	struct sock *sk = (struct sock *)arg;
+	struct net *net = sock_net(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	/* Restore orignal search range */
+	icsk->icsk_mtup.search_high = icsk->icsk_mtup.search_high_sav;
+	icsk->icsk_mtup.search_low = icsk->icsk_mtup.search_low_sav;
+	icsk->icsk_mtup.probe_size = 0;
+}
+
 /* MTU probing init per socket */
 void tcp_mtup_init(struct sock *sk)
 {
@@ -1357,6 +1369,9 @@ void tcp_mtup_init(struct sock *sk)
 	icsk->icsk_mtup.search_high_sav = icsk->icsk_mtup.search_high;
 	icsk->icsk_mtup.search_low_sav = icsk->icsk_mtup.search_low;
 	icsk->icsk_mtup.probe_size = 0;
+
+	setup_timer(&icsk->icsk_mtup.probe_timer, icsk_mtup_probe_timer,
+		    (unsigned long)sk);
 }
 EXPORT_SYMBOL(tcp_mtup_init);
 
@@ -1840,6 +1855,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sk_buff *skb, *nskb, *next;
+	struct net *net = sock_net(sk);
 	int len;
 	int probe_size;
 	int size_needed;
@@ -1865,7 +1881,12 @@ static int tcp_mtu_probe(struct sock *sk)
 	probe_size = (icsk->icsk_mtup.search_high + icsk->icsk_mtup.search_low) >> 1;
 	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
-		/* TODO: set timer for probe_converge_event */
+		u32 probe_interval = net->ipv4.sysctl_tcp_probe_interval;
+
+		/* Search has been converged, start the timer,
+		 * take advantage of path changing */
+		mod_timer(&icsk->icsk_mtup.probe_timer,
+			  jiffies + msecs_to_jiffies(1000*probe_interval));
 		return -1;
 	}
 
-- 
1.7.1
