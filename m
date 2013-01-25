From: pablo@netfilter.org
Subject: [PATCH 20/21] netfilter: nf_conntrack: refactor l4proto support for netns
Date: Fri, 25 Jan 2013 14:54:52 +0100
Message-ID: <1359122093-3404-21-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60352 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757366Ab3AYNzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:24 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Move the code that register/unregister l4proto to the
module_init/exit context.

Given that we have to modify some interfaces to accomodate
these changes, it is a good time to use shorter function names
for this using the nf_ct_* prefix instead of nf_conntrack_*,
that is:

nf_ct_l4proto_register
nf_ct_l4proto_pernet_register
nf_ct_l4proto_unregister
nf_ct_l4proto_pernet_unregister

We same many line breaks with it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |   10 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   62 +++++++++++++++---------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   62 +++++++++++++++---------
 net/netfilter/nf_conntrack_proto.c             |   27 +++--------
 net/netfilter/nf_conntrack_proto_dccp.c        |   43 +++++++++++-----
 net/netfilter/nf_conntrack_proto_gre.c         |   23 +++++++--
 net/netfilter/nf_conntrack_proto_sctp.c        |   43 +++++++++++-----
 net/netfilter/nf_conntrack_proto_udplite.c     |   40 +++++++++++----
 8 files changed, 204 insertions(+), 106 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index c3be4ae..914d8d9 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -121,12 +121,16 @@ extern struct nf_conntrack_l4proto *
 nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
 extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
 
-/* Protocol registration. */
-extern int nf_conntrack_l4proto_register(struct net *net,
+/* Protocol pernet registration. */
+extern int nf_ct_l4proto_pernet_register(struct net *net,
 					 struct nf_conntrack_l4proto *proto);
-extern void nf_conntrack_l4proto_unregister(struct net *net,
+extern void nf_ct_l4proto_pernet_unregister(struct net *net,
 					    struct nf_conntrack_l4proto *proto);
 
+/* Protocol global registration. */
+extern int nf_ct_l4proto_register(struct nf_conntrack_l4proto *proto);
+extern void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *proto);
+
 static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
 {
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 76b84fc..48990ad 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -420,22 +420,19 @@ static int ipv4_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_tcp4);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_tcp4 :protocol register failed\n");
+		pr_err("nf_conntrack_tcp4: pernet registration failed\n");
 		goto out_tcp;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udp4);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_udp4 :protocol register failed\n");
+		pr_err("nf_conntrack_udp4: pernet registration failed\n");
 		goto out_udp;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_icmp);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
+		pr_err("nf_conntrack_icmp4: pernet registration failed\n");
 		goto out_icmp;
 	}
 	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv4);
@@ -445,14 +442,11 @@ static int ipv4_net_init(struct net *net)
 	}
 	return 0;
 out_ipv4:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_icmp);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmp);
 out_icmp:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_udp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp4);
 out_udp:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_tcp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_tcp4);
 out_tcp:
 	return ret;
 }
@@ -460,12 +454,9 @@ out_tcp:
 static void ipv4_net_exit(struct net *net)
 {
 	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv4);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_icmp);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_udp4);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_tcp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmp);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_tcp4);
 }
 
 static struct pernet_operations ipv4_net_ops = {
@@ -499,10 +490,28 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_pernet;
 	}
 
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_tcp4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register tcp4 proto.\n");
+		goto cleanup_hooks;
+	}
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udp4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register udp4 proto.\n");
+		goto cleanup_tcp4;
+	}
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_icmp);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv4: can't register icmpv4 proto.\n");
+		goto cleanup_udp4;
+	}
+
 	ret = nf_ct_l3proto_register(&nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register ipv4 proto.\n");
-		goto cleanup_hooks;
+		goto cleanup_icmpv4;
 	}
 
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
@@ -515,6 +524,12 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
  cleanup_proto:
 	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
 #endif
+ cleanup_icmpv4:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
+ cleanup_udp4:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
+ cleanup_tcp4:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
  cleanup_hooks:
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_pernet:
@@ -531,6 +546,9 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_conntrack_ipv4_compat_fini();
 #endif
 	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 3eaf6ba..8a45bb2 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -421,22 +421,19 @@ static int ipv6_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_tcp6);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_l4proto_tcp6: protocol register failed\n");
+		pr_err("nf_conntrack_tcp6: pernet registration failed\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udp6);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_l4proto_udp6: protocol register failed\n");
+		pr_err("nf_conntrack_udp6: pernet registration failed\n");
 		goto cleanup_tcp6;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_icmpv6);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
-		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
+		pr_err("nf_conntrack_icmp6: pernet registration failed\n");
 		goto cleanup_udp6;
 	}
 	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv6);
