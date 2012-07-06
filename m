From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Fri, 06 Jul 2012 07:16:04 +0200
Message-ID: <1341551764.3265.47.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	 <1341484919.2583.3688.camel@edumazet-glaptop>
	 <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
	 <1341500196.2583.4222.camel@edumazet-glaptop>
	 <CACVXFVMgwbz1fDC=_9dhVUZ_btiO3fNdFiuXm-7gMXFUAMtmsw@mail.gmail.com>
	 <1341550714.3265.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37192 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab2GFFQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 01:16:10 -0400
Received: by eeit10 with SMTP id t10so3462996eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 22:16:09 -0700 (PDT)
In-Reply-To: <1341550714.3265.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 06:58 +0200, Eric Dumazet wrote:
> On Fri, 2012-07-06 at 08:45 +0800, Ming Lei wrote:
> 
> > Unfortunately, the patch still hasn't any improvement on the transmit
> > performance of beagle-xm.
> 
> Ah yes, I need to change usbnet as well to be able to fully recycle the
> big skbs allocated in turbo mode.
> 
> Right now they are constantly allocated/freed and this sucks if SLAB
> wants to check poison bytes in debug mode.

In the mean time, you also can use the following patch I have to polish,
but this should give you a nice boost, since the big skb skb->head wont
be checked by SLAB debug :



diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b21522..d31efa2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -296,9 +296,18 @@ EXPORT_SYMBOL(build_skb);
 struct netdev_alloc_cache {
 	struct page *page;
 	unsigned int offset;
+	unsigned int pagecnt_bias;
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
+#if PAGE_SIZE > 32768
+#define MAX_NETDEV_FRAGSIZE	PAGE_SIZE
+#else
+#define MAX_NETDEV_FRAGSIZE	32768
+#endif
+
+#define NETDEV_PAGECNT_BIAS	(MAX_NETDEV_FRAGSIZE /		\
+				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 /**
  * netdev_alloc_frag - allocate a page fragment
  * @fragsz: fragment size
@@ -316,18 +325,25 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	nc = &__get_cpu_var(netdev_alloc_cache);
 	if (unlikely(!nc->page)) {
 refill:
-		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
+				       get_order(MAX_NETDEV_FRAGSIZE));
+		if (unlikely(!nc->page))
+			goto end;
+recycle:
+		atomic_set(&nc->page->_count, NETDEV_PAGECNT_BIAS);
+		nc->pagecnt_bias = NETDEV_PAGECNT_BIAS;
 		nc->offset = 0;
 	}
-	if (likely(nc->page)) {
-		if (nc->offset + fragsz > PAGE_SIZE) {
-			put_page(nc->page);
-			goto refill;
-		}
-		data = page_address(nc->page) + nc->offset;
-		nc->offset += fragsz;
-		get_page(nc->page);
+	if (nc->offset + fragsz > MAX_NETDEV_FRAGSIZE) {
+		if (!atomic_sub_return(nc->pagecnt_bias,
+				       &nc->page->_count))
+			goto recycle;
+		goto refill;
 	}
+	data = page_address(nc->page) + nc->offset;
+	nc->offset += fragsz;
+	nc->pagecnt_bias--; /* avoid get_page()/get_page() false sharing */
+end:
 	local_irq_restore(flags);
 	return data;
 }
@@ -353,7 +369,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
-	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
+	if (fragsz <= MAX_NETDEV_FRAGSIZE && !(gfp_mask & __GFP_WAIT)) {
 		void *data = netdev_alloc_frag(fragsz);
 
 		if (likely(data)) {
