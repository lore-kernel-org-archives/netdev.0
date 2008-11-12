From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Cleanup of neighbour code
Date: Wed, 12 Nov 2008 07:31:58 +0100
Message-ID: <491A785E.5060903@cosmosbay.com>
References: <20081110.164424.167225199.davem@davemloft.net>	<20081111110847.GC3665@x200.localdomain>	<20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net> <491A75BE.1010907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080106000904050804010908"
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37232 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYKLGcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 01:32:07 -0500
In-Reply-To: <491A75BE.1010907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080106000904050804010908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Using read_pnet() and write_pnet() in neighbour code ease the reading of code.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/neighbour.h |   12 ++----------
 net/core/neighbour.c    |   12 +++---------
 2 files changed, 5 insertions(+), 19 deletions(-)


--------------080106000904050804010908
Content-Type: text/plain;
 name="neigh.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="neigh.patch"

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 365b5e2..d8d790e 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -220,11 +220,7 @@ extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *p
 static inline
 struct net			*neigh_parms_net(const struct neigh_parms *parms)
 {
-#ifdef CONFIG_NET_NS
-	return parms->net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&parms->net);
 }
 
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
@@ -241,11 +237,7 @@ extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void
 static inline
 struct net			*pneigh_net(const struct pneigh_entry *pneigh)
 {
-#ifdef CONFIG_NET_NS
-	return pneigh->net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&pneigh->net);
 }
 
 extern void neigh_app_ns(struct neighbour *n);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 500c243..cca6a55 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -531,9 +531,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
-#ifdef CONFIG_NET_NS
-	n->net = hold_net(net);
-#endif
+	write_pnet(&n->net, hold_net(net));
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -1350,9 +1348,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 
 		dev_hold(dev);
 		p->dev = dev;
-#ifdef CONFIG_NET_NS
-		p->net = hold_net(net);
-#endif
+		write_pnet(&p->net, hold_net(net));
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
@@ -1407,9 +1403,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	unsigned long now = jiffies;
 	unsigned long phsize;
 
-#ifdef CONFIG_NET_NS
-	tbl->parms.net = &init_net;
-#endif
+	write_pnet(&tbl->parms.net, &init_net);
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);

--------------080106000904050804010908--
