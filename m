From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/15] netfilter: nfacct: per network namespace support
Date: Fri, 21 Aug 2015 06:32:40 +0200
Message-ID: <1440131564-8807-12-git-send-email-pablo@netfilter.org>
References: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48161 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbbHUE10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 00:27:26 -0400
In-Reply-To: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>

- Move the nfnl_acct_list into the network namespace, initialize
  and destroy it per namespace
- Keep track of refcnt on nfacct objects, the old logic does not
  longer work with a per namespace list
- Adjust xt_nfacct to pass the namespace when registring objects

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_acct.h |    3 +-
 include/net/net_namespace.h              |    3 ++
 net/netfilter/nfnetlink_acct.c           |   71 +++++++++++++++++++++---------
 net/netfilter/xt_nfacct.c                |    2 +-
 4 files changed, 56 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_acct.h b/include/linux/netfilter/nfnetlink_acct.h
index 6ec9757..80ca889 100644
--- a/include/linux/netfilter/nfnetlink_acct.h
+++ b/include/linux/netfilter/nfnetlink_acct.h
@@ -2,6 +2,7 @@
 #define _NFNL_ACCT_H_
 
 #include <uapi/linux/netfilter/nfnetlink_acct.h>
+#include <net/net_namespace.h>
 
 enum {
 	NFACCT_NO_QUOTA		= -1,
@@ -11,7 +12,7 @@ enum {
 
 struct nf_acct;
 
-struct nf_acct *nfnl_acct_find_get(const char *filter_name);
+struct nf_acct *nfnl_acct_find_get(struct net *net, const char *filter_name);
 void nfnl_acct_put(struct nf_acct *acct);
 void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct);
 extern int nfnl_acct_overquota(const struct sk_buff *skb,
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index e951453..2dcea63 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -118,6 +118,9 @@ struct net {
 #endif
 	struct sock		*nfnl;
 	struct sock		*nfnl_stash;
+#if IS_ENABLED(CONFIG_NETFILTER_NETLINK_ACCT)
+	struct list_head        nfnl_acct_list;
+#endif
 #endif
 #ifdef CONFIG_WEXT_CORE
 	struct sk_buff_head	wext_nlevents;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index c18af2f..fefbf5f 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -27,8 +27,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
 MODULE_DESCRIPTION("nfacct: Extended Netfilter accounting infrastructure");
 
-static LIST_HEAD(nfnl_acct_list);
-
 struct nf_acct {
 	atomic64_t		pkts;
 	atomic64_t		bytes;
@@ -53,6 +51,7 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
 {
 	struct nf_acct *nfacct, *matching = NULL;
+	struct net *net = sock_net(nfnl);
 	char *acct_name;
 	unsigned int size = 0;
 	u32 flags = 0;
@@ -64,7 +63,7 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 	if (strlen(acct_name) == 0)
 		return -EINVAL;
 
-	list_for_each_entry(nfacct, &nfnl_acct_list, head) {
+	list_for_each_entry(nfacct, &net->nfnl_acct_list, head) {
 		if (strncmp(nfacct->name, acct_name, NFACCT_NAME_MAX) != 0)
 			continue;
 
@@ -124,7 +123,7 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 			     be64_to_cpu(nla_get_be64(tb[NFACCT_PKTS])));
 	}
 	atomic_set(&nfacct->refcnt, 1);
-	list_add_tail_rcu(&nfacct->head, &nfnl_acct_list);
+	list_add_tail_rcu(&nfacct->head, &net->nfnl_acct_list);
 	return 0;
 }
 
@@ -185,6 +184,7 @@ nla_put_failure:
 static int
 nfnl_acct_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nf_acct *cur, *last;
 	const struct nfacct_filter *filter = cb->data;
 
@@ -196,7 +196,7 @@ nfnl_acct_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[1] = 0;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(cur, &nfnl_acct_list, head) {
+	list_for_each_entry_rcu(cur, &net->nfnl_acct_list, head) {
 		if (last) {
 			if (cur != last)
 				continue;
@@ -257,6 +257,7 @@ static int
 nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
 {
+	struct net *net = sock_net(nfnl);
 	int ret = -ENOENT;
 	struct nf_acct *cur;
 	char *acct_name;
@@ -283,7 +284,7 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 		return -EINVAL;
 	acct_name = nla_data(tb[NFACCT_NAME]);
 
-	list_for_each_entry(cur, &nfnl_acct_list, head) {
+	list_for_each_entry(cur, &net->nfnl_acct_list, head) {
 		struct sk_buff *skb2;
 
 		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX)!= 0)
@@ -336,19 +337,20 @@ static int
 nfnl_acct_del(struct sock *nfnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
 {
+	struct net *net = sock_net(nfnl);
 	char *acct_name;
 	struct nf_acct *cur;
 	int ret = -ENOENT;
 
 	if (!tb[NFACCT_NAME]) {
-		list_for_each_entry(cur, &nfnl_acct_list, head)
+		list_for_each_entry(cur, &net->nfnl_acct_list, head)
 			nfnl_acct_try_del(cur);
 
 		return 0;
 	}
 	acct_name = nla_data(tb[NFACCT_NAME]);
 
-	list_for_each_entry(cur, &nfnl_acct_list, head) {
+	list_for_each_entry(cur, &net->nfnl_acct_list, head) {
 		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX) != 0)
 			continue;
 
@@ -394,12 +396,12 @@ static const struct nfnetlink_subsystem nfnl_acct_subsys = {
 
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_ACCT);
 
-struct nf_acct *nfnl_acct_find_get(const char *acct_name)
+struct nf_acct *nfnl_acct_find_get(struct net *net, const char *acct_name)
 {
 	struct nf_acct *cur, *acct = NULL;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(cur, &nfnl_acct_list, head) {
+	list_for_each_entry_rcu(cur, &net->nfnl_acct_list, head) {
 		if (strncmp(cur->name, acct_name, NFACCT_NAME_MAX)!= 0)
 			continue;
 
@@ -422,7 +424,9 @@ EXPORT_SYMBOL_GPL(nfnl_acct_find_get);
 
 void nfnl_acct_put(struct nf_acct *acct)
 {
-	atomic_dec(&acct->refcnt);
+	if (atomic_dec_and_test(&acct->refcnt))
+		kfree_rcu(acct, rcu_head);
+
 	module_put(THIS_MODULE);
 }
 EXPORT_SYMBOL_GPL(nfnl_acct_put);
@@ -478,34 +482,59 @@ int nfnl_acct_overquota(const struct sk_buff *skb, struct nf_acct *nfacct)
 }
 EXPORT_SYMBOL_GPL(nfnl_acct_overquota);
 
+static int __net_init nfnl_acct_net_init(struct net *net)
+{
+	INIT_LIST_HEAD(&net->nfnl_acct_list);
+
+	return 0;
+}
+
+static void __net_exit nfnl_acct_net_exit(struct net *net)
+{
+	struct nf_acct *cur, *tmp;
+
+	list_for_each_entry_safe(cur, tmp, &net->nfnl_acct_list, head) {
+		list_del_rcu(&cur->head);
+
+		if (atomic_dec_and_test(&cur->refcnt))
+			kfree_rcu(cur, rcu_head);
+	}
+}
+
+static struct pernet_operations nfnl_acct_ops = {
+        .init   = nfnl_acct_net_init,
+        .exit   = nfnl_acct_net_exit,
+};
+
 static int __init nfnl_acct_init(void)
 {
 	int ret;
 
+	ret = register_pernet_subsys(&nfnl_acct_ops);
+	if (ret < 0) {
+		pr_err("nfnl_acct_init: failed to register pernet ops\n");
+		goto err_out;
+	}
+
 	pr_info("nfnl_acct: registering with nfnetlink.\n");
 	ret = nfnetlink_subsys_register(&nfnl_acct_subsys);
 	if (ret < 0) {
 		pr_err("nfnl_acct_init: cannot register with nfnetlink.\n");
-		goto err_out;
+		goto cleanup_pernet;
 	}
 	return 0;
+
+cleanup_pernet:
+	unregister_pernet_subsys(&nfnl_acct_ops);
 err_out:
 	return ret;
 }
 
 static void __exit nfnl_acct_exit(void)
 {
-	struct nf_acct *cur, *tmp;
-
 	pr_info("nfnl_acct: unregistering from nfnetlink.\n");
 	nfnetlink_subsys_unregister(&nfnl_acct_subsys);
-
-	list_for_each_entry_safe(cur, tmp, &nfnl_acct_list, head) {
-		list_del_rcu(&cur->head);
-		/* We are sure that our objects have no clients at this point,
-		 * it's safe to release them all without checking refcnt. */
-		kfree_rcu(cur, rcu_head);
-	}
+	unregister_pernet_subsys(&nfnl_acct_ops);
 }
 
 module_init(nfnl_acct_init);
diff --git a/net/netfilter/xt_nfacct.c b/net/netfilter/xt_nfacct.c
index 8c646ed..3048a7e 100644
--- a/net/netfilter/xt_nfacct.c
+++ b/net/netfilter/xt_nfacct.c
@@ -37,7 +37,7 @@ nfacct_mt_checkentry(const struct xt_mtchk_param *par)
 	struct xt_nfacct_match_info *info = par->matchinfo;
 	struct nf_acct *nfacct;
 
-	nfacct = nfnl_acct_find_get(info->name);
+	nfacct = nfnl_acct_find_get(par->net, info->name);
 	if (nfacct == NULL) {
 		pr_info("xt_nfacct: accounting object with name `%s' "
 			"does not exists\n", info->name);
-- 
1.7.10.4
