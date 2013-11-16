From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Fri, 15 Nov 2013 21:11:57 -0500 (EST)
Message-ID: <20131115.211157.1873101189604068576.davem@davemloft.net>
References: <20131116004738.GA1491@gondor.apana.org.au>
	<20131115.203427.1522242353491609372.davem@davemloft.net>
	<20131116014350.GA1895@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	edumazet@google.com, herbert@gondor.apana.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab3KPCL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:11:58 -0500
In-Reply-To: <20131116014350.GA1895@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 16 Nov 2013 09:43:50 +0800

> On Fri, Nov 15, 2013 at 08:34:27PM -0500, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Sat, 16 Nov 2013 08:47:38 +0800
>> 
>> > Also, if the padding occurs on every single packet or a fairly
>> > large amount of packets then you should consider improving
>> > pskb_trim_rcsum to keep the CHECKSUM_COMPLETE value.
>> 
>> It should be as easy as this?  (this is actually just a 3 line change,
>> it looks like more because I'm moving pskb_trim_rcsum() later in the
>> file to where skb_checksum() is in scope).
> 
> Looks good to me.  Thanks!

Cool, I committed it as follows:

====================
[PATCH] net: Handle CHECKSUM_COMPLETE more adequately in pskb_trim_rcsum().

Currently pskb_trim_rcsum() just balks on CHECKSUM_COMPLETE packets
and remarks them as CHECKSUM_NONE, forcing a software checksum
validation later.

We have all of the mechanics available to fixup the skb->csum value,
even for complicated fragmented packets, via the helpers
skb_checksum() and csum_sub().

So just use them.

Based upon a suggestion by Herbert Xu.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 215b5ea..bec1cc7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2263,24 +2263,6 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
 
-/**
- *	pskb_trim_rcsum - trim received skb and update checksum
- *	@skb: buffer to trim
- *	@len: new length
- *
- *	This is exactly the same as pskb_trim except that it ensures the
- *	checksum of received packets are still valid after the operation.
- */
-
-static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
-{
-	if (likely(len >= skb->len))
-		return 0;
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->ip_summed = CHECKSUM_NONE;
-	return __pskb_trim(skb, len);
-}
-
 #define skb_queue_walk(queue, skb) \
 		for (skb = (queue)->next;					\
 		     skb != (struct sk_buff *)(queue);				\
@@ -2378,6 +2360,27 @@ __wsum __skb_checksum(const struct sk_buff *skb, int offset, int len,
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
 		    __wsum csum);
 
+/**
+ *	pskb_trim_rcsum - trim received skb and update checksum
+ *	@skb: buffer to trim
+ *	@len: new length
+ *
+ *	This is exactly the same as pskb_trim except that it ensures the
+ *	checksum of received packets are still valid after the operation.
+ */
+
+static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
+{
+	if (likely(len >= skb->len))
+		return 0;
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__wsum adj = skb_checksum(skb, len, skb->len - len, 0);
+
+		skb->csum = csum_sub(skb->csum, adj);
+	}
+	return __pskb_trim(skb, len);
+}
+
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
 {
-- 
1.7.11.7
