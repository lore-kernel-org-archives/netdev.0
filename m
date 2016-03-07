From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 01/13] rcu: Add list_next_or_null_rcu
Date: Mon, 7 Mar 2016 14:11:00 -0800
Message-ID: <1457388672-2600559-2-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:8448 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753609AbcCGWLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:11:49 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u27M6O0B014653
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:11:48 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 21fv0da463-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:11:48 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 95590908e4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:11:47 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a convenience function that returns the next entry in an RCU
list or NULL if at the end of the list.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rculist.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 14ec165..17d4f84 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -319,6 +319,27 @@ static inline void list_splice_tail_init_rcu(struct list_head *list,
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
2.6.5
