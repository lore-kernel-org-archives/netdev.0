From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next v2 03/12] netfilter: add nf_ct_kfree_compat_sysctl_table to make codes clear
Date: Sat, 16 Jun 2012 11:41:14 +0800
Message-ID: <1339818083-31356-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:25622 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759084Ab2FPDlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 23:41:05 -0400
In-Reply-To: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add function nf_ct_kfree_compat_sysctl_table to kfree l4proto's
compat sysctl table and set the sysctl table point to NULL.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    2 ++
 net/netfilter/nf_conntrack_proto.c           |   12 ++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 5dd60f2..11fcf27 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -124,6 +124,8 @@ extern int nf_conntrack_l4proto_register(struct net *net,
 extern void nf_conntrack_l4proto_unregister(struct net *net,
 					    struct nf_conntrack_l4proto *proto);
 
+extern void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn);
+
 /* Generic netlink helpers */
 extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
 				      const struct nf_conntrack_tuple *tuple);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 5ea2d71..1033ee6 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -327,6 +327,15 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 	return NULL;
 }
 
+void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	kfree(pn->ctl_compat_table);
+	pn->ctl_compat_table = NULL;
+#endif
+}
+EXPORT_SYMBOL_GPL(nf_ct_kfree_compat_sysctl_table);
+
 static
 int nf_ct_l4proto_register_sysctl(struct net *net,
 				  struct nf_conntrack_l4proto *l4proto)
@@ -361,8 +370,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 		if (err == 0)
 			goto out;
 
-		kfree(pn->ctl_compat_table);
-		pn->ctl_compat_table = NULL;
+		nf_ct_kfree_compat_sysctl_table(pn);
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
 					&pn->users);
-- 
1.7.7.6
