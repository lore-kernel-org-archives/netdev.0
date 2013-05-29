From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH] net: skbuff: use _RET_IP_
Date: Wed, 29 May 2013 14:09:03 -0700
Message-ID: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:33613 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966887Ab3E2VIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 17:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the already defined macro to pass the function return address.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 net/core/skbuff.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..0d06850 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -116,22 +116,22 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
  *	Keep out of line to prevent kernel bloat.
  *	__builtin_return_address is not used because it is not always reliable.
  */
-static void skb_panic(struct sk_buff *skb, unsigned int sz, void *addr,
+static void skb_panic(struct sk_buff *skb, unsigned int sz, unsigned long addr,
 		      const char msg[])
 {
-	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
+	pr_emerg("%s: text:0x%lx len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
 		 msg, addr, skb->len, sz, skb->head, skb->data,
 		 (unsigned long)skb->tail, (unsigned long)skb->end,
 		 skb->dev ? skb->dev->name : "<NULL>");
 	BUG();
 }
 
-static void skb_over_panic(struct sk_buff *skb, unsigned int sz, void *addr)
+static void skb_over_panic(struct sk_buff *skb, unsigned int sz, unsigned long addr)
 {
 	skb_panic(skb, sz, addr, __func__);
 }
 
-static void skb_under_panic(struct sk_buff *skb, unsigned int sz, void *addr)
+static void skb_under_panic(struct sk_buff *skb, unsigned int sz, unsigned long addr)
 {
 	skb_panic(skb, sz, addr, __func__);
 }
@@ -646,7 +646,7 @@ void kfree_skb(struct sk_buff *skb)
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
 		return;
-	trace_kfree_skb(skb, __builtin_return_address(0));
+	trace_kfree_skb(skb, (void *) _RET_IP_);
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(kfree_skb);
@@ -1279,7 +1279,7 @@ unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
 	skb->tail += len;
 	skb->len  += len;
 	if (unlikely(skb->tail > skb->end))
-		skb_over_panic(skb, len, __builtin_return_address(0));
+		skb_over_panic(skb, len, _RET_IP_);
 	return tmp;
 }
 EXPORT_SYMBOL(skb_put);
@@ -1298,7 +1298,7 @@ unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
 	skb->data -= len;
 	skb->len  += len;
 	if (unlikely(skb->data<skb->head))
-		skb_under_panic(skb, len, __builtin_return_address(0));
+		skb_under_panic(skb, len, _RET_IP_);
 	return skb->data;
 }
 EXPORT_SYMBOL(skb_push);
-- 
1.7.11.7
