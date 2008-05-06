From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 11/11] sysfs: user namespaces: add ns to user_struct
Date: Tue, 6 May 2008 14:03:33 -0500
Message-ID: <20080506190333.GB8315@sergelap.austin.ibm.com>
References: <20080506173030.653828076@theryb.frec.bull.fr> <20080506173336.068521615@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:56196 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758735AbYEFTDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 15:03:38 -0400
Content-Disposition: inline
In-Reply-To: <20080506173336.068521615@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Benjamin Thery (benjamin.thery@bull.net):
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
> 
> Signed-off-by: Serge Hallyn <serue@us.ibm.com>

Benjamin,

thanks for reposting.  Please do drop this patch from the set, though.
A slimmer version of it really is needed asap, but this version as
Eric had pointed out has some holdouts from my previous approach, which
I need to drop.

thanks,
-serge

> ---
>  fs/dquot.c                     |    2 -
>  fs/ioprio.c                    |    2 -
>  fs/sysfs/mount.c               |   25 +++++++++++++++++++++
>  include/linux/sched.h          |    3 +-
>  include/linux/sysfs.h          |    9 +++++++
>  include/linux/types.h          |    5 ++++
>  include/linux/user_namespace.h |    5 ++++
>  kernel/user.c                  |   48 ++++++++++++++++++++++++++++++++++-------
>  kernel/user_namespace.c        |    3 +-
>  security/keys/process_keys.c   |   14 +++++------
>  10 files changed, 97 insertions(+), 19 deletions(-)
> 
> Index: linux-vanilla/fs/dquot.c
> ===================================================================
> --- linux-vanilla.orig/fs/dquot.c
> +++ linux-vanilla/fs/dquot.c
> @@ -968,7 +968,7 @@ static void send_warning(const struct dq
>  		MINOR(dquot->dq_sb->s_dev));
>  	if (ret)
>  		goto attr_err_out;
> -	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID, current->user->uid);
> +	ret = nla_put_u64(skb, QUOTA_NL_A_CAUSED_ID, current->user->uid.uid);
>  	if (ret)
>  		goto attr_err_out;
>  	genlmsg_end(skb, msg_head);
> Index: linux-vanilla/fs/ioprio.c
> ===================================================================
> --- linux-vanilla.orig/fs/ioprio.c
> +++ linux-vanilla/fs/ioprio.c
> @@ -224,7 +224,7 @@ asmlinkage long sys_ioprio_get(int which
>  				break;
> 
>  			do_each_thread(g, p) {
> -				if (p->uid != user->uid)
> +				if (!task_user_equiv(p, user))
>  					continue;
>  				tmpio = get_task_ioprio(p);
>  				if (tmpio < 0)
> Index: linux-vanilla/fs/sysfs/mount.c
> ===================================================================
> --- linux-vanilla.orig/fs/sysfs/mount.c
> +++ linux-vanilla/fs/sysfs/mount.c
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
> Index: linux-vanilla/include/linux/sched.h
> ===================================================================
> --- linux-vanilla.orig/include/linux/sched.h
> +++ linux-vanilla/include/linux/sched.h
> @@ -595,7 +595,7 @@ struct user_struct {
> 
>  	/* Hash table maintenance information */
>  	struct hlist_node uidhash_node;
> -	uid_t uid;
> +	struct k_uid_t uid;
> 
>  #ifdef CONFIG_USER_SCHED
>  	struct task_group *tg;
> @@ -1697,6 +1697,7 @@ static inline struct user_struct *get_ui
>  extern void free_uid(struct user_struct *);
>  extern void switch_uid(struct user_struct *);
>  extern void release_uids(struct user_namespace *ns);
> +extern int task_user_equiv(struct task_struct *tsk, struct user_struct *u);
> 
>  #include <asm/current.h>
> 
> Index: linux-vanilla/include/linux/sysfs.h
> ===================================================================
> --- linux-vanilla.orig/include/linux/sysfs.h
> +++ linux-vanilla/include/linux/sysfs.h
> @@ -20,6 +20,7 @@
>  struct kobject;
>  struct module;
>  struct net;
> +struct user_namespace;
> 
>  /* FIXME
>   * The *owner field is no longer used, but leave around
> @@ -81,6 +82,7 @@ struct sysfs_ops {
> 
>  struct sysfs_tag_info {
>  	struct net *net_ns;
> +	struct user_namespace *user_ns;
>  };
> 
>  struct sysfs_tagged_dir_operations {
> @@ -139,6 +141,9 @@ int sysfs_enable_tagging(struct kobject 
> 
>  extern int __must_check sysfs_init(void);
> 
> +struct user_namespace;
> +void sysfs_userns_exit(struct user_namespace *user_ns);
> +
>  #else /* CONFIG_SYSFS */
> 
>  static inline int sysfs_schedule_callback(struct kobject *kobj,
> @@ -264,6 +269,10 @@ static inline int __must_check sysfs_ini
>  	return 0;
>  }
> 
> +static inline void sysfs_userns_exit(struct user_namespace *user_ns)
> +{
> +}
> +
>  #endif /* CONFIG_SYSFS */
> 
>  #endif /* _SYSFS_H_ */
> Index: linux-vanilla/include/linux/types.h
> ===================================================================
> --- linux-vanilla.orig/include/linux/types.h
> +++ linux-vanilla/include/linux/types.h
> @@ -37,6 +37,11 @@ typedef __kernel_gid32_t	gid_t;
>  typedef __kernel_uid16_t        uid16_t;
>  typedef __kernel_gid16_t        gid16_t;
> 
> +struct k_uid_t {
> +	uid_t uid;
> +	struct user_namespace *ns;
> +};
> +
>  typedef unsigned long		uintptr_t;
> 
>  #ifdef CONFIG_UID16
> Index: linux-vanilla/include/linux/user_namespace.h
> ===================================================================
> --- linux-vanilla.orig/include/linux/user_namespace.h
> +++ linux-vanilla/include/linux/user_namespace.h
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
> Index: linux-vanilla/kernel/user.c
> ===================================================================
> --- linux-vanilla.orig/kernel/user.c
> +++ linux-vanilla/kernel/user.c
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
> Index: linux-vanilla/kernel/user_namespace.c
> ===================================================================
> --- linux-vanilla.orig/kernel/user_namespace.c
> +++ linux-vanilla/kernel/user_namespace.c
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
> Index: linux-vanilla/security/keys/process_keys.c
> ===================================================================
> --- linux-vanilla.orig/security/keys/process_keys.c
> +++ linux-vanilla/security/keys/process_keys.c
> @@ -47,7 +47,7 @@ static int install_user_keyrings(struct 
>  	char buf[20];
>  	int ret;
> 
> -	kenter("%p{%u}", user, user->uid);
> +	kenter("%p{%u}", user, user->uid.uid);
> 
>  	if (user->uid_keyring) {
>  		kleave(" = 0 [exist]");
> @@ -62,13 +62,13 @@ static int install_user_keyrings(struct 
>  		 * - there may be one in existence already as it may have been
>  		 *   pinned by a session, but the user_struct pointing to it
>  		 *   may have been destroyed by setuid */
> -		sprintf(buf, "_uid.%u", user->uid);
> +		sprintf(buf, "_uid.%u", user->uid.uid);
> 
>  		uid_keyring = find_keyring_by_name(buf, true);
>  		if (IS_ERR(uid_keyring)) {
> -			uid_keyring = keyring_alloc(buf, user->uid, (gid_t) -1,
> -						    tsk, KEY_ALLOC_IN_QUOTA,
> -						    NULL);
> +			uid_keyring = keyring_alloc(buf, user->uid.uid,
> +						    (gid_t) -1, tsk,
> +						    KEY_ALLOC_IN_QUOTA, NULL);
>  			if (IS_ERR(uid_keyring)) {
>  				ret = PTR_ERR(uid_keyring);
>  				goto error;
> @@ -77,12 +77,12 @@ static int install_user_keyrings(struct 
> 
>  		/* get a default session keyring (which might also exist
>  		 * already) */
> -		sprintf(buf, "_uid_ses.%u", user->uid);
> +		sprintf(buf, "_uid_ses.%u", user->uid.uid);
> 
>  		session_keyring = find_keyring_by_name(buf, true);
>  		if (IS_ERR(session_keyring)) {
>  			session_keyring =
> -				keyring_alloc(buf, user->uid, (gid_t) -1,
> +				keyring_alloc(buf, user->uid.uid, (gid_t) -1,
>  					      tsk, KEY_ALLOC_IN_QUOTA, NULL);
>  			if (IS_ERR(session_keyring)) {
>  				ret = PTR_ERR(session_keyring);
> 
> -- 
