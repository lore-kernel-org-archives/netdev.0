From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 5/9] netns: ip6mr: declare counter cache_resolve_queue_len
 per-namespace
Date: Wed, 10 Dec 2008 17:03:06 +0100
Message-ID: <20081210160303.109477817@theryb.frec.bull.fr>
References: <20081210160301.883947374@theryb.frec.bull.fr>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42477 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbYLJQEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:04:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast forwarding netns-aware.

Declare variable cache_resolve_queue_len per-namespace: moves it into
struct netns_ipv6.

This variable counts the number of unresolved cache entries queued in the
list mfc_unres_queue. This list is kept global to all netns as the number
of entries per namespace is limited to 10 (hardcoded in routine 
ip6mr_cache_unresolved).
Entries belonging to different namespaces in mfc_unres_queue will be
identified by matching the mfc_net member introduced previously in 
struct mfc6_cache.

Keeping this list global to all netns, also allows us to keep a single
timer (ipmr_expire_timer) to handle their expiration.
In some places cache_resolve_queue_len value was tested for arming 
or deleting the timer. These tests were equivalent to testing 
mfc_unres_queue value instead and are replaced in this patch.

At the moment, cache_resolve_queue_len is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 +
 net/ipv6/ip6mr.c         |   40 +++++++++++++++++++++-------------------
 2 files changed, 22 insertions(+), 19 deletions(-)

Index: net-next-2.6/include/net/netns/ipv6.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv6.h
+++ net-next-2.6/include/net/netns/ipv6.h
@@ -60,6 +60,7 @@ struct netns_ipv6 {
 	struct mfc6_cache	**mfc6_cache_array;
 	struct mif_device	*vif6_table;
 	int			maxvif;
+	atomic_t		cache_resolve_queue_len;
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-next-2.6.orig/net/ipv6/ip6mr.c
+++ net-next-2.6/net/ipv6/ip6mr.c
@@ -69,7 +69,6 @@ static int mroute_do_pim;
 #endif
 
 static struct mfc6_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
@@ -519,7 +518,7 @@ static void ip6mr_destroy_unres(struct m
 {
 	struct sk_buff *skb;
 
-	atomic_dec(&cache_resolve_queue_len);
+	atomic_dec(&init_net.ipv6.cache_resolve_queue_len);
 
 	while((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
 		if (ipv6_hdr(skb)->version == 0) {
@@ -561,7 +560,7 @@ static void ipmr_do_expire_process(unsig
 		ip6mr_destroy_unres(c);
 	}
 
-	if (atomic_read(&cache_resolve_queue_len))
+	if (mfc_unres_queue != NULL)
 		mod_timer(&ipmr_expire_timer, jiffies + expires);
 }
 
@@ -572,7 +571,7 @@ static void ipmr_expire_process(unsigned
 		return;
 	}
 
-	if (atomic_read(&cache_resolve_queue_len))
+	if (mfc_unres_queue != NULL)
 		ipmr_do_expire_process(dummy);
 
 	spin_unlock(&mfc_unres_lock);
@@ -852,7 +851,8 @@ ip6mr_cache_unresolved(mifi_t mifi, stru
 
 	spin_lock_bh(&mfc_unres_lock);
 	for (c = mfc_unres_queue; c; c = c->next) {
-		if (ipv6_addr_equal(&c->mf6c_mcastgrp, &ipv6_hdr(skb)->daddr) &&
+		if (net_eq(mfc6_net(c), &init_net) &&
+		    ipv6_addr_equal(&c->mf6c_mcastgrp, &ipv6_hdr(skb)->daddr) &&
 		    ipv6_addr_equal(&c->mf6c_origin, &ipv6_hdr(skb)->saddr))
 			break;
 	}
@@ -862,7 +862,7 @@ ip6mr_cache_unresolved(mifi_t mifi, stru
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&cache_resolve_queue_len) >= 10 ||
+		if (atomic_read(&init_net.ipv6.cache_resolve_queue_len) >= 10 ||
 		    (c = ip6mr_cache_alloc_unres(&init_net)) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
@@ -891,7 +891,7 @@ ip6mr_cache_unresolved(mifi_t mifi, stru
 			return err;
 		}
 
-		atomic_inc(&cache_resolve_queue_len);
+		atomic_inc(&init_net.ipv6.cache_resolve_queue_len);
 		c->next = mfc_unres_queue;
 		mfc_unres_queue = c;
 
@@ -1119,14 +1119,16 @@ static int ip6mr_mfc_add(struct mf6cctl 
 	spin_lock_bh(&mfc_unres_lock);
 	for (cp = &mfc_unres_queue; (uc = *cp) != NULL;
 	     cp = &uc->next) {
-		if (ipv6_addr_equal(&uc->mf6c_origin, &c->mf6c_origin) &&
+		if (net_eq(mfc6_net(uc), &init_net) &&
+		    ipv6_addr_equal(&uc->mf6c_origin, &c->mf6c_origin) &&
 		    ipv6_addr_equal(&uc->mf6c_mcastgrp, &c->mf6c_mcastgrp)) {
 			*cp = uc->next;
-			if (atomic_dec_and_test(&cache_resolve_queue_len))
-				del_timer(&ipmr_expire_timer);
+			atomic_dec(&init_net.ipv6.cache_resolve_queue_len);
 			break;
 		}
 	}
+	if (mfc_unres_queue == NULL)
+		del_timer(&ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (uc) {
@@ -1172,18 +1174,18 @@ static void mroute_clean_tables(struct s
 		}
 	}
 
-	if (atomic_read(&cache_resolve_queue_len) != 0) {
-		struct mfc6_cache *c;
+	if (atomic_read(&init_net.ipv6.cache_resolve_queue_len) != 0) {
+		struct mfc6_cache *c, **cp;
 
 		spin_lock_bh(&mfc_unres_lock);
-		while (mfc_unres_queue != NULL) {
-			c = mfc_unres_queue;
-			mfc_unres_queue = c->next;
-			spin_unlock_bh(&mfc_unres_lock);
-
+		cp = &mfc_unres_queue;
+		while ((c = *cp) != NULL) {
+			if (!net_eq(mfc6_net(c), &init_net)) {
+				cp = &c->next;
+				continue;
+			}
+			*cp = c->next;
 			ip6mr_destroy_unres(c);
-
-			spin_lock_bh(&mfc_unres_lock);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
 	}

