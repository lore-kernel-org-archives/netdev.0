From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Thu, 17 May 2012 19:34:16 +0200
Message-ID: <1337276056.3403.37.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
	 <1337273387.3403.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46325 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760274Ab2EQReX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 13:34:23 -0400
Received: by eeit10 with SMTP id t10so605967eei.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 10:34:22 -0700 (PDT)
In-Reply-To: <1337273387.3403.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Please note I havent tested yet this patch, lacking hardware for this.

(tg3/bnx2/bnx2x use build_skb, r8169 does a copy of incoming frames,
ixgbe uses fragments...)

Any volunteer ?

Thanks

[PATCH net-next] net: netdev_alloc_skb() use build_skb()

netdev_alloc_skb() is used by networks driver in their RX path to
allocate an skb to receive an incoming frame.

With recent skb->head_frag infrastructure, it makes sense to change
netdev_alloc_skb() to use build_skb() and a frag allocator.

This permits a zero copy splice(socket->pipe), and better GRO or TCP
coalescing.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2a18719..c02a8ec 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -293,6 +293,12 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 }
 EXPORT_SYMBOL(build_skb);
 
+struct netdev_alloc_cache {
+	struct page *page;
+	unsigned int offset;
+};
+static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
+
 /**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
@@ -310,8 +316,32 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
+	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
+			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
+		struct netdev_alloc_cache *nc;
+		void *data = NULL;
+
+		nc = &get_cpu_var(netdev_alloc_cache);
+		if (!nc->page) {
+refill:			nc->page = alloc_page(gfp_mask);
+			nc->offset = 0;
+		}
+		if (likely(nc->page)) {
+			if (nc->offset + fragsz > PAGE_SIZE) {
+				put_page(nc->page);
+				goto refill;
+			}
+			data = page_address(nc->page) + nc->offset;
+			nc->offset += fragsz;
+			get_page(nc->page);
+		}
+		put_cpu_var(netdev_alloc_cache);
+		skb = data ? build_skb(data, fragsz) : NULL;
+	} else {
+		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+	}
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
