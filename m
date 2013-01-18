From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/2] mcast: add multicast proxy support (IPv4 and IPv6)
Date: Fri, 18 Jan 2013 17:59:38 +0100
Message-ID: <1358528378-2110-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49602 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3ARRHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 12:07:18 -0500
In-Reply-To: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the support of proxy multicast, ie being able to build a static
multicast tree. It adds the support of (*,*) and (*,G) entries.

The user should define an (*,*) entry which is not used for real forwarding.
This entry defines the upstream in iif and contains all interfaces from the
static tree in its oifs. It will be used to forward packet upstream when they
come from an interface belonging to the static tree.
Hence, the user should define (*,G) entries to build its static tree. Note that
upstream interface must be part of oifs: packets are sent to all oifs
interfaces except the input interface. This ensures to always join the whole
static tree, even if the packet is not coming from the upstream interface.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/mroute.h  |   4 +-
 include/uapi/linux/mroute6.h |   4 +-
 net/ipv4/ipmr.c              | 118 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/ip6mr.c             | 126 ++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 224 insertions(+), 28 deletions(-)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index 1c11004..a382d2c 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -26,7 +26,9 @@
 #define MRT_ASSERT	(MRT_BASE+7)	/* Activate PIM assert mode		*/
 #define MRT_PIM		(MRT_BASE+8)	/* enable PIM code			*/
 #define MRT_TABLE	(MRT_BASE+9)	/* Specify mroute table ID		*/
-#define MRT_MAX		(MRT_BASE+9)
+#define MRT_ADD_MFC_PROXY	(MRT_BASE+10)	/* Add a (*,*|G) mfc entry	*/
+#define MRT_DEL_MFC_PROXY	(MRT_BASE+11)	/* Del a (*,*|G) mfc entry	*/
+#define MRT_MAX		(MRT_BASE+11)
 
 #define SIOCGETVIFCNT	SIOCPROTOPRIVATE	/* IP protocol privates */
 #define SIOCGETSGCNT	(SIOCPROTOPRIVATE+1)
diff --git a/include/uapi/linux/mroute6.h b/include/uapi/linux/mroute6.h
index c206ae3..ce91215 100644
--- a/include/uapi/linux/mroute6.h
+++ b/include/uapi/linux/mroute6.h
@@ -26,7 +26,9 @@
 #define MRT6_ASSERT	(MRT6_BASE+7)	/* Activate PIM assert mode		*/
 #define MRT6_PIM	(MRT6_BASE+8)	/* enable PIM code			*/
 #define MRT6_TABLE	(MRT6_BASE+9)	/* Specify mroute table ID		*/
-#define MRT6_MAX	(MRT6_BASE+9)
+#define MRT6_ADD_MFC_PROXY	(MRT6_BASE+10)	/* Add a (*,*|G) mfc entry	*/
+#define MRT6_DEL_MFC_PROXY	(MRT6_BASE+11)	/* Del a (*,*|G) mfc entry	*/
+#define MRT6_MAX	(MRT6_BASE+11)
 
 #define SIOCGETMIFCNT_IN6	SIOCPROTOPRIVATE	/* IP protocol privates */
 #define SIOCGETSGCNT_IN6	(SIOCPROTOPRIVATE+1)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a9454cb..e8ec94a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -828,6 +828,48 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 	return NULL;
 }
 
+/* Look for a (*,*,oif) entry */
+static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table *mrt,
+						    int vifi)
+{
+	int line = MFC_HASH(0, 0);
+	struct mfc_cache *c;
+
+	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
+		if (c->mfc_origin == 0 &&
+		    c->mfc_mcastgrp == 0 &&
+		    c->mfc_un.res.ttls[vifi] < 255)
+			return c;
+
+	return NULL;
+}
+
+/* Look for a (*,G) entry */
+static struct mfc_cache *ipmr_cache_find_any(struct mr_table *mrt,
+					     __be32 mcastgrp, int vifi)
+{
+	int line = MFC_HASH(mcastgrp, 0);
+	struct mfc_cache *c, *proxy;
+
+	if (!mcastgrp)
+		goto skip;
+
+	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
+		if (c->mfc_origin == 0 && c->mfc_mcastgrp == mcastgrp) {
+			if (c->mfc_un.res.ttls[vifi] < 255)
+				return c;
+
+			/* It's ok if the vifi is part of the static tree */
+			proxy = ipmr_cache_find_any_parent(mrt,
+							   c->mfc_parent);
+			if (proxy && proxy->mfc_un.res.ttls[vifi] < 255)
+				return c;
+		}
+
+skip:
+	return ipmr_cache_find_any_parent(mrt, vifi);
+}
+
 /*
  *	Allocate a multicast cache entry
  */
