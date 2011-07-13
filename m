From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] net: Kill support for multiple hh_cache entries per
 neighbour
Date: Wed, 13 Jul 2011 01:52:19 -0700 (PDT)
Message-ID: <20110713.015219.536998335014077636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965064Ab1GMIwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 04:52:20 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6D8qJ63016961
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 01:52:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This never, ever, happens.

Neighbour entries are always tied to one address family, and therefore
one set of dst_ops, and therefore one dst_ops->protocol "hh_type"
value.

This capability was blindly imported by Alexey Kuznetsov when he wrote
the neighbour layer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    9 ++-------
 net/core/neighbour.c      |   37 ++++++++++++++++++-------------------
 2 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 564d89f..7538237 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -252,7 +252,6 @@ struct netdev_hw_addr_list {
 	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
 struct hh_cache {
-	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
 /*
  * We want hh_output, hh_len, hh_lock and hh_data be a in a separate
@@ -260,12 +259,8 @@ struct hh_cache {
  * They are mostly read, but hh_refcnt may be changed quite frequently,
  * incurring cache line ping pongs.
  */
-	__be16		hh_type ____cacheline_aligned_in_smp;
-					/* protocol identifier, f.e ETH_P_IP
-                                         *  NOTE:  For VLANs, this will be the
-                                         *  encapuslated type. --BLG
-                                         */
-	u16		hh_len;		/* length of header */
+	u16		hh_len ____cacheline_aligned_in_smp;
+	u16		__pad;
 	int		(*hh_output)(struct sk_buff *skb);
 	seqlock_t	hh_lock;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8f7e1d8..f879bb5 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -702,9 +702,9 @@ void neigh_destroy(struct neighbour *neigh)
 	if (neigh_del_timer(neigh))
 		printk(KERN_WARNING "Impossible event.\n");
 
-	while ((hh = neigh->hh) != NULL) {
-		neigh->hh = hh->hh_next;
-		hh->hh_next = NULL;
+	hh = neigh->hh;
+	if (hh) {
+		neigh->hh = NULL;
 
 		write_seqlock_bh(&hh->hh_lock);
 		hh->hh_output = neigh_blackhole;
@@ -737,7 +737,8 @@ static void neigh_suspect(struct neighbour *neigh)
 
 	neigh->output = neigh->ops->output;
 
-	for (hh = neigh->hh; hh; hh = hh->hh_next)
+	hh = neigh->hh;
+	if (hh)
 		hh->hh_output = neigh->ops->output;
 }
 
@@ -754,7 +755,8 @@ static void neigh_connect(struct neighbour *neigh)
 
 	neigh->output = neigh->ops->connected_output;
 
-	for (hh = neigh->hh; hh; hh = hh->hh_next)
+	hh = neigh->hh;
+	if (hh)
 		hh->hh_output = neigh->ops->hh_output;
 }
 
@@ -1025,7 +1027,8 @@ static void neigh_update_hhs(const struct neighbour *neigh)
 		update = neigh->dev->header_ops->cache_update;
 
 	if (update) {
-		for (hh = neigh->hh; hh; hh = hh->hh_next) {
+		hh = neigh->hh;
+		if (hh) {
 			write_seqlock_bh(&hh->hh_lock);
 			update(hh, neigh->dev, neigh->ha);
 			write_sequnlock_bh(&hh->hh_lock);
@@ -1211,19 +1214,17 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 }
 EXPORT_SYMBOL(neigh_event_ns);
 
-static inline bool neigh_hh_lookup(struct neighbour *n, struct dst_entry *dst,
-				   __be16 protocol)
+static inline bool neigh_hh_lookup(struct neighbour *n, struct dst_entry *dst)
 {
 	struct hh_cache *hh;
 
 	smp_rmb(); /* paired with smp_wmb() in neigh_hh_init() */
-	for (hh = n->hh; hh; hh = hh->hh_next) {
-		if (hh->hh_type == protocol) {
-			atomic_inc(&hh->hh_refcnt);
-			if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
-				hh_cache_put(hh);
-			return true;
-		}
+	hh = n->hh;
+	if (hh) {
+		atomic_inc(&hh->hh_refcnt);
+		if (unlikely(cmpxchg(&dst->hh, NULL, hh) != NULL))
+			hh_cache_put(hh);
+		return true;
 	}
 	return false;
 }
@@ -1235,7 +1236,7 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 	struct hh_cache	*hh;
 	struct net_device *dev = dst->dev;
 
-	if (likely(neigh_hh_lookup(n, dst, protocol)))
+	if (likely(neigh_hh_lookup(n, dst)))
 		return;
 
 	/* slow path */
@@ -1244,7 +1245,6 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 		return;
 
 	seqlock_init(&hh->hh_lock);
-	hh->hh_type = protocol;
 	atomic_set(&hh->hh_refcnt, 2);
 
 	if (dev->header_ops->cache(n, hh, protocol)) {
@@ -1255,7 +1255,7 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 	write_lock_bh(&n->lock);
 
 	/* must check if another thread already did the insert */
-	if (neigh_hh_lookup(n, dst, protocol)) {
+	if (neigh_hh_lookup(n, dst)) {
 		kfree(hh);
 		goto end;
 	}
@@ -1265,7 +1265,6 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 	else
 		hh->hh_output = n->ops->output;
 
-	hh->hh_next = n->hh;
 	smp_wmb(); /* paired with smp_rmb() in neigh_hh_lookup() */
 	n->hh	    = hh;
 
-- 
1.7.6

