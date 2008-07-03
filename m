From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 01/05: add dynamically sized qdisc class hash helpers
Date: Thu, 3 Jul 2008 14:18:24 +0200
Message-ID: <20080703121824.GA2559@ami.dom.local>
References: <20080701143411.26309.41549.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:61842 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758626AbYGCMS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:18:28 -0400
Received: by ug-out-1314.google.com with SMTP id h2so674502ugf.16
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 05:18:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080701143411.26309.41549.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few tiny doubts below...

Patrick McHardy wrote, On 07/01/2008 04:34 PM:

> net-sched: add dynamically sized qdisc class hash helpers
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
> commit fe2579f858479ce266763ba861c87cd0371389af
> tree fe574771047ca02df76c7ec07d70b9402278531a
> parent 98cd24a4b3ac9ba234631803a05f96c3fddb500b
> author Patrick McHardy <kaber@trash.net> Tue, 01 Jul 2008 14:02:55 +0200
> committer Patrick McHardy <kaber@trash.net> Tue, 01 Jul 2008 14:02:55 +0200
> 
>  include/net/sch_generic.h |   41 ++++++++++++++++++
>  net/sched/sch_api.c       |  104 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 145 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a87fc03..0541d3c 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -167,6 +167,47 @@ extern void qdisc_unlock_tree(struct net_device *dev);
>  extern struct Qdisc noop_qdisc;
>  extern struct Qdisc_ops noop_qdisc_ops;
>  
> +struct Qdisc_class_common
> +{
> +	u32			classid;
> +	struct hlist_node	hnode;
> +};
> +
> +struct Qdisc_class_hash
> +{
> +	struct hlist_head	*hash;
> +	unsigned int		hashsize;
> +	unsigned int		hashmask;

?	u32			hashmask;

> +	unsigned int		hashelems;
> +};
> +
> +static inline unsigned int qdisc_class_hash(u32 id, u32 mask)
> +{
> +	id ^= id >> 8;
> +	id ^= id >> 4;
> +	return id & mask;
> +}
> +
> +static inline void *qdisc_class_find(struct Qdisc_class_hash *hash, u32 id)

Why not Qdisc_class_common *?

