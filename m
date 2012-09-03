From: pablo@netfilter.org
Subject: [PATCH 20/25] netfilter: xt_CT: refactorize xt_ct_tg_check
Date: Tue,  4 Sep 2012 01:54:07 +0200
Message-ID: <1346716452-3080-21-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37174 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756605Ab2ICX4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:05 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds xt_ct_set_helper and xt_ct_set_timeout to reduce
the size of xt_ct_tg_check.

This aims to improve code mantainability by splitting xt_ct_tg_check
in smaller chunks.

Suggested by Eric Dumazet.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |  262 ++++++++++++++++++++++++-------------------------
 1 file changed, 126 insertions(+), 136 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 1160185..16c7125 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -72,14 +72,44 @@ static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
 		return 0;
 }
 
+static int
+xt_ct_set_helper(struct nf_conn *ct, const char *helper_name,
+		 const struct xt_tgchk_param *par)
+{
+	struct nf_conntrack_helper *helper;
+	struct nf_conn_help *help;
+	u8 proto;
+
+	proto = xt_ct_find_proto(par);
+	if (!proto) {
+		pr_info("You must specify a L4 protocol, and not use "
+			"inversions on it.\n");
+		return -ENOENT;
+	}
+
+	helper = nf_conntrack_helper_try_module_get(helper_name, par->family,
+						    proto);
+	if (helper == NULL) {
+		pr_info("No such helper \"%s\"\n", helper_name);
+		return -ENOENT;
+	}
+
+	help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
+	if (help == NULL) {
+		module_put(helper->me);
+		return -ENOMEM;
+	}
+
+	help->helper = helper;
+	return 0;
+}
+
 static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conntrack_tuple t;
-	struct nf_conn_help *help;
 	struct nf_conn *ct;
-	int ret = 0;
-	u8 proto;
+	int ret;
 
 	if (info->flags & ~XT_CT_NOTRACK)
 		return -EINVAL;
@@ -112,31 +142,9 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 		goto err3;
 
 	if (info->helper[0]) {
-		struct nf_conntrack_helper *helper;
-
-		ret = -ENOENT;
-		proto = xt_ct_find_proto(par);
-		if (!proto) {
-			pr_info("You must specify a L4 protocol, "
-				"and not use inversions on it.\n");
-			goto err3;
-		}
-
-		ret = -ENOENT;
-		helper = nf_conntrack_helper_try_module_get(info->helper,
-							    par->family,
-							    proto);
-		if (helper == NULL) {
-			pr_info("No such helper \"%s\"\n", info->helper);
-			goto err3;
-		}
-
-		ret = -ENOMEM;
-		help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
-		if (help == NULL)
+		ret = xt_ct_set_helper(ct, info->helper, par);
+		if (ret < 0)
 			goto err3;
-
-		help->helper = helper;
 	}
 
 	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
@@ -164,17 +172,77 @@ static void __xt_ct_tg_timeout_put(struct ctnl_timeout *timeout)
 }
 #endif
 
+static int
+xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
+		  const char *timeout_name)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
+	struct ctnl_timeout *timeout;
+	struct nf_conn_timeout *timeout_ext;
+	const struct ipt_entry *e = par->entryinfo;
+	struct nf_conntrack_l4proto *l4proto;
+	int ret = 0;
+
+	rcu_read_lock();
+	timeout_find_get = rcu_dereference(nf_ct_timeout_find_get_hook);
+	if (timeout_find_get == NULL) {
+		ret = -ENOENT;
+		pr_info("Timeout policy base is empty\n");
+		goto out;
+	}
+
+	if (e->ip.invflags & IPT_INV_PROTO) {
+		ret = -EINVAL;
+		pr_info("You cannot use inversion on L4 protocol\n");
+		goto out;
+	}
+
+	timeout = timeout_find_get(timeout_name);
+	if (timeout == NULL) {
+		ret = -ENOENT;
+		pr_info("No such timeout policy \"%s\"\n", timeout_name);
+		goto out;
+	}
+
+	if (timeout->l3num != par->family) {
+		ret = -EINVAL;
+		pr_info("Timeout policy `%s' can only be used by L3 protocol "
+			"number %d\n", timeout_name, timeout->l3num);
+		goto err_put_timeout;
+	}
+	/* Make sure the timeout policy matches any existing protocol tracker,
+	 * otherwise default to generic.
+	 */
+	l4proto = __nf_ct_l4proto_find(par->family, e->ip.proto);
+	if (timeout->l4proto->l4proto != l4proto->l4proto) {
+		ret = -EINVAL;
+		pr_info("Timeout policy `%s' can only be used by L4 protocol "
+			"number %d\n",
+			timeout_name, timeout->l4proto->l4proto);
+		goto err_put_timeout;
+	}
+	timeout_ext = nf_ct_timeout_ext_add(ct, timeout, GFP_ATOMIC);
+	if (timeout_ext == NULL)
+		ret = -ENOMEM;
+
+err_put_timeout:
+	__xt_ct_tg_timeout_put(timeout);
+out:
+	rcu_read_unlock();
+	return ret;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
 static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info_v1 *info = par->targinfo;
 	struct nf_conntrack_tuple t;
