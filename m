From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 07:56:37 +0000
Message-ID: <20090204075637.GA4279@ff.dom.local>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:55750 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbZBDH4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 02:56:46 -0500
Content-Disposition: inline
In-Reply-To: <20090203094108.GA4639@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 09:41:08AM +0000, Jarek Poplawski wrote:
> On Mon, Feb 02, 2009 at 11:50:17PM -0800, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 2 Feb 2009 08:43:58 +0000
> > 
> > > On Mon, Feb 02, 2009 at 12:18:54AM -0800, David Miller wrote:
> > > > Allocating 4096 or 8192 bytes for a 1500 byte frame is wasteful.
> > > 
> > > I mean allocating chunks of cached pages similarly to sk_sndmsg_page
> > > way. I guess the similar problem is to be worked out in any case. But
> > > it seems doing it on the linear area requires less changes in other
> > > places.
> > 
> > This is a very interesting idea, but it has some drawbacks:
> > 
> > 1) Just like any other allocator we'll need to find a way to
> >    handle > PAGE_SIZE allocations, and thus add handling for
> >    compound pages etc.
> >  
> >    And exactly the drivers that want such huge SKB data areas
> >    on receive should be converted to use scatter gather page
> >    vectors in order to avoid multi-order pages and thus strains
> >    on the page allocator.
> 
> I guess compound pages are handled by put_page() enough, but I don't
> think they should be main argument here, and I agree: scatter gather
> should be used where possible.
> 
> > 
> > 2) Space wastage and poor packing can be an issue.
> > 
> >    Even with SLAB/SLUB we get poor packing, look at Evegeniy's
> >    graphs that he made when writing his NTA patches.
> 
> I'm a bit lost here: could you "remind" the way page space would be
> used/saved in your paged variant e.g. for ~1500B skbs?

Here is some proof of concept to make sure I wasn't misunderstood.
alloc_paged() is used only for "normal" size skbs (2x ~1500B per page;
I think Herbert mentioned something like this at the beginning; it
also avoids allocs other than GFP_ATOMIC and GFP_KERNEL for
simplicity.)

I guess it could be replaced with any other mechanizm allocting to a
fragment or Evgeniy's allocator when it's ready.
 
Alas it's not tested, but if it works, I think it should show how
much gain is expected here for most common traffic.

Jarek P.
---

diff -Nurp a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2009-02-02 20:23:46.000000000 +0100
+++ b/include/linux/netdevice.h	2009-02-02 21:52:46.000000000 +0100
@@ -1154,6 +1154,9 @@ struct softnet_data
 	struct sk_buff		*completion_queue;
 
 	struct napi_struct	backlog;
+
+	struct page		*alloc_skb_page[2];
+	unsigned int		alloc_skb_off[2];
 };
 
 DECLARE_PER_CPU(struct softnet_data,softnet_data);
diff -Nurp a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2009-02-02 20:23:46.000000000 +0100
+++ b/include/linux/skbuff.h	2009-02-02 22:12:04.000000000 +0100
@@ -144,7 +144,8 @@ struct skb_shared_info {
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
-	unsigned short  gso_type;
+	__u8		gso_type;
+	__u8		alloc_paged;
 	__be32          ip6_frag_id;
 #ifdef CONFIG_HAS_DMA
 	unsigned int	num_dma_maps;
diff -Nurp a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2009-02-02 19:37:33.000000000 +0100
+++ b/net/core/dev.c	2009-02-02 23:15:55.000000000 +0100
@@ -5243,6 +5243,9 @@ static int __init net_dev_init(void)
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
+
+		queue->alloc_skb_page[0] = NULL;
+		queue->alloc_skb_page[1] = NULL;
 	}
 
 	dev_boot_phase = 0;
diff -Nurp a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c	2009-02-02 20:23:46.000000000 +0100
+++ b/net/core/skbuff.c	2009-02-02 23:57:10.000000000 +0100
@@ -151,6 +151,55 @@ void skb_truesize_bug(struct sk_buff *sk
 }
 EXPORT_SYMBOL(skb_truesize_bug);
 
+static inline void *alloc_paged(unsigned int size, gfp_t gfp_mask)
+{
+	struct softnet_data *sd;
+	unsigned long flags;
+	unsigned int off;
+	struct page *p;
+	void *ret;
+	int i;
+
+	if (size < 1400 || size > 2000)
+		return NULL;
+
+	if (gfp_mask == GFP_ATOMIC)
+		i = 0;
+	else if (gfp_mask == GFP_KERNEL)
+		i = 1;
+	else
+		return NULL;
+
+	local_irq_save(flags);
+	sd = &__get_cpu_var(softnet_data);
+	p = sd->alloc_skb_page[i];
+
+	if (p) {
+		off = sd->alloc_skb_off[i];
+		if (off + size > PAGE_SIZE) {
+			put_page(p);
+			goto new_page;
+		}
+	} else {
+new_page:
+		p = sd->alloc_skb_page[i] = alloc_pages(gfp_mask, 0);
+		if (!p) {
+			ret = NULL;
+			goto out;
+		}
+
+		off = 0;
+		/* hold one ref to this page until it's full */
+	}
+
+	get_page(p);
+	ret = page_address(p) + off;
+	sd->alloc_skb_off[i] = off + size;
+out:
+	local_irq_restore(flags);
+	return ret;
+}
+
 /* 	Allocate a new skbuff. We do this ourselves so we can fill in a few
  *	'private' fields and also do memory statistics to find all the
  *	[BEEP] leaks.
@@ -178,7 +227,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
-	u8 *data;
+	u8 *data, paged = 0;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
@@ -188,8 +237,13 @@ struct sk_buff *__alloc_skb(unsigned int
 		goto out;
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+	data = alloc_paged(size + sizeof(struct skb_shared_info), gfp_mask);
+	if (data)
+		paged = 1;
+	else
+		data = kmalloc_node_track_caller(size +
+						 sizeof(struct skb_shared_info),
+						 gfp_mask, node);
 	if (!data)
 		goto nodata;
 
@@ -214,6 +268,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->alloc_paged = paged;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -341,7 +396,10 @@ static void skb_release_data(struct sk_b
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		if (skb_shinfo(skb)->alloc_paged)
+			put_page(virt_to_page(skb->head));
+		else
+			kfree(skb->head);
 	}
 }
 
@@ -1380,7 +1438,7 @@ static inline int spd_fill_page(struct s
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
 
-	if (linear) {
+	if (linear && !skb_shinfo(skb)->alloc_paged) {
 		page = linear_to_page(page, len, &offset, skb);
 		if (!page)
 			return 1;
