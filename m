From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Wed, 5 Mar 2008 11:15:01 -0800
Message-ID: <20080305191501.GF8728@linux.vnet.ibm.com>
References: <47CE8FF7.7000701@openvz.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60934 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbYCETPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 14:15:11 -0500
Content-Disposition: inline
In-Reply-To: <47CE8FF7.7000701@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 03:20:07PM +0300, Pavel Emelyanov wrote:
> Current /proc/net is done with so called "shadows", but current
> implementation is broken and has little chances to get fixed.
> 
> The problem is that dentries subtree of /proc/net directory has
> fancy revalidation rules to make processes living in different
> net namespaces see different entries in /proc/net subtree, but
> currently, tasks see in the /proc/net subdir the contents of any
> other namespace, depending on who opened the file first.
> 
> The proposed fix is to turn /proc/net into a symlink, which points
> to /proc/self/net, which in turn shows what previously was in
> /proc/net - the network-related info, from the net namespace the
> appropriate task lives in.
> 
> # ls -l /proc/net
> lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net
> 
> In other words - this behaves like /proc/mounts, but unlike
> "mounts", "net" is not a file, but a directory.

One question below for get_proc_task_net() -- I don't see how the
reference to a task struct is released.

						Thanx, Paul

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 96ee899..cc43cf0 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -2274,6 +2274,7 @@ static const struct pid_entry tgid_base_stuff[] = {
>  	DIR("task",       S_IRUGO|S_IXUGO, task),
>  	DIR("fd",         S_IRUSR|S_IXUSR, fd),
>  	DIR("fdinfo",     S_IRUSR|S_IXUSR, fdinfo),
> +	DIR("net",        S_IRUGO|S_IXUSR, net),
>  	REG("environ",    S_IRUSR, environ),
>  	INF("auxv",       S_IRUSR, pid_auxv),
>  	ONE("status",     S_IRUGO, pid_status),
> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
> index 68971e6..a36ad3c 100644
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -377,15 +377,14 @@ static struct dentry_operations proc_dentry_operations =
>   * Don't create negative dentries here, return -ENOENT by hand
>   * instead.
>   */
> -struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nameidata *nd)
> +struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *dir,
> +		struct dentry *dentry)
>  {
>  	struct inode *inode = NULL;
> -	struct proc_dir_entry * de;
>  	int error = -ENOENT;
> 
>  	lock_kernel();
>  	spin_lock(&proc_subdir_lock);
> -	de = PDE(dir);
>  	if (de) {
>  		for (de = de->subdir; de ; de = de->next) {
>  			if (de->namelen != dentry->d_name.len)
> @@ -393,8 +392,6 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
>  			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
>  				unsigned int ino;
> 
> -				if (de->shadow_proc)
> -					de = de->shadow_proc(current, de);
>  				ino = de->low_ino;
>  				de_get(de);
>  				spin_unlock(&proc_subdir_lock);
> @@ -417,6 +414,12 @@ out_unlock:
>  	return ERR_PTR(error);
>  }
> 
> +struct dentry *proc_lookup(struct inode *dir, struct dentry *dentry,
> +		struct nameidata *nd)
> +{
> +	return proc_lookup_de(PDE(dir), dir, dentry);
> +}
> +
>  /*
>   * This returns non-zero if at EOF, so that the /proc
>   * root directory can use this and check if it should
> @@ -426,10 +429,9 @@ out_unlock:
>   * value of the readdir() call, as long as it's non-negative
>   * for success..
>   */
> -int proc_readdir(struct file * filp,
> -	void * dirent, filldir_t filldir)
> +int proc_readdir_de(struct proc_dir_entry *de, struct file *filp, void *dirent,
> +		filldir_t filldir)
>  {
> -	struct proc_dir_entry * de;
>  	unsigned int ino;
>  	int i;
>  	struct inode *inode = filp->f_path.dentry->d_inode;
> @@ -438,7 +440,6 @@ int proc_readdir(struct file * filp,
>  	lock_kernel();
> 
>  	ino = inode->i_ino;
> -	de = PDE(inode);
>  	if (!de) {
>  		ret = -EINVAL;
>  		goto out;
> @@ -499,6 +500,13 @@ out:	unlock_kernel();
>  	return ret;	
>  }
> 
> +int proc_readdir(struct file *filp, void *dirent, filldir_t filldir)
> +{
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +
> +	return proc_readdir_de(PDE(inode), filp, dirent, filldir);
> +}
> +
>  /*
>   * These are the generic /proc directory operations. They
>   * use the in-memory "struct proc_dir_entry" tree to parse
> diff --git a/fs/proc/internal.h b/fs/proc/internal.h
> index 1c81c8f..bc72f5c 100644
> --- a/fs/proc/internal.h
> +++ b/fs/proc/internal.h
> @@ -64,6 +64,8 @@ extern const struct file_operations proc_numa_maps_operations;
>  extern const struct file_operations proc_smaps_operations;
>  extern const struct file_operations proc_clear_refs_operations;
>  extern const struct file_operations proc_pagemap_operations;
> +extern const struct file_operations proc_net_operations;
> +extern const struct inode_operations proc_net_inode_operations;
> 
>  void free_proc_entry(struct proc_dir_entry *de);
> 
> @@ -83,3 +85,8 @@ static inline int proc_fd(struct inode *inode)
>  {
>  	return PROC_I(inode)->fd;
>  }
> +
> +struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *ino,
> +		struct dentry *dentry);
> +int proc_readdir_de(struct proc_dir_entry *de, struct file *filp, void *dirent,
> +		filldir_t filldir);
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index 14e9b5a..3372c2e 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -63,6 +63,63 @@ int seq_release_net(struct inode *ino, struct file *f)
>  }
>  EXPORT_SYMBOL_GPL(seq_release_net);
> 
> +static struct net *get_proc_task_net(struct inode *dir)
> +{
> +	struct task_struct *task;
> +	struct nsproxy *ns;
> +	struct net *net = NULL;
> +
> +	rcu_read_lock();
> +	task = get_proc_task(dir);

This implies a get_task_struct(), as get_proc_task() invokes get_proc_task()
which invokes get_pid_task() which invokes get_task_struct().

I don't see the corresponding put_task_struct() -- what am I missing here?

> +	if (task != NULL) {
> +		ns = task_nsproxy(task);
> +		if (ns != NULL)
> +			net = get_net(ns->net_ns);
> +	}
> +	rcu_read_unlock();
> +
> +	return net;
> +}
> +
> +static struct dentry *proc_tgid_net_lookup(struct inode *dir,
> +		struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct dentry *de;
> +	struct net *net;
> +
> +	de = ERR_PTR(-ENOENT);
> +	net = get_proc_task_net(dir);
> +	if (net != NULL) {
> +		de = proc_lookup_de(net->proc_net, dir, dentry);
> +		put_net(net);
> +	}
> +	return de;
> +}
> +
> +const struct inode_operations proc_net_inode_operations = {
> +	.lookup		= proc_tgid_net_lookup,
> +};
> +
> +static int proc_tgid_net_readdir(struct file *filp, void *dirent,
> +		filldir_t filldir)
> +{
> +	int ret;
> +	struct net *net;
> +
> +	ret = -EINVAL;
> +	net = get_proc_task_net(filp->f_path.dentry->d_inode);
> +	if (net != NULL) {
> +		ret = proc_readdir_de(net->proc_net, filp, dirent, filldir);
> +		put_net(net);
> +	}
> +	return ret;
> +}
> +
> +const struct file_operations proc_net_operations = {
> +	.read		= generic_read_dir,
> +	.readdir	= proc_tgid_net_readdir,
> +};
> +
> 
>  struct proc_dir_entry *proc_net_fops_create(struct net *net,
>  	const char *name, mode_t mode, const struct file_operations *fops)
> @@ -83,14 +140,6 @@ struct net *get_proc_net(const struct inode *inode)
>  }
>  EXPORT_SYMBOL_GPL(get_proc_net);
> 
> -static struct proc_dir_entry *shadow_pde;
> -
> -static struct proc_dir_entry *proc_net_shadow(struct task_struct *task,
> -						struct proc_dir_entry *de)
> -{
> -	return task->nsproxy->net_ns->proc_net;
> -}
> -
>  struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
>  		struct proc_dir_entry *parent)
>  {
> @@ -104,45 +153,35 @@ EXPORT_SYMBOL_GPL(proc_net_mkdir);
> 
>  static __net_init int proc_net_ns_init(struct net *net)
>  {
> -	struct proc_dir_entry *root, *netd, *net_statd;
> +	struct proc_dir_entry *netd, *net_statd;
>  	int err;
> 
>  	err = -ENOMEM;
> -	root = kzalloc(sizeof(*root), GFP_KERNEL);
> -	if (!root)
> +	netd = kzalloc(sizeof(*netd), GFP_KERNEL);
> +	if (!netd)
>  		goto out;
> 
> -	err = -EEXIST;
> -	netd = proc_net_mkdir(net, "net", root);
> -	if (!netd)
> -		goto free_root;
> +	netd->data = net;
> 
>  	err = -EEXIST;
>  	net_statd = proc_net_mkdir(net, "stat", netd);
>  	if (!net_statd)
>  		goto free_net;
> 
> -	root->data = net;
> -
> -	net->proc_net_root = root;
>  	net->proc_net = netd;
>  	net->proc_net_stat = net_statd;
> -	err = 0;
> +	return 0;
> 
> +free_net:
> +	kfree(netd);
>  out:
>  	return err;
> -free_net:
> -	remove_proc_entry("net", root);
> -free_root:
> -	kfree(root);
> -	goto out;
>  }
> 
>  static __net_exit void proc_net_ns_exit(struct net *net)
>  {
>  	remove_proc_entry("stat", net->proc_net);
> -	remove_proc_entry("net", net->proc_net_root);
> -	kfree(net->proc_net_root);
> +	kfree(net->proc_net);
>  }
> 
>  static struct pernet_operations __net_initdata proc_net_ns_ops = {
> @@ -152,8 +191,7 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
> 
>  int __init proc_net_init(void)
>  {
> -	shadow_pde = proc_mkdir("net", NULL);
> -	shadow_pde->shadow_proc = proc_net_shadow;
> +	proc_symlink("net", NULL, "self/net");
> 
>  	return register_pernet_subsys(&proc_net_ns_ops);
>  }
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index d9a9e71..9b6c935 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -50,8 +50,6 @@ typedef	int (read_proc_t)(char *page, char **start, off_t off,
>  typedef	int (write_proc_t)(struct file *file, const char __user *buffer,
>  			   unsigned long count, void *data);
>  typedef int (get_info_t)(char *, char **, off_t, int);
> -typedef struct proc_dir_entry *(shadow_proc_t)(struct task_struct *task,
> -						struct proc_dir_entry *pde);
> 
>  struct proc_dir_entry {
>  	unsigned int low_ino;
> @@ -82,7 +80,6 @@ struct proc_dir_entry {
>  	int pde_users;	/* number of callers into module in progress */
>  	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
>  	struct completion *pde_unload_completion;
> -	shadow_proc_t *shadow_proc;
>  };
> 
>  struct kcore_list {
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index 28738b7..923f2b8 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -31,7 +31,6 @@ struct net {
> 
>  	struct proc_dir_entry 	*proc_net;
>  	struct proc_dir_entry 	*proc_net_stat;
> -	struct proc_dir_entry 	*proc_net_root;
> 
>  	struct list_head	sysctl_table_headers;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