-	struct nf_conn_help *help;
 	struct nf_conn *ct;
-	int ret = 0;
-	u8 proto;
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-	struct ctnl_timeout *timeout;
-#endif
+	int ret;
+
 	if (info->flags & ~XT_CT_NOTRACK)
 		return -EINVAL;
 
@@ -206,93 +274,16 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 		goto err3;
 
 	if (info->helper[0]) {
-		struct nf_conntrack_helper *helper;
-
-		ret = -ENOENT;
-		proto = xt_ct_find_proto(par);
-		if (!proto) {
-			pr_info("You must specify a L4 protocol, "
-				"and not use inversions on it.\n");
-			goto err3;
-		}
-
-		ret = -ENOENT;
-		helper = nf_conntrack_helper_try_module_get(info->helper,
-							    par->family,
-							    proto);
-		if (helper == NULL) {
-			pr_info("No such helper \"%s\"\n", info->helper);
-			goto err3;
-		}
-
-		ret = -ENOMEM;
-		help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
-		if (help == NULL)
+		ret = xt_ct_set_helper(ct, info->helper, par);
+		if (ret < 0)
 			goto err3;
-
-		help->helper = helper;
 	}
 
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	if (info->timeout[0]) {
-		typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
-		struct nf_conn_timeout *timeout_ext;
-
-		rcu_read_lock();
-		timeout_find_get =
-			rcu_dereference(nf_ct_timeout_find_get_hook);
-
-		if (timeout_find_get) {
-			const struct ipt_entry *e = par->entryinfo;
-			struct nf_conntrack_l4proto *l4proto;
-
-			if (e->ip.invflags & IPT_INV_PROTO) {
-				ret = -EINVAL;
-				pr_info("You cannot use inversion on "
-					 "L4 protocol\n");
-				goto err4;
-			}
-			timeout = timeout_find_get(info->timeout);
-			if (timeout == NULL) {
-				ret = -ENOENT;
-				pr_info("No such timeout policy \"%s\"\n",
-					info->timeout);
-				goto err4;
-			}
-			if (timeout->l3num != par->family) {
-				ret = -EINVAL;
-				pr_info("Timeout policy `%s' can only be "
-					"used by L3 protocol number %d\n",
-					info->timeout, timeout->l3num);
-				goto err5;
-			}
-			/* Make sure the timeout policy matches any existing
-			 * protocol tracker, otherwise default to generic.
-			 */
-			l4proto = __nf_ct_l4proto_find(par->family,
-						       e->ip.proto);
-			if (timeout->l4proto->l4proto != l4proto->l4proto) {
-				ret = -EINVAL;
-				pr_info("Timeout policy `%s' can only be "
-					"used by L4 protocol number %d\n",
-					info->timeout,
-					timeout->l4proto->l4proto);
-				goto err5;
-			}
-			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
-							    GFP_ATOMIC);
-			if (timeout_ext == NULL) {
-				ret = -ENOMEM;
-				goto err5;
-			}
-		} else {
-			ret = -ENOENT;
-			pr_info("Timeout policy base is empty\n");
-			goto err4;
-		}
-		rcu_read_unlock();
+		ret = xt_ct_set_timeout(ct, par, info->timeout);
+		if (ret < 0)
+			goto err3;
 	}
-#endif
 
 	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
 	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
@@ -300,12 +291,6 @@ out:
 	info->ct = ct;
 	return 0;
 
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-err5:
-	__xt_ct_tg_timeout_put(timeout);
-err4:
-	rcu_read_unlock();
-#endif
 err3:
 	nf_conntrack_free(ct);
 err2:
@@ -330,15 +315,30 @@ static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
 	nf_ct_put(info->ct);
 }
 
-static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
+static void xt_ct_destroy_timeout(struct nf_conn *ct)
 {
-	struct xt_ct_target_info_v1 *info = par->targinfo;
-	struct nf_conn *ct = info->ct;
-	struct nf_conn_help *help;
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	struct nf_conn_timeout *timeout_ext;
 	typeof(nf_ct_timeout_put_hook) timeout_put;
+
+	rcu_read_lock();
+	timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
+
+	if (timeout_put) {
+		timeout_ext = nf_ct_timeout_find(ct);
+		if (timeout_ext)
+			timeout_put(timeout_ext->timeout);
+	}
+	rcu_read_unlock();
 #endif
+}
+
+static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
+{
+	struct xt_ct_target_info_v1 *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
+	struct nf_conn_help *help;
+
 	if (!nf_ct_is_untracked(ct)) {
 		help = nfct_help(ct);
 		if (help)
@@ -346,17 +346,7 @@ static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
 
 		nf_ct_l3proto_module_put(par->family);
 
-#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-		rcu_read_lock();
-		timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
-
-		if (timeout_put) {
-			timeout_ext = nf_ct_timeout_find(ct);
-			if (timeout_ext)
-				timeout_put(timeout_ext->timeout);
-		}
-		rcu_read_unlock();
-#endif
+		xt_ct_destroy_timeout(ct);
 	}
 	nf_ct_put(info->ct);
 }
-- 
1.7.10.4
