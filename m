From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/19] netfilter: l3proto: prepare reworking l3proto support for netns
Date: Fri, 28 Dec 2012 10:36:35 +0800
Message-ID: <1356662206-2260-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36421 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab2L1Cis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:48 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare to move the code that register/unregister l3proto
to the module_init/exit context.

This patch deletes the codes that register/unregister l3proto,
this code will be added in next two patch.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h   | 20 ++++++++++++-----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  6 ++---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  6 ++---
 net/netfilter/nf_conntrack_proto.c             | 31 ++++++++++----------------
 4 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 6f7c13f..f3834d5 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -76,11 +76,21 @@ struct nf_conntrack_l3proto {
 
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
 
-/* Protocol registration. */
-extern int nf_conntrack_l3proto_register(struct net *net,
-					 struct nf_conntrack_l3proto *proto);
-extern void nf_conntrack_l3proto_unregister(struct net *net,
-					    struct nf_conntrack_l3proto *proto);
+/* Protocol pernet registration. */
+extern int
+nf_conntrack_l3proto_pernet_register(struct net *net,
+				     struct nf_conntrack_l3proto *proto);
+extern void
+nf_conntrack_l3proto_pernet_unregister(struct net *net,
+				       struct nf_conntrack_l3proto *proto);
+
+/* Protocol global registration. */
+extern int
+nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto);
+
+extern void
+nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto);
+
 extern struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
 extern void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index fcdd0c2..afd3a96 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -438,8 +438,8 @@ static int ipv4_net_init(struct net *net)
 		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
 		goto out_icmp;
 	}
-	ret = nf_conntrack_l3proto_register(net,
-					    &nf_conntrack_l3proto_ipv4);
+	ret = nf_conntrack_l3proto_pernet_register(net,
+					&nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l3proto_ipv4 :protocol register failed\n");
 		goto out_ipv4;
@@ -460,7 +460,7 @@ out_tcp:
 
 static void ipv4_net_exit(struct net *net)
 {
-	nf_conntrack_l3proto_unregister(net,
+	nf_conntrack_l3proto_pernet_unregister(net,
 					&nf_conntrack_l3proto_ipv4);
 	nf_conntrack_l4proto_unregister(net,
 					&nf_conntrack_l4proto_icmp);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 00ee17c..469a15f 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -439,8 +439,8 @@ static int ipv6_net_init(struct net *net)
 		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
 		goto cleanup_udp6;
 	}
-	ret = nf_conntrack_l3proto_register(net,
-					    &nf_conntrack_l3proto_ipv6);
+	ret = nf_conntrack_l3proto_pernet_register(net,
+						&nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
 		printk(KERN_ERR "nf_conntrack_l3proto_ipv6: protocol register failed\n");
 		goto cleanup_icmpv6;
@@ -461,7 +461,7 @@ static int ipv6_net_init(struct net *net)
 
 static void ipv6_net_exit(struct net *net)
 {
-	nf_conntrack_l3proto_unregister(net,
+	nf_conntrack_l3proto_pernet_unregister(net,
 					&nf_conntrack_l3proto_ipv6);
 	nf_conntrack_l4proto_unregister(net,
 					&nf_conntrack_l4proto_icmpv6);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 3d01b90..5a625a6 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -212,8 +212,8 @@ static void nf_ct_l3proto_unregister_sysctl(struct net *net,
 #endif
 }
 
-static int
-nf_conntrack_l3proto_register_net(struct nf_conntrack_l3proto *proto)
+int
+nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
 	struct nf_conntrack_l3proto *old;
@@ -242,9 +242,10 @@ out_unlock:
 	return ret;
 
 }
+EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
-int nf_conntrack_l3proto_register(struct net *net,
-				  struct nf_conntrack_l3proto *proto)
+int nf_conntrack_l3proto_pernet_register(struct net *net,
+					 struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
 
@@ -258,18 +259,12 @@ int nf_conntrack_l3proto_register(struct net *net,
 	if (ret < 0)
 		return ret;
 
-	if (net == &init_net) {
-		ret = nf_conntrack_l3proto_register_net(proto);
-		if (ret < 0)
-			nf_ct_l3proto_unregister_sysctl(net, proto);
-	}
-
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
+EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_pernet_register);
 
-static void
-nf_conntrack_l3proto_unregister_net(struct nf_conntrack_l3proto *proto)
+void
+nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
 	BUG_ON(proto->l3proto >= AF_MAX);
 
@@ -283,19 +278,17 @@ nf_conntrack_l3proto_unregister_net(struct nf_conntrack_l3proto *proto)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
-void nf_conntrack_l3proto_unregister(struct net *net,
-				     struct nf_conntrack_l3proto *proto)
+void nf_conntrack_l3proto_pernet_unregister(struct net *net,
+					struct nf_conntrack_l3proto *proto)
 {
-	if (net == &init_net)
-		nf_conntrack_l3proto_unregister_net(proto);
-
 	nf_ct_l3proto_unregister_sysctl(net, proto);
 
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
+EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_pernet_unregister);
 
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
-- 
1.7.11.7