@@ -1053,7 +1095,7 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
  *	MFC cache manipulation by user space mroute daemon
  */
 
-static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
+static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
 {
 	int line;
 	struct mfc_cache *c, *next;
@@ -1062,7 +1104,8 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
 
 	list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
-		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
+		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr &&
+		    (parent == -1 || parent == c->mfc_parent)) {
 			list_del_rcu(&c->list);
 			mroute_netlink_event(mrt, c, RTM_DELROUTE);
 			ipmr_cache_free(c);
@@ -1073,7 +1116,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc)
 }
 
 static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
-			struct mfcctl *mfc, int mrtsock)
+			struct mfcctl *mfc, int mrtsock, int parent)
 {
 	bool found = false;
 	int line;
@@ -1086,7 +1129,8 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 
 	list_for_each_entry(c, &mrt->mfc_cache_array[line], list) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
-		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
+		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr &&
+		    (parent == -1 || parent == c->mfc_parent)) {
 			found = true;
 			break;
 		}
@@ -1103,7 +1147,8 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		return 0;
 	}
 
-	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
+	if (mfc->mfcc_mcastgrp.s_addr &&
+	    !ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
 	c = ipmr_cache_alloc();
@@ -1218,7 +1263,7 @@ static void mrtsock_destruct(struct sock *sk)
 
 int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
 {
-	int ret;
+	int ret, parent = 0;
 	struct vifctl vif;
 	struct mfcctl mfc;
 	struct net *net = sock_net(sk);
@@ -1287,16 +1332,22 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		 */
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
+		parent = -1;
+	case MRT_ADD_MFC_PROXY:
+	case MRT_DEL_MFC_PROXY:
 		if (optlen != sizeof(mfc))
 			return -EINVAL;
 		if (copy_from_user(&mfc, optval, sizeof(mfc)))
 			return -EFAULT;
+		if (parent == 0)
+			parent = mfc.mfcc_parent;
 		rtnl_lock();
-		if (optname == MRT_DEL_MFC)
-			ret = ipmr_mfc_delete(mrt, &mfc);
+		if (optname == MRT_DEL_MFC || optname == MRT_DEL_MFC_PROXY)
+			ret = ipmr_mfc_delete(mrt, &mfc, parent);
 		else
 			ret = ipmr_mfc_add(net, mrt, &mfc,
-					   sk == rtnl_dereference(mrt->mroute_sk));
+					   sk == rtnl_dereference(mrt->mroute_sk),
+					   parent);
 		rtnl_unlock();
 		return ret;
 		/*
@@ -1749,17 +1800,28 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 {
 	int psend = -1;
 	int vif, ct;
+	int true_vifi = ipmr_find_vif(mrt, skb->dev);
 
 	vif = cache->mfc_parent;
 	cache->mfc_un.res.pkt++;
 	cache->mfc_un.res.bytes += skb->len;
 
+	if (cache->mfc_origin == 0 && true_vifi >= 0) {
+		struct mfc_cache *cache_proxy;
+
+		/* For an (*,G) entry, we only check that the incomming
+		 * interface is part of the static tree.
+		 */
+		cache_proxy = ipmr_cache_find_any_parent(mrt, vif);
+		if (cache_proxy &&
+		    cache_proxy->mfc_un.res.ttls[true_vifi] < 255)
+			goto forward;
+	}
+
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
 	if (mrt->vif_table[vif].dev != skb->dev) {
-		int true_vifi;
-
 		if (rt_is_output_route(skb_rtable(skb))) {
 			/* It is our own packet, looped back.
 			 * Very complicated situation...
@@ -1776,7 +1838,6 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 		}
 
 		cache->mfc_un.res.wrong_if++;
-		true_vifi = ipmr_find_vif(mrt, skb->dev);
 
 		if (true_vifi >= 0 && mrt->mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
@@ -1794,15 +1855,33 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 		goto dont_forward;
 	}
 
+forward:
 	mrt->vif_table[vif].pkt_in++;
 	mrt->vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
 	 */
+	if (cache->mfc_origin == 0 &&
+	    cache->mfc_mcastgrp == 0) {
+		if (true_vifi >= 0 &&
+		    true_vifi != cache->mfc_parent &&
+		    ip_hdr(skb)->ttl >
+				cache->mfc_un.res.ttls[cache->mfc_parent]) {
+			/* It's an (*,*) entry and the packet is not coming from
+			 * the upstream: forward the packet to the upstream
+			 * only.
+			 */
+			psend = cache->mfc_parent;
+			goto last_forward;
+		}
+		goto dont_forward;
+	}
 	for (ct = cache->mfc_un.res.maxvif - 1;
 	     ct >= cache->mfc_un.res.minvif; ct--) {
-		if (ip_hdr(skb)->ttl > cache->mfc_un.res.ttls[ct]) {
+		/* For (*,G) entry, don't forward to the incoming interface */
+		if ((cache->mfc_origin || ct != true_vifi) &&
+		    ip_hdr(skb)->ttl > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
@@ -1813,6 +1892,7 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 			psend = ct;
 		}
 	}
+last_forward:
 	if (psend != -1) {
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -1902,6 +1982,13 @@ int ip_mr_input(struct sk_buff *skb)
 
 	/* already under rcu_read_lock() */
 	cache = ipmr_cache_find(mrt, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
+	if (cache == NULL) {
+		int vif = ipmr_find_vif(mrt, skb->dev);
+
+		if (vif >= 0)
+			cache = ipmr_cache_find_any(mrt, ip_hdr(skb)->daddr,
+						    vif);
+	}
 
 	/*
 	 *	No usable cache entry
@@ -2107,7 +2194,12 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 
 	rcu_read_lock();
 	cache = ipmr_cache_find(mrt, saddr, daddr);
+	if (cache == NULL && skb->dev) {
+		int vif = ipmr_find_vif(mrt, skb->dev);
 
+		if (vif >= 0)
+			cache = ipmr_cache_find_any(mrt, daddr, vif);
+	}
 	if (cache == NULL) {
 		struct sk_buff *skb2;
 		struct iphdr *iph;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 26dcdec..acc3249 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1017,6 +1017,50 @@ static struct mfc6_cache *ip6mr_cache_find(struct mr6_table *mrt,
 	return NULL;
 }
 
+/* Look for a (*,*,oif) entry */
+static struct mfc6_cache *ip6mr_cache_find_any_parent(struct mr6_table *mrt,
+						      mifi_t mifi)
+{
+	int line = MFC6_HASH(&in6addr_any, &in6addr_any);
+	struct mfc6_cache *c;
+
+	list_for_each_entry(c, &mrt->mfc6_cache_array[line], list)
+		if (ipv6_addr_any(&c->mf6c_origin) &&
+		    ipv6_addr_any(&c->mf6c_mcastgrp) &&
+		    (c->mfc_un.res.ttls[mifi] < 255))
+			return c;
+
+	return NULL;
+}
+
+/* Look for a (*,G) entry */
+static struct mfc6_cache *ip6mr_cache_find_any(struct mr6_table *mrt,
+					       struct in6_addr *mcastgrp,
+					       mifi_t mifi)
+{
+	int line = MFC6_HASH(mcastgrp, &in6addr_any);
+	struct mfc6_cache *c, *proxy;
+
+	if (ipv6_addr_any(mcastgrp))
+		goto skip;
+
+	list_for_each_entry(c, &mrt->mfc6_cache_array[line], list)
+		if (ipv6_addr_any(&c->mf6c_origin) &&
+		    ipv6_addr_equal(&c->mf6c_mcastgrp, mcastgrp)) {
+			if (c->mfc_un.res.ttls[mifi] < 255)
+				return c;
+
+			/* It's ok if the mifi is part of the static tree */
+			proxy = ip6mr_cache_find_any_parent(mrt,
+							    c->mf6c_parent);
+			if (proxy && proxy->mfc_un.res.ttls[mifi] < 255)
+				return c;
+		}
+
+skip:
+	return ip6mr_cache_find_any_parent(mrt, mifi);
+}
+
 /*
  *	Allocate a multicast cache entry
  */
@@ -1247,7 +1291,8 @@ ip6mr_cache_unresolved(struct mr6_table *mrt, mifi_t mifi, struct sk_buff *skb)
  *	MFC6 cache manipulation by user space
  */
 
-static int ip6mr_mfc_delete(struct mr6_table *mrt, struct mf6cctl *mfc)
+static int ip6mr_mfc_delete(struct mr6_table *mrt, struct mf6cctl *mfc,
+			    int parent)
 {
 	int line;
 	struct mfc6_cache *c, *next;
@@ -1256,7 +1301,9 @@ static int ip6mr_mfc_delete(struct mr6_table *mrt, struct mf6cctl *mfc)
 
 	list_for_each_entry_safe(c, next, &mrt->mfc6_cache_array[line], list) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
-		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr)) {
+		    ipv6_addr_equal(&c->mf6c_mcastgrp,
+				    &mfc->mf6cc_mcastgrp.sin6_addr) &&
+		    (parent == -1 || parent == c->mf6c_parent)) {
 			write_lock_bh(&mrt_lock);
 			list_del(&c->list);
 			write_unlock_bh(&mrt_lock);
@@ -1391,7 +1438,7 @@ void ip6_mr_cleanup(void)
 }
 
 static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
-			 struct mf6cctl *mfc, int mrtsock)
+			 struct mf6cctl *mfc, int mrtsock, int parent)
 {
 	bool found = false;
 	int line;
@@ -1413,7 +1460,9 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 
 	list_for_each_entry(c, &mrt->mfc6_cache_array[line], list) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
-		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr)) {
+		    ipv6_addr_equal(&c->mf6c_mcastgrp,
+				    &mfc->mf6cc_mcastgrp.sin6_addr) &&
+		    (parent == -1 || parent == mfc->mf6cc_parent)) {
 			found = true;
 			break;
 		}
@@ -1430,7 +1479,8 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 		return 0;
 	}
 
