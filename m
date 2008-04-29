From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 10/10] sysfs: user namespaces: add ns to user_struct
Date: Tue, 29 Apr 2008 12:51:29 -0700
Message-ID: <m17ieg1ltq.fsf@frodo.ebiederm.org>
References: <20080429171015.473938697@theryb.frec.bull.fr>
	<20080429171703.529721456@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43674 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbYD2T7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 15:59:34 -0400
In-Reply-To: <20080429171703.529721456@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Tue, 29 Apr 2008 19:11:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> Add the user_namespace to user_struct.
>
> Add a user_namespace to the sysfs_tag struct.
>
> Mark the /sys/kernel/uids directory to be tagged so that processes in
> different user namespaces can remount /sys and see their own uid
> listings.
>
> Without this patch, having CONFIG_FAIR_SCHED=y makes user namespaces
> unusable, because when you
>   clone(CLONE_NEWUSER)
> it will auto-create the root userid and try to create
> /sys/kernel/uids/0.  Since that already exists from the parent user
> namespace, the create fails, and the clone misleadingly ends up
> returning -ENOMEM.
>
> This patch fixes the issue by allowing each user namespace to remount
> /sys, and having /sys filter the /sys/kernel/uid/ entries by user
> namespace.

There is a lot of promising code in this patch.  This patch appears to
be building up a lot of userns infrastructure that is only indirectly
related to sysfs, and it still appears to have some debugging code
present.  

As a proof of concept patch (which I asked for) this looks good.

I do think this patch should get split into logical changes
and cleaned up a bit before it gets merged into mainline.

More comments inline below.

Eric

