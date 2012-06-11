From: pablo@netfilter.org
Subject: [PATCH 04/25] netfilter: nf_conntrack: prepare namespace support for l4 protocol trackers
Date: Mon, 11 Jun 2012 16:43:40 +0200
Message-ID: <1339425841-24171-5-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32812 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab2FKOou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:44:50 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitus.com>

This patch prepares the namespace support for layer 4 protocol trackers.
Basically, this modifies the following interfaces:

* nf_ct_[un]register_sysctl
* nf_conntrack_l4proto_[un]register

to include the namespace parameter. We still use init_net in this patch
to prepare the ground for follow-up patches for each layer 4 protocol
tracker.

We add a new net_id field to struct nf_conntrack_l4proto that is used
to store the pernet_operations id for each layer 4 protocol tracker.

Note that AF_INET6's protocols do not need to do sysctl compat. Thus,
we only register compat sysctl when l4proto.l3proto != AF_INET6.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |   11 +-
 include/net/netns/conntrack.h                  |   12 ++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   18 +--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   18 +--
 net/netfilter/nf_conntrack_proto.c             |  143 +++++++++++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c        |   10 +-
 net/netfilter/nf_conntrack_proto_gre.c         |    6 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |   10 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |   10 +-
 9 files changed, 159 insertions(+), 79 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 3b572bb..d621c91 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -12,6 +12,7 @@
 #include <linux/netlink.h>
 #include <net/netlink.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netns/generic.h>
 
 struct seq_file;
 
@@ -103,6 +104,10 @@ struct nf_conntrack_l4proto {
 	struct ctl_table	*ctl_compat_table;
 #endif
 #endif
+	int	*net_id;
+	/* Init l4proto pernet data */
+	int (*init_net)(struct net *net);
+
 	/* Protocol name */
 	const char *name;
 
@@ -123,8 +128,10 @@ nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
 extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
 
 /* Protocol registration. */
-extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
-extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
+extern int nf_conntrack_l4proto_register(struct net *net,
+					 struct nf_conntrack_l4proto *proto);
+extern void nf_conntrack_l4proto_unregister(struct net *net,
+					    struct nf_conntrack_l4proto *proto);
 
 /* Generic netlink helpers */
 extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index a053a19..1f53038 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -8,6 +8,18 @@
 struct ctl_table_header;
 struct nf_conntrack_ecache;
 
+struct nf_proto_net {
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *ctl_table_header;
+	struct ctl_table        *ctl_table;
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table_header *ctl_compat_header;
+	struct ctl_table        *ctl_compat_table;
+#endif
+#endif
+	unsigned int		users;
+};
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 91747d4..46ec515 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -391,19 +391,19 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		return ret;
 	}
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
 		goto cleanup_sockopt;
 	}
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register udp.\n");
 		goto cleanup_tcp;
 	}
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
 		goto cleanup_udp;
@@ -434,11 +434,11 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
  cleanup_ipv4:
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
  cleanup_icmp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
  cleanup_udp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
  cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
  cleanup_sockopt:
 	nf_unregister_sockopt(&so_getorigdst);
 	return ret;
@@ -452,9 +452,9 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 #endif
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
 	nf_unregister_sockopt(&so_getorigdst);
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 3224ef9..51ad9f1 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -340,19 +340,19 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	need_conntrack();
 	nf_defrag_ipv6_enable();
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
 		return ret;
 	}
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register udp.\n");
 		goto cleanup_tcp;
 	}
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
 		goto cleanup_udp;
@@ -376,11 +376,11 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
  cleanup_ipv6:
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
  cleanup_icmpv6:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
  cleanup_udp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
  cleanup_tcp:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
 	return ret;
 }
 
@@ -389,9 +389,9 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 	synchronize_net();
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
 }
 
 module_init(nf_conntrack_l3proto_ipv6_init);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 8b631b0..7ee31ac 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -36,28 +36,35 @@ static DEFINE_MUTEX(nf_ct_proto_mutex);
 
 #ifdef CONFIG_SYSCTL
 static int
-nf_ct_register_sysctl(struct ctl_table_header **header, const char *path,
-		      struct ctl_table *table, unsigned int *users)
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
 
 static void
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
 #endif
 
@@ -167,7 +174,8 @@ static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3proto *l3proto)
 
 #ifdef CONFIG_SYSCTL
 	if (l3proto->ctl_table != NULL) {
-		err = nf_ct_register_sysctl(&l3proto->ctl_table_header,
+		err = nf_ct_register_sysctl(&init_net,
+					    &l3proto->ctl_table_header,
 					    l3proto->ctl_table_path,
 					    l3proto->ctl_table, NULL);
 	}
@@ -180,7 +188,7 @@ static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3proto *l3proto
 #ifdef CONFIG_SYSCTL
 	if (l3proto->ctl_table_header != NULL)
 		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
-					l3proto->ctl_table, NULL);
+					&l3proto->ctl_table, NULL);
 #endif
 }
 
@@ -243,29 +251,54 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
-static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4proto *l4proto)
+static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
+					      struct nf_conntrack_l4proto *l4proto)
+{
+	if (l4proto->net_id)
+		return net_generic(net, *l4proto->net_id);
+	else
+		return NULL;
+}
+
+static
+int nf_ct_l4proto_register_sysctl(struct net *net,
+				  struct nf_conntrack_l4proto *l4proto)
 {
 	int err = 0;
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
+			if (!pn->users) {
+				kfree(pn->ctl_table);
+				pn->ctl_table = NULL;
+			}
 			goto out;
+		}
 	}
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (l4proto->ctl_compat_table != NULL) {
-		err = nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
+	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_table != NULL) {
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
@@ -273,25 +306,34 @@ out:
 	return err;
 }
 
