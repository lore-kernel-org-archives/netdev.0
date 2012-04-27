From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 02/17] netfilter: add namespace support for l4proto
Date: Fri, 27 Apr 2012 17:37:49 +0800
Message-ID: <1335519484-6089-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36137 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759969Ab2D0Jhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:37:48 -0400
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitus.com>

-nf_ct_(un)register_sysctl are changed to support net namespace,
 use (un)register_net_sysctl_table replaces (un)register_sysctl_paths.
 and in nf_ct_unregister_sysctl,kfree table only when users is 0.

-Add the struct net as param of nf_conntrack_l4proto_(un)register.
 register or unregister the l4proto only when the net is init_net.

-nf_conntrack_l4proto_register call init_net to initial the pernet
 data of l4proto.

-nf_ct_l4proto_net is used to get the pernet data of l4proto.

Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h |   13 +-
 net/netfilter/nf_conntrack_proto.c           |  240 +++++++++++++++-----------
 2 files changed, 152 insertions(+), 101 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index ad8ff89..e4ea46f 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -12,7 +12,7 @@
 #include <linux/netlink.h>
 #include <net/netlink.h>
 #include <net/netfilter/nf_conntrack.h>
-
+#include <net/netns/generic.h>
 struct seq_file;
 
 struct nf_conntrack_l4proto {
@@ -129,8 +129,15 @@ nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
 extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
 
 /* Protocol registration. */
-extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
-extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
+extern int nf_conntrack_l4proto_register(struct net *net,
+					 struct nf_conntrack_l4proto *proto);
+extern void nf_conntrack_l4proto_unregister(struct net *net,
+					    struct nf_conntrack_l4proto *proto);
+
+extern int nf_ct_l4proto_register_sysctl(struct net *net,
+					 struct nf_conntrack_l4proto *l4proto);
+extern void nf_ct_l4proto_unregister_sysctl(struct net *net,
+					    struct nf_conntrack_l4proto *l4proto);
 
 /* Generic netlink helpers */
 extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 8b631b0..85d71e0 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -35,30 +35,39 @@ EXPORT_SYMBOL_GPL(nf_ct_l3protos);
 static DEFINE_MUTEX(nf_ct_proto_mutex);
 
 #ifdef CONFIG_SYSCTL
-static int
-nf_ct_register_sysctl(struct ctl_table_header **header, const char *path,
-		      struct ctl_table *table, unsigned int *users)
+int
+nf_ct_register_sysctl(struct net *net,
+		      struct ctl_table_header **header,
+		      const char *path,
+		      struct ctl_table *table,
+		      unsigned int *users)
 {
 	if (*header == NULL) {
-		*header = register_net_sysctl(&init_net, path, table);
+		*header = register_net_sysctl(net, path, table);
 		if (*header == NULL)
 			return -ENOMEM;
 	}
 	if (users != NULL)
 		(*users)++;
+
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nf_ct_register_sysctl);
 
-static void
+void
 nf_ct_unregister_sysctl(struct ctl_table_header **header,
-			struct ctl_table *table, unsigned int *users)
+			struct ctl_table **table,
+			unsigned int *users)
 {
 	if (users != NULL && --*users > 0)
 		return;
 
 	unregister_net_sysctl_table(*header);
+	kfree(*table);
 	*header = NULL;
+	*table = NULL;
 }
+EXPORT_SYMBOL_GPL(nf_ct_unregister_sysctl);
 #endif
 
 struct nf_conntrack_l4proto *
@@ -243,137 +252,172 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
-static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4proto *l4proto)
+static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
+					      struct nf_conntrack_l4proto *l4proto)
 {
-	int err = 0;
+	if (l4proto->net_id)
+		return net_generic(net, *l4proto->net_id);
+	else
+		return NULL;
+}
 
