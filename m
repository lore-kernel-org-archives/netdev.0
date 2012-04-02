From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 19/51] nf_conntrack_netlink: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:09 -0400
Message-ID: <1333335521-1348-20-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288Ab2DBC7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:38 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_netlink.c |   83 ++++++++++++++++++++--------------
 1 files changed, 49 insertions(+), 34 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ca7e835..462ec2d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -66,7 +66,8 @@ ctnetlink_dump_tuples_proto(struct sk_buff *skb,
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_PROTO | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
-	NLA_PUT_U8(skb, CTA_PROTO_NUM, tuple->dst.protonum);
+	if (nla_put_u8(skb, CTA_PROTO_NUM, tuple->dst.protonum))
+		goto nla_put_failure;
 
 	if (likely(l4proto->tuple_to_nlattr))
 		ret = l4proto->tuple_to_nlattr(skb, tuple);
@@ -126,7 +127,8 @@ ctnetlink_dump_tuples(struct sk_buff *skb,
 static inline int
 ctnetlink_dump_status(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	NLA_PUT_BE32(skb, CTA_STATUS, htonl(ct->status));
+	if (nla_put_be32(skb, CTA_STATUS, htonl(ct->status)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -141,7 +143,8 @@ ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
 	if (timeout < 0)
 		timeout = 0;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT, htonl(timeout));
+	if (nla_put_be32(skb, CTA_TIMEOUT, htonl(timeout)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -190,7 +193,8 @@ ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
 	nest_helper = nla_nest_start(skb, CTA_HELP | NLA_F_NESTED);
 	if (!nest_helper)
 		goto nla_put_failure;
-	NLA_PUT_STRING(skb, CTA_HELP_NAME, helper->name);
+	if (nla_put_string(skb, CTA_HELP_NAME, helper->name))
+		goto nla_put_failure;
 
 	if (helper->to_nlattr)
 		helper->to_nlattr(skb, ct);
@@ -214,8 +218,9 @@ dump_counters(struct sk_buff *skb, u64 pkts, u64 bytes,
 	if (!nest_count)
 		goto nla_put_failure;
 
-	NLA_PUT_BE64(skb, CTA_COUNTERS_PACKETS, cpu_to_be64(pkts));
-	NLA_PUT_BE64(skb, CTA_COUNTERS_BYTES, cpu_to_be64(bytes));
+	if (nla_put_be64(skb, CTA_COUNTERS_PACKETS, cpu_to_be64(pkts)) ||
+	    nla_put_be64(skb, CTA_COUNTERS_BYTES, cpu_to_be64(bytes)))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest_count);
 
@@ -260,11 +265,10 @@ ctnetlink_dump_timestamp(struct sk_buff *skb, const struct nf_conn *ct)
 	if (!nest_count)
 		goto nla_put_failure;
 
-	NLA_PUT_BE64(skb, CTA_TIMESTAMP_START, cpu_to_be64(tstamp->start));
-	if (tstamp->stop != 0) {
-		NLA_PUT_BE64(skb, CTA_TIMESTAMP_STOP,
-			     cpu_to_be64(tstamp->stop));
-	}
+	if (nla_put_be64(skb, CTA_TIMESTAMP_START, cpu_to_be64(tstamp->start)) ||
+	    (tstamp->stop != 0 && nla_put_be64(skb, CTA_TIMESTAMP_STOP,
+					       cpu_to_be64(tstamp->stop))))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest_count);
 
 	return 0;
@@ -277,7 +281,8 @@ nla_put_failure:
 static inline int
 ctnetlink_dump_mark(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	NLA_PUT_BE32(skb, CTA_MARK, htonl(ct->mark));
+	if (nla_put_be32(skb, CTA_MARK, htonl(ct->mark)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -304,7 +309,8 @@ ctnetlink_dump_secctx(struct sk_buff *skb, const struct nf_conn *ct)
 	if (!nest_secctx)
 		goto nla_put_failure;
 
-	NLA_PUT_STRING(skb, CTA_SECCTX_NAME, secctx);
+	if (nla_put_string(skb, CTA_SECCTX_NAME, secctx))
+		goto nla_put_failure;
 	nla_nest_end(skb, nest_secctx);
 
 	ret = 0;
@@ -349,12 +355,13 @@ dump_nat_seq_adj(struct sk_buff *skb, const struct nf_nat_seq *natseq, int type)
 	if (!nest_parms)
 		goto nla_put_failure;
 
-	NLA_PUT_BE32(skb, CTA_NAT_SEQ_CORRECTION_POS,
-		     htonl(natseq->correction_pos));
-	NLA_PUT_BE32(skb, CTA_NAT_SEQ_OFFSET_BEFORE,
-		     htonl(natseq->offset_before));
-	NLA_PUT_BE32(skb, CTA_NAT_SEQ_OFFSET_AFTER,
-		     htonl(natseq->offset_after));
+	if (nla_put_be32(skb, CTA_NAT_SEQ_CORRECTION_POS,
+			 htonl(natseq->correction_pos)) ||
+	    nla_put_be32(skb, CTA_NAT_SEQ_OFFSET_BEFORE,
+			 htonl(natseq->offset_before)) ||
+	    nla_put_be32(skb, CTA_NAT_SEQ_OFFSET_AFTER,
+			 htonl(natseq->offset_after)))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest_parms);
 
@@ -390,7 +397,8 @@ ctnetlink_dump_nat_seq_adj(struct sk_buff *skb, const struct nf_conn *ct)
 static inline int
 ctnetlink_dump_id(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	NLA_PUT_BE32(skb, CTA_ID, htonl((unsigned long)ct));
+	if (nla_put_be32(skb, CTA_ID, htonl((unsigned long)ct)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -400,7 +408,8 @@ nla_put_failure:
 static inline int
 ctnetlink_dump_use(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	NLA_PUT_BE32(skb, CTA_USE, htonl(atomic_read(&ct->ct_general.use)));
+	if (nla_put_be32(skb, CTA_USE, htonl(atomic_read(&ct->ct_general.use))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -440,8 +449,9 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
-	if (nf_ct_zone(ct))
-		NLA_PUT_BE16(skb, CTA_ZONE, htons(nf_ct_zone(ct)));
+	if (nf_ct_zone(ct) &&
+	    nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
+		goto nla_put_failure;
 
 	if (ctnetlink_dump_status(skb, ct) < 0 ||
 	    ctnetlink_dump_timeout(skb, ct) < 0 ||
@@ -617,8 +627,9 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
-	if (nf_ct_zone(ct))
-		NLA_PUT_BE16(skb, CTA_ZONE, htons(nf_ct_zone(ct)));
+	if (nf_ct_zone(ct) &&
+	    nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
+		goto nla_put_failure;
 
 	if (ctnetlink_dump_id(skb, ct) < 0)
 		goto nla_put_failure;
@@ -1705,7 +1716,8 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 		if (!nest_parms)
 			goto nla_put_failure;
 
-		NLA_PUT_BE32(skb, CTA_EXPECT_NAT_DIR, htonl(exp->dir));
+		if (nla_put_be32(skb, CTA_EXPECT_NAT_DIR, htonl(exp->dir)))
+			goto nla_put_failure;
 
 		nat_tuple.src.l3num = nf_ct_l3num(master);
 		nat_tuple.src.u3.ip = exp->saved_ip;
@@ -1718,21 +1730,24 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 	        nla_nest_end(skb, nest_parms);
 	}
 #endif
-	NLA_PUT_BE32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout));
-	NLA_PUT_BE32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp));
-	NLA_PUT_BE32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags));
-	NLA_PUT_BE32(skb, CTA_EXPECT_CLASS, htonl(exp->class));
+	if (nla_put_be32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout)) ||
+	    nla_put_be32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp)) ||
+	    nla_put_be32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags)) ||
+	    nla_put_be32(skb, CTA_EXPECT_CLASS, htonl(exp->class)))
+		goto nla_put_failure;
 	help = nfct_help(master);
 	if (help) {
 		struct nf_conntrack_helper *helper;
 
 		helper = rcu_dereference(help->helper);
-		if (helper)
-			NLA_PUT_STRING(skb, CTA_EXPECT_HELP_NAME, helper->name);
+		if (helper &&
+		    nla_put_string(skb, CTA_EXPECT_HELP_NAME, helper->name))
+			goto nla_put_failure;
 	}
 	expfn = nf_ct_helper_expectfn_find_by_symbol(exp->expectfn);
-	if (expfn != NULL)
-		NLA_PUT_STRING(skb, CTA_EXPECT_FN, expfn->name);
+	if (expfn != NULL &&
+	    nla_put_string(skb, CTA_EXPECT_FN, expfn->name))
+		goto nla_put_failure;
 
 	return 0;
 
-- 
1.7.7.6
