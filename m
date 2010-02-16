From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 34/62: ctnetlink: add missing netlink attribute policies
Date: Tue, 16 Feb 2010 15:56:06 +0100 (MET)
Message-ID: <20100216145603.2796.24043.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52026 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab0BPO4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:06 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d0b0268fddea3235a8df35e52167c3b206bf2f5a
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 10 15:38:33 2010 +0100

    netfilter: ctnetlink: add missing netlink attribute policies
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 327c517..5c103b8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -708,6 +708,11 @@ ctnetlink_parse_tuple_proto(struct nlattr *attr,
 	return ret;
 }
 
+static const struct nla_policy tuple_nla_policy[CTA_TUPLE_MAX+1] = {
+	[CTA_TUPLE_IP]		= { .type = NLA_NESTED },
+	[CTA_TUPLE_PROTO]	= { .type = NLA_NESTED },
+};
+
 static int
 ctnetlink_parse_tuple(const struct nlattr * const cda[],
 		      struct nf_conntrack_tuple *tuple,
@@ -718,7 +723,7 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 
 	memset(tuple, 0, sizeof(*tuple));
 
-	nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], NULL);
+	nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], tuple_nla_policy);
 
 	if (!tb[CTA_TUPLE_IP])
 		return -EINVAL;
@@ -745,12 +750,16 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 	return 0;
 }
 
+static const struct nla_policy help_nla_policy[CTA_HELP_MAX+1] = {
+	[CTA_HELP_NAME]		= { .type = NLA_NUL_STRING },
+};
+
 static inline int
 ctnetlink_parse_help(const struct nlattr *attr, char **helper_name)
 {
 	struct nlattr *tb[CTA_HELP_MAX+1];
 
-	nla_parse_nested(tb, CTA_HELP_MAX, attr, NULL);
+	nla_parse_nested(tb, CTA_HELP_MAX, attr, help_nla_policy);
 
 	if (!tb[CTA_HELP_NAME])
 		return -EINVAL;
@@ -761,11 +770,17 @@ ctnetlink_parse_help(const struct nlattr *attr, char **helper_name)
 }
 
 static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
+	[CTA_TUPLE_ORIG]	= { .type = NLA_NESTED },
+	[CTA_TUPLE_REPLY]	= { .type = NLA_NESTED },
 	[CTA_STATUS] 		= { .type = NLA_U32 },
+	[CTA_PROTOINFO]		= { .type = NLA_NESTED },
+	[CTA_HELP]		= { .type = NLA_NESTED },
+	[CTA_NAT_SRC]		= { .type = NLA_NESTED },
 	[CTA_TIMEOUT] 		= { .type = NLA_U32 },
 	[CTA_MARK]		= { .type = NLA_U32 },
-	[CTA_USE]		= { .type = NLA_U32 },
 	[CTA_ID]		= { .type = NLA_U32 },
+	[CTA_NAT_DST]		= { .type = NLA_NESTED },
+	[CTA_TUPLE_MASTER]	= { .type = NLA_NESTED },
 };
 
 static int
@@ -1053,6 +1068,12 @@ ctnetlink_change_timeout(struct nf_conn *ct, const struct nlattr * const cda[])
 	return 0;
 }
 
+static const struct nla_policy protoinfo_policy[CTA_PROTOINFO_MAX+1] = {
+	[CTA_PROTOINFO_TCP]	= { .type = NLA_NESTED },
+	[CTA_PROTOINFO_DCCP]	= { .type = NLA_NESTED },
+	[CTA_PROTOINFO_SCTP]	= { .type = NLA_NESTED },
+};
+
 static inline int
 ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[])
 {
@@ -1061,7 +1082,7 @@ ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[]
 	struct nf_conntrack_l4proto *l4proto;
 	int err = 0;
 
-	nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, NULL);
+	nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy);
 
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
@@ -1073,12 +1094,18 @@ ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[]
 }
 
 #ifdef CONFIG_NF_NAT_NEEDED
+static const struct nla_policy nat_seq_policy[CTA_NAT_SEQ_MAX+1] = {
+	[CTA_NAT_SEQ_CORRECTION_POS]	= { .type = NLA_U32 },
+	[CTA_NAT_SEQ_OFFSET_BEFORE]	= { .type = NLA_U32 },
+	[CTA_NAT_SEQ_OFFSET_AFTER]	= { .type = NLA_U32 },
+};
+
 static inline int
 change_nat_seq_adj(struct nf_nat_seq *natseq, const struct nlattr * const attr)
 {
 	struct nlattr *cda[CTA_NAT_SEQ_MAX+1];
 
-	nla_parse_nested(cda, CTA_NAT_SEQ_MAX, attr, NULL);
+	nla_parse_nested(cda, CTA_NAT_SEQ_MAX, attr, nat_seq_policy);
 
 	if (!cda[CTA_NAT_SEQ_CORRECTION_POS])
 		return -EINVAL;
@@ -1648,8 +1675,12 @@ out:
 }
 
 static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
+	[CTA_EXPECT_MASTER]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_TUPLE]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_MASK]	= { .type = NLA_NESTED },
 	[CTA_EXPECT_TIMEOUT]	= { .type = NLA_U32 },
 	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
+	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING },
 };
 
 static int
