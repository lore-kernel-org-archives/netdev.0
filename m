From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 3/3] ipv6: add ip6_flowlabel_consistency sysctl
Date: Tue, 14 Jan 2014 18:50:16 +0100
Message-ID: <1389721816-21165-3-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1389721816-21165-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:45462 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703AbaANRuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 12:50:19 -0500
In-Reply-To: <1389721816-21165-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of IPV6_FL_F_REFLECT, there is no guarantee of
flow label unicity. This patch introduces a new sysctl to protect the old
behaviour, enable by default.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++++
 include/net/netns/ipv6.h               | 1 +
 kernel/sysctl_binary.c                 | 1 +
 net/ipv6/af_inet6.c                    | 1 +
 net/ipv6/ip6_flowlabel.c               | 7 +++++++
 net/ipv6/sysctl_net_ipv6.c             | 8 ++++++++
 6 files changed, 26 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c97932c..7453640 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1118,6 +1118,14 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+ip6_flowlabel_consistency - BOOLEAN
+	Protect the consistency (and unicity) of flow label.
+	You have to disable it to use IPV6_FL_F_REFLECT flag on the
+	flow label manager.
+	TRUE: enabled
+	FALSE: disabled
+	Default: TRUE
+
 anycast_src_echo_reply - BOOLEAN
 	Controls the use of anycast addresses as source addresses for ICMPv6
 	echo reply
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 76fc7d1..3cc291b 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -27,6 +27,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_gc_elasticity;
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
+	int ip6_flowlabel_consistency;
 	int icmpv6_time;
 };
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 653cbbd..7c32501 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -557,6 +557,7 @@ static const struct bin_table bin_net_ipv6_table[] = {
 	{ CTL_DIR,	NET_IPV6_ROUTE,		"route",	bin_net_ipv6_route_table },
 	{ CTL_DIR,	NET_IPV6_ICMP,		"icmp",		bin_net_ipv6_icmp_table },
 	{ CTL_INT,	NET_IPV6_BINDV6ONLY,		"bindv6only" },
+	{ CTL_INT,	NET_IPV6_FLOWLABEL_CONSISTENCY,	"ip6_flowlabel_consistency" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_HIGH_THRESH,	"ip6frag_high_thresh" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_LOW_THRESH,	"ip6frag_low_thresh" },
 	{ CTL_INT,	NET_IPV6_IP6FRAG_TIME,		"ip6frag_time" },
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c921d5d..943c796 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -775,6 +775,7 @@ static int __net_init inet6_net_init(struct net *net)
 
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
+	net->ipv6.sysctl.ip6_flowlabel_consistency = 1;
 	atomic_set(&net->ipv6.rt_genid, 0);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 2c0f9dc..85f0453 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -587,8 +587,15 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 	case IPV6_FL_A_GET:
 		if (freq.flr_flags & IPV6_FL_F_REFLECT) {
+			struct net *net = sock_net(sk);
+			if (net->ipv6.sysctl.ip6_flowlabel_consistency) {
+				pr_info("Can not set IPV6_FL_F_REFLECT if ip6_flowlabel_consistency sysctl is enable \n");
+				return -EPERM;
+			}
+
 			if (sk->sk_protocol != IPPROTO_TCP)
 				return -ENOPROTOOPT;
+
 			np->repflow = 1;
 			return 0;
 		}
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 6b6a2c8..8c99cf0 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -31,6 +31,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ip6_flowlabel_consistency",
+		.data		= &init_net.ipv6.sysctl.ip6_flowlabel_consistency,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -59,6 +66,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.anycast_src_echo_reply;
+	ipv6_table[2].data = &net->ipv6.sysctl.ip6_flowlabel_consistency;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.8.5.2
