From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/3] rcu: Add list_next_or_null_rcu
Date: Sun, 20 Sep 2015 15:29:19 -0700
Message-ID: <1442788161-2626305-2-git-send-email-tom@herbertland.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24817 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755393AbbITWbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 18:31:03 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8KMTJhh006046
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1x1xkjhfrd-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:02 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 456096c25fe711e5975c0002c992ebde-78dfd240 for <netdev@vger.kernel.org>;	Sun,
 20 Sep 2015 15:31:01 -0700
In-Reply-To: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a convenienve function that returns the next enrty in abn RCU
list or NULL if at the end of the list.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rculist.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 17c6b1f..3e8e2aa 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -293,6 +293,27 @@ static inline void list_splice_init_rcu(struct list_head *list,
 })
 
 /**
+ * list_next_or_null_rcu - get the first element from a list
+ * @head:	the head for the list.
+ * @ptr:        the list head to take the next element from.
+ * @type:       the type of the struct this is embedded in.
+ * @member:     the name of the list_head within the struct.
+ *
+ * Note that if the ptr is at the end of the list, NULL is returned.
+ *
+ * This primitive may safely run concurrently with the _rcu list-mutation
+ * primitives such as list_add_rcu() as long as it's guarded by rcu_read_lock().
+ */
+#define list_next_or_null_rcu(head, ptr, type, member) \
+({ \
+	struct list_head *__head = (head); \
+	struct list_head *__ptr = (ptr); \
+	struct list_head *__next = READ_ONCE(__ptr->next); \
+	likely(__next != __head) ? list_entry_rcu(__next, type, \
+						  member) : NULL; \
+})
+
+/**
  * list_for_each_entry_rcu	-	iterate over rcu list of given type
  * @pos:	the type * to use as a loop cursor.
  * @head:	the head for your list.
-- 
1.8.1
