From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 3/4] ipmr: RCU protection for mfc_cache_array
Date: Sat, 02 Oct 2010 04:15:08 +0200
Message-ID: <1285985708.2582.523.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54582 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594Ab0JBCPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 22:15:13 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so992146fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 19:15:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU & RTNL protection for mfc_cache_array[]

ipmr_cache_find() is called under rcu_read_lock();

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/mroute.h |    1 
 net/ipv4/ipmr.c        |   87 +++++++++++++++++++++------------------
 2 files changed, 48 insertions(+), 40 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index fa04b24..0fa7a3a 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -213,6 +213,7 @@ struct mfc_cache {
 			unsigned char ttls[MAXVIFS];	/* TTL thresholds		*/
 		} res;
 	} mfc_un;
+	struct rcu_head	rcu;
 };
 
 #define MFC_STATIC		1
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index e2db2ea..cbb6dab 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -577,11 +577,18 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 	return 0;
 }
 
-static inline void ipmr_cache_free(struct mfc_cache *c)
+static void ipmr_cache_free_rcu(struct rcu_head *head)
 {
+	struct mfc_cache *c = container_of(head, struct mfc_cache, rcu);
+
 	kmem_cache_free(mrt_cachep, c);
 }
 
+static inline void ipmr_cache_free(struct mfc_cache *c)
+{
+	call_rcu(&c->rcu, ipmr_cache_free_rcu);
+}
+
 /* Destroy an unresolved cache entry, killing queued skbs
    and reporting error to netlink readers.
  */
@@ -781,6 +788,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	return 0;
 }
 
+/* called with rcu_read_lock() */
 static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 					 __be32 origin,
 					 __be32 mcastgrp)
@@ -788,7 +796,7 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
-	list_for_each_entry(c, &mrt->mfc_cache_array[line], list) {
+	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == origin && c->mfc_mcastgrp == mcastgrp)
 			return c;
 	}
@@ -801,19 +809,20 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 static struct mfc_cache *ipmr_cache_alloc(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
-	if (c == NULL)
-		return NULL;
-	c->mfc_un.res.minvif = MAXVIFS;
+
+	if (c)
+		c->mfc_un.res.minvif = MAXVIFS;
 	return c;
 }
 
 static struct mfc_cache *ipmr_cache_alloc_unres(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
-	if (c == NULL)
-		return NULL;
-	skb_queue_head_init(&c->mfc_un.unres.unresolved);
-	c->mfc_un.unres.expires = jiffies + 10*HZ;
+
+	if (c) {
+		skb_queue_head_init(&c->mfc_un.unres.unresolved);
+		c->mfc_un.unres.expires = jiffies + 10*HZ;
+	}
 	return c;
 }
 
@@ -1040,9 +1049,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
 	list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
-			write_lock_bh(&mrt_lock);
-			list_del(&c->list);
-			write_unlock_bh(&mrt_lock);
+			list_del_rcu(&c->list);
 
 			ipmr_cache_free(c);
 			return 0;
@@ -1095,9 +1102,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
-	write_lock_bh(&mrt_lock);
-	list_add(&c->list, &mrt->mfc_cache_array[line]);
-	write_unlock_bh(&mrt_lock);
+	list_add_rcu(&c->list, &mrt->mfc_cache_array[line]);
 
 	/*
 	 *	Check to see if we resolved a queued list. If so we
@@ -1149,12 +1154,9 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	 */
 	for (i = 0; i < MFC_LINES; i++) {
 		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
-			if (c->mfc_flags&MFC_STATIC)
+			if (c->mfc_flags & MFC_STATIC)
 				continue;
-			write_lock_bh(&mrt_lock);
-			list_del(&c->list);
-			write_unlock_bh(&mrt_lock);
-
+			list_del_rcu(&c->list);
 			ipmr_cache_free(c);
 		}
 	}
@@ -1422,19 +1424,19 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 		if (copy_from_user(&sr, arg, sizeof(sr)))
 			return -EFAULT;
 
-		read_lock(&mrt_lock);
+		rcu_read_lock();
 		c = ipmr_cache_find(mrt, sr.src.s_addr, sr.grp.s_addr);
 		if (c) {
 			sr.pktcnt = c->mfc_un.res.pkt;
 			sr.bytecnt = c->mfc_un.res.bytes;
 			sr.wrong_if = c->mfc_un.res.wrong_if;
-			read_unlock(&mrt_lock);
+			rcu_read_unlock();
 
 			if (copy_to_user(arg, &sr, sizeof(sr)))
 				return -EFAULT;
 			return 0;
 		}
-		read_unlock(&mrt_lock);
+		rcu_read_unlock();
 		return -EADDRNOTAVAIL;
 	default:
 		return -ENOIOCTLCMD;
@@ -1764,7 +1766,7 @@ int ip_mr_input(struct sk_buff *skb)
 		    }
 	}
 
