From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] ipmr: improve hash scalability
Date: Thu, 12 Jan 2017 15:53:33 +0100
Message-ID: <1484232813-11473-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sharpd@cumulusnetworks.com,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37889 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdALOyc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:54:32 -0500
Received: by mail-wm0-f42.google.com with SMTP id r144so23711469wme.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 06:54:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently we started using ipmr with thousands of entries and easily hit
soft lockups on smaller devices. The reason is that the hash function
uses the high order bits from the src and dst, but those don't change in
many common cases, also the hash table  is only 64 elements so with
thousands it doesn't scale at all.
This patch migrates the hash table to rhashtable, and in particular the
rhl interface which allows for duplicate elements to be chained because
of the MFC_PROXY support (*,G; *,*,oif cases) which allows for multiple
duplicate entries to be added with different interfaces (IMO wrong, but
it's been in for a long time).

And here are some results from tests I've run in a VM:
 mr_table size (default, allocated for all namespaces):
  Before                    After
   49304 bytes               2400 bytes

 Add 65000 routes (the diff is much larger on smaller devices):
  Before                    After
   1m42s                     58s

 Forwarding 256 byte packets with 65000 routes (test done in a VM):
  Before                    After
   3 Mbps / ~1465 pps        122 Mbps / ~59000 pps

As a bonus we no longer see the soft lockups on smaller devices which
showed up even with 2000 entries before.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/mroute.h |  57 ++++++++---
 net/ipv4/ipmr.c        | 255 +++++++++++++++++++++++++++----------------------
 2 files changed, 182 insertions(+), 130 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index f019b62f27b5..d7f63339ef0b 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -3,6 +3,7 @@
 
 #include <linux/in.h>
 #include <linux/pim.h>
+#include <linux/rhashtable.h>
 #include <net/sock.h>
 #include <uapi/linux/mroute.h>
 
@@ -60,7 +61,6 @@ struct vif_device {
 #define VIFF_STATIC 0x8000
 
 #define VIF_EXISTS(_mrt, _idx) ((_mrt)->vif_table[_idx].dev != NULL)
-#define MFC_LINES 64
 
 struct mr_table {
 	struct list_head	list;
@@ -69,8 +69,9 @@ struct mr_table {
 	struct sock __rcu	*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
 	struct list_head	mfc_unres_queue;
-	struct list_head	mfc_cache_array[MFC_LINES];
 	struct vif_device	vif_table[MAXVIFS];
+	struct rhltable		mfc_hash;
+	struct list_head	mfc_cache_list;
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
 	bool			mroute_do_assert;
@@ -85,17 +86,48 @@ enum {
 	MFC_STATIC = BIT(0),
 };
 
+struct mfc_cache_cmp_arg {
+	__be32 mfc_mcastgrp;
+	__be32 mfc_origin;
+};
+
+/**
+ * struct mfc_cache - multicast routing entries
+ * @mnode: rhashtable list
+ * @mfc_mcastgrp: destination multicast group address
+ * @mfc_origin: source address
+ * @cmparg: used for rhashtable comparisons
+ * @mfc_parent: source interface (iif)
+ * @mfc_flags: entry flags
+ * @expires: unresolved entry expire time
+ * @unresolved: unresolved cached skbs
+ * @last_assert: time of last assert
+ * @minvif: minimum VIF id
+ * @maxvif: maximum VIF id
+ * @bytes: bytes that have passed for this entry
+ * @pkt: packets that have passed for this entry
+ * @wrong_if: number of wrong source interface hits
+ * @lastuse: time of last use of the group (traffic or update)
+ * @ttls: OIF TTL threshold array
+ * @list: global entry list
+ * @rcu: used for entry destruction
+ */
 struct mfc_cache {
-	struct list_head list;
-	__be32 mfc_mcastgrp;			/* Group the entry belongs to 	*/
-	__be32 mfc_origin;			/* Source of packet 		*/
-	vifi_t mfc_parent;			/* Source interface		*/
-	int mfc_flags;				/* Flags on line		*/
+	struct rhlist_head mnode;
+	union {
+		struct {
+			__be32 mfc_mcastgrp;
+			__be32 mfc_origin;
+		};
+		struct mfc_cache_cmp_arg cmparg;
+	};
+	vifi_t mfc_parent;
+	int mfc_flags;
 
 	union {
 		struct {
 			unsigned long expires;
-			struct sk_buff_head unresolved;	/* Unresolved buffers		*/
+			struct sk_buff_head unresolved;
 		} unres;
 		struct {
 			unsigned long last_assert;
@@ -105,18 +137,13 @@ struct mfc_cache {
 			unsigned long pkt;
 			unsigned long wrong_if;
 			unsigned long lastuse;
-			unsigned char ttls[MAXVIFS];	/* TTL thresholds		*/
+			unsigned char ttls[MAXVIFS];
 		} res;
 	} mfc_un;
+	struct list_head list;
 	struct rcu_head	rcu;
 };
 
-#ifdef __BIG_ENDIAN
-#define MFC_HASH(a,b)	(((((__force u32)(__be32)a)>>24)^(((__force u32)(__be32)b)>>26))&(MFC_LINES-1))
-#else
-#define MFC_HASH(a,b)	((((__force u32)(__be32)a)^(((__force u32)(__be32)b)>>2))&(MFC_LINES-1))
-#endif
-
 struct rtmsg;
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		   __be32 saddr, __be32 daddr,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 824c4fdf21eb..beacd028848c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -299,10 +299,29 @@ static void __net_exit ipmr_rules_exit(struct net *net)
 }
 #endif
 
+static inline int ipmr_hash_cmp(struct rhashtable_compare_arg *arg,
+				const void *ptr)
+{
+	const struct mfc_cache_cmp_arg *cmparg = arg->key;
+	struct mfc_cache *c = (struct mfc_cache *)ptr;
+
+	return cmparg->mfc_mcastgrp != c->mfc_mcastgrp ||
+	       cmparg->mfc_origin != c->mfc_origin;
+}
+
+static const struct rhashtable_params ipmr_rht_params = {
+	.head_offset = offsetof(struct mfc_cache, mnode),
+	.key_offset = offsetof(struct mfc_cache, cmparg),
+	.key_len = sizeof(struct mfc_cache_cmp_arg),
+	.nelem_hint = 3,
+	.locks_mul = 1,
+	.obj_cmpfn = ipmr_hash_cmp,
+	.automatic_shrinking = true,
+};
+
 static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 {
 	struct mr_table *mrt;
-	unsigned int i;
 
 	/* "pimreg%u" should not exceed 16 bytes (IFNAMSIZ) */
 	if (id != RT_TABLE_DEFAULT && id >= 1000000000)
@@ -318,10 +337,8 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 	write_pnet(&mrt->net, net);
 	mrt->id = id;
 
-	/* Forwarding cache */
-	for (i = 0; i < MFC_LINES; i++)
-		INIT_LIST_HEAD(&mrt->mfc_cache_array[i]);
-
+	rhltable_init(&mrt->mfc_hash, &ipmr_rht_params);
+	INIT_LIST_HEAD(&mrt->mfc_cache_list);
 	INIT_LIST_HEAD(&mrt->mfc_unres_queue);
 
 	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
@@ -338,6 +355,7 @@ static void ipmr_free_table(struct mr_table *mrt)
 {
 	del_timer_sync(&mrt->ipmr_expire_timer);
 	mroute_clean_tables(mrt, true);
+	rhltable_destroy(&mrt->mfc_hash);
 	kfree(mrt);
 }
 
@@ -839,13 +857,17 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 					 __be32 origin,
 					 __be32 mcastgrp)
 {
-	int line = MFC_HASH(mcastgrp, origin);
+	struct mfc_cache_cmp_arg arg = {
+			.mfc_mcastgrp = mcastgrp,
+			.mfc_origin = origin
+	};
+	struct rhlist_head *tmp, *list;
 	struct mfc_cache *c;
 
-	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list) {
-		if (c->mfc_origin == origin && c->mfc_mcastgrp == mcastgrp)
-			return c;
-	}
+	list = rhltable_lookup(&mrt->mfc_hash, &arg, ipmr_rht_params);
+	rhl_for_each_entry_rcu(c, tmp, list, mnode)
+		return c;
+
 	return NULL;
 }
 
@@ -853,13 +875,16 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table *mrt,
 						    int vifi)
 {
-	int line = MFC_HASH(htonl(INADDR_ANY), htonl(INADDR_ANY));
+	struct mfc_cache_cmp_arg arg = {
+			.mfc_mcastgrp = htonl(INADDR_ANY),
+			.mfc_origin = htonl(INADDR_ANY)
+	};
+	struct rhlist_head *tmp, *list;
 	struct mfc_cache *c;
 
-	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
-		if (c->mfc_origin == htonl(INADDR_ANY) &&
-		    c->mfc_mcastgrp == htonl(INADDR_ANY) &&
-		    c->mfc_un.res.ttls[vifi] < 255)
+	list = rhltable_lookup(&mrt->mfc_hash, &arg, ipmr_rht_params);
+	rhl_for_each_entry_rcu(c, tmp, list, mnode)
+		if (c->mfc_un.res.ttls[vifi] < 255)
 			return c;
 
 	return NULL;
@@ -869,29 +894,51 @@ static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table *mrt,
 static struct mfc_cache *ipmr_cache_find_any(struct mr_table *mrt,
 					     __be32 mcastgrp, int vifi)
 {
-	int line = MFC_HASH(mcastgrp, htonl(INADDR_ANY));
+	struct mfc_cache_cmp_arg arg = {
+			.mfc_mcastgrp = mcastgrp,
+			.mfc_origin = htonl(INADDR_ANY)
+	};
+	struct rhlist_head *tmp, *list;
 	struct mfc_cache *c, *proxy;
 
 	if (mcastgrp == htonl(INADDR_ANY))
 		goto skip;
 
-	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
-		if (c->mfc_origin == htonl(INADDR_ANY) &&
-		    c->mfc_mcastgrp == mcastgrp) {
-			if (c->mfc_un.res.ttls[vifi] < 255)
-				return c;
-
-			/* It's ok if the vifi is part of the static tree */
-			proxy = ipmr_cache_find_any_parent(mrt,
-							   c->mfc_parent);
-			if (proxy && proxy->mfc_un.res.ttls[vifi] < 255)
-				return c;
-		}
+	list = rhltable_lookup(&mrt->mfc_hash, &arg, ipmr_rht_params);
+	rhl_for_each_entry_rcu(c, tmp, list, mnode) {
+		if (c->mfc_un.res.ttls[vifi] < 255)
+			return c;
+
+		/* It's ok if the vifi is part of the static tree */
+		proxy = ipmr_cache_find_any_parent(mrt, c->mfc_parent);
+		if (proxy && proxy->mfc_un.res.ttls[vifi] < 255)
+			return c;
+	}
 
 skip:
 	return ipmr_cache_find_any_parent(mrt, vifi);
 }
 
+/* Look for a (S,G,iif) entry if parent != -1 */
+static struct mfc_cache *ipmr_cache_find_parent(struct mr_table *mrt,
+						__be32 origin, __be32 mcastgrp,
+						int parent)
+{
+	struct mfc_cache_cmp_arg arg = {
+			.mfc_mcastgrp = mcastgrp,
+			.mfc_origin = origin,
+	};
+	struct rhlist_head *tmp, *list;
+	struct mfc_cache *c;
+
+	list = rhltable_lookup(&mrt->mfc_hash, &arg, ipmr_rht_params);
+	rhl_for_each_entry_rcu(c, tmp, list, mnode)
+		if (parent == -1 || parent == c->mfc_parent)
+			return c;
+
+	return NULL;
+}
+
 /* Allocate a multicast cache entry */
 static struct mfc_cache *ipmr_cache_alloc(void)
 {
@@ -1028,10 +1075,10 @@ static int ipmr_cache_report(struct mr_table *mrt,
 static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
 				 struct sk_buff *skb)
 {
+	const struct iphdr *iph = ip_hdr(skb);
+	struct mfc_cache *c;
 	bool found = false;
 	int err;
-	struct mfc_cache *c;
-	const struct iphdr *iph = ip_hdr(skb);
 
 	spin_lock_bh(&mfc_unres_lock);
 	list_for_each_entry(c, &mrt->mfc_unres_queue, list) {
@@ -1095,46 +1142,39 @@ static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
 
 static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
 {
-	int line;
-	struct mfc_cache *c, *next;
+	struct mfc_cache *c;
 
-	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
+	/* The entries are added/deleted only under RTNL */
+	rcu_read_lock();
+	c = ipmr_cache_find_parent(mrt, mfc->mfcc_origin.s_addr,
+				   mfc->mfcc_mcastgrp.s_addr, parent);
+	rcu_read_unlock();
+	if (!c)
+		return -ENOENT;
+	rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
+	list_del_rcu(&c->list);
+	mroute_netlink_event(mrt, c, RTM_DELROUTE);
+	ipmr_cache_free(c);
 
-	list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[line], list) {
-		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
-		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr &&
-		    (parent == -1 || parent == c->mfc_parent)) {
-			list_del_rcu(&c->list);
-			mroute_netlink_event(mrt, c, RTM_DELROUTE);
-			ipmr_cache_free(c);
-			return 0;
-		}
-	}
-	return -ENOENT;
+	return 0;
 }
 
 static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 			struct mfcctl *mfc, int mrtsock, int parent)
 {
-	bool found = false;
-	int line;
 	struct mfc_cache *uc, *c;
+	bool found;
+	int ret;
 
 	if (mfc->mfcc_parent >= MAXVIFS)
 		return -ENFILE;
 
-	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
-
-	list_for_each_entry(c, &mrt->mfc_cache_array[line], list) {
-		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
-		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr &&
-		    (parent == -1 || parent == c->mfc_parent)) {
-			found = true;
-			break;
-		}
-	}
-
-	if (found) {
+	/* The entries are added/deleted only under RTNL */
+	rcu_read_lock();
+	c = ipmr_cache_find_parent(mrt, mfc->mfcc_origin.s_addr,
+				   mfc->mfcc_mcastgrp.s_addr, parent);
+	rcu_read_unlock();
+	if (c) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
 		ipmr_update_thresholds(mrt, c, mfc->mfcc_ttls);
@@ -1160,8 +1200,14 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
-	list_add_rcu(&c->list, &mrt->mfc_cache_array[line]);
-
+	ret = rhltable_insert_key(&mrt->mfc_hash, &c->cmparg, &c->mnode,
+				  ipmr_rht_params);
+	if (ret) {
+		pr_err("ipmr: rhtable insert error %d\n", ret);
+		ipmr_cache_free(c);
+		return ret;
+	}
+	list_add_tail_rcu(&c->list, &mrt->mfc_cache_list);
 	/* Check to see if we resolved a queued list. If so we
 	 * need to send on the frames and tidy up.
 	 */
@@ -1191,9 +1237,9 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 /* Close the multicast socket, and clear the vif tables etc */
 static void mroute_clean_tables(struct mr_table *mrt, bool all)
 {
-	int i;
+	struct mfc_cache *c, *tmp;
 	LIST_HEAD(list);
-	struct mfc_cache *c, *next;
+	int i;
 
 	/* Shut down all active vif entries */
 	for (i = 0; i < mrt->maxvif; i++) {
@@ -1204,19 +1250,18 @@ static void mroute_clean_tables(struct mr_table *mrt, bool all)
 	unregister_netdevice_many(&list);
 
 	/* Wipe the cache */
-	for (i = 0; i < MFC_LINES; i++) {
-		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
-			if (!all && (c->mfc_flags & MFC_STATIC))
-				continue;
-			list_del_rcu(&c->list);
-			mroute_netlink_event(mrt, c, RTM_DELROUTE);
-			ipmr_cache_free(c);
-		}
+	list_for_each_entry_safe(c, tmp, &mrt->mfc_cache_list, list) {
+		if (!all && (c->mfc_flags & MFC_STATIC))
+			continue;
+		rhltable_remove(&mrt->mfc_hash, &c->mnode, ipmr_rht_params);
+		list_del_rcu(&c->list);
+		mroute_netlink_event(mrt, c, RTM_DELROUTE);
+		ipmr_cache_free(c);
 	}
 
 	if (atomic_read(&mrt->cache_resolve_queue_len) != 0) {
 		spin_lock_bh(&mfc_unres_lock);
-		list_for_each_entry_safe(c, next, &mrt->mfc_unres_queue, list) {
+		list_for_each_entry_safe(c, tmp, &mrt->mfc_unres_queue, list) {
 			list_del(&c->list);
 			mroute_netlink_event(mrt, c, RTM_DELROUTE);
 			ipmr_destroy_unres(mrt, c);
@@ -1791,9 +1836,9 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			  struct sk_buff *skb, struct mfc_cache *cache,
 			  int local)
 {
+	int true_vifi = ipmr_find_vif(mrt, skb->dev);
 	int psend = -1;
 	int vif, ct;
-	int true_vifi = ipmr_find_vif(mrt, skb->dev);
 
 	vif = cache->mfc_parent;
 	cache->mfc_un.res.pkt++;
@@ -2293,34 +2338,30 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 	struct mr_table *mrt;
 	struct mfc_cache *mfc;
 	unsigned int t = 0, s_t;
-	unsigned int h = 0, s_h;
 	unsigned int e = 0, s_e;
 
 	s_t = cb->args[0];
-	s_h = cb->args[1];
-	s_e = cb->args[2];
+	s_e = cb->args[1];
 
 	rcu_read_lock();
 	ipmr_for_each_table(mrt, net) {
 		if (t < s_t)
 			goto next_table;
-		if (t > s_t)
-			s_h = 0;
-		for (h = s_h; h < MFC_LINES; h++) {
-			list_for_each_entry_rcu(mfc, &mrt->mfc_cache_array[h], list) {
-				if (e < s_e)
-					goto next_entry;
-				if (ipmr_fill_mroute(mrt, skb,
-						     NETLINK_CB(cb->skb).portid,
-						     cb->nlh->nlmsg_seq,
-						     mfc, RTM_NEWROUTE,
-						     NLM_F_MULTI) < 0)
-					goto done;
+		list_for_each_entry_rcu(mfc, &mrt->mfc_cache_list, list) {
+			if (e < s_e)
+				goto next_entry;
+			if (ipmr_fill_mroute(mrt, skb,
+					     NETLINK_CB(cb->skb).portid,
+					     cb->nlh->nlmsg_seq,
+					     mfc, RTM_NEWROUTE,
+					     NLM_F_MULTI) < 0)
+				goto done;
 next_entry:
-				e++;
-			}
-			e = s_e = 0;
+			e++;
 		}
+		e = 0;
+		s_e = 0;
+
 		spin_lock_bh(&mfc_unres_lock);
 		list_for_each_entry(mfc, &mrt->mfc_unres_queue, list) {
 			if (e < s_e)
@@ -2337,16 +2378,15 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 			e++;
 		}
 		spin_unlock_bh(&mfc_unres_lock);
-		e = s_e = 0;
-		s_h = 0;
+		e = 0;
+		s_e = 0;
 next_table:
 		t++;
 	}
 done:
 	rcu_read_unlock();
 
-	cb->args[2] = e;
-	cb->args[1] = h;
+	cb->args[1] = e;
 	cb->args[0] = t;
 
 	return skb->len;
@@ -2590,10 +2630,8 @@ struct ipmr_mfc_iter {
 	struct seq_net_private p;
 	struct mr_table *mrt;
 	struct list_head *cache;
-	int ct;
 };
 
-
 static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 					  struct ipmr_mfc_iter *it, loff_t pos)
 {
@@ -2601,12 +2639,10 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 	struct mfc_cache *mfc;
 
 	rcu_read_lock();
-	for (it->ct = 0; it->ct < MFC_LINES; it->ct++) {
-		it->cache = &mrt->mfc_cache_array[it->ct];
-		list_for_each_entry_rcu(mfc, it->cache, list)
-			if (pos-- == 0)
-				return mfc;
-	}
+	it->cache = &mrt->mfc_cache_list;
+	list_for_each_entry_rcu(mfc, &mrt->mfc_cache_list, list)
+		if (pos-- == 0)
+			return mfc;
 	rcu_read_unlock();
 
 	spin_lock_bh(&mfc_unres_lock);
@@ -2633,17 +2669,16 @@ static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 
 	it->mrt = mrt;
 	it->cache = NULL;
-	it->ct = 0;
 	return *pos ? ipmr_mfc_seq_idx(net, seq->private, *pos - 1)
 		: SEQ_START_TOKEN;
 }
 
 static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct mfc_cache *mfc = v;
 	struct ipmr_mfc_iter *it = seq->private;
 	struct net *net = seq_file_net(seq);
 	struct mr_table *mrt = it->mrt;
+	struct mfc_cache *mfc = v;
 
 	++*pos;
 
@@ -2656,19 +2691,9 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (it->cache == &mrt->mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != &mrt->mfc_cache_array[it->ct]);
-
-	while (++it->ct < MFC_LINES) {
-		it->cache = &mrt->mfc_cache_array[it->ct];
-		if (list_empty(it->cache))
-			continue;
-		return list_first_entry(it->cache, struct mfc_cache, list);
-	}
-
 	/* exhausted cache_array, show unresolved */
 	rcu_read_unlock();
 	it->cache = &mrt->mfc_unres_queue;
-	it->ct = 0;
 
 	spin_lock_bh(&mfc_unres_lock);
 	if (!list_empty(it->cache))
@@ -2688,7 +2713,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 
 	if (it->cache == &mrt->mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == &mrt->mfc_cache_array[it->ct])
+	else if (it->cache == &mrt->mfc_cache_list)
 		rcu_read_unlock();
 }
 
-- 
2.1.4
