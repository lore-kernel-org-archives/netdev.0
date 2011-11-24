From: kaber@trash.net
Subject: [PATCH 01/18] netfilter: nf_nat: export NAT definitions to userspace
Date: Thu, 24 Nov 2011 17:57:12 +0100
Message-ID: <1322153850-10533-2-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47955 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab1KXQ5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:35 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Export the NAT definitions to userspace. So far userspace (specifically,
iptables) has been copying the headers files from include/net. Also
rename some structures and definitions in preparation for IPv6 NAT.
Since these have never been officially exported, this doesn't affect
existing userspace code.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild                     |    1 +
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   27 +++++++++
 include/linux/netfilter/nf_nat.h                   |   25 +++++++++
 include/linux/netfilter_ipv4/Kbuild                |    1 -
 include/linux/netfilter_ipv4/nf_nat.h              |   58 --------------------
 include/net/netfilter/nf_conntrack_tuple.h         |    1 -
 include/net/netfilter/nf_nat.h                     |   10 ++--
 include/net/netfilter/nf_nat_core.h                |    2 +-
 include/net/netfilter/nf_nat_protocol.h            |   14 +++---
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   16 +++---
 net/ipv4/netfilter/ipt_NETMAP.c                    |   14 +++---
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   16 +++---
 net/ipv4/netfilter/nf_nat_core.c                   |   54 +++++++++---------
 net/ipv4/netfilter/nf_nat_h323.c                   |   20 ++++----
 net/ipv4/netfilter/nf_nat_helper.c                 |   10 ++--
 net/ipv4/netfilter/nf_nat_pptp.c                   |   14 +++---
 net/ipv4/netfilter/nf_nat_proto_common.c           |   24 ++++----
 net/ipv4/netfilter/nf_nat_proto_dccp.c             |    4 +-
 net/ipv4/netfilter/nf_nat_proto_gre.c              |    8 ++--
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |    4 +-
 net/ipv4/netfilter/nf_nat_proto_sctp.c             |    4 +-
 net/ipv4/netfilter/nf_nat_proto_tcp.c              |    4 +-
 net/ipv4/netfilter/nf_nat_proto_udp.c              |    4 +-
 net/ipv4/netfilter/nf_nat_proto_udplite.c          |    4 +-
 net/ipv4/netfilter/nf_nat_proto_unknown.c          |    2 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |   22 ++++----
 net/ipv4/netfilter/nf_nat_sip.c                    |   10 ++--
 net/ipv4/netfilter/nf_nat_standalone.c             |    2 +-
 net/netfilter/nf_conntrack_netlink.c               |    4 +-
 29 files changed, 185 insertions(+), 194 deletions(-)
 create mode 100644 include/linux/netfilter/nf_nat.h
 delete mode 100644 include/linux/netfilter_ipv4/nf_nat.h

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index a1b410c..d81f771 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -5,6 +5,7 @@ header-y += nf_conntrack_ftp.h
 header-y += nf_conntrack_sctp.h
 header-y += nf_conntrack_tcp.h
 header-y += nf_conntrack_tuple_common.h
+header-y += nf_nat.h
 header-y += nfnetlink.h
 header-y += nfnetlink_compat.h
 header-y += nfnetlink_conntrack.h
diff --git a/include/linux/netfilter/nf_conntrack_tuple_common.h b/include/linux/netfilter/nf_conntrack_tuple_common.h
index 2ea22b0..2f6bbc5 100644
--- a/include/linux/netfilter/nf_conntrack_tuple_common.h
+++ b/include/linux/netfilter/nf_conntrack_tuple_common.h
@@ -7,6 +7,33 @@ enum ip_conntrack_dir {
 	IP_CT_DIR_MAX
 };
 
+/* The protocol-specific manipulable parts of the tuple: always in
+ * network order
+ */
+union nf_conntrack_man_proto {
+	/* Add other protocols here. */
+	__be16 all;
+
+	struct {
+		__be16 port;
+	} tcp;
+	struct {
+		__be16 port;
+	} udp;
+	struct {
+		__be16 id;
+	} icmp;
+	struct {
+		__be16 port;
+	} dccp;
+	struct {
+		__be16 port;
+	} sctp;
+	struct {
+		__be16 key;	/* GRE key is 32bit, PPtP only uses 16bit */
+	} gre;
+};
+
 #define CTINFO2DIR(ctinfo) ((ctinfo) >= IP_CT_IS_REPLY ? IP_CT_DIR_REPLY : IP_CT_DIR_ORIGINAL)
 
 #endif /* _NF_CONNTRACK_TUPLE_COMMON_H */