> Index: linux-mm/fs/sysfs/mount.c
> ===================================================================
> --- linux-mm.orig/fs/sysfs/mount.c
> +++ linux-mm/fs/sysfs/mount.c
> @@ -17,6 +17,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/init.h>
>  #include <linux/nsproxy.h>
> +#include <linux/user_namespace.h>
>  #include <net/net_namespace.h>
>  
>  #include "sysfs.h"
> @@ -81,6 +82,7 @@ static int sysfs_fill_super(struct super
>  	sb->s_root = root;
>  	sb->s_fs_info = info;
>  	info->tag.net_ns = hold_net(current->nsproxy->net_ns);
> +	info->tag.user_ns = current->nsproxy->user_ns;
>  	return 0;
>  
>  out_err:
> @@ -100,6 +102,8 @@ static int sysfs_test_super(struct super
>  
>  	if (task->nsproxy->net_ns != info->tag.net_ns)
>  		found = 0;
> +	if (task->nsproxy->user_ns != info->tag.user_ns)
> +		found = 0;
>  
>  	return found;
>  }
> @@ -214,6 +218,27 @@ static struct pernet_operations sysfs_ne
>  };
>  #endif
>  
> +#ifdef CONFIG_USER_NS
> +void sysfs_userns_exit(struct user_namespace *user_ns)
> +{
> +	/* Allow the net namespace to go away while sysfs is still mounted. */
> +	struct super_block *sb;
> +	printk(KERN_NOTICE "sysfs: user namespace exiting\n");
Debugging?
> +	mutex_lock(&sysfs_rename_mutex);
> +	sysfs_grab_supers();
> +	mutex_lock(&sysfs_mutex);
> +	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
> +		struct sysfs_super_info *info = sysfs_info(sb);
> +		if (info->tag.user_ns != user_ns)
> +			continue;
> +		info->tag.user_ns = NULL;
> +	}
> +	mutex_unlock(&sysfs_mutex);
> +	sysfs_release_supers();
> +	mutex_unlock(&sysfs_rename_mutex);
> +}
> +#endif
> +
>  int __init sysfs_init(void)
>  {
>  	int err = -ENOMEM;
> Index: linux-mm/include/linux/sched.h
> ===================================================================
> --- linux-mm.orig/include/linux/sched.h
> +++ linux-mm/include/linux/sched.h
> @@ -598,7 +598,7 @@ struct user_struct {
>  
>  	/* Hash table maintenance information */
>  	struct hlist_node uidhash_node;
> -	uid_t uid;
> +	struct k_uid_t uid;

If we are going to go this direction my inclination
is to include an array of a single element in user_struct.

Maybe that makes sense.  I just know we need to talk about
how a user maps into different user namespaces.  As that
is a real concept that really occurs in real filesystems
like nfsv4 and p9fs, and having infrastructure that can
deal with the concept (even if it doesn't support it yet) would be
useful.

>  #endif /* _SYSFS_H_ */
> Index: linux-mm/include/linux/types.h
> ===================================================================
> --- linux-mm.orig/include/linux/types.h
> +++ linux-mm/include/linux/types.h
> @@ -37,6 +37,11 @@ typedef __kernel_gid32_t	gid_t;
>  typedef __kernel_uid16_t        uid16_t;
>  typedef __kernel_gid16_t        gid16_t;
>  
> +struct k_uid_t {
> +	uid_t uid;
> +	struct user_namespace *ns;
> +};

Weird a _t suffix in a structure name.  Usually _t indicates
that something is a typedef.

> +
>  typedef unsigned long		uintptr_t;
>  
>  #ifdef CONFIG_UID16
> Index: linux-mm/include/linux/user_namespace.h
> ===================================================================
> --- linux-mm.orig/include/linux/user_namespace.h
> +++ linux-mm/include/linux/user_namespace.h
> @@ -12,10 +12,15 @@
>  struct user_namespace {
>  	struct kref		kref;
>  	struct hlist_head	uidhash_table[UIDHASH_SZ];
> +	struct kset		*kset;
>  	struct user_struct	*root_user;
>  };
>  
>  extern struct user_namespace init_user_ns;
> +extern int register_user_ns_kobj(struct user_namespace *ns);
> +extern void unregister_user_ns_kobj(struct user_namespace *ns);
> +extern int register_user_ns_kobj(struct user_namespace *ns);
> +extern void unregister_user_ns_kobj(struct user_namespace *ns);
>  
>  #ifdef CONFIG_USER_NS
>  
> Index: linux-mm/kernel/user.c
> ===================================================================
> --- linux-mm.orig/kernel/user.c
> +++ linux-mm/kernel/user.c
> @@ -53,6 +53,10 @@ struct user_struct root_user = {
>  	.files		= ATOMIC_INIT(0),
>  	.sigpending	= ATOMIC_INIT(0),
>  	.locked_shm     = 0,
> +	.uid		= {
> +		.uid = 0,
> +		.ns = &init_user_ns,
> +	},
>  #ifdef CONFIG_USER_SCHED
>  	.tg		= &init_task_group,
>  #endif
> @@ -71,13 +75,23 @@ static void uid_hash_remove(struct user_
>  	hlist_del_init(&up->uidhash_node);
>  }
>  
> -static struct user_struct *uid_hash_find(uid_t uid, struct hlist_head *hashent)
> +int task_user_equiv(struct task_struct *tsk, struct user_struct *u)
> +{
> +	if (tsk->uid != u->uid.uid)
> +		return 0;
> +	if (tsk->nsproxy->user_ns != u->uid.ns)
> +		return 0;
> +	return 1;
> +}
> +
> +static struct user_struct *uid_hash_find(uid_t uid,
> +				struct hlist_head *hashent)
>  {
>  	struct user_struct *user;
>  	struct hlist_node *h;
>  
>  	hlist_for_each_entry(user, h, hashent, uidhash_node) {
> -		if (user->uid == uid) {
> +		if (user->uid.uid == uid) {
>  			atomic_inc(&user->__count);
>  			return user;
>  		}
> @@ -236,6 +250,23 @@ static void uids_release(struct kobject 
>  	return;
>  }
>  
> +static const void *userns_sb_tag(struct sysfs_tag_info *info)
> +{
> +       return info->user_ns;
> +}
> +
> +static const void *userns_kobject_tag(struct kobject *kobj)
> +{
> +       struct user_struct *up;
> +       up = container_of(kobj, struct user_struct, kobj);
> +       return up->uid.ns;
> +}
> +
> +static struct sysfs_tagged_dir_operations userns_tagged_dir_operations = {
> +       .sb_tag = userns_sb_tag,
> +       .kobject_tag = userns_kobject_tag,
> +};
> +
>  static struct kobj_type uids_ktype = {
>  	.sysfs_ops = &kobj_sysfs_ops,
>  	.default_attrs = uids_attributes,
> @@ -246,19 +277,19 @@ static struct kobj_type uids_ktype = {
>  static int uids_user_create(struct user_struct *up)
>  {
>  	struct kobject *kobj = &up->kobj;
> -	int error;
> +	int err;
>  
>  	memset(kobj, 0, sizeof(struct kobject));
>  	kobj->kset = uids_kset;
> -	error = kobject_init_and_add(kobj, &uids_ktype, NULL, "%d", up->uid);
> -	if (error) {
> +	err = kobject_init_and_add(kobj, &uids_ktype, NULL, "%d", up->uid.uid);
> +	if (err) {
>  		kobject_put(kobj);
>  		goto done;
>  	}
>  
>  	kobject_uevent(kobj, KOBJ_ADD);
>  done:
> -	return error;
> +	return err;
>  }
>  
>  /* create these entries in sysfs:
> @@ -271,7 +302,7 @@ int __init uids_sysfs_init(void)
>  	uids_kset = kset_create_and_add("uids", NULL, kernel_kobj);
>  	if (!uids_kset)
>  		return -ENOMEM;
> -
> +	sysfs_enable_tagging(&uids_kset->kobj, &userns_tagged_dir_operations);
>  	return uids_user_create(&root_user);
>  }
>  
> @@ -403,7 +434,8 @@ struct user_struct *alloc_uid(struct use
>  		if (!new)
>  			goto out_unlock;
>  
> -		new->uid = uid;
> +		new->uid.uid = uid;
> +		new->uid.ns = ns;
>  		atomic_set(&new->__count, 1);
>  
>  		if (sched_create_user(new) < 0)
> Index: linux-mm/kernel/user_namespace.c
> ===================================================================
> --- linux-mm.orig/kernel/user_namespace.c
> +++ linux-mm/kernel/user_namespace.c
> @@ -22,7 +22,7 @@ static struct user_namespace *clone_user
>  	struct user_struct *new_user;
>  	int n;
>  
> -	ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
> +	ns = kzalloc(sizeof(struct user_namespace), GFP_KERNEL);
>  	if (!ns)
>  		return ERR_PTR(-ENOMEM);
>  
> @@ -71,6 +71,7 @@ void free_user_ns(struct kref *kref)
>  	struct user_namespace *ns;
>  
>  	ns = container_of(kref, struct user_namespace, kref);
> +	sysfs_userns_exit(ns);
>  	release_uids(ns);
>  	kfree(ns);
>  }
