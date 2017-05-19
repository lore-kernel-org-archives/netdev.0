From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: introduce nf_conntrack_helper_put helper function
Date: Fri, 19 May 2017 10:33:45 +0200
Message-ID: <1495182833-2272-5-git-send-email-pablo@netfilter.org>
References: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43992 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753687AbdESIeU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:34:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 852C41DA0AC
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 72577FF2F9
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0A818FF137
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:10 +0200 (CEST)
In-Reply-To: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

And convert module_put invocation to nf_conntrack_helper_put, this is
prepared for the followup patch, which will add a refcnt for cthelper,
so we can reject the deleting request when cthelper is in use.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_helper.h | 2 ++
 net/netfilter/nf_conntrack_helper.c         | 6 ++++++
 net/netfilter/nft_ct.c                      | 4 ++--
 net/netfilter/xt_CT.c                       | 6 +++---
 net/openvswitch/conntrack.c                 | 4 ++--
 5 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index e04fa7691e5d..c1c12411103a 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -79,6 +79,8 @@ struct nf_conntrack_helper *__nf_conntrack_helper_find(const char *name,
 struct nf_conntrack_helper *nf_conntrack_helper_try_module_get(const char *name,
 							       u16 l3num,
 							       u8 protonum);
+void nf_conntrack_helper_put(struct nf_conntrack_helper *helper);
+
 void nf_ct_helper_init(struct nf_conntrack_helper *helper,
 		       u16 l3num, u16 protonum, const char *name,
 		       u16 default_port, u16 spec_port, u32 id,
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 3a60efa7799b..e17006b6e434 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -181,6 +181,12 @@ nf_conntrack_helper_try_module_get(const char *name, u16 l3num, u8 protonum)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_try_module_get);
 
+void nf_conntrack_helper_put(struct nf_conntrack_helper *helper)
+{
+	module_put(helper->me);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_helper_put);
+
 struct nf_conn_help *
 nf_ct_helper_ext_add(struct nf_conn *ct,
 		     struct nf_conntrack_helper *helper, gfp_t gfp)
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index a34ceb38fc55..1678e9e75e8e 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -826,9 +826,9 @@ static void nft_ct_helper_obj_destroy(struct nft_object *obj)
 	struct nft_ct_helper_obj *priv = nft_obj_data(obj);
 
 	if (priv->helper4)
-		module_put(priv->helper4->me);
+		nf_conntrack_helper_put(priv->helper4);
 	if (priv->helper6)
-		module_put(priv->helper6->me);
+		nf_conntrack_helper_put(priv->helper6);
 }
 
 static void nft_ct_helper_obj_eval(struct nft_object *obj,
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index bb7ad82dcd56..623ef37de886 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -96,7 +96,7 @@ xt_ct_set_helper(struct nf_conn *ct, const char *helper_name,
 
 	help = nf_ct_helper_ext_add(ct, helper, GFP_KERNEL);
 	if (help == NULL) {
-		module_put(helper->me);
+		nf_conntrack_helper_put(helper);
 		return -ENOMEM;
 	}
 
@@ -263,7 +263,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 err4:
 	help = nfct_help(ct);
 	if (help)
-		module_put(help->helper->me);
+		nf_conntrack_helper_put(help->helper);
 err3:
 	nf_ct_tmpl_free(ct);
 err2:
@@ -346,7 +346,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par,
 	if (ct) {
 		help = nfct_help(ct);
 		if (help)
-			module_put(help->helper->me);
+			nf_conntrack_helper_put(help->helper);
 
 		nf_ct_netns_put(par->net, par->family);
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index bf602e33c40a..08679ebb3068 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1123,7 +1123,7 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 
 	help = nf_ct_helper_ext_add(info->ct, helper, GFP_KERNEL);
 	if (!help) {
-		module_put(helper->me);
+		nf_conntrack_helper_put(helper);
 		return -ENOMEM;
 	}
 
@@ -1584,7 +1584,7 @@ void ovs_ct_free_action(const struct nlattr *a)
 static void __ovs_ct_free_action(struct ovs_conntrack_info *ct_info)
 {
 	if (ct_info->helper)
-		module_put(ct_info->helper->me);
+		nf_conntrack_helper_put(ct_info->helper);
 	if (ct_info->ct)
 		nf_ct_tmpl_free(ct_info->ct);
 }
-- 
2.1.4
