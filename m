From: Taehee Yoo <ap420073@gmail.com>
Subject: [PATCH] rhashtable: Fix missing elements when inserting.
Date: Wed, 24 May 2017 10:49:50 +0900
Message-ID: <20170524014950.3261-1-ap420073@gmail.com>
Cc: netdev@vger.kernel.org, Taehee Yoo <ap420073@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34247 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdEXBuA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 21:50:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id w69so31102454pfk.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 18:50:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rhltable_insert_key() inserts a node into list of element,
if node's key is duplicated, so that it becomes the chain of
element(as known as rhead). Also bucket table points that element directly.
If a inserted node's element chain is located at third,
rhltable misses first and second element chain.
This issue is causion of to failture the rhltable_remove().

After this patch, rhltable_insert_key() inserts a node into second of
element's list, so that rhlist do not misses elements.

Signed-off-by: Taehee Yoo <ap420073@gmail.com>
---
 include/linux/rhashtable.h | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 7d56a7e..d3c24b9 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -762,11 +762,9 @@ static inline void *__rhashtable_insert_fast(
 		list = container_of(obj, struct rhlist_head, rhead);
 		plist = container_of(head, struct rhlist_head, rhead);
 
-		RCU_INIT_POINTER(list->next, plist);
-		head = rht_dereference_bucket(head->next, tbl, hash);
-		RCU_INIT_POINTER(list->rhead.next, head);
-		rcu_assign_pointer(*pprev, obj);
-
+		RCU_INIT_POINTER(list->next, rht_dereference_bucket(plist->next,
+								    tbl, hash));
+		RCU_INIT_POINTER(plist->next, list);
 		goto good;
 	}
 
-- 
2.9.3
