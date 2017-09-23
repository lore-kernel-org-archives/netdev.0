From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: speed up skb_rbtree_purge()
Date: Sat, 23 Sep 2017 12:39:12 -0700
Message-ID: <1506195552.29839.214.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34632 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdIWTjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:39:14 -0400
Received: by mail-pf0-f193.google.com with SMTP id g65so1896460pfe.1
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 12:39:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As measured in my prior patch ("sch_netem: faster rb tree removal"),
rbtree_postorder_for_each_entry_safe() is nice looking but much slower
than using rb_next() directly, except when tree is small enough
to fit in CPU caches (then the cost is the same)

Also note that there is not even an increase of text size :
$ size net/core/skbuff.o.before net/core/skbuff.o
   text	   data	    bss	    dec	    hex	filename
  40711	   1298	      0	  42009	   a419	net/core/skbuff.o.before
  40711	   1298	      0	  42009	   a419	net/core/skbuff.o


From: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 16982de649b97b92423a4f9f5eac1e98ca803370..000ce735fa8d649e7abeeef2ebab8501dea96efd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2848,12 +2848,15 @@ EXPORT_SYMBOL(skb_queue_purge);
  */
 void skb_rbtree_purge(struct rb_root *root)
 {
-	struct sk_buff *skb, *next;
+	struct rb_node *p = rb_first(root);
 
-	rbtree_postorder_for_each_entry_safe(skb, next, root, rbnode)
-		kfree_skb(skb);
+	while (p) {
+		struct sk_buff *skb = rb_entry(p, struct sk_buff, rbnode);
 
-	*root = RB_ROOT;
+		p = rb_next(p);
+		rb_erase(&skb->rbnode, root);
+		kfree_skb(skb);
+	}
 }
 
 /**
