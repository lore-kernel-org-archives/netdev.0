From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 16/29: ctnetlink: helper modules load-on-demand support
Date: Thu, 27 Nov 2008 17:15:25 +0100 (MET)
Message-ID: <20081127161524.13891.37908.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53403 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbYK0QP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:26 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 226c0c0ef2abdf91b8d9cce1aaf7d4635a5e5926
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Nov 18 11:54:05 2008 +0100

    netfilter: ctnetlink: helper modules load-on-demand support
    
    This patch adds module loading for helpers via ctnetlink.
    
    * Creation path: We support explicit and implicit helper assignation. For
      the explicit case, we try to load the module. If the module is correctly
      loaded and the helper is present, we return EAGAIN to re-start the
      creation. Otherwise, we return EOPNOTSUPP.
    * Update path: release the spin lock, load the module and check. If it is
      present, then return EAGAIN to re-start the update.
    
    This patch provides a refactorized function to lookup-and-set the
    connection tracking helper. The function removes the exported symbol
    __nf_ct_helper_find as it has not clients anymore.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index f8060ab..66d65a7 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -39,9 +39,6 @@ struct nf_conntrack_helper
 };
 
 extern struct nf_conntrack_helper *
-__nf_ct_helper_find(const struct nf_conntrack_tuple *tuple);
-
-extern struct nf_conntrack_helper *
 __nf_conntrack_helper_find_byname(const char *name);
 
 extern int nf_conntrack_helper_register(struct nf_conntrack_helper *);
@@ -49,6 +46,8 @@ extern void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
 
 extern struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp);
 
+extern int __nf_ct_try_assign_helper(struct nf_conn *ct, gfp_t flags);
+
 static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
 {
 	return nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 622d7c6..1e649fb 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -588,14 +588,7 @@ init_conntrack(struct net *net,
 		nf_conntrack_get(&ct->master->ct_general);
 		NF_CT_STAT_INC(net, expect_new);
 	} else {
-		struct nf_conntrack_helper *helper;
-
-		helper = __nf_ct_helper_find(&repl_tuple);
-		if (helper) {
-			help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
-			if (help)
-				rcu_assign_pointer(help->helper, helper);
-		}
+		__nf_ct_try_assign_helper(ct, GFP_ATOMIC);
 		NF_CT_STAT_INC(net, new);
 	}
 
@@ -772,7 +765,6 @@ void nf_conntrack_alter_reply(struct nf_conn *ct,
 			      const struct nf_conntrack_tuple *newreply)
 {
 	struct nf_conn_help *help = nfct_help(ct);
-	struct nf_conntrack_helper *helper;
 
 	/* Should be unconfirmed, so not in hash table yet */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
@@ -785,23 +777,7 @@ void nf_conntrack_alter_reply(struct nf_conn *ct,
 		return;
 
 	rcu_read_lock();
-	helper = __nf_ct_helper_find(newreply);
-	if (helper == NULL) {
-		if (help)
-			rcu_assign_pointer(help->helper, NULL);
-		goto out;
-	}
-
-	if (help == NULL) {
-		help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
-		if (help == NULL)
-			goto out;
-	} else {
-		memset(&help->help, 0, sizeof(help->help));
-	}
-
-	rcu_assign_pointer(help->helper, helper);
-out:
+	__nf_ct_try_assign_helper(ct, GFP_ATOMIC);
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alter_reply);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 9c06b9f..9e4b74b 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -44,7 +44,7 @@ static unsigned int helper_hash(const struct nf_conntrack_tuple *tuple)
 		(__force __u16)tuple->src.u.all) % nf_ct_helper_hsize;
 }
 
-struct nf_conntrack_helper *
+static struct nf_conntrack_helper *
 __nf_ct_helper_find(const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_helper *helper;
@@ -62,7 +62,6 @@ __nf_ct_helper_find(const struct nf_conntrack_tuple *tuple)
 	}
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(__nf_ct_helper_find);
 
 struct nf_conntrack_helper *
 __nf_conntrack_helper_find_byname(const char *name)
