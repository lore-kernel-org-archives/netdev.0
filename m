From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH net-next v5 5/5] selinux: bpf: Add addtional check for
 bpf object file receive
Date: Mon, 16 Oct 2017 12:34:06 -0400
Message-ID: <1508171646.2722.7.camel@tycho.nsa.gov>
References: <20171012205510.36028-1-chenbofeng.kernel@gmail.com>
         <20171012205510.36028-6-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhil19pa12.eemsg.mail.mil ([214.24.21.85]:47694 "EHLO
        uhil19pa12.eemsg.mail.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753122AbdJPQ3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:29:20 -0400
In-Reply-To: <20171012205510.36028-6-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-10-12 at 13:55 -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Introduce a bpf object related check when sending and receiving files
> through unix domain socket as well as binder. It checks if the
> receiving
> process have privilege to read/write the bpf map or use the bpf
> program.
> This check is necessary because the bpf maps and programs are using a
> anonymous inode as their shared inode so the normal way of checking
> the
> files and sockets when passing between processes cannot work properly
> on
> eBPF object. This check only works when the BPF_SYSCALL is
> configured.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>
> ---
>  include/linux/bpf.h      |  3 +++
>  kernel/bpf/syscall.c     |  4 ++--
>  security/selinux/hooks.c | 49
> ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 54 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 225740688ab7..81d6c01b8825 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -285,6 +285,9 @@ int bpf_prog_array_copy_to_user(struct
> bpf_prog_array __rcu *progs,
>  #ifdef CONFIG_BPF_SYSCALL
>  DECLARE_PER_CPU(int, bpf_prog_active);
>  
> +extern const struct file_operations bpf_map_fops;
> +extern const struct file_operations bpf_prog_fops;
> +
>  #define BPF_PROG_TYPE(_id, _ops) \
>  	extern const struct bpf_verifier_ops _ops;
>  #define BPF_MAP_TYPE(_id, _ops) \
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index d3e152e282d8..8bdb98aa7f34 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -313,7 +313,7 @@ static ssize_t bpf_dummy_write(struct file *filp,
> const char __user *buf,
>  	return -EINVAL;
>  }
>  
> -static const struct file_operations bpf_map_fops = {
> +const struct file_operations bpf_map_fops = {
>  #ifdef CONFIG_PROC_FS
>  	.show_fdinfo	= bpf_map_show_fdinfo,
>  #endif
> @@ -967,7 +967,7 @@ static void bpf_prog_show_fdinfo(struct seq_file
> *m, struct file *filp)
>  }
>  #endif
>  
> -static const struct file_operations bpf_prog_fops = {
> +const struct file_operations bpf_prog_fops = {
>  #ifdef CONFIG_PROC_FS
>  	.show_fdinfo	= bpf_prog_show_fdinfo,
>  #endif
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 12cf7de8cbed..ef7e5c1de640 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -1815,6 +1815,10 @@ static inline int file_path_has_perm(const
> struct cred *cred,
>  	return inode_has_perm(cred, file_inode(file), av, &ad);
>  }
>  
> +#ifdef CONFIG_BPF_SYSCALL
> +static int bpf_fd_pass(struct file *file, u32 sid);
> +#endif
> +
>  /* Check whether a task can use an open file descriptor to
>     access an inode in a given way.  Check access to the
>     descriptor itself, and then use dentry_has_perm to
> @@ -1845,6 +1849,12 @@ static int file_has_perm(const struct cred
> *cred,
>  			goto out;
>  	}
>  
> +#ifdef CONFIG_BPF_SYSCALL
> +	rc = bpf_fd_pass(file, cred_sid(cred));
> +	if (rc)
> +		return rc;
> +#endif
> +
>  	/* av is zero if only checking access to the descriptor. */
>  	rc = 0;
>  	if (av)
> @@ -2165,6 +2175,12 @@ static int selinux_binder_transfer_file(struct
> task_struct *from,
>  			return rc;
>  	}
>  
> +#ifdef CONFIG_BPF_SYSCALL
> +	rc = bpf_fd_pass(file, sid);
> +	if (rc)
> +		return rc;
> +#endif
> +
>  	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
>  		return 0;
>  
> @@ -6288,6 +6304,39 @@ static u32 bpf_map_fmode_to_av(fmode_t fmode)
>  	return av;
>  }
>  
> +/* This function will check the file pass through unix socket or
> binder to see
> + * if it is a bpf related object. And apply correspinding checks on
> the bpf
> + * object based on the type. The bpf maps and programs, not like
> other files and
> + * socket, are using a shared anonymous inode inside the kernel as
> their inode.
> + * So checking that inode cannot identify if the process have
> privilege to
> + * access the bpf object and that's why we have to add this
> additional check in
> + * selinux_file_receive and selinux_binder_transfer_files.
> + */
> +static int bpf_fd_pass(struct file *file, u32 sid)
> +{
> +	struct bpf_security_struct *bpfsec;
> +	struct bpf_prog *prog;
> +	struct bpf_map *map;
> +	int ret;
> +
> +	if (file->f_op == &bpf_map_fops) {
> +		map = file->private_data;
> +		bpfsec = map->security;
> +		ret = avc_has_perm(sid, bpfsec->sid,
> SECCLASS_BPF_MAP,
> +				   bpf_map_fmode_to_av(file-
> >f_mode), NULL);
> +		if (ret)
> +			return ret;
> +	} else if (file->f_op == &bpf_prog_fops) {
> +		prog = file->private_data;
> +		bpfsec = prog->aux->security;
> +		ret = avc_has_perm(sid, bpfsec->sid,
> SECCLASS_BPF_PROG,
> +				   BPF__PROG_RUN, NULL);
> +		if (ret)
> +			return ret;
> +	}
> +	return 0;
> +}

My apologies, I should have caught this earlier, but you didn't update
the class/permission symbols used above when you re-spun patch 4/5 with
a single bpf class with distinct permissions defined.

Please, ensure that the entire series compiles and works before
sending.

Also, you likely should be cc'ing linux-security-module mailing list
and selinux mailing list; I thought you were doing so on earlier
versions.

> +
>  static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
>  {
>  	u32 sid = current_sid();
