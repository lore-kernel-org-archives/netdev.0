From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH net-next 4/4] selinux: bpf: Add addtional check for bpf
 object file receive
Date: Thu, 05 Oct 2017 14:26:51 -0400
Message-ID: <1507228011.27146.20.camel@tycho.nsa.gov>
References: <20171004182932.140028-1-chenbofeng.kernel@gmail.com>
         <20171004182932.140028-5-chenbofeng.kernel@gmail.com>
         <1507210621.27146.7.camel@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Chenbo Feng <fengc@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Lorenzo Colitti <lorenzo@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1507210621.27146.7.camel@tycho.nsa.gov>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-05 at 09:37 -0400, Stephen Smalley wrote:
> On Wed, 2017-10-04 at 11:29 -0700, Chenbo Feng wrote:
> > From: Chenbo Feng <fengc@google.com>
> > 
> > Introduce a bpf object related check when sending and receiving
> > files
> > through unix domain socket as well as binder. It checks if the
> > receiving
> > process have privilege to read/write the bpf map or use the bpf
> > program.
> > This check is necessary because the bpf maps and programs are using
> > a
> > anonymous inode as their shared inode so the normal way of checking
> > the
> > files and sockets when passing between processes cannot work
> > properly
> > on
> > eBPF object. This check only works when the BPF_SYSCALL is
> > configured.
> > 
> > Signed-off-by: Chenbo Feng <fengc@google.com>
> > ---
> >  include/linux/bpf.h      |  3 +++
> >  kernel/bpf/syscall.c     |  4 ++--
> >  security/selinux/hooks.c | 57
> > +++++++++++++++++++++++++++++++++++++++++++++++-
> >  3 files changed, 61 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> > index d757ea3f2228..ac8428a36d56 100644
> > --- a/include/linux/bpf.h
> > +++ b/include/linux/bpf.h
> > @@ -250,6 +250,9 @@ int bpf_prog_test_run_skb(struct bpf_prog
> > *prog,
> > const union bpf_attr *kattr,
> >  #ifdef CONFIG_BPF_SYSCALL
> >  DECLARE_PER_CPU(int, bpf_prog_active);
> >  
> > +extern const struct file_operations bpf_map_fops;
> > +extern const struct file_operations bpf_prog_fops;
> > +
> >  #define BPF_PROG_TYPE(_id, _ops) \
> >  	extern const struct bpf_verifier_ops _ops;
> >  #define BPF_MAP_TYPE(_id, _ops) \
> > diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> > index 58ff769d58ab..5789a5359f0a 100644
> > --- a/kernel/bpf/syscall.c
> > +++ b/kernel/bpf/syscall.c
> > @@ -313,7 +313,7 @@ static ssize_t bpf_dummy_write(struct file
> > *filp,
> > const char __user *buf,
> >  	return -EINVAL;
> >  }
> >  
> > -static const struct file_operations bpf_map_fops = {
> > +const struct file_operations bpf_map_fops = {
> >  #ifdef CONFIG_PROC_FS
> >  	.show_fdinfo	= bpf_map_show_fdinfo,
> >  #endif
> > @@ -965,7 +965,7 @@ static void bpf_prog_show_fdinfo(struct
> > seq_file
> > *m, struct file *filp)
> >  }
> >  #endif
> >  
> > -static const struct file_operations bpf_prog_fops = {
> > +const struct file_operations bpf_prog_fops = {
> >  #ifdef CONFIG_PROC_FS
> >  	.show_fdinfo	= bpf_prog_show_fdinfo,
> >  #endif
> > diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> > index 41aba4e3d57c..381474ce3216 100644
> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -1847,6 +1847,7 @@ static int file_has_perm(const struct cred
> > *cred,
> >  
> >  	/* av is zero if only checking access to the descriptor.
> > */
> >  	rc = 0;
> > +
> >  	if (av)
> >  		rc = inode_has_perm(cred, inode, av, &ad);
> >  
> > @@ -2142,6 +2143,10 @@ static int
> > selinux_binder_transfer_binder(struct task_struct *from,
> >  			    NULL);
> >  }
> >  
> > +#ifdef CONFIG_BPF_SYSCALL
> > +static int bpf_fd_pass(struct file *file, u32 sid);
> > +#endif
> > +
> >  static int selinux_binder_transfer_file(struct task_struct *from,
> >  					struct task_struct *to,
> >  					struct file *file)
> > @@ -2165,6 +2170,12 @@ static int
> > selinux_binder_transfer_file(struct
> > task_struct *from,
> >  			return rc;
> >  	}
> >  
> > +#ifdef CONFIG_BPF_SYSCALL
> > +	rc = bpf_fd_pass(file, sid);
> > +	if (rc)
> > +		return rc;
> > +#endif
> > +
> >  	if (unlikely(IS_PRIVATE(d_backing_inode(dentry))))
> >  		return 0;
> >  
> > @@ -3735,8 +3746,18 @@ static int
> > selinux_file_send_sigiotask(struct
> > task_struct *tsk,
> >  static int selinux_file_receive(struct file *file)
> >  {
> >  	const struct cred *cred = current_cred();
> > +	int rc;
> > +
> > +	rc = file_has_perm(cred, file, file_to_av(file));
> > +	if (rc)
> > +		goto out;
> > +
> > +#ifdef CONFIG_BPF_SYSCALL
> > +	rc = bpf_fd_pass(file, cred_sid(sid));
> > +#endif
> >  
> > -	return file_has_perm(cred, file, file_to_av(file));
> > +out:
> > +	return rc;
> >  }
> >  
> >  static int selinux_file_open(struct file *file, const struct cred
> > *cred)
> > @@ -6288,6 +6309,40 @@ static u32 bpf_map_fmode_to_av(fmode_t
> > fmode)
> >  	return av;
> >  }
> >  
> > +/* This function will check the file pass through unix socket or
> > binder to see
> > + * if it is a bpf related object. And apply correspinding checks
> > on
> > the bpf
> > + * object based on the type. The bpf maps and programs, not like
> > other files and
> > + * socket, are using a shared anonymous inode inside the kernel as
> > their inode.
> > + * So checking that inode cannot identify if the process have
> > privilege to
> > + * access the bpf object and that's why we have to add this
> > additional check in
> > + * selinux_file_receive and selinux_binder_transfer_files.
> > + */
> > +static int bpf_fd_pass(struct file *file, u32 sid)
> > +{
> > +	struct bpf_security_struct *bpfsec;
> > +	u32 sid = cred_sid(cred);
> > +	struct bpf_prog *prog;
> > +	struct bpf_map *map;
> > +	int ret;
> > +
> > +	if (file->f_op == &bpf_map_fops) {
> > +		map = file->private_data;
> > +		bpfsec = map->security;
> > +		ret = avc_has_perm(sid, bpfsec->sid,
> > SECCLASS_BPF_MAP,
> > +				   bpf_map_fmode_to_av(file-
> > > f_mode), NULL);
> > 
> > +		if (ret)
> > +			return ret;
> > +	} else if (file->f_op == &bpf_prog_fops) {
> > +		prog = file->private_data;
> > +		bpfsec = prog->aux->security;
> > +		ret = avc_has_perm(sid, bpfsec->sid,
> > SECCLASS_BPF_PROG,
> > +				   BPF_PROG__USE, NULL);
> > +		if (ret)
> > +			return ret;
> > +	}
> > +	return 0;
> > +}
> 
> When the struct file is allocated for the bpf map and/or prog, you
> could call a hook at that time passing both, and note the fact that
> it
> is a bpf map/prog in the file_security_struct.  Then, on
> file_receive/binder_transfer_file, you could apply the appropriate
> checking.  Further, if we know that the file is always allocated at
> the
> same point as the bpf map/prog, then they should have the same SID
> (i.e
> fsec->sid should be the same as bpfsec->sid), so we shouldn't even
> need
> to dereference the bpf map/prog.  Unless I'm missing something.
> 
> Also, are we concerned about doing the same in
> flush_unauthorized_files(), for inheriting descriptors across a
> context-changing execve?  Should this checking actually go into
> file_has_perm() itself so it is always applied on any use of the
> struct
> file?
> 
> Lastly, do we need/want these checks if sid == bpfsec->sid?  We skip
> FD__USE in the case where sid == fsec->sid, for example.

BTW, the prog use check seems slightly redundant in that we will
already check fd use permission.  So we only really need it if you want
to allow fd use but deny prog use.  The map read/write checks are more
granular than fd use, so I guess we can't get rid of those.

> 
> > +
> >  static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
> >  {
> >  	u32 sid = current_sid();
