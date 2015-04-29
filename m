From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ipv6: Flow label state ranges
Date: Wed, 29 Apr 2015 15:33:21 -0700
Message-ID: <1430346801-2297436-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51600 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbbD2Wdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:33:39 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3TMV5cU024515
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:33:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u370j84sf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:33:38 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c6f52624eebf11e4aa650002c9521c9e-bfbfd6c0 for <netdev@vger.kernel.org>;	Wed,
 29 Apr 2015 15:33:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch divides the IPv6 flow label space into two ranges:
0-7ffff is reserved for flow label manager, 80000-fffff will be
used for creating auto flow labels (per RFC6438). This only affects how
labels are set on transmit, it does not affect receive. This range split
can be disbaled by systcl.

Background:

IPv6 flow labels have been an unmitigated disappointment thus far
in the lifetime of IPv6. Support in HW devices to use them for ECMP
is lacking, and OSes don't turn them on by default. If we had these
we could get much better hashing in IPv6 networks without resorting
to DPI, possibly eliminating some of the motivations to to define new
encaps in UDP just for getting ECMP.

Unfortunately, the initial specfications of IPv6 did not clarify
how they are to be used. There has always been a vague concept that
these can be used for ECMP, flow hashing, etc. and we do now have a
good standard how to this in RFC6438. The problem is that flow labels
can be either stateful or stateless (as in RFC6438), and we are
presented with the possibility that a stateless label may collide
with a stateful one.  Attempts to split the flow label space were
rejected in IETF. When we added support in Linux for RFC6438, we
could not turn on flow labels by default due to this conflict.

This patch splits the flow label space and should give us
a path to enabling auto flow labels by default for all IPv6 packets.
This is an API change so we need to consider compatibility with
existing deployment. The stateful range is chosen to be the lower
values in hopes that most uses would have chosen small numbers.

Once we resolve the stateless/stateful issue, we can proceed to
look at enabling RFC6438 flow labels by default (starting with
scaled testing).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 8 ++++++++
 include/net/ipv6.h                     | 9 +++++++--
 include/net/netns/ipv6.h               | 1 +
 net/ipv6/af_inet6.c                    | 1 +
 net/ipv6/ip6_flowlabel.c               | 4 ++++
 net/ipv6/sysctl_net_ipv6.c             | 8 ++++++++
 6 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 071fb18..5095c63 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1213,6 +1213,14 @@ auto_flowlabels - BOOLEAN
 	FALSE: disabled
 	Default: false
 
+flowlabel_state_ranges - BOOLEAN
+	Split the flow label number space into two ranges. 0-0x7FFFF is
+	reserved for the IPv6 flow manager facility, 0x80000-0xFFFFF
+	is reserved for stateless flow labels as described in RFC6437.
+	TRUE: enabled
+	FALSE: disabled
+	Default: true
+
 anycast_src_echo_reply - BOOLEAN
 	Controls the use of anycast addresses as source addresses for ICMPv6
 	echo reply
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index eec8ad3..53d25ef 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -239,8 +239,10 @@ struct ip6_flowlabel {
 	struct net		*fl_net;
 };
 
-#define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
-#define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
+#define IPV6_FLOWINFO_MASK		cpu_to_be32(0x0FFFFFFF)
+#define IPV6_FLOWLABEL_MASK		cpu_to_be32(0x000FFFFF)
+#define IPV6_FLOWLABEL_STATELESS_FLAG	cpu_to_be32(0x00080000)
+
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 #define IPV6_TCLASS_SHIFT	20
 
@@ -719,6 +721,9 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 		hash ^= hash >> 12;
 
 		flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
+
+		if (net->ipv6.sysctl.flowlabel_state_ranges)
+			flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
 	}
 
 	return flowlabel;
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index d2527bf..8d93544 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -34,6 +34,7 @@ struct netns_sysctl_ipv6 {
 	int fwmark_reflect;
 	int idgen_retries;
 	int idgen_delay;
+	int flowlabel_state_ranges;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index eef63b3..4632afa 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -768,6 +768,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.auto_flowlabels = 0;
 	net->ipv6.sysctl.idgen_retries = 3;
 	net->ipv6.sysctl.idgen_delay = 1 * HZ;
+	net->ipv6.sysctl.flowlabel_state_ranges = 1;
 	atomic_set(&net->ipv6.fib6_sernum, 1);
 
 	err = ipv6_init_mibs(net);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index d491125..1f9ebe3 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -595,6 +595,10 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		if (freq.flr_label & ~IPV6_FLOWLABEL_MASK)
 			return -EINVAL;
 
+		if (net->ipv6.sysctl.flowlabel_state_ranges &&
+		    (freq.flr_label & IPV6_FLOWLABEL_STATELESS_FLAG))
+			return -ERANGE;
+
 		fl = fl_create(net, sk, &freq, optval, optlen, &err);
 		if (!fl)
 			return err;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index abcc79f..4e705ad 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -68,6 +68,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "flowlabel_state_ranges",
+		.data		= &init_net.ipv6.sysctl.flowlabel_state_ranges,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -109,6 +116,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[4].data = &net->ipv6.sysctl.fwmark_reflect;
 	ipv6_table[5].data = &net->ipv6.sysctl.idgen_retries;
 	ipv6_table[6].data = &net->ipv6.sysctl.idgen_delay;
+	ipv6_table[7].data = &net->ipv6.sysctl.flowlabel_state_ranges;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.8.1
