From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] seq_file: add RCU versions of new hlist/list iterators (v3)
Date: Mon, 22 Feb 2010 09:57:17 -0800
Message-ID: <20100222175742.601785018@vyatta.com>
References: <20100222175716.900955428@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46592 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060Ab0BVR65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 12:58:57 -0500
Content-Disposition: inline; filename=seq_hlist_rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many usages of seq_file use RCU protected lists, so non RCU
iterators will not work safely.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Add comment (same as other RCU functions)

 fs/seq_file.c            |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rculist.h  |    5 ++++
 include/linux/seq_file.h |   12 +++++++---
 3 files changed, 70 insertions(+), 3 deletions(-)

--- a/fs/seq_file.c	2010-02-22 09:17:18.362742798 -0800
+++ b/fs/seq_file.c	2010-02-22 09:20:54.481180584 -0800
@@ -750,3 +750,74 @@ struct hlist_node *seq_hlist_next(void *
 		return node->next;
 }
 EXPORT_SYMBOL(seq_hlist_next);
+
+/**
+ * seq_hlist_start_rcu - start an iteration of a hlist protected by RCU
+ * @head: the head of the hlist
+ * @pos:  the start position of the sequence
+ *
+ * Called at seq_file->op->start().
+ *
+ * This list-traversal primitive may safely run concurrently with
+ * the _rcu list-mutation primitives such as hlist_add_head_rcu()
+ * as long as the traversal is guarded by rcu_read_lock().
+ */
+struct hlist_node *seq_hlist_start_rcu(struct hlist_head *head,
+				       loff_t pos)
+{
+	struct hlist_node *node;
+
+	__hlist_for_each_rcu(node, head)
+		if (pos-- == 0)
+			return node;
+	return NULL;
+}
+EXPORT_SYMBOL(seq_hlist_start_rcu);
+
+/**
+ * seq_hlist_start_head_rcu - start an iteration of a hlist protected by RCU
+ * @head: the head of the hlist
+ * @pos:  the start position of the sequence
+ *
+ * Called at seq_file->op->start(). Call this function if you want to
+ * print a header at the top of the output.
+ *
+ * This list-traversal primitive may safely run concurrently with
+ * the _rcu list-mutation primitives such as hlist_add_head_rcu()
+ * as long as the traversal is guarded by rcu_read_lock().
+ */
+struct hlist_node *seq_hlist_start_head_rcu(struct hlist_head *head,
+					    loff_t pos)
+{
+	if (!pos)
+		return SEQ_START_TOKEN;
+
+	return seq_hlist_start_rcu(head, pos - 1);
+}
+EXPORT_SYMBOL(seq_hlist_start_head_rcu);
+
+/**
+ * seq_hlist_next_rcu - move to the next position of the hlist protected by RCU
+ * @v:    the current iterator
+ * @head: the head of the hlist
+ * @pos:  the current posision
+ *
+ * Called at seq_file->op->next().
+ *
+ * This list-traversal primitive may safely run concurrently with
+ * the _rcu list-mutation primitives such as hlist_add_head_rcu()
+ * as long as the traversal is guarded by rcu_read_lock().
+ */
+struct hlist_node *seq_hlist_next_rcu(void *v,
+				      struct hlist_head *head,
+				      loff_t *ppos)
+{
+	struct hlist_node *node = v;
+
+	++*ppos;
+	if (v == SEQ_START_TOKEN)
+		return rcu_dereference(head->first);
+	else
+		return rcu_dereference(node->next);
+}
+EXPORT_SYMBOL(seq_hlist_next_rcu);
--- a/include/linux/seq_file.h	2010-02-22 09:17:18.382742869 -0800
+++ b/include/linux/seq_file.h	2010-02-22 09:21:10.841180579 -0800
@@ -140,10 +140,17 @@ extern struct list_head *seq_list_next(v
  */
 
 extern struct hlist_node *seq_hlist_start(struct hlist_head *head,
-		loff_t pos);
+					  loff_t pos);
 extern struct hlist_node *seq_hlist_start_head(struct hlist_head *head,
-		loff_t pos);
+					       loff_t pos);
 extern struct hlist_node *seq_hlist_next(void *v, struct hlist_head *head,
-		loff_t *ppos);
+					 loff_t *ppos);
 
+extern struct hlist_node *seq_hlist_start_rcu(struct hlist_head *head,
+					      loff_t pos);
+extern struct hlist_node *seq_hlist_start_head_rcu(struct hlist_head *head,
+						   loff_t pos);
+extern struct hlist_node *seq_hlist_next_rcu(void *v,
+						   struct hlist_head *head,
+						   loff_t *ppos);
 #endif
--- a/include/linux/rculist.h	2010-02-22 09:17:18.372742980 -0800
+++ b/include/linux/rculist.h	2010-02-22 09:17:26.771810143 -0800
@@ -406,6 +406,11 @@ static inline void hlist_add_after_rcu(s
 		n->next->pprev = &n->next;
 }
 
+#define __hlist_for_each_rcu(pos, head)			\
+	for (pos = rcu_dereference((head)->first);	\
+	     pos && ({ prefetch(pos->next); 1; });	\
+	     pos = rcu_dereference(pos->next))
+
 /**
  * hlist_for_each_entry_rcu - iterate over rcu list of given type
  * @tpos:	the type * to use as a loop cursor.

-- 

