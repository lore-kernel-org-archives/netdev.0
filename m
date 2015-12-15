From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 4/6] bpf: hash: convert per-hashtable lock into
 per-bucket bit spinlock
Date: Tue, 15 Dec 2015 14:51:19 -0800
Message-ID: <20151215225118.GA67370@ast-mbp.thefacebook.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
 <1450178464-27721-5-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450178464-27721-5-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 07:21:02PM +0800, Ming Lei wrote:
> Both htab_map_update_elem() and htab_map_delete_elem() can be
> called from eBPF program, and they may be in kernel hot path,
> so it isn't efficient to use a per-hashtable lock in this two
> helpers.
> 
> The per-hashtable spinlock is used just for protecting bucket's
> hlist, and per-bucket lock should be enough. This patch converts
> the per-hashtable lock into per-bucket bit spinlock, so that
> contention can be decreased a lot, and no extra memory can be
> consumed for these locks.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

thank you for working on this.
Interesting stuff!

>  	/* bpf_map_update_elem() can be called in_irq() */
> -	raw_spin_lock_irqsave(&htab->lock, flags);
> +	raw_local_irq_save(flags);
> +	bit_spin_lock(HLIST_LOCK_BIT, (unsigned long *)&head->first);

can you add a helper for bit_spin_lock/unlock as well so that whole hlist+bit
api looks consistent?

>  
> -	l_old = lookup_elem_raw(head, l_new->hash, key, key_size);
> +	l_old = lookup_elem_raw(hlist_get_head_lock(head, &h), l_new->hash,
> +			key, key_size);
>  
>  	if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
>  		/* if elem with this 'key' doesn't exist and we've reached
> @@ -278,18 +284,20 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
>  	/* add new element to the head of the list, so that concurrent
>  	 * search will find it before old elem
>  	 */
> -	hlist_add_head_rcu(&l_new->hash_node, head);
> +	hlist_add_head_rcu_lock(&l_new->hash_node, head);

I think the new macros have confusing names:

+#define hlist_get_first(h)     \
+       (struct hlist_node *)((unsigned long)(h)->first & ~HLIST_LOCK_MASK)
+#define hlist_get_lock(h)    ((unsigned long)(h)->first & HLIST_LOCK_MASK)
+#define hlist_make_1st_node(h, n) \
+       (struct hlist_node *)((unsigned long)(n) | hlist_get_lock(h))
+
+static inline struct hlist_head *hlist_get_head_lock(
+               struct hlist_head *head, struct hlist_head *new_head)
+{
+       new_head->first = hlist_get_first(head);
+       return new_head;
+}

This new hlist_add_head_rcu_lock() adds new element and it doesn't take new lock.
May be rename this new api as 'locked_hlist' ?
Then all normal helpers will convert like:
hlist_add_head_rcu() -> locked_hlist_add_head_rcu()

>  	if (l_old) {
> -		hlist_del_rcu(&l_old->hash_node);
> +		hlist_del_rcu_lock(&l_old->hash_node);

and here it will be:
hlist_del_rcu() -> locked_hlist_del_rcu()

Also is there a race here ?
+static inline void hlist_add_head_rcu_lock(struct hlist_node *n,
+                                          struct hlist_head *h)
+{
+       struct hlist_node *first = hlist_get_first(h);
+
+       n->next = first;
+       n->pprev = &h->first;
+       rcu_assign_pointer(hlist_first_rcu(h), hlist_make_1st_node(h, n));
+       if (first)
+               first->pprev = &n->next;
+}

Do you need cmpxchg when updatding hlist_head->first ?

Overall looks like a very interesting idea, but I'm not sure about
trade-off of saving 8 bytes for rounded-up spinlock per bucket.
The loss of lockdep is concerning.
Have you compared performance of this bit-lock embedded inside hlist_head vs
just adding spinlock_t for every hlist_head?
Another concern is that hlist walking may be more costly due to
requirement of having to clear that bit while doing the walk in lookup().
I guess I would prefer normal spinlock per bucket. Additional 8 * n_buckets bytes
don't seem to be worth optimizing.
