From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 1/2] include: add linked list implementation from kernel
Date: Tue, 22 Mar 2016 10:02:20 +0100
Message-ID: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com,
	hannes@stressinduktion.org, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33033 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbcCVJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 05:02:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id u125so1834618wmg.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 02:02:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Rename hlist.h to list.h while adding it to be aligned with kernel

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- fix some checkpatch issues
---
 include/hlist.h |  56 ----------------------------
 include/list.h  | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ip/ipnetns.c    |   2 +-
 lib/ll_map.c    |   2 +-
 tc/tc_class.c   |   2 +-
 5 files changed, 115 insertions(+), 59 deletions(-)
 delete mode 100644 include/hlist.h
 create mode 100644 include/list.h

diff --git a/include/hlist.h b/include/hlist.h
deleted file mode 100644
index 4e8de9e..0000000
--- a/include/hlist.h
+++ /dev/null
@@ -1,56 +0,0 @@
-#ifndef __HLIST_H__
-#define __HLIST_H__ 1
-/* Hash list stuff from kernel */
-
-#include <stddef.h>
-
-#define container_of(ptr, type, member) ({			\
-	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
-	(type *)( (char *)__mptr - offsetof(type,member) );})
-
-struct hlist_head {
-	struct hlist_node *first;
-};
-
-struct hlist_node {
-	struct hlist_node *next, **pprev;
-};
-
-static inline void hlist_del(struct hlist_node *n)
-{
-	struct hlist_node *next = n->next;
-	struct hlist_node **pprev = n->pprev;
-	*pprev = next;
-	if (next)
-		next->pprev = pprev;
-}
-
-static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
-{
-	struct hlist_node *first = h->first;
-	n->next = first;
-	if (first)
-		first->pprev = &n->next;
-	h->first = n;
-	n->pprev = &h->first;
-}
-
-#define hlist_for_each(pos, head) \
-	for (pos = (head)->first; pos ; pos = pos->next)
-
-
-#define hlist_for_each_safe(pos, n, head) \
-	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
-	     pos = n)
-
-#define hlist_entry_safe(ptr, type, member) \
-	({ typeof(ptr) ____ptr = (ptr); \
-	   ____ptr ? hlist_entry(____ptr, type, member) : NULL; \
-	})
-
-#define hlist_for_each_entry(pos, head, member)				\
-	for (pos = hlist_entry_safe((head)->first, typeof(*(pos)), member);\
-	     pos;							\
-	     pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))
-
-#endif /* __HLIST_H__ */
diff --git a/include/list.h b/include/list.h
new file mode 100644
index 0000000..cdebe4d
--- /dev/null
+++ b/include/list.h
@@ -0,0 +1,112 @@
+#ifndef __LIST_H__
+#define __LIST_H__ 1
+/* List and hash list stuff from kernel */
+
+#include <stddef.h>
+
+#define container_of(ptr, type, member) ({			\
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
+	(type *)( (char *)__mptr - offsetof(type,member) );})
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+static inline void INIT_LIST_HEAD(struct list_head *list)
+{
+	list->next = list;
+	list->prev = list;
+}
+
+static inline void __list_add(struct list_head *new,
+			      struct list_head *prev,
+			      struct list_head *next)
+{
+	next->prev = new;
+	new->next = next;
+	new->prev = prev;
+	prev->next = new;
+}
+
+static inline void list_add(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head, head->next);
+}
+
+static inline void __list_del(struct list_head *prev, struct list_head *next)
+{
+	next->prev = prev;
+	prev->next = next;
+}
+
+static inline void list_del(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+}
+
+#define list_entry(ptr, type, member) \
+	container_of(ptr, type, member)
+
+#define list_first_entry(ptr, type, member) \
+	list_entry((ptr)->next, type, member)
+
+#define list_next_entry(pos, member) \
+	list_entry((pos)->member.next, typeof(*(pos)), member)
+
+#define list_for_each_entry(pos, head, member)				\
+	for (pos = list_first_entry(head, typeof(*pos), member);	\
+	     &pos->member != (head);					\
+	     pos = list_next_entry(pos, member))
+
+#define list_for_each_entry_safe(pos, n, head, member)			\
+	for (pos = list_first_entry(head, typeof(*pos), member),	\
+		n = list_next_entry(pos, member);			\
+	     &pos->member != (head);					\
+	     pos = n, n = list_next_entry(n, member))
+
+struct hlist_head {
+	struct hlist_node *first;
+};
+
+struct hlist_node {
+	struct hlist_node *next, **pprev;
+};
+
+static inline void hlist_del(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+	*pprev = next;
+	if (next)
+		next->pprev = pprev;
+}
+
+static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
+{
+	struct hlist_node *first = h->first;
+	n->next = first;
+	if (first)
+		first->pprev = &n->next;
+	h->first = n;
+	n->pprev = &h->first;
+}
+
+#define hlist_for_each(pos, head) \
+	for (pos = (head)->first; pos ; pos = pos->next)
+
+
+#define hlist_for_each_safe(pos, n, head) \
+	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
+	     pos = n)
+
+#define hlist_entry_safe(ptr, type, member) \
+	({ typeof(ptr) ____ptr = (ptr); \
+	   ____ptr ? hlist_entry(____ptr, type, member) : NULL; \
+	})
+
+#define hlist_for_each_entry(pos, head, member)				\
+	for (pos = hlist_entry_safe((head)->first, typeof(*(pos)), member);\
+	     pos;							\
+	     pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))
+
+#endif /* __LIST_H__ */
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 4ce5989..0596b2c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -18,7 +18,7 @@
 #include <linux/net_namespace.h>
 
 #include "utils.h"
-#include "hlist.h"
+#include "list.h"
 #include "ip_common.h"
 #include "namespace.h"
 
diff --git a/lib/ll_map.c b/lib/ll_map.c
index c6f7027..fa14a77 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -22,7 +22,7 @@
 
 #include "libnetlink.h"
 #include "ll_map.h"
-#include "hlist.h"
+#include "list.h"
 
 struct ll_cache {
 	struct hlist_node idx_hash;
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 3acd030..7d3b009 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -24,7 +24,7 @@
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_common.h"
-#include "hlist.h"
+#include "list.h"
 
 struct graph_node {
 	struct hlist_node hlist;
-- 
2.5.5
