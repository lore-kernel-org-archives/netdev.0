From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net (v2)
Date: Thu, 06 Mar 2008 19:45:12 +0300
Message-ID: <47D01F98.5010609@openvz.org>
References: <47CFB6CA.8090001@openvz.org> <1204821325.1397.298.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	James Morris <jmorris@namei.org>,
	Eric Paris <eparis@parisplace.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42233 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbYCFQrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 11:47:19 -0500
In-Reply-To: <1204821325.1397.298.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Smalley wrote:
> On Thu, 2008-03-06 at 12:18 +0300, Pavel Emelyanov wrote:
>> Current /proc/net is done with so called "shadows", but current
>> implementation is broken and has little chances to get fixed.
>>
>> The problem is that dentries subtree of /proc/net directory has
>> fancy revalidation rules to make processes living in different
>> net namespaces see different entries in /proc/net subtree, but
>> currently, tasks see in the /proc/net subdir the contents of any
>> other namespace, depending on who opened the file first.
>>
>> The proposed fix is to turn /proc/net into a symlink, which points
>> to /proc/self/net, which in turn shows what previously was in
>> /proc/net - the network-related info, from the net namespace the
>> appropriate task lives in.
>>
>> # ls -l /proc/net
>> lrwxrwxrwx  1 root root 8 Mar  5 15:17 /proc/net -> self/net
>>
>> In other words - this behaves like /proc/mounts, but unlike
>> "mounts", "net" is not a file, but a directory.
>>
>> Fixed a task_struct leak in get_proc_task_net, pointed out by Paul.
> 
> Does this break SELinux labeling of /proc/net inodes and thus its access
> controls on them?

It should not, since the proc_dir_etries are still organized in
a required hierarchy.