diff --git a/include/linux/netfilter/nf_nat.h b/include/linux/netfilter/nf_nat.h
new file mode 100644
index 0000000..8df2d13
--- /dev/null
+++ b/include/linux/netfilter/nf_nat.h
@@ -0,0 +1,25 @@
+#ifndef _NETFILTER_NF_NAT_H
+#define _NETFILTER_NF_NAT_H
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+
+#define NF_NAT_RANGE_MAP_IPS		1
+#define NF_NAT_RANGE_PROTO_SPECIFIED	2
+#define NF_NAT_RANGE_PROTO_RANDOM	4
+#define NF_NAT_RANGE_PERSISTENT		8
+
+struct nf_nat_ipv4_range {
+	unsigned int			flags;
+	__be32				min_ip;
+	__be32				max_ip;
+	union nf_conntrack_man_proto	min;
+	union nf_conntrack_man_proto	max;
+};
+
+struct nf_nat_ipv4_multi_range_compat {
+	unsigned int			rangesize;
+	struct nf_nat_ipv4_range	range[1];
+};
+
+#endif /* _NETFILTER_NF_NAT_H */
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index c3b4548..f9930c8 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -12,4 +12,3 @@ header-y += ipt_ah.h
 header-y += ipt_ecn.h
 header-y += ipt_realm.h
 header-y += ipt_ttl.h
-header-y += nf_nat.h
diff --git a/include/linux/netfilter_ipv4/nf_nat.h b/include/linux/netfilter_ipv4/nf_nat.h
deleted file mode 100644
index 7a861d0..0000000
--- a/include/linux/netfilter_ipv4/nf_nat.h
+++ /dev/null
@@ -1,58 +0,0 @@
-#ifndef _LINUX_NF_NAT_H
-#define _LINUX_NF_NAT_H
-
-#include <linux/types.h>
-
-#define IP_NAT_RANGE_MAP_IPS 1
-#define IP_NAT_RANGE_PROTO_SPECIFIED 2
-#define IP_NAT_RANGE_PROTO_RANDOM 4
-#define IP_NAT_RANGE_PERSISTENT 8
-
-/* The protocol-specific manipulable parts of the tuple. */
-union nf_conntrack_man_proto {
-	/* Add other protocols here. */
-	__be16 all;
-
-	struct {
-		__be16 port;
-	} tcp;
-	struct {
-		__be16 port;
-	} udp;
-	struct {
-		__be16 id;
-	} icmp;
-	struct {
-		__be16 port;
-	} dccp;
-	struct {
-		__be16 port;
-	} sctp;
-	struct {
-		__be16 key;	/* GRE key is 32bit, PPtP only uses 16bit */
-	} gre;
-};
-
-/* Single range specification. */
-struct nf_nat_range {
-	/* Set to OR of flags above. */
-	unsigned int flags;
-
-	/* Inclusive: network order. */
-	__be32 min_ip, max_ip;
-
-	/* Inclusive: network order */
-	union nf_conntrack_man_proto min, max;
-};
-
-/* For backwards compat: don't use in modern code. */
-struct nf_nat_multi_range_compat {
-	unsigned int rangesize; /* Must be 1. */
-
-	/* hangs off end. */
-	struct nf_nat_range range[1];
-};
-
-#define nf_nat_multi_range nf_nat_multi_range_compat
-
-#endif
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index 2f8fb77..aea3f82 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -12,7 +12,6 @@
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
-#include <linux/netfilter_ipv4/nf_nat.h>
 #include <linux/list_nulls.h>
 
 /* A `tuple' is a structure containing the information to uniquely
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index b8872df..b4de990 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -1,14 +1,12 @@
 #ifndef _NF_NAT_H
 #define _NF_NAT_H
 #include <linux/netfilter_ipv4.h>
-#include <linux/netfilter_ipv4/nf_nat.h>
+#include <linux/netfilter/nf_nat.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
 
-#define NF_NAT_MAPPING_TYPE_MAX_NAMELEN 16
-
 enum nf_nat_manip_type {
-	IP_NAT_MANIP_SRC,
-	IP_NAT_MANIP_DST
+	NF_NAT_MANIP_SRC,
+	NF_NAT_MANIP_DST
 };
 
 /* SRC manip occurs POST_ROUTING or LOCAL_IN */
@@ -52,7 +50,7 @@ struct nf_conn_nat {
 
 /* Set up the info structure to map into this range. */
 extern unsigned int nf_nat_setup_info(struct nf_conn *ct,
-				      const struct nf_nat_range *range,
+				      const struct nf_nat_ipv4_range *range,
 				      enum nf_nat_manip_type maniptype);
 
 /* Is this tuple already taken? (not by us)*/
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 3dc7b98..b13d8d1 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -20,7 +20,7 @@ extern int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
 {
-	if (manip == IP_NAT_MANIP_SRC)
+	if (manip == NF_NAT_MANIP_SRC)
 		return ct->status & IPS_SRC_NAT_DONE;
 	else
 		return ct->status & IPS_DST_NAT_DONE;
diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index 93cc90d..7156c00 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -4,7 +4,7 @@
 #include <net/netfilter/nf_nat.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
-struct nf_nat_range;
+struct nf_nat_ipv4_range;
 
 struct nf_nat_protocol {
 	/* Protocol number. */
@@ -30,15 +30,15 @@ struct nf_nat_protocol {
 	   possible.  Per-protocol part of tuple is initialized to the
 	   incoming packet. */
 	void (*unique_tuple)(struct nf_conntrack_tuple *tuple,
-			     const struct nf_nat_range *range,
+			     const struct nf_nat_ipv4_range *range,
 			     enum nf_nat_manip_type maniptype,
 			     const struct nf_conn *ct);
 
 	int (*range_to_nlattr)(struct sk_buff *skb,
-			       const struct nf_nat_range *range);
+			       const struct nf_nat_ipv4_range *range);
 
 	int (*nlattr_to_range)(struct nlattr *tb[],
-			       struct nf_nat_range *range);
+			       struct nf_nat_ipv4_range *range);
 };
 
 /* Protocol registration. */
@@ -61,14 +61,14 @@ extern bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 				  const union nf_conntrack_man_proto *max);
 
 extern void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
