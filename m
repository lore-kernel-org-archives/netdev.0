From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] seq_file: add RCU versions of new hlist/list iterators (v2)
Date: Thu, 18 Feb 2010 21:41:46 -0800
Message-ID: <20100219054201.420923686@vyatta.com>
References: <20100219054145.959067404@vyatta.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53498 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173Ab0BSFqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 00:46:36 -0500
Content-Disposition: inline; filename=seq_hlist_rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many usages of seq_file use RCU protected lists, so non RCU
iterators will not work safely. Needed to make __hlist_for_each_rcu
macro (like __list_for_each_rcu).

Also indented prototypes to match existing style.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 fs/seq_file.c            |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rculist.h  |    5 ++
 include/linux/seq_file.h |   27 +++++++++-----
 3 files changed, 111 insertions(+), 9 deletions(-)

--- a/fs/seq_file.c	2010-02-18 15:08:53.228872265 -0800
+++ b/fs/seq_file.c	2010-02-18 15:37:09.660996801 -0800
@@ -695,6 +695,38 @@ struct list_head *seq_list_next(void *v,
 }
 EXPORT_SYMBOL(seq_list_next);
 
+struct list_head *seq_list_start_rcu(struct list_head *head, loff_t pos)
+{
+	struct list_head *lh;
+
+	__list_for_each_rcu(lh, head)
+		if (pos-- == 0)
+			return lh;
+
+	return NULL;
+}
+EXPORT_SYMBOL(seq_list_start_rcu);
+
+struct list_head *seq_list_start_head_rcu(struct list_head *head, loff_t pos)
+{
+	if (!pos)
+		return head;
+
+	return seq_list_start_rcu(head, pos - 1);
+}
+EXPORT_SYMBOL(seq_list_start_head_rcu);
+
+struct list_head *seq_list_next_rcu(void *v, struct list_head *head,
+				    loff_t *ppos)
+{
+	struct list_head *lh = v;
+
+	lh = rcu_dereference(lh->next);
+	++*ppos;
+	return lh == head ? NULL : lh;
+}
+EXPORT_SYMBOL(seq_list_next_rcu);
+
 /**
  * seq_hlist_start - start an iteration of a hlist
  * @head: the head of the hlist
@@ -750,3 +782,59 @@ struct hlist_node *seq_hlist_next(void *
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
+ */
+struct hlist_node *seq_hlist_start_rcu(struct hlist_head *head, loff_t pos)
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
+ */
+struct hlist_node *seq_hlist_start_head_rcu(struct hlist_head *head, loff_t pos)
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
+ */
+struct hlist_node *seq_hlist_next_rcu(void *v, struct hlist_head *head,
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
--- a/include/linux/seq_file.h	2010-02-18 15:08:53.256872028 -0800
+++ b/include/linux/seq_file.h	2010-02-18 15:09:14.128997914 -0800
@@ -127,23 +127,32 @@ int seq_release_private(struct inode *, 
 /*
  * Helpers for iteration over list_head-s in seq_files
  */
-
 extern struct list_head *seq_list_start(struct list_head *head,
-		loff_t pos);
+					loff_t pos);
 extern struct list_head *seq_list_start_head(struct list_head *head,
-		loff_t pos);
+					     loff_t pos);
 extern struct list_head *seq_list_next(void *v, struct list_head *head,
-		loff_t *ppos);
-
+				       loff_t *ppos);
+extern struct list_head *seq_list_start_rcu(struct list_head *head,
+					    loff_t pos);
+extern struct list_head *seq_list_start_head_rcu(struct list_head *head,
+						 loff_t pos);
+extern struct list_head *seq_list_next_rcu(void *v, struct list_head *head,
+					   loff_t *ppos);
 /*
  * Helpers for iteration over hlist_head-s in seq_files
  */
-
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
+extern struct hlist_node *seq_hlist_next_rcu(void *v, struct hlist_head *head,
+					     loff_t *ppos);
 #endif
--- a/include/linux/rculist.h	2010-02-18 15:25:03.681496691 -0800
+++ b/include/linux/rculist.h	2010-02-18 15:33:26.352872829 -0800
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

