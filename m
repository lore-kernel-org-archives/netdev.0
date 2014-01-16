From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH V3 net-next 3/3] ipv6: add flowlabel_consistency sysctl
Date: Thu, 16 Jan 2014 17:19:18 +0100
Message-ID: <1389889158-1710-3-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57311 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749AbaAPQTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 11:19:22 -0500
In-Reply-To: <1389889158-1710-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of IPV6_FL_F_REFLECT, there is no guarantee of
flow label unicity. This patch introduces a new sysctl to protect the old
behaviour, enable by default.

Changelog of V3:
 * rename ip6_flowlabel_consistency to flowlabel_consistency
 * use net_info_ratelimited()
 * checkpatch cleanups

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++++
 include/net/netns/ipv6.h               | 1 +
 net/ipv6/af_inet6.c                    | 1 +
 net/ipv6/ip6_flowlabel.c               | 7 +++++++
 net/ipv6/sysctl_net_ipv6.c             | 8 ++++++++
 5 files changed, 25 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c97932c..5de0374 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1118,6 +1118,14 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+flowlabel_consistency - BOOLEAN
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
index 592fecd..21edaf1 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -27,6 +27,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_gc_elasticity;
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
+	int flowlabel_consistency;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
 };
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c921d5d..d935889 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -775,6 +775,7 @@ static int __net_init inet6_net_init(struct net *net)
 
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
+	net->ipv6.sysctl.flowlabel_consistency = 1;
 	atomic_set(&net->ipv6.rt_genid, 0);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 01bf252..dfa41bb 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -588,8 +588,15 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 
 	case IPV6_FL_A_GET:
 		if (freq.flr_flags & IPV6_FL_F_REFLECT) {
+			struct net *net = sock_net(sk);
+			if (net->ipv6.sysctl.flowlabel_consistency) {
+				net_info_ratelimited("Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable\n");
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
index b51b268..7f405a1 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -31,6 +31,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "flowlabel_consistency",
+		.data		= &init_net.ipv6.sysctl.flowlabel_consistency,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -59,6 +66,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
+	ipv6_table[2].data = &net->ipv6.sysctl.flowlabel_consistency;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.8.5.2
