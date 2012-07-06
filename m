From: pablo@netfilter.org
Subject: [PATCH 15/18] netfilter: nf_conntrack: generalize nf_ct_l4proto_net
Date: Fri,  6 Jul 2012 13:17:05 +0200
Message-ID: <1341573428-3204-16-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch generalizes nf_ct_l4proto_net by splitting it into chunks and
moving the corresponding protocol part to where it really belongs to.

To clarify, note that we follow two different approaches to support per-net
depending if it's built-in or run-time loadable protocol tracker.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |    3 +++
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 ++++++
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    6 ++++++
 net/netfilter/nf_conntrack_proto.c             |   22 ++++++----------------
 net/netfilter/nf_conntrack_proto_generic.c     |    6 ++++++
 net/netfilter/nf_conntrack_proto_tcp.c         |    7 +++++++
 net/netfilter/nf_conntrack_proto_udp.c         |    7 +++++++
 7 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 08bb571..c3be4ae 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -99,6 +99,9 @@ struct nf_conntrack_l4proto {
 	/* Init l4proto pernet data */
 	int (*init_net)(struct net *net, u_int16_t proto);
 
+	/* Return the per-net protocol part. */
+	struct nf_proto_net *(*get_net_proto)(struct net *net);
+
 	/* Protocol name */
 	const char *name;
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 9c2095c..5241d99 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -388,6 +388,11 @@ static int icmp_init_net(struct net *net, u_int16_t proto)
 	return ret;
 }
 
+static struct nf_proto_net *icmp_get_net_proto(struct net *net)
+{
+	return &net->ct.nf_ct_proto.icmp.pn;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -418,4 +423,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= icmp_init_net,
+	.get_net_proto		= icmp_get_net_proto,
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 9fc5cf5..2d54b20 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -358,6 +358,11 @@ static int icmpv6_init_net(struct net *net, u_int16_t proto)
 	return icmpv6_kmemdup_sysctl_table(pn, in);
 }
 
+static struct nf_proto_net *icmpv6_get_net_proto(struct net *net)
+{
+	return &net->ct.nf_ct_proto.icmpv6.pn;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
@@ -386,4 +391,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= icmpv6_init_net,
+	.get_net_proto		= icmpv6_get_net_proto,
 };
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 21b850c..0dc6385 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -303,22 +303,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
-	switch (l4proto->l4proto) {
-	case IPPROTO_TCP:
-		return (struct nf_proto_net *)&net->ct.nf_ct_proto.tcp;
-	case IPPROTO_UDP:
-		return (struct nf_proto_net *)&net->ct.nf_ct_proto.udp;
-	case IPPROTO_ICMP:
-		return (struct nf_proto_net *)&net->ct.nf_ct_proto.icmp;
-	case IPPROTO_ICMPV6:
-		return (struct nf_proto_net *)&net->ct.nf_ct_proto.icmpv6;
-	case 255: /* l4proto_generic */
-		return (struct nf_proto_net *)&net->ct.nf_ct_proto.generic;
-	default:
-		if (l4proto->net_id)
-			return net_generic(net, *l4proto->net_id);
-		else
-			return NULL;
+	if (l4proto->get_net_proto) {
+		/* statically built-in protocols use static per-net */
+		return l4proto->get_net_proto(net);
+	} else if (l4proto->net_id) {
+		/* ... and loadable protocols use dynamic per-net */
+		return net_generic(net, *l4proto->net_id);
 	}
 	return NULL;
 }
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 7c11c54..d25f293 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -186,6 +186,11 @@ static int generic_init_net(struct net *net, u_int16_t proto)
 	return ret;
 }
 
+static struct nf_proto_net *generic_get_net_proto(struct net *net)
+{
+	return &net->ct.nf_ct_proto.generic.pn;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 {
 	.l3proto		= PF_UNSPEC,
@@ -207,4 +212,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= generic_init_net,
+	.get_net_proto		= generic_get_net_proto,
 };
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44f0da8..07e56ea 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1623,6 +1623,11 @@ static int tcp_init_net(struct net *net, u_int16_t proto)
 	return ret;
 }
 
+static struct nf_proto_net *tcp_get_net_proto(struct net *net)
+{
+	return &net->ct.nf_ct_proto.tcp.pn;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -1656,6 +1661,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= tcp_init_net,
+	.get_net_proto		= tcp_get_net_proto,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 
@@ -1692,5 +1698,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= tcp_init_net,
+	.get_net_proto		= tcp_get_net_proto,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index e7e0434..59623cc 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -297,6 +297,11 @@ static int udp_init_net(struct net *net, u_int16_t proto)
 	return ret;
 }
 
+static struct nf_proto_net *udp_get_net_proto(struct net *net)
+{
+	return &net->ct.nf_ct_proto.udp.pn;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -325,6 +330,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= udp_init_net,
+	.get_net_proto		= udp_get_net_proto,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -356,5 +362,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.init_net		= udp_init_net,
+	.get_net_proto		= udp_get_net_proto,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
-- 
1.7.10

