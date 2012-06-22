From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Fri, 22 Jun 2012 14:33:50 +0200
Message-ID: <1340368430.4604.10280.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
	 <1340198514.4604.970.camel@edumazet-glaptop>  <4FE29DE4.1010705@gmail.com>
	 <1340255226.4604.3774.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55127 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761835Ab2FVMdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 08:33:55 -0400
Received: by bkcji2 with SMTP id ji2so1480460bkc.19
        for <netdev@vger.kernel.org>; Fri, 22 Jun 2012 05:33:54 -0700 (PDT)
In-Reply-To: <1340255226.4604.3774.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 07:07 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 21:07 -0700, Alexander Duyck wrote:
> > On 6/20/2012 6:21 AM, Eric Dumazet wrote:
> 
> > > +		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
> > > +				       (NETDEV_FRAG_ORDER ? __GFP_COMP : 0),
> > > +				       NETDEV_FRAG_ORDER);
> 
> > I was wondering if you needed the check for NETDEV_FRAG_ORDER here.  
> >  From what I can tell setting __GFP_COMP for an order 0 page has no 
> > effect since it only seems to get checked in prep_new_page and that is 
> > after a check to verify if the page is order 0 or not.
> 
> Good point, it seems some net drivers could be changed to remove
> useless tests.
> 
> I'll post some performance data as well.

Here is the patch I tested here.

Using 32768 bytes allocations is actually nice for MTU=9000 traffic,
since we can fit 3 frames per 32KB instead of only 2 frames (using
kmalloc-16384 slab))

Also, I prefill page->_count with a high bias value, to avoid the
get_page() we did for each allocated frag.

In my profiles, the get_page() cost was dominant, because of false
sharing with skb consumers (as they might run on different cpus)

This way, when 32768 bytes are filled, we perform a single
atomic_sub_return() and can recycle the page if we find we are the last
user (this is what you did in your patch, when testing page->_count
being 1)

Note : If I used max(PAGE_SIZE, 32678) for MAX_NETDEV_FRAGSIZE,
gcc was not able to optimise get_order(MAX_NETDEV_FRAGSIZE), strange...


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
