From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 05/16] bpf: introduce syscall(BPF, ...)
 and BPF maps
Date: Wed, 23 Jul 2014 11:02:16 -0700
Message-ID: <CAGXu5jJAOyA=UB-k4fmu84RTB_ygHAs2UqtbBfUPs2JCaxo0Eg@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-6-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405657206-12060-6-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 9:19 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> BPF syscall is a demux for different BPF releated commands.
>
> 'maps' is a generic storage of different types for sharing data between kernel
> and userspace.
>
> The maps can be created from user space via BPF syscall:
> - create a map with given type and attributes
>   fd = bpf_map_create(map_type, struct nlattr *attr, int len)
>   returns fd or negative error
>
> - close(fd) deletes the map
>
> Next patch allows userspace programs to populate/read maps that eBPF programs
> are concurrently updating.
>
> maps can have different types: hash, bloom filter, radix-tree, etc.
>
> The map is defined by:
>   . type
>   . max number of elements
>   . key size in bytes
>   . value size in bytes
>
> Next patches allow eBPF programs to access maps via API:
>   void * bpf_map_lookup_elem(u32 fd, void *key);
>   int bpf_map_update_elem(u32 fd, void *key, void *value);
>   int bpf_map_delete_elem(u32 fd, void *key);
>
> This patch establishes core infrastructure for BPF maps.
> Next patches implement lookup/update and hashtable type.
> More map types can be added in the future.
>
> syscall is using type-length-value style of passing arguments to be backwards
> compatible with future extensions to map attributes. Different map types may
> use different attributes as well.
> The concept of type-lenght-value is borrowed from netlink, but netlink itself
> is not applicable here, since BPF programs and maps can be used in NET-less
> configurations.
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>  Documentation/networking/filter.txt |   69 +++++++++++
>  include/linux/bpf.h                 |   43 +++++++
>  include/uapi/linux/bpf.h            |   24 ++++
>  kernel/bpf/Makefile                 |    2 +-
>  kernel/bpf/syscall.c                |  225 +++++++++++++++++++++++++++++++++++
>  5 files changed, 362 insertions(+), 1 deletion(-)
>  create mode 100644 include/linux/bpf.h
>  create mode 100644 kernel/bpf/syscall.c
>
> diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
> index ee78eba78a9d..e14e486f69cd 100644
> --- a/Documentation/networking/filter.txt
> +++ b/Documentation/networking/filter.txt
> @@ -995,6 +995,75 @@ BPF_XADD | BPF_DW | BPF_STX: lock xadd *(u64 *)(dst_reg + off16) += src_reg
>  Where size is one of: BPF_B or BPF_H or BPF_W or BPF_DW. Note that 1 and
>  2 byte atomic increments are not supported.
>
> +eBPF maps
> +---------
> +'maps' is a generic storage of different types for sharing data between kernel
> +and userspace.
> +
> +The maps are accessed from user space via BPF syscall, which has commands:
> +- create a map with given id, type and attributes
> +  map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
> +  returns positive map id or negative error

Looks like these docs need updating for the fd-based approach instead
of the map_id approach?

