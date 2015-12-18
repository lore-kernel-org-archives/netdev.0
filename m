From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/23] netfilter: cttimeout: add netns support
Date: Fri, 18 Dec 2015 21:26:45 +0100
Message-ID: <1450470409-31427-20-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58102 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965218AbbLRUeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:11 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3A98117F1CB
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E7DBEDA86C
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 898B2DA87A
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:06 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira <pablo@netfilter.org>

Add a per-netns list of timeout objects and adjust code to use it.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/net_namespace.h                  |  3 +
 include/net/netfilter/nf_conntrack_timeout.h |  2 +-
 net/netfilter/nf_conntrack_timeout.c         |  2 +-
 net/netfilter/nfnetlink_cttimeout.c          | 82 +++++++++++++++++-----------
 net/netfilter/xt_CT.c                        |  2 +-
 5 files changed, 57 insertions(+), 34 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2dcea63..4089abc 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -121,6 +121,9 @@ struct net {
 #if IS_ENABLED(CONFIG_NETFILTER_NETLINK_ACCT)
 	struct list_head        nfnl_acct_list;
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	struct list_head	nfct_timeout_list;
+#endif
 #endif
 #ifdef CONFIG_WEXT_CORE
 	struct sk_buff_head	wext_nlevents;
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index f72be38..5cc5e9e 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -104,7 +104,7 @@ static inline void nf_conntrack_timeout_fini(void)
 #endif /* CONFIG_NF_CONNTRACK_TIMEOUT */
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-extern struct ctnl_timeout *(*nf_ct_timeout_find_get_hook)(const char *name);
+extern struct ctnl_timeout *(*nf_ct_timeout_find_get_hook)(struct net *net, const char *name);
 extern void (*nf_ct_timeout_put_hook)(struct ctnl_timeout *timeout);
 #endif
 
diff --git a/net/netfilter/nf_conntrack_timeout.c b/net/netfilter/nf_conntrack_timeout.c
index 93da609..26e7420 100644
--- a/net/netfilter/nf_conntrack_timeout.c
+++ b/net/netfilter/nf_conntrack_timeout.c
@@ -25,7 +25,7 @@
 #include <net/netfilter/nf_conntrack_timeout.h>
 
 struct ctnl_timeout *
-(*nf_ct_timeout_find_get_hook)(const char *name) __read_mostly;
+(*nf_ct_timeout_find_get_hook)(struct net *net, const char *name) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_timeout_find_get_hook);
 
 void (*nf_ct_timeout_put_hook)(struct ctnl_timeout *timeout) __read_mostly;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index c7a2d0e..3921d54 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -38,8 +38,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
 MODULE_DESCRIPTION("cttimeout: Extended Netfilter Connection Tracking timeout tuning");
 
-static LIST_HEAD(cttimeout_list);
-
 static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
 	[CTA_TIMEOUT_NAME]	= { .type = NLA_NUL_STRING,
 				    .len  = CTNL_TIMEOUT_NAME_MAX - 1},
@@ -90,7 +88,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 	l3num = ntohs(nla_get_be16(cda[CTA_TIMEOUT_L3PROTO]));
 	l4num = nla_get_u8(cda[CTA_TIMEOUT_L4PROTO]);
 
