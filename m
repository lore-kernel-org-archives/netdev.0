From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/20] netfilter: ipt_CLUSTERIP: make proc directory per net namespace
Date: Mon,  4 Nov 2013 22:50:27 +0100
Message-ID: <1383601842-4570-6-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55671 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753403Ab3KDVuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:50:55 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Create /proc/net/ipt_CLUSTERIP directory for per net namespace.
Right now,only allow to create entries under the ipt_CLUSTERIP
in init net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   70 ++++++++++++++++++++++++++----------
 1 file changed, 51 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 0b732ef..e66b91b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -28,6 +28,7 @@
 #include <linux/netfilter_ipv4/ipt_CLUSTERIP.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include <net/checksum.h>
 #include <net/ip.h>
 
@@ -64,9 +65,16 @@ static DEFINE_SPINLOCK(clusterip_lock);
 
 #ifdef CONFIG_PROC_FS
 static const struct file_operations clusterip_proc_fops;
-static struct proc_dir_entry *clusterip_procdir;
 #endif
 
+static int clusterip_net_id __read_mostly;
+
+struct clusterip_net {
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *procdir;
+#endif
+};
+
 static inline void
 clusterip_config_get(struct clusterip_config *c)
 {
@@ -158,6 +166,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 			struct net_device *dev)
 {
 	struct clusterip_config *c;
+	struct clusterip_net *cn = net_generic(&init_net, clusterip_net_id);
 
 	c = kzalloc(sizeof(*c), GFP_ATOMIC);
 	if (!c)
@@ -180,7 +189,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 		/* create proc dir entry */
 		sprintf(buffer, "%pI4", &ip);
 		c->pde = proc_create_data(buffer, S_IWUSR|S_IRUSR,
-					  clusterip_procdir,
+					  cn->procdir,
 					  &clusterip_proc_fops, c);
 		if (!c->pde) {
 			kfree(c);
@@ -698,48 +707,71 @@ static const struct file_operations clusterip_proc_fops = {
 
 #endif /* CONFIG_PROC_FS */
 
+static int clusterip_net_init(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
+
+	cn->procdir = proc_mkdir("ipt_CLUSTERIP", net->proc_net);
+	if (!cn->procdir) {
+		pr_err("Unable to proc dir entry\n");
+		return -ENOMEM;
+	}
+#endif /* CONFIG_PROC_FS */
+
+	return 0;
+}
+
+static void clusterip_net_exit(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
+	proc_remove(cn->procdir);
+#endif
+}
+
+static struct pernet_operations clusterip_net_ops = {
+	.init = clusterip_net_init,
+	.exit = clusterip_net_exit,
+	.id   = &clusterip_net_id,
+	.size = sizeof(struct clusterip_net),
+};
+
 static int __init clusterip_tg_init(void)
 {
 	int ret;
 
-	ret = xt_register_target(&clusterip_tg_reg);
+	ret = register_pernet_subsys(&clusterip_net_ops);
 	if (ret < 0)
 		return ret;
 
+	ret = xt_register_target(&clusterip_tg_reg);
+	if (ret < 0)
+		goto cleanup_subsys;
+
 	ret = nf_register_hook(&cip_arp_ops);
 	if (ret < 0)
 		goto cleanup_target;
 
-#ifdef CONFIG_PROC_FS
-	clusterip_procdir = proc_mkdir("ipt_CLUSTERIP", init_net.proc_net);
-	if (!clusterip_procdir) {
-		pr_err("Unable to proc dir entry\n");
-		ret = -ENOMEM;
-		goto cleanup_hook;
-	}
-#endif /* CONFIG_PROC_FS */
-
 	pr_info("ClusterIP Version %s loaded successfully\n",
 		CLUSTERIP_VERSION);
+
 	return 0;
 
-#ifdef CONFIG_PROC_FS
-cleanup_hook:
-	nf_unregister_hook(&cip_arp_ops);
-#endif /* CONFIG_PROC_FS */
 cleanup_target:
 	xt_unregister_target(&clusterip_tg_reg);
+cleanup_subsys:
+	unregister_pernet_subsys(&clusterip_net_ops);
 	return ret;
 }
 
 static void __exit clusterip_tg_exit(void)
 {
 	pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
-#ifdef CONFIG_PROC_FS
-	proc_remove(clusterip_procdir);
-#endif
+
 	nf_unregister_hook(&cip_arp_ops);
 	xt_unregister_target(&clusterip_tg_reg);
+	unregister_pernet_subsys(&clusterip_net_ops);
 
 	/* Wait for completion of call_rcu_bh()'s (clusterip_config_rcu_free) */
 	rcu_barrier_bh();
-- 
1.7.10.4
