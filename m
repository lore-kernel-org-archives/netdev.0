From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 5/8] netns: ip6mr: store netns in struct mfc6_cache
Date: Mon, 08 Dec 2008 17:02:01 +0100
Message-ID: <20081208160157.565735916@localhost.localdomain>
References: <20081208160156.343758157@localhost.localdomain>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35092 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbYLHQDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:03:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch stores into struct mfc6_cache the network namespace each
mfc6_cache belongs to. The new member is mfc6_net.

mfc6_net is assigned at cache allocation and doesn't change during
the rest of the cache entry life.

This will help to retrieve the current netns around the IPv6 multicast
forwarding code.

At the moment, all mfc6_cache are allocated in init_net.

Changelog:
==========
* Use write_pnet()/read_pnet() to set and get mfc6_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/linux/mroute6.h |   15 +++++++++++++++
 net/ipv6/ip6mr.c        |   28 +++++++++++++++++++---------
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 2cd9901..15d85fe 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -188,6 +188,9 @@ struct mif_device
 struct mfc6_cache
 {
 	struct mfc6_cache *next;		/* Next entry on cache line 	*/
+#ifdef CONFIG_NET_NS
+	struct net *mfc6_net;
+#endif
 	struct in6_addr mf6c_mcastgrp;			/* Group the entry belongs to 	*/
 	struct in6_addr mf6c_origin;			/* Source of packet 		*/
 	mifi_t mf6c_parent;			/* Source interface		*/
@@ -210,6 +213,18 @@ struct mfc6_cache
 	} mfc_un;
 };
 
+static inline
+struct net *mfc6_net(const struct mfc6_cache *mfc)
+{
+	return read_pnet(&mfc->mfc6_net);
+}
+
+static inline
+void mfc6_net_set(struct mfc6_cache *mfc, struct net *net)
+{
+	write_pnet(&mfc->mfc6_net, hold_net(net));
+}
+
 #define MFC_STATIC		1
 #define MFC_NOTIFY		2
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 94a3133..1583202 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -498,6 +498,14 @@ static int mif6_delete(int vifi)
 	return 0;
 }
 
+static inline void ip6mr_cache_free(struct mfc6_cache *c)
+{
+#ifdef CONFIG_NET_NS
+	release_net(c->mfc6_net);
+#endif
+	kmem_cache_free(mrt_cachep, c);
+}
+
 /* Destroy an unresolved cache entry, killing queued skbs
    and reporting error to netlink readers.
  */
@@ -520,7 +528,7 @@ static void ip6mr_destroy_unres(struct mfc6_cache *c)
 			kfree_skb(skb);
 	}
 
-	kmem_cache_free(mrt_cachep, c);
+	ip6mr_cache_free(c);
 }
 
 
@@ -677,22 +685,24 @@ static struct mfc6_cache *ip6mr_cache_find(struct in6_addr *origin, struct in6_a
 /*
  *	Allocate a multicast cache entry
  */
-static struct mfc6_cache *ip6mr_cache_alloc(void)
+static struct mfc6_cache *ip6mr_cache_alloc(struct net *net)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 	if (c == NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXMIFS;
+	mfc6_net_set(c, net);
 	return c;
 }
 
-static struct mfc6_cache *ip6mr_cache_alloc_unres(void)
+static struct mfc6_cache *ip6mr_cache_alloc_unres(struct net *net)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
 	if (c == NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10 * HZ;
+	mfc6_net_set(c, net);
 	return c;
 }
 
@@ -848,7 +858,7 @@ ip6mr_cache_unresolved(mifi_t mifi, struct sk_buff *skb)
 		 */
 
 		if (atomic_read(&cache_resolve_queue_len) >= 10 ||
-		    (c = ip6mr_cache_alloc_unres()) == NULL) {
+		    (c = ip6mr_cache_alloc_unres(&init_net)) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
 			kfree_skb(skb);
@@ -871,7 +881,7 @@ ip6mr_cache_unresolved(mifi_t mifi, struct sk_buff *skb)
 			 */
 			spin_unlock_bh(&mfc_unres_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ip6mr_cache_free(c);
 			kfree_skb(skb);
 			return err;
 		}
@@ -917,7 +927,7 @@ static int ip6mr_mfc_delete(struct mf6cctl *mfc)
 			*cp = c->next;
 			write_unlock_bh(&mrt_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ip6mr_cache_free(c);
 			return 0;
 		}
 	}
@@ -1081,7 +1091,7 @@ static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 	if (!ipv6_addr_is_multicast(&mfc->mf6cc_mcastgrp.sin6_addr))
 		return -EINVAL;
 
-	c = ip6mr_cache_alloc();
+	c = ip6mr_cache_alloc(&init_net);
 	if (c == NULL)
 		return -ENOMEM;
 
@@ -1116,7 +1126,7 @@ static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 
 	if (uc) {
 		ip6mr_cache_resolve(uc, c);
-		kmem_cache_free(mrt_cachep, uc);
+		ip6mr_cache_free(uc);
 	}
 	return 0;
 }
@@ -1153,7 +1163,7 @@ static void mroute_clean_tables(struct sock *sk)
 			*cp = c->next;
 			write_unlock_bh(&mrt_lock);
 
-			kmem_cache_free(mrt_cachep, c);
+			ip6mr_cache_free(c);
 		}
 	}
 

