From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/16] tipc: Reduce footprint by un-inlining buf_acquire routine
Date: Tue, 11 May 2010 20:30:17 -0400
Message-ID: <14e7d20d5b864e785ceb5439f6713b722f65e127.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35269 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754189Ab0ELAae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:34 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UY85000147
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:34 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Convert buf_acquire inline routine that is more than one line into
a standard function, thereby eliminating some repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c |   24 ++++++++++++++++++++++++
 net/tipc/core.h |   24 +-----------------------
 2 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index b47d184..6964681 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -102,6 +102,30 @@ int tipc_get_mode(void)
 }
 
 /**
+ * buf_acquire - creates a TIPC message buffer
+ * @size: message size (including TIPC header)
+ *
+ * Returns a new buffer with data pointers set to the specified size.
+ *
+ * NOTE: Headroom is reserved to allow prepending of a data link header.
+ *       There may also be unrequested tailroom present at the buffer's end.
+ */
+
+struct sk_buff *buf_acquire(u32 size)
+{
+	struct sk_buff *skb;
+	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
+
+	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
+	if (skb) {
+		skb_reserve(skb, BUF_HEADROOM);
+		skb_put(skb, size);
+		skb->next = NULL;
+	}
+	return skb;
+}
+
+/**
  * tipc_core_stop_net - shut down TIPC networking sub-systems
  */
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 1e149f5..1887990 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -328,29 +328,7 @@ static inline struct tipc_msg *buf_msg(struct sk_buff *skb)
 	return (struct tipc_msg *)skb->data;
 }
 
-/**
- * buf_acquire - creates a TIPC message buffer
- * @size: message size (including TIPC header)
- *
- * Returns a new buffer with data pointers set to the specified size.
- *
- * NOTE: Headroom is reserved to allow prepending of a data link header.
- *       There may also be unrequested tailroom present at the buffer's end.
- */
-
-static inline struct sk_buff *buf_acquire(u32 size)
-{
-	struct sk_buff *skb;
-	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
-
-	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
-	if (skb) {
-		skb_reserve(skb, BUF_HEADROOM);
-		skb_put(skb, size);
-		skb->next = NULL;
-	}
-	return skb;
-}
+extern struct sk_buff *buf_acquire(u32 size);
 
 /**
  * buf_discard - frees a TIPC message buffer
-- 
1.7.1.rc2