-static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l4proto *l4proto)
+static
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
+	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_header != NULL)
+		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
+					&pn->ctl_compat_table,
+					NULL);
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
+#else
+	pn->users--;
 #endif /* CONFIG_SYSCTL */
 }
 
 /* FIXME: Allow NULL functions and sub in pointers to generic for
    them. --RR */
-int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
+static int
+nf_conntrack_l4proto_register_net(struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 
@@ -333,10 +375,6 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 		goto out_unlock;
 	}
 
-	ret = nf_ct_l4proto_register_sysctl(l4proto);
-	if (ret < 0)
-		goto out_unlock;
-
 	l4proto->nla_size = 0;
 	if (l4proto->nlattr_size)
 		l4proto->nla_size += l4proto->nlattr_size();
@@ -345,17 +383,34 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 
 	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
 			   l4proto);
-
 out_unlock:
 	mutex_unlock(&nf_ct_proto_mutex);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
-void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
+int nf_conntrack_l4proto_register(struct net *net,
+				  struct nf_conntrack_l4proto *l4proto)
 {
-	struct net *net;
+	int ret = 0;
+	if (net == &init_net)
+		ret = nf_conntrack_l4proto_register_net(l4proto);
+
+	if (ret < 0)
+		return ret;
+
+	if (l4proto->init_net)
+		ret = l4proto->init_net(net);
 
+	if (ret < 0)
+		return ret;
+
+	return nf_ct_l4proto_register_sysctl(net, l4proto);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
+
+static void
+nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
+{
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -365,15 +420,21 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 			) != l4proto);
 	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
 			   &nf_conntrack_l4proto_generic);
-	nf_ct_l4proto_unregister_sysctl(l4proto);
 	mutex_unlock(&nf_ct_proto_mutex);
 
 	synchronize_rcu();
+}
 
+void nf_conntrack_l4proto_unregister(struct net *net,
+				     struct nf_conntrack_l4proto *l4proto)
+{
+	if (net == &init_net)
+		nf_conntrack_l4proto_unregister_net(l4proto);
+
+	nf_ct_l4proto_unregister_sysctl(net, l4proto);
 	/* Remove all contrack entries for this protocol */
 	rtnl_lock();
-	for_each_net(net)
-		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
@@ -383,7 +444,7 @@ int nf_conntrack_proto_init(void)
 	unsigned int i;
 	int err;
 
-	err = nf_ct_l4proto_register_sysctl(&nf_conntrack_l4proto_generic);
+	err = nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l4proto_generic);
 	if (err < 0)
 		return err;
 
@@ -397,7 +458,7 @@ void nf_conntrack_proto_fini(void)
 {
 	unsigned int i;
 
-	nf_ct_l4proto_unregister_sysctl(&nf_conntrack_l4proto_generic);
+	nf_ct_l4proto_unregister_sysctl(&init_net, &nf_conntrack_l4proto_generic);
 
 	/* free l3proto protocol tables */
 	for (i = 0; i < PF_MAX; i++)
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index ef706a4..5a8e037 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -945,17 +945,17 @@ static int __init nf_conntrack_proto_dccp_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = nf_conntrack_l4proto_register(&dccp_proto4);
+	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto4);
 	if (err < 0)
 		goto err2;
 
-	err = nf_conntrack_l4proto_register(&dccp_proto6);
+	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto6);
 	if (err < 0)
 		goto err3;
 	return 0;
 
 err3:
-	nf_conntrack_l4proto_unregister(&dccp_proto4);
+	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
 err2:
 	unregister_pernet_subsys(&dccp_net_ops);
 err1:
@@ -965,8 +965,8 @@ err1:
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
 	unregister_pernet_subsys(&dccp_net_ops);
-	nf_conntrack_l4proto_unregister(&dccp_proto6);
-	nf_conntrack_l4proto_unregister(&dccp_proto4);
+	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto6);
+	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
 }
 
 module_init(nf_conntrack_proto_dccp_init);
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 4bf6b4e..132f0d2 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -396,18 +396,18 @@ static int __init nf_ct_proto_gre_init(void)
 {
 	int rv;
 
-	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
+	rv = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_gre4);
 	if (rv < 0)
 		return rv;
 	rv = register_pernet_subsys(&proto_gre_net_ops);
 	if (rv < 0)
-		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+		nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_gre4);
 	return rv;
 }
 
 static void __exit nf_ct_proto_gre_fini(void)
 {
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_gre4);
 	unregister_pernet_subsys(&proto_gre_net_ops);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 996db2f..97bbc20 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -791,12 +791,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
 {
 	int ret;
 
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp4);
 	if (ret) {
 		pr_err("nf_conntrack_l4proto_sctp4: protocol register failed\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
+	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp6);
 	if (ret) {
 		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
 		goto cleanup_sctp4;
@@ -805,15 +805,15 @@ static int __init nf_conntrack_proto_sctp_init(void)
 	return ret;
 
  cleanup_sctp4:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
  out:
 	return ret;
 }
 
 static void __exit nf_conntrack_proto_sctp_fini(void)
 {
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
 }
 
 module_init(nf_conntrack_proto_sctp_init);
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4d60a53..fa142a8 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -299,23 +299,23 @@ static int __init nf_conntrack_proto_udplite_init(void)
 {
 	int err;
 
-	err = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite4);
+	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite4);
 	if (err < 0)
 		goto err1;
-	err = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite6);
+	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite6);
 	if (err < 0)
 		goto err2;
 	return 0;
 err2:
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
 err1:
 	return err;
 }
 
 static void __exit nf_conntrack_proto_udplite_exit(void)
 {
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite6);
+	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
 }
 
 module_init(nf_conntrack_proto_udplite_init);
-- 
1.7.10
