From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Tue, 7 Jun 2011 23:59:02 +0100
Message-ID: <20110607225902.GS11521@ZenIV.linux.org.uk>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
 <m1k4cy6auf.fsf@fess.ebiederm.org>
 <20110607215834.GR11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110607215834.GR11521@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 07, 2011 at 10:58:34PM +0100, Al Viro wrote:
> On Mon, Jun 06, 2011 at 12:03:52PM -0700, Eric W. Biederman wrote:
> 
> > Other pieces of information that should be helpful to know.
> > - All sysfs directory entries for a network namespace should be
> >   removed from sysfs by the time sysfs_exit_ns is called.
> 
> Then why do we need to do _anything_ with ->ns[...]?  Is there any problem
> with postponing actual freeing of that sucker until after umount, so that
> memory doesn't get reused?  Since everything stale should be gone by the
> point when sysfs_exit_ns() would put NULL into ->ns[...], we can as well
> keep the old pointer in there - it won't match anything else for as long
> as the struct net is not freed...

OK, how about the following:
	* extra refcount in struct net, initialized to 1.
	* new method in kobj_ns_type_operations: put_ns.  For struct net
that'd be "decrement that refcount by 1, if it hits zero call net_free()".
Existing callers of net_free() replaced by calls of that function.
	* current_ns semantics change: for struct net it'd bump that refcount.
	* sysfs_kill_sb() does corresponding put_ns on everything it finds in
its ->ns[...]
	* so does sysfs_mount() if it decides to discard the sysfs_super_info
after having found a duplicate
	* sysfs_exit_ns() is gone, along with kobj_ns_exit(), net_kobj_ns_exit()
and kobj_net_ops.

Completely untested patch follows:

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 2668957..1e7a2ee 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -111,8 +111,11 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 		info->ns[type] = kobj_ns_current(type);
 
 	sb = sget(fs_type, sysfs_test_super, sysfs_set_super, info);
