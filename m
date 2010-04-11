From: kaber@trash.net
Subject: [RFC PATCH 7/9] ipv4: ipmr: convert struct mfc_cache to struct list_head
Date: Sun, 11 Apr 2010 19:37:13 +0200
Message-ID: <1271007435-20035-8-git-send-email-kaber@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37505 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528Ab0DKRhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:22 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id 1FDC6B2C4E
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:21 +0200 (MEST)
In-Reply-To: <1271007435-20035-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/mroute.h   |    2 +-
 include/net/netns/ipv4.h |    4 +-
 net/ipv4/ipmr.c          |  125 ++++++++++++++++++++++-----------------------
 3 files changed, 64 insertions(+), 67 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index de7780a..7ff6c77 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -191,7 +191,7 @@ struct vif_device {
 #define VIFF_STATIC 0x8000
 
 struct mfc_cache {
-	struct mfc_cache *next;			/* Next entry on cache line 	*/
+	struct list_head list;
 	__be32 mfc_mcastgrp;			/* Group the entry belongs to 	*/
 	__be32 mfc_origin;			/* Source of packet 		*/
 	vifi_t mfc_parent;			/* Source interface		*/
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b15e518..5d06429 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -61,8 +61,8 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_MROUTE
 	struct sock		*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
-	struct mfc_cache	*mfc_unres_queue;
-	struct mfc_cache	**mfc_cache_array;
+	struct list_head	mfc_unres_queue;
+	struct list_head	*mfc_cache_array;
 	struct vif_device	*vif_table;
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index d7250e2..6107790 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -366,35 +366,32 @@ static void ipmr_expire_process(unsigned long arg)
 	struct net *net = (struct net *)arg;
 	unsigned long now;
 	unsigned long expires;
-	struct mfc_cache *c, **cp;
+	struct mfc_cache *c, *next;
 
 	if (!spin_trylock(&mfc_unres_lock)) {
 		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies+HZ/10);
 		return;
 	}
 
-	if (net->ipv4.mfc_unres_queue == NULL)
+	if (list_empty(&net->ipv4.mfc_unres_queue))
 		goto out;
 
 	now = jiffies;
 	expires = 10*HZ;
-	cp = &net->ipv4.mfc_unres_queue;
 
-	while ((c=*cp) != NULL) {
+	list_for_each_entry_safe(c, next, &net->ipv4.mfc_unres_queue, list) {
 		if (time_after(c->mfc_un.unres.expires, now)) {
 			unsigned long interval = c->mfc_un.unres.expires - now;
 			if (interval < expires)
 				expires = interval;
-			cp = &c->next;
 			continue;
 		}
 
-		*cp = c->next;
-
+		list_del(&c->list);
 		ipmr_destroy_unres(net, c);
 	}
 
-	if (net->ipv4.mfc_unres_queue != NULL)
+	if (!list_empty(&net->ipv4.mfc_unres_queue))
 		mod_timer(&net->ipv4.ipmr_expire_timer, jiffies + expires);
 
 out:
@@ -536,11 +533,11 @@ static struct mfc_cache *ipmr_cache_find(struct net *net,
 	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
-	for (c = net->ipv4.mfc_cache_array[line]; c; c = c->next) {
-		if (c->mfc_origin==origin && c->mfc_mcastgrp==mcastgrp)
-			break;
+	list_for_each_entry(c, &net->ipv4.mfc_cache_array[line], list) {
+		if (c->mfc_origin == origin && c->mfc_mcastgrp == mcastgrp)
+			return c;
 	}
-	return c;
+	return NULL;
 }
 
 /*
@@ -698,18 +695,21 @@ static int ipmr_cache_report(struct net *net,
 static int
 ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 {
+	bool found = false;
 	int err;
 	struct mfc_cache *c;
 	const struct iphdr *iph = ip_hdr(skb);
 
 	spin_lock_bh(&mfc_unres_lock);
-	for (c=net->ipv4.mfc_unres_queue; c; c=c->next) {
+	list_for_each_entry(c, &net->ipv4.mfc_unres_queue, list) {
 		if (c->mfc_mcastgrp == iph->daddr &&
-		    c->mfc_origin == iph->saddr)
+		    c->mfc_origin == iph->saddr) {
+			found = true;
 			break;
+		}
 	}
 
-	if (c == NULL) {
+	if (!found) {
 		/*
 		 *	Create a new entry if allowable
 		 */
@@ -745,8 +745,7 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 		}
 
 		atomic_inc(&net->ipv4.cache_resolve_queue_len);
-		c->next = net->ipv4.mfc_unres_queue;
-		net->ipv4.mfc_unres_queue = c;
+		list_add_tail(&c->list, &net->ipv4.mfc_unres_queue);
 
 		mod_timer(&net->ipv4.ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
@@ -773,16 +772,15 @@ ipmr_cache_unresolved(struct net *net, vifi_t vifi, struct sk_buff *skb)
 static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
 {
 	int line;
-	struct mfc_cache *c, **cp;
+	struct mfc_cache *c, *next;
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp = &net->ipv4.mfc_cache_array[line];
-	     (c = *cp) != NULL; cp = &c->next) {
+	list_for_each_entry_safe(c, next, &net->ipv4.mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			write_lock_bh(&mrt_lock);
-			*cp = c->next;
+			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
 			ipmr_cache_free(c);
@@ -794,22 +792,24 @@ static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
 
 static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 {
+	bool found = false;
 	int line;
-	struct mfc_cache *uc, *c, **cp;
+	struct mfc_cache *uc, *c;
 
 	if (mfc->mfcc_parent >= MAXVIFS)
 		return -ENFILE;
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp = &net->ipv4.mfc_cache_array[line];
-	     (c = *cp) != NULL; cp = &c->next) {
+	list_for_each_entry(c, &net->ipv4.mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
-		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr)
+		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
+			found = true;
 			break;
+		}
 	}
 
-	if (c != NULL) {
+	if (found) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
 		ipmr_update_thresholds(net, c, mfc->mfcc_ttls);
@@ -834,8 +834,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = net->ipv4.mfc_cache_array[line];
-	net->ipv4.mfc_cache_array[line] = c;
+	list_add_tail(&c->list, &net->ipv4.mfc_cache_array[line]);
 	write_unlock_bh(&mrt_lock);
 
 	/*
@@ -843,16 +842,15 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	 *	need to send on the frames and tidy up.
 	 */
 	spin_lock_bh(&mfc_unres_lock);
-	for (cp = &net->ipv4.mfc_unres_queue; (uc=*cp) != NULL;
-	     cp = &uc->next) {
+	list_for_each_entry(uc, &net->ipv4.mfc_unres_queue, list) {
 		if (uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
-			*cp = uc->next;
+			list_del(&uc->list);
 			atomic_dec(&net->ipv4.cache_resolve_queue_len);
 			break;
 		}
 	}
-	if (net->ipv4.mfc_unres_queue == NULL)
+	if (list_empty(&net->ipv4.mfc_unres_queue))
 		del_timer(&net->ipv4.ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
@@ -871,6 +869,7 @@ static void mroute_clean_tables(struct net *net)
 {
 	int i;
 	LIST_HEAD(list);
+	struct mfc_cache *c, *next;
 
 	/*
 	 *	Shut down all active vif entries
@@ -884,17 +883,12 @@ static void mroute_clean_tables(struct net *net)
 	/*
 	 *	Wipe the cache
 	 */
-	for (i=0; i<MFC_LINES; i++) {
-		struct mfc_cache *c, **cp;
-
-		cp = &net->ipv4.mfc_cache_array[i];
-		while ((c = *cp) != NULL) {
-			if (c->mfc_flags&MFC_STATIC) {
-				cp = &c->next;
+	for (i = 0; i < MFC_LINES; i++) {
+		list_for_each_entry_safe(c, next, &net->ipv4.mfc_cache_array[i], list) {
+			if (c->mfc_flags&MFC_STATIC)
 				continue;
-			}
 			write_lock_bh(&mrt_lock);
-			*cp = c->next;
+			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
 
 			ipmr_cache_free(c);
@@ -902,12 +896,9 @@ static void mroute_clean_tables(struct net *net)
 	}
 
 	if (atomic_read(&net->ipv4.cache_resolve_queue_len) != 0) {
-		struct mfc_cache *c, **cp;
-
 		spin_lock_bh(&mfc_unres_lock);
-		cp = &net->ipv4.mfc_unres_queue;
-		while ((c = *cp) != NULL) {
-			*cp = c->next;
+		list_for_each_entry_safe(c, next, &net->ipv4.mfc_unres_queue, list) {
+			list_del(&c->list);
 			ipmr_destroy_unres(net, c);
 		}
 		spin_unlock_bh(&mfc_unres_lock);
@@ -1788,7 +1779,7 @@ static const struct file_operations ipmr_vif_fops = {
 
 struct ipmr_mfc_iter {
 	struct seq_net_private p;
-	struct mfc_cache **cache;
+	struct list_head *cache;
 	int ct;
 };
 
@@ -1798,18 +1789,18 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 {
 	struct mfc_cache *mfc;
 
-	it->cache = net->ipv4.mfc_cache_array;
 	read_lock(&mrt_lock);
-	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
-		for (mfc = net->ipv4.mfc_cache_array[it->ct];
-		     mfc; mfc = mfc->next)
+	for (it->ct = 0; it->ct < MFC_LINES; it->ct++) {
+		it->cache = &net->ipv4.mfc_cache_array[it->ct];
+		list_for_each_entry(mfc, it->cache, list)
 			if (pos-- == 0)
 				return mfc;
+	}
 	read_unlock(&mrt_lock);
 
-	it->cache = &net->ipv4.mfc_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for (mfc = net->ipv4.mfc_unres_queue; mfc; mfc = mfc->next)
+	it->cache = &net->ipv4.mfc_unres_queue;
+	list_for_each_entry(mfc, it->cache, list)
 		if (pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
@@ -1841,18 +1832,19 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (v == SEQ_START_TOKEN)
 		return ipmr_mfc_seq_idx(net, seq->private, 0);
 
-	if (mfc->next)
-		return mfc->next;
+	if (mfc->list.next != it->cache)
+		return list_entry(mfc->list.next, struct mfc_cache, list);
 
 	if (it->cache == &net->ipv4.mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != net->ipv4.mfc_cache_array);
+	BUG_ON(it->cache != &net->ipv4.mfc_cache_array[it->ct]);
 
 	while (++it->ct < MFC_LINES) {
-		mfc = net->ipv4.mfc_cache_array[it->ct];
-		if (mfc)
-			return mfc;
+		it->cache = &net->ipv4.mfc_cache_array[it->ct];
+		if (list_empty(it->cache))
+			continue;
+		return list_first_entry(it->cache, struct mfc_cache, list);
 	}
 
 	/* exhausted cache_array, show unresolved */
@@ -1861,9 +1853,8 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
-	mfc = net->ipv4.mfc_unres_queue;
-	if (mfc)
-		return mfc;
+	if (!list_empty(it->cache))
+		return list_first_entry(it->cache, struct mfc_cache, list);
 
  end_of_list:
 	spin_unlock_bh(&mfc_unres_lock);
@@ -1879,7 +1870,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 
 	if (it->cache == &net->ipv4.mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == net->ipv4.mfc_cache_array)
+	else if (it->cache == &net->ipv4.mfc_cache_array[it->ct])
 		read_unlock(&mrt_lock);
 }
 
@@ -1959,6 +1950,7 @@ static const struct net_protocol pim_protocol = {
  */
 static int __net_init ipmr_net_init(struct net *net)
 {
+	unsigned int i;
 	int err = 0;
 
 	net->ipv4.vif_table = kcalloc(MAXVIFS, sizeof(struct vif_device),
@@ -1970,13 +1962,18 @@ static int __net_init ipmr_net_init(struct net *net)
 
 	/* Forwarding cache */
 	net->ipv4.mfc_cache_array = kcalloc(MFC_LINES,
-					    sizeof(struct mfc_cache *),
+					    sizeof(struct list_head),
 					    GFP_KERNEL);
 	if (!net->ipv4.mfc_cache_array) {
 		err = -ENOMEM;
 		goto fail_mfc_cache;
 	}
 
+	for (i = 0; i < MFC_LINES; i++)
+		INIT_LIST_HEAD(&net->ipv4.mfc_cache_array[i]);
+
+	INIT_LIST_HEAD(&net->ipv4.mfc_unres_queue);
+
 	setup_timer(&net->ipv4.ipmr_expire_timer, ipmr_expire_process,
 		    (unsigned long)net);
 
-- 
1.7.0.4

