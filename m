From: Daniel J Walsh <dwalsh@redhat.com>
Subject: Re: [PATCH 2/3] security: introducing security_request_module
Date: Thu, 13 Aug 2009 13:17:47 -0400
Message-ID: <4A844ABB.3050001@redhat.com>
References: <20090813033537.27287.18981.stgit@paris.rdu.redhat.com> <20090813033543.27287.95970.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	sds@tycho.nsa.gov, davem@davemloft.net,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090813033543.27287.95970.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2009 11:35 PM, Eric Paris wrote:
> Calling request_module() will trigger a userspace upcall which will load a
> new module into the kernel.  This can be a dangerous event if the process
> able to trigger request_module() is able to control either the modprobe
> binary or the module binary.  This patch adds a new security hook to
> request_module() which can be used by an LSM to control a processes ability
> to call request_module().
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> ---
> 
>  include/linux/security.h |   10 ++++++++++
>  kernel/kmod.c            |    4 ++++
>  security/capability.c    |    6 ++++++
>  security/security.c      |    5 +++++
>  4 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/security.h b/include/linux/security.h
> index d5f6578..34c5465 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -678,6 +678,9 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	@inode points to the inode to use as a reference.
>   *	The current task must be the one that nominated @inode.
>   *	Return 0 if successful.
> + * @kernel_module_request:
> + *	Ability to trigger the kernel to automatically upcall to userspace for
> + *	userspace to load a kernel module with the given name.
>   * @task_setuid:
>   *	Check permission before setting one or more of the user identity
>   *	attributes of the current process.  The @flags parameter indicates
> @@ -1500,6 +1503,7 @@ struct security_operations {
>  	void (*cred_commit)(struct cred *new, const struct cred *old);
>  	int (*kernel_act_as)(struct cred *new, u32 secid);
>  	int (*kernel_create_files_as)(struct cred *new, struct inode *inode);
> +	int (*kernel_module_request)(void);
>  	int (*task_setuid) (uid_t id0, uid_t id1, uid_t id2, int flags);
>  	int (*task_fix_setuid) (struct cred *new, const struct cred *old,
>  				int flags);
> @@ -1755,6 +1759,7 @@ int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
>  void security_commit_creds(struct cred *new, const struct cred *old);
>  int security_kernel_act_as(struct cred *new, u32 secid);
>  int security_kernel_create_files_as(struct cred *new, struct inode *inode);
> +int security_kernel_module_request(void);
>  int security_task_setuid(uid_t id0, uid_t id1, uid_t id2, int flags);
>  int security_task_fix_setuid(struct cred *new, const struct cred *old,
>  			     int flags);
> @@ -2306,6 +2311,11 @@ static inline int security_kernel_create_files_as(struct cred *cred,
>  	return 0;
>  }
>  
> +static inline int security_kernel_module_request(void)
> +{
> +	return 0;
> +}
> +
>  static inline int security_task_setuid(uid_t id0, uid_t id1, uid_t id2,
>  				       int flags)
>  {
> diff --git a/kernel/kmod.c b/kernel/kmod.c
> index 385c31a..5a7ae57 100644
> --- a/kernel/kmod.c
> +++ b/kernel/kmod.c
> @@ -78,6 +78,10 @@ int __request_module(bool wait, const char *fmt, ...)
>  #define MAX_KMOD_CONCURRENT 50	/* Completely arbitrary value - KAO */
>  	static int kmod_loop_msg;
>  
> +	ret = security_kernel_module_request();
> +	if (ret)
> +		return ret;
> +
>  	va_start(args, fmt);
>  	ret = vsnprintf(module_name, MODULE_NAME_LEN, fmt, args);
>  	va_end(args);
> diff --git a/security/capability.c b/security/capability.c
> index 4f23f4f..06400cf 100644
> --- a/security/capability.c
> +++ b/security/capability.c
> @@ -396,6 +396,11 @@ static int cap_kernel_create_files_as(struct cred *new, struct inode *inode)
>  	return 0;
>  }
>  
> +static int cap_kernel_module_request(void)
> +{
> +	return 0;
> +}
> +
>  static int cap_task_setuid(uid_t id0, uid_t id1, uid_t id2, int flags)
>  {
>  	return 0;
> @@ -961,6 +966,7 @@ void security_fixup_ops(struct security_operations *ops)
>  	set_to_cap_if_null(ops, cred_commit);
>  	set_to_cap_if_null(ops, kernel_act_as);
>  	set_to_cap_if_null(ops, kernel_create_files_as);
> +	set_to_cap_if_null(ops, kernel_module_request);
>  	set_to_cap_if_null(ops, task_setuid);
>  	set_to_cap_if_null(ops, task_fix_setuid);
>  	set_to_cap_if_null(ops, task_setgid);
> diff --git a/security/security.c b/security/security.c
> index b98c684..f88eaf6 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -709,6 +709,11 @@ int security_kernel_create_files_as(struct cred *new, struct inode *inode)
>  	return security_ops->kernel_create_files_as(new, inode);
>  }
>  
> +int security_kernel_module_request(void)
> +{
> +	return security_ops->kernel_module_request();
> +}
> +
>  int security_task_setuid(uid_t id0, uid_t id1, uid_t id2, int flags)
>  {
>  	return security_ops->task_setuid(id0, id1, id2, flags);
> 
Every domain that I know of that currently causes this sys_module has net_admin privs, so this will allow us to run a tighter policy.


