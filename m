From: pablo@netfilter.org
Subject: [PATCH 3/7] netfilter: xt_CT: merge common code of revision 0 and 1
Date: Tue, 19 Feb 2013 01:10:47 +0100
Message-ID: <1361232651-5626-4-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:43604 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757755Ab3BSALQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 19:11:16 -0500
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch merges the common code for revision 0 and 1.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |  145 +++++++++++++++++++------------------------------
 1 file changed, 56 insertions(+), 89 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index bde009e..d69f1c7 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -20,12 +20,8 @@
 #include <net/netfilter/nf_conntrack_timeout.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-static unsigned int xt_ct_target_v0(struct sk_buff *skb,
-				    const struct xt_action_param *par)
+static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 {
-	const struct xt_ct_target_info *info = par->targinfo;
-	struct nf_conn *ct = info->ct;
-
 	/* Previously seen (loopback)? Ignore. */
 	if (skb->nfct != NULL)
 		return XT_CONTINUE;
@@ -37,21 +33,22 @@ static unsigned int xt_ct_target_v0(struct sk_buff *skb,
 	return XT_CONTINUE;
 }
 
-static unsigned int xt_ct_target_v1(struct sk_buff *skb,
+static unsigned int xt_ct_target_v0(struct sk_buff *skb,
 				    const struct xt_action_param *par)
 {
-	const struct xt_ct_target_info_v1 *info = par->targinfo;
+	const struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
 
-	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
-		return XT_CONTINUE;
+	return xt_ct_target(skb, ct);
+}
 
-	atomic_inc(&ct->ct_general.use);
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+static unsigned int xt_ct_target_v1(struct sk_buff *skb,
+				    const struct xt_action_param *par)
+{
+	const struct xt_ct_target_info_v1 *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
 
-	return XT_CONTINUE;
+	return xt_ct_target(skb, ct);
 }
 
 static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
@@ -104,67 +101,6 @@ xt_ct_set_helper(struct nf_conn *ct, const char *helper_name,
 	return 0;
 }
 
-static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
-{
-	struct xt_ct_target_info *info = par->targinfo;
-	struct nf_conntrack_tuple t;
-	struct nf_conn *ct;
-	int ret = -EOPNOTSUPP;
-
-	if (info->flags & ~XT_CT_NOTRACK)
-		return -EINVAL;
-
-	if (info->flags & XT_CT_NOTRACK) {
-		ct = nf_ct_untracked_get();
-		atomic_inc(&ct->ct_general.use);
-		goto out;
-	}
-
-#ifndef CONFIG_NF_CONNTRACK_ZONES
-	if (info->zone)
-		goto err1;
-#endif
-
-	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0)
-		goto err1;
-
-	memset(&t, 0, sizeof(t));
-	ct = nf_conntrack_alloc(par->net, info->zone, &t, &t, GFP_KERNEL);
-	ret = PTR_ERR(ct);
-	if (IS_ERR(ct))
-		goto err2;
-
-	ret = 0;
-	if ((info->ct_events || info->exp_events) &&
-	    !nf_ct_ecache_ext_add(ct, info->ct_events, info->exp_events,
-				  GFP_KERNEL))
-		goto err3;
-
-	if (info->helper[0]) {
-		ret = xt_ct_set_helper(ct, info->helper, par);
-		if (ret < 0)
-			goto err3;
-	}
-
-	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
-	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
-
-	/* Overload tuple linked list to put us in template list. */
-	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-				 &par->net->ct.tmpl);
-out:
-	info->ct = ct;
-	return 0;
-
-err3:
-	nf_conntrack_free(ct);
-err2:
-	nf_ct_l3proto_module_put(par->family);
-err1:
-	return ret;
-}
-
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 static void __xt_ct_tg_timeout_put(struct ctnl_timeout *timeout)
 {
@@ -242,9 +178,9 @@ out:
 #endif
 }
 
-static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
+static int xt_ct_tg_check(const struct xt_tgchk_param *par,
+			  struct xt_ct_target_info_v1 *info)
 {
-	struct xt_ct_target_info_v1 *info = par->targinfo;
 	struct nf_conntrack_tuple t;
 	struct nf_conn *ct;
 	int ret = -EOPNOTSUPP;
@@ -309,20 +245,31 @@ err1:
 	return ret;
 }
 
-static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
+static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
-	struct nf_conn *ct = info->ct;
-	struct nf_conn_help *help;
+	struct xt_ct_target_info_v1 info_v1 = {
+		.flags 		= info->flags,
+		.zone		= info->zone,
+		.ct_events	= info->ct_events,
+		.exp_events	= info->exp_events,
+	};
+	int ret;
 
-	if (!nf_ct_is_untracked(ct)) {
-		help = nfct_help(ct);
-		if (help)
-			module_put(help->helper->me);
+	memcpy(info_v1.helper, info->helper, sizeof(info->helper));
 
-		nf_ct_l3proto_module_put(par->family);
-	}
-	nf_ct_put(info->ct);
+	ret = xt_ct_tg_check(par, &info_v1);
+	if (ret < 0)
+		return ret;
+
+	info->ct = info_v1.ct;
+
+	return ret;
+}
+
+static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
+{
+	return xt_ct_tg_check(par, par->targinfo);
 }
 
 static void xt_ct_destroy_timeout(struct nf_conn *ct)
@@ -343,9 +290,9 @@ static void xt_ct_destroy_timeout(struct nf_conn *ct)
 #endif
 }
 
-static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
+static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
+			     struct xt_ct_target_info_v1 *info)
 {
-	struct xt_ct_target_info_v1 *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
 	struct nf_conn_help *help;
 
@@ -361,6 +308,26 @@ static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
 	nf_ct_put(info->ct);
 }
 
+static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
+{
+	struct xt_ct_target_info *info = par->targinfo;
+	struct xt_ct_target_info_v1 info_v1 = {
+		.flags 		= info->flags,
+		.zone		= info->zone,
+		.ct_events	= info->ct_events,
+		.exp_events	= info->exp_events,
+		.ct		= info->ct,
+	};
+	memcpy(info_v1.helper, info->helper, sizeof(info->helper));
+
+	xt_ct_tg_destroy(par, &info_v1);
+}
+
+static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
+{
+	xt_ct_tg_destroy(par, par->targinfo);
+}
+
 static struct xt_target xt_ct_tg_reg[] __read_mostly = {
 	{
 		.name		= "CT",
-- 
1.7.10.4
