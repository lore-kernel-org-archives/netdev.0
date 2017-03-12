From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 22/27] afnetns: track owning namespace for inet_bind
Date: Mon, 13 Mar 2017 00:01:46 +0100
Message-ID: <20170312230151.5185-23-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57761 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935572AbdCLXCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:21 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 3A56520753
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:14 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 8C120240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:13 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order for a newly created afnetns to allow its processes to bind to
ports lower than 1024 we need to track the to be created user namespace
to check for the permissions for binding so.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/afnetns.h    |  7 +++++--
 kernel/nsproxy.c         |  2 +-
 net/core/afnetns.c       | 18 ++++++++++++------
 net/core/net_namespace.c |  2 +-
 4 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/net/afnetns.h b/include/net/afnetns.h
index 9039086717c356..9db49551fff714 100644
--- a/include/net/afnetns.h
+++ b/include/net/afnetns.h
@@ -8,6 +8,7 @@
 struct afnetns {
 #if IS_ENABLED(CONFIG_AFNETNS)
 	refcount_t ref;
+	struct user_namespace *user_ns;
 	struct ns_common ns;
 	struct net *net;
 #endif
@@ -17,8 +18,10 @@ extern struct afnetns init_afnetns;
 
 int afnet_ns_init(void);
 
-struct afnetns *afnetns_new(struct net *net);
-struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old);
+struct afnetns *afnetns_new(struct net *net, struct user_namespace *user_ns);
+struct afnetns *copy_afnet_ns(unsigned long flags,
+			      struct user_namespace *user_ns,
+			      struct nsproxy *old);
 struct afnetns *afnetns_get_by_fd(int fd);
 unsigned int afnetns_to_inode(struct afnetns *afnetns);
 void afnetns_free(struct afnetns *afnetns);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f99ecbdd506137..90462012aecf78 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -114,7 +114,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	}
 
 #if IS_ENABLED(CONFIG_AFNETNS)
-	new_nsp->afnet_ns = copy_afnet_ns(flags, tsk->nsproxy);
+	new_nsp->afnet_ns = copy_afnet_ns(flags, user_ns, tsk->nsproxy);
 	if (IS_ERR(new_nsp->afnet_ns)) {
 		err = PTR_ERR(new_nsp->afnet_ns);
 		goto out_afnet;
diff --git a/net/core/afnetns.c b/net/core/afnetns.c
index b96c25b5ebe30d..69d776564c69be 100644
--- a/net/core/afnetns.c
+++ b/net/core/afnetns.c
@@ -5,6 +5,7 @@
 #include <linux/file.h>
 #include <linux/nsproxy.h>
 #include <linux/proc_ns.h>
+#include <linux/user_namespace.h>
 
 const struct proc_ns_operations afnetns_operations;
 
@@ -17,7 +18,8 @@ static struct afnetns *ns_to_afnet(struct ns_common *ns)
 	return container_of(ns, struct afnetns, ns);
 }
 
-static int afnet_setup(struct afnetns *afnetns, struct net *net)
+static int afnet_setup(struct afnetns *afnetns, struct net *net,
+		       struct user_namespace *user_ns)
 {
 	int err;
 
@@ -28,11 +30,12 @@ static int afnet_setup(struct afnetns *afnetns, struct net *net)
 
 	refcount_set(&afnetns->ref, 1);
 	afnetns->net = get_net(net);
+	afnetns->user_ns = get_user_ns(user_ns);
 
 	return err;
 }
 
-struct afnetns *afnetns_new(struct net *net)
+struct afnetns *afnetns_new(struct net *net, struct user_namespace *user_ns)
 {
 	int err;
 	struct afnetns *afnetns;
@@ -41,7 +44,7 @@ struct afnetns *afnetns_new(struct net *net)
 	if (!afnetns)
 		return ERR_PTR(-ENOMEM);
 
-	err = afnet_setup(afnetns, net);
+	err = afnet_setup(afnetns, net, user_ns);
 	if (err) {
 		kfree(afnetns);
 		return ERR_PTR(err);
@@ -54,6 +57,7 @@ void afnetns_free(struct afnetns *afnetns)
 {
 	ns_free_inum(&afnetns->ns);
 	put_net(afnetns->net);
+	put_user_ns(afnetns->user_ns);
 	kfree(afnetns);
 }
 EXPORT_SYMBOL(afnetns_free);
@@ -85,7 +89,9 @@ unsigned int afnetns_to_inode(struct afnetns *afnetns)
 }
 EXPORT_SYMBOL(afnetns_to_inode);
 
-struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old)
+struct afnetns *copy_afnet_ns(unsigned long flags,
+			      struct user_namespace *user_ns,
+			      struct nsproxy *old)
 {
 	if (flags & CLONE_NEWNET)
 		return afnetns_get(old->net_ns->afnet_ns);
@@ -93,7 +99,7 @@ struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old)
 	if (!(flags & CLONE_NEWAFNET))
 		return afnetns_get(old->afnet_ns);
 
-	return afnetns_new(old->net_ns);
+	return afnetns_new(old->net_ns, user_ns);
 }
 
 static struct ns_common *afnet_get(struct task_struct *task)
@@ -144,7 +150,7 @@ int __init afnet_ns_init(void)
 {
 	int err;
 
-	err = afnet_setup(&init_afnetns, &init_net);
+	err = afnet_setup(&init_afnetns, &init_net, &init_user_ns);
 	if (err)
 		return err;
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1b11883d8cdbbd..6bb1c87e72dcc0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -287,7 +287,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 
 #if IS_ENABLED(CONFIG_AFNETNS)
 	if (likely(!net_eq(&init_net, net))) {
-		net->afnet_ns = afnetns_new(net);
+		net->afnet_ns = afnetns_new(net, user_ns);
 		if (IS_ERR(net->afnet_ns)) {
 			error = PTR_ERR(net->afnet_ns);
 			goto out;
-- 
2.9.3
