From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Frag list lost on head expansion.
Date: Thu, 02 Sep 2010 20:43:32 -0700 (PDT)
Message-ID: <20100902.204332.02275687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58092
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755747Ab0ICDnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 23:43:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0C77524C087
	for <netdev@vger.kernel.org>; Thu,  2 Sep 2010 20:43:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When pskb_expand_head() releases the data, with skb_release_data(), it
tries to properly preserve any fragment list using
skb_clone_fraglist().

Although skb_clone_fraglist() will properly grab a reference to all of
the fragment list SKBs, it will not block skb_release_data() from
NULL'ing out the ->frag_list pointer when it calls skb_drop_list() via
skb_drop_fraglist().

As a result we lose the fragment SKBs and they are leaked forever.

Instead, hide the fragment list pointer around the skb_release_data()
call and restore it afterwards.  This fixes the bug and also makes
it cheaper since we won't grab and release every single fragment
list SKB reference.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I found this via pure code inspection, please review.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 26396ff..def2e49 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -789,6 +789,7 @@ EXPORT_SYMBOL(pskb_copy);
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		     gfp_t gfp_mask)
 {
+	struct sk_buff *frag_list;
 	int i;
 	u8 *data;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
@@ -822,11 +823,13 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		get_page(skb_shinfo(skb)->frags[i].page);
 
-	if (skb_has_frags(skb))
-		skb_clone_fraglist(skb);
+	frag_list = skb_shinfo(skb)->frag_list;
+	skb_shinfo(skb)->frag_list = NULL;
 
 	skb_release_data(skb);
 
+	skb_shinfo(skb)->frag_list = frag_list;
+
 	off = (data + nhead) - skb->head;
 
 	skb->head     = data;
