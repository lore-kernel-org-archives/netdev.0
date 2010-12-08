From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: use size of fetched data in
 __load_pointer()
Date: Wed, 08 Dec 2010 09:26:15 +0100
Message-ID: <1291796775.2883.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32964 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335Ab0LHI0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 03:26:18 -0500
Received: by wwa36 with SMTP id 36so891105wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 00:26:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__load_pointer() checks data we fetch from skb is included in head
portion, but assumes we fetch one byte, instead of up to four.

This wont crash because we have extra bytes (struct skb_shared_info)
after head, but this can read uninitialized bytes.

Fix this using size of the data (1, 2, 4 bytes) in the test.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/filter.c b/net/core/filter.c
index 25500f1..a57991e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -88,7 +88,7 @@ enum {
 };
 
 /* No hurry in this branch */
-static void *__load_pointer(const struct sk_buff *skb, int k)
+static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
 {
 	u8 *ptr = NULL;
 
@@ -97,7 +97,7 @@ static void *__load_pointer(const struct sk_buff *skb, int k)
 	else if (k >= SKF_LL_OFF)
 		ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
 
-	if (ptr >= skb->head && ptr < skb_tail_pointer(skb))
+	if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
 		return ptr;
 	return NULL;
 }
@@ -110,7 +110,7 @@ static inline void *load_pointer(const struct sk_buff *skb, int k,
 	else {
 		if (k >= SKF_AD_OFF)
 			return NULL;
-		return __load_pointer(skb, k);
+		return __load_pointer(skb, k, size);
 	}
 }
 


