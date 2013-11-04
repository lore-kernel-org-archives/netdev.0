From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/20] netfilter: ipt_CLUSTERIP: make clusterip_list per net namespace
Date: Mon,  4 Nov 2013 22:50:28 +0100
Message-ID: <1383601842-4570-7-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

clusterip_configs should be per net namespace, so operate
cluster in one net namespace won't affect other net
namespace. right now, only allow to operate the clusterip_configs
of init net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index e66b91b..8ef3e6f 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -58,8 +58,6 @@ struct clusterip_config {
 	struct rcu_head rcu;
 };
 
-static LIST_HEAD(clusterip_configs);
-
 /* clusterip_lock protects the clusterip_configs list */
 static DEFINE_SPINLOCK(clusterip_lock);
 
@@ -70,6 +68,7 @@ static const struct file_operations clusterip_proc_fops;
 static int clusterip_net_id __read_mostly;
 
 struct clusterip_net {
+	struct list_head configs;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *procdir;
 #endif
@@ -124,8 +123,9 @@ static struct clusterip_config *
 __clusterip_config_find(__be32 clusterip)
 {
 	struct clusterip_config *c;
+	struct clusterip_net *cn = net_generic(&init_net, clusterip_net_id);
 
-	list_for_each_entry_rcu(c, &clusterip_configs, list) {
+	list_for_each_entry_rcu(c, &cn->configs, list) {
 		if (c->clusterip == clusterip)
 			return c;
 	}
@@ -199,7 +199,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 #endif
 
 	spin_lock_bh(&clusterip_lock);
-	list_add_rcu(&c->list, &clusterip_configs);
+	list_add_rcu(&c->list, &cn->configs);
 	spin_unlock_bh(&clusterip_lock);
 
 	return c;
@@ -709,9 +709,11 @@ static const struct file_operations clusterip_proc_fops = {
 
 static int clusterip_net_init(struct net *net)
 {
-#ifdef CONFIG_PROC_FS
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 
+	INIT_LIST_HEAD(&cn->configs);
+
+#ifdef CONFIG_PROC_FS
 	cn->procdir = proc_mkdir("ipt_CLUSTERIP", net->proc_net);
 	if (!cn->procdir) {
 		pr_err("Unable to proc dir entry\n");
-- 
1.7.10.4