+int nf_ct_l4proto_register_sysctl(struct net *net,
+				  struct nf_conntrack_l4proto *l4proto)
+{
+	int err = 0;
+	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
+	if (pn == NULL)
+		return 0;
 #ifdef CONFIG_SYSCTL
-	if (l4proto->ctl_table != NULL) {
-		err = nf_ct_register_sysctl(l4proto->ctl_table_header,
+	if (pn->ctl_table != NULL) {
+		err = nf_ct_register_sysctl(net,
+					    &pn->ctl_table_header,
 					    "net/netfilter",
-					    l4proto->ctl_table,
-					    l4proto->ctl_table_users);
-		if (err < 0)
+					    pn->ctl_table,
+					    &pn->users);
+		if (err < 0) {
+			kfree(pn->ctl_table);
+			pn->ctl_table = NULL;
 			goto out;
+		}
 	}
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (l4proto->ctl_compat_table != NULL) {
-		err = nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
+	if (l4proto->compat && pn->ctl_compat_table != NULL) {
+		err = nf_ct_register_sysctl(net,
+					    &pn->ctl_compat_header,
 					    "net/ipv4/netfilter",
-					    l4proto->ctl_compat_table, NULL);
+					    pn->ctl_compat_table,
+					    NULL);
 		if (err == 0)
 			goto out;
-		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
-					l4proto->ctl_table,
-					l4proto->ctl_table_users);
+
+		kfree(pn->ctl_compat_table);
+		pn->ctl_compat_table = NULL;
+		nf_ct_unregister_sysctl(&pn->ctl_table_header,
+					&pn->ctl_table,
+					&pn->users);
 	}
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 out:
 #endif /* CONFIG_SYSCTL */
 	return err;
 }
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_register_sysctl);
 
-static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l4proto *l4proto)
+void nf_ct_l4proto_unregister_sysctl(struct net *net,
+				     struct nf_conntrack_l4proto *l4proto)
 {
+	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
+	if (pn == NULL)
+		return;
 #ifdef CONFIG_SYSCTL
-	if (l4proto->ctl_table_header != NULL &&
-	    *l4proto->ctl_table_header != NULL)
-		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
-					l4proto->ctl_table,
-					l4proto->ctl_table_users);
+	if (pn->ctl_table_header != NULL)
+		nf_ct_unregister_sysctl(&pn->ctl_table_header,
+					&pn->ctl_table,
+					&pn->users);
+
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (l4proto->ctl_compat_table_header != NULL)
-		nf_ct_unregister_sysctl(&l4proto->ctl_compat_table_header,
-					l4proto->ctl_compat_table, NULL);
+	if (l4proto->compat && pn->ctl_compat_header != NULL)
+		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
+					&pn->ctl_compat_table,
+					NULL);
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
+#else
+	pn->users--;
 #endif /* CONFIG_SYSCTL */
 }
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_sysctl);
 
 /* FIXME: Allow NULL functions and sub in pointers to generic for
    them. --RR */
