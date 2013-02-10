From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net-next] skbuff: create skb_panic() to let caller
 specify panic
Date: Sun, 10 Feb 2013 19:24:51 +0100
Message-ID: <20130210182451.GA1602@minipsycho.orion>
References: <1360484610-11432-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:36495 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756423Ab3BJSYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 13:24:55 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so2938477eek.13
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 10:24:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360484610-11432-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 10, 2013 at 09:23:30AM CET, sakiwit@gmail.com wrote:
>Combine skb_over_panic() and skb_under_panic() into skb_panic() and let
>the caller specify whether it is skb_over_panic or skb_under_panic.
>
>In skb_panic() definition, change 'int sz' and 'here' to 'unsigned int
>size' and 'addr' for clarity, and accommodate the output message.
>Rewrite kernel doc for skb_panic().
>
>Signed-off-by: Jean Sacren <sakiwit@gmail.com>
>---
>v2: don't split format over multiple lines as advised by Joe Perches.
>
> net/core/skbuff.c | 49 +++++++++++++++----------------------------------
> 1 file changed, 15 insertions(+), 34 deletions(-)
>
>diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>index 6114c11..86d915b 100644
>--- a/net/core/skbuff.c
>+++ b/net/core/skbuff.c
>@@ -104,48 +104,27 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
> 	.get = sock_pipe_buf_get,
> };
> 
>-/*
>- *	Keep out-of-line to prevent kernel bloat.
>- *	__builtin_return_address is not used because it is not always
>- *	reliable.
>- */
>-
> /**
>- *	skb_over_panic	- 	private function
>- *	@skb: buffer
>- *	@sz: size
>- *	@here: address
>+ *	skb_panic - private function for out-of-line support
>+ *	@skb:	buffer
>+ *	@size:	size
>+ *	@addr:	address
>+ *	@panic:	skb_over_panic or skb_under_panic
>  *
>- *	Out of line support code for skb_put(). Not user callable.
>- */
>-static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
>-{
>-	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
>-		 __func__, here, skb->len, sz, skb->head, skb->data,
>-		 (unsigned long)skb->tail, (unsigned long)skb->end,
>-		 skb->dev ? skb->dev->name : "<NULL>");
>-	BUG();
>-}
>-
>-/**
>- *	skb_under_panic	- 	private function
>- *	@skb: buffer
>- *	@sz: size
>- *	@here: address
>- *
>- *	Out of line support code for skb_push(). Not user callable.
>+ *	Out-of-line support for skb_put() and skb_push(). Not user callable.
>+ *	Keep out-of-line to prevent kernel bloat.
>+ *	__builtin_return_address is not used because it is not always reliable.
>  */
>-
>-static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
>+static void skb_panic(struct sk_buff *skb, unsigned int size, void *addr,
>+		      const char panic[])
> {
> 	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
>-		 __func__, here, skb->len, sz, skb->head, skb->data,
>+		 panic, addr, skb->len, size, skb->head, skb->data,
> 		 (unsigned long)skb->tail, (unsigned long)skb->end,
> 		 skb->dev ? skb->dev->name : "<NULL>");
> 	BUG();
> }
> 
>-
> /*
>  * kmalloc_reserve is a wrapper around kmalloc_node_track_caller that tells
>  * the caller if emergency pfmemalloc reserves are being used. If it is and
>@@ -1259,12 +1238,13 @@ EXPORT_SYMBOL(skb_pad);
>  */
> unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
> {
>+	const char panic[] = "skb_over_panic";

How about to leave skb_under_panic() and skb_over_panic() wrapping
functions there just to wrap "skb_panic(skb, sz, addr, __func__);" call?

Seems nice that to state the name in str...


> 	unsigned char *tmp = skb_tail_pointer(skb);
> 	SKB_LINEAR_ASSERT(skb);
> 	skb->tail += len;
> 	skb->len  += len;
> 	if (unlikely(skb->tail > skb->end))
>-		skb_over_panic(skb, len, __builtin_return_address(0));
>+		skb_panic(skb, len, __builtin_return_address(0), panic);
> 	return tmp;
> }
> EXPORT_SYMBOL(skb_put);
>@@ -1280,10 +1260,11 @@ EXPORT_SYMBOL(skb_put);
>  */
> unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
> {
>+	const char panic[] = "skb_under_panic";
> 	skb->data -= len;
> 	skb->len  += len;
> 	if (unlikely(skb->data<skb->head))
>-		skb_under_panic(skb, len, __builtin_return_address(0));
>+		skb_panic(skb, len, __builtin_return_address(0), panic);
> 	return skb->data;
> }
> EXPORT_SYMBOL(skb_push);
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