-	if (IS_ERR(sb) || sb->s_fs_info != info)
+	if (IS_ERR(sb) || sb->s_fs_info != info) {
+		for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
+			kobj_ns_put(type, info->ns[type]);
 		kfree(info);
+	}
 	if (IS_ERR(sb))
 		return ERR_CAST(sb);
 	if (!sb->s_root) {
@@ -131,11 +134,14 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 static void sysfs_kill_sb(struct super_block *sb)
 {
 	struct sysfs_super_info *info = sysfs_info(sb);
+	int type;
 
 	/* Remove the superblock from fs_supers/s_instances
 	 * so we can't find it, before freeing sysfs_super_info.
 	 */
 	kill_anon_super(sb);
+	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
+		kobj_ns_put(type, info->ns[type]);
 	kfree(info);
 }
 
@@ -145,28 +151,6 @@ static struct file_system_type sysfs_fs_type = {
 	.kill_sb	= sysfs_kill_sb,
 };
 
-void sysfs_exit_ns(enum kobj_ns_type type, const void *ns)
-{
-	struct super_block *sb;
-
-	mutex_lock(&sysfs_mutex);
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &sysfs_fs_type.fs_supers, s_instances) {
-		struct sysfs_super_info *info = sysfs_info(sb);
-		/*
-		 * If we see a superblock on the fs_supers/s_instances
-		 * list the unmount has not completed and sb->s_fs_info
-		 * points to a valid struct sysfs_super_info.
-		 */
-		/* Ignore superblocks with the wrong ns */
-		if (info->ns[type] != ns)
-			continue;
-		info->ns[type] = NULL;
-	}
-	spin_unlock(&sb_lock);
-	mutex_unlock(&sysfs_mutex);
-}
-
 int __init sysfs_init(void)
 {
 	int err = -ENOMEM;
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 3d28af3..2ed2404 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -136,7 +136,7 @@ struct sysfs_addrm_cxt {
  * instance).
  */
 struct sysfs_super_info {
-	const void *ns[KOBJ_NS_TYPES];
+	void *ns[KOBJ_NS_TYPES];
 };
 #define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
 extern struct sysfs_dirent sysfs_root;
diff --git a/include/linux/kobject_ns.h b/include/linux/kobject_ns.h
index 82cb5bf..5fa481c 100644
--- a/include/linux/kobject_ns.h
+++ b/include/linux/kobject_ns.h
@@ -38,9 +38,10 @@ enum kobj_ns_type {
  */
 struct kobj_ns_type_operations {
 	enum kobj_ns_type type;
-	const void *(*current_ns)(void);
+	void *(*current_ns)(void);
 	const void *(*netlink_ns)(struct sock *sk);
 	const void *(*initial_ns)(void);
+	void (*put_ns)(void *);
 };
 
 int kobj_ns_type_register(const struct kobj_ns_type_operations *ops);
@@ -48,9 +49,9 @@ int kobj_ns_type_registered(enum kobj_ns_type type);
 const struct kobj_ns_type_operations *kobj_child_ns_ops(struct kobject *parent);
 const struct kobj_ns_type_operations *kobj_ns_ops(struct kobject *kobj);
 
-const void *kobj_ns_current(enum kobj_ns_type type);
+void *kobj_ns_current(enum kobj_ns_type type);
 const void *kobj_ns_netlink(enum kobj_ns_type type, struct sock *sk);
 const void *kobj_ns_initial(enum kobj_ns_type type);
-void kobj_ns_exit(enum kobj_ns_type type, const void *ns);
+void kobj_ns_put(enum kobj_ns_type type, void *ns);
 
 #endif /* _LINUX_KOBJECT_NS_H */
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index c3acda6..e2696d7 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -177,9 +177,6 @@ struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
 struct sysfs_dirent *sysfs_get(struct sysfs_dirent *sd);
 void sysfs_put(struct sysfs_dirent *sd);
 
-/* Called to clear a ns tag when it is no longer valid */
-void sysfs_exit_ns(enum kobj_ns_type type, const void *tag);
-
 int __must_check sysfs_init(void);
 
 #else /* CONFIG_SYSFS */
@@ -338,10 +335,6 @@ static inline void sysfs_put(struct sysfs_dirent *sd)
 {
 }
 
-static inline void sysfs_exit_ns(int type, const void *tag)
-{
-}
-
 static inline int __must_check sysfs_init(void)
 {
 	return 0;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2bf9ed9..415af64 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -35,8 +35,11 @@ struct netns_ipvs;
 #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
 
 struct net {
+	atomic_t		passive;	/* To decided when the network
+						 * namespace should be freed.
+						 */
 	atomic_t		count;		/* To decided when the network
-						 *  namespace should be freed.
+						 *  namespace should be shut down.
 						 */
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_t		use_count;	/* To track references we
@@ -154,6 +157,9 @@ int net_eq(const struct net *net1, const struct net *net2)
 {
 	return net1 == net2;
 }
+
+extern void net_put_ns(void *);
+
 #else
 
 static inline struct net *get_net(struct net *net)
@@ -175,6 +181,8 @@ int net_eq(const struct net *net1, const struct net *net2)
 {
 	return 1;
 }
+
+#define net_put_ns NULL
 #endif
 
 
diff --git a/lib/kobject.c b/lib/kobject.c
index 82dc34c..f584cd4 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -948,9 +948,9 @@ const struct kobj_ns_type_operations *kobj_ns_ops(struct kobject *kobj)
 }
 
 
-const void *kobj_ns_current(enum kobj_ns_type type)
+void *kobj_ns_current(enum kobj_ns_type type)
 {
-	const void *ns = NULL;
+	void *ns = NULL;
 
 	spin_lock(&kobj_ns_type_lock);
 	if ((type > KOBJ_NS_TYPE_NONE) && (type < KOBJ_NS_TYPES) &&
@@ -987,23 +987,15 @@ const void *kobj_ns_initial(enum kobj_ns_type type)
 	return ns;
 }
 
-/*
- * kobj_ns_exit - invalidate a namespace tag
- *
- * @type: the namespace type (i.e. KOBJ_NS_TYPE_NET)
- * @ns: the actual namespace being invalidated
- *
- * This is called when a tag is no longer valid.  For instance,
- * when a network namespace exits, it uses this helper to
- * make sure no sb's sysfs_info points to the now-invalidated
- * netns.
- */
-void kobj_ns_exit(enum kobj_ns_type type, const void *ns)
+void kobj_ns_put(enum kobj_ns_type type, void *ns)
 {
-	sysfs_exit_ns(type, ns);
+	spin_lock(&kobj_ns_type_lock);
+	if ((type > KOBJ_NS_TYPE_NONE) && (type < KOBJ_NS_TYPES) &&
+	    kobj_ns_ops_tbl[type])
+		kobj_ns_ops_tbl[type]->put_ns(ns);
+	spin_unlock(&kobj_ns_type_lock);
 }
 
-
 EXPORT_SYMBOL(kobject_get);
 EXPORT_SYMBOL(kobject_put);
 EXPORT_SYMBOL(kobject_del);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 11b98bc..b002c71 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1179,9 +1179,12 @@ static void remove_queue_kobjects(struct net_device *net)
 #endif
 }
 
-static const void *net_current_ns(void)
+static void *net_current_ns(void)
 {
-	return current->nsproxy->net_ns;
+	struct net *ns = current->nsproxy->net_ns;
+	if (ns)
+		atomic_inc(&ns->passive);
+	return ns;
 }
 
 static const void *net_initial_ns(void)
@@ -1199,19 +1202,10 @@ struct kobj_ns_type_operations net_ns_type_operations = {
 	.current_ns = net_current_ns,
 	.netlink_ns = net_netlink_ns,
 	.initial_ns = net_initial_ns,
+	.put_ns = net_put_ns,
 };
 EXPORT_SYMBOL_GPL(net_ns_type_operations);
 
-static void net_kobj_ns_exit(struct net *net)
-{
-	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
-}
-
-static struct pernet_operations kobj_net_ops = {
-	.exit = net_kobj_ns_exit,
-};
-
-
 #ifdef CONFIG_HOTPLUG
 static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 {
@@ -1339,6 +1333,5 @@ EXPORT_SYMBOL(netdev_class_remove_file);
 int netdev_kobject_init(void)
 {
 	kobj_ns_type_register(&net_ns_type_operations);
-	register_pernet_subsys(&kobj_net_ops);
 	return class_register(&net_class);
 }
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6c6b86d..19feb20 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -128,6 +128,7 @@ static __net_init int setup_net(struct net *net)
 	LIST_HEAD(net_exit_list);
 
 	atomic_set(&net->count, 1);
+	atomic_set(&net->passive, 1);
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -210,6 +211,13 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
+void net_put_ns(void *p)
+{
+	struct net *ns = p;
+	if (ns && atomic_dec_and_test(&ns->passive))
+		net_free(ns);
+}
+
 struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 {
 	struct net *net;
@@ -230,7 +238,7 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	}
 	mutex_unlock(&net_mutex);
 	if (rv < 0) {
-		net_free(net);
+		net_put_ns(net);
 		return ERR_PTR(rv);
 	}
 	return net;
@@ -286,7 +294,7 @@ static void cleanup_net(struct work_struct *work)
 	/* Finally it is safe to free my network namespace structure */
 	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
 		list_del_init(&net->exit_list);
-		net_free(net);
+		net_put_ns(net);
 	}
 }
 static DECLARE_WORK(net_cleanup_work, cleanup_net);