-				      const struct nf_nat_range *range,
+				      const struct nf_nat_ipv4_range *range,
 				      enum nf_nat_manip_type maniptype,
 				      const struct nf_conn *ct,
 				      u_int16_t *rover);
 
 extern int nf_nat_proto_range_to_nlattr(struct sk_buff *skb,
-					const struct nf_nat_range *range);
+					const struct nf_nat_ipv4_range *range);
 extern int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
-					struct nf_nat_range *range);
+					struct nf_nat_ipv4_range *range);
 
 #endif /*_NF_NAT_PROTO_H*/
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 9931152..2f210c7 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -30,9 +30,9 @@ MODULE_DESCRIPTION("Xtables: automatic-address SNAT");
 /* FIXME: Multiple targets. --RR */
 static int masquerade_tg_check(const struct xt_tgchk_param *par)
 {
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
-	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
+	if (mr->range[0].flags & NF_NAT_RANGE_MAP_IPS) {
 		pr_debug("bad MAP_IPS.\n");
 		return -EINVAL;
 	}
@@ -49,8 +49,8 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_conn *ct;
 	struct nf_conn_nat *nat;
 	enum ip_conntrack_info ctinfo;
-	struct nf_nat_range newrange;
-	const struct nf_nat_multi_range_compat *mr;
+	struct nf_nat_ipv4_range newrange;
+	const struct nf_nat_ipv4_multi_range_compat *mr;
 	const struct rtable *rt;
 	__be32 newsrc;
 
@@ -79,13 +79,13 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	nat->masq_index = par->out->ifindex;
 
 	/* Transfer from original range. */
-	newrange = ((struct nf_nat_range)
-		{ mr->range[0].flags | IP_NAT_RANGE_MAP_IPS,
+	newrange = ((struct nf_nat_ipv4_range)
+		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
 		  newsrc, newsrc,
 		  mr->range[0].min, mr->range[0].max });
 
 	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, IP_NAT_MANIP_SRC);
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
 }
 
 static int