-	if (!ipv6_addr_is_multicast(&mfc->mf6cc_mcastgrp.sin6_addr))
+	if (!ipv6_addr_any(&mfc->mf6cc_mcastgrp.sin6_addr) &&
+	    !ipv6_addr_is_multicast(&mfc->mf6cc_mcastgrp.sin6_addr))
 		return -EINVAL;
 
 	c = ip6mr_cache_alloc();
@@ -1596,7 +1646,7 @@ struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
 
 int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
 {
-	int ret;
+	int ret, parent = 0;
 	struct mif6ctl vif;
 	struct mf6cctl mfc;
 	mifi_t mifi;
@@ -1653,15 +1703,21 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	 */
 	case MRT6_ADD_MFC:
 	case MRT6_DEL_MFC:
+		parent = -1;
+	case MRT6_ADD_MFC_PROXY:
+	case MRT6_DEL_MFC_PROXY:
 		if (optlen < sizeof(mfc))
 			return -EINVAL;
 		if (copy_from_user(&mfc, optval, sizeof(mfc)))
 			return -EFAULT;
+		if (parent == 0)
+			parent = mfc.mf6cc_parent;
 		rtnl_lock();
-		if (optname == MRT6_DEL_MFC)
-			ret = ip6mr_mfc_delete(mrt, &mfc);
+		if (optname == MRT6_DEL_MFC || optname == MRT6_DEL_MFC_PROXY)
+			ret = ip6mr_mfc_delete(mrt, &mfc, parent);
 		else
-			ret = ip6mr_mfc_add(net, mrt, &mfc, sk == mrt->mroute6_sk);
+			ret = ip6mr_mfc_add(net, mrt, &mfc,
+					    sk == mrt->mroute6_sk, parent);
 		rtnl_unlock();
 		return ret;
 
@@ -2015,19 +2071,29 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 {
 	int psend = -1;
 	int vif, ct;
+	int true_vifi = ip6mr_find_vif(mrt, skb->dev);
 
 	vif = cache->mf6c_parent;
 	cache->mfc_un.res.pkt++;
 	cache->mfc_un.res.bytes += skb->len;
 
+	if (ipv6_addr_any(&cache->mf6c_origin) && true_vifi >= 0) {
+		struct mfc6_cache *cache_proxy;
+
+		/* For an (*,G) entry, we only check that the incomming
+		 * interface is part of the static tree.
+		 */
+		cache_proxy = ip6mr_cache_find_any_parent(mrt, vif);
+		if (cache_proxy &&
+		    cache_proxy->mfc_un.res.ttls[true_vifi] < 255)
+			goto forward;
+	}
+
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
 	if (mrt->vif6_table[vif].dev != skb->dev) {
-		int true_vifi;
-
 		cache->mfc_un.res.wrong_if++;
-		true_vifi = ip6mr_find_vif(mrt, skb->dev);
 
 		if (true_vifi >= 0 && mrt->mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
@@ -2045,14 +2111,32 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 		goto dont_forward;
 	}
 
+forward:
 	mrt->vif6_table[vif].pkt_in++;
 	mrt->vif6_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
 	 */
+	if (ipv6_addr_any(&cache->mf6c_origin) &&
+	    ipv6_addr_any(&cache->mf6c_mcastgrp)) {
+		if (true_vifi >= 0 &&
+		    true_vifi != cache->mf6c_parent &&
+		    ipv6_hdr(skb)->hop_limit >
+				cache->mfc_un.res.ttls[cache->mf6c_parent]) {
+			/* It's an (*,*) entry and the packet is not coming from
+			 * the upstream: forward the packet to the upstream
+			 * only.
+			 */
+			psend = cache->mf6c_parent;
+			goto last_forward;
+		}
+		goto dont_forward;
+	}
 	for (ct = cache->mfc_un.res.maxvif - 1; ct >= cache->mfc_un.res.minvif; ct--) {
-		if (ipv6_hdr(skb)->hop_limit > cache->mfc_un.res.ttls[ct]) {
+		/* For (*,G) entry, don't forward to the incoming interface */
+		if ((!ipv6_addr_any(&cache->mf6c_origin) || ct != true_vifi) &&
+		    ipv6_hdr(skb)->hop_limit > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2)
@@ -2061,6 +2145,7 @@ static int ip6_mr_forward(struct net *net, struct mr6_table *mrt,
 			psend = ct;
 		}
 	}
+last_forward:
 	if (psend != -1) {
 		ip6mr_forward2(net, mrt, skb, cache, psend);
 		return 0;
@@ -2096,6 +2181,14 @@ int ip6_mr_input(struct sk_buff *skb)
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt,
 				 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr);
+	if (cache == NULL) {
+		int vif = ip6mr_find_vif(mrt, skb->dev);
+
+		if (vif >= 0)
+			cache = ip6mr_cache_find_any(mrt,
+						     &ipv6_hdr(skb)->daddr,
+						     vif);
+	}
 
 	/*
 	 *	No usable cache entry
@@ -2183,6 +2276,13 @@ int ip6mr_get_route(struct net *net,
 
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt, &rt->rt6i_src.addr, &rt->rt6i_dst.addr);
+	if (!cache && skb->dev) {
+		int vif = ip6mr_find_vif(mrt, skb->dev);
+
+		if (vif >= 0)
+			cache = ip6mr_cache_find_any(mrt, &rt->rt6i_dst.addr,
+						     vif);
+	}
 
 	if (!cache) {
 		struct sk_buff *skb2;
-- 
1.8.0.1
