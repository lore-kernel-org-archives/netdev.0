From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use kfree_skb_list() helper
Date: Fri, 20 Dec 2013 14:29:08 -0800
Message-ID: <1387578548.19078.471.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f170.google.com ([209.85.161.170]:54166 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114Ab3LTW3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:29:11 -0500
Received: by mail-gg0-f170.google.com with SMTP id 24so707310gge.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 14:29:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We can use kfree_skb_list() instead of open coding it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c    |   18 +++---------------
 net/core/skbuff.c |    5 +----
 2 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c482fe8abf87..973c23656673 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2454,13 +2454,8 @@ static void dev_gso_skb_destructor(struct sk_buff *skb)
 {
 	struct dev_gso_cb *cb;
 
-	do {
-		struct sk_buff *nskb = skb->next;
-
-		skb->next = nskb->next;
-		nskb->next = NULL;
-		kfree_skb(nskb);
-	} while (skb->next);
+	kfree_skb_list(skb->next);
+	skb->next = NULL;
 
 	cb = DEV_GSO_CB(skb);
 	if (cb->destructor)
@@ -4240,17 +4235,10 @@ EXPORT_SYMBOL(netif_napi_add);
 
 void netif_napi_del(struct napi_struct *napi)
 {
-	struct sk_buff *skb, *next;
-
 	list_del_init(&napi->dev_list);
 	napi_free_frags(napi);
 
-	for (skb = napi->gro_list; skb; skb = next) {
-		next = skb->next;
-		skb->next = NULL;
-		kfree_skb(skb);
-	}
-
+	kfree_skb_list(napi->gro_list);
 	napi->gro_list = NULL;
 	napi->gro_count = 0;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2b6b863f51f2..eb96c2c22400 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2981,10 +2981,7 @@ perform_csum_check:
 	return segs;
 
 err:
-	while ((skb = segs)) {
-		segs = skb->next;
-		kfree_skb(skb);
-	}
+	kfree_skb_list(segs);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(skb_segment);
