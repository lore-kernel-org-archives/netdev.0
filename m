From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/6] rcu: Add list_next_or_null_rcu
Date: Fri, 20 Nov 2015 13:21:55 -0800
Message-ID: <1448054520-1464587-2-git-send-email-tom@herbertland.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davewatson@fb.com>,
	<alexei.starovoitov@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60498 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760406AbbKTVWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:22:16 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAKLJLgY018862
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:16 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9rg53uqd-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:16 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 c514eeb28fcc11e5bc8d24be0595f910-165fb230 for <netdev@vger.kernel.org>;	Fri,
 20 Nov 2015 13:22:15 -0800
In-Reply-To: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a convenience function that returns the next entry in an RCU
list or NULL if at the end of the list.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rculist.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 5ed5409..a9376fd 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -290,6 +290,27 @@ static inline void list_splice_init_rcu(struct list_head *list,
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
2.4.6
