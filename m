From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 01/13] seq_file: Add helpers for iteration over a hlist
Date: Fri, 05 Feb 2010 13:04:04 +0800
Message-ID: <4B6BA6C4.5030205@cn.fujitsu.com>
References: <4B6B780D.10003@cn.fujitsu.com>	<20100204175828.51b9e8a1.akpm@linux-foundation.org>	<4B6B7EA8.4070104@cn.fujitsu.com> <20100204.203216.97839493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53412 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750698Ab0BEFDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 00:03:48 -0500
In-Reply-To: <20100204.203216.97839493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some places in kernel need to iterate over a hlist in seq_file,
so provide some common helpers.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

Here's the resend of the first patch.

I'll send another patch to add some kerneldoc for seq_list_xxx()
and seq_hlist_xxx().

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
-- 1.6.3 
