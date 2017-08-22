From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 1/2] net: core: Specify skb_pad()/skb_put_padto() SKB freeing
Date: Tue, 22 Aug 2017 15:12:14 -0700
Message-ID: <20170822221215.16305-2-f.fainelli@gmail.com>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, UNGLinuxDriver@microchip.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35039 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdHVWM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 18:12:27 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so474658wmd.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 15:12:26 -0700 (PDT)
In-Reply-To: <20170822221215.16305-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename skb_pad() into __skb_pad() and make it take a third argument:
free_on_error which controls whether kfree_skb() should be called or
not, skb_pad() directly makes use of it and passes true to preserve its
existing behavior. Do exactly the same thing with __skb_put_padto() and
skb_put_padto().

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/skbuff.h | 41 +++++++++++++++++++++++++++++++++++++----
 net/core/skbuff.c      | 13 ++++++++-----
 2 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dbe29b6c9bd6..d67a8182e5eb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -973,7 +973,23 @@ int __must_check skb_to_sgvec_nomark(struct sk_buff *skb, struct scatterlist *sg
 int __must_check skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg,
 			      int offset, int len);
 int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
-int skb_pad(struct sk_buff *skb, int pad);
+int __skb_pad(struct sk_buff *skb, int pad, bool free_on_error);
+
+/**
+ *	skb_pad			-	zero pad the tail of an skb
+ *	@skb: buffer to pad
+ *	@pad: space to pad
+ *
+ *	Ensure that a buffer is followed by a padding area that is zero
+ *	filled. Used by network drivers which may DMA or transfer data
+ *	beyond the buffer end onto the wire.
+ *
+ *	May return error in out of memory cases. The skb is freed on error.
+ */
+static inline int skb_pad(struct sk_buff *skb, int pad)
+{
+	return __skb_pad(skb, pad, true);
+}
 #define dev_kfree_skb(a)	consume_skb(a)
 
 int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
@@ -2825,25 +2841,42 @@ static inline int skb_padto(struct sk_buff *skb, unsigned int len)
  *	skb_put_padto - increase size and pad an skbuff up to a minimal size
  *	@skb: buffer to pad
  *	@len: minimal length
+ *	@free_on_error: free buffer on error
  *
  *	Pads up a buffer to ensure the trailing bytes exist and are
  *	blanked. If the buffer already contains sufficient data it
  *	is untouched. Otherwise it is extended. Returns zero on
- *	success. The skb is freed on error.
+ *	success. The skb is freed on error if @free_on_error is true.
  */
-static inline int skb_put_padto(struct sk_buff *skb, unsigned int len)
+static inline int __skb_put_padto(struct sk_buff *skb, unsigned int len,
+				  bool free_on_error)
 {
 	unsigned int size = skb->len;
 
 	if (unlikely(size < len)) {
 		len -= size;
-		if (skb_pad(skb, len))
+		if (__skb_pad(skb, len, free_on_error))
 			return -ENOMEM;
 		__skb_put(skb, len);
 	}
 	return 0;
 }
 
+/**
+ *	skb_put_padto - increase size and pad an skbuff up to a minimal size
+ *	@skb: buffer to pad
+ *	@len: minimal length
+ *
+ *	Pads up a buffer to ensure the trailing bytes exist and are
+ *	blanked. If the buffer already contains sufficient data it
+ *	is untouched. Otherwise it is extended. Returns zero on
+ *	success. The skb is freed on error.
+ */
+static inline int skb_put_padto(struct sk_buff *skb, unsigned int len)
+{
+	return __skb_put_padto(skb, len, true);
+}
+
 static inline int skb_add_data(struct sk_buff *skb,
 			       struct iov_iter *from, int copy)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f990eb8b30a9..e07556606284 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1363,18 +1363,20 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 EXPORT_SYMBOL(skb_copy_expand);
 
 /**
- *	skb_pad			-	zero pad the tail of an skb
+ *	__skb_pad		-	zero pad the tail of an skb
  *	@skb: buffer to pad
  *	@pad: space to pad
+ *	@free_on_error: free buffer on error
  *
  *	Ensure that a buffer is followed by a padding area that is zero
  *	filled. Used by network drivers which may DMA or transfer data
  *	beyond the buffer end onto the wire.
  *
- *	May return error in out of memory cases. The skb is freed on error.
+ *	May return error in out of memory cases. The skb is freed on error
+ *	if @free_on_error is true.
  */
 
-int skb_pad(struct sk_buff *skb, int pad)
+int __skb_pad(struct sk_buff *skb, int pad, bool free_on_error)
 {
 	int err;
 	int ntail;
@@ -1403,10 +1405,11 @@ int skb_pad(struct sk_buff *skb, int pad)
 	return 0;
 
 free_skb:
-	kfree_skb(skb);
+	if (free_on_error)
+		kfree_skb(skb);
 	return err;
 }
-EXPORT_SYMBOL(skb_pad);
+EXPORT_SYMBOL(__skb_pad);
 
 /**
  *	pskb_put - add data to the tail of a potentially fragmented buffer
-- 
2.9.3
