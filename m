From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 15:21:54 +0200
Message-ID: <1340198514.4604.970.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f66.google.com ([209.85.214.66]:55675 "EHLO
	mail-bk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab2FTNWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 09:22:31 -0400
Received: by bkty5 with SMTP id y5so2187761bkt.1
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 06:22:29 -0700 (PDT)
In-Reply-To: <1340180223.4604.828.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 10:17 +0200, Eric Dumazet wrote:

> Strange, I did again benchs with order-2 allocations and got good
> results this time, but with latest net-next, maybe things have changed
> since last time I did this.
> 
> (netdev_alloc_frag(), get_page_from_freelist() and put_page() less
> prevalent in perf results)
> 

In fact, since SLUB uses order-3 for kmalloc-2048, I felt lucky to try
this as well, and results are really good, on ixgbe at least.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b21522..ffd2cba 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -299,6 +299,9 @@ struct netdev_alloc_cache {
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
+#define MAX_NETDEV_FRAGSIZE	max_t(unsigned int, PAGE_SIZE, 32768)
+#define NETDEV_FRAG_ORDER	get_order(MAX_NETDEV_FRAGSIZE)
+
 /**
  * netdev_alloc_frag - allocate a page fragment
  * @fragsz: fragment size
@@ -316,11 +319,13 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	nc = &__get_cpu_var(netdev_alloc_cache);
 	if (unlikely(!nc->page)) {
 refill:
-		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
+				       (NETDEV_FRAG_ORDER ? __GFP_COMP : 0),
+				       NETDEV_FRAG_ORDER);
 		nc->offset = 0;
 	}
 	if (likely(nc->page)) {
-		if (nc->offset + fragsz > PAGE_SIZE) {
+		if (nc->offset + fragsz > MAX_NETDEV_FRAGSIZE) {
 			put_page(nc->page);
 			goto refill;
 		}
@@ -353,7 +358,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
-	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
+	if (fragsz <= MAX_NETDEV_FRAGSIZE && !(gfp_mask & __GFP_WAIT)) {
 		void *data = netdev_alloc_frag(fragsz);
 
 		if (likely(data)) {
