From: kaber@trash.net
Subject: [RFC PATCH 6/9] ipv4: ipmr: remove net pointer from struct mfc_cache
Date: Sun, 11 Apr 2010 19:37:12 +0200
Message-ID: <1271007435-20035-7-git-send-email-kaber@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37504 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab0DKRhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:22 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id 80577B2C4D
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:20 +0200 (MEST)
In-Reply-To: <1271007435-20035-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Now that cache entries in unres_queue don't need to be distinguished by their
network namespace pointer anymore, we can remove it from struct mfc_cache
add pass the namespace as function argument to the functions that need it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/mroute.h |   15 -----------
 net/ipv4/ipmr.c        |   65 +++++++++++++++++++++++------------------------
 2 files changed, 32 insertions(+), 48 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index c5f3d53..de7780a 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -192,9 +192,6 @@ struct vif_device {
 
 struct mfc_cache {
 	struct mfc_cache *next;			/* Next entry on cache line 	*/
-#ifdef CONFIG_NET_NS
-	struct net *mfc_net;
-#endif
 	__be32 mfc_mcastgrp;			/* Group the entry belongs to 	*/
 	__be32 mfc_origin;			/* Source of packet 		*/
 	vifi_t mfc_parent;			/* Source interface		*/
@@ -217,18 +214,6 @@ struct mfc_cache {
 	} mfc_un;
 };
 
-static inline
-struct net *mfc_net(const struct mfc_cache *mfc)
-{
-	return read_pnet(&mfc->mfc_net);
-}
-
-static inline
-void mfc_net_set(struct mfc_cache *mfc, struct net *net)
-{
-	write_pnet(&mfc->mfc_net, hold_net(net));
-}
-
 #define MFC_STATIC		1
 #define MFC_NOTIFY		2
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 4f30bd9..d7250e2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -92,10 +92,12 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 
 static struct kmem_cache *mrt_cachep __read_mostly;
 
-static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local);
+static int ip_mr_forward(struct net *net, struct sk_buff *skb,
+			 struct mfc_cache *cache, int local);
 static int ipmr_cache_report(struct net *net,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
-static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
+static int ipmr_fill_mroute(struct net *net, struct sk_buff *skb,
+			    struct mfc_cache *c, struct rtmsg *rtm);
 
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
 
@@ -324,7 +326,6 @@ static int vif_delete(struct net *net, int vifi, int notify,
 
 static inline void ipmr_cache_free(struct mfc_cache *c)
 {
-	release_net(mfc_net(c));
 	kmem_cache_free(mrt_cachep, c);
 }
 
@@ -332,11 +333,10 @@ static inline void ipmr_cache_free(struct mfc_cache *c)
    and reporting error to netlink readers.
  */
 
-static void ipmr_destroy_unres(struct mfc_cache *c)
+static void ipmr_destroy_unres(struct net *net, struct mfc_cache *c)
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
-	struct net *net = mfc_net(c);
 
 	atomic_dec(&net->ipv4.cache_resolve_queue_len);
 
@@ -391,7 +391,7 @@ static void ipmr_expire_process(unsigned long arg)
 
 		*cp = c->next;
 
-		ipmr_destroy_unres(c);
+		ipmr_destroy_unres(net, c);
 	}
 
 	if (net->ipv4.mfc_unres_queue != NULL)
@@ -403,10 +403,10 @@ out:
 
 /* Fill oifs list. It is called under write locked mrt_lock. */
 
-static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
+static void ipmr_update_thresholds(struct net *net, struct mfc_cache *cache,
+				   unsigned char *ttls)
 {
 	int vifi;
-	struct net *net = mfc_net(cache);
 
 	cache->mfc_un.res.minvif = MAXVIFS;
 	cache->mfc_un.res.maxvif = 0;
@@ -546,24 +546,22 @@ static struct mfc_cache *ipmr_cache_find(struct net *net,
 /*
  *	Allocate a multicast cache entry
  */
-static struct mfc_cache *ipmr_cache_alloc(struct net *net)
+static struct mfc_cache *ipmr_cache_alloc(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
 	if (c == NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXVIFS;
-	mfc_net_set(c, net);
 	return c;
 }
 
-static struct mfc_cache *ipmr_cache_alloc_unres(struct net *net)
+static struct mfc_cache *ipmr_cache_alloc_unres(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
 	if (c == NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10*HZ;
-	mfc_net_set(c, net);
 	return c;
 }
 
@@ -571,7 +569,8 @@ static struct mfc_cache *ipmr_cache_alloc_unres(struct net *net)
  *	A cache entry has gone into a resolved state from queued
  */
 
-static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
+static void ipmr_cache_resolve(struct net *net, struct mfc_cache *uc,
+			       struct mfc_cache *c)
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
@@ -584,7 +583,7 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
-			if (ipmr_fill_mroute(skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (ipmr_fill_mroute(net, skb, c, NLMSG_DATA(nlh)) > 0) {
 				nlh->nlmsg_len = (skb_tail_pointer(skb) -
 						  (u8 *)nlh);
 			} else {
@@ -596,9 +595,9 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
 
-			rtnl_unicast(skb, mfc_net(c), NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
 		} else
-			ip_mr_forward(skb, c, 0);
+			ip_mr_forward(net, skb, c, 0);
 	}
 }
 
@@ -716,7 +715,7 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 		 */
 
 		if (atomic_read(&net->ipv4.cache_resolve_queue_len) >= 10 ||
-		    (c = ipmr_cache_alloc_unres(net)) == NULL) {
+		    (c = ipmr_cache_alloc_unres()) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
 			kfree_skb(skb);
@@ -813,7 +812,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	if (c != NULL) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
-		ipmr_update_thresholds(c, mfc->mfcc_ttls);
+		ipmr_update_thresholds(net, c, mfc->mfcc_ttls);
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
@@ -823,14 +822,14 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
-	c = ipmr_cache_alloc(net);
+	c = ipmr_cache_alloc();
 	if (c == NULL)
 		return -ENOMEM;
 
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent = mfc->mfcc_parent;
-	ipmr_update_thresholds(c, mfc->mfcc_ttls);
+	ipmr_update_thresholds(net, c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
@@ -858,7 +857,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
-		ipmr_cache_resolve(uc, c);
+		ipmr_cache_resolve(net, uc, c);
 		ipmr_cache_free(uc);
 	}
 	return 0;
@@ -909,7 +908,7 @@ static void mroute_clean_tables(struct net *net)
 		cp = &net->ipv4.mfc_unres_queue;
 		while ((c = *cp) != NULL) {
 			*cp = c->next;
-			ipmr_destroy_unres(c);
+			ipmr_destroy_unres(net, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
 	}
@@ -1220,9 +1219,9 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
  *	Processing handlers for ipmr_forward
  */
 
-static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
+static void ipmr_queue_xmit(struct net *net, struct sk_buff *skb,
+			    struct mfc_cache *c, int vifi)
 {
-	struct net *net = mfc_net(c);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct vif_device *vif = &net->ipv4.vif_table[vifi];
 	struct net_device *dev;
@@ -1334,11 +1333,11 @@ static int ipmr_find_vif(struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local)
+static int ip_mr_forward(struct net *net, struct sk_buff *skb,
+			 struct mfc_cache *cache, int local)
 {
 	int psend = -1;
 	int vif, ct;
-	struct net *net = mfc_net(cache);
 
 	vif = cache->mfc_parent;
 	cache->mfc_un.res.pkt++;
@@ -1395,7 +1394,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2)
-					ipmr_queue_xmit(skb2, cache, psend);
+					ipmr_queue_xmit(net, skb2, cache, psend);
 			}
 			psend = ct;
 		}
@@ -1404,9 +1403,9 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2)
-				ipmr_queue_xmit(skb2, cache, psend);
+				ipmr_queue_xmit(net, skb2, cache, psend);
 		} else {
-			ipmr_queue_xmit(skb, cache, psend);
+			ipmr_queue_xmit(net, skb, cache, psend);
 			return 0;
 		}
 	}
@@ -1487,7 +1486,7 @@ int ip_mr_input(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	ip_mr_forward(skb, cache, local);
+	ip_mr_forward(net, skb, cache, local);
 
 	read_unlock(&mrt_lock);
 
@@ -1601,11 +1600,11 @@ drop:
 #endif
 
 static int
-ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
+ipmr_fill_mroute(struct net *net, struct sk_buff *skb, struct mfc_cache *c,
+		 struct rtmsg *rtm)
 {
 	int ct;
 	struct rtnexthop *nhp;
-	struct net *net = mfc_net(c);
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
@@ -1685,7 +1684,7 @@ int ipmr_get_route(struct net *net,
 
 	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
 		cache->mfc_flags |= MFC_NOTIFY;
-	err = ipmr_fill_mroute(skb, cache, rtm);
+	err = ipmr_fill_mroute(net, skb, cache, rtm);
 	read_unlock(&mrt_lock);
 	return err;
 }
-- 
1.7.0.4

