From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH v2 net-next] skbuff: create skb_panic() to let caller specify panic
Date: Sun, 10 Feb 2013 01:23:30 -0700
Message-ID: <1360484610-11432-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:38191 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab3BJIYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 03:24:10 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so2405025dak.0
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 00:24:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combine skb_over_panic() and skb_under_panic() into skb_panic() and let
the caller specify whether it is skb_over_panic or skb_under_panic.

In skb_panic() definition, change 'int sz' and 'here' to 'unsigned int
size' and 'addr' for clarity, and accommodate the output message.
Rewrite kernel doc for skb_panic().

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
v2: don't split format over multiple lines as advised by Joe Perches.

 net/core/skbuff.c | 49 +++++++++++++++----------------------------------
 1 file changed, 15 insertions(+), 34 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6114c11..86d915b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -104,48 +104,27 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
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
+ *	skb_panic - private function for out-of-line support
+ *	@skb:	buffer
+ *	@size:	size
+ *	@addr:	address
+ *	@panic:	skb_over_panic or skb_under_panic
  *
- *	Out of line support code for skb_put(). Not user callable.
- */
-static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
-{
-	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
-		 __func__, here, skb->len, sz, skb->head, skb->data,
-		 (unsigned long)skb->tail, (unsigned long)skb->end,
-		 skb->dev ? skb->dev->name : "<NULL>");
-	BUG();
-}
-
-/**
- *	skb_under_panic	- 	private function
- *	@skb: buffer
- *	@sz: size
- *	@here: address
- *
- *	Out of line support code for skb_push(). Not user callable.
+ *	Out-of-line support for skb_put() and skb_push(). Not user callable.
+ *	Keep out-of-line to prevent kernel bloat.
+ *	__builtin_return_address is not used because it is not always reliable.
  */
-
-static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_panic(struct sk_buff *skb, unsigned int size, void *addr,
+		      const char panic[])
 {
 	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
-		 __func__, here, skb->len, sz, skb->head, skb->data,
+		 panic, addr, skb->len, size, skb->head, skb->data,
 		 (unsigned long)skb->tail, (unsigned long)skb->end,
 		 skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
-
 /*
  * kmalloc_reserve is a wrapper around kmalloc_node_track_caller that tells
  * the caller if emergency pfmemalloc reserves are being used. If it is and
@@ -1259,12 +1238,13 @@ EXPORT_SYMBOL(skb_pad);
  */
 unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
 {
+	const char panic[] = "skb_over_panic";
 	unsigned char *tmp = skb_tail_pointer(skb);
 	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
 	if (unlikely(skb->tail > skb->end))
-		skb_over_panic(skb, len, __builtin_return_address(0));
+		skb_panic(skb, len, __builtin_return_address(0), panic);
 	return tmp;
 }
 EXPORT_SYMBOL(skb_put);
@@ -1280,10 +1260,11 @@ EXPORT_SYMBOL(skb_put);
  */
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
 {
+	const char panic[] = "skb_under_panic";
 	skb->data -= len;
 	skb->len  += len;
 	if (unlikely(skb->data<skb->head))
-		skb_under_panic(skb, len, __builtin_return_address(0));
+		skb_panic(skb, len, __builtin_return_address(0), panic);
 	return skb->data;
 }
 EXPORT_SYMBOL(skb_push);
