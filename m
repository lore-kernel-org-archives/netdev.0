From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/5] ipv6: Implement different admin modes for automatic flow labels
Date: Fri, 31 Jul 2015 16:52:12 -0700
Message-ID: <1438386734-1942188-4-git-send-email-tom@herbertland.com>
References: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9676 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbbGaX6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:58:39 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6VNwbqP018059
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:58:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w0hd9gdpx-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:58:39 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 acefb20837df11e5a2e824be0593f280-b9ff32b0 for <netdev@vger.kernel.org>;	Fri,
 31 Jul 2015 16:55:52 -0700
In-Reply-To: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the meaning of net.ipv6.auto_flowlabels to provide a mode for
automatic flow labels generation. There are four modes:

0: flow labels are disabled
1: flow labels are enabled, sockets can opt-out
2: flow labels are allowed, sockets can opt-in
3: flow labels are enabled and enforced, no opt-out for sockets

np->autoflowlabel is initialized according to the sysctl value.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 20 ++++++++----
 include/net/ipv6.h                     | 59 ++++++++++++++++++++++++++--------
 net/ipv6/af_inet6.c                    |  3 +-
 net/ipv6/ip6_gre.c                     |  4 +--
 net/ipv6/ip6_tunnel.c                  |  2 +-
 net/ipv6/sysctl_net_ipv6.c             |  7 +++-
 6 files changed, 70 insertions(+), 25 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 00d26d9..9ac3af3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1215,14 +1215,20 @@ flowlabel_consistency - BOOLEAN
 	FALSE: disabled
 	Default: TRUE
 
-auto_flowlabels - BOOLEAN
-	Automatically generate flow labels based based on a flow hash
-	of the packet. This allows intermediate devices, such as routers,
-	to idenfify packet flows for mechanisms like Equal Cost Multipath
+auto_flowlabels - INTEGER
+	Automatically generate flow labels based on a flow hash of the
+	packet. This allows intermediate devices, such as routers, to
+	identify packet flows for mechanisms like Equal Cost Multipath
 	Routing (see RFC 6438).
-	TRUE: enabled
-	FALSE: disabled
-	Default: false
+	0: automatic flow labels are completely disabled
+	1: automatic flow labels are enabled by default, they can be
+	   disabled on a per socket basis using the IPV6_AUTOFLOWLABEL
+	   socket option
+	2: automatic flow labels are allowed, they may be enabled on a
+	   per socket basis using the IPV6_AUTOFLOWLABEL socket option
+	3: automatic flow labels are enabled and enforced, they cannot
+	   be disabled by the socket option
+	Default: 0
 
 flowlabel_state_ranges - BOOLEAN
 	Split the flow label number space into two ranges. 0-0x7FFFF is
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d6bf7f1..f8e755b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -707,36 +707,69 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+
+/* Sysctl settings for net ipv6.auto_flowlabels */
+#define IP6_AUTO_FLOW_LABEL_OFF		0
+#define IP6_AUTO_FLOW_LABEL_OPTOUT	1
+#define IP6_AUTO_FLOW_LABEL_OPTIN	2
+#define IP6_AUTO_FLOW_LABEL_FORCED	3
+
+#define IP6_AUTO_FLOW_LABEL_MAX		IP6_AUTO_FLOW_LABEL_FORCED
+
+#define IP6_DEFAULT_AUTO_FLOW_LABELS	IP6_AUTO_FLOW_LABEL_OFF
+
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel,
 					struct flowi6 *fl6)
 {
-	if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
-		u32 hash;
+	u32 hash;
 
-		hash = skb_get_hash_flowi6(skb, fl6);
+	if (flowlabel ||
+	    net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
+	    (!autolabel &&
+	     net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
+		return flowlabel;
 
-		/* Since this is being sent on the wire obfuscate hash a bit
-		 * to minimize possbility that any useful information to an
-		 * attacker is leaked. Only lower 20 bits are relevant.
-		 */
-		hash ^= hash >> 12;
+	hash = skb_get_hash_flowi6(skb, fl6);
 
-		flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
+	/* Since this is being sent on the wire obfuscate hash a bit
+	 * to minimize possbility that any useful information to an
+	 * attacker is leaked. Only lower 20 bits are relevant.
+	 */
+	rol32(hash, 16);
 
-		if (net->ipv6.sysctl.flowlabel_state_ranges)
-			flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
-	}
+	flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
+
+	if (net->ipv6.sysctl.flowlabel_state_ranges)
+		flowlabel |= IPV6_FLOWLABEL_STATELESS_FLAG;
 
 	return flowlabel;
 }
+
+static inline int ip6_default_np_autolabel(struct net *net)
+{
+	switch (net->ipv6.sysctl.auto_flowlabels) {
+	case IP6_AUTO_FLOW_LABEL_OFF:
+	case IP6_AUTO_FLOW_LABEL_OPTIN:
+	default:
+		return 0;
+	case IP6_AUTO_FLOW_LABEL_OPTOUT:
+	case IP6_AUTO_FLOW_LABEL_FORCED:
+		return 1;
+	}
+}
 #else
 static inline void ip6_set_txhash(struct sock *sk) { }
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
-					__be32 flowlabel, bool autolabel)
+					__be32 flowlabel, bool autolabel,
+					struct flowi6 *fl6)
 {
 	return flowlabel;
 }
