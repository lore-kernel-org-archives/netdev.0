From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 1/3] security: bpf: Add eBPF LSM hooks to security module
Date: Fri, 01 Sep 2017 08:50:23 -0400
Message-ID: <1504270223.8240.2.camel@tycho.nsa.gov>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
         <20170831205635.80256-2-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Chenbo Feng <fengc@google.com>, SELinux <Selinux@tycho.nsa.gov>,
        netdev@vger.kernel.org,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com
To: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170831205635.80256-2-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-31 at 13:56 -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Introduce 5 LSM hooks to provide finer granularity controls on eBPF
> related operations including create eBPF maps, modify and read eBPF
> maps
> content and load eBPF programs to the kernel. Hooks use the new
> security
> pointer inside the eBPF map struct to store the owner's security
> information and the different security modules can perform different
> checks based on the information stored inside the security field.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> ---
>  include/linux/lsm_hooks.h | 41
> +++++++++++++++++++++++++++++++++++++++++
>  include/linux/security.h  | 36 ++++++++++++++++++++++++++++++++++++
>  security/security.c       | 28 ++++++++++++++++++++++++++++
>  3 files changed, 105 insertions(+)
> 
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index ce02f76a6188..3aaf9a08a983 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -1353,6 +1353,32 @@
>   *	@inode we wish to get the security context of.
>   *	@ctx is a pointer in which to place the allocated security
> context.
>   *	@ctxlen points to the place to put the length of @ctx.
> + *
> + * Security hooks for using the eBPF maps and programs
> functionalities through
> + * eBPF syscalls.
> + *
> + * @bpf_map_create:
> + *	Check permissions prior to creating a new bpf map.
> + *	Return 0 if the permission is granted.
> + *
> + * @bpf_map_modify:
> + *	Check permission prior to insert, update and delete map
> content.
> + *	@map pointer to the struct bpf_map that contains map
> information.
> + *	Return 0 if the permission is granted.
> + *
> + * @bpf_map_read:
> + *	Check permission prior to read a bpf map content.
> + *	@map pointer to the struct bpf_map that contains map
> information.
> + *	Return 0 if the permission is granted.
> + *
> + * @bpf_prog_load:
> + *	Check permission prior to load eBPF program.
> + *	Return 0 if the permission is granted.
> + *
> + * @bpf_post_create:
> + *	Initialize the bpf object security field inside struct
> bpf_maps and
> + *	it is used for future security checks.
> + *
>   */
>  union security_list_options {
>  	int (*binder_set_context_mgr)(struct task_struct *mgr);
> @@ -1685,6 +1711,14 @@ union security_list_options {
>  				struct audit_context *actx);
>  	void (*audit_rule_free)(void *lsmrule);
>  #endif /* CONFIG_AUDIT */
> +
> +#ifdef CONFIG_BPF_SYSCALL
> +	int (*bpf_map_create)(void);
> +	int (*bpf_map_read)(struct bpf_map *map);
> +	int (*bpf_map_modify)(struct bpf_map *map);
> +	int (*bpf_prog_load)(void);
> +	int (*bpf_post_create)(struct bpf_map *map);
> +#endif /* CONFIG_BPF_SYSCALL */
>  };
>  
>  struct security_hook_heads {
> @@ -1905,6 +1939,13 @@ struct security_hook_heads {
>  	struct list_head audit_rule_match;
>  	struct list_head audit_rule_free;
>  #endif /* CONFIG_AUDIT */
> +#ifdef CONFIG_BPF_SYSCALL
> +	struct list_head bpf_map_create;
> +	struct list_head bpf_map_read;
> +	struct list_head bpf_map_modify;
> +	struct list_head bpf_prog_load;
> +	struct list_head bpf_post_create;
> +#endif /* CONFIG_BPF_SYSCALL */
>  } __randomize_layout;
>  
>  /*
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 458e24bea2d4..0656a4f74d14 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -31,6 +31,7 @@
>  #include <linux/string.h>
>  #include <linux/mm.h>
>  #include <linux/fs.h>
> +#include <linux/bpf.h>
>  
>  struct linux_binprm;
>  struct cred;
> @@ -1735,6 +1736,41 @@ static inline void securityfs_remove(struct
> dentry *dentry)
>  
>  #endif
>  
> +#ifdef CONFIG_BPF_SYSCALL
> +#ifdef CONFIG_SECURITY
> +int security_map_create(void);
> +int security_map_modify(struct bpf_map *map);
> +int security_map_read(struct bpf_map *map);
> +int security_prog_load(void);
> +int security_post_create(struct bpf_map *map);
> +#else
> +static inline int security_map_create(void)
> +{
> +	return 0;
> +}
> +
> +static inline int security_map_read(struct bpf_map *map)
> +{
> +	return 0;
> +}
> +
> +static inline int security_map_modify(struct bpf_map *map)
> +{
> +	return 0;
> +}
> +
> +static inline int security_prog_load(void)
> +{
> +	return 0;
> +}
> +
> +static inline int security_post_create(struct bpf_map *map)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_SECURITY */
> +#endif /* CONFIG_BPF_SYSCALL */

These should be named consistently with the ones in lsm_hooks.h and
should unambiguously indicate that these are hooks for bpf
objects/operations, i.e. security_bpf_map_create(),
security_bpf_map_read(), etc.

Do you need this level of granularity?

Could you coalesce the map_create() and post_map_create() hooks into
one hook and just unwind the create in that case?

Why do you label bpf maps but not bpf progs?  Should we be controlling
the ability to attach/detach a bpf prog (partly controlled by
CAP_NET_ADMIN, but also somewhat broad in scope and doesn't allow
control based on who created the prog)?

Should there be a top-level security_bpf_use() hook and permission
check that limits ability to use bpf() at all?

> +
>  #ifdef CONFIG_SECURITY
>  
>  static inline char *alloc_secdata(void)
> diff --git a/security/security.c b/security/security.c
> index 55b5997e4b72..02272f93a89e 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -12,6 +12,7 @@
>   *	(at your option) any later version.
>   */
>  
> +#include <linux/bpf.h>
>  #include <linux/capability.h>
>  #include <linux/dcache.h>
>  #include <linux/module.h>
> @@ -1708,3 +1709,30 @@ int security_audit_rule_match(u32 secid, u32
> field, u32 op, void *lsmrule,
>  				actx);
>  }
>  #endif /* CONFIG_AUDIT */
> +
> +#ifdef CONFIG_BPF_SYSCALL
> +int security_map_create(void)
> +{
> +	return call_int_hook(bpf_map_create, 0);
> +}
> +
> +int security_map_modify(struct bpf_map *map)
> +{
> +	return call_int_hook(bpf_map_modify, 0, map);
> +}
> +
> +int security_map_read(struct bpf_map *map)
> +{
> +	return call_int_hook(bpf_map_read, 0, map);
> +}
> +
> +int security_prog_load(void)
> +{
> +	return call_int_hook(bpf_prog_load, 0);
> +}
> +
> +int security_post_create(struct bpf_map *map)
> +{
> +	return call_int_hook(bpf_post_create, 0, map);
> +}
> +#endif /* CONFIG_BPF_SYSCALL */
