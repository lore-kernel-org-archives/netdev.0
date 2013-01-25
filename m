From: pablo@netfilter.org
Subject: [PATCH 19/21] netfilter: nf_conntrack: refactor l3proto support for netns
Date: Fri, 25 Jan 2013 14:54:51 +0100
Message-ID: <1359122093-3404-20-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60344 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757351Ab3AYNzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:21 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Move the code that register/unregister l3proto to the
module_init/exit context.

Given that we have to modify some interfaces to accomodate
these changes, it is a good time to use shorter function names
for this using the nf_ct_* prefix instead of nf_conntrack_*,
that is:

nf_ct_l3proto_register
nf_ct_l3proto_pernet_register
nf_ct_l3proto_unregister
nf_ct_l3proto_pernet_unregister

We same many line breaks with it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |   11 ++++++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   22 +++++++++++------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   26 +++++++++++++-------
 net/netfilter/nf_conntrack_proto.c             |   31 +++++++-----------------
 4 files changed, 49 insertions(+), 41 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 6f7c13f..3bb89ea 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -76,11 +76,16 @@ struct nf_conntrack_l3proto {
 
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
 
-/* Protocol registration. */
-extern int nf_conntrack_l3proto_register(struct net *net,
+/* Protocol pernet registration. */
+extern int nf_ct_l3proto_pernet_register(struct net *net,
 					 struct nf_conntrack_l3proto *proto);
-extern void nf_conntrack_l3proto_unregister(struct net *net,
+extern void nf_ct_l3proto_pernet_unregister(struct net *net,
 					    struct nf_conntrack_l3proto *proto);
+
+/* Protocol global registration. */
+extern int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto);
+extern void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto);
+
 extern struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
 extern void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index fcdd0c2..76b84fc 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -438,10 +438,9 @@ static int ipv4_net_init(struct net *net)
 		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
 		goto out_icmp;
 	}
-	ret = nf_conntrack_l3proto_register(net,
-					    &nf_conntrack_l3proto_ipv4);
+	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l3proto_ipv4 :protocol register failed\n");
+		pr_err("nf_conntrack_ipv4: pernet registration failed\n");
 		goto out_ipv4;
 	}
 	return 0;
@@ -460,8 +459,7 @@ out_tcp:
 
 static void ipv4_net_exit(struct net *net)
 {
-	nf_conntrack_l3proto_unregister(net,
-					&nf_conntrack_l3proto_ipv4);
+	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv4);
 	nf_conntrack_l4proto_unregister(net,
 					&nf_conntrack_l4proto_icmp);
 	nf_conntrack_l4proto_unregister(net,
@@ -500,16 +498,25 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
 		goto cleanup_pernet;
 	}
+
+	ret = nf_ct_l3proto_register(&nf_conntrack_l3proto_ipv4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register ipv4 proto.\n");
+		goto cleanup_hooks;
+	}
+
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	ret = nf_conntrack_ipv4_compat_init();
 	if (ret < 0)
-		goto cleanup_hooks;
+		goto cleanup_proto;
 #endif
 	return ret;
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+ cleanup_proto:
+	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
+#endif
  cleanup_hooks:
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
-#endif
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
@@ -523,6 +530,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	nf_conntrack_ipv4_compat_fini();
 #endif
+	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 137e245..3eaf6ba 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -439,10 +439,9 @@ static int ipv6_net_init(struct net *net)
 		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
 		goto cleanup_udp6;
 	}
-	ret = nf_conntrack_l3proto_register(net,
-					    &nf_conntrack_l3proto_ipv6);
+	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_l3proto_ipv6: protocol register failed\n");
+		pr_err("nf_conntrack_ipv6: pernet registration failed.\n");
 		goto cleanup_icmpv6;
 	}
 	return 0;
@@ -461,8 +460,7 @@ static int ipv6_net_init(struct net *net)
 
 static void ipv6_net_exit(struct net *net)
 {
-	nf_conntrack_l3proto_unregister(net,
-					&nf_conntrack_l3proto_ipv6);
+	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv6);
 	nf_conntrack_l4proto_unregister(net,
 					&nf_conntrack_l4proto_icmpv6);
 	nf_conntrack_l4proto_unregister(net,
@@ -491,19 +489,28 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 
 	ret = register_pernet_subsys(&ipv6_net_ops);
 	if (ret < 0)
-		goto cleanup_pernet;
+		goto cleanup_sockopt;
+
 	ret = nf_register_hooks(ipv6_conntrack_ops,
 				ARRAY_SIZE(ipv6_conntrack_ops));
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register pre-routing defrag "
 		       "hook.\n");
-		goto cleanup_ipv6;
+		goto cleanup_pernet;
+	}
+
+	ret = nf_ct_l3proto_register(&nf_conntrack_l3proto_ipv6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register ipv6 proto.\n");
+		goto cleanup_hooks;
 	}
 	return ret;
 
- cleanup_ipv6:
-	unregister_pernet_subsys(&ipv6_net_ops);
+ cleanup_hooks:
+	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_pernet:
+	unregister_pernet_subsys(&ipv6_net_ops);
+ cleanup_sockopt:
 	nf_unregister_sockopt(&so_getorigdst6);
 	return ret;
 }
@@ -511,6 +518,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
+	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
 	nf_unregister_sockopt(&so_getorigdst6);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index f0ec07c..076d827 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -212,8 +212,7 @@ static void nf_ct_l3proto_unregister_sysctl(struct net *net,
 #endif
 }
 
-static int
-nf_conntrack_l3proto_register_net(struct nf_conntrack_l3proto *proto)
+int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
 	struct nf_conntrack_l3proto *old;
@@ -242,8 +241,9 @@ out_unlock:
 	return ret;
 
 }
+EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 
-int nf_conntrack_l3proto_register(struct net *net,
+int nf_ct_l3proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
@@ -254,22 +254,11 @@ int nf_conntrack_l3proto_register(struct net *net,
 			return ret;
 	}
 
-	ret = nf_ct_l3proto_register_sysctl(net, proto);
-	if (ret < 0)
-		return ret;
-
-	if (net == &init_net) {
-		ret = nf_conntrack_l3proto_register_net(proto);
-		if (ret < 0)
-			nf_ct_l3proto_unregister_sysctl(net, proto);
-	}
-
-	return ret;
+	return nf_ct_l3proto_register_sysctl(net, proto);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
+EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
 
-static void
-nf_conntrack_l3proto_unregister_net(struct nf_conntrack_l3proto *proto)
+void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
 	BUG_ON(proto->l3proto >= AF_MAX);
 
@@ -283,19 +272,17 @@ nf_conntrack_l3proto_unregister_net(struct nf_conntrack_l3proto *proto)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 
-void nf_conntrack_l3proto_unregister(struct net *net,
+void nf_ct_l3proto_pernet_unregister(struct net *net,
 				     struct nf_conntrack_l3proto *proto)
 {
-	if (net == &init_net)
-		nf_conntrack_l3proto_unregister_net(proto);
-
 	nf_ct_l3proto_unregister_sysctl(net, proto);
 
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
+EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_unregister);
 
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
-- 
1.7.10.4
