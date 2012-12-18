From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: [RFC][PATCH] ipv6 multicast forwarding: Remove threshold checking
 and some trivial bugs
Date: Tue, 18 Dec 2012 12:57:11 +0800
Message-ID: <50CFF7A7.1070508@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:36095 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753840Ab2LRE5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 23:57:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes trivial bugs for IPv6 multicast forwarding code and remove
threshold checking for multicast forwarding cache.

1. Threshold checking in IPv6 multicast forwarding cache (MFC) was not properly implemented.
syscall to setsockopt(... MRT6_ADD_MIF,...) doesn't affect the TTL because it is never used.
In fact, all MFC will always have ttl of 1 as set by ip6mr_mfc_add. From my limited knowledge of
multicast routing, threshold setting on interface is only used by DVMRP which doesn't support
IPv6. FreeBSD's struct mif6ctl doesn't have vifc_threshold. This patch removes the ttl cruft
within kernel. Userspace ABI for backward compatibility. Can someone knowledgable in multicast
routing please verify whether my understanding is correct?
2. Don't allow addition of MFC with non-existent multicast interface index.
3. Don't allow addition of MFC where incoming interface is part of oif list. This does not make
   sense. Why would we want to send a multicast back to the interface where it originates from.
4. setsockopt(....MRT6_ADD_MIF, ) allows a "physical" interface to be registered as multicast 
   interface multiple times. This doesn't make sense. Don't allow registration duplicate 
   registration of the same "physical" interface. 

This patch has been tested, albeit minimally using a simple program. Is this patch okay for
inclusion? Will sign off if it is okay.


---
 include/linux/mroute6.h |    3 +-
 net/ipv6/ip6mr.c        |   79 +++++++++++++++++++++++++----------------------
 2 files changed, 43 insertions(+), 39 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index a223561..88a79d8 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -66,7 +66,6 @@ struct mif_device {
 	unsigned long	bytes_in,bytes_out;
 	unsigned long	pkt_in,pkt_out;		/* Statistics 			*/
 	unsigned long	rate_limit;		/* Traffic shaping (NI) 	*/
-	unsigned char	threshold;		/* TTL threshold 		*/
 	unsigned short	flags;			/* Control flags 		*/
 	int		link;			/* Physical interface index	*/
 };
@@ -92,7 +91,7 @@ struct mfc6_cache {
 			unsigned long bytes;
 			unsigned long pkt;
 			unsigned long wrong_if;
-			unsigned char ttls[MAXMIFS];	/* TTL thresholds		*/
+			struct if_set mf6c_ifset;	/* Where it is going */
 		} res;
 	} mfc_un;
 };
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 26dcdec..0a12fe4 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -122,6 +122,7 @@ static int ip6mr_rtm_dumproute(struct sk_buff *skb,
 			       struct netlink_callback *cb);
 static void mroute_clean_tables(struct mr6_table *mrt);
 static void ipmr_expire_process(unsigned long arg);
+static int ip6mr_find_vif(struct mr6_table *mrt, struct net_device *dev);
 
 #ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
 #define ip6mr_for_each_table(mrt, net) \
