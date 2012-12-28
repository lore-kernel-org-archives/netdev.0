From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 12/19] netfilter: l4proto: prepare reworking l4proto support for netns
Date: Fri, 28 Dec 2012 10:36:39 +0800
Message-ID: <1356662206-2260-13-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare to move the code that register/unregister l4proto
to the module_init/exit context.

This patch deletes the codes that register/unregister l4proto,
this code will be added in next patches.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h   | 18 ++++++++++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 24 +++++++++----------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 24 +++++++++----------
 net/netfilter/nf_conntrack_proto.c             | 33 ++++++++++----------------
 net/netfilter/nf_conntrack_proto_dccp.c        | 20 ++++++++--------
 net/netfilter/nf_conntrack_proto_gre.c         |  6 +++--
 net/netfilter/nf_conntrack_proto_sctp.c        | 14 +++++------
 net/netfilter/nf_conntrack_proto_udplite.c     | 17 +++++++------
 8 files changed, 80 insertions(+), 76 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index c3be4ae..c001ef7 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -121,11 +121,19 @@ extern struct nf_conntrack_l4proto *
 nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
 extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
 
-/* Protocol registration. */
-extern int nf_conntrack_l4proto_register(struct net *net,
-					 struct nf_conntrack_l4proto *proto);
-extern void nf_conntrack_l4proto_unregister(struct net *net,
-					    struct nf_conntrack_l4proto *proto);
+/* Protocol pernet registration. */
+extern int
+nf_conntrack_l4proto_pernet_register(struct net *net,
+				struct nf_conntrack_l4proto *proto);
+extern void
+nf_conntrack_l4proto_pernet_unregister(struct net *net,
+				struct nf_conntrack_l4proto *proto);
+
+/* Protocol global registration. */
+extern int
+nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
+extern void
+nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
 
 static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
 {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index a942add..933da838 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -420,20 +420,20 @@ static int ipv4_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_tcp4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_tcp4 :protocol register failed\n");
 		goto out_tcp;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udp4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_udp4 :protocol register failed\n");
 		goto out_udp;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_icmp);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_icmp4 :protocol register failed\n");
 		goto out_icmp;
@@ -446,13 +446,13 @@ static int ipv4_net_init(struct net *net)
 	}
 	return 0;
 out_ipv4:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_icmp);
 out_icmp:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_udp4);
 out_udp:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_tcp4);
 out_tcp:
 	return ret;
@@ -462,11 +462,11 @@ static void ipv4_net_exit(struct net *net)
 {
 	nf_conntrack_l3proto_pernet_unregister(net,
 					&nf_conntrack_l3proto_ipv4);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_icmp);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_udp4);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_tcp4);
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 07ec50b..8db8182 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -421,20 +421,20 @@ static int ipv6_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_tcp6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
 		printk(KERN_ERR "nf_conntrack_l4proto_tcp6: protocol register failed\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udp6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
 		printk(KERN_ERR "nf_conntrack_l4proto_udp6: protocol register failed\n");
 		goto cleanup_tcp6;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_icmpv6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
 		printk(KERN_ERR "nf_conntrack_l4proto_icmp6: protocol register failed\n");
 		goto cleanup_udp6;
@@ -447,13 +447,13 @@ static int ipv6_net_init(struct net *net)
 	}
 	return 0;
  cleanup_icmpv6:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_icmpv6);
  cleanup_udp6:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_udp6);
  cleanup_tcp6:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_tcp6);
  out:
 	return ret;
@@ -463,11 +463,11 @@ static void ipv6_net_exit(struct net *net)
 {
 	nf_conntrack_l3proto_pernet_unregister(net,
 					&nf_conntrack_l3proto_ipv6);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_icmpv6);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_udp6);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_tcp6);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 5a625a6..ff38923 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -369,8 +369,8 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
 
 /* FIXME: Allow NULL functions and sub in pointers to generic for
    them. --RR */
-static int
-nf_conntrack_l4proto_register_net(struct nf_conntrack_l4proto *l4proto)
+int
+nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 
@@ -424,9 +424,10 @@ out_unlock:
 	mutex_unlock(&nf_ct_proto_mutex);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
