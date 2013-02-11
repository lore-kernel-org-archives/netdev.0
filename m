From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH v3 net-next] skbuff: create skb_panic() function and its wrappers
Date: Mon, 11 Feb 2013 16:30:38 -0700
Message-ID: <1360625438-13072-1-git-send-email-sakiwit@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:63863 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760128Ab3BKXbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 18:31:20 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so3300828pad.6
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 15:31:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create skb_panic() function in lieu of both skb_over_panic() and
skb_under_panic() so that code duplication would be avoided. Update type
and variable name where necessary.

Jiri Pirko suggested using wrappers so that we would be able to keep the
fruits of the original code.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
v3:
 - Update commit header and log.
 - Implement Jiri Pirko's contribution and cc him.

v2:
 - Fix breaking into multiple lines as advised by Joe Perches.

 net/core/skbuff.c | 48 +++++++++++++++++++-----------------------------
 1 file changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6114c11..8731c39 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -104,47 +104,37 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
 	.get = sock_pipe_buf_get,
 };
 
-/*
- *	Keep out-of-line to prevent kernel bloat.
- *	__builtin_return_address is not used because it is not always
- *	reliable.
- */
-
 /**
- *	skb_over_panic	- 	private function
- *	@skb: buffer
- *	@sz: size
- *	@here: address
- *
- *	Out of line support code for skb_put(). Not user callable.
+ *	skb_panic - private function for out-of-line support
+ *	@skb:	buffer
+ *	@sz:	size
+ *	@addr:	address
+ *	@panic: skb_over_panic or skb_under_panic
+ *
+ *	Out-of-line support for skb_put() and skb_push().
+ *	Called via the wrapper skb_over_panic() or skb_under_panic().
+ *	Keep out of line to prevent kernel bloat.
+ *	__builtin_return_address is not used because it is not always reliable.
  */
-static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_panic(struct sk_buff *skb, unsigned int sz, void *addr,
+		      const char panic[])
 {
 	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
-		 __func__, here, skb->len, sz, skb->head, skb->data,
+		 panic, addr, skb->len, sz, skb->head, skb->data,
 		 (unsigned long)skb->tail, (unsigned long)skb->end,
 		 skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
-/**
- *	skb_under_panic	- 	private function
- *	@skb: buffer
- *	@sz: size
- *	@here: address
- *
- *	Out of line support code for skb_push(). Not user callable.
- */
-
-static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_over_panic(struct sk_buff *skb, unsigned int sz, void *addr)
 {
-	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
-		 __func__, here, skb->len, sz, skb->head, skb->data,
-		 (unsigned long)skb->tail, (unsigned long)skb->end,
-		 skb->dev ? skb->dev->name : "<NULL>");
-	BUG();
+	skb_panic(skb, sz, addr, __func__);
 }
 
+static void skb_under_panic(struct sk_buff *skb, unsigned int sz, void *addr)
+{
+	skb_panic(skb, sz, addr, __func__);
+}
 
 /*
  * kmalloc_reserve is a wrapper around kmalloc_node_track_caller that tells
