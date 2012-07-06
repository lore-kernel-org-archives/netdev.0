From: pablo@netfilter.org
Subject: [PATCH 05/18] netfilter: nf_conntrack: use l4proto->users as refcount for per-net data
Date: Fri,  6 Jul 2012 13:16:55 +0200
Message-ID: <1341573428-3204-6-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Currently, nf_proto_net's l4proto->users meaning is quite confusing
since it depends on the compilation tweaks.

To resolve this, we cleanup this code to regard it as the refcount
for l4proto's per-net data, since there may be two l4protos use the
same per-net data.

Thus, we increment pn->users when nf_conntrack_l4proto_register
successfully, and decrement it for nf_conntrack_l4_unregister case.

The users refcnt is not required form layer 3 protocol trackers.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c |   76 ++++++++++++++++++++++--------------
 1 file changed, 46 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 9d6b6ab..63612e6 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -39,16 +39,13 @@ static int
 nf_ct_register_sysctl(struct net *net,
 		      struct ctl_table_header **header,
 		      const char *path,
-		      struct ctl_table *table,
-		      unsigned int *users)
+		      struct ctl_table *table)
 {
 	if (*header == NULL) {
 		*header = register_net_sysctl(net, path, table);
 		if (*header == NULL)
 			return -ENOMEM;
 	}
-	if (users != NULL)
-		(*users)++;
 
 	return 0;
 }
@@ -56,9 +53,9 @@ nf_ct_register_sysctl(struct net *net,
 static void
 nf_ct_unregister_sysctl(struct ctl_table_header **header,
 			struct ctl_table **table,
-			unsigned int *users)
+			unsigned int users)
 {
-	if (users != NULL && --*users > 0)
+	if (users > 0)
 		return;
 
 	unregister_net_sysctl_table(*header);
@@ -191,8 +188,7 @@ static int nf_ct_l3proto_register_sysctl(struct net *net,
 		err = nf_ct_register_sysctl(net,
 					    &in->ctl_table_header,
 					    l3proto->ctl_table_path,
-					    in->ctl_table,
-					    NULL);
+					    in->ctl_table);
 		if (err < 0) {
 			kfree(in->ctl_table);
 			in->ctl_table = NULL;
@@ -213,7 +209,7 @@ static void nf_ct_l3proto_unregister_sysctl(struct net *net,
 	if (in->ctl_table_header != NULL)
 		nf_ct_unregister_sysctl(&in->ctl_table_header,
 					&in->ctl_table,
-					NULL);
+					0);
 #endif
 }
 
@@ -329,20 +325,17 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 
 static
 int nf_ct_l4proto_register_sysctl(struct net *net,
+				  struct nf_proto_net *pn,
 				  struct nf_conntrack_l4proto *l4proto)
 {
 	int err = 0;
-	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
-	if (pn == NULL)
-		return 0;
 
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table != NULL) {
 		err = nf_ct_register_sysctl(net,
 					    &pn->ctl_table_header,
 					    "net/netfilter",
-					    pn->ctl_table,
-					    &pn->users);
+					    pn->ctl_table);
 		if (err < 0) {
 			if (!pn->users) {
 				kfree(pn->ctl_table);
@@ -356,15 +349,14 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 		err = nf_ct_register_sysctl(net,
 					    &pn->ctl_compat_header,
 					    "net/ipv4/netfilter",
-					    pn->ctl_compat_table,
-					    NULL);
+					    pn->ctl_compat_table);
 		if (err == 0)
 			goto out;
 
 		nf_ct_kfree_compat_sysctl_table(pn);
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
-					&pn->users);
+					pn->users);
 	}
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 out:
@@ -374,25 +366,21 @@ out:
 
 static
 void nf_ct_l4proto_unregister_sysctl(struct net *net,
+				     struct nf_proto_net *pn,
 				     struct nf_conntrack_l4proto *l4proto)
 {
-	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
-	if (pn == NULL)
-		return;
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table_header != NULL)
 		nf_ct_unregister_sysctl(&pn->ctl_table_header,
 					&pn->ctl_table,
-					&pn->users);
+					pn->users);
 
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_header != NULL)
 		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
 					&pn->ctl_compat_table,
-					NULL);
+					0);
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
-#else
-	pn->users--;
 #endif /* CONFIG_SYSCTL */
 }
 
@@ -458,23 +446,32 @@ int nf_conntrack_l4proto_register(struct net *net,
 				  struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
+	struct nf_proto_net *pn = NULL;
 
 	if (l4proto->init_net) {
 		ret = l4proto->init_net(net, l4proto->l3proto);
 		if (ret < 0)
-			return ret;
+			goto out;
 	}
 
-	ret = nf_ct_l4proto_register_sysctl(net, l4proto);
+	pn = nf_ct_l4proto_net(net, l4proto);
+	if (pn == NULL)
+		goto out;
+
+	ret = nf_ct_l4proto_register_sysctl(net, pn, l4proto);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	if (net == &init_net) {
 		ret = nf_conntrack_l4proto_register_net(l4proto);
-		if (ret < 0)
-			nf_ct_l4proto_unregister_sysctl(net, l4proto);
+		if (ret < 0) {
+			nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
+			goto out;
+		}
 	}
 
+	pn->users++;
+out:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
@@ -499,10 +496,18 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
 void nf_conntrack_l4proto_unregister(struct net *net,
 				     struct nf_conntrack_l4proto *l4proto)
 {
+	struct nf_proto_net *pn = NULL;
+
 	if (net == &init_net)
 		nf_conntrack_l4proto_unregister_net(l4proto);
 
-	nf_ct_l4proto_unregister_sysctl(net, l4proto);
+	pn = nf_ct_l4proto_net(net, l4proto);
+	if (pn == NULL)
+		return;
+
+	pn->users--;
+	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
+
 	/* Remove all contrack entries for this protocol */
 	rtnl_lock();
 	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
@@ -514,11 +519,15 @@ int nf_conntrack_proto_init(struct net *net)
 {
 	unsigned int i;
 	int err;
+	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
+					&nf_conntrack_l4proto_generic);
+
 	err = nf_conntrack_l4proto_generic.init_net(net,
 					nf_conntrack_l4proto_generic.l3proto);
 	if (err < 0)
 		return err;
 	err = nf_ct_l4proto_register_sysctl(net,
+					    pn,
 					    &nf_conntrack_l4proto_generic);
 	if (err < 0)
 		return err;
@@ -528,13 +537,20 @@ int nf_conntrack_proto_init(struct net *net)
 			rcu_assign_pointer(nf_ct_l3protos[i],
 					   &nf_conntrack_l3proto_generic);
 	}
+
+	pn->users++;
 	return 0;
 }
 
 void nf_conntrack_proto_fini(struct net *net)
 {
 	unsigned int i;
+	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
+					&nf_conntrack_l4proto_generic);
+
+	pn->users--;
 	nf_ct_l4proto_unregister_sysctl(net,
+					pn,
 					&nf_conntrack_l4proto_generic);
 	if (net == &init_net) {
 		/* free l3proto protocol tables */
-- 
1.7.10

