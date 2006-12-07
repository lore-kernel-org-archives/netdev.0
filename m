From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert hh_lock to seqlock
Date: Thu, 7 Dec 2006 11:33:09 -0800
Message-ID: <20061207113309.2f892cf1@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:59248 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938001AbWLGTdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 14:33:21 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hard header cache is in the main output path, so using
seqlock instead of reader/writer lock should reduce overhead.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netdevice.h |    2 +-
 include/net/neighbour.h   |   18 ++++++++++++++++++
 net/core/neighbour.c      |   11 ++++++-----
 net/ipv4/ip_output.c      |   14 +++-----------
 net/ipv6/ip6_output.c     |   15 +++------------
 5 files changed, 31 insertions(+), 29 deletions(-)

--- linux-2.6.19.orig/include/linux/netdevice.h	2006-12-05 13:55:54.000000000 -0800
+++ linux-2.6.19/include/linux/netdevice.h	2006-12-06 10:29:15.000000000 -0800
@@ -199,7 +199,7 @@
                                          */
 	u16		hh_len;		/* length of header */
 	int		(*hh_output)(struct sk_buff *skb);
-	rwlock_t	hh_lock;
+	seqlock_t	hh_lock;
 
 	/* cached hardware header; allow for machine alignment needs.        */
 #define HH_DATA_MOD	16
--- linux-2.6.19.orig/include/net/neighbour.h	2006-12-05 13:36:16.000000000 -0800
+++ linux-2.6.19/include/net/neighbour.h	2006-12-06 14:53:52.000000000 -0800
@@ -309,6 +309,24 @@
 	return 0;
 }
 
+static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
+{
+	unsigned seq;
+	int hh_len;
+
+	do {
+		int hh_alen;
+
+		seq = read_seqbegin(&hh->hh_lock);
+		hh_len = hh->hh_len;
+		hh_alen = HH_DATA_ALIGN(hh_len);
+		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
+	} while (read_seqretry(&hh->hh_lock, seq));
+
+	skb_push(skb, hh_len);
+	return hh->hh_output(skb);
+}
+
 static inline struct neighbour *
 __neigh_lookup(struct neigh_table *tbl, const void *pkey, struct net_device *dev, int creat)
 {
--- linux-2.6.19.orig/net/core/neighbour.c	2006-12-05 13:55:54.000000000 -0800
+++ linux-2.6.19/net/core/neighbour.c	2006-12-06 10:29:15.000000000 -0800
@@ -577,9 +577,10 @@
 	while ((hh = neigh->hh) != NULL) {
 		neigh->hh = hh->hh_next;
 		hh->hh_next = NULL;
-		write_lock_bh(&hh->hh_lock);
+
+		write_seqlock_bh(&hh->hh_lock);
 		hh->hh_output = neigh_blackhole;
-		write_unlock_bh(&hh->hh_lock);
+		write_sequnlock_bh(&hh->hh_lock);
 		if (atomic_dec_and_test(&hh->hh_refcnt))
 			kfree(hh);
 	}
@@ -897,9 +898,9 @@
 
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
@@ -1089,7 +1090,7 @@
 			break;
 
 	if (!hh && (hh = kzalloc(sizeof(*hh), GFP_ATOMIC)) != NULL) {
-		rwlock_init(&hh->hh_lock);
+		seqlock_init(&hh->hh_lock);
 		hh->hh_type = protocol;
 		atomic_set(&hh->hh_refcnt, 0);
 		hh->hh_next = NULL;
--- linux-2.6.19.orig/net/ipv4/ip_output.c	2006-12-05 13:55:54.000000000 -0800
+++ linux-2.6.19/net/ipv4/ip_output.c	2006-12-06 10:29:15.000000000 -0800
@@ -164,7 +164,6 @@
 static inline int ip_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
-	struct hh_cache *hh = dst->hh;
 	struct net_device *dev = dst->dev;
 	int hh_len = LL_RESERVED_SPACE(dev);
 
@@ -183,16 +182,9 @@
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
+	if (dst->hh)
+		return neigh_hh_output(dst->hh, skb);
+	else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
 	if (net_ratelimit())
--- linux-2.6.19.orig/net/ipv6/ip6_output.c	2006-12-05 13:55:54.000000000 -0800
+++ linux-2.6.19/net/ipv6/ip6_output.c	2006-12-06 10:33:24.000000000 -0800
@@ -72,20 +72,11 @@
 
 static inline int ip6_output_finish(struct sk_buff *skb)
 {
-
 	struct dst_entry *dst = skb->dst;
-	struct hh_cache *hh = dst->hh;
-
-	if (hh) {
-		int hh_alen;
 
-		read_lock_bh(&hh->hh_lock);
-		hh_alen = HH_DATA_ALIGN(hh->hh_len);
-		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
-		read_unlock_bh(&hh->hh_lock);
-	        skb_push(skb, hh->hh_len);
-		return hh->hh_output(skb);
-	} else if (dst->neighbour)
+	if (dst->hh)
+		return neigh_hh_output(dst->hh, skb);
+	else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
 	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
