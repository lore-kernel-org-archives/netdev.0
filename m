From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Mon, 26 Nov 2007 15:17:54 -0700
Message-ID: <m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35448 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbXKZWTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 17:19:14 -0500
In-Reply-To: <4743026B.2020907@openvz.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 18:51:07 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Pavel Emelyanov <xemul@openvz.org> writes:

> Rafael J. Wysocki wrote:
>> On Monday, 19 of November 2007, Pavel Machek wrote:
>>> Hi!
>>>
>>> I think that this worked before:
>>>
>>> root@amd:/proc# find . -name "timer_info"
>>> find: WARNING: Hard link count is wrong for ./net: this may be a bug
>>> in your filesystem driver.  Automatically turning on find's -noleaf
>>> option.  Earlier results may have failed to include directories that
>>> should have been searched.
>>> root@amd:/proc#
>> 
>> I'm seeing that too.
>
> I have a better things with 2.6.24-rc3 ;)
>
> # cd /proc/net
> # ls ..
> ls: reading directory ..: Not a directory
>
> and this
>
> # cd /proc
> # find
> ...
> ./net
> find: . changed during execution of find
> # find net
> find: net changed during execution of find
> # find net/
> <this works ok however>
>
> Moreover. Program that opens /proc/net and dumps the /proc/self/fd
> files produces the following:
>
> # cd /
> # a.out /proc/net
> ...
> lr-x------  1 root root 64 Nov 20 18:02 3 -> /proc/net/net (deleted)
> ...
> # cd /proc/net
> # a.out .
> ...
> lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net/net (deleted)
> ...
> # a.out ..
> ...
> lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net
> ...

Well I clearly goofed when I added the initial network namespace support
for /proc/net.  Currently things work but there are odd details visible
to user space, even when we have a single network namespace.

Since we do not cache proc_dir_entry dentries at the moment we can
just modify ->lookup to return a different directory inode depending
on the network namespace of the process looking at /proc/net, replacing
the current technique of using a magic and fragile follow_link method.

To accomplish that this patch:
- introduces a shadow_proc method to allow different dentries to
  be returned from proc_lookup.
- Removes the old /proc/net follow_link magic
- Fixes a weakness in our not caching of proc generic dentries.

As shadow_proc uses a task struct to decided which dentry to return we
can go back later and fix the proc generic caching without modifying any code that
uses the shadow_proc method.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/generic.c       |   12 ++++++-
 fs/proc/proc_net.c      |   86 +++--------------------------------------------
 include/linux/proc_fs.h |    3 ++
 3 files changed, 19 insertions(+), 82 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index a9806bc..c2b7523 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -374,9 +374,16 @@ static int proc_delete_dentry(struct dentry * dentry)
 	return 1;
 }
 
+static int proc_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
+{
+	d_drop(dentry);
+	return 0;
+}
+
 static struct dentry_operations proc_dentry_operations =
 {
 	.d_delete	= proc_delete_dentry,
+	.d_revalidate	= proc_revalidate_dentry,
 };
 
 /*
@@ -397,8 +404,11 @@ struct dentry *proc_lookup(struct inode * dir, struct dentry *dentry, struct nam
 			if (de->namelen != dentry->d_name.len)
 				continue;
 			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
-				unsigned int ino = de->low_ino;
+				unsigned int ino;
 
+				if (de->shadow_proc)
+					de = de->shadow_proc(current, de);
+				ino = de->low_ino;
 				de_get(de);
 				spin_unlock(&proc_subdir_lock);
 				error = -EINVAL;
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 131f9c6..0afe21e 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -50,89 +50,14 @@ struct net *get_proc_net(const struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(get_proc_net);
 
-static struct proc_dir_entry *proc_net_shadow;
+static struct proc_dir_entry *shadow_pde;
 
-static struct dentry *proc_net_shadow_dentry(struct dentry *parent,
+static struct proc_dir_entry *proc_net_shadow(struct task_struct *task,
 						struct proc_dir_entry *de)
 {
-	struct dentry *shadow = NULL;
-	struct inode *inode;
-	if (!de)
-		goto out;
-	de_get(de);
-	inode = proc_get_inode(parent->d_inode->i_sb, de->low_ino, de);
-	if (!inode)
-		goto out_de_put;
-	shadow = d_alloc_name(parent, de->name);
-	if (!shadow)
-		goto out_iput;
-	shadow->d_op = parent->d_op; /* proc_dentry_operations */
-	d_instantiate(shadow, inode);
-out:
-	return shadow;
-out_iput:
-	iput(inode);
-out_de_put:
-	de_put(de);
-	goto out;
-}
-
-static void *proc_net_follow_link(struct dentry *parent, struct nameidata *nd)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-	shadow = proc_net_shadow_dentry(parent, net->proc_net);
-	if (!shadow)
-		return ERR_PTR(-ENOENT);
-
-	dput(nd->dentry);
-	/* My dentry count is 1 and that should be enough as the
-	 * shadow dentry is thrown away immediately.
-	 */
-	nd->dentry = shadow;
-	return NULL;
+	return task->nsproxy->net_ns->proc_net;
 }
 
-static struct dentry *proc_net_lookup(struct inode *dir, struct dentry *dentry,
-				      struct nameidata *nd)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-
-	shadow = proc_net_shadow_dentry(nd->dentry, net->proc_net);
-	if (!shadow)
-		return ERR_PTR(-ENOENT);
-
-	dput(nd->dentry);
-	nd->dentry = shadow;
-
-	return shadow->d_inode->i_op->lookup(shadow->d_inode, dentry, nd);
-}
-
-static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
-{
-	struct net *net = current->nsproxy->net_ns;
-	struct dentry *shadow;
-	int ret;
-
-	shadow = proc_net_shadow_dentry(dentry->d_parent, net->proc_net);
-	if (!shadow)
-		return -ENOENT;
-	ret = shadow->d_inode->i_op->setattr(shadow, iattr);
-	dput(shadow);
-	return ret;
-}
-
-static const struct file_operations proc_net_dir_operations = {
-	.read			= generic_read_dir,
-};
-
-static struct inode_operations proc_net_dir_inode_operations = {
-	.follow_link	= proc_net_follow_link,
-	.lookup		= proc_net_lookup,
-	.setattr	= proc_net_setattr,
-};
-
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *root, *netd, *net_statd;
@@ -185,9 +110,8 @@ static struct pernet_operations __net_initdata proc_net_ns_ops = {
 
 int __init proc_net_init(void)
 {
-	proc_net_shadow = proc_mkdir("net", NULL);
-	proc_net_shadow->proc_iops = &proc_net_dir_inode_operations;
-	proc_net_shadow->proc_fops = &proc_net_dir_operations;
+	shadow_pde = proc_mkdir("net", NULL);
+	shadow_pde->shadow_proc = proc_net_shadow;
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index b070b3b..a5d22c1 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -48,6 +48,8 @@ typedef	int (read_proc_t)(char *page, char **start, off_t off,
 typedef	int (write_proc_t)(struct file *file, const char __user *buffer,
 			   unsigned long count, void *data);
 typedef int (get_info_t)(char *, char **, off_t, int);
+typedef struct proc_dir_entry *(shadow_proc_t)(struct task_struct *task,
+						struct proc_dir_entry *pde);
 
 struct proc_dir_entry {
 	unsigned int low_ino;
@@ -79,6 +81,7 @@ struct proc_dir_entry {
 	int pde_users;	/* number of callers into module in progress */
 	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
 	struct completion *pde_unload_completion;
+	shadow_proc_t *shadow_proc;
 };
 
 struct kcore_list {
-- 
1.5.3.rc6.17.g1911
