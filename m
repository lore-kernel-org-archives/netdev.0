From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 19/31: ctnetlink: cleanup message-size calculation
Date: Wed, 10 Jun 2009 21:46:45 +0200 (MEST)
Message-ID: <20090610194644.11112.91537.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761151AbZFJTqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:43 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 03b64f518a893512d32f07a10b053e558beafcaf
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:08:27 2009 +0200

    netfilter: ctnetlink: cleanup message-size calculation
    
    This patch cleans up the message calculation to make it similar
    to rtnetlink, moreover, it removes unneeded verbose information.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5c14867..58fde0e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -403,76 +403,55 @@ nla_put_failure:
 }
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
-/*
- * The general structure of a ctnetlink event is
- *
- *  CTA_TUPLE_ORIG
- *    <l3/l4-proto-attributes>
- *  CTA_TUPLE_REPLY
- *    <l3/l4-proto-attributes>
- *  CTA_ID
- *  ...
- *  CTA_PROTOINFO
- *    <l4-proto-attributes>
- *  CTA_TUPLE_MASTER
- *    <l3/l4-proto-attributes>
- *
- * Therefore the formular is
- *
- *   size = sizeof(headers) + sizeof(generic_nlas) + 3 * sizeof(tuple_nlas)
- *		+ sizeof(protoinfo_nlas)
- */
-static struct sk_buff *
-ctnetlink_alloc_skb(const struct nf_conntrack_tuple *tuple, gfp_t gfp)
+static inline size_t
+ctnetlink_proto_size(const struct nf_conn *ct)
 {
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
-	int len;
-
-#define NLA_TYPE_SIZE(type)		nla_total_size(sizeof(type))
-
-	/* proto independant part */
-	len = NLMSG_ALIGN(sizeof(struct nfgenmsg))
-		+ 3 * nla_total_size(0)		/* CTA_TUPLE_ORIG|REPL|MASTER */
-		+ 3 * nla_total_size(0)		/* CTA_TUPLE_IP */
-		+ 3 * nla_total_size(0)		/* CTA_TUPLE_PROTO */
-		+ 3 * NLA_TYPE_SIZE(u_int8_t)	/* CTA_PROTO_NUM */
-		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_ID */
-		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_STATUS */
+	size_t len = 0;
+
+	rcu_read_lock();
+	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
+	len += l3proto->nla_size;
+
+	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	len += l4proto->nla_size;
+	rcu_read_unlock();
+
+	return len;
+}
+
+static inline size_t
+ctnetlink_nlmsg_size(const struct nf_conn *ct)
+{
+	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
+	       + 3 * nla_total_size(0) /* CTA_TUPLE_ORIG|REPL|MASTER */
+	       + 3 * nla_total_size(0) /* CTA_TUPLE_IP */
+	       + 3 * nla_total_size(0) /* CTA_TUPLE_PROTO */
+	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
 #ifdef CONFIG_NF_CT_ACCT
-		+ 2 * nla_total_size(0)		/* CTA_COUNTERS_ORIG|REPL */
-		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_PACKETS */
-		+ 2 * NLA_TYPE_SIZE(uint64_t)	/* CTA_COUNTERS_BYTES */
+	       + 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
 #endif
-		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_TIMEOUT */
-		+ nla_total_size(0)		/* CTA_PROTOINFO */
-		+ nla_total_size(0)		/* CTA_HELP */
-		+ nla_total_size(NF_CT_HELPER_NAME_LEN)	/* CTA_HELP_NAME */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
+	       + nla_total_size(0) /* CTA_PROTOINFO */
+	       + nla_total_size(0) /* CTA_HELP */
+	       + nla_total_size(NF_CT_HELPER_NAME_LEN) /* CTA_HELP_NAME */
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
-		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_SECMARK */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_SECMARK */
 #endif
 #ifdef CONFIG_NF_NAT_NEEDED
-		+ 2 * nla_total_size(0)		/* CTA_NAT_SEQ_ADJ_ORIG|REPL */
-		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_POS */
-		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_BEFORE */
-		+ 2 * NLA_TYPE_SIZE(u_int32_t)	/* CTA_NAT_SEQ_CORRECTION_AFTER */
+	       + 2 * nla_total_size(0) /* CTA_NAT_SEQ_ADJ_ORIG|REPL */
+	       + 6 * nla_total_size(sizeof(u_int32_t)) /* CTA_NAT_SEQ_OFFSET */
 #endif
 #ifdef CONFIG_NF_CONNTRACK_MARK
-		+ NLA_TYPE_SIZE(u_int32_t)	/* CTA_MARK */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_MARK */
 #endif
-		;
-
-#undef NLA_TYPE_SIZE
-
-	rcu_read_lock();
-	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
-	len += l3proto->nla_size;
-
-	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
-	len += l4proto->nla_size;
-	rcu_read_unlock();
-
-	return nlmsg_new(len, gfp);
+	       + ctnetlink_proto_size(ct)
+	       ;
 }
 
 static int ctnetlink_conntrack_event(struct notifier_block *this,
@@ -507,9 +486,8 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	if (!item->report && !nfnetlink_has_listeners(group))
 		return NOTIFY_DONE;
 
-	skb = ctnetlink_alloc_skb(nf_ct_tuple(ct, IP_CT_DIR_ORIGINAL),
-				  GFP_ATOMIC);
-	if (!skb)
+	skb = nlmsg_new(ctnetlink_nlmsg_size(ct), GFP_ATOMIC);
+	if (skb == NULL)
 		goto errout;
 
 	type |= NFNL_SUBSYS_CTNETLINK << 8;
