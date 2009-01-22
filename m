From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 5/9] netns: ipmr: declare counter cache_resolve_queue_len
 per-namespace
Date: Thu, 22 Jan 2009 15:56:19 +0100
Message-ID: <20090122145615.934880407@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:59046 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbZAVO5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv4 multicast routing netns-aware.

Declare variable cache_resolve_queue_len per-namespace: moves it into
struct netns_ipv4.

This variable counts the number of unresolved cache entries queued in the
list mfc_unres_queue. This list is kept global to all netns as the number
of entries per namespace is limited to 10 (hardcoded in routine 
ipmr_cache_unresolved).
Entries belonging to different namespaces in mfc_unres_queue will be
identified by matching the mfc_net member introduced previously in 
struct mfc_cache.

Keeping this list global to all netns, also allows us to keep a single
timer (ipmr_expire_timer) to handle their expiration.
In some places cache_resolve_queue_len value was tested for arming 
or deleting the timer. These tests were equivalent to testing 
mfc_unres_queue value instead and are replaced in this patch.

At the moment, cache_resolve_queue_len is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

---
 include/net/netns/ipv4.h |    1 +
 net/ipv4/ipmr.c          |   39 +++++++++++++++++++++------------------
 2 files changed, 22 insertions(+), 18 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -60,6 +60,7 @@ struct netns_ipv4 {
 	struct mfc_cache	**mfc_cache_array;
 	struct vif_device	*vif_table;
 	int			maxvif;
+	atomic_t		cache_resolve_queue_len;
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -83,7 +83,6 @@ static int mroute_do_assert;				/* Set i
 static int mroute_do_pim;
 
 static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
@@ -340,7 +339,7 @@ static void ipmr_destroy_unres(struct mf
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
 
-	atomic_dec(&cache_resolve_queue_len);
+	atomic_dec(&init_net.ipv4.cache_resolve_queue_len);
 
 	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
@@ -374,7 +373,7 @@ static void ipmr_expire_process(unsigned
 		return;
 	}
 
-	if (atomic_read(&cache_resolve_queue_len) == 0)
+	if (mfc_unres_queue == NULL)
 		goto out;
 
 	now = jiffies;
@@ -395,7 +394,7 @@ static void ipmr_expire_process(unsigned
 		ipmr_destroy_unres(c);
 	}
 
-	if (atomic_read(&cache_resolve_queue_len))
+	if (mfc_unres_queue != NULL)
 		mod_timer(&ipmr_expire_timer, jiffies + expires);
 
 out:
@@ -690,7 +689,8 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 
 	spin_lock_bh(&mfc_unres_lock);
 	for (c=mfc_unres_queue; c; c=c->next) {
-		if (c->mfc_mcastgrp == iph->daddr &&
+		if (net_eq(mfc_net(c), &init_net) &&
+		    c->mfc_mcastgrp == iph->daddr &&
 		    c->mfc_origin == iph->saddr)
 			break;
 	}
@@ -700,7 +700,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&cache_resolve_queue_len) >= 10 ||
+		if (atomic_read(&init_net.ipv4.cache_resolve_queue_len) >= 10 ||
 		    (c = ipmr_cache_alloc_unres(&init_net)) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
@@ -729,7 +729,7 @@ ipmr_cache_unresolved(vifi_t vifi, struc
 			return err;
 		}
 
-		atomic_inc(&cache_resolve_queue_len);
+		atomic_inc(&init_net.ipv4.cache_resolve_queue_len);
 		c->next = mfc_unres_queue;
 		mfc_unres_queue = c;
 
@@ -827,14 +827,16 @@ static int ipmr_mfc_add(struct mfcctl *m
 	spin_lock_bh(&mfc_unres_lock);
 	for (cp = &mfc_unres_queue; (uc=*cp) != NULL;
 	     cp = &uc->next) {
-		if (uc->mfc_origin == c->mfc_origin &&
+		if (net_eq(mfc_net(uc), &init_net) &&
+		    uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			*cp = uc->next;
-			if (atomic_dec_and_test(&cache_resolve_queue_len))
-				del_timer(&ipmr_expire_timer);
+			atomic_dec(&init_net.ipv4.cache_resolve_queue_len);
 			break;
 		}
 	}
+	if (mfc_unres_queue == NULL)
+		del_timer(&ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
@@ -880,18 +882,19 @@ static void mroute_clean_tables(struct s
 		}
 	}
 
-	if (atomic_read(&cache_resolve_queue_len) != 0) {
-		struct mfc_cache *c;
+	if (atomic_read(&init_net.ipv4.cache_resolve_queue_len) != 0) {
+		struct mfc_cache *c, **cp;
 
 		spin_lock_bh(&mfc_unres_lock);
-		while (mfc_unres_queue != NULL) {
-			c = mfc_unres_queue;
-			mfc_unres_queue = c->next;
-			spin_unlock_bh(&mfc_unres_lock);
+		cp = &mfc_unres_queue;
+		while ((c = *cp) != NULL) {
+			if (!net_eq(mfc_net(c), &init_net)) {
+				cp = &c->next;
+				continue;
+			}
+			*cp = c->next;
 
 			ipmr_destroy_unres(c);
-
-			spin_lock_bh(&mfc_unres_lock);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
 	}

