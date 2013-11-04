From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/20] netfilter: ipt_CLUSTERIP: add parameter net in clusterip_config_find_get
Date: Mon,  4 Nov 2013 22:50:30 +0100
Message-ID: <1383601842-4570-9-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55679 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505Ab3KDVu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:50:57 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Inorder to find clusterip_config in net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1bf5aa30..b7fc9d5 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -122,10 +122,10 @@ clusterip_config_entry_put(struct clusterip_config *c)
 }
 
 static struct clusterip_config *
-__clusterip_config_find(__be32 clusterip)
+__clusterip_config_find(struct net *net, __be32 clusterip)
 {
 	struct clusterip_config *c;
-	struct clusterip_net *cn = net_generic(&init_net, clusterip_net_id);
+	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 
 	list_for_each_entry_rcu(c, &cn->configs, list) {
 		if (c->clusterip == clusterip)
@@ -136,12 +136,12 @@ __clusterip_config_find(__be32 clusterip)
 }
 
 static inline struct clusterip_config *
-clusterip_config_find_get(__be32 clusterip, int entry)
+clusterip_config_find_get(struct net *net, __be32 clusterip, int entry)
 {
 	struct clusterip_config *c;
 
 	rcu_read_lock_bh();
-	c = __clusterip_config_find(clusterip);
+	c = __clusterip_config_find(net, clusterip);
 	if (c) {
 		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
 			c = NULL;
@@ -381,7 +381,7 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 
 	/* FIXME: further sanity checks */
 
-	config = clusterip_config_find_get(e->ip.dst.s_addr, 1);
+	config = clusterip_config_find_get(&init_net, e->ip.dst.s_addr, 1);
 	if (!config) {
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
 			pr_info("no config found for %pI4, need 'new'\n",
@@ -519,7 +519,7 @@ arp_mangle(unsigned int hook,
 
 	/* if there is no clusterip configuration for the arp reply's
 	 * source ip, we don't want to mangle it */
-	c = clusterip_config_find_get(payload->src_ip, 0);
+	c = clusterip_config_find_get(&init_net, payload->src_ip, 0);
 	if (!c)
 		return NF_ACCEPT;
 
-- 
1.7.10.4
