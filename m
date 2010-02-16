From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/62: ctnetlink: netns support
Date: Tue, 16 Feb 2010 15:55:33 +0100 (MET)
Message-ID: <20100216145530.2796.37950.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 9592a5c01e79dbc59eb56fa26b124e94ffcd0962
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Wed Jan 13 16:04:18 2010 +0100

    netfilter: ctnetlink: netns support
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index d4c5d06..79478df 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -30,6 +30,7 @@
 
 #include <linux/netfilter.h>
 #include <net/netlink.h>
+#include <net/sock.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -456,6 +457,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 static int
 ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 {
+	struct net *net;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
@@ -482,7 +484,8 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	} else
 		return 0;
 
-	if (!item->report && !nfnetlink_has_listeners(&init_net, group))
+	net = nf_ct_net(ct);
+	if (!item->report && !nfnetlink_has_listeners(net, group))
 		return 0;
 
 	skb = nlmsg_new(ctnetlink_nlmsg_size(ct), GFP_ATOMIC);
@@ -559,7 +562,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	err = nfnetlink_send(skb, &init_net, item->pid, group, item->report,
+	err = nfnetlink_send(skb, net, item->pid, group, item->report,
 			     GFP_ATOMIC);
 	if (err == -ENOBUFS || err == -EAGAIN)
 		return -ENOBUFS;
@@ -572,7 +575,7 @@ nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
-	nfnetlink_set_err(&init_net, 0, group, -ENOBUFS);
+	nfnetlink_set_err(net, 0, group, -ENOBUFS);
 	return 0;
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
@@ -587,6 +590,7 @@ static int ctnetlink_done(struct netlink_callback *cb)
 static int
 ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
@@ -597,7 +601,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
-		hlist_nulls_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
+		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[cb->args[0]],
 					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
@@ -769,6 +773,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -782,7 +787,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
 		/* Flush the whole table */
-		nf_conntrack_flush_report(&init_net,
+		nf_conntrack_flush_report(net,
 					 NETLINK_CB(skb).pid,
 					 nlmsg_report(nlh));
 		return 0;
@@ -791,7 +796,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -829,6 +834,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -851,7 +857,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1176,7 +1182,8 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 }
 
 static struct nf_conn *
-ctnetlink_create_conntrack(const struct nlattr * const cda[],
+ctnetlink_create_conntrack(struct net *net,
+			   const struct nlattr * const cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
 			   u8 u3)
@@ -1185,7 +1192,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 	int err = -EINVAL;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, otuple, rtuple, GFP_ATOMIC);
 	if (IS_ERR(ct))
 		return ERR_PTR(-ENOMEM);
 
@@ -1286,7 +1293,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 		if (err < 0)
 			goto err2;
 
-		master_h = nf_conntrack_find_get(&init_net, &master);
+		master_h = nf_conntrack_find_get(net, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
 			goto err2;
@@ -1314,6 +1321,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1334,9 +1342,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = __nf_conntrack_find(&init_net, &otuple);
+		h = __nf_conntrack_find(net, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = __nf_conntrack_find(&init_net, &rtuple);
+		h = __nf_conntrack_find(net, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
@@ -1344,7 +1352,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			struct nf_conn *ct;
 			enum ip_conntrack_events events;
 
-			ct = ctnetlink_create_conntrack(cda, &otuple,
+			ct = ctnetlink_create_conntrack(net, cda, &otuple,
 							&rtuple, u3);
 			if (IS_ERR(ct)) {
 				err = PTR_ERR(ct);
@@ -1526,9 +1534,10 @@ nla_put_failure:
 static int
 ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 {
+	struct nf_conntrack_expect *exp = item->exp;
+	struct net *net = nf_ct_exp_net(exp);
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	struct nf_conntrack_expect *exp = item->exp;
 	struct sk_buff *skb;
 	unsigned int type;
 	int flags = 0;
@@ -1540,7 +1549,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 		return 0;
 
 	if (!item->report &&
-	    !nfnetlink_has_listeners(&init_net, NFNLGRP_CONNTRACK_EXP_NEW))
+	    !nfnetlink_has_listeners(net, NFNLGRP_CONNTRACK_EXP_NEW))
 		return 0;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
@@ -1563,7 +1572,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	nfnetlink_send(skb, &init_net, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
+	nfnetlink_send(skb, net, item->pid, NFNLGRP_CONNTRACK_EXP_NEW,
 		       item->report, GFP_ATOMIC);
 	return 0;
 
@@ -1573,7 +1582,7 @@ nla_put_failure:
 nlmsg_failure:
 	kfree_skb(skb);
 errout:
-	nfnetlink_set_err(&init_net, 0, 0, -ENOBUFS);
+	nfnetlink_set_err(net, 0, 0, -ENOBUFS);
 	return 0;
 }
 #endif
@@ -1587,7 +1596,7 @@ static int ctnetlink_exp_done(struct netlink_callback *cb)
 static int
 ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct nf_conntrack_expect *exp, *last;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	struct hlist_node *n;
@@ -1640,6 +1649,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct sk_buff *skb2;
@@ -1661,7 +1671,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(&init_net, &tuple);
+	exp = nf_ct_expect_find_get(net, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -1701,6 +1711,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_helper *h;
@@ -1717,7 +1728,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(&init_net, &tuple);
+		exp = nf_ct_expect_find_get(net, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -1747,7 +1758,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &init_net.ct.expect_hash[i],
+						  &net->ct.expect_hash[i],
 						  hnode) {
 				m_help = nfct_help(exp->master);
 				if (m_help->helper == h
@@ -1763,7 +1774,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		spin_lock_bh(&nf_conntrack_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &init_net.ct.expect_hash[i],
+						  &net->ct.expect_hash[i],
 						  hnode) {
 				if (del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect(exp);
@@ -1784,7 +1795,8 @@ ctnetlink_change_expect(struct nf_conntrack_expect *x,
 }
 
 static int
-ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
+ctnetlink_create_expect(struct net *net, const struct nlattr * const cda[],
+			u_int8_t u3,
 			u32 pid, int report)
 {
 	struct nf_conntrack_tuple tuple, mask, master_tuple;
@@ -1806,7 +1818,7 @@ ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
 		return err;
 
 	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(&init_net, &master_tuple);
+	h = nf_conntrack_find_get(net, &master_tuple);
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
@@ -1846,6 +1858,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1862,13 +1875,13 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		return err;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = __nf_ct_expect_find(&init_net, &tuple);
+	exp = __nf_ct_expect_find(net, &tuple);
 
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
-			err = ctnetlink_create_expect(cda,
+			err = ctnetlink_create_expect(net, cda,
 						      u3,
 						      NETLINK_CB(skb).pid,
 						      nlmsg_report(nlh));
