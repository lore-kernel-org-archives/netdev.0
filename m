From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 3/8] skb: Add skb_push_uchar
Date: Mon,  4 May 2015 13:05:47 -0700
Message-ID: <1eb3a36cd2777ce7bb81b40937282237975b8cec.1430769295.git.joe@perches.com>
References: <cover.1430769294.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0008.hostedemail.com ([216.40.44.8]:36835 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752205AbbEDUGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:06:10 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay02.hostedemail.com (Postfix) with ESMTP id DDCDD12BA1A
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:09 +0000 (UTC)
Received: from joe-laptop.perches.com (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Mon,  4 May 2015 20:06:08 +0000 (UTC)
In-Reply-To: <cover.1430769294.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_push currently returns an unsigned char *.

There are uses like "*skb_push(skb, 1) = <char>" that might be
better represented by a new skb_push_uchar(<char>) function.

This would allow the skb_push function to be converted to
return void and eliminate many casts of the unsigned char *
return to some other type.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 894071e1..30cd234 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1690,6 +1690,7 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 }
 
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
+void *skb_push_uchar(struct sk_buff *skb, unsigned char uc);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
 	skb->data -= len;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 73e20ad..b092d2b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1455,6 +1455,28 @@ unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
 EXPORT_SYMBOL(skb_push);
 
 /**
+ *	skb_push_uchar - add an unsigned char to the start of a buffer
+ *	@skb: buffer to use
+ *	@uc: unsigned char to add
+ *
+ *	This function extends the used data area of the buffer at the buffer
+ *	start. If this would exceed the total buffer headroom the kernel will
+ *	panic. A pointer to the first byte of the extra data is returned.
+ */
+void *skb_push_uchar(struct sk_buff *skb, unsigned char uc)
+{
+	skb->data--;
+	skb->len++;
+	if (unlikely(skb->data<skb->head))
+		skb_under_panic(skb, 1, __builtin_return_address(0));
+
+	*skb->data = uc;
+
+	return skb->data;
+}
+EXPORT_SYMBOL(skb_push_uchar);
+
+/**
  *	skb_pull - remove data from the start of a buffer
  *	@skb: buffer to use
  *	@len: amount of data to remove
-- 
2.1.4