>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>
>> ---
>>
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index 96ee899..cc43cf0 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -2274,6 +2274,7 @@ static const struct pid_entry tgid_base_stuff[] = {
>>  	DIR("task",       S_IRUGO|S_IXUGO, task),
>>  	DIR("fd",         S_IRUSR|S_IXUSR, fd),
>>  	DIR("fdinfo",     S_IRUSR|S_IXUSR, fdinfo),
>> +	DIR("net",        S_IRUGO|S_IXUSR, net),
>>  	REG("environ",    S_IRUSR, environ),
>>  	INF("auxv",       S_IRUSR, pid_auxv),
>>  	ONE("status",     S_IRUGO, pid_status),
>> diff --git a/fs/proc/generic.c b/fs/proc/generic.c
>> index 68971e6..a36ad3c 100644
>> --- a/fs/proc/generic.c
>> +++ b/fs/proc/generic.c
>> @@ -377,15 +377,14 @@ static struct dentry_operations proc_dentry_operations =
>>   * Don't create negative dentries here, return -ENOENT by hand
>>   * instead.
>>   */
>> -struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nameidata *nd)
>> +struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *dir,
>> +		struct dentry *dentry)
>>  {
>>  	struct inode *inode = NULL;
>> -	struct proc_dir_entry * de;
>>  	int error = -ENOENT;
>>  
>>  	lock_kernel();
>>  	spin_lock(&proc_subdir_lock);
>> -	de = PDE(dir);
>>  	if (de) {
>>  		for (de = de->subdir; de ; de = de->next) {
>>  			if (de->namelen != dentry->d_name.len)
>> @@ -393,8 +392,6 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
>>  			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
>>  				unsigned int ino;
>>  
>> -				if (de->shadow_proc)
>> -					de = de->shadow_proc(current, de);
>>  				ino = de->low_ino;
>>  				de_get(de);
>>  				spin_unlock(&proc_subdir_lock);
>> @@ -417,6 +414,12 @@ out_unlock:
>>  	return ERR_PTR(error);
>>  }
>>  
>> +struct dentry *proc_lookup(struct inode *dir, struct dentry *dentry,
>> +		struct nameidata *nd)
>> +{
>> +	return proc_lookup_de(PDE(dir), dir, dentry);
>> +}
>> +
>>  /*
>>   * This returns non-zero if at EOF, so that the /proc
>>   * root directory can use this and check if it should
>> @@ -426,10 +429,9 @@ out_unlock:
>>   * value of the readdir() call, as long as it's non-negative
>>   * for success..
>>   */
>> -int proc_readdir(struct file * filp,
>> -	void * dirent, filldir_t filldir)
>> +int proc_readdir_de(struct proc_dir_entry *de, struct file *filp, void *dirent,
>> +		filldir_t filldir)
>>  {
>> -	struct proc_dir_entry * de;
>>  	unsigned int ino;
>>  	int i;
>>  	struct inode *inode = filp->f_path.dentry->d_inode;
>> @@ -438,7 +440,6 @@ int proc_readdir(struct file * filp,
>>  	lock_kernel();
>>  
>>  	ino = inode->i_ino;
>> -	de = PDE(inode);
>>  	if (!de) {
>>  		ret = -EINVAL;
>>  		goto out;
>> @@ -499,6 +500,13 @@ out:	unlock_kernel();
>>  	return ret;	
>>  }
>>  
>> +int proc_readdir(struct file *filp, void *dirent, filldir_t filldir)
>> +{
>> +	struct inode *inode = filp->f_path.dentry->d_inode;
>> +
>> +	return proc_readdir_de(PDE(inode), filp, dirent, filldir);
>> +}
>> +
>>  /*
>>   * These are the generic /proc directory operations. They
>>   * use the in-memory "struct proc_dir_entry" tree to parse
>> diff --git a/fs/proc/internal.h b/fs/proc/internal.h
>> index 1c81c8f..bc72f5c 100644
>> --- a/fs/proc/internal.h
>> +++ b/fs/proc/internal.h
>> @@ -64,6 +64,8 @@ extern const struct file_operations proc_numa_maps_operations;
>>  extern const struct file_operations proc_smaps_operations;
>>  extern const struct file_operations proc_clear_refs_operations;
>>  extern const struct file_operations proc_pagemap_operations;
>> +extern const struct file_operations proc_net_operations;
>> +extern const struct inode_operations proc_net_inode_operations;
>>  
>>  void free_proc_entry(struct proc_dir_entry *de);
>>  
>> @@ -83,3 +85,8 @@ static inline int proc_fd(struct inode *inode)
>>  {
>>  	return PROC_I(inode)->fd;
>>  }
>> +
>> +struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *ino,
>> +		struct dentry *dentry);
>> +int proc_readdir_de(struct proc_dir_entry *de, struct file *filp, void *dirent,
>> +		filldir_t filldir);
>> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
>> index 14e9b5a..18d413c 100644
>> --- a/fs/proc/proc_net.c
>> +++ b/fs/proc/proc_net.c
>> @@ -63,6 +63,63 @@ int seq_release_net(struct inode *ino, struct file *f)
>>  }
>>  EXPORT_SYMBOL_GPL(seq_release_net);
>>  
>> +static struct net *get_proc_task_net(struct inode *dir)
>> +{
>> +	struct task_struct *task;
>> +	struct nsproxy *ns;
>> +	struct net *net = NULL;
>> +
>> +	rcu_read_lock();
>> +	task = pid_task(proc_pid(dir), PIDTYPE_PID);
>> +	if (task != NULL) {
>> +		ns = task_nsproxy(task);
>> +		if (ns != NULL)
>> +			net = get_net(ns->net_ns);
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	return net;
>> +}
>> +
>> +static struct dentry *proc_tgid_net_lookup(struct inode *dir,
>> +		struct dentry *dentry, struct nameidata *nd)
>> +{
>> +	struct dentry *de;
>> +	struct net *net;
>> +
>> +	de = ERR_PTR(-ENOENT);
>> +	net = get_proc_task_net(dir);
>> +	if (net != NULL) {
>> +		de = proc_lookup_de(net->proc_net, dir, dentry);
>> +		put_net(net);
>> +	}
>> +	return de;
>> +}
>> +
>> +const struct inode_operations proc_net_inode_operations = {
>> +	.lookup		= proc_tgid_net_lookup,
>> +};
>> +
>> +static int proc_tgid_net_readdir(struct file *filp, void *dirent,
>> +		filldir_t filldir)
>> +{
>> +	int ret;
>> +	struct net *net;
>> +
>> +	ret = -EINVAL;
>> +	net = get_proc_task_net(filp->f_path.dentry->d_inode);
>> +	if (net != NULL) {
>> +		ret = proc_readdir_de(net->proc_net, filp, dirent, filldir);
>> +		put_net(net);
>> +	}
>> +	return ret;
>> +}
>> +
>> +const struct file_operations proc_net_operations = {
>> +	.read		= generic_read_dir,
>> +	.readdir	= proc_tgid_net_readdir,
>> +};
>> +
>>  
>>  struct proc_dir_entry *proc_net_fops_create(struct net *net,
>>  	const char *name, mode_t mode, const struct file_operations *fops)
>> @@ -83,14 +140,6 @@ struct net *get_proc_net(const struct inode *inode)
>>  }
>>  EXPORT_SYMBOL_GPL(get_proc_net);
>>  
>> -static struct proc_dir_entry *shadow_pde;
>> -
>> -static struct proc_dir_entry *proc_net_shadow(struct task_struct *task,
>> -						struct proc_dir_entry *de)
>> -{
>> -	return task->nsproxy->net_ns->proc_net;
>> -}
>> -
>>  struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
>>  		struct proc_dir_entry *parent)
>>  {
>> @@ -104,45 +153,35 @@ EXPORT_SYMBOL_GPL(proc_net_mkdir);
>>  
>>  static __net_init int proc_net_ns_init(struct net *net)
>>  {
>> -	struct proc_dir_entry *root, *netd, *net_statd;
>> +	struct proc_dir_entry *netd, *net_statd;
>>  	int err;
>>  
>>  	err = -ENOMEM;
>> -	root = kzalloc(sizeof(*root), GFP_KERNEL);
>> -	if (!root)
>> +	netd = kzalloc(sizeof(*netd), GFP_KERNEL);
>> +	if (!netd)
>>  		goto out;
>>  
>> -	err = -EEXIST;
>> -	netd = proc_net_mkdir(net, "net", root);
>> -	if (!netd)
>> -		goto free_root;
>> +	netd->data = net;
>>  
>>  	err = -EEXIST;
>>  	net_statd = proc_net_mkdir(net, "stat", netd);
>>  	if (!net_statd)
>>  		goto free_net;
>>  
>> -	root->data = net;
>> -
>> -	net->proc_net_root = root;
>>  	net->proc_net = netd;
>>  	net->proc_net_stat = net_statd;
>> -	err = 0;
>> +	return 0;
>>  
>> +free_net:
>> +	kfree(netd);
>>  out:
>>  	return err;
>> -free_net:
>> -	remove_proc_entry("net", root);
>> -free_root:
>> -	kfree(root);
>> -	goto out;
>>  }
>>  
>>  static __net_exit void proc_net_ns_exit(struct net *net)
>>  {
>>  	remove_proc_entry("stat", net->proc_net);
>> -	remove_proc_entry("net", net->proc_net_root);
>> -	kfree(net->proc_net_root);
>> +	kfree(net->proc_net);
>>  }
>>  
>>  static struct pernet_operations __net_initdata proc_net_ns_ops = {
>> @@ -152,8 +191,7 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
>>  
>>  int __init proc_net_init(void)
>>  {
>> -	shadow_pde = proc_mkdir("net", NULL);
>> -	shadow_pde->shadow_proc = proc_net_shadow;
>> +	proc_symlink("net", NULL, "self/net");
>>  
>>  	return register_pernet_subsys(&proc_net_ns_ops);
>>  }
>> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
>> index d9a9e71..9b6c935 100644
>> --- a/include/linux/proc_fs.h
>> +++ b/include/linux/proc_fs.h
>> @@ -50,8 +50,6 @@ typedef	int (read_proc_t)(char *page, char **start, off_t off,
>>  typedef	int (write_proc_t)(struct file *file, const char __user *buffer,
>>  			   unsigned long count, void *data);
>>  typedef int (get_info_t)(char *, char **, off_t, int);
>> -typedef struct proc_dir_entry *(shadow_proc_t)(struct task_struct *task,
>> -						struct proc_dir_entry *pde);
>>  
>>  struct proc_dir_entry {
>>  	unsigned int low_ino;
>> @@ -82,7 +80,6 @@ struct proc_dir_entry {
>>  	int pde_users;	/* number of callers into module in progress */
>>  	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
>>  	struct completion *pde_unload_completion;
>> -	shadow_proc_t *shadow_proc;
>>  };
>>  
>>  struct kcore_list {
>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
>> index 28738b7..923f2b8 100644
>> --- a/include/net/net_namespace.h
>> +++ b/include/net/net_namespace.h
>> @@ -31,7 +31,6 @@ struct net {
>>  
>>  	struct proc_dir_entry 	*proc_net;
>>  	struct proc_dir_entry 	*proc_net_stat;
>> -	struct proc_dir_entry 	*proc_net_root;
>>  
>>  	struct list_head	sysctl_table_headers;
>>  
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