> +{
> +	struct Qdisc_class_common *cl;
> +	struct hlist_node *n;
> +	unsigned int h;
> +
> +	h = qdisc_class_hash(id, hash->hashmask);
> +	hlist_for_each_entry(cl, n, &hash->hash[h], hnode) {
> +		if (cl->classid == id)
> +			return cl;
> +	}
> +	return NULL;
> +}
> +
> +extern int qdisc_class_hash_init(struct Qdisc_class_hash *);
> +extern void qdisc_class_hash_insert(struct Qdisc_class_hash *, struct Qdisc_class_common *);
> +extern void qdisc_class_hash_remove(struct Qdisc_class_hash *, struct Qdisc_class_common *);
> +extern void qdisc_class_hash_grow(struct Qdisc *, struct Qdisc_class_hash *);
> +extern void qdisc_class_hash_destroy(struct Qdisc_class_hash *);
> +
>  extern void dev_init_scheduler(struct net_device *dev);
>  extern void dev_shutdown(struct net_device *dev);
>  extern void dev_activate(struct net_device *dev);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 10f01ad..e9ebc7a 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -316,6 +316,110 @@ void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_cancel);
>  
> +struct hlist_head *qdisc_class_hash_alloc(unsigned int n)
> +{
> +	unsigned int size = n * sizeof(struct hlist_head), i;
> +	struct hlist_head *h;
> +
> +	if (size <= PAGE_SIZE)
> +		h = kmalloc(size, GFP_KERNEL);
> +	else
> +		h = (struct hlist_head *)
> +			__get_free_pages(GFP_KERNEL, get_order(size));
> +
> +	if (h != NULL) {
> +		for (i = 0; i < n; i++)
> +			INIT_HLIST_HEAD(&h[i]);
> +	}
> +	return h;
> +}
> +
> +static void qdisc_class_hash_free(struct hlist_head *h, unsigned int n)
> +{
> +	unsigned int size = n * sizeof(struct hlist_head);
> +
> +	if (size <= PAGE_SIZE)
> +		kfree(h);
> +	else
> +		free_pages((unsigned long)h, get_order(size));
> +}
> +
> +void qdisc_class_hash_grow(struct Qdisc *sch, struct Qdisc_class_hash *clhash)
> +{
> +	struct Qdisc_class_common *cl;
> +	struct hlist_node *n, *next;
> +	struct hlist_head *nhash, *ohash;
> +	unsigned int nsize, nmask, osize;
> +	unsigned int i, h;
> +
> +	/* Rehash when load factor exceeds 0.75 */
> +	if (clhash->hashelems * 4 <= clhash->hashsize * 3)

With current init hashsize == 4 this will trigger after adding: 4th,
7th, 13th,... class. Maybe we could start with something higher?

> +		return;
> +	nsize = clhash->hashsize * 2;
> +	nmask = nsize - 1;
> +	nhash = qdisc_class_hash_alloc(nsize);
> +	if (nhash == NULL)
> +		return;
> +
> +	ohash = clhash->hash;
> +	osize = clhash->hashsize;
> +
> +	sch_tree_lock(sch);
> +	for (i = 0; i < osize; i++) {
> +		hlist_for_each_entry_safe(cl, n, next, &ohash[i], hnode) {
> +			h = qdisc_class_hash(cl->classid, nmask);
> +			hlist_add_head(&cl->hnode, &nhash[h]);

With a large number of classes and changes this could probably give
noticable delays, so maybe there would be reasonable to add a
possibility of user defined, ungrowable hashsize as well?

Otherwise, it looks very nice to me.

Thanks,
Jarek P.

> +		}
> +	}
> +	clhash->hash     = nhash;
> +	clhash->hashsize = nsize;
> +	clhash->hashmask = nmask;
> +	sch_tree_unlock(sch);
> +
> +	qdisc_class_hash_free(ohash, osize);
> +}
> +EXPORT_SYMBOL(qdisc_class_hash_grow);
> +
> +int qdisc_class_hash_init(struct Qdisc_class_hash *clhash)
> +{
> +	unsigned int size = 4;
> +
> +	clhash->hash = qdisc_class_hash_alloc(size);
> +	if (clhash->hash == NULL)
> +		return -ENOMEM;
> +	clhash->hashsize  = size;
> +	clhash->hashmask  = size - 1;
> +	clhash->hashelems = 0;
> +	return 0;
> +}
> +EXPORT_SYMBOL(qdisc_class_hash_init);
> +
> +void qdisc_class_hash_destroy(struct Qdisc_class_hash *clhash)
> +{
> +	qdisc_class_hash_free(clhash->hash, clhash->hashsize);
> +}
> +EXPORT_SYMBOL(qdisc_class_hash_destroy);
> +
> +void qdisc_class_hash_insert(struct Qdisc_class_hash *clhash,
> +			     struct Qdisc_class_common *cl)
> +{
> +	unsigned int h;
> +
> +	INIT_HLIST_NODE(&cl->hnode);
> +	h = qdisc_class_hash(cl->classid, clhash->hashmask);
> +	hlist_add_head(&cl->hnode, &clhash->hash[h]);
> +	clhash->hashelems++;
> +}
> +EXPORT_SYMBOL(qdisc_class_hash_insert);
> +
> +void qdisc_class_hash_remove(struct Qdisc_class_hash *clhash,
> +			     struct Qdisc_class_common *cl)
> +{
> +	hlist_del(&cl->hnode);
> +	clhash->hashelems--;
> +}
> +EXPORT_SYMBOL(qdisc_class_hash_remove);
> +
>  /* Allocate an unique handle from space managed by kernel */
>  
>  static u32 qdisc_alloc_handle(struct net_device *dev)
