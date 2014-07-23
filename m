From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH RFC v2 net-next 07/16] bpf: add lookup/update/delete/iterate
 methods to BPF maps
Date: Wed, 23 Jul 2014 11:25:13 -0700
Message-ID: <CAGXu5j+cvG5BhNSA=UrcbYs3LPSZUZyj4_ey8=9O0KgbUYUd9g@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-8-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-8-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 9:19 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> 'maps' is a generic storage of different types for sharing data between kernel
> and userspace.
>
> The maps are accessed from user space via BPF syscall, which has commands:
>
> - create a map with given type and attributes
>   fd = bpf_map_create(map_type, struct nlattr *attr, int len)
>   returns fd or negative error
>
> - lookup key in a given map referenced by fd
>   err = bpf_map_lookup_elem(int fd, void *key, void *value)
>   returns zero and stores found elem into value or negative error
>
> - create or update key/value pair in a given map
>   err = bpf_map_update_elem(int fd, void *key, void *value)
>   returns zero or negative error
>
> - find and delete element by key in a given map
>   err = bpf_map_delete_elem(int fd, void *key)
>
> - iterate map elements (based on input key return next_key)
>   err = bpf_map_get_next_key(int fd, void *key, void *next_key)
>
> - close(fd) deletes the map
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  include/linux/bpf.h      |    6 ++
>  include/uapi/linux/bpf.h |   25 ++++++
>  kernel/bpf/syscall.c     |  209 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 240 insertions(+)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 57af236a0eb4..91e2caf8edf9 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -18,6 +18,12 @@ struct bpf_map_ops {
>         /* funcs callable from userspace (via syscall) */
>         struct bpf_map *(*map_alloc)(struct nlattr *attrs[BPF_MAP_ATTR_MAX + 1]);
>         void (*map_free)(struct bpf_map *);
> +       int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
> +
> +       /* funcs callable from userspace and from eBPF programs */
> +       void *(*map_lookup_elem)(struct bpf_map *map, void *key);
> +       int (*map_update_elem)(struct bpf_map *map, void *key, void *value);
> +       int (*map_delete_elem)(struct bpf_map *map, void *key);
>  };
>
>  struct bpf_map {
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index dcc7eb97a64a..5e1bfbc9cdc7 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -308,6 +308,31 @@ enum bpf_cmd {
>          * map is deleted when fd is closed
>          */
>         BPF_MAP_CREATE,
> +
> +       /* lookup key in a given map referenced by map_id
> +        * err = bpf_map_lookup_elem(int map_id, void *key, void *value)

This needs map_id documentation updates too?

> +        * returns zero and stores found elem into value
> +        * or negative error
> +        */
> +       BPF_MAP_LOOKUP_ELEM,
> +
> +       /* create or update key/value pair in a given map
> +        * err = bpf_map_update_elem(int map_id, void *key, void *value)
> +        * returns zero or negative error
> +        */
> +       BPF_MAP_UPDATE_ELEM,
> +
> +       /* find and delete elem by key in a given map
> +        * err = bpf_map_delete_elem(int map_id, void *key)
> +        * returns zero or negative error
> +        */
> +       BPF_MAP_DELETE_ELEM,
> +
> +       /* lookup key in a given map and return next key
> +        * err = bpf_map_get_elem(int map_id, void *key, void *next_key)
> +        * returns zero and stores next key or negative error
> +        */
> +       BPF_MAP_GET_NEXT_KEY,
>  };
>
>  enum bpf_map_attributes {
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index c4a330642653..ca2be66845b3 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -13,6 +13,7 @@
>  #include <linux/syscalls.h>
>  #include <net/netlink.h>
>  #include <linux/anon_inodes.h>
> +#include <linux/file.h>
>
>  /* mutex to protect insertion/deletion of map_id in IDR */
>  static DEFINE_MUTEX(bpf_map_lock);
> @@ -209,6 +210,202 @@ free_attr:
>         return err;
>  }
>
> +static int get_map_id(struct fd f)
> +{
> +       struct bpf_map *map;
> +
> +       if (!f.file)
> +               return -EBADF;
> +
> +       if (f.file->f_op != &bpf_map_fops) {
> +               fdput(f);

It feels weird to me to do the fdput inside this function. Instead,
should map_lookup_elem get a "err_put" label, instead?

> +               return -EINVAL;
> +       }
> +
> +       map = f.file->private_data;
> +
> +       return map->map_id;
> +}
> +
> +static int map_lookup_elem(int ufd, void __user *ukey, void __user *uvalue)
> +{
> +       struct fd f = fdget(ufd);
> +       struct bpf_map *map;
> +       void *key, *value;
> +       int err;
> +
> +       err = get_map_id(f);
> +       if (err < 0)
> +               return err;

for example:

    if (err < 0)
        goto fail_put;

> +
> +       rcu_read_lock();
> +       map = idr_find(&bpf_map_id_idr, err);
> +       err = -EINVAL;
> +       if (!map)
> +               goto err_unlock;
> +
> +       err = -ENOMEM;
> +       key = kmalloc(map->key_size, GFP_ATOMIC);
> +       if (!key)
> +               goto err_unlock;
> +
> +       err = -EFAULT;
> +       if (copy_from_user(key, ukey, map->key_size) != 0)
> +               goto free_key;
> +
> +       err = -ESRCH;
> +       value = map->ops->map_lookup_elem(map, key);
> +       if (!value)
> +               goto free_key;
> +
> +       err = -EFAULT;
> +       if (copy_to_user(uvalue, value, map->value_size) != 0)
> +               goto free_key;

I'm made uncomfortable with memory copying where explicit lengths from
userspace aren't being used. It does look like it would be redundant,
though. Are there other syscalls where the kernel may stomp on user
memory based on internal kernel sizes? I think this is fine as-is, but
it makes me want to think harder about it. :)

> +
> +       err = 0;
> +
> +free_key:
> +       kfree(key);
> +err_unlock:
> +       rcu_read_unlock();

fail_put:

> +       fdput(f);
> +       return err;
> +}
> +
> +static int map_update_elem(int ufd, void __user *ukey, void __user *uvalue)
> +{
> +       struct fd f = fdget(ufd);
> +       struct bpf_map *map;
> +       void *key, *value;
> +       int err;
> +
> +       err = get_map_id(f);
> +       if (err < 0)
> +               return err;

Same thing?

> +
> +       rcu_read_lock();
> +       map = idr_find(&bpf_map_id_idr, err);
> +       err = -EINVAL;
> +       if (!map)
> +               goto err_unlock;
> +
> +       err = -ENOMEM;
> +       key = kmalloc(map->key_size, GFP_ATOMIC);
> +       if (!key)
> +               goto err_unlock;
> +
> +       err = -EFAULT;
> +       if (copy_from_user(key, ukey, map->key_size) != 0)
> +               goto free_key;
> +
> +       err = -ENOMEM;
> +       value = kmalloc(map->value_size, GFP_ATOMIC);
> +       if (!value)
> +               goto free_key;
> +
> +       err = -EFAULT;
> +       if (copy_from_user(value, uvalue, map->value_size) != 0)
> +               goto free_value;
> +
> +       err = map->ops->map_update_elem(map, key, value);
> +
> +free_value:
> +       kfree(value);
> +free_key:
> +       kfree(key);
> +err_unlock:
> +       rcu_read_unlock();
> +       fdput(f);
> +       return err;
> +}
> +
> +static int map_delete_elem(int ufd, void __user *ukey)
> +{
> +       struct fd f = fdget(ufd);
> +       struct bpf_map *map;
> +       void *key;
> +       int err;
> +
> +       err = get_map_id(f);
> +       if (err < 0)
> +               return err;
> +
> +       rcu_read_lock();
> +       map = idr_find(&bpf_map_id_idr, err);
> +       err = -EINVAL;
> +       if (!map)
> +               goto err_unlock;
> +
> +       err = -ENOMEM;
> +       key = kmalloc(map->key_size, GFP_ATOMIC);
> +       if (!key)
> +               goto err_unlock;
> +
> +       err = -EFAULT;
> +       if (copy_from_user(key, ukey, map->key_size) != 0)
> +               goto free_key;
> +
> +       err = map->ops->map_delete_elem(map, key);
> +
> +free_key:
> +       kfree(key);
> +err_unlock:
> +       rcu_read_unlock();
> +       fdput(f);
> +       return err;
> +}
> +
> +static int map_get_next_key(int ufd, void __user *ukey, void __user *unext_key)
> +{
> +       struct fd f = fdget(ufd);
> +       struct bpf_map *map;
> +       void *key, *next_key;
> +       int err;
> +
> +       err = get_map_id(f);
> +       if (err < 0)
> +               return err;
> +
> +       rcu_read_lock();
> +       map = idr_find(&bpf_map_id_idr, err);
> +       err = -EINVAL;
> +       if (!map)
> +               goto err_unlock;
> +
> +       err = -ENOMEM;
> +       key = kmalloc(map->key_size, GFP_ATOMIC);
> +       if (!key)
> +               goto err_unlock;
> +
> +       err = -EFAULT;
> +       if (copy_from_user(key, ukey, map->key_size) != 0)
> +               goto free_key;
> +
> +       err = -ENOMEM;
> +       next_key = kmalloc(map->key_size, GFP_ATOMIC);

In the interests of defensiveness, I'd use kzalloc here.

> +       if (!next_key)
> +               goto free_key;
> +
> +       err = map->ops->map_get_next_key(map, key, next_key);
> +       if (err)
> +               goto free_next_key;
> +
> +       err = -EFAULT;
> +       if (copy_to_user(unext_key, next_key, map->key_size) != 0)
> +               goto free_next_key;
> +
> +       err = 0;
> +
> +free_next_key:
> +       kfree(next_key);
> +free_key:
> +       kfree(key);
> +err_unlock:
> +       rcu_read_unlock();
> +       fdput(f);
> +       return err;
> +}
> +
>  SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
>                 unsigned long, arg4, unsigned long, arg5)
>  {
> @@ -219,6 +416,18 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
>         case BPF_MAP_CREATE:
>                 return map_create((enum bpf_map_type) arg2,
>                                   (struct nlattr __user *) arg3, (int) arg4);
> +       case BPF_MAP_LOOKUP_ELEM:
> +               return map_lookup_elem((int) arg2, (void __user *) arg3,
> +                                      (void __user *) arg4);
> +       case BPF_MAP_UPDATE_ELEM:
> +               return map_update_elem((int) arg2, (void __user *) arg3,
> +                                      (void __user *) arg4);
> +       case BPF_MAP_DELETE_ELEM:
> +               return map_delete_elem((int) arg2, (void __user *) arg3);
> +
> +       case BPF_MAP_GET_NEXT_KEY:
> +               return map_get_next_key((int) arg2, (void __user *) arg3,
> +                                       (void __user *) arg4);

Same observation as the other syscall cmd: perhaps arg5 == 0 should be
checked? Also, since each of these functions looks up the fd and
builds the key, maybe those should be added to a common helper instead
of copy/pasting into each demuxed function?

-Kees

>         default:
>                 return -EINVAL;
>         }
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
