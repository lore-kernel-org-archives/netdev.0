From: kaber@trash.net
Subject: [PATCH 3/6] ipv6: ip6mr: convert struct mfc_cache to struct list_head
Date: Tue, 11 May 2010 16:02:28 +0200
Message-ID: <1273586551-3521-4-git-send-email-kaber@trash.net>
References: <1273586551-3521-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40377 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757925Ab0EKOCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:02:35 -0400
In-Reply-To: <1273586551-3521-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/mroute6.h  |    2 +-
 include/net/netns/ipv6.h |    4 +-
 net/ipv6/ip6mr.c         |  127 ++++++++++++++++++++++-----------------------
 3 files changed, 65 insertions(+), 68 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 04e2e54..94a0cb5 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -182,7 +182,7 @@ struct mif_device {
 #define VIFF_STATIC 0x8000
 
 struct mfc6_cache {
-	struct mfc6_cache *next;		/* Next entry on cache line 	*/
+	struct list_head list;
 	struct in6_addr mf6c_mcastgrp;			/* Group the entry belongs to 	*/
 	struct in6_addr mf6c_origin;			/* Source of packet 		*/
 	mifi_t mf6c_parent;			/* Source interface		*/
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 43d842a..9cb3b5f 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -61,8 +61,8 @@ struct netns_ipv6 {
 #ifdef CONFIG_IPV6_MROUTE
 	struct sock		*mroute6_sk;
 	struct timer_list	ipmr_expire_timer;
-	struct mfc6_cache	*mfc6_unres_queue;
-	struct mfc6_cache	**mfc6_cache_array;
+	struct list_head	mfc6_unres_queue;
+	struct list_head	*mfc6_cache_array;
 	struct mif_device	*vif6_table;
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index b3783a4..08e0904 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -89,7 +89,7 @@ static void mroute_clean_tables(struct net *net);
 
 struct ipmr_mfc_iter {
 	struct seq_net_private p;
-	struct mfc6_cache **cache;
+	struct list_head *cache;
 	int ct;
 };
 
@@ -99,18 +99,18 @@ static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
 {
 	struct mfc6_cache *mfc;
 
-	it->cache = net->ipv6.mfc6_cache_array;
 	read_lock(&mrt_lock);
-	for (it->ct = 0; it->ct < MFC6_LINES; it->ct++)
-		for (mfc = net->ipv6.mfc6_cache_array[it->ct];
-		     mfc; mfc = mfc->next)
+	for (it->ct = 0; it->ct < MFC6_LINES; it->ct++) {
+		it->cache = &net->ipv6.mfc6_cache_array[it->ct];
+		list_for_each_entry(mfc, it->cache, list)
 			if (pos-- == 0)
 				return mfc;
+	}
 	read_unlock(&mrt_lock);
 
-	it->cache = &net->ipv6.mfc6_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for (mfc = net->ipv6.mfc6_unres_queue; mfc; mfc = mfc->next)
+	it->cache = &net->ipv6.mfc6_unres_queue;
+	list_for_each_entry(mfc, it->cache, list)
 		if (pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
@@ -119,9 +119,6 @@ static struct mfc6_cache *ipmr_mfc_seq_idx(struct net *net,
 	return NULL;
 }
 
-
-
-
 /*
  *	The /proc interfaces to multicast routing /proc/ip6_mr_cache /proc/ip6_mr_vif
  */
@@ -238,18 +235,19 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (v == SEQ_START_TOKEN)
 		return ipmr_mfc_seq_idx(net, seq->private, 0);
 
-	if (mfc->next)
-		return mfc->next;
+	if (mfc->list.next != it->cache)
+		return list_entry(mfc->list.next, struct mfc6_cache, list);
 
 	if (it->cache == &net->ipv6.mfc6_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != net->ipv6.mfc6_cache_array);
+	BUG_ON(it->cache != &net->ipv6.mfc6_cache_array[it->ct]);
 
 	while (++it->ct < MFC6_LINES) {
-		mfc = net->ipv6.mfc6_cache_array[it->ct];
-		if (mfc)
-			return mfc;
+		it->cache = &net->ipv6.mfc6_cache_array[it->ct];
+		if (list_empty(it->cache))
+			continue;
+		return list_first_entry(it->cache, struct mfc6_cache, list);
 	}
 
 	/* exhausted cache_array, show unresolved */
@@ -258,9 +256,8 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
-	mfc = net->ipv6.mfc6_unres_queue;
-	if (mfc)
-		return mfc;
+	if (!list_empty(it->cache))
+		return list_first_entry(it->cache, struct mfc6_cache, list);
 
  end_of_list:
 	spin_unlock_bh(&mfc_unres_lock);
@@ -560,25 +557,22 @@ static void ipmr_do_expire_process(struct net *net)
 {
 	unsigned long now = jiffies;
 	unsigned long expires = 10 * HZ;
-	struct mfc6_cache *c, **cp;
-
-	cp = &net->ipv6.mfc6_unres_queue;
+	struct mfc6_cache *c, *next;
 
-	while ((c = *cp) != NULL) {
+	list_for_each_entry_safe(c, next, &net->ipv6.mfc6_unres_queue, list) {
 		if (time_after(c->mfc_un.unres.expires, now)) {
 			/* not yet... */
 			unsigned long interval = c->mfc_un.unres.expires - now;
 			if (interval < expires)
 				expires = interval;
-			cp = &c->next;
 			continue;
 		}
 
-		*cp = c->next;
+		list_del(&c->list);
 		ip6mr_destroy_unres(net, c);
 	}
 
-	if (net->ipv6.mfc6_unres_queue != NULL)
+	if (!list_empty(&net->ipv6.mfc6_unres_queue))
 		mod_timer(&net->ipv6.ipmr_expire_timer, jiffies + expires);
 }
 
@@ -591,7 +585,7 @@ static void ipmr_expire_process(unsigned long arg)
 		return;
 	}
 
-	if (net->ipv6.mfc6_unres_queue != NULL)
+	if (!list_empty(&net->ipv6.mfc6_unres_queue))
 		ipmr_do_expire_process(net);
 
 	spin_unlock(&mfc_unres_lock);
@@ -706,12 +700,12 @@ static struct mfc6_cache *ip6mr_cache_find(struct net *net,
 	int line = MFC6_HASH(mcastgrp, origin);
 	struct mfc6_cache *c;
 
-	for (c = net->ipv6.mfc6_cache_array[line]; c; c = c->next) {
+	list_for_each_entry(c, &net->ipv6.mfc6_cache_array[line], list) {
 		if (ipv6_addr_equal(&c->mf6c_origin, origin) &&
 		    ipv6_addr_equal(&c->mf6c_mcastgrp, mcastgrp))
-			break;
+			return c;
 	}
-	return c;
+	return NULL;
 }
 
 /*
@@ -872,17 +866,20 @@ static int ip6mr_cache_report(struct net *net, struct sk_buff *pkt, mifi_t mifi,
 static int
 ip6mr_cache_unresolved(struct net *net, mifi_t mifi, struct sk_buff *skb)
 {
+	bool found = false;
 	int err;
 	struct mfc6_cache *c;
 
 	spin_lock_bh(&mfc_unres_lock);
-	for (c = net->ipv6.mfc6_unres_queue; c; c = c->next) {
+	list_for_each_entry(c, &net->ipv6.mfc6_unres_queue, list) {
 		if (ipv6_addr_equal(&c->mf6c_mcastgrp, &ipv6_hdr(skb)->daddr) &&
-		    ipv6_addr_equal(&c->mf6c_origin, &ipv6_hdr(skb)->saddr))
+		    ipv6_addr_equal(&c->mf6c_origin, &ipv6_hdr(skb)->saddr)) {
+			found = true;
 			break;
+		}
 	}
 
-	if (c == NULL) {
+	if (!found) {
 		/*
 		 *	Create a new entry if allowable
 		 */
@@ -918,8 +915,7 @@ ip6mr_cache_unresolved(struct net *net, mifi_t mifi, struct sk_buff *skb)
 		}
 
 		atomic_inc(&net->ipv6.cache_resolve_queue_len);
-		c->next = net->ipv6.mfc6_unres_queue;
-		net->ipv6.mfc6_unres_queue = c;
+		list_add(&c->list, &net->ipv6.mfc6_unres_queue);
 
 		ipmr_do_expire_process(net);
 	}
@@ -946,16 +942,15 @@ ip6mr_cache_unresolved(struct net *net, mifi_t mifi, struct sk_buff *skb)
 static int ip6mr_mfc_delete(struct net *net, struct mf6cctl *mfc)
 {
 	int line;
-	struct mfc6_cache *c, **cp;
+	struct mfc6_cache *c, *next;
 
 	line = MFC6_HASH(&mfc->mf6cc_mcastgrp.sin6_addr, &mfc->mf6cc_origin.sin6_addr);
 
-	for (cp = &net->ipv6.mfc6_cache_array[line];
-	     (c = *cp) != NULL; cp = &c->next) {
+	list_for_each_entry_safe(c, next, &net->ipv6.mfc6_cache_array[line], list) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
 		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr)) {
 			write_lock_bh(&mrt_lock);
-			*cp = c->next;
+			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
 			ip6mr_cache_free(c);
@@ -997,7 +992,9 @@ static struct notifier_block ip6_mr_notifier = {
 
 static int __net_init ip6mr_net_init(struct net *net)
 {
+	unsigned int i;
 	int err = 0;
+
 	net->ipv6.vif6_table = kcalloc(MAXMIFS, sizeof(struct mif_device),
 				       GFP_KERNEL);
 	if (!net->ipv6.vif6_table) {
@@ -1007,13 +1004,18 @@ static int __net_init ip6mr_net_init(struct net *net)
 
 	/* Forwarding cache */
 	net->ipv6.mfc6_cache_array = kcalloc(MFC6_LINES,
-					     sizeof(struct mfc6_cache *),
+					     sizeof(struct list_head),
 					     GFP_KERNEL);
 	if (!net->ipv6.mfc6_cache_array) {
 		err = -ENOMEM;
 		goto fail_mfc6_cache;
 	}
 
+	for (i = 0; i < MFC6_LINES; i++)
+		INIT_LIST_HEAD(&net->ipv6.mfc6_cache_array[i]);
+
+	INIT_LIST_HEAD(&net->ipv6.mfc6_unres_queue);
+
 	setup_timer(&net->ipv6.ipmr_expire_timer, ipmr_expire_process,
 		    (unsigned long)net);
 
@@ -1105,8 +1107,9 @@ void ip6_mr_cleanup(void)
 
 static int ip6mr_mfc_add(struct net *net, struct mf6cctl *mfc, int mrtsock)
 {
+	bool found = false;
 	int line;
-	struct mfc6_cache *uc, *c, **cp;
+	struct mfc6_cache *uc, *c;
 	unsigned char ttls[MAXMIFS];
 	int i;
 
@@ -1122,14 +1125,15 @@ static int ip6mr_mfc_add(struct net *net, struct mf6cctl *mfc, int mrtsock)
 
 	line = MFC6_HASH(&mfc->mf6cc_mcastgrp.sin6_addr, &mfc->mf6cc_origin.sin6_addr);
 
-	for (cp = &net->ipv6.mfc6_cache_array[line];
-	     (c = *cp) != NULL; cp = &c->next) {
+	list_for_each_entry(c, &net->ipv6.mfc6_cache_array[line], list) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
-		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr))
+		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr)) {
+			found = true;
 			break;
+		}
 	}
 
-	if (c != NULL) {
+	if (found) {
 		write_lock_bh(&mrt_lock);
 		c->mf6c_parent = mfc->mf6cc_parent;
 		ip6mr_update_thresholds(net, c, ttls);
@@ -1154,29 +1158,29 @@ static int ip6mr_mfc_add(struct net *net, struct mf6cctl *mfc, int mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = net->ipv6.mfc6_cache_array[line];
-	net->ipv6.mfc6_cache_array[line] = c;
+	list_add(&c->list, &net->ipv6.mfc6_cache_array[line]);
 	write_unlock_bh(&mrt_lock);
 
 	/*
 	 *	Check to see if we resolved a queued list. If so we
 	 *	need to send on the frames and tidy up.
 	 */
+	found = false;
 	spin_lock_bh(&mfc_unres_lock);
-	for (cp = &net->ipv6.mfc6_unres_queue; (uc = *cp) != NULL;
-	     cp = &uc->next) {
+	list_for_each_entry(uc, &net->ipv6.mfc6_unres_queue, list) {
 		if (ipv6_addr_equal(&uc->mf6c_origin, &c->mf6c_origin) &&
 		    ipv6_addr_equal(&uc->mf6c_mcastgrp, &c->mf6c_mcastgrp)) {
-			*cp = uc->next;
+			list_del(&uc->list);
 			atomic_dec(&net->ipv6.cache_resolve_queue_len);
+			found = true;
 			break;
 		}
 	}
-	if (net->ipv6.mfc6_unres_queue == NULL)
+	if (list_empty(&net->ipv6.mfc6_unres_queue))
 		del_timer(&net->ipv6.ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
-	if (uc) {
+	if (found) {
 		ip6mr_cache_resolve(net, uc, c);
 		ip6mr_cache_free(uc);
 	}
@@ -1191,6 +1195,7 @@ static void mroute_clean_tables(struct net *net)
 {
 	int i;
 	LIST_HEAD(list);
+	struct mfc6_cache *c, *next;
 
 	/*
 	 *	Shut down all active vif entries
@@ -1205,16 +1210,11 @@ static void mroute_clean_tables(struct net *net)
 	 *	Wipe the cache
 	 */
 	for (i = 0; i < MFC6_LINES; i++) {
-		struct mfc6_cache *c, **cp;
-
-		cp = &net->ipv6.mfc6_cache_array[i];
-		while ((c = *cp) != NULL) {
-			if (c->mfc_flags & MFC_STATIC) {
-				cp = &c->next;
+		list_for_each_entry_safe(c, next, &net->ipv6.mfc6_cache_array[i], list) {
+			if (c->mfc_flags & MFC_STATIC)
 				continue;
-			}
 			write_lock_bh(&mrt_lock);
-			*cp = c->next;
+			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
 			ip6mr_cache_free(c);
@@ -1222,12 +1222,9 @@ static void mroute_clean_tables(struct net *net)
 	}
 
 	if (atomic_read(&net->ipv6.cache_resolve_queue_len) != 0) {
-		struct mfc6_cache *c, **cp;
-
 		spin_lock_bh(&mfc_unres_lock);
-		cp = &net->ipv6.mfc6_unres_queue;
-		while ((c = *cp) != NULL) {
-			*cp = c->next;
+		list_for_each_entry_safe(c, next, &net->ipv6.mfc6_unres_queue, list) {
+			list_del(&c->list);
 			ip6mr_destroy_unres(net, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
-- 
1.7.0.4