-int nf_conntrack_l4proto_register(struct net *net,
-				  struct nf_conntrack_l4proto *l4proto)
+int nf_conntrack_l4proto_pernet_register(struct net *net,
+					struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nf_proto_net *pn = NULL;
@@ -445,22 +446,14 @@ int nf_conntrack_l4proto_register(struct net *net,
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
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_pernet_register);
 
-static void
-nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
+void
+nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
@@ -475,15 +468,13 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
 
 	synchronize_rcu();
 }
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-void nf_conntrack_l4proto_unregister(struct net *net,
-				     struct nf_conntrack_l4proto *l4proto)
+void nf_conntrack_l4proto_pernet_unregister(struct net *net,
+					struct nf_conntrack_l4proto *l4proto)
 {
 	struct nf_proto_net *pn = NULL;
 
-	if (net == &init_net)
-		nf_conntrack_l4proto_unregister_net(l4proto);
-
 	pn = nf_ct_l4proto_net(net, l4proto);
 	if (pn == NULL)
 		return;
@@ -494,7 +485,7 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_pernet_unregister);
 
 int nf_conntrack_proto_pernet_init(struct net *net)
 {
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a8ae287..3850d68 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -935,32 +935,32 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 static __net_init int dccp_net_init(struct net *net)
 {
 	int ret = 0;
-	ret = nf_conntrack_l4proto_register(net,
-					    &dccp_proto4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+						   &dccp_proto4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_dccp4 :protocol register failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &dccp_proto6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+						   &dccp_proto6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_dccp6 :protocol register failed.\n");
 		goto cleanup_dccp4;
 	}
 	return 0;
 cleanup_dccp4:
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto4);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					       &dccp_proto4);
 out:
 	return ret;
 }
 
 static __net_exit void dccp_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto6);
-	nf_conntrack_l4proto_unregister(net,
-					&dccp_proto4);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					       &dccp_proto6);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					       &dccp_proto4);
 }
 
 static struct pernet_operations dccp_net_ops = {
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index b09b7af..f5f14c2 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -397,7 +397,8 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 static int proto_gre_net_init(struct net *net)
 {
 	int ret = 0;
-	ret = nf_conntrack_l4proto_register(net, &nf_conntrack_l4proto_gre4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+						&nf_conntrack_l4proto_gre4);
 	if (ret < 0)
 		pr_err("nf_conntrack_l4proto_gre4 :protocol register failed.\n");
 	return ret;
@@ -405,7 +406,8 @@ static int proto_gre_net_init(struct net *net)
 
 static void proto_gre_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_gre4);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					       &nf_conntrack_l4proto_gre4);
 	nf_ct_gre_keymap_flush(net);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c746d61..0aa91dd 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -853,14 +853,14 @@ static int sctp_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_sctp4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+						&nf_conntrack_l4proto_sctp4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_sctp4 :protocol register failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_sctp6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+						&nf_conntrack_l4proto_sctp6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_sctp6 :protocol register failed.\n");
 		goto cleanup_sctp4;
@@ -868,7 +868,7 @@ static int sctp_net_init(struct net *net)
 	return 0;
 
 cleanup_sctp4:
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_sctp4);
 out:
 	return ret;
@@ -876,9 +876,9 @@ out:
 
 static void sctp_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_sctp6);
-	nf_conntrack_l4proto_unregister(net,
+	nf_conntrack_l4proto_pernet_unregister(net,
 					&nf_conntrack_l4proto_sctp4);
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4b66df2..56e53c0 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -336,14 +336,14 @@ static int udplite_net_init(struct net *net)
 {
 	int ret = 0;
 
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udplite4);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_udplite4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
 		goto out;
 	}
-	ret = nf_conntrack_l4proto_register(net,
-					    &nf_conntrack_l4proto_udplite6);
+	ret = nf_conntrack_l4proto_pernet_register(net,
+					&nf_conntrack_l4proto_udplite6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
 		goto cleanup_udplite4;
@@ -351,15 +351,18 @@ static int udplite_net_init(struct net *net)
 	return 0;
 
 cleanup_udplite4:
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					&nf_conntrack_l4proto_udplite4);
 out:
 	return ret;
 }
 
 static void udplite_net_exit(struct net *net)
 {
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite6);
-	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					&nf_conntrack_l4proto_udplite6);
+	nf_conntrack_l4proto_pernet_unregister(net,
+					&nf_conntrack_l4proto_udplite4);
 }
 
 static struct pernet_operations udplite_net_ops = {
-- 
1.7.11.7