-	read_lock(&mrt_lock);
+	/* already under rcu_read_lock() */
 	cache = ipmr_cache_find(mrt, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 
 	/*
@@ -1776,13 +1778,12 @@ int ip_mr_input(struct sk_buff *skb)
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 			ip_local_deliver(skb);
-			if (skb2 == NULL) {
-				read_unlock(&mrt_lock);
+			if (skb2 == NULL)
 				return -ENOBUFS;
-			}
 			skb = skb2;
 		}
 
+		read_lock(&mrt_lock);
 		vif = ipmr_find_vif(mrt, skb->dev);
 		if (vif >= 0) {
 			int err2 = ipmr_cache_unresolved(mrt, vif, skb);
@@ -1795,8 +1796,8 @@ int ip_mr_input(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
+	read_lock(&mrt_lock);
 	ip_mr_forward(net, mrt, skb, cache, local);
-
 	read_unlock(&mrt_lock);
 
 	if (local)
@@ -1963,7 +1964,7 @@ int ipmr_get_route(struct net *net,
 	if (mrt == NULL)
 		return -ENOENT;
 
-	read_lock(&mrt_lock);
+	rcu_read_lock();
 	cache = ipmr_cache_find(mrt, rt->rt_src, rt->rt_dst);
 
 	if (cache == NULL) {
@@ -1973,18 +1974,21 @@ int ipmr_get_route(struct net *net,
 		int vif;
 
 		if (nowait) {
-			read_unlock(&mrt_lock);
+			rcu_read_unlock();
 			return -EAGAIN;
 		}
 
 		dev = skb->dev;
+		read_lock(&mrt_lock);
 		if (dev == NULL || (vif = ipmr_find_vif(mrt, dev)) < 0) {
 			read_unlock(&mrt_lock);
+			rcu_read_unlock();
 			return -ENODEV;
 		}
 		skb2 = skb_clone(skb, GFP_ATOMIC);
 		if (!skb2) {
 			read_unlock(&mrt_lock);
+			rcu_read_unlock();
 			return -ENOMEM;
 		}
 
@@ -1997,13 +2001,16 @@ int ipmr_get_route(struct net *net,
 		iph->version = 0;
 		err = ipmr_cache_unresolved(mrt, vif, skb2);
 		read_unlock(&mrt_lock);
+		rcu_read_unlock();
 		return err;
 	}
 
-	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
+	read_lock(&mrt_lock);
+	if (!nowait && (rtm->rtm_flags & RTM_F_NOTIFY))
 		cache->mfc_flags |= MFC_NOTIFY;
 	err = __ipmr_fill_mroute(mrt, skb, cache, rtm);
 	read_unlock(&mrt_lock);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -2055,14 +2062,14 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[1];
 	s_e = cb->args[2];
 
-	read_lock(&mrt_lock);
+	rcu_read_lock();
 	ipmr_for_each_table(mrt, net) {
 		if (t < s_t)
 			goto next_table;
 		if (t > s_t)
 			s_h = 0;
 		for (h = s_h; h < MFC_LINES; h++) {
-			list_for_each_entry(mfc, &mrt->mfc_cache_array[h], list) {
+			list_for_each_entry_rcu(mfc, &mrt->mfc_cache_array[h], list) {
 				if (e < s_e)
 					goto next_entry;
 				if (ipmr_fill_mroute(mrt, skb,
@@ -2080,7 +2087,7 @@ next_table:
 		t++;
 	}
 done:
-	read_unlock(&mrt_lock);
+	rcu_read_unlock();
 
 	cb->args[2] = e;
 	cb->args[1] = h;
@@ -2213,14 +2220,14 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct net *net,
 	struct mr_table *mrt = it->mrt;
 	struct mfc_cache *mfc;
 
-	read_lock(&mrt_lock);
+	rcu_read_lock();
 	for (it->ct = 0; it->ct < MFC_LINES; it->ct++) {
 		it->cache = &mrt->mfc_cache_array[it->ct];
-		list_for_each_entry(mfc, it->cache, list)
+		list_for_each_entry_rcu(mfc, it->cache, list)
 			if (pos-- == 0)
 				return mfc;
 	}
-	read_unlock(&mrt_lock);
+	rcu_read_unlock();
 
 	spin_lock_bh(&mfc_unres_lock);
 	it->cache = &mrt->mfc_unres_queue;
@@ -2279,7 +2286,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 
 	/* exhausted cache_array, show unresolved */
-	read_unlock(&mrt_lock);
+	rcu_read_unlock();
 	it->cache = &mrt->mfc_unres_queue;
 	it->ct = 0;
 
@@ -2302,7 +2309,7 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 	if (it->cache == &mrt->mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
 	else if (it->cache == &mrt->mfc_cache_array[it->ct])
-		read_unlock(&mrt_lock);
+		rcu_read_unlock();
 }
 
 static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
@@ -2426,7 +2433,7 @@ int __init ip_mr_init(void)
 
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
-				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+				       0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
 				       NULL);
 	if (!mrt_cachep)
 		return -ENOMEM;


