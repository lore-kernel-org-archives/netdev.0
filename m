From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 18/31: ctnetlink: use nlmsg_* helper function to build messages
Date: Wed, 10 Jun 2009 21:46:44 +0200 (MEST)
Message-ID: <20090610194642.11112.1193.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 96bcf938dc9637e8bb8b2c5d7885d72af5cd10af
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:07:39 2009 +0200

    netfilter: ctnetlink: use nlmsg_* helper function to build messages
    
    Replaces the old macros to build Netlink messages with the
    new nlmsg_*() helper functions.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 3553f39..5c14867 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -353,13 +353,14 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
-	unsigned char *b = skb_tail_pointer(skb);
+	unsigned int flags = pid ? NLM_F_MULTI : 0;
 
 	event |= NFNL_SUBSYS_CTNETLINK << 8;
-	nlh    = NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
-	nfmsg  = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
-	nlh->nlmsg_flags    = pid ? NLM_F_MULTI : 0;
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = nf_ct_l3num(ct);
 	nfmsg->version      = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
@@ -392,12 +393,12 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	    ctnetlink_dump_nat_seq_adj(skb, ct) < 0)
 		goto nla_put_failure;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	nlmsg_end(skb, nlh);
 	return skb->len;
 
 nlmsg_failure:
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nlmsg_cancel(skb, nlh);
 	return -1;
 }
 
@@ -431,7 +432,7 @@ ctnetlink_alloc_skb(const struct nf_conntrack_tuple *tuple, gfp_t gfp)
 #define NLA_TYPE_SIZE(type)		nla_total_size(sizeof(type))
 
 	/* proto independant part */
-	len = NLMSG_SPACE(sizeof(struct nfgenmsg))
+	len = NLMSG_ALIGN(sizeof(struct nfgenmsg))
 		+ 3 * nla_total_size(0)		/* CTA_TUPLE_ORIG|REPL|MASTER */
 		+ 3 * nla_total_size(0)		/* CTA_TUPLE_IP */
 		+ 3 * nla_total_size(0)		/* CTA_TUPLE_PROTO */
@@ -471,7 +472,7 @@ ctnetlink_alloc_skb(const struct nf_conntrack_tuple *tuple, gfp_t gfp)
 	len += l4proto->nla_size;
 	rcu_read_unlock();
 
-	return alloc_skb(len, gfp);
+	return nlmsg_new(len, gfp);
 }
 
 static int ctnetlink_conntrack_event(struct notifier_block *this,
@@ -484,7 +485,6 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	struct nf_conn *ct = item->ct;
 	struct sk_buff *skb;
 	unsigned int type;
-	sk_buff_data_t b;
 	unsigned int flags = 0, group;
 
 	/* ignore our fake conntrack entry */
@@ -512,13 +512,12 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	if (!skb)
 		goto errout;
 
-	b = skb->tail;
-
 	type |= NFNL_SUBSYS_CTNETLINK << 8;
-	nlh   = NLMSG_PUT(skb, item->pid, 0, type, sizeof(struct nfgenmsg));
-	nfmsg = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, item->pid, 0, type, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
-	nlh->nlmsg_flags    = flags;
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = nf_ct_l3num(ct);
 	nfmsg->version	= NFNETLINK_V0;
 	nfmsg->res_id	= 0;
@@ -582,12 +581,13 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 #endif
 	rcu_read_unlock();
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 	nfnetlink_send(skb, item->pid, group, item->report);
 	return NOTIFY_DONE;
 
 nla_put_failure:
 	rcu_read_unlock();
+	nlmsg_cancel(skb, nlh);
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
@@ -609,7 +609,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(cb->nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
 
 	rcu_read_lock();
@@ -789,7 +789,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
@@ -844,7 +844,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
 	struct sk_buff *skb2 = NULL;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
@@ -869,8 +869,8 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
 	err = -ENOMEM;
-	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb2) {
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL) {
 		nf_ct_put(ct);
 		return -ENOMEM;
 	}
@@ -1322,7 +1322,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 {
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
@@ -1504,13 +1504,14 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned char *b = skb_tail_pointer(skb);
+	unsigned int flags = pid ? NLM_F_MULTI : 0;
 
 	event |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
-	nlh    = NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
-	nfmsg  = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
-	nlh->nlmsg_flags    = pid ? NLM_F_MULTI : 0;
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = exp->tuple.src.l3num;
 	nfmsg->version	    = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
@@ -1518,12 +1519,12 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	if (ctnetlink_exp_dump_expect(skb, exp) < 0)
 		goto nla_put_failure;
 
-	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
+	nlmsg_end(skb, nlh);
 	return skb->len;
 
 nlmsg_failure:
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nlmsg_cancel(skb, nlh);
 	return -1;
 }
 
@@ -1537,7 +1538,6 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	struct nf_conntrack_expect *exp = item->exp;
 	struct sk_buff *skb;
 	unsigned int type;
-	sk_buff_data_t b;
 	int flags = 0;
 
 	if (events & IPEXP_NEW) {
@@ -1550,17 +1550,16 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	    !nfnetlink_has_listeners(NFNLGRP_CONNTRACK_EXP_NEW))
 		return NOTIFY_DONE;
 
-	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
-	if (!skb)
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (skb == NULL)
 		goto errout;
 
-	b = skb->tail;
-
 	type |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
-	nlh   = NLMSG_PUT(skb, item->pid, 0, type, sizeof(struct nfgenmsg));
-	nfmsg = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, item->pid, 0, type, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
 
-	nlh->nlmsg_flags    = flags;
+	nfmsg = nlmsg_data(nlh);
 	nfmsg->nfgen_family = exp->tuple.src.l3num;
 	nfmsg->version	    = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
@@ -1570,12 +1569,13 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 		goto nla_put_failure;
 	rcu_read_unlock();
 
-	nlh->nlmsg_len = skb->tail - b;
+	nlmsg_end(skb, nlh);
 	nfnetlink_send(skb, item->pid, NFNLGRP_CONNTRACK_EXP_NEW, item->report);
 	return NOTIFY_DONE;
 
 nla_put_failure:
 	rcu_read_unlock();
+	nlmsg_cancel(skb, nlh);
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
@@ -1595,7 +1595,7 @@ ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = &init_net;
 	struct nf_conntrack_expect *exp, *last;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(cb->nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	struct hlist_node *n;
 	u_int8_t l3proto = nfmsg->nfgen_family;
 
@@ -1648,7 +1648,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct sk_buff *skb2;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
@@ -1679,8 +1679,8 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	err = -ENOMEM;
-	skb2 = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb2)
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
 		goto out;
 
 	rcu_read_lock();
@@ -1708,7 +1708,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_helper *h;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct hlist_node *n, *next;
 	u_int8_t u3 = nfmsg->nfgen_family;
 	unsigned int i;
@@ -1849,7 +1849,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
-	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	int err = 0;
 
