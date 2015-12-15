From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 2/6] hlist: prepare for supporting bit spinlock
Date: Tue, 15 Dec 2015 19:21:00 +0800
Message-ID: <1450178464-27721-3-git-send-email-tom.leiming@gmail.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hlist_head is often used for implementing bucket header of
hash table, and one lock is often needed for adding/deleting
node in the bucket list. It can consume lots of memory if
per-bucket spinlock is used, so this patch trys to use the 1st
bit of hlist_head->first as bit lock for this purpose.

bit spinlock isn't efficient as spin lock, but the contention
shouldn't be very high for operating per-bucket hlist, so bit
spinlock should be OK.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/linux/rculist.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 14ec165..9fc394a 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -435,6 +435,61 @@ static inline void hlist_replace_rcu(struct hlist_node *old,
 #define hlist_next_rcu(node)	(*((struct hlist_node __rcu **)(&(node)->next)))
 #define hlist_pprev_rcu(node)	(*((struct hlist_node __rcu **)((node)->pprev)))
 
+/*
+ * This bit of hlist_head->first can be used as per-bucket
+ * bit spin_lock in hash table use case, and the lock bit
+ * should always be kept when hlist_node is added, deleted
+ * and other update operations.
+ *
+ * When lock bit is used, only the _lock version of hlist
+ * helpers can be used for operating the hlist.
+ */
+#define	HLIST_LOCK_BIT		0
+#define	HLIST_LOCK_MASK		(1UL << HLIST_LOCK_BIT)
+#define hlist_get_first(h)	\
+	(struct hlist_node *)((unsigned long)(h)->first & ~HLIST_LOCK_MASK)
+#define hlist_get_lock(h)    ((unsigned long)(h)->first & HLIST_LOCK_MASK)
+#define hlist_make_1st_node(h, n) \
+	(struct hlist_node *)((unsigned long)(n) | hlist_get_lock(h))
+
+static inline struct hlist_head *hlist_get_head_lock(
+		struct hlist_head *head, struct hlist_head *new_head)
+{
+	new_head->first = hlist_get_first(head);
+	return new_head;
+}
+
+static inline void __hlist_del_lock(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+
+	WRITE_ONCE(*pprev, (unsigned long)next |
+			((unsigned long)*pprev & HLIST_LOCK_MASK));
+	if (next)
+		next->pprev = pprev;
+}
+
+/* The bit lock should be held before calling this helper */
+static inline void hlist_del_rcu_lock(struct hlist_node *n)
+{
+	__hlist_del_lock(n);
+	n->pprev = LIST_POISON2;
+}
+
+/* The bit lock should be held before calling this helper */
+static inline void hlist_add_head_rcu_lock(struct hlist_node *n,
+					   struct hlist_head *h)
+{
+	struct hlist_node *first = hlist_get_first(h);
+
+	n->next = first;
+	n->pprev = &h->first;
+	rcu_assign_pointer(hlist_first_rcu(h), hlist_make_1st_node(h, n));
+	if (first)
+		first->pprev = &n->next;
+}
+
 /**
  * hlist_add_head_rcu
  * @n: the element to add to the hash list.
-- 
1.9.1
