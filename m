From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: add /proc/*/net/id symlink
Date: Sat, 21 May 2011 12:39:36 +0300
Message-ID: <20110521093936.GA3015@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, equinox@diac24.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56088 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab1EUJkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 05:40:17 -0400
Received: by ewy4 with SMTP id 4so1380274ewy.19
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 02:40:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Lamparter pointed some real scenarios where knowing
if two processes live in same netns is important,
like "how do I kill _all_ processes in netns to shutdown it".

Currently only kernel knows if two netns are the same.
Userspace maybe can look at different proc files to find a match
indirectly sysconf-style but result will be ugly no matter what.

Add /proc/*/net/id symlink which "points" to an integer.

	$ readlink /proc/net/id
	0

	$ readlink /proc/2941/net/id
	1

"id" is not a file because 1 syscall is faster than 3 syscalls.

The only rules and expectations for userspace are:
[as if they will comply, ha-ha]

* init_net always has id 0
* two netns do not have same id
* id is unsigned integer

Kernel code continues to use net_eq(), there is no need
to compare net->id inside kernel, because it is slower than net_eq().

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 fs/proc/generic.c           |   16 +++++++++++++
 fs/proc/proc_net.c          |   31 ++++++++++++++++++++++++-
 include/linux/proc_fs.h     |    7 +++++
 include/net/net_namespace.h |   10 ++++++++
 net/core/net_namespace.c    |   54 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 117 insertions(+), 1 deletion(-)

--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -660,6 +660,22 @@ struct proc_dir_entry *proc_symlink(const char *name,
 }
 EXPORT_SYMBOL(proc_symlink);
 
+struct proc_dir_entry *_proc_symlink(const char *name, struct proc_dir_entry *parent, const struct inode_operations *proc_iops)
+{
+	struct proc_dir_entry *pde;
+
+	pde = __proc_create(&parent, name, S_IFLNK | S_IRUGO|S_IWUGO|S_IXUGO, 1);
+	if (!pde)
+		return NULL;
+	pde->proc_iops = proc_iops;
+	pde->data = NULL;
+	if (proc_register(parent, pde) < 0) {
+		kfree(pde);
+		return NULL;
+	}
+	return pde;
+}
+
 struct proc_dir_entry *proc_mkdir_mode(const char *name, mode_t mode,
 		struct proc_dir_entry *parent)
 {
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -191,9 +191,30 @@ void proc_net_remove(struct net *net, const char *name)
 }
 EXPORT_SYMBOL_GPL(proc_net_remove);
 
+static int net_id_readlink(struct dentry *dentry, char __user *buf, int buflen)
+{
+	struct net *net;
+	char kbuf[42];
+	int len;
+
+	net = get_proc_net(dentry->d_inode);
+	if (!net)
+		return -ENXIO;
+	len = snprintf(kbuf, sizeof(kbuf), "%u", net->id);
+	put_net(net);
+	len = min(len, buflen);
+	if (copy_to_user(buf, kbuf, len))
+		return -EFAULT;
+	return len;
+}
+
+static const struct inode_operations net_id_proc_iops = {
+	.readlink	= net_id_readlink,
+};
+
 static __net_init int proc_net_ns_init(struct net *net)
 {
-	struct proc_dir_entry *netd, *net_statd;
+	struct proc_dir_entry *netd, *net_statd, *pde;
 	int err;
 
 	err = -ENOMEM;
@@ -214,8 +235,15 @@ static __net_init int proc_net_ns_init(struct net *net)
 
 	net->proc_net = netd;
 	net->proc_net_stat = net_statd;
+
+	pde = _proc_symlink("id", net->proc_net, &net_id_proc_iops);
+	if (!pde)
+		goto free_net_stat;
+
 	return 0;
 
+free_net_stat:
+	kfree(net_statd);
 free_net:
 	kfree(netd);
 out:
@@ -224,6 +252,7 @@ out:
 
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
+	remove_proc_entry("id", net->proc_net);
 	remove_proc_entry("stat", net->proc_net);
 	kfree(net->proc_net);
 }
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -143,6 +143,7 @@ extern void proc_device_tree_update_prop(struct proc_dir_entry *pde,
 					 struct property *oldprop);
 #endif /* CONFIG_PROC_DEVICETREE */
 