> +
> +- delete map with given map id
> +  err = bpf_map_delete(int map_id)
> +  returns zero or negative error
> +
> +- lookup key in a given map referenced by map_id
> +  err = bpf_map_lookup_elem(int map_id, void *key, void *value)
> +  returns zero and stores found elem into value or negative error
> +
> +- create or update key/value pair in a given map
> +  err = bpf_map_update_elem(int map_id, void *key, void *value)
> +  returns zero or negative error
> +
> +- find and delete element by key in a given map
> +  err = bpf_map_delete_elem(int map_id, void *key)
> +
> +userspace programs uses this API to create/populate/read maps that eBPF programs
> +are concurrently updating.
> +
> +maps can have different types: hash, bloom filter, radix-tree, etc.
> +
> +The map is defined by:
> +  . id
> +  . type
> +  . max number of elements
> +  . key size in bytes
> +  . value size in bytes
> +
> +The maps are accesible from eBPF program with API:
> +  void * bpf_map_lookup_elem(u32 map_id, void *key);
> +  int bpf_map_update_elem(u32 map_id, void *key, void *value);
> +  int bpf_map_delete_elem(u32 map_id, void *key);
> +
> +If eBPF verifier is configured to recognize extra calls in the program
> +bpf_map_lookup_elem() and bpf_map_update_elem() then access to maps looks like:
> +  ...
> +  ptr_to_value = map_lookup_elem(const_int_map_id, key)
> +  access memory [ptr_to_value, ptr_to_value + value_size_in_bytes]
> +  ...
> +  prepare key2 and value2 on stack of key_size and value_size
> +  err = map_update_elem(const_int_map_id2, key2, value2)
> +  ...
> +
> +eBPF program cannot create or delete maps
> +(such calls will be unknown to verifier)
> +
> +During program loading the refcnt of used maps is incremented, so they don't get
> +deleted while program is running
> +
> +bpf_map_update_elem() can fail if maximum number of elements reached.
> +if key2 already exists, bpf_map_update_elem() replaces it with value2 atomically
> +
> +bpf_map_lookup_elem() can return null or ptr_to_value
> +ptr_to_value is read/write from the program point of view.
> +
> +The verifier will check that the program accesses map elements within specified
> +size. It will not let programs pass junk values as 'key' and 'value' to
> +bpf_map_*_elem() functions, so these functions (implemented in C inside kernel)
> +can safely access the pointers in all cases.
> +
>  Testing
>  -------
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> new file mode 100644
> index 000000000000..57af236a0eb4
> --- /dev/null
> +++ b/include/linux/bpf.h
> @@ -0,0 +1,43 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + */
> +#ifndef _LINUX_BPF_H
> +#define _LINUX_BPF_H 1
> +
> +#include <uapi/linux/bpf.h>
> +#include <linux/workqueue.h>
> +
> +struct bpf_map;
> +struct nlattr;
> +
> +/* map is generic key/value storage optionally accesible by eBPF programs */
> +struct bpf_map_ops {
> +       /* funcs callable from userspace (via syscall) */
> +       struct bpf_map *(*map_alloc)(struct nlattr *attrs[BPF_MAP_ATTR_MAX + 1]);
> +       void (*map_free)(struct bpf_map *);
> +};
> +
> +struct bpf_map {
> +       atomic_t refcnt;
> +       int map_id;
> +       enum bpf_map_type map_type;
> +       u32 key_size;
> +       u32 value_size;
> +       u32 max_entries;
> +       struct bpf_map_ops *ops;
> +       struct work_struct work;
> +};
> +
> +struct bpf_map_type_list {
> +       struct list_head list_node;
> +       struct bpf_map_ops *ops;
> +       enum bpf_map_type type;
> +};
> +
> +void bpf_register_map_type(struct bpf_map_type_list *tl);
> +struct bpf_map *bpf_map_get(u32 map_id);
> +
> +#endif /* _LINUX_BPF_H */
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 3ff5bf5045a7..dcc7eb97a64a 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -300,4 +300,28 @@ struct bpf_insn {
>         __s32   imm;            /* signed immediate constant */
>  };
>
> +/* BPF syscall commands */
> +enum bpf_cmd {
> +       /* create a map with given type and attributes
> +        * fd = bpf_map_create(bpf_map_type, struct nlattr *attr, int len)
> +        * returns fd or negative error
> +        * map is deleted when fd is closed
> +        */
> +       BPF_MAP_CREATE,
> +};
> +
> +enum bpf_map_attributes {
> +       BPF_MAP_UNSPEC,
> +       BPF_MAP_KEY_SIZE,       /* size of key in bytes */
> +       BPF_MAP_VALUE_SIZE,     /* size of value in bytes */
> +       BPF_MAP_MAX_ENTRIES,    /* maximum number of entries in a map */
> +       __BPF_MAP_ATTR_MAX,
> +};
> +#define BPF_MAP_ATTR_MAX (__BPF_MAP_ATTR_MAX - 1)
> +#define BPF_MAP_MAX_ATTR_SIZE 65535
> +
> +enum bpf_map_type {
> +       BPF_MAP_TYPE_UNSPEC,
> +};
> +
>  #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
> index 6a71145e2769..e9f7334ed07a 100644
> --- a/kernel/bpf/Makefile
> +++ b/kernel/bpf/Makefile
> @@ -1 +1 @@
> -obj-y := core.o
> +obj-y := core.o syscall.o
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> new file mode 100644
> index 000000000000..c4a330642653
> --- /dev/null
> +++ b/kernel/bpf/syscall.c
> @@ -0,0 +1,225 @@
> +/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + */
> +#include <linux/bpf.h>
> +#include <linux/syscalls.h>
> +#include <net/netlink.h>
> +#include <linux/anon_inodes.h>
> +
> +/* mutex to protect insertion/deletion of map_id in IDR */
> +static DEFINE_MUTEX(bpf_map_lock);
> +static DEFINE_IDR(bpf_map_id_idr);
> +
> +/* maximum number of outstanding maps */
> +#define MAX_BPF_MAP_CNT 1024
> +static u32 bpf_map_cnt;
> +
> +static LIST_HEAD(bpf_map_types);
> +
> +static struct bpf_map *find_and_alloc_map(enum bpf_map_type type,
> +                                         struct nlattr *tb[BPF_MAP_ATTR_MAX + 1])
> +{
> +       struct bpf_map_type_list *tl;
> +       struct bpf_map *map;
> +
> +       list_for_each_entry(tl, &bpf_map_types, list_node) {
> +               if (tl->type == type) {
> +                       map = tl->ops->map_alloc(tb);
> +                       if (IS_ERR(map))
> +                               return map;
> +                       map->ops = tl->ops;
> +                       map->map_type = type;
> +                       return map;
> +               }
> +       }
> +       return ERR_PTR(-EINVAL);
> +}
> +
> +/* boot time registration of different map implementations */
> +void bpf_register_map_type(struct bpf_map_type_list *tl)
> +{
> +       list_add(&tl->list_node, &bpf_map_types);
> +}
> +
> +/* called from workqueue */
> +static void bpf_map_free_deferred(struct work_struct *work)
> +{
> +       struct bpf_map *map = container_of(work, struct bpf_map, work);
> +
> +       /* grab the mutex and free the map */
> +       mutex_lock(&bpf_map_lock);
> +
> +       bpf_map_cnt--;
> +       idr_remove(&bpf_map_id_idr, map->map_id);
> +
> +       mutex_unlock(&bpf_map_lock);
> +
> +       /* implementation dependent freeing */
> +       map->ops->map_free(map);
> +}
> +
> +/* decrement map refcnt and schedule it for freeing via workqueue
> + * (unrelying map implementation ops->map_free() might sleep)
> + */
> +static void __bpf_map_put(struct bpf_map *map)
> +{
> +       if (atomic_dec_and_test(&map->refcnt)) {
> +               INIT_WORK(&map->work, bpf_map_free_deferred);
> +               schedule_work(&map->work);
> +       }
> +}
> +
> +/* find map by id and decrement its refcnt
> + *
> + * can be called without any locks held
> + *
> + * returns true if map was found
> + */
> +static bool bpf_map_put(u32 map_id)
> +{
> +       struct bpf_map *map;
> +
> +       rcu_read_lock();
> +       map = idr_find(&bpf_map_id_idr, map_id);
> +
> +       if (!map) {
> +               rcu_read_unlock();
> +               return false;
> +       }
> +
> +       __bpf_map_put(map);
> +       rcu_read_unlock();
> +
> +       return true;
> +}
> +
> +/* called with bpf_map_lock held */
> +struct bpf_map *bpf_map_get(u32 map_id)
> +{
> +       BUG_ON(!mutex_is_locked(&bpf_map_lock));
> +
> +       return idr_find(&bpf_map_id_idr, map_id);
> +}
> +
> +static int bpf_map_release(struct inode *inode, struct file *filp)
> +{
> +       struct bpf_map *map = filp->private_data;
> +
> +       __bpf_map_put(map);
> +       return 0;
> +}
> +
> +static const struct file_operations bpf_map_fops = {
> +        .release = bpf_map_release,
> +};
> +
> +static const struct nla_policy map_policy[BPF_MAP_ATTR_MAX + 1] = {
> +       [BPF_MAP_KEY_SIZE]    = { .type = NLA_U32 },
> +       [BPF_MAP_VALUE_SIZE]  = { .type = NLA_U32 },
> +       [BPF_MAP_MAX_ENTRIES] = { .type = NLA_U32 },
> +};
> +
> +/* called via syscall */
> +static int map_create(enum bpf_map_type type, struct nlattr __user *uattr, int len)
> +{
> +       struct nlattr *tb[BPF_MAP_ATTR_MAX + 1];
> +       struct bpf_map *map;
> +       struct nlattr *attr;
> +       int err;
> +
> +       if (len <= 0 || len > BPF_MAP_MAX_ATTR_SIZE)
> +               return -EINVAL;
> +
> +       attr = kmalloc(len, GFP_USER);
> +       if (!attr)
> +               return -ENOMEM;
> +
> +       /* copy map attributes from user space */
> +       err = -EFAULT;
> +       if (copy_from_user(attr, uattr, len) != 0)
> +               goto free_attr;
> +
> +       /* perform basic validation */
> +       err = nla_parse(tb, BPF_MAP_ATTR_MAX, attr, len, map_policy);
> +       if (err < 0)
> +               goto free_attr;
> +
> +       /* find map type and init map: hashtable vs rbtree vs bloom vs ... */
> +       map = find_and_alloc_map(type, tb);
> +       if (IS_ERR(map)) {
> +               err = PTR_ERR(map);
> +               goto free_attr;
> +       }
> +
> +       atomic_set(&map->refcnt, 1);
> +
> +       mutex_lock(&bpf_map_lock);
> +
> +       if (bpf_map_cnt >= MAX_BPF_MAP_CNT) {
> +               mutex_unlock(&bpf_map_lock);
> +               err = -ENOSPC;
> +               goto free_map;
> +       }
> +
> +       /* allocate map id */
> +       err = idr_alloc(&bpf_map_id_idr, map, 1 /* min map_id */, 0, GFP_USER);
> +
> +       if (err > 0)
> +               bpf_map_cnt++;
> +
> +       map->map_id = err;
> +
> +       mutex_unlock(&bpf_map_lock);
> +
> +       if (err < 0)
> +               /* failed to allocate map id */
> +               goto free_map;
> +
> +       err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
> +
> +       if (err < 0)
> +               /* failed to allocate fd */
> +               goto free_map_id;
> +
> +       /* user supplied array of map attributes is no longer needed */
> +       kfree(attr);
> +
> +       return err;
> +
> +free_map_id:
> +       /* grab the mutex and free the map */
> +       mutex_lock(&bpf_map_lock);
> +
> +       bpf_map_cnt--;
> +       idr_remove(&bpf_map_id_idr, map->map_id);
> +
> +       mutex_unlock(&bpf_map_lock);
> +free_map:
> +       map->ops->map_free(map);
> +free_attr:
> +       kfree(attr);
> +       return err;
> +}
> +
> +SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
> +               unsigned long, arg4, unsigned long, arg5)
> +{
> +       if (!capable(CAP_SYS_ADMIN))
> +               return -EPERM;

It might be valuable to have a comment here describing why this is
currently limited to CAP_SYS_ADMIN.

> +
> +       switch (cmd) {
> +       case BPF_MAP_CREATE:
> +               return map_create((enum bpf_map_type) arg2,
> +                                 (struct nlattr __user *) arg3, (int) arg4);

I'd recommend requiring arg5 == 0 here, just for future flexibility.

-Kees

> +       default:
> +               return -EINVAL;
> +       }
> +}
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