-int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
+int nf_conntrack_l4proto_register(struct net *net,
+				  struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 
-	if (l4proto->l3proto >= PF_MAX)
-		return -EBUSY;
-
-	if ((l4proto->to_nlattr && !l4proto->nlattr_size)
-		|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
-		return -EINVAL;
-
-	mutex_lock(&nf_ct_proto_mutex);
-	if (!nf_ct_protos[l4proto->l3proto]) {
-		/* l3proto may be loaded latter. */
-		struct nf_conntrack_l4proto __rcu **proto_array;
-		int i;
-
-		proto_array = kmalloc(MAX_NF_CT_PROTO *
-				      sizeof(struct nf_conntrack_l4proto *),
-				      GFP_KERNEL);
-		if (proto_array == NULL) {
-			ret = -ENOMEM;
+	if (net == &init_net) {
+		if (l4proto->l3proto >= PF_MAX)
+			return -EBUSY;
+
+		if ((l4proto->to_nlattr && !l4proto->nlattr_size)
+			|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
+			return -EINVAL;
+
+		mutex_lock(&nf_ct_proto_mutex);
+		if (!nf_ct_protos[l4proto->l3proto]) {
+			/* l3proto may be loaded latter. */
+			struct nf_conntrack_l4proto __rcu **proto_array;
+			int i;
+
+			proto_array = kmalloc(MAX_NF_CT_PROTO *
+					      sizeof(struct nf_conntrack_l4proto *),
+					      GFP_KERNEL);
+			if (proto_array == NULL) {
+				ret = -ENOMEM;
+				goto out_unlock;
+			}
+
+			for (i = 0; i < MAX_NF_CT_PROTO; i++)
+				RCU_INIT_POINTER(proto_array[i], &nf_conntrack_l4proto_generic);
+
+			/* Before making proto_array visible to lockless readers,
+			 * we must make sure its content is committed to memory.
+			 */
+			smp_wmb();
+
+			nf_ct_protos[l4proto->l3proto] = proto_array;
+		} else if (rcu_dereference_protected(
+				nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+				lockdep_is_held(&nf_ct_proto_mutex)
+				) != &nf_conntrack_l4proto_generic) {
+			ret = -EBUSY;
 			goto out_unlock;
 		}
-
-		for (i = 0; i < MAX_NF_CT_PROTO; i++)
-			RCU_INIT_POINTER(proto_array[i], &nf_conntrack_l4proto_generic);
-
-		/* Before making proto_array visible to lockless readers,
-		 * we must make sure its content is committed to memory.
-		 */
-		smp_wmb();
-
-		nf_ct_protos[l4proto->l3proto] = proto_array;
-	} else if (rcu_dereference_protected(
-			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
-			lockdep_is_held(&nf_ct_proto_mutex)
-			) != &nf_conntrack_l4proto_generic) {
-		ret = -EBUSY;
-		goto out_unlock;
-	}
-
-	ret = nf_ct_l4proto_register_sysctl(l4proto);
-	if (ret < 0)
-		goto out_unlock;
-
-	l4proto->nla_size = 0;
-	if (l4proto->nlattr_size)
-		l4proto->nla_size += l4proto->nlattr_size();
-	if (l4proto->nlattr_tuple_size)
-		l4proto->nla_size += 3 * l4proto->nlattr_tuple_size();
-
-	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
-			   l4proto);
-
+
+		l4proto->nla_size = 0;
+		if (l4proto->nlattr_size)
+			l4proto->nla_size += l4proto->nlattr_size();
+		if (l4proto->nlattr_tuple_size)
+			l4proto->nla_size += 3 * l4proto->nlattr_tuple_size();
+
+		rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+				   l4proto);
 out_unlock:
-	mutex_unlock(&nf_ct_proto_mutex);
-	return ret;
+		mutex_unlock(&nf_ct_proto_mutex);
+		if (ret < 0)
+			return ret;
+	}
+	if (l4proto->init_net) {
+		ret = l4proto->init_net(net, l4proto->compat);
+		if (ret < 0)
+			return ret;
+	}
+	return nf_ct_l4proto_register_sysctl(net, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
-void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
+void nf_conntrack_l4proto_unregister(struct net *net,
+				     struct nf_conntrack_l4proto *l4proto)
 {
-	struct net *net;
-
-	BUG_ON(l4proto->l3proto >= PF_MAX);
-
-	mutex_lock(&nf_ct_proto_mutex);
-	BUG_ON(rcu_dereference_protected(
-			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
-			lockdep_is_held(&nf_ct_proto_mutex)
-			) != l4proto);
-	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
-			   &nf_conntrack_l4proto_generic);
-	nf_ct_l4proto_unregister_sysctl(l4proto);
-	mutex_unlock(&nf_ct_proto_mutex);
-
-	synchronize_rcu();
+	if (net == &init_net) {
+		BUG_ON(l4proto->l3proto >= PF_MAX);
+		mutex_lock(&nf_ct_proto_mutex);
+
+		BUG_ON(rcu_dereference_protected(
+				nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+				lockdep_is_held(&nf_ct_proto_mutex)
+				) != l4proto);
+		rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
+				   &nf_conntrack_l4proto_generic);
+		mutex_unlock(&nf_ct_proto_mutex);
+
+		synchronize_rcu();
+	}
+	nf_ct_l4proto_unregister_sysctl(net, l4proto);
 
 	/* Remove all contrack entries for this protocol */
 	rtnl_lock();
-	for_each_net(net)
-		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
-- 
1.7.7.6
