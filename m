From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 3/9] netns: ipmr: store netns in struct mfc_cache
Date: Thu, 22 Jan 2009 15:56:17 +0100
Message-ID: <20090122145615.536663595@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58791 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526AbZAVO5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch stores into struct mfc_cache the network namespace each
mfc_cache belongs to. The new member is mfc_net.

mfc_net is assigned at cache allocation and doesn't change during
the rest of the cache entry life.
A new net parameter is added to ipmr_cache_alloc/ipmr_cache_alloc_unres.

This will help to retrieve the current netns around the IPv4 multicast
routing code.

At the moment, all mfc_cache are allocated in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/linux/mroute.h |   15 +++++++++++++++
 net/ipv4/ipmr.c        |   26 +++++++++++++++++---------
 2 files changed, 32 insertions(+), 9 deletions(-)

Index: net-next-2.6/include/linux/mroute.h
===================================================================
--- net-next-2.6.orig/include/linux/mroute.h
+++ net-next-2.6/include/linux/mroute.h
@@ -193,6 +193,9 @@ struct vif_device
 struct mfc_cache 
 {
 	struct mfc_cache *next;			/* Next entry on cache line 	*/
+#ifdef CONFIG_NET_NS
+	struct net *mfc_net;
+#endif
 	__be32 mfc_mcastgrp;			/* Group the entry belongs to 	*/
 	__be32 mfc_origin;			/* Source of packet 		*/
 	vifi_t mfc_parent;			/* Source interface		*/
@@ -215,6 +218,18 @@ struct mfc_cache 
 	} mfc_un;
 };
 
+static inline
+struct net *mfc_net(const struct mfc_cache *mfc)
+{
+	return read_pnet(&mfc->mfc_net);
+}
+
+static inline
+void mfc_net_set(struct mfc_cache *mfc, struct net *net)
+{
+	write_pnet(&mfc->mfc_net, hold_net(net));
+}
+
 #define MFC_STATIC		1
 #define MFC_NOTIFY		2
 
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -327,6 +327,12 @@ static int vif_delete(int vifi, int noti
 	return 0;
 }
 
+static inline void ipmr_cache_free(struct mfc_cache *c)
+{
+	release_net(mfc_net(c));
+	kmem_cache_free(mrt_cachep, c);
+}
+
 /* Destroy an unresolved cache entry, killing queued skbs
    and reporting error to netlink readers.
  */
@@ -353,7 +359,7 @@ static void ipmr_destroy_unres(struct mf
 			kfree_skb(skb);
 	}
 
-	kmem_cache_free(mrt_cachep, c);
+	ipmr_cache_free(c);
 }
 
 
@@ -528,22 +534,24 @@ static struct mfc_cache *ipmr_cache_find
 /*
  *	Allocate a multicast cache entry
  */
-static struct mfc_cache *ipmr_cache_alloc(void)
+static struct mfc_cache *ipmr_cache_alloc(struct net *net)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 	if (c == NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXVIFS;
+	mfc_net_set(c, net);
 	return c;
 }
 
-static struct mfc_cache *ipmr_cache_alloc_unres(void)
+static struct mfc_cache *ipmr_cache_alloc_unres(struct net *net)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
 	if (c == NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10*HZ;
+	mfc_net_set(c, net);
 	return c;
 }
 
@@ -695,7 +703,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 		 */
 
 		if (atomic_read(&cache_resolve_queue_len) >= 10 ||
-		    (c=ipmr_cache_alloc_unres())==NULL) {
+		    (c = ipmr_cache_alloc_unres(&init_net)) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
 			kfree_skb(skb);
@@ -718,7 +726,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 			 */
 			spin_unlock_bh(&mfc_unres_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ipmr_cache_free(c);
 			kfree_skb(skb);
 			return err;
 		}
@@ -763,7 +771,7 @@ static int ipmr_mfc_delete(struct mfcctl
 			*cp = c->next;
 			write_unlock_bh(&mrt_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ipmr_cache_free(c);
 			return 0;
 		}
 	}
@@ -796,7 +804,7 @@ static int ipmr_mfc_add(struct mfcctl *m
 	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
-	c = ipmr_cache_alloc();
+	c = ipmr_cache_alloc(&init_net);
 	if (c == NULL)
 		return -ENOMEM;
 
@@ -831,7 +839,7 @@ static int ipmr_mfc_add(struct mfcctl *m
 
 	if (uc) {
 		ipmr_cache_resolve(uc, c);
-		kmem_cache_free(mrt_cachep, uc);
+		ipmr_cache_free(uc);
 	}
 	return 0;
 }
@@ -868,7 +876,7 @@ static void mroute_clean_tables(struct s
 			*cp = c->next;
 			write_unlock_bh(&mrt_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ipmr_cache_free(c);
 		}
 	}
 

