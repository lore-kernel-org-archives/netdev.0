From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/47] netfilter: conntrack: do not enable connection tracking unless needed
Date: Mon,  4 Sep 2017 00:28:56 +0200
Message-ID: <1504477763-12205-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51456 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753005AbdICW3f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:29:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6F08A190F60
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 59354B502A
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:08 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Discussion during NFWS 2017 in Faro has shown that the current
conntrack behaviour is unreasonable.

Even if conntrack module is loaded on behalf of a single net namespace,
its turned on for all namespaces, which is expensive.  Commit
481fa373476 ("netfilter: conntrack: add nf_conntrack_default_on sysctl")
attempted to provide an alternative to the 'default on' behaviour by
adding a sysctl to change it.

However, as Eric points out, the sysctl only becomes available
once the module is loaded, and then its too late.

So we either have to move the sysctl to the core, or, alternatively,
change conntrack to become active only once the rule set requires this.

This does the latter, conntrack is only enabled when a rule needs it.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/nf_conntrack-sysctl.txt | 11 ---------
 include/net/netfilter/nf_conntrack_l3proto.h     | 15 ------------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c   | 16 ++-----------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c   | 17 ++------------
 net/netfilter/nf_conntrack_proto.c               | 29 ------------------------
 net/netfilter/nf_conntrack_standalone.c          | 10 --------
 6 files changed, 4 insertions(+), 94 deletions(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index 497d668288f9..433b6724797a 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -96,17 +96,6 @@ nf_conntrack_max - INTEGER
 	Size of connection tracking table.  Default value is
 	nf_conntrack_buckets value * 4.
 
-nf_conntrack_default_on - BOOLEAN
-	0 - don't register conntrack in new net namespaces
-	1 - register conntrack in new net namespaces (default)
-
-	This controls wheter newly created network namespaces have connection
-	tracking enabled by default.  It will be enabled automatically
-	regardless of this setting if the new net namespace requires
-	connection tracking, e.g. when NAT rules are created.
-	This setting is only visible in initial user namespace, it has no
-	effect on existing namespaces.
-
 nf_conntrack_tcp_be_liberal - BOOLEAN
 	0 - disabled (default)
 	not 0 - enabled
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 6d14b36e3a49..1b8de164d744 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -73,21 +73,6 @@ struct nf_conntrack_l3proto {
 
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[NFPROTO_NUMPROTO];
 
-#ifdef CONFIG_SYSCTL
-/* Protocol pernet registration. */
-int nf_ct_l3proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l3proto *proto);
-#else
-static inline int nf_ct_l3proto_pernet_register(struct net *n,
-						struct nf_conntrack_l3proto *p)
-{
-	return 0;
-}
-#endif
-
-void nf_ct_l3proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l3proto *proto);
-
 /* Protocol global registration. */
 int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto);
 void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 63e4ea0e01f8..de5f0e6ddd1b 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -398,24 +398,12 @@ static struct nf_conntrack_l4proto *builtin_l4proto4[] = {
 
 static int ipv4_net_init(struct net *net)
 {
-	int ret = 0;
-
-	ret = nf_ct_l4proto_pernet_register(net, builtin_l4proto4,
-					    ARRAY_SIZE(builtin_l4proto4));
-	if (ret < 0)
-		return ret;
-	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv4);
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv4: pernet registration failed\n");
-		nf_ct_l4proto_pernet_unregister(net, builtin_l4proto4,
-						ARRAY_SIZE(builtin_l4proto4));
-	}
-	return ret;
+	return nf_ct_l4proto_pernet_register(net, builtin_l4proto4,
+					     ARRAY_SIZE(builtin_l4proto4));
 }
 
 static void ipv4_net_exit(struct net *net)
 {
-	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv4);
 	nf_ct_l4proto_pernet_unregister(net, builtin_l4proto4,
 					ARRAY_SIZE(builtin_l4proto4));
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index f2d2f4a9294b..ddef5ee9e0a8 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -398,25 +398,12 @@ static struct nf_conntrack_l4proto *builtin_l4proto6[] = {
 
 static int ipv6_net_init(struct net *net)
 {
-	int ret = 0;
-
-	ret = nf_ct_l4proto_pernet_register(net, builtin_l4proto6,
-					    ARRAY_SIZE(builtin_l4proto6));
-	if (ret < 0)
-		return ret;
-
-	ret = nf_ct_l3proto_pernet_register(net, &nf_conntrack_l3proto_ipv6);
-	if (ret < 0) {
-		pr_err("nf_conntrack_ipv6: pernet registration failed.\n");
-		nf_ct_l4proto_pernet_unregister(net, builtin_l4proto6,
-						ARRAY_SIZE(builtin_l4proto6));
-	}
-	return ret;
+	return nf_ct_l4proto_pernet_register(net, builtin_l4proto6,
+					     ARRAY_SIZE(builtin_l4proto6));
 }
 
 static void ipv6_net_exit(struct net *net)
 {
-	nf_ct_l3proto_pernet_unregister(net, &nf_conntrack_l3proto_ipv6);
 	nf_ct_l4proto_pernet_unregister(net, builtin_l4proto6,
 					ARRAY_SIZE(builtin_l4proto6));
 }
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 1dcad229c3cc..7c89dade6fd3 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -238,20 +238,6 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 
-#ifdef CONFIG_SYSCTL
-extern unsigned int nf_conntrack_default_on;
-
-int nf_ct_l3proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l3proto *proto)
-{
-	if (nf_conntrack_default_on == 0)
-		return 0;
-
-	return proto->net_ns_get ? proto->net_ns_get(net) : 0;
-}
-EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
-#endif
-
 void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
 	BUG_ON(proto->l3proto >= NFPROTO_NUMPROTO);
@@ -270,21 +256,6 @@ void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 
-void nf_ct_l3proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l3proto *proto)
-{
-	/*
-	 * nf_conntrack_default_on *might* have registered hooks.
-	 * ->net_ns_put must cope with more puts() than get(), i.e.
-	 * if nf_conntrack_default_on was 0 at time of
-	 * nf_ct_l3proto_pernet_register invocation this net_ns_put()
-	 * should be a noop.
-	 */
-	if (proto->net_ns_put)
-		proto->net_ns_put(net);
-}
-EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_unregister);
-
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index ccb5cb9043e0..5b6c675d55b1 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -452,9 +452,6 @@ static int log_invalid_proto_max __read_mostly = 255;
 /* size the user *wants to set */
 static unsigned int nf_conntrack_htable_size_user __read_mostly;
 
-extern unsigned int nf_conntrack_default_on;
-unsigned int nf_conntrack_default_on __read_mostly = 1;
-
 static int
 nf_conntrack_hash_sysctl(struct ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -520,13 +517,6 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.procname	= "nf_conntrack_default_on",
-		.data		= &nf_conntrack_default_on,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{ }
 };
 
-- 
2.1.4
