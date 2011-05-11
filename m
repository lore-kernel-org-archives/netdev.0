From: Nathan Lynch <ntl@pobox.com>
Subject: Re: [PATCH 1/7] ns: proc files for namespace naming policy.
Date: Wed, 11 May 2011 14:20:48 -0500
Message-ID: <1305141667.1236.47.camel@orca.stoopid.dyndns.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
 <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

A few comments on your patch set.


On Fri, 2011-05-06 at 19:24 -0700, Eric W. Biederman wrote:
> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
> index d15aa1b..74b48cf 100644
> --- a/fs/proc/inode.c
> +++ b/fs/proc/inode.c
> @@ -28,6 +28,7 @@ static void proc_evict_inode(struct inode *inode)
>  {
>  	struct proc_dir_entry *de;
>  	struct ctl_table_header *head;
> +	const struct proc_ns_operations *ns_ops;
>  
>  	truncate_inode_pages(&inode->i_data, 0);
>  	end_writeback(inode);
> @@ -44,6 +45,10 @@ static void proc_evict_inode(struct inode *inode)
>  		rcu_assign_pointer(PROC_I(inode)->sysctl, NULL);
>  		sysctl_head_put(head);
>  	}
> +	/* Release any associated namespace */
> +	ns_ops = PROC_I(inode)->ns_ops;
> +	if (ns_ops && ns_ops->put)
> +		ns_ops->put(PROC_I(inode)->ns);

Is it ever valid for ns_ops->put to be null?  If not, I suggest removing
the check.


> diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
> new file mode 100644
> index 0000000..6ae9f07
> --- /dev/null
> +++ b/fs/proc/namespaces.c

...

> +static struct dentry *proc_ns_dir_lookup(struct inode *dir,
> +				struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct dentry *error;
> +	struct task_struct *task = get_proc_task(dir);
> +	const struct proc_ns_operations **entry, **last;
> +	unsigned int len = dentry->d_name.len;
> +
> +	error = ERR_PTR(-ENOENT);
> +
> +	if (!task)
> +		goto out_no_task;
> +
> +	error = ERR_PTR(-EPERM);
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ))
> +		goto out;
> +
> +	last = &ns_entries[ARRAY_SIZE(ns_entries) - 1];
> +	for (entry = ns_entries; entry <= last; entry++) {
> +		if (strlen((*entry)->name) != len)
> +			continue;
> +		if (!memcmp(dentry->d_name.name, (*entry)->name, len))
> +			break;
> +	}
> +	if (entry > last)
> +		goto out;

This returns EPERM when it should return ENOENT?


> +
> +	error = proc_ns_instantiate(dir, dentry, task, *entry);
> +out:
> +	put_task_struct(task);
> +out_no_task:
> +	return error;
> +}

...

> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -250,6 +257,15 @@ kclist_add(struct kcore_list *new, void *addr, size_t size, int type)
>  extern void kclist_add(struct kcore_list *, void *, size_t, int type);
>  #endif
>  
> +struct nsproxy;
> +struct proc_ns_operations {
> +	const char *name;
> +	int type;
> +	void *(*get)(struct task_struct *task);
> +	void (*put)(void *ns);
> +	int (*install)(struct nsproxy *nsproxy, void *ns);
> +};
> +
>  union proc_op {
>  	int (*proc_get_link)(struct inode *, struct path *);
>  	int (*proc_read)(struct task_struct *task, char *page);
> @@ -268,6 +284,8 @@ struct proc_inode {
>  	struct proc_dir_entry *pde;
>  	struct ctl_table_header *sysctl;
>  	struct ctl_table *sysctl_entry;
> +	void *ns;
> +	const struct proc_ns_operations *ns_ops;
>  	struct inode vfs_inode;
>  };

Not that I have any better ideas, but it seems a bit undesirable to
increase the size of proc_inode for this one purpose.
