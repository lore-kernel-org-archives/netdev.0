From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH RFC net-next 1/2] net: skbuff: propagate pfmemalloc to skb
Date: Sun, 24 Aug 2014 03:07:18 +0530
Message-ID: <1408829839-20742-2-git-send-email-_govind@gmx.com>
References: <1408829839-20742-1-git-send-email-_govind@gmx.com>
Cc: davem@davemloft.net, edumazet@google.com, mgorman@suse.de,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:61367 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbaHWVhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 17:37:45 -0400
In-Reply-To: <1408829839-20742-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __netdev_alloc_skb, __netdev_alloc_frag might have allocated page with
flag __GFP_MEMALLOC. But we do not propagate it to the skb.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 net/core/skbuff.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 163b673..51a3328 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -425,8 +425,14 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 
 		if (likely(data)) {
 			skb = build_skb(data, fragsz);
-			if (unlikely(!skb))
+			if (unlikely(!skb)) {
 				put_page(virt_to_head_page(data));
+			} else {
+				struct page *page;
+
+				page = virt_to_head_page(data);
+				skb_propagate_pfmemalloc(page, skb);
+			}
 		}
 	} else {
 		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
-- 
2.1.0
