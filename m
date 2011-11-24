From: kaber@trash.net
Subject: [PATCH 07/18] netfilter: ctnetlink: remove dead NAT code
Date: Thu, 24 Nov 2011 17:57:18 +0100
Message-ID: <1322153850-10533-8-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47970 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692Ab1KXQ5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 11:57:36 -0500
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The NAT range to nlattr conversation callbacks and helpers are entirely
dead code and are also useless since there are no NAT ranges in conntrack
context, they are only used for initially selecting a tuple. The final NAT
information is contained in the selected tuples of the conntrack entry.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_protocol.h   |    5 -----
 net/ipv4/netfilter/nf_nat_proto_common.c  |   14 +-------------
 net/ipv4/netfilter/nf_nat_proto_dccp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_gre.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_icmp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_sctp.c    |    1 -
 net/ipv4/netfilter/nf_nat_proto_tcp.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_udp.c     |    1 -
 net/ipv4/netfilter/nf_nat_proto_udplite.c |    1 -
 9 files changed, 1 insertions(+), 25 deletions(-)

diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index eaad0ac..7b0b511 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -32,9 +32,6 @@ struct nf_nat_protocol {
 			     enum nf_nat_manip_type maniptype,
 			     const struct nf_conn *ct);
 
-	int (*range_to_nlattr)(struct sk_buff *skb,
-			       const struct nf_nat_ipv4_range *range);
-
 	int (*nlattr_to_range)(struct nlattr *tb[],
 			       struct nf_nat_ipv4_range *range);
 };
@@ -64,8 +61,6 @@ extern void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 				      const struct nf_conn *ct,
 				      u_int16_t *rover);
 
-extern int nf_nat_proto_range_to_nlattr(struct sk_buff *skb,
-					const struct nf_nat_ipv4_range *range);
 extern int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
 					struct nf_nat_ipv4_range *range);
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/ipv4/netfilter/nf_nat_proto_common.c
index 47fff91..9993bc9 100644
--- a/net/ipv4/netfilter/nf_nat_proto_common.c
+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
@@ -96,18 +96,6 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 EXPORT_SYMBOL_GPL(nf_nat_proto_unique_tuple);
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-int nf_nat_proto_range_to_nlattr(struct sk_buff *skb,
-				 const struct nf_nat_ipv4_range *range)
-{
-	NLA_PUT_BE16(skb, CTA_PROTONAT_PORT_MIN, range->min.all);
-	NLA_PUT_BE16(skb, CTA_PROTONAT_PORT_MAX, range->max.all);
-	return 0;
-
-nla_put_failure:
-	return -1;
-}
-EXPORT_SYMBOL_GPL(nf_nat_proto_nlattr_to_range);
-
 int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
 				 struct nf_nat_ipv4_range *range)
 {
@@ -122,5 +110,5 @@ int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_range_to_nlattr);
+EXPORT_SYMBOL_GPL(nf_nat_proto_nlattr_to_range);
 #endif
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/ipv4/netfilter/nf_nat_proto_dccp.c
index 466d63d..3f67138 100644
--- a/net/ipv4/netfilter/nf_nat_proto_dccp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_dccp.c
@@ -84,7 +84,6 @@ static const struct nf_nat_protocol nf_nat_protocol_dccp = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= dccp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 35cd158..46ba0b9 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -123,7 +123,6 @@ static const struct nf_nat_protocol gre = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= gre_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 036c009..b351728 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -78,7 +78,6 @@ const struct nf_nat_protocol nf_nat_protocol_icmp = {
 	.in_range		= icmp_in_range,
 	.unique_tuple		= icmp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 50283ab..3cce9b6 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -74,7 +74,6 @@ static const struct nf_nat_protocol nf_nat_protocol_sctp = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= sctp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index e0e2ba8..9fb4b4e 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -86,7 +86,6 @@ const struct nf_nat_protocol nf_nat_protocol_tcp = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= tcp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index bde94cd..9883336 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -77,7 +77,6 @@ const struct nf_nat_protocol nf_nat_protocol_udp = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= udp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_udplite.c b/net/ipv4/netfilter/nf_nat_proto_udplite.c
index 58e9a3a..d24d10a 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udplite.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udplite.c
@@ -76,7 +76,6 @@ static const struct nf_nat_protocol nf_nat_protocol_udplite = {
 	.in_range		= nf_nat_proto_in_range,
 	.unique_tuple		= udplite_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.range_to_nlattr	= nf_nat_proto_range_to_nlattr,
 	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
 #endif
 };
-- 
1.7.1
