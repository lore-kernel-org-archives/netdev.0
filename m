From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] net/mlx4_en: Memory consumption issue with mlx4_en
 driver
Date: Wed, 11 Mar 2015 13:23:14 -0700
Message-ID: <1426105394.11398.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150311185146.GA1032293@devbig242.prn2.facebook.com>
	 <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	kernel-team@fb.com
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:39696 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbCKUXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:23:16 -0400
Received: by igdh15 with SMTP id h15so43643840igd.4
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 13:23:15 -0700 (PDT)
In-Reply-To: <1426105262.11398.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 13:21 -0700, Eric Dumazet wrote:

> You know, even the order-3 allocations done for regular skb allocations
> will hurt you : a single copybreaked skb stored a long time in a tcp
> receive queue will hold 32KB of memory.
> 
> Even 4KB can lead to disasters.
> 
> You could lower tcp_rmem so that collapsing happens sooner.

I also played with following :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6af09a597d4f..118568267a2a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -458,10 +458,17 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
                                   unsigned int length, gfp_t gfp_mask)
 {
        struct sk_buff *skb = NULL;
-       unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
-                             SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+       unsigned int fragsz;
 
-       if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
+       length = SKB_DATA_ALIGN(length + NET_SKB_PAD);
+       fragsz = length + SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+       /* if fragment is smaller than struct skb_shared_info overhead,
+        * do not bother use a page fragment, because malicious traffic
+        * could hold a full page (order-0 or order-3)
+        */
+       if (fragsz <= PAGE_SIZE &&
+           length > SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) &&
+           !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
                void *data;
 
                if (sk_memalloc_socks())
