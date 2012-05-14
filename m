From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 16/17] netfilter: add namespace support for cttimeout
Date: Mon, 14 May 2012 16:52:26 +0800
Message-ID: <1336985547-31960-17-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:5805 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755443Ab2ENIxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 04:53:11 -0400
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add struct net as a param of ctnl_timeout.nlattr_to_obj,

modify ctnl_timeout_parse_policy and cttimeout_new_timeout
to transmit struct net to nlattr_to_obj.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |    3 ++-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    3 ++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    3 ++-
 net/netfilter/nf_conntrack_proto_dccp.c        |    3 ++-
 net/netfilter/nf_conntrack_proto_generic.c     |    3 ++-
 net/netfilter/nf_conntrack_proto_gre.c         |    3 ++-
 net/netfilter/nf_conntrack_proto_sctp.c        |    3 ++-
 net/netfilter/nf_conntrack_proto_tcp.c         |    3 ++-
 net/netfilter/nf_conntrack_proto_udp.c         |    3 ++-
 net/netfilter/nf_conntrack_proto_udplite.c     |    3 ++-
 net/netfilter/nfnetlink_cttimeout.c            |   13 ++++++++-----
 11 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 4881df34..d8457c4 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -88,7 +88,8 @@ struct nf_conntrack_l4proto {
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
 	struct {
 		size_t obj_size;
-		int (*nlattr_to_obj)(struct nlattr *tb[], void *data);
+		int (*nlattr_to_obj)(struct nlattr *tb[],
+				     struct net *net, void *data);
 		int (*obj_to_nlattr)(struct sk_buff *skb, const void *data);
 
 		unsigned int nlattr_max;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 90da247..c80b73c 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -279,7 +279,8 @@ static int icmp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
 	unsigned int *timeout = data;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 12ca315..0ea5ba9 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -286,7 +286,8 @@ static int icmpv6_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[],
+					struct net *net, void *data)
 {
 	unsigned int *timeout = data;
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 034f8ea..b301fb0 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -712,7 +712,8 @@ static int dccp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
 	struct dccp_net *dn = dccp_pernet(&init_net);
 	unsigned int *timeouts = data;
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 0f87a77..de326f4 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -75,7 +75,8 @@ static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int generic_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int generic_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net, void *data)
 {
 	unsigned int *timeout = data;
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 8d70452..e4cc5e4 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -304,7 +304,8 @@ static void gre_destroy(struct nf_conn *ct)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int gre_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int gre_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 291cef4..a28f3c4 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -562,7 +562,8 @@ static int sctp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
 	int i;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4d16b8a..c0c0010 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1259,7 +1259,8 @@ static int tcp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
 	int i;
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index c38ab58..14444a9 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -156,7 +156,8 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index cb3dc81..34bd65f 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -172,7 +172,8 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
 
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
1.7.7.6
