From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 1/8] skb: Add skb_put_uchar
Date: Mon,  4 May 2015 13:05:45 -0700
Message-ID: <812f80051bdd23912e1e7bab36e29d9f4d71775b.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0229.hostedemail.com ([216.40.44.229]:46023 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752205AbbEDUGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:06 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay04.hostedemail.com (Postfix) with ESMTP id 3E46D3522AE
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:05 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:04 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_put currently returns an unsigned char *.

There are uses like "*skb_put(skb, 1) = <char>" that might be
better represented by a new skb_put_uchar(<char>) function.

This would allow the skb_put function to be converted to
return void and eliminate many casts of the unsigned char *
return to some other type.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index acb83e2..894071e1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1679,6 +1679,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
  */
 unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
+void *skb_put_uchar(struct sk_buff *skb, unsigned char uc);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *tmp = skb_tail_pointer(skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..73e20ad 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1410,6 +1410,32 @@ unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
 EXPORT_SYMBOL(skb_put);
 
 /**
+ *	skb_put_uchar - add an unsigned char to a buffer
+ *	@skb: buffer to use
+ *	@uc: unsigned char to add
+ *
+ *	This function extends the used data area of the buffer. If this would
+ *	exceed the total buffer size the kernel will panic. A pointer to the
+ *	first byte of the extra data is returned.
+ */
+void *skb_put_uchar(struct sk_buff *skb, unsigned char uc)
+{
+	unsigned char *tmp = skb_tail_pointer(skb);
+
+	SKB_LINEAR_ASSERT(skb);
+
+	skb->tail++;
+	skb->len++;
+	if (unlikely(skb->tail > skb->end))
+		skb_over_panic(skb, 1, __builtin_return_address(0));
+
+	*tmp = uc;
+
+	return tmp;
+}
+EXPORT_SYMBOL(skb_put_uchar);
+
+/**
  *	skb_push - add data to the start of a buffer
  *	@skb: buffer to use
  *	@len: amount of data to add
-- 
2.1.4