@@ -446,14 +443,11 @@ static int ipv6_net_init(struct net *net)
 	}
 	return 0;
  cleanup_icmpv6:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_icmpv6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmpv6);
  cleanup_udp6:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_udp6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp6);
  cleanup_tcp6:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_tcp6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_tcp6);
  out:
 	return ret;
 }
@@ -461,12 +455,9 @@ static int ipv6_net_init(struct net *net)
 static void ipv6_net_exit(struct net *net)
 {
 	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv6);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_icmpv6);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_udp6);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_tcp6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_icmpv6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udp6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_tcp6);
 }
 
 static struct pernet_operations ipv6_net_ops = {
@@ -499,13 +490,37 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 		goto cleanup_pernet;
 	}
 
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_tcp6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register tcp6 proto.\n");
+		goto cleanup_hooks;
+	}
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udp6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register udp6 proto.\n");
+		goto cleanup_tcp6;
+	}
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_icmpv6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_ipv6: can't register icmpv6 proto.\n");
+		goto cleanup_udp6;
+	}
+
 	ret = nf_ct_l3proto_register(&nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register ipv6 proto.\n");
-		goto cleanup_hooks;
+		goto cleanup_icmpv6;
 	}
 	return ret;
 
+ cleanup_icmpv6:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
+ cleanup_udp6:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp6);
+ cleanup_tcp6:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
  cleanup_hooks:
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_pernet:
@@ -519,6 +534,9 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
 	nf_ct_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp6);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
 	nf_unregister_sockopt(&so_getorigdst6);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 076d827..58ab405 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -363,8 +363,7 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
 
 /* FIXME: Allow NULL functions and sub in pointers to generic for
    them. --RR */
-static int
-nf_conntrack_l4proto_register_net(struct nf_conntrack_l4proto *l4proto)
+int nf_ct_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 
@@ -418,8 +417,9 @@ out_unlock:
 	mutex_unlock(&nf_ct_proto_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_register);
 
-int nf_conntrack_l4proto_register(struct net *net,
+int nf_ct_l4proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
@@ -439,22 +439,13 @@ int nf_conntrack_l4proto_register(struct net *net,
 	if (ret < 0)
 		goto out;
 
-	if (net == &init_net) {
-		ret = nf_conntrack_l4proto_register_net(l4proto);
-		if (ret < 0) {
-			nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
-			goto out;
-		}
-	}
-
 	pn->users++;
 out:
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_register);
 
-static void
-nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
+void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
@@ -469,15 +460,13 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister);
 
-void nf_conntrack_l4proto_unregister(struct net *net,
+void nf_ct_l4proto_pernet_unregister(struct net *net,
 				     struct nf_conntrack_l4proto *l4proto)
 {
 	struct nf_proto_net *pn = NULL;
 
-	if (net == &init_net)
-		nf_conntrack_l4proto_unregister_net(l4proto);
-
 	pn = nf_ct_l4proto_net(net, l4proto);
 	if (pn == NULL)
 		return;
@@ -488,7 +477,7 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_unregister);
 
 int nf_conntrack_proto_pernet_init(struct net *net)
 {
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a8ae287..432f957 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -935,32 +935,27 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 static __net_init int dccp_net_init(struct net *net)
 {
 	int ret = 0;
-	ret = nf_conntrack_l4proto_register(net,
-					    &dccp_proto4);
+	ret = nf_ct_l4proto_pernet_register(net, &dccp_proto4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_dccp4 :protocol register failed.\n");
+		pr_err("nf_conntrack_dccp4: pernet registration failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &dccp_proto6);
+	ret = nf_ct_l4proto_pernet_register(net, &dccp_proto6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_dccp6 :protocol register failed.\n");
+		pr_err("nf_conntrack_dccp6: pernet registration failed.\n");
 		goto cleanup_dccp4;
 	}
 	return 0;
 cleanup_dccp4:
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto4);
+	nf_ct_l4proto_pernet_unregister(net, &dccp_proto4);
 out:
 	return ret;
 }
 
 static __net_exit void dccp_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto6);
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto4);
+	nf_ct_l4proto_pernet_unregister(net, &dccp_proto6);
+	nf_ct_l4proto_pernet_unregister(net, &dccp_proto4);
 }
 
 static struct pernet_operations dccp_net_ops = {
@@ -972,11 +967,33 @@ static struct pernet_operations dccp_net_ops = {
 
 static int __init nf_conntrack_proto_dccp_init(void)
 {
-	return register_pernet_subsys(&dccp_net_ops);
+	int ret;
+
+	ret = nf_ct_l4proto_register(&dccp_proto4);
+	if (ret < 0)
+		goto out_dccp4;
+
+	ret = nf_ct_l4proto_register(&dccp_proto6);
+	if (ret < 0)
+		goto out_dccp6;
+
+	ret = register_pernet_subsys(&dccp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_ct_l4proto_unregister(&dccp_proto6);
+out_dccp6:
+	nf_ct_l4proto_unregister(&dccp_proto4);
+out_dccp4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
+	nf_ct_l4proto_unregister(&dccp_proto6);
+	nf_ct_l4proto_unregister(&dccp_proto4);
 	unregister_pernet_subsys(&dccp_net_ops);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index b09b7af..bd7d01d 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -397,15 +397,15 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 static int proto_gre_net_init(struct net *net)
 {
 	int ret = 0;
-	ret = nf_conntrack_l4proto_register(net, &nf_conntrack_l4proto_gre4);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_gre4);
 	if (ret < 0)
-		pr_err("nf_conntrack_l4proto_gre4 :protocol register failed.\n");
+		pr_err("nf_conntrack_gre4: pernet registration failed.\n");
 	return ret;
 }
 
 static void proto_gre_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_gre4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_gre4);
 	nf_ct_gre_keymap_flush(net);
 }
 
@@ -418,11 +418,26 @@ static struct pernet_operations proto_gre_net_ops = {
 
 static int __init nf_ct_proto_gre_init(void)
 {
-	return register_pernet_subsys(&proto_gre_net_ops);
+	int ret;
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_gre4);
+	if (ret < 0)
+		goto out_gre4;
+
+	ret = register_pernet_subsys(&proto_gre_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+out_gre4:
+	return ret;
 }
 
 static void __exit nf_ct_proto_gre_fini(void)
 {
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 	unregister_pernet_subsys(&proto_gre_net_ops);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c746d61..480f616 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -853,33 +853,28 @@ static int sctp_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_sctp4);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_sctp4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_sctp4 :protocol register failed.\n");
+		pr_err("nf_conntrack_sctp4: pernet registration failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_sctp6);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_sctp6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_sctp6 :protocol register failed.\n");
+		pr_err("nf_conntrack_sctp6: pernet registration failed.\n");
 		goto cleanup_sctp4;
 	}
 	return 0;
 
 cleanup_sctp4:
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_sctp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_sctp4);
 out:
 	return ret;
 }
 
 static void sctp_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_sctp6);
