From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 2/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Sat, 9 Jan 2016 18:06:15 +0800
Message-ID: <CACVXFVNg_3j0T8WCmtVR8XEb9xRd0qJBEZcsW3_OJ+HYZHNvEg@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
	<1452206155-1492617-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:35192 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbcAIKGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 05:06:16 -0500
In-Reply-To: <1452206155-1492617-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This patch adds BPFMAP_TYPE_PERCPU_HASH map type and its
> htab_map_ops implementation.
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  include/uapi/linux/bpf.h |   1 +
>  kernel/bpf/hashtab.c     | 201 ++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 201 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 8bed7f1..e4f8060 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -81,6 +81,7 @@ enum bpf_map_type {
>         BPF_MAP_TYPE_ARRAY,
>         BPF_MAP_TYPE_PROG_ARRAY,
>         BPF_MAP_TYPE_PERF_EVENT_ARRAY,
> +       BPF_MAP_TYPE_PERCPU_HASH,
>  };
>
>  enum bpf_prog_type {
> diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> index d55df8c..63f2945 100644
> --- a/kernel/bpf/hashtab.c
> +++ b/kernel/bpf/hashtab.c
> @@ -278,7 +278,7 @@ find_first_elem:
>  }
>
>  static struct htab_elem_common *htab_elem_common_alloc(struct bpf_htab *htab,
> -                                                       void *key)
> +                                                      void *key)

better to not introduce the above change.

