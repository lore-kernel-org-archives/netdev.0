From: pablo@netfilter.org
Subject: [PATCH 18/25] netfilter: nf_conntrack: add namespace support for cttimeout
Date: Mon, 11 Jun 2012 16:43:54 +0200
Message-ID: <1339425841-24171-19-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for cttimeout.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |    3 ++-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    6 ++++--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    6 ++++--
 net/netfilter/nf_conntrack_proto_dccp.c        |    5 +++--
 net/netfilter/nf_conntrack_proto_generic.c     |    6 ++++--
 net/netfilter/nf_conntrack_proto_gre.c         |    8 +++++---
 net/netfilter/nf_conntrack_proto_sctp.c        |    6 ++++--
 net/netfilter/nf_conntrack_proto_tcp.c         |    6 ++++--
 net/netfilter/nf_conntrack_proto_udp.c         |    8 +++++---
 net/netfilter/nf_conntrack_proto_udplite.c     |    8 +++++---
 net/netfilter/nfnetlink_cttimeout.c            |   13 ++++++++-----
 11 files changed, 48 insertions(+), 27 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index cfa2f89..81c52b5 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -87,7 +87,8 @@ struct nf_conntrack_l4proto {
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
 	struct {
 		size_t obj_size;
-		int (*nlattr_to_obj)(struct nlattr *tb[], void *data);
+		int (*nlattr_to_obj)(struct nlattr *tb[],
+				     struct net *net, void *data);
 		int (*obj_to_nlattr)(struct sk_buff *skb, const void *data);
 
 		unsigned int nlattr_max;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 2bca7a5..041923c 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -279,16 +279,18 @@ static int icmp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_icmp_net *in = icmp_pernet(net);
 
 	if (tb[CTA_TIMEOUT_ICMP_TIMEOUT]) {
 		*timeout =
 			ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMP_TIMEOUT])) * HZ;
 	} else {
 		/* Set default ICMP timeout. */
-		*timeout = nf_ct_icmp_timeout;
+		*timeout = in->timeout;
 	}
 	return 0;
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 1b7818f..63ed012 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -286,16 +286,18 @@ static int icmpv6_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[],
+					struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_icmp_net *in = icmpv6_pernet(net);
 
 	if (tb[CTA_TIMEOUT_ICMPV6_TIMEOUT]) {
 		*timeout =
 		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMPV6_TIMEOUT])) * HZ;
 	} else {
 		/* Set default ICMPv6 timeout. */
-		*timeout = nf_ct_icmpv6_timeout;
+		*timeout = in->timeout;
 	}
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 8d798a6..c33f76a 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -712,9 +712,10 @@ static int dccp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
-	struct dccp_net *dn = dccp_pernet(&init_net);
+	struct dccp_net *dn = dccp_pernet(net);
 	unsigned int *timeouts = data;
 	int i;
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index e4e2d2a..bb0e74f 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -75,16 +75,18 @@ static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int generic_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int generic_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_generic_net *gn = generic_pernet(net);
 
 	if (tb[CTA_TIMEOUT_GENERIC_TIMEOUT])
 		*timeout =
 		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ;
 	else {
 		/* Set default generic timeout. */
-		*timeout = nf_ct_generic_timeout;
+		*timeout = gn->timeout;
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index e36973f..25ba5a2 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -304,13 +304,15 @@ static void gre_destroy(struct nf_conn *ct)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int gre_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int gre_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 
 	/* set default timeouts for GRE. */
-	timeouts[GRE_CT_UNREPLIED] = gre_timeouts[GRE_CT_UNREPLIED];
-	timeouts[GRE_CT_REPLIED] = gre_timeouts[GRE_CT_REPLIED];
+	timeouts[GRE_CT_UNREPLIED] = net_gre->gre_timeouts[GRE_CT_UNREPLIED];
+	timeouts[GRE_CT_REPLIED] = net_gre->gre_timeouts[GRE_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_GRE_UNREPLIED]) {
 		timeouts[GRE_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index d785f2c..8fb0582 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -562,14 +562,16 @@ static int sctp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct sctp_net *sn = sctp_pernet(net);
 	int i;
 
 	/* set default SCTP timeouts. */
 	for (i=0; i<SCTP_CONNTRACK_MAX; i++)
-		timeouts[i] = sctp_timeouts[i];
+		timeouts[i] = sn->timeouts[i];
 
 	/* there's a 1:1 mapping between attributes and protocol states. */
 	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index e57f2a8..1cff854 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1260,14 +1260,16 @@ static int tcp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	int i;
 
 	/* set default TCP timeouts. */
 	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
-		timeouts[i] = tcp_timeouts[i];
+		timeouts[i] = tn->timeouts[i];
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
 		timeouts[TCP_CONNTRACK_SYN_SENT] =
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index db7abad..360565a 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -156,13 +156,15 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct nf_udp_net *un = udp_pernet(net);
 
 	/* set default timeouts for UDP. */
-	timeouts[UDP_CT_UNREPLIED] = udp_timeouts[UDP_CT_UNREPLIED];
-	timeouts[UDP_CT_REPLIED] = udp_timeouts[UDP_CT_REPLIED];
+	timeouts[UDP_CT_UNREPLIED] = un->timeouts[UDP_CT_UNREPLIED];
+	timeouts[UDP_CT_REPLIED] = un->timeouts[UDP_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
 		timeouts[UDP_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 2e25e98..b32e700 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -172,13 +172,15 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct udplite_net *un = udplite_pernet(net);
 
 	/* set default timeouts for UDPlite. */
-	timeouts[UDPLITE_CT_UNREPLIED] = udplite_timeouts[UDPLITE_CT_UNREPLIED];
-	timeouts[UDPLITE_CT_REPLIED] = udplite_timeouts[UDPLITE_CT_REPLIED];
+	timeouts[UDPLITE_CT_UNREPLIED] = un->timeouts[UDPLITE_CT_UNREPLIED];
+	timeouts[UDPLITE_CT_REPLIED] = un->timeouts[UDPLITE_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_UDPLITE_UNREPLIED]) {
 		timeouts[UDPLITE_CT_UNREPLIED] =
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 3e65528..cdecbc8 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -49,8 +49,9 @@ static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
 
 static int
 ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
-			       struct nf_conntrack_l4proto *l4proto,
-			       const struct nlattr *attr)
+			  struct nf_conntrack_l4proto *l4proto,
+			  struct net *net,
+			  const struct nlattr *attr)
 {
 	int ret = 0;
 
@@ -60,7 +61,8 @@ ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
 		nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
 				 attr, l4proto->ctnl_timeout.nla_policy);
 
-		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, &timeout->data);
+		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, net,
+							  &timeout->data);
 	}
 	return ret;
 }
@@ -74,6 +76,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 	__u8 l4num;
 	struct nf_conntrack_l4proto *l4proto;
 	struct ctnl_timeout *timeout, *matching = NULL;
+	struct net *net = sock_net(skb->sk);
 	char *name;
 	int ret;
 
@@ -117,7 +120,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 				goto err_proto_put;
 			}
 
-			ret = ctnl_timeout_parse_policy(matching, l4proto,
+			ret = ctnl_timeout_parse_policy(matching, l4proto, net,
 							cda[CTA_TIMEOUT_DATA]);
 			return ret;
 		}
@@ -132,7 +135,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 		goto err_proto_put;
 	}
 
-	ret = ctnl_timeout_parse_policy(timeout, l4proto,
+	ret = ctnl_timeout_parse_policy(timeout, l4proto, net,
 					cda[CTA_TIMEOUT_DATA]);
 	if (ret < 0)
 		goto err;
-- 
1.7.10

