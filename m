From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] gro: Remember number of held packets instead of counting every time
Date: Mon, 09 Feb 2009 15:00:36 +1100
Message-ID: <E1LWNK0-0000nY-SZ@gondolin.me.apana.org.au>
References: <20090209035930.GA2988@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34966 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753836AbZBIEAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 23:00:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Remember number of held packets instead of counting every time

This patch prepares for the move of the same_flow checks out of
dev_gro_receive.  As such we need to remember the number of held
packets since doing a loop just to count them every time is silly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   12 +++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7a5057f..e1d482c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -314,6 +314,9 @@ struct napi_struct {
 	spinlock_t		poll_lock;
 	int			poll_owner;
 #endif
+
+	unsigned int		gro_count;
+
 	struct net_device	*dev;
 	struct list_head	dev_list;
 	struct sk_buff		*gro_list;
diff --git a/net/core/dev.c b/net/core/dev.c
index 247f161..330534e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2372,6 +2372,7 @@ void napi_gro_flush(struct napi_struct *napi)
 		napi_gro_complete(skb);
 	}
 
+	napi->gro_count = 0;
 	napi->gro_list = NULL;
 }
 EXPORT_SYMBOL(napi_gro_flush);
@@ -2402,7 +2403,6 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	struct packet_type *ptype;
 	__be16 type = skb->protocol;
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
-	int count = 0;
 	int same_flow;
 	int mac_len;
 	int ret;
@@ -2430,8 +2430,6 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		NAPI_GRO_CB(skb)->free = 0;
 
 		for (p = napi->gro_list; p; p = p->next) {
-			count++;
-
 			if (!NAPI_GRO_CB(p)->same_flow)
 				continue;
 
@@ -2457,15 +2455,16 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		*pp = nskb->next;
 		nskb->next = NULL;
 		napi_gro_complete(nskb);
-		count--;
+		napi->gro_count--;
 	}
 
 	if (same_flow)
 		goto ok;
 
-	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS)
+	if (NAPI_GRO_CB(skb)->flush || napi->gro_count >= MAX_GRO_SKBS)
 		goto normal;
 
+	napi->gro_count++;
 	NAPI_GRO_CB(skb)->count = 1;
 	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
 	skb->next = napi->gro_list;
@@ -2713,6 +2712,7 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
 	INIT_LIST_HEAD(&napi->poll_list);
+	napi->gro_count = 0;
 	napi->gro_list = NULL;
 	napi->skb = NULL;
 	napi->poll = poll;
@@ -2741,6 +2741,7 @@ void netif_napi_del(struct napi_struct *napi)
 	}
 
 	napi->gro_list = NULL;
+	napi->gro_count = 0;
 }
 EXPORT_SYMBOL(netif_napi_del);
 
@@ -5246,6 +5247,7 @@ static int __init net_dev_init(void)
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
+		queue->backlog.gro_count = 0;
 	}
 
 	dev_boot_phase = 0;
