From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCHv2 next-next 1/3] net: move pskb_put() to core code
Date: Thu,  7 Nov 2013 14:18:24 +0100
Message-ID: <1383830306-16697-2-git-send-email-mathias.krause@secunet.com>
References: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55211 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab3KGNSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 08:18:39 -0500
In-Reply-To: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function has usage beside IPsec so move it to the core skbuff code.
While doing so, give it some documentation and change its return type to
'unsigned char *' to be in line with skb_put().

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
v2: kernel-doc fixes, as noticed by Ben

 include/linux/skbuff.h |    1 +
 include/net/esp.h      |    2 --
 net/core/skbuff.c      |   23 +++++++++++++++++++++++
 net/xfrm/xfrm_algo.c   |   13 -------------
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e153b6..491dd6c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1417,6 +1417,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 /*
  *	Add data to an sk_buff
  */
+unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
diff --git a/include/net/esp.h b/include/net/esp.h
index c92213c..a43be85 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -3,8 +3,6 @@
 
 #include <linux/skbuff.h>
 
-void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
-
 struct ip_esp_hdr;
 
 static inline struct ip_esp_hdr *ip_esp_hdr(const struct sk_buff *skb)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..2fbea08 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1264,6 +1264,29 @@ free_skb:
 EXPORT_SYMBOL(skb_pad);
 
 /**
+ *	pskb_put - add data to the tail of a potentially fragmented buffer
+ *	@skb: start of the buffer to use
+ *	@tail: tail fragment of the buffer to use
+ *	@len: amount of data to add
+ *
+ *	This function extends the used data area of the potentially
+ *	fragmented buffer. @tail must be the last fragment of @skb -- or
+ *	@skb itself. If this would exceed the total buffer size the kernel
+ *	will panic. A pointer to the first byte of the extra data is
+ *	returned.
+ */
+
+unsigned char *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
+{
+	if (tail != skb) {
+		skb->data_len += len;
+		skb->len += len;
+	}
+	return skb_put(tail, len);
+}
+EXPORT_SYMBOL_GPL(pskb_put);
+
+/**
  *	skb_put - add data to a buffer
  *	@skb: buffer to use
  *	@len: amount of data to add
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index ab4ef72..debe733 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -802,17 +802,4 @@ int xfrm_count_pfkey_enc_supported(void)
 }
 EXPORT_SYMBOL_GPL(xfrm_count_pfkey_enc_supported);
 
-#if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
-
-void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len)
-{
-	if (tail != skb) {
-		skb->data_len += len;
-		skb->len += len;
-	}
-	return skb_put(tail, len);
-}
-EXPORT_SYMBOL_GPL(pskb_put);
-#endif
-
 MODULE_LICENSE("GPL");
-- 
1.7.2.3