>  {
>         struct htab_elem_common *l;
>
> @@ -451,9 +451,208 @@ static struct bpf_map_type_list htab_type __read_mostly = {
>         .type = BPF_MAP_TYPE_HASH,
>  };
>
> +/* each htab_percpu_elem is struct htab_percpu_elem + key  */
> +struct htab_percpu_elem {
> +       struct htab_elem_common common;
> +       void * __percpu value;
> +       char key[0] __aligned(8);
> +};
> +
> +static struct htab_percpu_elem *htab_percpu_elem(struct htab_elem_common *l)
> +{
> +       return (struct htab_percpu_elem *)l;
> +}
> +
> +static void htab_percpu_elem_free(struct htab_percpu_elem *l)
> +{
> +       free_percpu(l->value);
> +       kfree(l);
> +}
> +
> +static void htab_percpu_elem_rcu_free(struct rcu_head *head)
> +{
> +       struct htab_elem_common *l = container_of(head,
> +                                                 struct htab_elem_common,
> +                                                 rcu);
> +
> +       htab_percpu_elem_free(htab_percpu_elem(l));
> +}
> +
> +static void htab_percpu_map_flush(struct bpf_htab *htab)
> +{
> +       int i;
> +
> +       for (i = 0; i < htab->n_buckets; i++) {
> +               struct hlist_head *head = select_bucket(htab, i);
> +               struct hlist_node *n;
> +               struct htab_elem_common *l;
> +
> +               hlist_for_each_entry_safe(l, n, head, hash_node) {
> +                       hlist_del_rcu(&l->hash_node);
> +                       atomic_dec(&htab->count);
> +                       htab_percpu_elem_free(htab_percpu_elem(l));
> +               }
> +       }
> +}

The above helper should have been saved by introduce percpu_map
flag in bpf_htab.

> +
> +/* Called from syscall */
> +static struct bpf_map *htab_percpu_map_alloc(union bpf_attr *attr)
> +{
> +       u32 elem_size = sizeof(struct htab_percpu_elem) +
> +               round_up(attr->key_size, 8);
> +       u32 elem_value_size = elem_size +
> +               num_possible_cpus() * attr->value_size;
> +
> +       return __htab_map_alloc(attr, elem_size, elem_value_size,
> +                               offsetof(struct htab_percpu_elem, key),
> +                               htab_percpu_map_flush);
> +}
> +
> +/* Called from syscall or from eBPF program */
> +static int htab_percpu_map_delete_elem(struct bpf_map *map, void *key)
> +{
> +       struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
> +       struct htab_elem_common *l;
> +       struct hlist_head *head;
> +       unsigned long flags;
> +       u32 hash, key_size;
> +       struct bucket *b;
> +       int ret = -ENOENT;
> +
> +       WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +       key_size = map->key_size;
> +
> +       hash = htab_map_hash(key, key_size);
> +       b = __select_bucket(htab, hash);
> +       head = &b->head;
> +
> +       raw_spin_lock_irqsave(&b->lock, flags);
> +
> +       l = lookup_elem_raw(htab, head, hash, key);
> +
> +       if (l) {
> +               hlist_del_rcu(&l->hash_node);
> +               atomic_dec(&htab->count);
> +               call_rcu(&l->rcu, htab_percpu_elem_rcu_free);
> +               ret = 0;
> +       }
> +
> +       raw_spin_unlock_irqrestore(&b->lock, flags);
> +       return ret;
> +}
> +
> +/* Called from syscall or eBPF program */
> +static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
> +{
> +       struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
> +       struct htab_elem_common *l;
> +
> +       l = __htab_map_lookup_elem(htab, key);
> +       if (l) {
> +               void *value = per_cpu_ptr(htab_percpu_elem(l)->value,
> +                                         smp_processor_id());
> +               return value;
> +       }
> +
> +       return NULL;
> +
> +}
> +
> +/* Called from syscall or from eBPF program */
> +static int htab_percpu_map_update_elem(struct bpf_map *map, void *key,
> +                                      void *value, u64 map_flags)
> +{
> +       struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
> +       struct htab_percpu_elem *l_new, *l_old;
> +       struct hlist_head *head;
> +       struct bucket *b;
> +       unsigned long flags;
> +       int ret;
> +
> +       if (map_flags > BPF_EXIST)
> +               /* unknown flags */
> +               return -EINVAL;
> +
> +       WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +       /* allocate new element outside of lock */
> +       l_new = htab_percpu_elem(htab_elem_common_alloc(htab, key));
> +       if (!l_new)
> +               return -ENOMEM;
> +
> +       l_new->value = __alloc_percpu_gfp(htab->map.value_size, 8,
> +                                         GFP_ATOMIC | __GFP_NOWARN);

Looks not good to introduce another memory allocation in eBPF prog,
it is a bit heavy to run, and it is in my TODO list to remove allocation of
htab_elem in eBPF prog.

> +       if (!l_new->value) {
> +               htab_percpu_elem_free(l_new);
> +               return -ENOMEM;
> +       }
> +
> +       memcpy(raw_cpu_ptr(l_new->value), value, map->value_size);
> +
> +       b = __select_bucket(htab, l_new->common.hash);
> +       head = &b->head;
> +
> +       /* bpf_map_update_elem() can be called in_irq() */
> +       raw_spin_lock_irqsave(&b->lock, flags);
> +
> +       l_old = htab_percpu_elem(lookup_elem_raw(htab, head, l_new->common.hash,
> +                                                key));
> +
> +       if (!l_old && unlikely(atomic_read(&htab->count) >= map->max_entries)) {
> +               /* if elem with this 'key' doesn't exist and we've reached
> +                * max_entries limit, fail insertion of new elem
> +                */
> +               ret = -E2BIG;
> +               goto err;
> +       }
> +
> +       if (l_old && map_flags == BPF_NOEXIST) {
> +               /* elem already exists */
> +               ret = -EEXIST;
> +               goto err;
> +       }
> +
> +       if (!l_old && map_flags == BPF_EXIST) {
> +               /* elem doesn't exist, cannot update it */
> +               ret = -ENOENT;
> +               goto err;
> +       }
> +
> +       if (l_old) {
> +               memcpy(this_cpu_ptr(l_old->value), value, map->value_size);
> +       } else {
> +               hlist_add_head_rcu(&l_new->common.hash_node, head);
> +               atomic_inc(&htab->count);
> +       }
> +
> +       raw_spin_unlock_irqrestore(&b->lock, flags);
> +
> +       return 0;
> +err:
> +       raw_spin_unlock_irqrestore(&b->lock, flags);
> +       htab_percpu_elem_free(l_new);
> +       return ret;
> +}

It isn't good to introduce so much code duplication.

> +
> +static const struct bpf_map_ops htab_percpu_ops = {
> +       .map_alloc = htab_percpu_map_alloc,
> +       .map_free = htab_map_free,
> +       .map_get_next_key = htab_map_get_next_key,
> +       .map_lookup_elem = htab_percpu_map_lookup_elem,
> +       .map_update_elem = htab_percpu_map_update_elem,
> +       .map_delete_elem = htab_percpu_map_delete_elem,
> +};
> +
> +static struct bpf_map_type_list htab_percpu_type __read_mostly = {
> +       .ops = &htab_percpu_ops,
> +       .type = BPF_MAP_TYPE_PERCPU_HASH,
> +};
> +
>  static int __init register_htab_map(void)
>  {
>         bpf_register_map_type(&htab_type);
> +       bpf_register_map_type(&htab_percpu_type);
>         return 0;
>  }
>  late_initcall(register_htab_map);
> --
> 2.5.1
>



-- 
Ming Lei
