From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 2/7] ns: Introduce the setns syscall
Date: Sat, 7 May 2011 20:51:09 -0700
Message-ID: <20110508035109.GG12920@count0.beaverton.ibm.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
 <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
 <1304735101-1824-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	linux-fsdevel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304735101-1824-2-git-send-email-ebiederm@xmission.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2011 at 07:24:56PM -0700, Eric W. Biederman wrote:
> With the networking stack today there is demand to handle
> multiple network stacks at a time.  Not in the context
> of containers but in the context of people doing interesting
> things with routing.
> 
> There is also demand in the context of containers to have
> an efficient way to execute some code in the container itself.
> If nothing else it is very useful ad a debugging technique.
> 
> Both problems can be solved by starting some form of login
> daemon in the namespaces people want access to, or you
> can play games by ptracing a process and getting the
> traced process to do things you want it to do. However
> it turns out that a login daemon or a ptrace puppet
> controller are more code, they are more prone to
> failure, and generally they are less efficient than
> simply changing the namespace of a process to a
> specified one.
> 
> Pieces of this puzzle can also be solved by instead of
> coming up with a general purpose system call coming up
> with targed system calls perhaps socketat that solve
> a subset of the larger problem.  Overall that appears
> to be more work for less reward.
> 
> int setns(int fd, int nstype);
> 
> The fd argument is a file descriptor referring to a proc
> file of the namespace you want to switch the process to.
> 
> In the setns system call the nstype is 0 or specifies
> an clone flag of the namespace you intend to change
> to prevent changing a namespace unintentionally.
> 
> v2: Most of the architecture support added by Daniel Lezcano <dlezcano@fr.ibm.com>
> v3: ported to v2.6.36-rc4 by: Eric W. Biederman <ebiederm@xmission.com>
> v4: Moved wiring up of the system call to another patch
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  kernel/nsproxy.c |   37 +++++++++++++++++++++++++++++++++++++
>  1 files changed, 37 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index a05d191..96059d8 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -22,6 +22,9 @@
>  #include <linux/pid_namespace.h>
>  #include <net/net_namespace.h>
>  #include <linux/ipc_namespace.h>
> +#include <linux/proc_fs.h>
> +#include <linux/file.h>
> +#include <linux/syscalls.h>
> 
>  static struct kmem_cache *nsproxy_cachep;
> 
> @@ -233,6 +236,40 @@ void exit_task_namespaces(struct task_struct *p)
>  	switch_task_namespaces(p, NULL);
>  }
> 
> +SYSCALL_DEFINE2(setns, int, fd, int, nstype)
> +{
> +	const struct proc_ns_operations *ops;
> +	struct task_struct *tsk = current;
> +	struct nsproxy *new_nsproxy;
> +	struct proc_inode *ei;
> +	struct file *file;
> +	int err;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	file = proc_ns_fget(fd);
> +	if (IS_ERR(file))
> +		return PTR_ERR(file);
> +
> +	err = -EINVAL;
> +	ei = PROC_I(file->f_dentry->d_inode);
> +	ops = ei->ns_ops;
> +	if (nstype && (ops->type != nstype))
> +		goto out;
> +
> +	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);

Doesn't this need some error checking like:

	if (IS_ERR(new_nsproxy)) {
		err = PTR_ERR(new_nsproxy);
		goto out;
	}


> +	err = ops->install(new_nsproxy, ei->ns);
> +	if (err) {
> +		free_nsproxy(new_nsproxy);
> +		goto out;
> +	}
> +	switch_task_namespaces(tsk, new_nsproxy);
> +out:
> +	fput(file);
> +	return err;
> +}
> +
>  static int __init nsproxy_cache_init(void)
>  {
>  	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
> -- 
> 1.6.5.2.143.g8cc62
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
