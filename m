From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/4] list.h: Add list_splice_tail() and list_splice_tail_init()
Date: Mon, 4 Aug 2008 15:48:00 -0700
Message-ID: <1217890080-12073-1-git-send-email-lrodriguez@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>
To: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If you are using linked lists for queues list_splice() will not do what
you would expect even if you use the elements passed reversed. We need
to handle these differently. We add list_splice_tail() and
list_splice_tail_init()

Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---
 include/linux/list.h |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 453916b..594f67c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -229,7 +229,7 @@ static inline void __list_splice(const struct list_head *list,
 }
 
 /**
- * list_splice - join two lists
+ * list_splice - join two lists, this is designed for stacks
  * @list: the new list to add.
  * @head: the place to add it in the first list.
  */
@@ -256,6 +256,49 @@ static inline void list_splice_init(struct list_head *list,
 	}
 }
 
+static inline void __list_splice_tail(const struct list_head *list,
+				 struct list_head *head)
+{
+	struct list_head *first = list->next;
+	struct list_head *last = list->prev;
+	struct list_head *current_tail = head->prev;
+
+	current_tail->next = first;
+	last->next = head;
+	head->prev = last;
+	first->prev = current_tail;
+}
+
+/**
+ * list_splice_tail - join two lists, each list being a queue
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ */
+static inline void list_splice_tail(const struct list_head *list,
+				struct list_head *head)
+{
+	if (!list_empty(list))
+		__list_splice_tail(list, head);
+}
+
+/**
+ * list_splice_tail_init - join two lists, each list being a queue, and
+ * 	reinitialise the emptied list.
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ *
+ * The list at @list is reinitialised
+ */
+static inline void list_splice_tail_init(struct list_head *list,
+				    struct list_head *head)
+{
+	if (!list_empty(list)) {
+		__list_splice_tail(list, head);
+		INIT_LIST_HEAD(list);
+	}
+}
+
+
 /**
  * list_entry - get the struct for this entry
  * @ptr:	the &struct list_head pointer.
-- 
1.5.6.rc2.15.g457bb.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
