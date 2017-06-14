From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Wed, 14 Jun 2017 13:36:53 -0700
Message-ID: <1497472613.18751.67.camel@perches.com>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:60668 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751754AbdFNUg4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:36:56 -0400
In-Reply-To: <20170614201720.21070-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 22:17 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> It's nicer to return void, since then there's no need to
> cast to any structures. Currently none of the users have
> a cast, but a number of future conversions do.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  include/linux/skbuff.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 1151b50892d1..01ea64d0783a 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1904,9 +1904,9 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
>  	return tmp;
>  }
>  
> -static inline unsigned char *skb_put_zero(struct sk_buff *skb, unsigned int len)
> +static inline void *skb_put_zero(struct sk_buff *skb, unsigned int len)
>  {
> -	unsigned char *tmp = skb_put(skb, len);
> +	void *tmp = skb_put(skb, len);
>  
>  	memset(tmp, 0, len);

Given you are adding a lot of these, it might be better
to add an exported function that duplicates most of
skb_put with a memset at the end.

That would probably create a smaller kernel and might
be a bit faster.

Perhaps:
---
 include/linux/skbuff.h | 10 +---------
 net/core/skbuff.c      | 22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 78213b3f9552..f725cbe30c9c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1895,6 +1895,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
  */
 unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
+void *skb_put_zero(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *tmp = skb_tail_pointer(skb);
@@ -1904,15 +1905,6 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
-static inline unsigned char *skb_put_zero(struct sk_buff *skb, unsigned int len)
-{
-	unsigned char *tmp = skb_put(skb, len);
-
-	memset(tmp, 0, len);
-
-	return tmp;
-}
-
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 304602784c3b..e70aa414b139 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1454,6 +1454,28 @@ unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
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
+	unsigned char *tmp = skb_tail_pointer(skb);
+
+	SKB_LINEAR_ASSERT(skb);
+	skb->tail += len;
+	skb->len  += len;
+	if (unlikely(skb->tail > skb->end))
+		skb_over_panic(skb, len, __builtin_return_address(0));
+	return memset(tmp, 0, len);
+}
+EXPORT_SYMBOL(skb_put_zero);
+
+/**
  *	skb_push - add data to the start of a buffer
  *	@skb: buffer to use
  *	@len: amount of data to add
