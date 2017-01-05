From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: ipt_CLUSTERIP: check duplicate config when initializing
Date: Thu,  5 Jan 2017 12:19:52 +0100
Message-ID: <1483615193-2931-6-git-send-email-pablo@netfilter.org>
References: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49678 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938504AbdAELUM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 06:20:12 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AEE335230B
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 93C22D191F
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 453709EBD7
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 12:20:06 +0100 (CET)
In-Reply-To: <1483615193-2931-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>

Now when adding an ipt_CLUSTERIP rule, it only checks duplicate config in
clusterip_config_find_get(). But after that, there may be still another
thread to insert a config with the same ip, then it leaves proc_create_data
to do duplicate check.

It's more reasonable to check duplicate config by ipt_CLUSTERIP itself,
instead of checking it by proc fs duplicate file check. Before, when proc
fs allowed duplicate name files in a directory, It could even crash kernel
because of use-after-free.

This patch is to check duplicate config under the protection of clusterip
net lock when initializing a new config and correct the return err.

Note that it also moves proc file node creation after adding new config, as
proc_create_data may sleep, it couldn't be called under the clusterip_net
lock. clusterip_config_find_get returns NULL if c->pde is null to make sure
it can't be used until the proc file node creation is done.

Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 21db00d0362b..a6b8c1a4102b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -144,7 +144,7 @@ clusterip_config_find_get(struct net *net, __be32 clusterip, int entry)
 	rcu_read_lock_bh();
 	c = __clusterip_config_find(net, clusterip);
 	if (c) {
-		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
+		if (!c->pde || unlikely(!atomic_inc_not_zero(&c->refcount)))
 			c = NULL;
 		else if (entry)
 			atomic_inc(&c->entries);
@@ -166,14 +166,15 @@ clusterip_config_init_nodelist(struct clusterip_config *c,
 
 static struct clusterip_config *
 clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
-			struct net_device *dev)
+		      struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
 	struct clusterip_config *c;
-	struct clusterip_net *cn = net_generic(dev_net(dev), clusterip_net_id);
+	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 
 	c = kzalloc(sizeof(*c), GFP_ATOMIC);
 	if (!c)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	c->dev = dev;
 	c->clusterip = ip;
@@ -185,6 +186,17 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 	atomic_set(&c->refcount, 1);
 	atomic_set(&c->entries, 1);
 
+	spin_lock_bh(&cn->lock);
+	if (__clusterip_config_find(net, ip)) {
+		spin_unlock_bh(&cn->lock);
+		kfree(c);
+
+		return ERR_PTR(-EBUSY);
+	}
+
+	list_add_rcu(&c->list, &cn->configs);
+	spin_unlock_bh(&cn->lock);
+
 #ifdef CONFIG_PROC_FS
 	{
 		char buffer[16];
@@ -195,16 +207,16 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 					  cn->procdir,
 					  &clusterip_proc_fops, c);
 		if (!c->pde) {
+			spin_lock_bh(&cn->lock);
+			list_del_rcu(&c->list);
+			spin_unlock_bh(&cn->lock);
 			kfree(c);
-			return NULL;
+
+			return ERR_PTR(-ENOMEM);
 		}
 	}
 #endif
 
-	spin_lock_bh(&cn->lock);
-	list_add_rcu(&c->list, &cn->configs);
-	spin_unlock_bh(&cn->lock);
-
 	return c;
 }
 
@@ -410,9 +422,9 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 
 			config = clusterip_config_init(cipinfo,
 							e->ip.dst.s_addr, dev);
-			if (!config) {
+			if (IS_ERR(config)) {
 				dev_put(dev);
-				return -ENOMEM;
+				return PTR_ERR(config);
 			}
 			dev_mc_add(config->dev, config->clustermac);
 		}
-- 
2.1.4
