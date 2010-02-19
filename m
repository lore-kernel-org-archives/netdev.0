From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] seq_file: add RCU versions of new hlist/list iterators (v3)
Date: Fri, 19 Feb 2010 13:59:14 -0800
Message-ID: <20100219220111.692855800@vyatta.com>
References: <20100219215913.819285957@vyatta.com>
Cc: netdev@vger.kernel.org
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos S
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49110 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518Ab0BSWHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 17:07:06 -0500
Content-Disposition: inline; filename=seq_hlist_rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many usages of seq_file use RCU protected lists, so non RCU
iterators will not work safely.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This version drops the list_rcu variants because not needed yet

 fs/seq_file.c            |   56 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rculist.h  |    5 ++++
 include/linux/seq_file.h |   12 +++++++---
 3 files changed, 70 insertions(+), 3 deletions(-)

--- a/fs/seq_file.c	2010-02-18 21:46:46.978333060 -0800
+++ b/fs/seq_file.c	2010-02-19 11:22:30.540260974 -0800
@@ -750,3 +750,59 @@ struct hlist_node *seq_hlist_next(void *
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
--- a/include/linux/seq_file.h	2010-02-18 21:46:47.014333155 -0800
+++ b/include/linux/seq_file.h	2010-02-19 11:24:42.356546569 -0800
@@ -140,10 +140,16 @@ extern struct list_head *seq_list_next(v
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
+extern struct hlist_node *seq_hlist_next_rcu(void *v, struct hlist_head *head,
+					     loff_t *ppos);
 #endif
--- a/include/linux/rculist.h	2010-02-18 21:46:46.998211692 -0800
+++ b/include/linux/rculist.h	2010-02-19 11:21:32.880295586 -0800
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

