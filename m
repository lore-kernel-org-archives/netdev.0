From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 0/6] skb data accessor cleanups
Date: Fri, 16 Jun 2017 12:17:47 -0700
Message-ID: <1497640667.10546.13.camel@perches.com>
References: <20170616122924.3557-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0113.hostedemail.com ([216.40.44.113]:48338 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751798AbdFPTRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:17:51 -0400
In-Reply-To: <20170616122924.3557-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 14:29 +0200, Johannes Berg wrote:
> Changes from v1:
>  * add skb_put_u8() as suggested by Joe and Bjørn
> 
> Again build-tested by myself and kbuild bot.

Now that I think about it, I did something similar in 2015
https://www.spinics.net/lists/netdev/msg327404.html

At that time Eric Dumazet objected to the API expansion.

And here's an FYI that was a bit surprising to me:

Adding separate EXPORT_SYMBOL functions for skb_put_zero
and skb_put_data that do the memset/memcpy does not
shrink an x86-64 defconfig kernel image much at all.

$ size vmlinux.new vmlinux.old
   text	   data	    bss	    dec	    hex	
filename
10779941	4707128	 892928	16379997	 f9f05d	
vmlinux.new
10780631	4707128	 892928	16380687	 f9f30f	
vmlinux.old

This was the patch I tested:
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 852feacf4bbf..9de7c642ee4f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1904,24 +1904,8 @@ static inline void *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
-static inline void *skb_put_zero(struct sk_buff *skb, unsigned int len)
-{
-	void *tmp = skb_put(skb, len);
-
-	memset(tmp, 0, len);
-
-	return tmp;
-}
-
-static inline void *skb_put_data(struct sk_buff *skb, const void *data,
-				 unsigned int len)
-{
-	void *tmp = skb_put(skb, len);
-
-	memcpy(tmp, data, len);
-
-	return tmp;
-}
+void *skb_put_zero(struct sk_buff *skb, unsigned int len);
+void *skb_put_data(struct sk_buff *skb, const void *data, unsigned int len);
 
 static inline void skb_put_u8(struct sk_buff *skb, u8 val)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f75897a33fa4..327f7cd2e0bb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1431,6 +1431,19 @@ void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
 }
 EXPORT_SYMBOL_GPL(pskb_put);
 
+static __always_inline void *___skb_put(struct sk_buff *skb, unsigned int len)
+{
+	void *tmp = skb_tail_pointer(skb);
+
+	SKB_LINEAR_ASSERT(skb);
+	skb->tail += len;
+	skb->len  += len;
+	if (unlikely(skb->tail > skb->end))
+		skb_over_panic(skb, len, __builtin_return_address(0));
+
+	return tmp;
+}
+
 /**
  *	skb_put - add data to a buffer
  *	@skb: buffer to use
@@ -1442,17 +1455,42 @@ EXPORT_SYMBOL_GPL(pskb_put);
  */
 void *skb_put(struct sk_buff *skb, unsigned int len)
 {
-	void *tmp = skb_tail_pointer(skb);
-	SKB_LINEAR_ASSERT(skb);
-	skb->tail += len;
-	skb->len  += len;
-	if (unlikely(skb->tail > skb->end))
-		skb_over_panic(skb, len, __builtin_return_address(0));
-	return tmp;
+	return ___skb_put(skb, len);
 }
 EXPORT_SYMBOL(skb_put);
 
 /**
+ *	skb_put_zero - add zeroed data to a buffer
+ *	@skb: buffer to use
+ *	@len: amount of zeroed data to add
+ *
+ *	This function extends the used data area of the buffer. If this would
+ *	exceed the total buffer size the kernel will panic. A pointer to the
+ *	first byte of the extra data is returned.
+ */
+void *skb_put_zero(struct sk_buff *skb, unsigned int len)
+{
+	return memset(___skb_put(skb, len), 0, len);
+}
+EXPORT_SYMBOL(skb_put_zero);
+
+/**
+ *	skb_put_data - Copy data to a buffer
+ *	@skb: buffer to use
+ *	@data: pointer to data to copy
+ *	@len: amount of data to add
+ *
+ *	This function extends the used data area of the buffer. If this would
+ *	exceed the total buffer size the kernel will panic. A pointer to the
+ *	first byte of the extra data is returned.
+ */
+void *skb_put_data(struct sk_buff *skb, const void *data, unsigned int len)
+{
+	return memcpy(___skb_put(skb, len), data, len);
+}
+EXPORT_SYMBOL(skb_put_data);
+
+/**
  *	skb_push - add data to the start of a buffer
  *	@skb: buffer to use
  *	@len: amount of data to add
