From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 14/29: ctnetlink: get rid of module refcounting in ctnetlink
Date: Thu, 27 Nov 2008 17:15:22 +0100 (MET)
Message-ID: <20081127161522.13891.89231.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53384 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbYK0QPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:23 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 528a3a6f67d4fbe708b9f306be194e78b29e8d7a
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Nov 17 16:00:40 2008 +0100

    netfilter: ctnetlink: get rid of module refcounting in ctnetlink
    
    This patch replaces the unnecessary module refcounting with
    the read-side locks. With this patch, all the dump and fill_info
    function are called under the RCU read lock.
    
    Based on a patch from Fabian Hugelshofer.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index d87a939..49a04fa 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -105,16 +105,14 @@ ctnetlink_dump_tuples(struct sk_buff *skb,
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
 
-	l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
+	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
 	ret = ctnetlink_dump_tuples_ip(skb, tuple, l3proto);
-	nf_ct_l3proto_put(l3proto);
 
 	if (unlikely(ret < 0))
 		return ret;
 
-	l4proto = nf_ct_l4proto_find_get(tuple->src.l3num, tuple->dst.protonum);
+	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
 	ret = ctnetlink_dump_tuples_proto(skb, tuple, l4proto);
-	nf_ct_l4proto_put(l4proto);
 
 	return ret;
 }
@@ -151,11 +149,9 @@ ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct nf_conn *ct)
 	struct nlattr *nest_proto;
 	int ret;
 
-	l4proto = nf_ct_l4proto_find_get(nf_ct_l3num(ct), nf_ct_protonum(ct));
-	if (!l4proto->to_nlattr) {
-		nf_ct_l4proto_put(l4proto);
+	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	if (!l4proto->to_nlattr)
 		return 0;
-	}
 
 	nest_proto = nla_nest_start(skb, CTA_PROTOINFO | NLA_F_NESTED);
 	if (!nest_proto)
@@ -163,14 +159,11 @@ ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct nf_conn *ct)
 
 	ret = l4proto->to_nlattr(skb, nest_proto, ct);
 
-	nf_ct_l4proto_put(l4proto);
-
 	nla_nest_end(skb, nest_proto);
 
 	return ret;
 
 nla_put_failure:
-	nf_ct_l4proto_put(l4proto);
 	return -1;
 }
 
@@ -184,7 +177,6 @@ ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
 	if (!help)
 		return 0;
 
-	rcu_read_lock();
 	helper = rcu_dereference(help->helper);
 	if (!helper)
 		goto out;
@@ -199,11 +191,9 @@ ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct nf_conn *ct)
 
 	nla_nest_end(skb, nest_helper);
 out:
-	rcu_read_unlock();
 	return 0;
 
 nla_put_failure:
-	rcu_read_unlock();
 	return -1;
 }
 
@@ -461,6 +451,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	nfmsg->version	= NFNETLINK_V0;
 	nfmsg->res_id	= 0;
 
+	rcu_read_lock();
 	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
 	if (!nest_parms)
 		goto nla_put_failure;
@@ -517,13 +508,15 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 	    && ctnetlink_dump_mark(skb, ct) < 0)
 		goto nla_put_failure;
 #endif
+	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
 	nfnetlink_send(skb, 0, group, 0);
 	return NOTIFY_DONE;
 
-nlmsg_failure:
 nla_put_failure:
+	rcu_read_unlock();
+nlmsg_failure:
 	kfree_skb(skb);
 	return NOTIFY_DONE;
 }
@@ -795,8 +788,10 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		return -ENOMEM;
 	}
 
+	rcu_read_lock();
 	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq,
 				  IPCTNL_MSG_CT_NEW, 1, ct);
+	rcu_read_unlock();
 	nf_ct_put(ct);
 	if (err <= 0)
 		goto free;
@@ -1292,16 +1287,14 @@ ctnetlink_exp_dump_mask(struct sk_buff *skb,
 	if (!nest_parms)
 		goto nla_put_failure;
 
-	l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
+	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
 	ret = ctnetlink_dump_tuples_ip(skb, &m, l3proto);
-	nf_ct_l3proto_put(l3proto);
 
 	if (unlikely(ret < 0))
 		goto nla_put_failure;
 
-	l4proto = nf_ct_l4proto_find_get(tuple->src.l3num, tuple->dst.protonum);
+	l4proto = __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.protonum);
 	ret = ctnetlink_dump_tuples_proto(skb, &m, l4proto);
-	nf_ct_l4proto_put(l4proto);
 	if (unlikely(ret < 0))
 		goto nla_put_failure;
 
@@ -1408,15 +1401,18 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 	nfmsg->version	    = NFNETLINK_V0;
 	nfmsg->res_id	    = 0;
 
+	rcu_read_lock();
 	if (ctnetlink_exp_dump_expect(skb, exp) < 0)
 		goto nla_put_failure;
+	rcu_read_unlock();
 
 	nlh->nlmsg_len = skb->tail - b;
 	nfnetlink_send(skb, 0, NFNLGRP_CONNTRACK_EXP_NEW, 0);
 	return NOTIFY_DONE;
 
-nlmsg_failure:
 nla_put_failure:
+	rcu_read_unlock();
+nlmsg_failure:
 	kfree_skb(skb);
 	return NOTIFY_DONE;
 }
@@ -1520,9 +1516,11 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (!skb2)
 		goto out;
 
+	rcu_read_lock();
 	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid,
 				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW,
 				      1, exp);
+	rcu_read_unlock();
 	if (err <= 0)
 		goto free;
 
