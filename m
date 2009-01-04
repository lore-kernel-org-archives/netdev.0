From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Sun, 4 Jan 2009 16:18:19 +0100
Message-ID: <20090104151819.GA6590@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix up truesize after pskb_expand_head() in wireless stack
 
When using a zd1211rw wireless usb stick I regularly got truesize
warnings in the kernel log.

This patch fixes those up in the wireless layer. tx.c already
did that, but not rx.c. I think my messages only came from
the middle case, but I fixed up all three users in rx.c 

The underlying problem seems to be that pskb_expand_head() doesn't 
manipulate truesize. Perhaps it should? I suspect more users of it have 
the same problem. I didn't change the low level code because
I was afraid to break some callers, but perhaps it would be
better to do it this way. Anyways here's a patch that only
changes it in the wireless layer with minimal risk.

Patch against 2.6.28, but I think linus git still has the same
issue.

I believe this is a 2.6.28 stable candidate. I even saw
the same problem in 2.6.27.

Signed-off-by: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

---
 net/mac80211/rx.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

Index: linux-2.6.28-test/net/mac80211/rx.c
===================================================================
--- linux-2.6.28-test.orig/net/mac80211/rx.c	2008-10-24 13:35:11.000000000 +0200
+++ linux-2.6.28-test/net/mac80211/rx.c	2009-01-01 15:51:34.000000000 +0100
@@ -263,10 +263,12 @@
 		 * probably export the length to drivers so that we can have
 		 * them allocate enough headroom to start with.
 		 */
-		if (skb_headroom(skb) < needed_headroom &&
-		    pskb_expand_head(skb, needed_headroom, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			return NULL;
+		if (skb_headroom(skb) < needed_headroom) {
+			if (pskb_expand_head(skb, needed_headroom, 0, GFP_ATOMIC)) {
+				dev_kfree_skb(skb);
+				return NULL;
+			}
+			skb->truesize += needed_headroom;
 		}
 	} else {
 		/*
@@ -945,6 +947,7 @@
 			__skb_queue_purge(&entry->skb_list);
 			return RX_DROP_UNUSABLE;
 		}
+		rx->skb->truesize += entry->extra_len;
 	}
 	while ((skb = __skb_dequeue(&entry->skb_list))) {
 		memcpy(skb_put(rx->skb, skb->len), skb->data, skb->len);
@@ -1691,9 +1694,11 @@
 	if (rx->flags & IEEE80211_RX_CMNTR_REPORTED)
 		goto out_free_skb;
 
-	if (skb_headroom(skb) < sizeof(*rthdr) &&
-	    pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC))
-		goto out_free_skb;
+	if (skb_headroom(skb) < sizeof(*rthdr)) {
+		if (pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC))
+			goto out_free_skb;
+		skb->truesize += sizeof(*rthdr);
+	}
 
 	rthdr = (void *)skb_push(skb, sizeof(*rthdr));
 	memset(rthdr, 0, sizeof(*rthdr));
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
