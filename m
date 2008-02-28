From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2] Make /proc/net a symlink and drop proc shadows
Date: Thu, 28 Feb 2008 18:51:33 +0300
Message-ID: <47C6D885.90302@openvz.org>
References: <47C6D743.1050802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761291AbYB1Pw0@vger.kernel.org>
In-Reply-To: <47C6D743.1050802@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turn /proc/net into a symlink, which behaves similar to /proc/self
link - it points to .netns/<id> directory where the <id> is the id
of net namespace, current task lives in.

# ls -l /proc/net
lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0

The /proc/.netns dir contains subtrees for all the namespaces in 
the system:

# ls -l /proc/.netns/
total 0
dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
dr-xr-xr-x  3 root root 0 Feb 28 18:39 1

To provide some security each /proc/.netns/<id> directory allows
access to tasks that live in the owning namespace only (with the
exception, that init_net tasks can see everything).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 68971e6..d4103e5 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -227,7 +227,7 @@ static const struct file_operations proc_file_operations = {
 	.write		= proc_file_write,
 };
 
-static int proc_notify_change(struct dentry *dentry, struct iattr *iattr)
+int proc_notify_change(struct dentry *dentry, struct iattr *iattr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct proc_dir_entry *de = PDE(inode);
@@ -248,7 +248,7 @@ out:
 	return error;
 }
 
-static int proc_getattr(struct vfsmount *mnt, struct dentry *dentry,
+int proc_getattr(struct vfsmount *mnt, struct dentry *dentry,
 			struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
@@ -393,8 +393,6 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
 				unsigned int ino;
 
-				if (de->shadow_proc)
-					de = de->shadow_proc(current, de);
 				ino = de->low_ino;
 				de_get(de);
 				spin_unlock(&proc_subdir_lock);
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 14e9b5a..8000ea4 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -83,14 +83,6 @@ struct net *get_proc_net(const struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(get_proc_net);
 
-static struct proc_dir_entry *shadow_pde;
-
-static struct proc_dir_entry *proc_net_shadow(struct task_struct *task,
-						struct proc_dir_entry *de)
-{
-	return task->nsproxy->net_ns->proc_net;
-}
-
 struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 		struct proc_dir_entry *parent)
 {
@@ -102,47 +94,61 @@ struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 }
 EXPORT_SYMBOL_GPL(proc_net_mkdir);
 
+static int proc_netns_id_permission(struct inode *inode, int mask,
+		struct nameidata *nd)
+{
+	struct net *net = current->nsproxy->net_ns;
+
+	if (net == &init_net || net == PDE(inode)->data)
+		return generic_permission(inode, mask, NULL);
+	else
+		return -EACCES;
+}
+
+static const struct inode_operations proc_netns_id_ops = {
+	.lookup		= proc_lookup,
+	.getattr	= proc_getattr,
+	.setattr	= proc_notify_change,
+	.permission	= proc_netns_id_permission,
+};
+
+static struct proc_dir_entry *netns_dir;
+
 static __net_init int proc_net_ns_init(struct net *net)
 {
-	struct proc_dir_entry *root, *netd, *net_statd;
-	int err;
+	struct proc_dir_entry *netd, *net_statd;
+	char id[PROC_NUMBUF];
 
-	err = -ENOMEM;
-	root = kzalloc(sizeof(*root), GFP_KERNEL);
-	if (!root)
-		goto out;
+	snprintf(id, sizeof(id), "%d", net->id);
 
-	err = -EEXIST;
-	netd = proc_net_mkdir(net, "net", root);
+	netd = proc_net_mkdir(net, id, netns_dir);
 	if (!netd)
-		goto free_root;
+		goto out;
+
+	netd->proc_iops = &proc_netns_id_ops;
 
-	err = -EEXIST;
 	net_statd = proc_net_mkdir(net, "stat", netd);
 	if (!net_statd)
 		goto free_net;
 
-	root->data = net;
-
-	net->proc_net_root = root;
 	net->proc_net = netd;
 	net->proc_net_stat = net_statd;
-	err = 0;
+	return 0;
 
-out:
-	return err;
 free_net:
-	remove_proc_entry("net", root);
-free_root:
-	kfree(root);
-	goto out;
+	remove_proc_entry(id, netns_dir);
+out:
+	return -ENOMEM;
 }
 
 static __net_exit void proc_net_ns_exit(struct net *net)
 {
+	char id[PROC_NUMBUF];
+
+	snprintf(id, sizeof(id), "%d", net->id);
+
 	remove_proc_entry("stat", net->proc_net);
-	remove_proc_entry("net", net->proc_net_root);
-	kfree(net->proc_net_root);
+	remove_proc_entry(id, netns_dir);
 }
 
 static struct pernet_operations __net_initdata proc_net_ns_ops = {
@@ -150,10 +156,36 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
 	.exit = proc_net_ns_exit,
 };
 
+static int proc_net_readlink(struct dentry *dentry, char __user *buffer,
+			      int buflen)
+{
+	char tmp[PROC_NUMBUF];
+
+	sprintf(tmp, ".netns/%d", current->nsproxy->net_ns->id);
+	return vfs_readlink(dentry, buffer, buflen, tmp);
+}
+
+static void *proc_net_follow_link(struct dentry *dentry, struct nameidata *nd)
+{
+	char tmp[PROC_NUMBUF];
+
+	sprintf(tmp, ".netns/%d", current->nsproxy->net_ns->id);
+	return ERR_PTR(vfs_follow_link(nd, tmp));
+}
+
+static const struct inode_operations proc_net_link_ops = {
+	.readlink	= proc_net_readlink,
+	.follow_link	= proc_net_follow_link,
+};
+
 int __init proc_net_init(void)
 {
-	shadow_pde = proc_mkdir("net", NULL);
-	shadow_pde->shadow_proc = proc_net_shadow;
+	struct proc_dir_entry *nnet;
+
+	netns_dir = proc_mkdir(".netns", NULL);
+	nnet = proc_symlink("net", NULL, ".netns/0");
+
+	nnet->proc_iops = &proc_net_link_ops;
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index d9a9e71..be0c9b7 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -82,7 +82,6 @@ struct proc_dir_entry {
 	int pde_users;	/* number of callers into module in progress */
 	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
 	struct completion *pde_unload_completion;
-	shadow_proc_t *shadow_proc;
 };
 
 struct kcore_list {
@@ -145,6 +144,9 @@ extern struct inode *proc_get_inode(struct super_block *, unsigned int, struct p
  */
 extern int proc_readdir(struct file *, void *, filldir_t);
 extern struct dentry *proc_lookup(struct inode *, struct dentry *, struct nameidata *);
+extern int proc_getattr(struct vfsmount *mnt, struct dentry *dentry,
+			struct kstat *stat);
+extern int proc_notify_change(struct dentry *dentry, struct iattr *iattr);
 
 extern const struct file_operations proc_kcore_operations;
 extern const struct file_operations proc_kmsg_operations;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 28738b7..8aedfd6 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -32,7 +32,6 @@ struct net {
 
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
-	struct proc_dir_entry 	*proc_net_root;
 
 	struct list_head	sysctl_table_headers;
 
