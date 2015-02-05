From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 10/29] net: Flip neigh structs to net_ctx
Date: Wed,  4 Feb 2015 18:34:11 -0700
Message-ID: <1423100070-31848-11-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:62905 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbbBEBgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:02 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so39057602igb.2
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:01 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/neighbour.h | 44 ++++++++++++++++++++++++++++++++++++--------
 net/core/neighbour.c    |  6 +++---
 2 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 76f708486aae..6228edd1e483 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -65,9 +65,7 @@ enum {
 };
 
 struct neigh_parms {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
+	struct net_ctx net_ctx;
 	struct net_device *dev;
 	struct list_head list;
 	int	(*neigh_setup)(struct neighbour *);
@@ -167,9 +165,7 @@ struct neigh_ops {
 
 struct pneigh_entry {
 	struct pneigh_entry	*next;
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	struct net_ctx		net_ctx;
 	struct net_device	*dev;
 	u8			flags;
 	u8			key[0];
@@ -281,9 +277,22 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
 static inline
 struct net *neigh_parms_net(const struct neigh_parms *parms)
 {
-	return read_pnet(&parms->net);
+	return read_pnet(&parms->net_ctx.net);
 }
 
+static inline
+int neigh_parms_net_ctx_eq(const struct neigh_parms *parms,
+			   const struct net_ctx *net_ctx)
+{
+#ifdef CONFIG_NET_NS
+	if (net_eq(neigh_parms_net(parms), net_ctx->net))
+		return 1;
+
+	return 0;
+#else
+	return 1;
+#endif
+}
 unsigned long neigh_rand_reach_time(unsigned long base);
 
 void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
@@ -298,7 +307,26 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key,
 
 static inline struct net *pneigh_net(const struct pneigh_entry *pneigh)
 {
-	return read_pnet(&pneigh->net);
+	return read_pnet(&pneigh->net_ctx.net);
+}
+static inline
+void pneigh_net_ctx_set(struct pneigh_entry *pneigh,
+			const struct net_ctx *net_ctx)
+{
+	write_pnet(&pneigh->net_ctx.net, hold_net(net_ctx->net));
+}
+static inline
+int pneigh_net_ctx_eq(const struct pneigh_entry *pneigh,
+		      const struct net_ctx *net_ctx)
+{
+#ifdef CONFIG_NET_NS
+	if (net_eq(pneigh_net(pneigh), net_ctx->net))
+		return 1;
+
+	return 0;
+#else
+	return 1;
+#endif
 }
 
 void neigh_app_ns(struct neighbour *n);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 70fe9e10ac86..bd77804849cc 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -601,7 +601,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
-	write_pnet(&n->net, hold_net(net));
+	write_pnet(&n->net_ctx.net, hold_net(net));
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -1464,7 +1464,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 		dev_hold(dev);
 		p->dev = dev;
-		write_pnet(&p->net, hold_net(net));
+		write_pnet(&p->net_ctx.net, hold_net(net));
 		p->sysctl_table = NULL;
 
 		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
@@ -1523,7 +1523,7 @@ void neigh_table_init(int index, struct neigh_table *tbl)
 
 	INIT_LIST_HEAD(&tbl->parms_list);
 	list_add(&tbl->parms.list, &tbl->parms_list);
-	write_pnet(&tbl->parms.net, &init_net);
+	write_pnet(&tbl->parms.net_ctx.net, &init_net);
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME));
-- 
1.9.3 (Apple Git-50)
