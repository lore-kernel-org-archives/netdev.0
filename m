From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] skbuff: only inherit relevant tx_flags
Date: Thu,  8 Jun 2017 11:35:03 -0400
Message-ID: <20170608153503.74199-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, soheil@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36510 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbdFHPfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:35:15 -0400
Received: by mail-qt0-f196.google.com with SMTP id s33so8938455qtg.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 08:35:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When inheriting tx_flags from one skbuff to another, always apply a
mask to avoid overwriting unrelated other bits in the field.

The two SKBTX_SHARED_FRAG cases clears all other bits. In practice,
tx_flags are zero at this point now. But this is fragile. Timestamp
flags are set, for instance, if in tcp_gso_segment, after this clear
in skb_segment.

The SKBTX_ANY_TSTAMP mask in __skb_tstamp_tx ensures that new
skbs do not accidentally inherit flags such as SKBTX_SHARED_FRAG.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 82cfc9c7a090..e508c1eae67f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2646,7 +2646,8 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
 
-	skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
+	skb_shinfo(skb1)->tx_flags |= skb_shinfo(skb)->tx_flags &
+				      SKBTX_SHARED_FRAG;
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -3261,8 +3262,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		skb_copy_from_linear_data_offset(head_skb, offset,
 						 skb_put(nskb, hsize), hsize);
 
-		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags &
-			SKBTX_SHARED_FRAG;
+		skb_shinfo(nskb)->tx_flags |= skb_shinfo(head_skb)->tx_flags &
+					      SKBTX_SHARED_FRAG;
 
 		while (pos < offset + len) {
 			if (i >= nfrags) {
@@ -3948,7 +3949,8 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		return;
 
 	if (tsonly) {
-		skb_shinfo(skb)->tx_flags = skb_shinfo(orig_skb)->tx_flags;
+		skb_shinfo(skb)->tx_flags |= skb_shinfo(orig_skb)->tx_flags &
+					     SKBTX_ANY_TSTAMP;
 		skb_shinfo(skb)->tskey = skb_shinfo(orig_skb)->tskey;
 	}
 
-- 
2.13.0.506.g27d5fe0cd-goog