@@ -139,7 +139,7 @@ static struct xt_target masquerade_tg_reg __read_mostly = {
 	.name		= "MASQUERADE",
 	.family		= NFPROTO_IPV4,
 	.target		= masquerade_tg,
-	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
+	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 	.table		= "nat",
 	.hooks		= 1 << NF_INET_POST_ROUTING,
 	.checkentry	= masquerade_tg_check,
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index 6cdb298..b5bfbba 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -24,9 +24,9 @@ MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of IPv4 subnets");
 
 static int netmap_tg_check(const struct xt_tgchk_param *par)
 {
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
-	if (!(mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)) {
+	if (!(mr->range[0].flags & NF_NAT_RANGE_MAP_IPS)) {
 		pr_debug("bad MAP_IPS.\n");
 		return -EINVAL;
 	}
@@ -43,8 +43,8 @@ netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 	__be32 new_ip, netmask;
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_range newrange;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_ipv4_range newrange;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_POST_ROUTING ||
@@ -61,8 +61,8 @@ netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		new_ip = ip_hdr(skb)->saddr & ~netmask;
 	new_ip |= mr->range[0].min_ip & netmask;
 
-	newrange = ((struct nf_nat_range)
-		{ mr->range[0].flags | IP_NAT_RANGE_MAP_IPS,
+	newrange = ((struct nf_nat_ipv4_range)
+		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
 		  new_ip, new_ip,
 		  mr->range[0].min, mr->range[0].max });
 
@@ -74,7 +74,7 @@ static struct xt_target netmap_tg_reg __read_mostly = {
 	.name 		= "NETMAP",
 	.family		= NFPROTO_IPV4,
 	.target 	= netmap_tg,
-	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
+	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 	.table		= "nat",
 	.hooks		= (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING) |
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 18a0656..7c0103a 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -28,9 +28,9 @@ MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
 /* FIXME: Take multiple ranges --RR */
 static int redirect_tg_check(const struct xt_tgchk_param *par)
 {
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
-	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
+	if (mr->range[0].flags & NF_NAT_RANGE_MAP_IPS) {
 		pr_debug("bad MAP_IPS.\n");
 		return -EINVAL;
 	}
@@ -47,8 +47,8 @@ redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 	__be32 newdst;
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_range newrange;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_ipv4_range newrange;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_LOCAL_OUT);
@@ -76,20 +76,20 @@ redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	}
 
 	/* Transfer from original range. */
-	newrange = ((struct nf_nat_range)
-		{ mr->range[0].flags | IP_NAT_RANGE_MAP_IPS,
+	newrange = ((struct nf_nat_ipv4_range)
+		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
 		  newdst, newdst,
 		  mr->range[0].min, mr->range[0].max });
 
 	/* Hand modified range to generic setup. */
-	return nf_nat_setup_info(ct, &newrange, IP_NAT_MANIP_DST);
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
 }
 
 static struct xt_target redirect_tg_reg __read_mostly = {
 	.name		= "REDIRECT",
 	.family		= NFPROTO_IPV4,
 	.target		= redirect_tg,
-	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
+	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 	.table		= "nat",
 	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= redirect_tg_check,
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 447bc5c..58ab7a4 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -82,14 +82,14 @@ EXPORT_SYMBOL(nf_nat_used_tuple);
  * that meet the constraints of range. */
 static int
 in_range(const struct nf_conntrack_tuple *tuple,
-	 const struct nf_nat_range *range)
+	 const struct nf_nat_ipv4_range *range)
 {
 	const struct nf_nat_protocol *proto;
 	int ret = 0;
 
 	/* If we are supposed to map IPs, then we must be in the
 	   range specified, otherwise let this drag us onto a new src IP. */
-	if (range->flags & IP_NAT_RANGE_MAP_IPS) {
+	if (range->flags & NF_NAT_RANGE_MAP_IPS) {
 		if (ntohl(tuple->src.u3.ip) < ntohl(range->min_ip) ||
 		    ntohl(tuple->src.u3.ip) > ntohl(range->max_ip))
 			return 0;
@@ -97,8 +97,8 @@ in_range(const struct nf_conntrack_tuple *tuple,
 
 	rcu_read_lock();
 	proto = __nf_nat_proto_find(tuple->dst.protonum);
-	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) ||
-	    proto->in_range(tuple, IP_NAT_MANIP_SRC,
+	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED) ||
+	    proto->in_range(tuple, NF_NAT_MANIP_SRC,
 			    &range->min, &range->max))
 		ret = 1;
 	rcu_read_unlock();
@@ -123,7 +123,7 @@ static int
 find_appropriate_src(struct net *net, u16 zone,
 		     const struct nf_conntrack_tuple *tuple,
 		     struct nf_conntrack_tuple *result,
-		     const struct nf_nat_range *range)
+		     const struct nf_nat_ipv4_range *range)
 {
 	unsigned int h = hash_by_src(net, zone, tuple);
 	const struct nf_conn_nat *nat;
@@ -157,7 +157,7 @@ find_appropriate_src(struct net *net, u16 zone,
 */
 static void
 find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
-		    const struct nf_nat_range *range,
+		    const struct nf_nat_ipv4_range *range,
 		    const struct nf_conn *ct,
 		    enum nf_nat_manip_type maniptype)
 {
@@ -166,10 +166,10 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 	u_int32_t minip, maxip, j;
 
 	/* No IP mapping?  Do nothing. */
-	if (!(range->flags & IP_NAT_RANGE_MAP_IPS))
+	if (!(range->flags & NF_NAT_RANGE_MAP_IPS))
 		return;
 
-	if (maniptype == IP_NAT_MANIP_SRC)
+	if (maniptype == NF_NAT_MANIP_SRC)
 		var_ipp = &tuple->src.u3.ip;
 	else
 		var_ipp = &tuple->dst.u3.ip;
@@ -189,7 +189,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 	minip = ntohl(range->min_ip);
 	maxip = ntohl(range->max_ip);
 	j = jhash_2words((__force u32)tuple->src.u3.ip,
-			 range->flags & IP_NAT_RANGE_PERSISTENT ?
+			 range->flags & NF_NAT_RANGE_PERSISTENT ?
 				0 : (__force u32)tuple->dst.u3.ip ^ zone, 0);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
 	*var_ipp = htonl(minip + j);
@@ -204,7 +204,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 static void
 get_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 const struct nf_conntrack_tuple *orig_tuple,
-		 const struct nf_nat_range *range,
+		 const struct nf_nat_ipv4_range *range,
 		 struct nf_conn *ct,
 		 enum nf_nat_manip_type maniptype)
 {
@@ -219,8 +219,8 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	   This is only required for source (ie. NAT/masq) mappings.
 	   So far, we don't do local source mappings, so multiple
 	   manips not an issue.  */
-	if (maniptype == IP_NAT_MANIP_SRC &&
-	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
+	if (maniptype == NF_NAT_MANIP_SRC &&
+	    !(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
 		/* try the original tuple first */
 		if (in_range(orig_tuple, range)) {
 			if (!nf_nat_used_tuple(orig_tuple, ct)) {
@@ -247,8 +247,8 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	proto = __nf_nat_proto_find(orig_tuple->dst.protonum);
 
 	/* Only bother mapping if it's not already in range and unique */
-	if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) {
+	if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
+		if (range->flags & NF_NAT_RANGE_PROTO_SPECIFIED) {
 			if (proto->in_range(tuple, maniptype, &range->min,
 					    &range->max) &&
 			    (range->min.all == range->max.all ||
@@ -267,7 +267,7 @@ out:
 
 unsigned int
 nf_nat_setup_info(struct nf_conn *ct,
-		  const struct nf_nat_range *range,
+		  const struct nf_nat_ipv4_range *range,
 		  enum nf_nat_manip_type maniptype)
 {
 	struct net *net = nf_ct_net(ct);
@@ -284,8 +284,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 		}
 	}
 
-	NF_CT_ASSERT(maniptype == IP_NAT_MANIP_SRC ||
-		     maniptype == IP_NAT_MANIP_DST);
+	NF_CT_ASSERT(maniptype == NF_NAT_MANIP_SRC ||
+		     maniptype == NF_NAT_MANIP_DST);
 	BUG_ON(nf_nat_initialized(ct, maniptype));
 
 	/* What we've got will look like inverse of reply. Normally
@@ -306,13 +306,13 @@ nf_nat_setup_info(struct nf_conn *ct,
 		nf_conntrack_alter_reply(ct, &reply);
 
 		/* Non-atomic: we own this at the moment. */
-		if (maniptype == IP_NAT_MANIP_SRC)
+		if (maniptype == NF_NAT_MANIP_SRC)
 			ct->status |= IPS_SRC_NAT;
 		else
 			ct->status |= IPS_DST_NAT;
 	}
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		unsigned int srchash;
 
 		srchash = hash_by_src(net, nf_ct_zone(ct),
@@ -327,7 +327,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 	}
 
 	/* It's done. */
-	if (maniptype == IP_NAT_MANIP_DST)
+	if (maniptype == NF_NAT_MANIP_DST)
 		ct->status |= IPS_DST_NAT_DONE;
 	else
 		ct->status |= IPS_SRC_NAT_DONE;
@@ -361,7 +361,7 @@ manip_pkt(u_int16_t proto,
 
 	iph = (void *)skb->data + iphdroff;
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
 		iph->saddr = target->src.u3.ip;
 	} else {
@@ -381,7 +381,7 @@ unsigned int nf_nat_packet(struct nf_conn *ct,
 	unsigned long statusbit;
 	enum nf_nat_manip_type mtype = HOOK2MANIP(hooknum);
 
-	if (mtype == IP_NAT_MANIP_SRC)
+	if (mtype == NF_NAT_MANIP_SRC)
 		statusbit = IPS_SRC_NAT;
 	else
 		statusbit = IPS_DST_NAT;
@@ -447,7 +447,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 			return 0;
 	}
 
-	if (manip == IP_NAT_MANIP_SRC)
+	if (manip == NF_NAT_MANIP_SRC)
 		statusbit = IPS_SRC_NAT;
 	else
 		statusbit = IPS_DST_NAT;
@@ -602,7 +602,7 @@ static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
 
 static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 				     const struct nf_conn *ct,
-				     struct nf_nat_range *range)
+				     struct nf_nat_ipv4_range *range)
 {
 	struct nlattr *tb[CTA_PROTONAT_MAX+1];
 	const struct nf_nat_protocol *npt;
@@ -626,7 +626,7 @@ static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
 
 static int
 nfnetlink_parse_nat(const struct nlattr *nat,
-		    const struct nf_conn *ct, struct nf_nat_range *range)
+		    const struct nf_conn *ct, struct nf_nat_ipv4_range *range)
 {
 	struct nlattr *tb[CTA_NAT_MAX+1];
 	int err;
@@ -646,7 +646,7 @@ nfnetlink_parse_nat(const struct nlattr *nat,
 		range->max_ip = nla_get_be32(tb[CTA_NAT_MAXIP]);
 
 	if (range->min_ip)
-		range->flags |= IP_NAT_RANGE_MAP_IPS;
+		range->flags |= NF_NAT_RANGE_MAP_IPS;
 
 	if (!tb[CTA_NAT_PROTO])
 		return 0;
@@ -663,7 +663,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
 			  const struct nlattr *attr)
 {
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	if (nfnetlink_parse_nat(attr, ct, &range) < 0)
 		return -EINVAL;
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index b9a1136..dc1dd91 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -398,7 +398,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 static void ip_nat_q931_expect(struct nf_conn *new,
 			       struct nf_conntrack_expect *this)
 {
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	if (this->tuple.src.u3.ip != 0) {	/* Only accept calls from GK */
 		nf_nat_follow_master(new, this);
@@ -409,16 +409,16 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 	BUG_ON(new->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
-	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.flags = NF_NAT_RANGE_MAP_IPS;
 	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
-	nf_nat_setup_info(new, &range, IP_NAT_MANIP_SRC);
+	nf_nat_setup_info(new, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
-	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
+	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
 	range.min = range.max = this->saved_proto;
 	range.min_ip = range.max_ip =
 	    new->master->tuplehash[!this->dir].tuple.src.u3.ip;
-	nf_nat_setup_info(new, &range, IP_NAT_MANIP_DST);
+	nf_nat_setup_info(new, &range, NF_NAT_MANIP_DST);
 }
 
 /****************************************************************************/
@@ -496,21 +496,21 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 static void ip_nat_callforwarding_expect(struct nf_conn *new,
 					 struct nf_conntrack_expect *this)
 {
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(new->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
-	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.flags = NF_NAT_RANGE_MAP_IPS;
 	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
-	nf_nat_setup_info(new, &range, IP_NAT_MANIP_SRC);
+	nf_nat_setup_info(new, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
-	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
+	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
 	range.min = range.max = this->saved_proto;
 	range.min_ip = range.max_ip = this->saved_ip;
-	nf_nat_setup_info(new, &range, IP_NAT_MANIP_DST);
+	nf_nat_setup_info(new, &range, NF_NAT_MANIP_DST);
 }
 
 /****************************************************************************/
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index ebc5f88..049e8b7 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -430,22 +430,22 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 void nf_nat_follow_master(struct nf_conn *ct,
 			  struct nf_conntrack_expect *exp)
 {
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
-	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.flags = NF_NAT_RANGE_MAP_IPS;
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
-	nf_nat_setup_info(ct, &range, IP_NAT_MANIP_SRC);
+	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
-	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
+	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
 	range.min = range.max = exp->saved_proto;
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.src.u3.ip;
-	nf_nat_setup_info(ct, &range, IP_NAT_MANIP_DST);
+	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 }
 EXPORT_SYMBOL(nf_nat_follow_master);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 3e8284b..c273d58 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -47,7 +47,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 	struct nf_conntrack_tuple t;
 	const struct nf_ct_pptp_master *ct_pptp_info;
 	const struct nf_nat_pptp *nat_pptp_info;
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	ct_pptp_info = &nfct_help(master)->help.ct_pptp_info;
 	nat_pptp_info = &nfct_nat(master)->help.nat_pptp_info;
@@ -88,24 +88,24 @@ static void pptp_nat_expected(struct nf_conn *ct,
 	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
-	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.flags = NF_NAT_RANGE_MAP_IPS;
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
 	if (exp->dir == IP_CT_DIR_ORIGINAL) {
-		range.flags |= IP_NAT_RANGE_PROTO_SPECIFIED;
+		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 		range.min = range.max = exp->saved_proto;
 	}
-	nf_nat_setup_info(ct, &range, IP_NAT_MANIP_SRC);
+	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
-	range.flags = IP_NAT_RANGE_MAP_IPS;
+	range.flags = NF_NAT_RANGE_MAP_IPS;
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.src.u3.ip;
 	if (exp->dir == IP_CT_DIR_REPLY) {
-		range.flags |= IP_NAT_RANGE_PROTO_SPECIFIED;
+		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 		range.min = range.max = exp->saved_proto;
 	}
-	nf_nat_setup_info(ct, &range, IP_NAT_MANIP_DST);
+	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 }
 
 /* outbound packets == from PNS to PAC */
diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/ipv4/netfilter/nf_nat_proto_common.c
index a3d9976..47fff91 100644
--- a/net/ipv4/netfilter/nf_nat_proto_common.c
+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
@@ -26,7 +26,7 @@ bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 {
 	__be16 port;
 
-	if (maniptype == IP_NAT_MANIP_SRC)
+	if (maniptype == NF_NAT_MANIP_SRC)
 		port = tuple->src.u.all;
 	else
 		port = tuple->dst.u.all;
@@ -37,7 +37,7 @@ bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 EXPORT_SYMBOL_GPL(nf_nat_proto_in_range);
 
 void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
-			       const struct nf_nat_range *range,
+			       const struct nf_nat_ipv4_range *range,
 			       enum nf_nat_manip_type maniptype,
 			       const struct nf_conn *ct,
 			       u_int16_t *rover)
@@ -46,15 +46,15 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 	__be16 *portptr;
 	u_int16_t off;
 
-	if (maniptype == IP_NAT_MANIP_SRC)
+	if (maniptype == NF_NAT_MANIP_SRC)
 		portptr = &tuple->src.u.all;
 	else
 		portptr = &tuple->dst.u.all;
 
 	/* If no range specified... */
-	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED)) {
+	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED)) {
 		/* If it's dst rewrite, can't change port */
-		if (maniptype == IP_NAT_MANIP_DST)
+		if (maniptype == NF_NAT_MANIP_DST)
 			return;
 
 		if (ntohs(*portptr) < 1024) {
@@ -75,9 +75,9 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 		range_size = ntohs(range->max.all) - min + 1;
 	}
 
-	if (range->flags & IP_NAT_RANGE_PROTO_RANDOM)
+	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
 		off = secure_ipv4_port_ephemeral(tuple->src.u3.ip, tuple->dst.u3.ip,
-						 maniptype == IP_NAT_MANIP_SRC
+						 maniptype == NF_NAT_MANIP_SRC
 						 ? tuple->dst.u.all
 						 : tuple->src.u.all);
 	else
@@ -87,7 +87,7 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 		*portptr = htons(min + off % range_size);
 		if (++i != range_size && nf_nat_used_tuple(tuple, ct))
 			continue;
-		if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM))
+		if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM))
 			*rover = off;
 		return;
 	}
@@ -97,7 +97,7 @@ EXPORT_SYMBOL_GPL(nf_nat_proto_unique_tuple);
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 int nf_nat_proto_range_to_nlattr(struct sk_buff *skb,
-				 const struct nf_nat_range *range)
+				 const struct nf_nat_ipv4_range *range)
 {
 	NLA_PUT_BE16(skb, CTA_PROTONAT_PORT_MIN, range->min.all);
 	NLA_PUT_BE16(skb, CTA_PROTONAT_PORT_MAX, range->max.all);
@@ -109,16 +109,16 @@ nla_put_failure:
 EXPORT_SYMBOL_GPL(nf_nat_proto_nlattr_to_range);
 
 int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
-				 struct nf_nat_range *range)
+				 struct nf_nat_ipv4_range *range)
 {
 	if (tb[CTA_PROTONAT_PORT_MIN]) {
 		range->min.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MIN]);
 		range->max.all = range->min.tcp.port;
-		range->flags |= IP_NAT_RANGE_PROTO_SPECIFIED;
+		range->flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 	if (tb[CTA_PROTONAT_PORT_MAX]) {
 		range->max.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MAX]);
-		range->flags |= IP_NAT_RANGE_PROTO_SPECIFIED;
+		range->flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 	return 0;
 }
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/ipv4/netfilter/nf_nat_proto_dccp.c
index 570faf2..c43d5b3 100644
--- a/net/ipv4/netfilter/nf_nat_proto_dccp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_dccp.c
@@ -24,7 +24,7 @@ static u_int16_t dccp_port_rover;
 
 static void
 dccp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_range *range,
+		  const struct nf_nat_ipv4_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
@@ -54,7 +54,7 @@ dccp_manip_pkt(struct sk_buff *skb,
 	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct dccp_hdr *)(skb->data + hdroff);
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		oldip = iph->saddr;
 		newip = tuple->src.u3.ip;
 		newport = tuple->src.u.dccp.port;
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index bc8d83a..9b1c629 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -39,7 +39,7 @@ MODULE_DESCRIPTION("Netfilter NAT protocol helper module for GRE");
 /* generate unique tuple ... */
 static void
 gre_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_range *range,
+		 const struct nf_nat_ipv4_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
@@ -52,12 +52,12 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 	if (!ct->master)
 		return;
 
-	if (maniptype == IP_NAT_MANIP_SRC)
+	if (maniptype == NF_NAT_MANIP_SRC)
 		keyptr = &tuple->src.u.gre.key;
 	else
 		keyptr = &tuple->dst.u.gre.key;
 
-	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED)) {
+	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED)) {
 		pr_debug("%p: NATing GRE PPTP\n", ct);
 		min = 1;
 		range_size = 0xffff;
@@ -99,7 +99,7 @@ gre_manip_pkt(struct sk_buff *skb, unsigned int iphdroff,
 
 	/* we only have destination manip of a packet, since 'source key'
 	 * is not present in the packet itself */
-	if (maniptype != IP_NAT_MANIP_DST)
+	if (maniptype != NF_NAT_MANIP_DST)
 		return true;
 	switch (greh->version) {
 	case GRE_VERSION_1701:
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 9f4dc12..8f87b4b 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -30,7 +30,7 @@ icmp_in_range(const struct nf_conntrack_tuple *tuple,
 
 static void
 icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_range *range,
+		  const struct nf_nat_ipv4_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
@@ -40,7 +40,7 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 	range_size = ntohs(range->max.icmp.id) - ntohs(range->min.icmp.id) + 1;
 	/* If no range specified... */
-	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED))
+	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED))
 		range_size = 0xFFFF;
 
 	for (i = 0; ; ++id) {
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index bd5a80a..4e70dc6 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -19,7 +19,7 @@ static u_int16_t nf_sctp_port_rover;
 
 static void
 sctp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_range *range,
+		  const struct nf_nat_ipv4_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
@@ -46,7 +46,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct sctphdr *)(skb->data + hdroff);
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
 		oldip = iph->saddr;
 		newip = tuple->src.u3.ip;
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index 0d67bb8..6fcc865 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -23,7 +23,7 @@ static u_int16_t tcp_port_rover;
 
 static void
 tcp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_range *range,
+		 const struct nf_nat_ipv4_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
@@ -55,7 +55,7 @@ tcp_manip_pkt(struct sk_buff *skb,
 	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct tcphdr *)(skb->data + hdroff);
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
 		oldip = iph->saddr;
 		newip = tuple->src.u3.ip;
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index 0b1b860..18ea44e 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -22,7 +22,7 @@ static u_int16_t udp_port_rover;
 
 static void
 udp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_range *range,
+		 const struct nf_nat_ipv4_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
@@ -47,7 +47,7 @@ udp_manip_pkt(struct sk_buff *skb,
 	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct udphdr *)(skb->data + hdroff);
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
 		oldip = iph->saddr;
 		newip = tuple->src.u3.ip;
diff --git a/net/ipv4/netfilter/nf_nat_proto_udplite.c b/net/ipv4/netfilter/nf_nat_proto_udplite.c
index f83ef23..a17b75b 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udplite.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udplite.c
@@ -21,7 +21,7 @@ static u_int16_t udplite_port_rover;
 
 static void
 udplite_unique_tuple(struct nf_conntrack_tuple *tuple,
-		     const struct nf_nat_range *range,
+		     const struct nf_nat_ipv4_range *range,
 		     enum nf_nat_manip_type maniptype,
 		     const struct nf_conn *ct)
 {
@@ -47,7 +47,7 @@ udplite_manip_pkt(struct sk_buff *skb,
 	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct udphdr *)(skb->data + hdroff);
 
-	if (maniptype == IP_NAT_MANIP_SRC) {
+	if (maniptype == NF_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
 		oldip = iph->saddr;
 		newip = tuple->src.u3.ip;
diff --git a/net/ipv4/netfilter/nf_nat_proto_unknown.c b/net/ipv4/netfilter/nf_nat_proto_unknown.c
index a50f2bc..ab8e8c1 100644
--- a/net/ipv4/netfilter/nf_nat_proto_unknown.c
+++ b/net/ipv4/netfilter/nf_nat_proto_unknown.c
@@ -27,7 +27,7 @@ static bool unknown_in_range(const struct nf_conntrack_tuple *tuple,
 }
 
 static void unknown_unique_tuple(struct nf_conntrack_tuple *tuple,
-				 const struct nf_nat_range *range,
+				 const struct nf_nat_ipv4_range *range,
 				 enum nf_nat_manip_type maniptype,
 				 const struct nf_conn *ct)
 {
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 733c9ab..d2a9dc3 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -44,7 +44,7 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING ||
 		     par->hooknum == NF_INET_LOCAL_IN);
@@ -56,7 +56,7 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_action_param *par)
 			    ctinfo == IP_CT_RELATED_REPLY));
 	NF_CT_ASSERT(par->out != NULL);
 
-	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_SRC);
+	return nf_nat_setup_info(ct, &mr->range[0], NF_NAT_MANIP_SRC);
 }
 
 static unsigned int
@@ -64,7 +64,7 @@ ipt_dnat_target(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_LOCAL_OUT);
@@ -74,12 +74,12 @@ ipt_dnat_target(struct sk_buff *skb, const struct xt_action_param *par)
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
-	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
+	return nf_nat_setup_info(ct, &mr->range[0], NF_NAT_MANIP_DST);
 }
 
 static int ipt_snat_checkentry(const struct xt_tgchk_param *par)
 {
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
@@ -91,7 +91,7 @@ static int ipt_snat_checkentry(const struct xt_tgchk_param *par)
 
 static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
 {
-	const struct nf_nat_multi_range_compat *mr = par->targinfo;
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
@@ -105,13 +105,13 @@ static unsigned int
 alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 {
 	/* Force range to this IP; let proto decide mapping for
-	   per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
+	   per-proto parts (hence not NF_NAT_RANGE_PROTO_SPECIFIED).
 	*/
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	range.flags = 0;
 	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct,
-		 HOOK2MANIP(hooknum) == IP_NAT_MANIP_SRC ?
+		 HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
 		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip :
 		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip);
 
@@ -140,7 +140,7 @@ int nf_nat_rule_find(struct sk_buff *skb,
 static struct xt_target ipt_snat_reg __read_mostly = {
 	.name		= "SNAT",
 	.target		= ipt_snat_target,
-	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
+	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 	.table		= "nat",
 	.hooks		= (1 << NF_INET_POST_ROUTING) | (1 << NF_INET_LOCAL_IN),
 	.checkentry	= ipt_snat_checkentry,
@@ -150,7 +150,7 @@ static struct xt_target ipt_snat_reg __read_mostly = {
 static struct xt_target ipt_dnat_reg __read_mostly = {
 	.name		= "DNAT",
 	.target		= ipt_dnat_target,
-	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
+	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 	.table		= "nat",
 	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= ipt_dnat_checkentry,
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 78844d9..d0319f9 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -249,25 +249,25 @@ static void ip_nat_sip_seq_adjust(struct sk_buff *skb, s16 off)
 static void ip_nat_sip_expected(struct nf_conn *ct,
 				struct nf_conntrack_expect *exp)
 {
-	struct nf_nat_range range;
+	struct nf_nat_ipv4_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
 
 	/* For DST manip, map port here to where it's expected. */
-	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
+	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
 	range.min = range.max = exp->saved_proto;
 	range.min_ip = range.max_ip = exp->saved_ip;
-	nf_nat_setup_info(ct, &range, IP_NAT_MANIP_DST);
+	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 
 	/* Change src to where master sends to, but only if the connection
 	 * actually came from the same source. */
 	if (ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip ==
 	    ct->master->tuplehash[exp->dir].tuple.src.u3.ip) {
-		range.flags = IP_NAT_RANGE_MAP_IPS;
+		range.flags = NF_NAT_RANGE_MAP_IPS;
 		range.min_ip = range.max_ip
 			= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
-		nf_nat_setup_info(ct, &range, IP_NAT_MANIP_SRC);
+		nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 	}
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 9290048..3828a42 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -137,7 +137,7 @@ nf_nat_fn(unsigned int hooknum,
 				return ret;
 		} else
 			pr_debug("Already setup manip %s for ct %p\n",
-				 maniptype == IP_NAT_MANIP_SRC ? "SRC" : "DST",
+				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
 		break;
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e58aa9b..2eb1c69 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1087,14 +1087,14 @@ ctnetlink_change_nat(struct nf_conn *ct, const struct nlattr * const cda[])
 
 	if (cda[CTA_NAT_DST]) {
 		ret = ctnetlink_parse_nat_setup(ct,
-						IP_NAT_MANIP_DST,
+						NF_NAT_MANIP_DST,
 						cda[CTA_NAT_DST]);
 		if (ret < 0)
 			return ret;
 	}
 	if (cda[CTA_NAT_SRC]) {
 		ret = ctnetlink_parse_nat_setup(ct,
-						IP_NAT_MANIP_SRC,
+						NF_NAT_MANIP_SRC,
 						cda[CTA_NAT_SRC]);
 		if (ret < 0)
 			return ret;
-- 
1.7.1