@@ -574,10 +575,10 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++) {
 				if (MIF_EXISTS(mrt, n) &&
-				    mfc->mfc_un.res.ttls[n] < 255)
+				    IF_ISSET(n, &mfc->mfc_un.res.mf6c_ifset))
 					seq_printf(seq,
 						   " %2d:%-3d",
-						   n, mfc->mfc_un.res.ttls[n]);
+						   n, 1);
 			}
 		} else {
 			/* unresolved mfc_caches don't contain
@@ -895,28 +896,6 @@ static void ipmr_expire_process(unsigned long arg)
 	spin_unlock(&mfc_unres_lock);
 }
 
-/* Fill oifs list. It is called under write locked mrt_lock. */
-
-static void ip6mr_update_thresholds(struct mr6_table *mrt, struct mfc6_cache *cache,
-				    unsigned char *ttls)
-{
-	int vifi;
-
-	cache->mfc_un.res.minvif = MAXMIFS;
-	cache->mfc_un.res.maxvif = 0;
-	memset(cache->mfc_un.res.ttls, 255, MAXMIFS);
-
-	for (vifi = 0; vifi < mrt->maxvif; vifi++) {
-		if (MIF_EXISTS(mrt, vifi) &&
-		    ttls[vifi] && ttls[vifi] < 255) {
-			cache->mfc_un.res.ttls[vifi] = ttls[vifi];
-			if (cache->mfc_un.res.minvif > vifi)
-				cache->mfc_un.res.minvif = vifi;
-			if (cache->mfc_un.res.maxvif <= vifi)
-				cache->mfc_un.res.maxvif = vifi + 1;
-		}
-	}
-}
 
 static int mif6_add(struct net *net, struct mr6_table *mrt,
 		    struct mif6ctl *vifc, int mrtsock)
@@ -955,6 +934,12 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 		dev = dev_get_by_index(net, vifc->mif6c_pifi);
 		if (!dev)
 			return -EADDRNOTAVAIL;
+
+		if (ip6mr_find_vif(mrt, dev) >= 0) {
+			dev_put(dev);
+			return -EADDRINUSE;
+		}
+
 		err = dev_set_allmulti(dev, 1);
 		if (err) {
 			dev_put(dev);
@@ -980,7 +965,6 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 	v->flags = vifc->mif6c_flags;
 	if (!mrtsock)
 		v->flags |= VIFF_STATIC;
-	v->threshold = vifc->vifc_threshold;
 	v->bytes_in = 0;
 	v->bytes_out = 0;
 	v->pkt_in = 0;
@@ -1393,22 +1377,37 @@ void ip6_mr_cleanup(void)
 static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 			 struct mf6cctl *mfc, int mrtsock)
 {
+	int minvif = MAXMIFS;
+	int maxvif = 0;
 	bool found = false;
 	int line;
 	struct mfc6_cache *uc, *c;
-	unsigned char ttls[MAXMIFS];
 	int i;
 
-	if (mfc->mf6cc_parent >= MAXMIFS)
+	if (mfc->mf6cc_parent >= MAXMIFS || !MIF_EXISTS(mrt, mfc->mf6cc_parent))
 		return -ENFILE;
 
-	memset(ttls, 255, MAXMIFS);
-	for (i = 0; i < MAXMIFS; i++) {
-		if (IF_ISSET(i, &mfc->mf6cc_ifset))
-			ttls[i] = 1;
+	/* incoming interface should not be part of outgoing interfaces, doing so
+	 * will cause duplicate
+	 */
+	if (IF_ISSET(mfc->mf6cc_parent, &mfc->mf6cc_ifset))
+		return -EINVAL;
 
+	for (i = 0; i < MAXMIFS; i++) {
+		if (IF_ISSET(i, &mfc->mf6cc_ifset)) {
+			if (!MIF_EXISTS(mrt, i))
+				return -ENFILE;
+
+			if (minvif > i)
+				minvif = i;
+			if (maxvif <= i)
+				maxvif = i + 1;
+		}
 	}
 
+	if (maxvif <= minvif)	/* mf6cc_ifset is basically empty */
+		return -EINVAL;
+
 	line = MFC6_HASH(&mfc->mf6cc_mcastgrp.sin6_addr, &mfc->mf6cc_origin.sin6_addr);
 
 	list_for_each_entry(c, &mrt->mfc6_cache_array[line], list) {
@@ -1422,7 +1421,10 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 	if (found) {
 		write_lock_bh(&mrt_lock);
 		c->mf6c_parent = mfc->mf6cc_parent;
-		ip6mr_update_thresholds(mrt, c, ttls);
+		c->mfc_un.res.mf6c_ifset = mfc->mf6cc_ifset;
+		c->mfc_un.res.minvif = minvif;
+		c->mfc_un.res.maxvif = maxvif;
+
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
@@ -1440,7 +1442,10 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 	c->mf6c_origin = mfc->mf6cc_origin.sin6_addr;
 	c->mf6c_mcastgrp = mfc->mf6cc_mcastgrp.sin6_addr;
 	c->mf6c_parent = mfc->mf6cc_parent;
-	ip6mr_update_thresholds(mrt, c, ttls);
+	c->mfc_un.res.mf6c_ifset = mfc->mf6cc_ifset;
+	c->mfc_un.res.minvif = minvif;
+	c->mfc_un.res.maxvif = maxvif;
+
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
@@ -2036,7 +2041,7 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
 		    (mrt->mroute_do_pim ||
-		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
+		     IF_ISSET(true_vifi, &cache->mfc_un.res.mf6c_ifset)) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
@@ -2052,7 +2057,7 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 	 *	Forward the frame
 	 */
 	for (ct = cache->mfc_un.res.maxvif - 1; ct >= cache->mfc_un.res.minvif; ct--) {
-		if (ipv6_hdr(skb)->hop_limit > cache->mfc_un.res.ttls[ct]) {
+		if (IF_ISSET(ct, &cache->mfc_un.res.mf6c_ifset)) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2)
@@ -2143,7 +2148,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
-		if (MIF_EXISTS(mrt, ct) && c->mfc_un.res.ttls[ct] < 255) {
+		if (MIF_EXISTS(mrt, ct) && IF_ISSET(ct, &c->mfc_un.res.mf6c_ifset)) {
 			nhp = nla_reserve_nohdr(skb, sizeof(*nhp));
 			if (nhp == NULL) {
 				nla_nest_cancel(skb, mp_attr);
@@ -2151,7 +2156,7 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 			}
 
 			nhp->rtnh_flags = 0;
-			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
+			nhp->rtnh_hops = 1;	/* this is  broken as IPv6 does not use TTL threshold */
 			nhp->rtnh_ifindex = mrt->vif6_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
