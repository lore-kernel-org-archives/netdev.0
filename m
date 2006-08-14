From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 6/7] neighbour: convert hard header cache to sequence number
Date: Mon, 14 Aug 2006 14:20:10 -0700
Message-ID: <20060814212144.065091071@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53737 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964961AbWHNVYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:21 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=hardheader-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reading of the hard header cache in the output path can be
made lockless using seqlock.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/linux/netdevice.h |    3 ++-
 include/net/neighbour.h   |    2 ++
 net/core/neighbour.c      |   40 +++++++++++++++++++++++++++++++++++-----
 net/ipv4/ip_output.c      |   13 +++----------
 net/ipv6/ip6_output.c     |   13 +++----------
 5 files changed, 45 insertions(+), 26 deletions(-)

--- net-2.6.19.orig/include/linux/netdevice.h
+++ net-2.6.19/include/linux/netdevice.h
@@ -193,7 +193,7 @@ struct hh_cache
                                          */
 	int		hh_len;		/* length of header */
 	int		(*hh_output)(struct sk_buff *skb);
-	rwlock_t	hh_lock;
+	seqlock_t	hh_lock;
 
 	/* cached hardware header; allow for machine alignment needs.        */
 #define HH_DATA_MOD	16
@@ -217,6 +217,7 @@ struct hh_cache
 #define LL_RESERVED_SPACE_EXTRA(dev,extra) \
 	((((dev)->hard_header_len+extra)&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)
 
+
 /* These flag bits are private to the generic network queueing
  * layer, they may not be explicitly referenced by any other
  * code.
--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -591,9 +591,11 @@ void neigh_destroy(struct neighbour *nei
 	while ((hh = neigh->hh) != NULL) {
 		neigh->hh = hh->hh_next;
 		hh->hh_next = NULL;
-		write_lock_bh(&hh->hh_lock);
+
+		write_seqlock_bh(&hh->hh_lock);
 		hh->hh_output = neigh_blackhole;
-		write_unlock_bh(&hh->hh_lock);
+		write_sequnlock_bh(&hh->hh_lock);
+
 		if (atomic_dec_and_test(&hh->hh_refcnt))
 			kfree(hh);
 	}
@@ -912,9 +914,9 @@ static __inline__ void neigh_update_hhs(
 
 	if (update) {
 		for (hh = neigh->hh; hh; hh = hh->hh_next) {
-			write_lock_bh(&hh->hh_lock);
+			write_seqlock_bh(&hh->hh_lock);
 			update(hh, neigh->dev, neigh->ha);
-			write_unlock_bh(&hh->hh_lock);
+			write_sequnlock_bh(&hh->hh_lock);
 		}
 	}
 }
@@ -1105,7 +1107,7 @@ static void neigh_hh_init(struct neighbo
 			break;
 
 	if (!hh && (hh = kzalloc(sizeof(*hh), GFP_ATOMIC)) != NULL) {
-		rwlock_init(&hh->hh_lock);
+		seqlock_init(&hh->hh_lock);
 		hh->hh_type = protocol;
 		atomic_set(&hh->hh_refcnt, 0);
 		hh->hh_next = NULL;
@@ -1128,6 +1130,33 @@ static void neigh_hh_init(struct neighbo
 	}
 }
 
+
+/*
+ * Add header to skb from hard header cache
+ * Handle case where cache gets changed.
+ */
+int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb)
+{
+	int len, alen;
+	unsigned seq;
+	int (*output)(struct sk_buff *);
+
+	for(;;) {
+		seq = read_seqbegin(&hh->hh_lock);
+		len = hh->hh_len;
+		alen = HH_DATA_ALIGN(len);
+		output = hh->hh_output;
+		memcpy(skb->data - alen, hh->hh_data, alen);
+		skb_push(skb, len);
+
+		if (likely(!read_seqretry(&hh->hh_lock, seq)))
+			return output(skb);
+
+		/* undo and try again */
+		__skb_pull(skb, len);
+	}
+}
+
 /* This function can be used in contexts, where only old dev_queue_xmit
    worked, f.e. if you want to override normal output path (eql, shaper),
    but resolution is not made yet.
@@ -2762,6 +2791,7 @@ EXPORT_SYMBOL(neigh_delete);
 EXPORT_SYMBOL(neigh_destroy);
 EXPORT_SYMBOL(neigh_dump_info);
 EXPORT_SYMBOL(neigh_event_ns);
+EXPORT_SYMBOL(neigh_hh_output);
 EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
 EXPORT_SYMBOL(neigh_lookup_nodev);
--- net-2.6.19.orig/net/ipv4/ip_output.c
+++ net-2.6.19/net/ipv4/ip_output.c
@@ -182,16 +182,9 @@ static inline int ip_finish_output2(stru
 		skb = skb2;
 	}
 
-	if (hh) {
-		int hh_alen;
-
-		read_lock_bh(&hh->hh_lock);
-		hh_alen = HH_DATA_ALIGN(hh->hh_len);
-  		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
-		read_unlock_bh(&hh->hh_lock);
-	        skb_push(skb, hh->hh_len);
-		return hh->hh_output(skb);
-	} else if (dst->neighbour)
+	if (hh)
+		return neigh_hh_output(hh, skb);
+	else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
 	if (net_ratelimit())
--- net-2.6.19.orig/net/ipv6/ip6_output.c
+++ net-2.6.19/net/ipv6/ip6_output.c
@@ -76,16 +76,9 @@ static inline int ip6_output_finish(stru
 	struct dst_entry *dst = skb->dst;
 	struct hh_cache *hh = dst->hh;
 
-	if (hh) {
-		int hh_alen;
-
-		read_lock_bh(&hh->hh_lock);
-		hh_alen = HH_DATA_ALIGN(hh->hh_len);
-		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
-		read_unlock_bh(&hh->hh_lock);
-	        skb_push(skb, hh->hh_len);
-		return hh->hh_output(skb);
-	} else if (dst->neighbour)
+	if (hh)
+		return neigh_hh_output(hh, skb);
+	else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
 	IP6_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -193,6 +193,8 @@ extern struct neighbour *	neigh_create(s
 					     struct net_device *dev);
 extern void			neigh_destroy(struct neighbour *neigh);
 extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
+extern int			neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb);
+
 extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, 
 					     u32 flags);
 extern void			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);

--

