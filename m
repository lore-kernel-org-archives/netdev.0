From: Chris Mi <chrism@mellanox.com>
Subject: RE: Extended IDR API
Date: Tue, 12 Sep 2017 02:27:18 +0000
Message-ID: <VI1PR0501MB214337A02E74A449149F5CEDAB690@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <20170911211408.GA26747@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Rehas Sachdeva <aquannie@gmail.com>
To: Matthew Wilcox <willy@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0072.outbound.protection.outlook.com ([104.47.2.72]:18080
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751022AbdILC1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 22:27:24 -0400
In-Reply-To: <20170911211408.GA26747@bombadil.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improvement is good.  But I have a concern that
the parameters of idr_alloc and idr_alloc_ul are different.
I mean in idr_alloc, we have start and end.
In our new API, we keep them. So our design goal is to
make them consistent.  Your new API has its advantage surely.
If you want to change it, I don't object personally.
=20
> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@infradead.org]
> Sent: Tuesday, September 12, 2017 5:14 AM
> To: Chris Mi <chrism@mellanox.com>
> Cc: Jiri Pirko <jiri@mellanox.com>; David S. Miller <davem@davemloft.net>=
;
> Tejun Heo <tj@kernel.org>; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; Rehas Sachdeva <aquannie@gmail.com>
> Subject: Extended IDR API
>=20
>=20
> I really don't like your new API.  I wish you'd discussed it before mergi=
ng it.
> Here's my redesign.  Does anybody have a suggestion for improvement?
>=20
> We have a lovely new test-suite for the IDR (in tools/testing/radix-tree)=
 ...
> when adding a new API, it's polite to update the test-suite too.
> Do you have any plans to add test cases?
OK, we will add it once these APIs are stabilized.

