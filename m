From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] remove dead skb_iter* functions
Date: Mon, 01 Nov 2004 19:40:51 +0100
Message-ID: <41868333.7050602@trash.net>
References: <20041101115653.GA7714@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041101115653.GA7714@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald is working on code for pattern-matching inside
non-linear skbs for conntrack helpers. This code needs
the skb_iter* functions.

Regards
Patrick

Christoph Hellwig wrote:

>Signed-off-by: Christoph Hellwig <hch@lst.de>
>
>
>
>--- 1.56/include/linux/skbuff.h	2004-10-05 23:51:01 +02:00
>+++ edited/include/linux/skbuff.h	2004-10-30 21:04:33 +02:00
>@@ -592,7 +592,6 @@
> /*
>  *	Insert a packet on a list.
>  */
>-extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk);
> static inline void __skb_insert(struct sk_buff *newsk,
> 				struct sk_buff *prev, struct sk_buff *next,
> 				struct sk_buff_head *list)
>@@ -1120,22 +1119,6 @@
> 
> extern void skb_init(void);
> extern void skb_add_mtu(int mtu);
>-
>-struct skb_iter {
>-	/* Iteration functions set these */
>-	unsigned char *data;
>-	unsigned int len;
>-
>-	/* Private to iteration */
>-	unsigned int nextfrag;
>-	struct sk_buff *fraglist;
>-};
>-
>-/* Keep iterating until skb_iter_next returns false. */
>-extern void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i);
>-extern int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i);
>-/* Call this if aborting loop before !skb_iter_next */
>-extern void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i);
> 
> #ifdef CONFIG_NETFILTER
> static inline void nf_conntrack_put(struct nf_conntrack *nfct)
>--- 1.39/net/core/skbuff.c	2004-10-20 06:56:24 +02:00
>+++ edited/net/core/skbuff.c	2004-10-30 21:04:33 +02:00
>@@ -929,72 +929,7 @@
> 	return -EFAULT;
> }
> 
>-/* Keep iterating until skb_iter_next returns false. */
>-void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i)
>-{
>-	i->len = skb_headlen(skb);
>-	i->data = (unsigned char *)skb->data;
>-	i->nextfrag = 0;
>-	i->fraglist = NULL;
>-}
>-
>-int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i)
>-{
>-	/* Unmap previous, if not head fragment. */
>-	if (i->nextfrag)
>-		kunmap_skb_frag(i->data);
>-
>-	if (i->fraglist) {
>-	fraglist:
>-		/* We're iterating through fraglist. */
>-		if (i->nextfrag < skb_shinfo(i->fraglist)->nr_frags) {
>-			i->data = kmap_skb_frag(&skb_shinfo(i->fraglist)
>-						->frags[i->nextfrag]);
>-			i->len = skb_shinfo(i->fraglist)->frags[i->nextfrag]
>-				.size;
>-			i->nextfrag++;
>-			return 1;
>-		}
>-		/* Fragments with fragments?  Too hard! */
>-		BUG_ON(skb_shinfo(i->fraglist)->frag_list);
>-		i->fraglist = i->fraglist->next;
>-		if (!i->fraglist)
>-			goto end;
>-
>-		i->len = skb_headlen(i->fraglist);
>-		i->data = i->fraglist->data;
>-		i->nextfrag = 0;
>-		return 1;
>-	}
>-
>-	if (i->nextfrag < skb_shinfo(skb)->nr_frags) {
>-		i->data = kmap_skb_frag(&skb_shinfo(skb)->frags[i->nextfrag]);
>-		i->len = skb_shinfo(skb)->frags[i->nextfrag].size;
>-		i->nextfrag++;
>-		return 1;
>-	}
>-
>-	i->fraglist = skb_shinfo(skb)->frag_list;
>-	if (i->fraglist)
>-		goto fraglist;
>-
>-end:
>-	/* Bug trap for callers */
>-	i->data = NULL;
>-	return 0;
>-}
>-
>-void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i)
>-{
>-	/* Unmap previous, if not head fragment. */
>-	if (i->data && i->nextfrag)
>-		kunmap_skb_frag(i->data);
>-	/* Bug trap for callers */
>-	i->data = NULL;
>-}
>-
> /* Checksum skb data. */
>-
> unsigned int skb_checksum(const struct sk_buff *skb, int offset,
> 			  int len, unsigned int csum)
> {
>@@ -1318,25 +1253,6 @@
> }
> 
> 
>-/**
>- *	skb_insert	-	insert a buffer
>- *	@old: buffer to insert before
>- *	@newsk: buffer to insert
>- *
>- *	Place a packet before a given packet in a list. The list locks are taken
>- *	and this function is atomic with respect to other list locked calls
>- *	A buffer cannot be placed on two lists at the same time.
>- */
>-
>-void skb_insert(struct sk_buff *old, struct sk_buff *newsk)
>-{
>-	unsigned long flags;
>-
>-	spin_lock_irqsave(&old->list->lock, flags);
>-	__skb_insert(newsk, old->prev, old, old->list);
>-	spin_unlock_irqrestore(&old->list->lock, flags);
>-}
>-
> #if 0
> /*
>  * 	Tune the memory allocator for a new MTU size.
>@@ -1444,7 +1360,6 @@
> EXPORT_SYMBOL(pskb_expand_head);
> EXPORT_SYMBOL(skb_checksum);
> EXPORT_SYMBOL(skb_clone);
>-EXPORT_SYMBOL(skb_clone_fraglist);
> EXPORT_SYMBOL(skb_copy);
> EXPORT_SYMBOL(skb_copy_and_csum_bits);
> EXPORT_SYMBOL(skb_copy_and_csum_dev);
>@@ -1456,13 +1371,8 @@
> EXPORT_SYMBOL(skb_under_panic);
> EXPORT_SYMBOL(skb_dequeue);
> EXPORT_SYMBOL(skb_dequeue_tail);
>-EXPORT_SYMBOL(skb_insert);
> EXPORT_SYMBOL(skb_queue_purge);
> EXPORT_SYMBOL(skb_queue_head);
> EXPORT_SYMBOL(skb_queue_tail);
> EXPORT_SYMBOL(skb_unlink);
> EXPORT_SYMBOL(skb_append);
>-EXPORT_SYMBOL(skb_split);
>-EXPORT_SYMBOL(skb_iter_first);
>-EXPORT_SYMBOL(skb_iter_next);
>-EXPORT_SYMBOL(skb_iter_abort);
>
>  
>
