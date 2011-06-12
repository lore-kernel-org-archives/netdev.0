From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sun, 12 Jun 2011 00:15:40 -0700
Message-ID: <m1y617wmeb.fsf@fess.ebiederm.org>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
	<m1k4cy6auf.fsf@fess.ebiederm.org>
	<20110607215834.GR11521@ZenIV.linux.org.uk>
	<20110607225902.GS11521@ZenIV.linux.org.uk>
	<20110609012646.GV11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48712 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab1FLHPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 03:15:47 -0400
In-Reply-To: <20110609012646.GV11521@ZenIV.linux.org.uk> (Al Viro's message of
	"Thu, 9 Jun 2011 02:26:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Tue, Jun 07, 2011 at 11:59:02PM +0100, Al Viro wrote:
>
>> Completely untested patch follows:
>
> FWIW, modulo a couple of brainos it seems to work here without blowing
> everything up.  Actual freeing of struct net is delayed until after
> umount of sysfs instances refering it, shutdown is *not* delayed, sysfs
> entries are removed nicely as they ought to, no objects from other net_ns
> are picked by readdir or lookup...
>
> If somebody has objections - yell.  If I don't hear anything, the following
> goes to -next:

The change seems reasonable, and much more likely to keep working after
small changes to sysfs.  Sigh.

I honestly hate the pattern that is being used here.  Holding a
reference count because we can't be bothered to free things reliably
when we actually stop using them.  It does look less error prone than
what I am doing today, and 2.5KiB for struct net isn't that much memory
to pin.

Will pinning an extra 2.5KiB be a problem when we get to the point where
unprivileged mounts are safe?  I expect there are easier ways to pin more
memory so I doubt this is worth worrying about.

The naming of things after your patch stinks.

It isn't clear what is taking or putting what kind of refcount from the
names.  If we don't correct the bad naming your patch will be worse for
maintenance than what we already have.

> commit 72d4e98002b45598bb88af74eeac20874f2789be
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Wed Jun 8 21:13:01 2011 -0400
>
>     Delay struct net freeing while there's a sysfs instance refering to it
>     
>     	* new refcount in struct net, controlling actual freeing of the memory
>     	* new method in kobj_ns_type_operations (->put_ns())
>     	* ->current_ns() semantics change - it's supposed to be followed by
>     corresponding ->put_ns().  For struct net in case of CONFIG_NET_NS it bumps
>     the new refcount; net_put_ns() decrements it and calls net_free() if the
>     last reference has been dropped.

We need to rename kobj_ns_current so it is clear we get a ref count.

>     	* old net_free() callers call net_put_ns() instead.
>     	* sysfs_exit_ns() is gone, along with a large part of callchain
>     leading to it; now that the references stored in ->ns[...] stay valid we
>     do not need to hunt them down and replace them with NULL.  That fixes
>     problems in sysfs_lookup() and sysfs_readdir(), along with getting rid
>     of sb->s_instances abuse.

Honestly I can fix at least the lookup problems by assigning 
((void *)-1UL) instead of NULL, in sysfs_exit_ns.

>     	Note that struct net *shutdown* logics has not changed - net_cleanup()
>     is called exactly when it used to be called.  The only thing postponed by
>     having a sysfs instance refering to that struct net is actual freeing of
>     memory occupied by struct net.
>     
>     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
>
> diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
> index 2668957..1e7a2ee 100644
> --- a/fs/sysfs/mount.c
> +++ b/fs/sysfs/mount.c
> @@ -111,8 +111,11 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
>  		info->ns[type] = kobj_ns_current(type);
>  
>  	sb = sget(fs_type, sysfs_test_super, sysfs_set_super, info);
> -	if (IS_ERR(sb) || sb->s_fs_info != info)
> +	if (IS_ERR(sb) || sb->s_fs_info != info) {
> +		for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
> +			kobj_ns_put(type, info->ns[type]);
>  		kfree(info);
> +	}
>  	if (IS_ERR(sb))
>  		return ERR_CAST(sb);
>  	if (!sb->s_root) {
> @@ -131,11 +134,14 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
>  static void sysfs_kill_sb(struct super_block *sb)
>  {
>  	struct sysfs_super_info *info = sysfs_info(sb);
> +	int type;
>  
>  	/* Remove the superblock from fs_supers/s_instances
>  	 * so we can't find it, before freeing sysfs_super_info.
>  	 */
>  	kill_anon_super(sb);
> +	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
> +		kobj_ns_put(type, info->ns[type]);

This loop and the kfree probably deserve a small function of their own.

>  	kfree(info);
>  }
>  
> @@ -145,28 +151,6 @@ static struct file_system_type sysfs_fs_type = {
>  	.kill_sb	= sysfs_kill_sb,
>  };
>  
> -void sysfs_exit_ns(enum kobj_ns_type type, const void *ns)
> -{
> -	struct super_block *sb;
> -
> -	mutex_lock(&sysfs_mutex);
> -	spin_lock(&sb_lock);
> -	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
> -		struct sysfs_super_info *info = sysfs_info(sb);
> -		/*
> -		 * If we see a superblock on the fs_supers/s_instances
> -		 * list the unmount has not completed and sb->s_fs_info
> -		 * points to a valid struct sysfs_super_info.
> -		 */
> -		/* Ignore superblocks with the wrong ns */
> -		if (info->ns[type] != ns)
> -			continue;
> -		info->ns[type] = NULL;
> -	}
> -	spin_unlock(&sb_lock);
> -	mutex_unlock(&sysfs_mutex);
> -}
> -
>  int __init sysfs_init(void)
>  {
>  	int err = -ENOMEM;
> diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
> index 3d28af3..2ed2404 100644
> --- a/fs/sysfs/sysfs.h
> +++ b/fs/sysfs/sysfs.h
> @@ -136,7 +136,7 @@ struct sysfs_addrm_cxt {
>   * instance).
>   */
>  struct sysfs_super_info {
> -	const void *ns[KOBJ_NS_TYPES];
> +	void *ns[KOBJ_NS_TYPES];
>  };
>  #define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
>  extern struct sysfs_dirent sysfs_root;
> diff --git a/include/linux/kobject_ns.h b/include/linux/kobject_ns.h
> index 82cb5bf..5fa481c 100644
> --- a/include/linux/kobject_ns.h
> +++ b/include/linux/kobject_ns.h
> @@ -38,9 +38,10 @@ enum kobj_ns_type {
>   */
>  struct kobj_ns_type_operations {
>  	enum kobj_ns_type type;
> -	const void *(*current_ns)(void);
> +	void *(*current_ns)(void);

I really don't like removing const here.  It made it very clear that
what we are messing with is a token and not something that we ever will
deference.

>  	const void *(*netlink_ns)(struct sock *sk);
>  	const void *(*initial_ns)(void);
> +	void (*put_ns)(void *);
>  };
>  
>  int kobj_ns_type_register(const struct kobj_ns_type_operations *ops);
> @@ -48,9 +49,9 @@ int kobj_ns_type_registered(enum kobj_ns_type type);
>  const struct kobj_ns_type_operations *kobj_child_ns_ops(struct kobject *parent);
>  const struct kobj_ns_type_operations *kobj_ns_ops(struct kobject *kobj);
>  
> -const void *kobj_ns_current(enum kobj_ns_type type);
> +void *kobj_ns_current(enum kobj_ns_type type);
>  const void *kobj_ns_netlink(enum kobj_ns_type type, struct sock *sk);
>  const void *kobj_ns_initial(enum kobj_ns_type type);
> -void kobj_ns_exit(enum kobj_ns_type type, const void *ns);
> +void kobj_ns_put(enum kobj_ns_type type, void *ns);
>  
>  #endif /* _LINUX_KOBJECT_NS_H */
> diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
> index c3acda6..e2696d7 100644
> --- a/include/linux/sysfs.h
> +++ b/include/linux/sysfs.h
> @@ -177,9 +177,6 @@ struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
>  struct sysfs_dirent *sysfs_get(struct sysfs_dirent *sd);
>  void sysfs_put(struct sysfs_dirent *sd);
>  
> -/* Called to clear a ns tag when it is no longer valid */
> -void sysfs_exit_ns(enum kobj_ns_type type, const void *tag);
> -
>  int __must_check sysfs_init(void);
>  
>  #else /* CONFIG_SYSFS */
> @@ -338,10 +335,6 @@ static inline void sysfs_put(struct sysfs_dirent *sd)
>  {
>  }
>  
> -static inline void sysfs_exit_ns(int type, const void *tag)
> -{
> -}
> -
>  static inline int __must_check sysfs_init(void)
>  {
>  	return 0;
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index 2bf9ed9..415af64 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -35,8 +35,11 @@ struct netns_ipvs;
>  #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
>  
>  struct net {
> +	atomic_t		passive;	/* To decided when the network
> +						 * namespace should be freed.
> +						 */
>  	atomic_t		count;		/* To decided when the network
> -						 *  namespace should be freed.
> +						 *  namespace should be shut down.
>  						 */
>  #ifdef NETNS_REFCNT_DEBUG
>  	atomic_t		use_count;	/* To track references we
> @@ -154,6 +157,9 @@ int net_eq(const struct net *net1, const struct net *net2)
>  {
>  	return net1 == net2;
>  }
> +
> +extern void net_put_ns(void *);
> +
>  #else
>  
>  static inline struct net *get_net(struct net *net)
> @@ -175,6 +181,8 @@ int net_eq(const struct net *net1, const struct net *net2)
>  {
>  	return 1;
>  }
> +
> +#define net_put_ns NULL
>  #endif
>  
>  
> diff --git a/lib/kobject.c b/lib/kobject.c
> index 82dc34c..43116b2 100644
> --- a/lib/kobject.c
> +++ b/lib/kobject.c
> @@ -948,9 +948,9 @@ const struct kobj_ns_type_operations *kobj_ns_ops(struct kobject *kobj)
>  }
>  
>  
> -const void *kobj_ns_current(enum kobj_ns_type type)
> +void *kobj_ns_current(enum kobj_ns_type type)
>  {
> -	const void *ns = NULL;
> +	void *ns = NULL;
>  
>  	spin_lock(&kobj_ns_type_lock);
>  	if ((type > KOBJ_NS_TYPE_NONE) && (type < KOBJ_NS_TYPES) &&
> @@ -987,23 +987,15 @@ const void *kobj_ns_initial(enum kobj_ns_type type)
>  	return ns;
>  }
>  
> -/*
> - * kobj_ns_exit - invalidate a namespace tag
> - *
> - * @type: the namespace type (i.e. KOBJ_NS_TYPE_NET)
> - * @ns: the actual namespace being invalidated
> - *
> - * This is called when a tag is no longer valid.  For instance,
> - * when a network namespace exits, it uses this helper to
> - * make sure no sb's sysfs_info points to the now-invalidated
> - * netns.
> - */
> -void kobj_ns_exit(enum kobj_ns_type type, const void *ns)
> +void kobj_ns_put(enum kobj_ns_type type, void *ns)
>  {
> -	sysfs_exit_ns(type, ns);
> +	spin_lock(&kobj_ns_type_lock);
> +	if ((type > KOBJ_NS_TYPE_NONE) && (type < KOBJ_NS_TYPES) &&
> +	    kobj_ns_ops_tbl[type] && kobj_ns_ops_tbl[type]->put_ns)
> +		kobj_ns_ops_tbl[type]->put_ns(ns);
> +	spin_unlock(&kobj_ns_type_lock);
>  }
>  
> -
>  EXPORT_SYMBOL(kobject_get);
>  EXPORT_SYMBOL(kobject_put);
>  EXPORT_SYMBOL(kobject_del);
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 11b98bc..0c799f1 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -1179,9 +1179,14 @@ static void remove_queue_kobjects(struct net_device *net)
>  #endif
>  }
>  
> -static const void *net_current_ns(void)
> +static void *net_current_ns(void)
>  {
> -	return current->nsproxy->net_ns;
> +	struct net *ns = current->nsproxy->net_ns;
> +#ifdef CONFIG_NET_NS
> +	if (ns)
> +		atomic_inc(&ns->passive);
> +#endif
This code  doesn't need to be #ifdef'd
> +	return ns;
>  }
>  
>  static const void *net_initial_ns(void)
> @@ -1199,19 +1204,10 @@ struct kobj_ns_type_operations net_ns_type_operations = {
>  	.current_ns = net_current_ns,
>  	.netlink_ns = net_netlink_ns,
>  	.initial_ns = net_initial_ns,
> +	.put_ns = net_put_ns,
>  };
>  EXPORT_SYMBOL_GPL(net_ns_type_operations);
>  
> -static void net_kobj_ns_exit(struct net *net)
> -{
> -	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
> -}
> -
> -static struct pernet_operations kobj_net_ops = {
> -	.exit = net_kobj_ns_exit,
> -};
> -
> -
>  #ifdef CONFIG_HOTPLUG
>  static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
>  {
> @@ -1339,6 +1335,5 @@ EXPORT_SYMBOL(netdev_class_remove_file);
>  int netdev_kobject_init(void)
>  {
>  	kobj_ns_type_register(&net_ns_type_operations);
> -	register_pernet_subsys(&kobj_net_ops);
>  	return class_register(&net_class);
>  }
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 6c6b86d..19feb20 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -128,6 +128,7 @@ static __net_init int setup_net(struct net *net)
>  	LIST_HEAD(net_exit_list);
>  
>  	atomic_set(&net->count, 1);
> +	atomic_set(&net->passive, 1);
>  
>  #ifdef NETNS_REFCNT_DEBUG
>  	atomic_set(&net->use_count, 0);
> @@ -210,6 +211,13 @@ static void net_free(struct net *net)
>  	kmem_cache_free(net_cachep, net);
>  }
>  
> +void net_put_ns(void *p)
> +{
There has got to be a better name.  We already have put and get net
methods.

> +	struct net *ns = p;
> +	if (ns && atomic_dec_and_test(&ns->passive))
> +		net_free(ns);
> +}
> +
>  struct net *copy_net_ns(unsigned long flags, struct net *old_net)
>  {
>  	struct net *net;
> @@ -230,7 +238,7 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
>  	}
>  	mutex_unlock(&net_mutex);
>  	if (rv < 0) {
> -		net_free(net);
> +		net_put_ns(net);
>  		return ERR_PTR(rv);
>  	}
>  	return net;
> @@ -286,7 +294,7 @@ static void cleanup_net(struct work_struct *work)
>  	/* Finally it is safe to free my network namespace structure */
>  	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
>  		list_del_init(&net->exit_list);
> -		net_free(net);
> +		net_put_ns(net);
>  	}
>  }
>  static DECLARE_WORK(net_cleanup_work, cleanup_net);

Eric
