From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 00/13] net: simplify seq_file code
Date: Fri, 05 Feb 2010 09:44:45 +0800
Message-ID: <4B6B780D.10003@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 01/13] seq_file: Add helpers for iteration over a hlist

Some places in kernel need to iterate over a hlist in seq_file,
so provide some common helpers.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 fs/seq_file.c            |   37 ++++++++++++++++++++++++++++++++++---
 include/linux/seq_file.h |   11 +++++++++++
 2 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index eae7d9d..e833076 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -674,7 +674,6 @@ struct list_head *seq_list_start(struct list_head *head, loff_t pos)
 
 	return NULL;
 }
-
 EXPORT_SYMBOL(seq_list_start);
 
 struct list_head *seq_list_start_head(struct list_head *head, loff_t pos)
@@ -684,7 +683,6 @@ struct list_head *seq_list_start_head(struct list_head *head, loff_t pos)
 
 	return seq_list_start(head, pos - 1);
 }
-
 EXPORT_SYMBOL(seq_list_start_head);
 
 struct list_head *seq_list_next(void *v, struct list_head *head, loff_t *ppos)
@@ -695,5 +693,38 @@ struct list_head *seq_list_next(void *v, struct list_head *head, loff_t *ppos)
 	++*ppos;
 	return lh == head ? NULL : lh;
 }
-
 EXPORT_SYMBOL(seq_list_next);
+
+struct hlist_node *seq_hlist_start(struct hlist_head *head, loff_t pos)
+{
+	struct hlist_node *node;
+
+	hlist_for_each(node, head)
+		if (pos-- == 0)
+			return node;
+	return NULL;
+}
+EXPORT_SYMBOL(seq_hlist_start);
+
+struct hlist_node *seq_hlist_start_head(struct hlist_head *head, loff_t pos)
+{
+	if (!pos)
+		return SEQ_START_TOKEN;
+
+	return seq_hlist_start(head, pos - 1);
+}
+EXPORT_SYMBOL(seq_hlist_start_head);
+
+struct hlist_node *seq_hlist_next(void *v, struct hlist_head *head,
+				  loff_t *ppos)
+{
+	struct hlist_node *node = v;
+
+	++*ppos;
+	if (v == SEQ_START_TOKEN)
+		return head->first;
+	else
+		return node->next;
+}
+EXPORT_SYMBOL(seq_hlist_next);
+
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 8366d8f..c95bcdc 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -135,4 +135,15 @@ extern struct list_head *seq_list_start_head(struct list_head *head,
 extern struct list_head *seq_list_next(void *v, struct list_head *head,
 		loff_t *ppos);
 
+/*
+ * Helpers for iteration over hlist_head-s in seq_files
+ */
+
+extern struct hlist_node *seq_hlist_start(struct hlist_head *head,
+		loff_t pos);
+extern struct hlist_node *seq_hlist_start_head(struct hlist_head *head,
+		loff_t pos);
+extern struct hlist_node *seq_hlist_next(void *v, struct hlist_head *head,
+		loff_t *ppos);
+
 #endif
-- 
1.6.3
