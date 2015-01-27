From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next V2 1/1] dev: add per net_device packet type chains
Date: Tue, 27 Jan 2015 11:35:48 -0800
Message-ID: <1422387348-10885-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.aristanetworks.com ([162.210.130.12]:38378 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751897AbbA0Tfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:35:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When many pf_packet listeners are created on a lot of interfaces the
current implementation using global packet type lists scales poorly.
This patch adds per net_device packet type lists to fix this problem.

The patch was originally written by Eric Biederman for linux-2.6.29.
Tested on linux-3.16.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/linux/netdevice.h |   2 +
 net/core/dev.c            | 132 +++++++++++++++++++++++++++++-----------------
 2 files changed, 86 insertions(+), 48 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426..3d37c6e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1514,6 +1514,8 @@ struct net_device {
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
 	struct list_head	close_list;
+	struct list_head	ptype_all;
+	struct list_head	ptype_specific;
 
 	struct {
 		struct list_head upper;
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e325ad..a7b6c62 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -371,9 +371,10 @@ static inline void netdev_set_addr_lockdep_class(struct net_device *dev)
 static inline struct list_head *ptype_head(const struct packet_type *pt)
 {
 	if (pt->type == htons(ETH_P_ALL))
-		return &ptype_all;
+		return pt->dev ? &pt->dev->ptype_all : &ptype_all;
 	else
-		return &ptype_base[ntohs(pt->type) & PTYPE_HASH_MASK];
+		return pt->dev ? &pt->dev->ptype_specific :
+				 &ptype_base[ntohs(pt->type) & PTYPE_HASH_MASK];
 }
 
 /**
@@ -1734,6 +1735,23 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
+static inline void deliver_ptype_list_skb(struct sk_buff *skb,
+					  struct packet_type **pt,
+					  struct net_device *dev, __be16 type,
+					  struct list_head *ptype_list)
+{
+	struct packet_type *ptype, *pt_prev = *pt;
+
+	list_for_each_entry_rcu(ptype, ptype_list, list) {
+		if (ptype->type != type)
+			continue;
+		if (pt_prev)
+			deliver_skb(skb, pt_prev, dev);
+		pt_prev = ptype;
+	}
+	*pt = pt_prev;
+}
+
 static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
 {
 	if (!ptype->af_packet_priv || !skb->sk)
@@ -1757,45 +1775,54 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	struct packet_type *ptype;
 	struct sk_buff *skb2 = NULL;
 	struct packet_type *pt_prev = NULL;
+	struct list_head *ptype_list = &ptype_all;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+again:
+	list_for_each_entry_rcu(ptype, ptype_list, list) {
 		/* Never send packets back to the socket
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
-		if ((ptype->dev == dev || !ptype->dev) &&
-		    (!skb_loop_sk(ptype, skb))) {
-			if (pt_prev) {
-				deliver_skb(skb2, pt_prev, skb->dev);
-				pt_prev = ptype;
-				continue;
-			}
+		if (skb_loop_sk(ptype, skb))
+			continue;
 
-			skb2 = skb_clone(skb, GFP_ATOMIC);
-			if (!skb2)
-				break;
+		if (pt_prev) {
+			deliver_skb(skb2, pt_prev, skb->dev);
+			pt_prev = ptype;
+			continue;
+		}
 
-			net_timestamp_set(skb2);
+		/* need to clone skb, done only once */
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		if (!skb2)
+			goto out_unlock;
 
-			/* skb->nh should be correctly
-			   set by sender, so that the second statement is
-			   just protection against buggy protocols.
-			 */
-			skb_reset_mac_header(skb2);
-
-			if (skb_network_header(skb2) < skb2->data ||
-			    skb_network_header(skb2) > skb_tail_pointer(skb2)) {
-				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
-						     ntohs(skb2->protocol),
-						     dev->name);
-				skb_reset_network_header(skb2);
-			}
+		net_timestamp_set(skb2);
 
-			skb2->transport_header = skb2->network_header;
-			skb2->pkt_type = PACKET_OUTGOING;
-			pt_prev = ptype;
+		/* skb->nh should be correctly
+		 * set by sender, so that the second statement is
+		 * just protection against buggy protocols.
+		 */
+		skb_reset_mac_header(skb2);
+
+		if (skb_network_header(skb2) < skb2->data ||
+		    skb_network_header(skb2) > skb_tail_pointer(skb2)) {
+			net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
+					     ntohs(skb2->protocol),
+					     dev->name);
+			skb_reset_network_header(skb2);
 		}
+
+		skb2->transport_header = skb2->network_header;
+		skb2->pkt_type = PACKET_OUTGOING;
+		pt_prev = ptype;
+	}
+
+	if (ptype_list == &ptype_all) {
+		ptype_list = &dev->ptype_all;
+		goto again;
 	}
+out_unlock:
 	if (pt_prev)
 		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
@@ -2617,7 +2644,7 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 	unsigned int len;
 	int rc;
 
-	if (!list_empty(&ptype_all))
+	if (!list_empty(&ptype_all) || !list_empty(&dev->ptype_all))
 		dev_queue_xmit_nit(skb, dev);
 
 	len = skb->len;
@@ -3615,7 +3642,6 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
-	struct net_device *null_or_dev;
 	bool deliver_exact = false;
 	int ret = NET_RX_DROP;
 	__be16 type;
@@ -3658,11 +3684,15 @@ another_round:
 		goto skip_taps;
 
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev == skb->dev) {
-			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = ptype;
-		}
+		if (pt_prev)
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+		pt_prev = ptype;
+	}
+
+	list_for_each_entry_rcu(ptype, &skb->dev->ptype_all, list) {
+		if (pt_prev)
+			ret = deliver_skb(skb, pt_prev, orig_dev);
+		pt_prev = ptype;
 	}
 
 skip_taps:
@@ -3718,19 +3748,21 @@ ncls:
 		skb->vlan_tci = 0;
 	}
 
+	type = skb->protocol;
+
 	/* deliver only exact match when indicated */
-	null_or_dev = deliver_exact ? skb->dev : NULL;
+	if (likely(!deliver_exact)) {
+		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+				       &ptype_base[ntohs(type) &
+				       		   PTYPE_HASH_MASK]);
+	}
 
-	type = skb->protocol;
-	list_for_each_entry_rcu(ptype,
-			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type == type &&
-		    (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
-		     ptype->dev == orig_dev)) {
-			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = ptype;
-		}
+	deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+			       &orig_dev->ptype_specific);
+
+	if (unlikely(skb->dev != orig_dev)) {
+		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
+				       &skb->dev->ptype_specific);
 	}
 
 	if (pt_prev) {
@@ -6579,6 +6611,8 @@ void netdev_run_todo(void)
 
 		/* paranoia */
 		BUG_ON(netdev_refcnt_read(dev));
+		BUG_ON(!list_empty(&dev->ptype_all));
+		BUG_ON(!list_empty(&dev->ptype_specific));
 		WARN_ON(rcu_access_pointer(dev->ip_ptr));
 		WARN_ON(rcu_access_pointer(dev->ip6_ptr));
 		WARN_ON(dev->dn_ptr);
@@ -6761,6 +6795,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->adj_list.lower);
 	INIT_LIST_HEAD(&dev->all_adj_list.upper);
 	INIT_LIST_HEAD(&dev->all_adj_list.lower);
+	INIT_LIST_HEAD(&dev->ptype_all);
+	INIT_LIST_HEAD(&dev->ptype_specific);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
 	setup(dev);
 
-- 
1.8.1.4
