From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/5] bpf: Add file mode configuration into
 bpf maps
Date: Mon, 9 Oct 2017 16:07:19 -0700
Message-ID: <20171009230718.q6y57izbnyqtfw4y@ast-mbp>
References: <20171009222028.13096-1-chenbofeng.kernel@gmail.com>
 <20171009222028.13096-2-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        Jeffrey Vander Stoep <jeffv@google.com>, lorenzo@google.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009222028.13096-2-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 03:20:24PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Introduce the map read/write flags to the eBPF syscalls that returns the
> map fd. The flags is used to set up the file mode when construct a new
> file descriptor for bpf maps. To not break the backward capability, the
> f_flags is set to O_RDWR if the flag passed by syscall is 0. Otherwise
> it should be O_RDONLY or O_WRONLY. When the userspace want to modify or
> read the map content, it will check the file mode to see if it is
> allowed to make the change.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  include/linux/bpf.h      |  6 ++--
>  include/uapi/linux/bpf.h |  6 ++++
>  kernel/bpf/arraymap.c    |  7 +++--
>  kernel/bpf/devmap.c      |  5 ++-
>  kernel/bpf/hashtab.c     |  5 +--
>  kernel/bpf/inode.c       | 15 ++++++---
>  kernel/bpf/lpm_trie.c    |  3 +-
>  kernel/bpf/sockmap.c     |  5 ++-
>  kernel/bpf/stackmap.c    |  5 ++-
>  kernel/bpf/syscall.c     | 80 +++++++++++++++++++++++++++++++++++++++++++-----
>  10 files changed, 114 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index bc7da2ddfcaf..0e9ca2555d7f 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -308,11 +308,11 @@ void bpf_map_area_free(void *base);
>  
>  extern int sysctl_unprivileged_bpf_disabled;
>  
> -int bpf_map_new_fd(struct bpf_map *map);
> +int bpf_map_new_fd(struct bpf_map *map, int flags);
>  int bpf_prog_new_fd(struct bpf_prog *prog);
>  
>  int bpf_obj_pin_user(u32 ufd, const char __user *pathname);
> -int bpf_obj_get_user(const char __user *pathname);
> +int bpf_obj_get_user(const char __user *pathname, int flags);
>  
>  int bpf_percpu_hash_copy(struct bpf_map *map, void *key, void *value);
>  int bpf_percpu_array_copy(struct bpf_map *map, void *key, void *value);
> @@ -331,6 +331,8 @@ int bpf_fd_htab_map_update_elem(struct bpf_map *map, struct file *map_file,
>  				void *key, void *value, u64 map_flags);
>  int bpf_fd_htab_map_lookup_elem(struct bpf_map *map, void *key, u32 *value);
>  
> +int bpf_get_file_flag(int flags);
> +
>  /* memcpy that is used with 8-byte aligned pointers, power-of-8 size and
>   * forced to use 'long' read/writes to try to atomically copy long counters.
>   * Best-effort only.  No barriers here, since it _will_ race with concurrent
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 6db9e1d679cd..9cb50a228c39 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -217,6 +217,10 @@ enum bpf_attach_type {
>  
>  #define BPF_OBJ_NAME_LEN 16U
>  
> +/* Flags for accessing BPF object */
> +#define BPF_F_RDONLY		(1U << 3)
> +#define BPF_F_WRONLY		(1U << 4)
> +
>  union bpf_attr {
>  	struct { /* anonymous struct used by BPF_MAP_CREATE command */
>  		__u32	map_type;	/* one of enum bpf_map_type */
> @@ -259,6 +263,7 @@ union bpf_attr {
>  	struct { /* anonymous struct used by BPF_OBJ_* commands */
>  		__aligned_u64	pathname;
>  		__u32		bpf_fd;
> +		__u32		file_flags;
>  	};
>  
>  	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
> @@ -286,6 +291,7 @@ union bpf_attr {
>  			__u32		map_id;
>  		};
>  		__u32		next_id;
> +		__u32		open_flags;
>  	};
>  
>  	struct { /* anonymous struct used by BPF_OBJ_GET_INFO_BY_FD */
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index 68d866628be0..f869e48ef2f6 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -19,6 +19,9 @@
>  
>  #include "map_in_map.h"
>  
> +#define ARRAY_CREATE_FLAG_MASK \
> +	(BPF_F_NUMA_NODE | BPF_F_RDONLY | BPF_F_WRONLY)
> +
>  static void bpf_array_free_percpu(struct bpf_array *array)
>  {
>  	int i;
> @@ -56,8 +59,8 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
>  
>  	/* check sanity of attributes */
>  	if (attr->max_entries == 0 || attr->key_size != 4 ||
> -	    attr->value_size == 0 || attr->map_flags & ~BPF_F_NUMA_NODE ||
> -	    (percpu && numa_node != NUMA_NO_NODE))
> +	    attr->value_size == 0 || attr->map_flags &
> +	    ~ARRAY_CREATE_FLAG_MASK || (percpu && numa_node != NUMA_NO_NODE))

that's very non-standard way of breaking lines.
Did you run checkpatch ? did it complain?