Thanks,
Chris
>=20
> (Compile tested only; I'm at a conference.  Also, I didn't check the kern=
eldoc
> because I don't have Sphinx installed on my laptop.)
>=20
> From ff45b2a6806cd0e4177c5a10f26c97999164c10c Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Mon, 11 Sep 2017 16:16:29 -0400
> Subject: [PATCH] idr: Rewrite extended IDR API
>=20
>  - Rename the API to be 'ul' for unsigned long instead of 'ext'.  This
>    fits better with other usage in the Linux kernel.
>  - idr_alloc() moves back to being a function instead of inline
>  - idr_alloc_ul() takes 'nextid' as an in-out parameter like idr_get_next=
(),
>    instead of having 'index' as an out-only parameter.
>  - idr_alloc_ul() needs a __must_check to ensure that users don't look at
>    the result without checking whether the function succeeded.
>  - idr_alloc_ul() takes 'max' rather than 'end', or it is impossible to
>    allocate the ULONG_MAX id.
>  - idr_replace() can simply take an unsigned long parameter instead of
>    an int.
>  - idr_remove() and idr_find() are the same as idr_replace().
>  - We don't need separate idr_get_free() and idr_get_free_ext().
>  - Add kerneldoc for idr_alloc_ul().
>=20
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/idr.h        | 75 +++++----------------------------------
>  include/linux/radix-tree.h | 17 +--------
>  lib/idr.c                  | 88 +++++++++++++++++++++++++++++++++-------=
------
>  lib/radix-tree.c           |  2 +-
>  net/sched/act_api.c        | 22 ++++++------
>  net/sched/cls_flower.c     | 16 +++++----
>  6 files changed, 95 insertions(+), 125 deletions(-)
>=20
> diff --git a/include/linux/idr.h b/include/linux/idr.h index
> 7c3a365f7e12..90faf8279559 100644
> --- a/include/linux/idr.h
> +++ b/include/linux/idr.h
> @@ -81,74 +81,22 @@ static inline void idr_set_cursor(struct idr *idr,
> unsigned int val)
>=20
>  void idr_preload(gfp_t gfp_mask);
>=20
> -int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
> -		  unsigned long start, unsigned long end, gfp_t gfp,
> -		  bool ext);
> -
> -/**
> - * idr_alloc - allocate an id
> - * @idr: idr handle
> - * @ptr: pointer to be associated with the new id
> - * @start: the minimum id (inclusive)
> - * @end: the maximum id (exclusive)
> - * @gfp: memory allocation flags
> - *
> - * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
> - * if there are no unused IDs in that range.
> - *
> - * Note that @end is treated as max when <=3D 0.  This is to always allo=
w
> - * using @start + N as @end as long as N is inside integer range.
> - *
> - * Simultaneous modifications to the @idr are not allowed and should be
> - * prevented by the user, usually with a lock.  idr_alloc() may be calle=
d
> - * concurrently with read-only accesses to the @idr, such as idr_find() =
and
> - * idr_for_each_entry().
> - */
> -static inline int idr_alloc(struct idr *idr, void *ptr,
> -			    int start, int end, gfp_t gfp)
> -{
> -	unsigned long id;
> -	int ret;
> -
> -	if (WARN_ON_ONCE(start < 0))
> -		return -EINVAL;
> -
> -	ret =3D idr_alloc_cmn(idr, ptr, &id, start, end, gfp, false);
> -
> -	if (ret)
> -		return ret;
> -
> -	return id;
> -}
> -
> -static inline int idr_alloc_ext(struct idr *idr, void *ptr,
> -				unsigned long *index,
> -				unsigned long start,
> -				unsigned long end,
> -				gfp_t gfp)
> -{
> -	return idr_alloc_cmn(idr, ptr, index, start, end, gfp, true);
> -}
> -
> +int idr_alloc(struct idr *, void *, int start, int end, gfp_t); int
> +__must_check idr_alloc_ul(struct idr *, void *, unsigned long *nextid,
> +			unsigned long max, gfp_t);
>  int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_=
t);  int
> idr_for_each(const struct idr *,
>  		 int (*fn)(int id, void *p, void *data), void *data);  void
> *idr_get_next(struct idr *, int *nextid); -void *idr_get_next_ext(struct =
idr
> *idr, unsigned long *nextid); -void *idr_replace(struct idr *, void *, in=
t id); -
> void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
> +void *idr_get_next_ul(struct idr *, unsigned long *nextid); void
> +*idr_replace(struct idr *, void *, unsigned long id);
>  void idr_destroy(struct idr *);
>=20
> -static inline void *idr_remove_ext(struct idr *idr, unsigned long id)
> +static inline void *idr_remove(struct idr *idr, unsigned long id)
>  {
>  	return radix_tree_delete_item(&idr->idr_rt, id, NULL);  }
>=20
> -static inline void *idr_remove(struct idr *idr, int id) -{
> -	return idr_remove_ext(idr, id);
> -}
> -
>  static inline void idr_init(struct idr *idr)  {
>  	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER); @@ -184,16
> +132,11 @@ static inline void idr_preload_end(void)
>   * This function can be called under rcu_read_lock(), given that the lea=
f
>   * pointers lifetimes are correctly managed.
>   */
> -static inline void *idr_find_ext(const struct idr *idr, unsigned long id=
)
> +static inline void *idr_find(const struct idr *idr, unsigned long id)
>  {
>  	return radix_tree_lookup(&idr->idr_rt, id);  }
>=20
> -static inline void *idr_find(const struct idr *idr, int id) -{
> -	return idr_find_ext(idr, id);
> -}
> -
>  /**
>   * idr_for_each_entry - iterate over an idr's elements of a given type
>   * @idr:     idr handle
> @@ -206,8 +149,8 @@ static inline void *idr_find(const struct idr *idr, i=
nt id)
>   */
>  #define idr_for_each_entry(idr, entry, id)			\
>  	for (id =3D 0; ((entry) =3D idr_get_next(idr, &(id))) !=3D NULL; ++id)
> -#define idr_for_each_entry_ext(idr, entry, id)			\
> -	for (id =3D 0; ((entry) =3D idr_get_next_ext(idr, &(id))) !=3D NULL; ++=
id)
> +#define idr_for_each_entry_ul(idr, entry, id)			\
> +	for (id =3D 0; ((entry) =3D idr_get_next_ul(idr, &(id))) !=3D NULL; ++i=
d)
>=20
>  /**
>   * idr_for_each_entry_continue - continue iteration over an idr's elemen=
ts
> of a given type diff --git a/include/linux/radix-tree.h b/include/linux/r=
adix-
> tree.h index 567ebb5eaab0..8275fc2ed0f4 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -358,24 +358,9 @@ int radix_tree_split(struct radix_tree_root *,
> unsigned long index,  int radix_tree_join(struct radix_tree_root *, unsig=
ned
> long index,
>  			unsigned new_order, void *);
>=20
> -void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
> +void __rcu **idr_get_free(struct radix_tree_root *root,
>  			      struct radix_tree_iter *iter, gfp_t gfp,
>  			      unsigned long max);
> -static inline void __rcu **idr_get_free(struct radix_tree_root *root,
> -					struct radix_tree_iter *iter,
> -					gfp_t gfp,
> -					int end)
> -{
> -	return idr_get_free_cmn(root, iter, gfp, end > 0 ? end - 1 : INT_MAX);
> -}
> -
> -static inline void __rcu **idr_get_free_ext(struct radix_tree_root *root=
,
> -					    struct radix_tree_iter *iter,
> -					    gfp_t gfp,
> -					    unsigned long end)
> -{
> -	return idr_get_free_cmn(root, iter, gfp, end - 1);
> -}
>=20
>  enum {
>  	RADIX_TREE_ITER_TAG_MASK =3D 0x0f,	/* tag index in lower nybble
> */
> diff --git a/lib/idr.c b/lib/idr.c
> index 082778cf883e..230879a65d99 100644
> --- a/lib/idr.c
> +++ b/lib/idr.c
> @@ -7,9 +7,26 @@
>  DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);  static
> DEFINE_SPINLOCK(simple_ida_lock);
>=20
> -int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
> -		  unsigned long start, unsigned long end, gfp_t gfp,
> -		  bool ext)
> +/**
> + * idr_alloc_ul - allocate a large ID
> + * @idr: idr handle
> + * @ptr: pointer to be associated with the new ID
> + * @nextid: Pointer to minimum ID to allocate
> + * @max: the maximum ID (inclusive)
> + * @gfp: memory allocation flags
> + *
> + * Allocates an unused ID in the range [*nextid, end] and stores it in
> + * @nextid.  Note that @max differs from the @end parameter to
> idr_alloc().
> + *
> + * Simultaneous modifications to the @idr are not allowed and should be
> + * prevented by the user, usually with a lock.  idr_alloc_ul() may be
> +called
> + * concurrently with read-only accesses to the @idr, such as idr_find()
> +and
> + * idr_for_each_entry().
> + *
> + * Return: 0 on success or a negative errno on failure (ENOMEM or
> +ENOSPC)  */ int idr_alloc_ul(struct idr *idr, void *ptr, unsigned long
> +*nextid,
> +			unsigned long max, gfp_t gfp)
>  {
>  	struct radix_tree_iter iter;
>  	void __rcu **slot;
> @@ -17,22 +34,54 @@ int idr_alloc_cmn(struct idr *idr, void *ptr, unsigne=
d
> long *index,
>  	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
>  		return -EINVAL;
>=20
> -	radix_tree_iter_init(&iter, start);
> -	if (ext)
> -		slot =3D idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
> -	else
> -		slot =3D idr_get_free(&idr->idr_rt, &iter, gfp, end);
> +	radix_tree_iter_init(&iter, *nextid);
> +	slot =3D idr_get_free(&idr->idr_rt, &iter, gfp, max);
>  	if (IS_ERR(slot))
>  		return PTR_ERR(slot);
>=20
>  	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
>  	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
>=20
> -	if (index)
> -		*index =3D iter.index;
> +	*nextid =3D iter.index;
>  	return 0;
>  }
> -EXPORT_SYMBOL_GPL(idr_alloc_cmn);
> +EXPORT_SYMBOL_GPL(idr_alloc_ul);
> +
> +/**
> + * idr_alloc - allocate an id
> + * @idr: idr handle
> + * @ptr: pointer to be associated with the new id
> + * @start: the minimum id (inclusive)
> + * @end: the maximum id (exclusive)
> + * @gfp: memory allocation flags
> + *
> + * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
> + * if there are no unused IDs in that range.
> + *
> + * Note that @end is treated as max when <=3D 0.  This is to always allo=
w
> + * using @start + N as @end as long as N is inside integer range.
> + *
> + * Simultaneous modifications to the @idr are not allowed and should be
> + * prevented by the user, usually with a lock.  idr_alloc() may be
> +called
> + * concurrently with read-only accesses to the @idr, such as idr_find()
> +and
> + * idr_for_each_entry().
> + */
> +int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t
> +gfp) {
> +	unsigned long id =3D start;
> +	int ret;
> +
> +	if (WARN_ON_ONCE(start < 0))
> +		return -EINVAL;
> +
> +	ret =3D idr_alloc_ul(idr, ptr, &id, end > 0 ? end - 1 : INT_MAX, gfp);
> +
> +	if (ret)
> +		return ret;
> +
> +	return id;
> +}
> +EXPORT_SYMBOL_GPL(idr_alloc);
>=20
>  /**
>   * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion @@ -1=
21,7
> +170,7 @@ void *idr_get_next(struct idr *idr, int *nextid)  }
> EXPORT_SYMBOL(idr_get_next);
>=20
> -void *idr_get_next_ext(struct idr *idr, unsigned long *nextid)
> +void *idr_get_next_ul(struct idr *idr, unsigned long *nextid)
>  {
>  	struct radix_tree_iter iter;
>  	void __rcu **slot;
> @@ -133,7 +182,7 @@ void *idr_get_next_ext(struct idr *idr, unsigned long
> *nextid)
>  	*nextid =3D iter.index;
>  	return rcu_dereference_raw(*slot);
>  }
> -EXPORT_SYMBOL(idr_get_next_ext);
> +EXPORT_SYMBOL(idr_get_next_ul);
>=20
>  /**
>   * idr_replace - replace pointer for given id @@ -149,16 +198,7 @@
> EXPORT_SYMBOL(idr_get_next_ext);
>   * Returns: 0 on success.  %-ENOENT indicates that @id was not found.
>   * %-EINVAL indicates that @id or @ptr were not valid.
>   */
> -void *idr_replace(struct idr *idr, void *ptr, int id) -{
> -	if (WARN_ON_ONCE(id < 0))
> -		return ERR_PTR(-EINVAL);
> -
> -	return idr_replace_ext(idr, ptr, id);
> -}
> -EXPORT_SYMBOL(idr_replace);
> -
> -void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
> +void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
>  {
>  	struct radix_tree_node *node;
>  	void __rcu **slot =3D NULL;
> @@ -175,7 +215,7 @@ void *idr_replace_ext(struct idr *idr, void *ptr,
> unsigned long id)
>=20
>  	return entry;
>  }
> -EXPORT_SYMBOL(idr_replace_ext);
> +EXPORT_SYMBOL(idr_replace);
>=20
>  /**
>   * DOC: IDA description
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c index
> 8b1feca1230a..9fcd4e5c5237 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -2139,7 +2139,7 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)  }
> EXPORT_SYMBOL(ida_pre_get);
>=20
> -void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
> +void __rcu **idr_get_free(struct radix_tree_root *root,
>  			      struct radix_tree_iter *iter, gfp_t gfp,
>  			      unsigned long max)
>  {
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c index
> a306974e2fb4..131817ab3ad3 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -73,7 +73,7 @@ static void free_tcf(struct rcu_head *head)  static voi=
d
> tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)  {
>  	spin_lock_bh(&idrinfo->lock);
> -	idr_remove_ext(&idrinfo->action_idr, p->tcfa_index);
> +	idr_remove(&idrinfo->action_idr, p->tcfa_index);
>  	spin_unlock_bh(&idrinfo->lock);
>  	gen_kill_estimator(&p->tcfa_rate_est);
>  	/*
> @@ -121,7 +121,7 @@ static int tcf_dump_walker(struct tcf_idrinfo *idrinf=
o,
> struct sk_buff *skb,
>=20
>  	s_i =3D cb->args[0];
>=20
> -	idr_for_each_entry_ext(idr, p, id) {
> +	idr_for_each_entry_ul(idr, p, id) {
>  		index++;
>  		if (index < s_i)
>  			continue;
> @@ -178,7 +178,7 @@ static int tcf_del_walker(struct tcf_idrinfo *idrinfo=
,
> struct sk_buff *skb,
>  	if (nla_put_string(skb, TCA_KIND, ops->kind))
>  		goto nla_put_failure;
>=20
> -	idr_for_each_entry_ext(idr, p, id) {
> +	idr_for_each_entry_ul(idr, p, id) {
>  		ret =3D __tcf_idr_release(p, false, true);
>  		if (ret =3D=3D ACT_P_DELETED) {
>  			module_put(p->ops->owner);
> @@ -216,10 +216,10 @@ EXPORT_SYMBOL(tcf_generic_walker);
>=20
>  static struct tc_action *tcf_idr_lookup(u32 index, struct tcf_idrinfo *i=
drinfo)
> {
> -	struct tc_action *p =3D NULL;
> +	struct tc_action *p;
>=20
>  	spin_lock_bh(&idrinfo->lock);
> -	p =3D idr_find_ext(&idrinfo->action_idr, index);
> +	p =3D idr_find(&idrinfo->action_idr, index);
>  	spin_unlock_bh(&idrinfo->lock);
>=20
>  	return p;
> @@ -296,10 +296,10 @@ int tcf_idr_create(struct tc_action_net *tn, u32
> index, struct nlattr *est,
>  	spin_lock_init(&p->tcfa_lock);
>  	/* user doesn't specify an index */
>  	if (!index) {
> +		idr_index =3D 1;
>  		idr_preload(GFP_KERNEL);
>  		spin_lock_bh(&idrinfo->lock);
> -		err =3D idr_alloc_ext(idr, NULL, &idr_index, 1, 0,
> -				    GFP_ATOMIC);
> +		err =3D idr_alloc_ul(idr, NULL, &idr_index, UINT_MAX,
> GFP_ATOMIC);
>  		spin_unlock_bh(&idrinfo->lock);
>  		idr_preload_end();
>  		if (err) {
> @@ -309,10 +309,10 @@ int tcf_idr_create(struct tc_action_net *tn, u32
> index, struct nlattr *est,
>  		}
>  		p->tcfa_index =3D idr_index;
>  	} else {
> +		idr_index =3D index;
>  		idr_preload(GFP_KERNEL);
>  		spin_lock_bh(&idrinfo->lock);
> -		err =3D idr_alloc_ext(idr, NULL, NULL, index, index + 1,
> -				    GFP_ATOMIC);
> +		err =3D idr_alloc_ul(idr, NULL, &idr_index, index, GFP_ATOMIC);
>  		spin_unlock_bh(&idrinfo->lock);
>  		idr_preload_end();
>  		if (err)
> @@ -345,7 +345,7 @@ void tcf_idr_insert(struct tc_action_net *tn, struct
> tc_action *a)
>  	struct tcf_idrinfo *idrinfo =3D tn->idrinfo;
>=20
>  	spin_lock_bh(&idrinfo->lock);
> -	idr_replace_ext(&idrinfo->action_idr, a, a->tcfa_index);
> +	idr_replace(&idrinfo->action_idr, a, a->tcfa_index);
>  	spin_unlock_bh(&idrinfo->lock);
>  }
>  EXPORT_SYMBOL(tcf_idr_insert);
> @@ -358,7 +358,7 @@ void tcf_idrinfo_destroy(const struct tc_action_ops
> *ops,
>  	int ret;
>  	unsigned long id =3D 1;
>=20
> -	idr_for_each_entry_ext(idr, p, id) {
> +	idr_for_each_entry_ul(idr, p, id) {
>  		ret =3D __tcf_idr_release(p, false, true);
>  		if (ret =3D=3D ACT_P_DELETED)
>  			module_put(ops->owner);
> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c index
> 1a267e77c6de..ad30968f587d 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c
> @@ -298,7 +298,7 @@ static void __fl_delete(struct tcf_proto *tp, struct
> cls_fl_filter *f)  {
>  	struct cls_fl_head *head =3D rtnl_dereference(tp->root);
>=20
> -	idr_remove_ext(&head->handle_idr, f->handle);
> +	idr_remove(&head->handle_idr, f->handle);
>  	list_del_rcu(&f->list);
>  	if (!tc_skip_hw(f->flags))
>  		fl_hw_destroy_filter(tp, f);
> @@ -341,7 +341,7 @@ static void *fl_get(struct tcf_proto *tp, u32 handle)=
  {
>  	struct cls_fl_head *head =3D rtnl_dereference(tp->root);
>=20
> -	return idr_find_ext(&head->handle_idr, handle);
> +	return idr_find(&head->handle_idr, handle);
>  }
>=20
>  static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] =3D { @@ -9=
01,8
> +901,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  		goto errout;
>=20
>  	if (!handle) {
> -		err =3D idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> -				    1, 0x80000000, GFP_KERNEL);
> +		idr_index =3D 1;
> +		err =3D idr_alloc_ul(&head->handle_idr, fnew, &idr_index,
> +				    INT_MAX, GFP_KERNEL);
>  		if (err)
>  			goto errout;
>  		fnew->handle =3D idr_index;
> @@ -910,8 +911,9 @@ static int fl_change(struct net *net, struct sk_buff
> *in_skb,
>=20
>  	/* user specifies a handle and it doesn't exist */
>  	if (handle && !fold) {
> -		err =3D idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> -				    handle, handle + 1, GFP_KERNEL);
> +		idr_index =3D handle;
> +		err =3D idr_alloc_ul(&head->handle_idr, fnew, &idr_index,
> +				    handle, GFP_KERNEL);
>  		if (err)
>  			goto errout;
>  		fnew->handle =3D idr_index;
> @@ -970,7 +972,7 @@ static int fl_change(struct net *net, struct sk_buff
> *in_skb,
>=20
>  	if (fold) {
>  		fnew->handle =3D handle;
> -		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
> +		idr_replace(&head->handle_idr, fnew, fnew->handle);
>  		list_replace_rcu(&fold->list, &fnew->list);
>  		tcf_unbind_filter(tp, &fold->res);
>  		call_rcu(&fold->rcu, fl_destroy_filter);
> --
> 2.14.1
>=20