-	nf_conntrack_l4proto_unregister(net,
-					&nf_conntrack_l4proto_sctp4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_sctp6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_sctp4);
 }
 
 static struct pernet_operations sctp_net_ops = {
@@ -891,11 +886,33 @@ static struct pernet_operations sctp_net_ops = {
 
 static int __init nf_conntrack_proto_sctp_init(void)
 {
-	return register_pernet_subsys(&sctp_net_ops);
+	int ret;
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_sctp4);
+	if (ret < 0)
+		goto out_sctp4;
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_sctp6);
+	if (ret < 0)
+		goto out_sctp6;
+
+	ret = register_pernet_subsys(&sctp_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
+out_sctp6:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
+out_sctp4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_sctp_fini(void)
 {
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
 	unregister_pernet_subsys(&sctp_net_ops);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4b66df2..1574895 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -336,30 +336,28 @@ static int udplite_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udplite4);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_udplite4);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
+		pr_err("nf_conntrack_udplite4: pernet registration failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udplite6);
+	ret = nf_ct_l4proto_pernet_register(net, &nf_conntrack_l4proto_udplite6);
 	if (ret < 0) {
-		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
+		pr_err("nf_conntrack_udplite6: pernet registration failed.\n");
 		goto cleanup_udplite4;
 	}
 	return 0;
 
 cleanup_udplite4:
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udplite4);
 out:
 	return ret;
 }
 
 static void udplite_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite6);
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udplite6);
+	nf_ct_l4proto_pernet_unregister(net, &nf_conntrack_l4proto_udplite4);
 }
 
 static struct pernet_operations udplite_net_ops = {
@@ -371,11 +369,33 @@ static struct pernet_operations udplite_net_ops = {
 
 static int __init nf_conntrack_proto_udplite_init(void)
 {
-	return register_pernet_subsys(&udplite_net_ops);
+	int ret;
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udplite4);
+	if (ret < 0)
+		goto out_udplite4;
+
+	ret = nf_ct_l4proto_register(&nf_conntrack_l4proto_udplite6);
+	if (ret < 0)
+		goto out_udplite6;
+
+	ret = register_pernet_subsys(&udplite_net_ops);
+	if (ret < 0)
+		goto out_pernet;
+
+	return 0;
+out_pernet:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
+out_udplite6:
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
+out_udplite4:
+	return ret;
 }
 
 static void __exit nf_conntrack_proto_udplite_exit(void)
 {
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
+	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
 	unregister_pernet_subsys(&udplite_net_ops);
 }
 
-- 
1.7.10.4
