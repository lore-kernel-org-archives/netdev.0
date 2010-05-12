From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/16] tipc: Reduce footprint by un-inlining bearer congestion routine
Date: Tue, 11 May 2010 20:30:16 -0400
Message-ID: <7eaf155f67b59e56af852bfdadfa09140d7dca2e.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35265 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab0ELAae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:34 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UXvB000142
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:33 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Convert bearer congestion inline routine that is more than one line into
a standard function, thereby eliminating some repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   12 ++++++++++++
 net/tipc/bearer.h |   16 ++--------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index ccec12f..52ae17b 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -467,6 +467,18 @@ int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr)
 	return res;
 }
 
+/**
+ * tipc_bearer_congested - determines if bearer is currently congested
+ */
+
+int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr)
+{
+	if (unlikely(b_ptr->publ.blocked))
+		return 1;
+	if (likely(list_empty(&b_ptr->cong_links)))
+		return 0;
+	return !tipc_bearer_resolve_congestion(b_ptr, l_ptr);
+}
 
 /**
  * tipc_enable_bearer - enable bearer with the given name
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 000228e..a850b38 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -125,6 +125,7 @@ void tipc_bearer_remove_dest(struct bearer *b_ptr, u32 dest);
 void tipc_bearer_schedule(struct bearer *b_ptr, struct link *l_ptr);
 struct bearer *tipc_bearer_find_interface(const char *if_name);
 int tipc_bearer_resolve_congestion(struct bearer *b_ptr, struct link *l_ptr);
+int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr);
 int tipc_bearer_init(void);
 void tipc_bearer_stop(void);
 void tipc_bearer_lock_push(struct bearer *b_ptr);
@@ -154,17 +155,4 @@ static inline int tipc_bearer_send(struct bearer *b_ptr, struct sk_buff *buf,
 	return !b_ptr->media->send_msg(buf, &b_ptr->publ, dest);
 }
 
-/**
- * tipc_bearer_congested - determines if bearer is currently congested
- */
-
-static inline int tipc_bearer_congested(struct bearer *b_ptr, struct link *l_ptr)
-{
-	if (unlikely(b_ptr->publ.blocked))
-		return 1;
-	if (likely(list_empty(&b_ptr->cong_links)))
-		return 0;
-	return !tipc_bearer_resolve_congestion(b_ptr, l_ptr);
-}
-
-#endif
+#endif	/* _TIPC_BEARER_H */
-- 
1.7.1.rc2

