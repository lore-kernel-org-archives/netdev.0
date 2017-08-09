From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/2] sock: fix zerocopy_success regression with msg_zerocopy
Date: Wed,  9 Aug 2017 19:09:44 -0400
Message-ID: <20170809230944.59289-3-willemdebruijn.kernel@gmail.com>
References: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, dsahern@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35267 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdHIXJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:09:53 -0400
Received: by mail-qk0-f196.google.com with SMTP id a77so7071782qkb.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 16:09:53 -0700 (PDT)
In-Reply-To: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Do not use uarg->zerocopy outside msg_zerocopy. In other paths the
field is not explicitly initialized and aliases another field.

Those paths have only one reference so do not need this intermediate
variable. Call uarg->callback directly.

Fixes: 1f8b977ab32d ("sock: enable MSG_ZEROCOPY")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8c0708d2e5e6..7594e19bce62 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1273,8 +1273,13 @@ static inline void skb_zcopy_clear(struct sk_buff *skb, bool zerocopy)
 	struct ubuf_info *uarg = skb_zcopy(skb);
 
 	if (uarg) {
-		uarg->zerocopy = uarg->zerocopy && zerocopy;
-		sock_zerocopy_put(uarg);
+		if (uarg->callback == sock_zerocopy_callback) {
+			uarg->zerocopy = uarg->zerocopy && zerocopy;
+			sock_zerocopy_put(uarg);
+		} else {
+			uarg->callback(uarg, zerocopy);
+		}
+
 		skb_shinfo(skb)->tx_flags &= ~SKBTX_ZEROCOPY_FRAG;
 	}
 }
-- 
2.14.0.434.g98096fd7a8-goog