@@ -94,6 +93,35 @@ struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp)
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_ext_add);
 
+int __nf_ct_try_assign_helper(struct nf_conn *ct, gfp_t flags)
+{
+	int ret = 0;
+	struct nf_conntrack_helper *helper;
+	struct nf_conn_help *help = nfct_help(ct);
+
+	helper = __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	if (helper == NULL) {
+		if (help)
+			rcu_assign_pointer(help->helper, NULL);
+		goto out;
+	}
+
+	if (help == NULL) {
+		help = nf_ct_helper_ext_add(ct, flags);
+		if (help == NULL) {
+			ret = -ENOMEM;
+			goto out;
+		}
+	} else {
+		memset(&help->help, 0, sizeof(help->help));
+	}
+
+	rcu_assign_pointer(help->helper, helper);
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__nf_ct_try_assign_helper);
+
 static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 			 const struct nf_conntrack_helper *me)
 {
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 49a04fa..4f6486c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -917,8 +917,22 @@ ctnetlink_change_helper(struct nf_conn *ct, struct nlattr *cda[])
 	}
 
 	helper = __nf_conntrack_helper_find_byname(helpname);
-	if (helper == NULL)
+	if (helper == NULL) {
+#ifdef CONFIG_MODULES
+		spin_unlock_bh(&nf_conntrack_lock);
+
+		if (request_module("nfct-helper-%s", helpname) < 0) {
+			spin_lock_bh(&nf_conntrack_lock);
+			return -EOPNOTSUPP;
+		}
+
+		spin_lock_bh(&nf_conntrack_lock);
+		helper = __nf_conntrack_helper_find_byname(helpname);
+		if (helper)
+			return -EAGAIN;
+#endif
 		return -EOPNOTSUPP;
+	}
 
 	if (help) {
 		if (help->helper == helper)
@@ -1082,7 +1096,6 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 {
 	struct nf_conn *ct;
 	int err = -EINVAL;
-	struct nf_conn_help *help;
 	struct nf_conntrack_helper *helper;
 
 	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_KERNEL);
@@ -1097,16 +1110,55 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	ct->status |= IPS_CONFIRMED;
 
 	rcu_read_lock();
-	helper = __nf_ct_helper_find(rtuple);
-	if (helper) {
-		help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
-		if (help == NULL) {
+ 	if (cda[CTA_HELP]) {
+ 		char *helpname;
+
+ 		err = ctnetlink_parse_help(cda[CTA_HELP], &helpname);
+ 		if (err < 0) {
+			rcu_read_unlock();
+			goto err;
+		}
+
+		helper = __nf_conntrack_helper_find_byname(helpname);
+		if (helper == NULL) {
+			rcu_read_unlock();
+#ifdef CONFIG_MODULES
+			if (request_module("nfct-helper-%s", helpname) < 0) {
+				err = -EOPNOTSUPP;
+				goto err;
+			}
+
+			rcu_read_lock();
+			helper = __nf_conntrack_helper_find_byname(helpname);
+			if (helper) {
+				rcu_read_unlock();
+				err = -EAGAIN;
+				goto err;
+			}
+			rcu_read_unlock();
+#endif
+			err = -EOPNOTSUPP;
+			goto err;
+		} else {
+			struct nf_conn_help *help;
+
+			help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
+			if (help == NULL) {
+				rcu_read_unlock();
+				err = -ENOMEM;
+				goto err;
+			}
+
+			/* not in hash table yet so not strictly necessary */
+			rcu_assign_pointer(help->helper, helper);
+		}
+	} else {
+		/* try an implicit helper assignation */
+		err = __nf_ct_try_assign_helper(ct, GFP_ATOMIC);
+		if (err < 0) {
 			rcu_read_unlock();
-			err = -ENOMEM;
 			goto err;
 		}
-		/* not in hash table yet so not strictly necessary */
-		rcu_assign_pointer(help->helper, helper);
 	}
 
 	if (cda[CTA_STATUS]) {
