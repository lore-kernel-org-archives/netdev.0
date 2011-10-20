From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: constify skbuff and Qdisc elements
Date: Thu, 20 Oct 2011 23:41:57 +0200
Message-ID: <1319146917.2854.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56994 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab1JTVmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:42:02 -0400
Received: by wyg36 with SMTP id 36so3361015wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 14:42:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary patch before tcp constification

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h    |   17 +++++++++--------
 include/net/sch_generic.h |   24 ++++++++++++------------
 2 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1ebf1ea..3411f22 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -853,9 +853,9 @@ static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
  *	The reference count is not incremented and the reference is therefore
  *	volatile. Use with caution.
  */
-static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
+static inline struct sk_buff *skb_peek(const struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((struct sk_buff *)list_)->next;
+	struct sk_buff *list = ((const struct sk_buff *)list_)->next;
 	if (list == (struct sk_buff *)list_)
 		list = NULL;
 	return list;
@@ -874,9 +874,9 @@ static inline struct sk_buff *skb_peek(struct sk_buff_head *list_)
  *	The reference count is not incremented and the reference is therefore
  *	volatile. Use with caution.
  */
-static inline struct sk_buff *skb_peek_tail(struct sk_buff_head *list_)
+static inline struct sk_buff *skb_peek_tail(const struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((struct sk_buff *)list_)->prev;
+	struct sk_buff *list = ((const struct sk_buff *)list_)->prev;
 	if (list == (struct sk_buff *)list_)
 		list = NULL;
 	return list;
@@ -1830,7 +1830,7 @@ static inline dma_addr_t skb_frag_dma_map(struct device *dev,
  *	Returns true if modifying the header part of the cloned buffer
  *	does not requires the data to be copied.
  */
-static inline int skb_clone_writable(struct sk_buff *skb, unsigned int len)
+static inline int skb_clone_writable(const struct sk_buff *skb, unsigned int len)
 {
 	return !skb_header_cloned(skb) &&
 	       skb_headroom(skb) + len <= skb->hdr_len;
@@ -2451,7 +2451,8 @@ static inline bool skb_warn_if_lro(const struct sk_buff *skb)
 {
 	/* LRO sets gso_size but not gso_type, whereas if GSO is really
 	 * wanted then gso_type will be set. */
-	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+
 	if (skb_is_nonlinear(skb) && shinfo->gso_size != 0 &&
 	    unlikely(shinfo->gso_type == 0)) {
 		__skb_warn_lro_forwarding(skb);
@@ -2475,7 +2476,7 @@ static inline void skb_forward_csum(struct sk_buff *skb)
  * Instead of forcing ip_summed to CHECKSUM_NONE, we can
  * use this helper, to document places where we make this assertion.
  */
-static inline void skb_checksum_none_assert(struct sk_buff *skb)
+static inline void skb_checksum_none_assert(const struct sk_buff *skb)
 {
 #ifdef DEBUG
 	BUG_ON(skb->ip_summed != CHECKSUM_NONE);
@@ -2484,7 +2485,7 @@ static inline void skb_checksum_none_assert(struct sk_buff *skb)
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
-static inline bool skb_is_recycleable(struct sk_buff *skb, int skb_size)
+static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
 {
 	if (irqs_disabled())
 		return false;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4fc88f3..2eb207e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -46,14 +46,14 @@ struct qdisc_size_table {
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
-	unsigned		flags;
+	unsigned int		flags;
 #define TCQ_F_BUILTIN		1
 #define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
 #define TCQ_F_MQROOT		8
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
-	struct Qdisc_ops	*ops;
+	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
 	struct list_head	list;
 	u32			handle;
@@ -224,7 +224,7 @@ struct qdisc_skb_cb {
 	long			data[];
 };
 
-static inline int qdisc_qlen(struct Qdisc *q)
+static inline int qdisc_qlen(const struct Qdisc *q)
 {
 	return q->q.qlen;
 }
@@ -239,12 +239,12 @@ static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
 	return &qdisc->q.lock;
 }
 
-static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
+static inline struct Qdisc *qdisc_root(const struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->qdisc;
 }
 
-static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
+static inline struct Qdisc *qdisc_root_sleeping(const struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->qdisc_sleeping;
 }
@@ -260,7 +260,7 @@ static inline struct Qdisc *qdisc_root_sleeping(struct Qdisc *qdisc)
  * root.  This is enforced by holding the RTNL semaphore, which
  * all users of this lock accessor must do.
  */
-static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
+static inline spinlock_t *qdisc_root_lock(const struct Qdisc *qdisc)
 {
 	struct Qdisc *root = qdisc_root(qdisc);
 
@@ -268,7 +268,7 @@ static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
 	return qdisc_lock(root);
 }
 
-static inline spinlock_t *qdisc_root_sleeping_lock(struct Qdisc *qdisc)
+static inline spinlock_t *qdisc_root_sleeping_lock(const struct Qdisc *qdisc)
 {
 	struct Qdisc *root = qdisc_root_sleeping(qdisc);
 
@@ -276,17 +276,17 @@ static inline spinlock_t *qdisc_root_sleeping_lock(struct Qdisc *qdisc)
 	return qdisc_lock(root);
 }
 
-static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
+static inline struct net_device *qdisc_dev(const struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
 }
 
-static inline void sch_tree_lock(struct Qdisc *q)
+static inline void sch_tree_lock(const struct Qdisc *q)
 {
 	spin_lock_bh(qdisc_root_sleeping_lock(q));
 }
 
-static inline void sch_tree_unlock(struct Qdisc *q)
+static inline void sch_tree_unlock(const struct Qdisc *q)
 {
 	spin_unlock_bh(qdisc_root_sleeping_lock(q));
 }
@@ -319,7 +319,7 @@ static inline unsigned int qdisc_class_hash(u32 id, u32 mask)
 }
 
 static inline struct Qdisc_class_common *
-qdisc_class_find(struct Qdisc_class_hash *hash, u32 id)
+qdisc_class_find(const struct Qdisc_class_hash *hash, u32 id)
 {
 	struct Qdisc_class_common *cl;
 	struct hlist_node *n;
@@ -393,7 +393,7 @@ static inline bool qdisc_all_tx_empty(const struct net_device *dev)
 }
 
 /* Are any of the TX qdiscs changing?  */
-static inline bool qdisc_tx_changing(struct net_device *dev)
+static inline bool qdisc_tx_changing(const struct net_device *dev)
 {
 	unsigned int i;
 	for (i = 0; i < dev->num_tx_queues; i++) {
