From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net : optimize skb_release_data()
Date: Tue, 23 Sep 2014 18:39:30 -0700
Message-ID: <1411522770.15395.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:60798 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaIXBjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 21:39:39 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so7482885pad.26
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 18:39:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Cache skb_shinfo(skb) in a variable to avoid computing it multiple
times.

Reorganize the tests to remove one indentation level.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 06a8feb10099..d4fdc649112c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -491,32 +491,33 @@ static void skb_free_head(struct sk_buff *skb)
 
 static void skb_release_data(struct sk_buff *skb)
 {
-	if (!skb->cloned ||
-	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
-			       &skb_shinfo(skb)->dataref)) {
-		if (skb_shinfo(skb)->nr_frags) {
-			int i;
-			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-				skb_frag_unref(skb, i);
-		}
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	int i;
 
-		/*
-		 * If skb buf is from userspace, we need to notify the caller
-		 * the lower device DMA has done;
-		 */
-		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
-			struct ubuf_info *uarg;
+	if (skb->cloned &&
+	    atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
+			      &shinfo->dataref))
+		return;
 
-			uarg = skb_shinfo(skb)->destructor_arg;
-			if (uarg->callback)
-				uarg->callback(uarg, true);
-		}
+	for (i = 0; i < shinfo->nr_frags; i++)
+		__skb_frag_unref(&shinfo->frags[i]);
 
-		if (skb_has_frag_list(skb))
-			skb_drop_fraglist(skb);
+	/*
+	 * If skb buf is from userspace, we need to notify the caller
+	 * the lower device DMA has done;
+	 */
+	if (shinfo->tx_flags & SKBTX_DEV_ZEROCOPY) {
+		struct ubuf_info *uarg;
 
-		skb_free_head(skb);
+		uarg = shinfo->destructor_arg;
+		if (uarg->callback)
+			uarg->callback(uarg, true);
 	}
+
+	if (shinfo->frag_list)
+		kfree_skb_list(shinfo->frag_list);
+
+	skb_free_head(skb);
 }
 
 /*