-	list_for_each_entry(timeout, &cttimeout_list, head) {
+	list_for_each_entry(timeout, &net->nfct_timeout_list, head) {
 		if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
 			continue;
 
@@ -145,7 +143,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 	timeout->l3num = l3num;
 	timeout->l4proto = l4proto;
 	atomic_set(&timeout->refcnt, 1);
-	list_add_tail_rcu(&timeout->head, &cttimeout_list);
+	list_add_tail_rcu(&timeout->head, &net->nfct_timeout_list);
 
 	return 0;
 err:
@@ -209,6 +207,7 @@ nla_put_failure:
 static int
 ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct ctnl_timeout *cur, *last;
 
 	if (cb->args[2])
@@ -219,7 +218,7 @@ ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[1] = 0;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(cur, &cttimeout_list, head) {
+	list_for_each_entry_rcu(cur, &net->nfct_timeout_list, head) {
 		if (last) {
 			if (cur != last)
 				continue;
@@ -245,6 +244,7 @@ cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
 		      const struct nlmsghdr *nlh,
 		      const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(skb->sk);
 	int ret = -ENOENT;
 	char *name;
 	struct ctnl_timeout *cur;
@@ -260,7 +260,7 @@ cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
 		return -EINVAL;
 	name = nla_data(cda[CTA_TIMEOUT_NAME]);
 
-	list_for_each_entry(cur, &cttimeout_list, head) {
+	list_for_each_entry(cur, &net->nfct_timeout_list, head) {
 		struct sk_buff *skb2;
 
 		if (strncmp(cur->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
@@ -301,17 +301,17 @@ static void untimeout(struct nf_conntrack_tuple_hash *i,
 		RCU_INIT_POINTER(timeout_ext->timeout, NULL);
 }
 
-static void ctnl_untimeout(struct ctnl_timeout *timeout)
+static void ctnl_untimeout(struct net *net, struct ctnl_timeout *timeout)
 {
 	struct nf_conntrack_tuple_hash *h;
 	const struct hlist_nulls_node *nn;
 	int i;
 
 	local_bh_disable();
-	for (i = 0; i < init_net.ct.htable_size; i++) {
+	for (i = 0; i < net->ct.htable_size; i++) {
 		spin_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
-		if (i < init_net.ct.htable_size) {
-			hlist_nulls_for_each_entry(h, nn, &init_net.ct.hash[i], hnnode)
+		if (i < net->ct.htable_size) {
+			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 				untimeout(h, timeout);
 		}
 		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
@@ -320,7 +320,7 @@ static void ctnl_untimeout(struct ctnl_timeout *timeout)
 }
 
 /* try to delete object, fail if it is still in use. */
-static int ctnl_timeout_try_del(struct ctnl_timeout *timeout)
+static int ctnl_timeout_try_del(struct net *net, struct ctnl_timeout *timeout)
 {
 	int ret = 0;
 
@@ -329,7 +329,7 @@ static int ctnl_timeout_try_del(struct ctnl_timeout *timeout)
 		/* We are protected by nfnl mutex. */
 		list_del_rcu(&timeout->head);
 		nf_ct_l4proto_put(timeout->l4proto);
-		ctnl_untimeout(timeout);
+		ctnl_untimeout(net, timeout);
 		kfree_rcu(timeout, rcu_head);
 	} else {
 		/* still in use, restore reference counter. */
@@ -344,23 +344,24 @@ cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
 		      const struct nlmsghdr *nlh,
 		      const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(skb->sk);
 	char *name;
 	struct ctnl_timeout *cur;
 	int ret = -ENOENT;
 
 	if (!cda[CTA_TIMEOUT_NAME]) {
-		list_for_each_entry(cur, &cttimeout_list, head)
-			ctnl_timeout_try_del(cur);
+		list_for_each_entry(cur, &net->nfct_timeout_list, head)
+			ctnl_timeout_try_del(net, cur);
 
 		return 0;
 	}
 	name = nla_data(cda[CTA_TIMEOUT_NAME]);
 
-	list_for_each_entry(cur, &cttimeout_list, head) {
+	list_for_each_entry(cur, &net->nfct_timeout_list, head) {
 		if (strncmp(cur->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
 			continue;
 
-		ret = ctnl_timeout_try_del(cur);
+		ret = ctnl_timeout_try_del(net, cur);
 		if (ret < 0)
 			return ret;
 
@@ -511,12 +512,13 @@ err:
 }
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-static struct ctnl_timeout *ctnl_timeout_find_get(const char *name)
+static struct ctnl_timeout *
+ctnl_timeout_find_get(struct net *net, const char *name)
 {
 	struct ctnl_timeout *timeout, *matching = NULL;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(timeout, &cttimeout_list, head) {
+	list_for_each_entry_rcu(timeout, &net->nfct_timeout_list, head) {
 		if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
 			continue;
 
@@ -569,10 +571,39 @@ static const struct nfnetlink_subsystem cttimeout_subsys = {
 
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_CTNETLINK_TIMEOUT);
 
+static int __net_init cttimeout_net_init(struct net *net)
+{
+	INIT_LIST_HEAD(&net->nfct_timeout_list);
+
+	return 0;
+}
+
+static void __net_exit cttimeout_net_exit(struct net *net)
+{
+	struct ctnl_timeout *cur, *tmp;
+
+	ctnl_untimeout(net, NULL);
+
+	list_for_each_entry_safe(cur, tmp, &net->nfct_timeout_list, head) {
+		list_del_rcu(&cur->head);
+		nf_ct_l4proto_put(cur->l4proto);
+		kfree_rcu(cur, rcu_head);
+	}
+}
+
+static struct pernet_operations cttimeout_ops = {
+	.init	= cttimeout_net_init,
+	.exit	= cttimeout_net_exit,
+};
+
 static int __init cttimeout_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&cttimeout_ops);
+	if (ret < 0)
+		return ret;
+
 	ret = nfnetlink_subsys_register(&cttimeout_subsys);
 	if (ret < 0) {
 		pr_err("cttimeout_init: cannot register cttimeout with "
@@ -586,28 +617,17 @@ static int __init cttimeout_init(void)
 	return 0;
 
 err_out:
+	unregister_pernet_subsys(&cttimeout_ops);
 	return ret;
 }
 
 static void __exit cttimeout_exit(void)
 {
-	struct ctnl_timeout *cur, *tmp;
-
 	pr_info("cttimeout: unregistering from nfnetlink.\n");
 
 	nfnetlink_subsys_unregister(&cttimeout_subsys);
 
-	/* Make sure no conntrack objects refer to custom timeouts anymore. */
-	ctnl_untimeout(NULL);
-
-	list_for_each_entry_safe(cur, tmp, &cttimeout_list, head) {
-		list_del_rcu(&cur->head);
-		/* We are sure that our objects have no clients at this point,
-		 * it's safe to release them all without checking refcnt.
-		 */
-		nf_ct_l4proto_put(cur->l4proto);
-		kfree_rcu(cur, rcu_head);
-	}
+	unregister_pernet_subsys(&cttimeout_ops);
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	RCU_INIT_POINTER(nf_ct_timeout_find_get_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_timeout_put_hook, NULL);
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index e7ac07e..6669e68 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -143,7 +143,7 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 		goto out;
 	}
 
-	timeout = timeout_find_get(timeout_name);
+	timeout = timeout_find_get(par->net, timeout_name);
 	if (timeout == NULL) {
 		ret = -ENOENT;
 		pr_info("No such timeout policy \"%s\"\n", timeout_name);
-- 
2.1.4