+static inline int ip6_default_np_autolabel(struct net *net)
+{
+	return 0;
+}
 #endif
 
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7bc92ea..3f0ae3a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -197,6 +197,7 @@ lookup_protocol:
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
+	np->autoflowlabel = ip6_default_np_autolabel(sock_net(sk));
 	sk->sk_ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
@@ -767,7 +768,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
-	net->ipv6.sysctl.auto_flowlabels = 0;
+	net->ipv6.sysctl.auto_flowlabels = IP6_DEFAULT_AUTO_FLOW_LABELS;
 	net->ipv6.sysctl.idgen_retries = 3;
 	net->ipv6.sysctl.idgen_delay = 1 * HZ;
 	net->ipv6.sysctl.flowlabel_state_ranges = 1;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a7d1ca2..34f1218 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -728,7 +728,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	 */
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false, fl6));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
 	ipv6h->hop_limit = tunnel->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
@@ -1182,7 +1182,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 
 	ip6_flow_hdr(ipv6h, 0,
 		     ip6_make_flowlabel(dev_net(dev), skb,
-					t->fl.u.ip6.flowlabel, false,
+					t->fl.u.ip6.flowlabel, true,
 					&t->fl.u.ip6));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = NEXTHDR_GRE;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 54e694c..b0ab420 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1095,7 +1095,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	skb_reset_network_header(skb);
 	ipv6h = ipv6_hdr(skb);
 	ip6_flow_hdr(ipv6h, INET_ECN_encapsulate(0, dsfield),
-		     ip6_make_flowlabel(net, skb, fl6->flowlabel, false, fl6));
+		     ip6_make_flowlabel(net, skb, fl6->flowlabel, true, fl6));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index db48aeb..45243bb 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,6 +17,9 @@
 #include <net/inet_frag.h>
 
 static int one = 1;
+static int auto_flowlabels_min;
+static int auto_flowlabels_max = IP6_AUTO_FLOW_LABEL_MAX;
+
 
 static struct ctl_table ipv6_table_template[] = {
 	{
@@ -45,7 +48,9 @@ static struct ctl_table ipv6_table_template[] = {
 		.data		= &init_net.ipv6.sysctl.auto_flowlabels,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &auto_flowlabels_min,
+		.extra2		= &auto_flowlabels_max
 	},
 	{
 		.procname	= "fwmark_reflect",
-- 
1.8.5.6
