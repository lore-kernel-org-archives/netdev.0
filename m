From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 10:01:56 +0400
Message-ID: <20060807060155.GA6487@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40611 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751093AbWHGGCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 02:02:10 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Attached patch allows to avoid unnecessary alignment overhead
in skb->data allocation.
Main idea is to allocate struct skb_shared_info from cache when
addition of sizeof(struct skb_shared_info) ens up in different order
allocation than initial size order.
This allows to solve problem with 4k allocations for 1500 MTU and 32k
allocations for 9k jumbo frames for some chips.
Patch was not tested, so if idea worth it I will complete it.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19c96d4..7474682 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -282,7 +282,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				shinfo_cache:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
@@ -403,7 +404,9 @@ extern unsigned int   skb_find_text(stru
 				    struct ts_state *state);
 
 /* Internal */
-#define skb_shinfo(SKB)		((struct skb_shared_info *)((SKB)->end))
+#define skb_shinfo(SKB)		((SKB)->shinfo_cache?\
+		(struct skb_shared_info *)(*((SKB)->end)):\
+		((struct skb_shared_info *)((SKB)->end)))
 
 /**
  *	skb_queue_empty - check if a queue is empty
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 022d889..7287814 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -69,6 +69,7 @@ #include <asm/system.h>
 
 static kmem_cache_t *skbuff_head_cache __read_mostly;
 static kmem_cache_t *skbuff_fclone_cache __read_mostly;
+static kmem_cache_t *skbuff_shared_info_cache __read_mostly;
 
 /*
  *	Keep out-of-line to prevent kernel bloat.
@@ -146,6 +147,8 @@ struct sk_buff *__alloc_skb(unsigned int
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
+	int order = get_order(size + sizeof(void *));
+	struct skb_shared_info *sh;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
@@ -156,11 +159,28 @@ struct sk_buff *__alloc_skb(unsigned int
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
-	data = ____kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
-	if (!data)
-		goto nodata;
+	if ((1UL << order) > size + sizeof(void *) + sizeof(struct skb_shared_info)) {
+		data = ____kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+		if (!data)
+			goto nodata;
+		memset(skb, 0, offsetof(struct sk_buff, truesize));
+	} else {
+		unsigned long *ptr;
+
+		data = ____kmalloc(size, gfp_mask);
+		if (!data)
+			goto nodata;
+		sh = kmem_cache_alloc(skbuff_shared_info_cache, gfp_mask);
+		if (!sh) {
+			kfree(data);
+			goto nodata;
+		}
+		memset(skb, 0, offsetof(struct sk_buff, truesize));
+		skb->shinfo_cache = 1;
+		ptr = data;
+		ptr[size] = sh;
+	}
 
-	memset(skb, 0, offsetof(struct sk_buff, truesize));
 	skb->truesize = size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
 	skb->head = data;
@@ -314,6 +334,8 @@ static void skb_release_data(struct sk_b
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
+		if (skb->shinfo_cache)
+			kmem_cache_free(skbuff_shared_info_cache, *(skb->end));
 	}
 }
 
@@ -500,6 +522,7 @@ #endif
 	C(data);
 	C(tail);
 	C(end);
+	C(shinfo_cache);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned = 1;
@@ -2057,6 +2080,14 @@ void __init skb_init(void)
 						NULL, NULL);
 	if (!skbuff_fclone_cache)
 		panic("cannot create skbuff cache");
+	
+	skbuff_shared_info_cache = kmem_cache_create("skbuff_shared_info_cache",
+						sizeof(struct sbk_shared_info),
+						0,
+						SLAB_HWCACHE_ALIGN,
+						NULL, NULL);
+	if (!skbuff_shared_info_cache)
+		panic("cannot create skbuff shared info cache");
 }
 
 EXPORT_SYMBOL(___pskb_trim);


-- 
	Evgeniy Polyakov