+struct proc_dir_entry *_proc_symlink(const char *name, struct proc_dir_entry *parent, const struct inode_operations *proc_iops);
 extern struct proc_dir_entry *proc_symlink(const char *,
 		struct proc_dir_entry *, const char *);
 extern struct proc_dir_entry *proc_mkdir(const char *,struct proc_dir_entry *);
@@ -204,8 +205,14 @@ static inline struct proc_dir_entry *proc_create_data(const char *name,
 }
 #define remove_proc_entry(name, parent) do {} while (0)
 
+static inline struct proc_dir_entry *_proc_symlink(const char *name, struct proc_dir_entry *parent, const struct inode_operations *proc_iops)
+{
+	return NULL;
+}
+
 static inline struct proc_dir_entry *proc_symlink(const char *name,
 		struct proc_dir_entry *parent,const char *dest) {return NULL;}
+
 static inline struct proc_dir_entry *proc_mkdir(const char *name,
 	struct proc_dir_entry *parent) {return NULL;}
 static inline struct proc_dir_entry *proc_mkdir_mode(const char *name,
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -96,6 +96,16 @@ struct net {
 	struct netns_xfrm	xfrm;
 #endif
 	struct netns_ipvs	*ipvs;
+
+	/*
+	 * netns unique id solely for userspace consumption,
+	 * see /proc/net/id symlink.
+	 *
+	 * init_net has id 0.
+	 *
+	 * Write-once field.
+	 */
+	unsigned int		id;
 };
 
 
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -115,6 +115,52 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+#ifdef CONFIG_NET_NS
+static DEFINE_IDA(net_id_ida);
+static DEFINE_SPINLOCK(net_id_ida_lock);
+
+static int __net_init set_net_id(struct net *net)
+{
+	int id;
+
+	if (net_eq(net, &init_net)) {
+		id = 0;
+	} else {
+		int rv;
+
+		do {
+			if (ida_pre_get(&net_id_ida, GFP_KERNEL) == 0)
+				return -ENOMEM;
+			spin_lock(&net_id_ida_lock);
+			/* init_net has id 0 */
+			rv = ida_get_new_above(&net_id_ida, 1, &id);
+			spin_unlock(&net_id_ida_lock);
+		} while (rv == -EAGAIN);
+		if (rv < 0)
+			return rv;
+	}
+	net->id = id;
+	return 0;
+}
+
+static void free_net_id(struct net *net)
+{
+	spin_lock(&net_id_ida_lock);
+	ida_remove(&net_id_ida, net->id);
+	spin_unlock(&net_id_ida_lock);
+}
+#else
+static inline int set_net_id(struct net *net)
+{
+	net->id = 0;
+	return 0;
+}
+
+static inline void free_net_id(struct net *net)
+{
+}
+#endif
+
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -131,6 +177,10 @@ static __net_init int setup_net(struct net *net)
 	atomic_set(&net->use_count, 0);
 #endif
 
+	error = set_net_id(net);
+	if (error < 0)
+		goto out;
+
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);
 		if (error < 0)
@@ -140,6 +190,8 @@ out:
 	return error;
 
 out_undo:
+	free_net_id(net);
+
 	/* Walk through the list backwards calling the exit functions
 	 * for the pernet modules whose init functions did not fail.
 	 */
@@ -204,6 +256,8 @@ static void net_free(struct net *net)
 		return;
 	}
 #endif
+
+	free_net_id(net);
 	kfree(net->gen);
 	kmem_cache_free(net_cachep, net);
 }
