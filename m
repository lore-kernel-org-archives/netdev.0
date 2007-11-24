From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [CFT][PATCH] proc_net: Remove userspace visible changes.
Date: Sat, 24 Nov 2007 16:34:00 -0700
Message-ID: <m1prxznrpz.fsf_-_@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40495 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbXKXXfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 18:35:25 -0500
In-Reply-To: <4743026B.2020907@openvz.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 18:51:07 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok.  I have kicked around a lot implementation ideas and took a good hard
look at my /proc/net implementation.  The patch below should close all
of the holes with /proc/net that I am aware of.

Bind mounts work and properly capture /proc/net/
stat of /proc/net and /proc/net/ return the same information.
cd /proc/net/ ; ls .. works
The dentry has the proper parent and no longer appears deleted.

As well as few more theoretical cases I have been able to imagine,
like open("/proc/net", O_NOFOLLOW | O_DIRECTORY) getdents...

Please take a look and kick this patch around.  I don't expect anyone
to find any issues but a few more eyeballs before I send this
along to Linus would be appreciated.  Thanks.


From: Eric W. Biederman <ebiederm@xmission.com>
Subject: [PATCH] proc_net: Remove userspace visible changes.

This patch fixes some bugs in corner cases of the /proc/net
implementation.

In proc_net_shadow_dentry.
- Set the parent dentry properly.
- Make the dentry appear hashed so .. works.

Remove the unreachable proc_net_lookup.

Implement proc_net_getattr to complete the
set of implemented inode operations.

Implement proc_net_open which changes the directory we
are openting to remove the need to implement any other
file operations.

Add a big fat comment on how /proc/net works to make it
easier for someone else to look at and understand this code.

This patch should remove the last of the accidental user visible artifacts
that arose from adding network namespace support to /proc/net.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_net.c |  116 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 93 insertions(+), 23 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 131f9c6..b0b4b3f 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -50,24 +50,69 @@ struct net *get_proc_net(const struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(get_proc_net);
 
+/*
+ * The contents of the files under /proc/net depend on which network
+ * namespace you are in.  
+ *
+ * This implementation relies on the following properties.
+ *
+ * - Each network namespaces has it's own /proc/net dcache tree.
+ * - A directory with a follow_link method never calls lookup
+ * - It is possible in ->open to competely change which underlying
+ *   filesystem, path, and inode the struct file refers to.
+ * - A dcache entry with DCACHE_UNHASHED clear and pprev set
+ *   appares hashed (and thus valid) to the dcache.
+ *
+ * To give each network namespace it's own /proc/net directory
+ * in a manner transparent to user space (and not requiring /proc)
+ * be remounted we do the following things:
+ *
+ *   Keep a different dentry tree for each network namespace under
+ *   /proc/net.
+ *
+ *   Have the root of the /proc/net dentry tree be a ``unhashed''
+ *   dentry with it's root pointing at the /proc dentry.  Making
+ *   it appear in parallel with the normal /proc/net.
+ *
+ *   Redirect all opens of the normal /proc/net to the one appropriate
+ *   for the opening process in ->open.
+ *
+ *   Redirect all directory traversals onto the appropriate /proc/net
+ *   with a follow_link method.
+ *
+ *   Wrap all other applicable inode operations so they appear to
+ *   happen not on the normal /proc/net but on the network namespace
+ *   specific one.
+ *
+ * Currently we can use a bind mount inside a network namespace
+ * to /proc/net visible to processes outside that network namespace.
+ * Long term /proc/net should migrate to /proc/<pid>/net removing
+ * the need for the bind mount for monitoring processes.
+ */
+
 static struct proc_dir_entry *proc_net_shadow;
 
-static struct dentry *proc_net_shadow_dentry(struct dentry *parent,
-						struct proc_dir_entry *de)
+static struct dentry *proc_net_shadow_dentry(struct net *net,
+					     struct dentry *dentry)
 {
+	struct proc_dir_entry *de = net->proc_net;
 	struct dentry *shadow = NULL;
 	struct inode *inode;
 	if (!de)
 		goto out;
 	de_get(de);
-	inode = proc_get_inode(parent->d_inode->i_sb, de->low_ino, de);
+	inode = proc_get_inode(dentry->d_sb, de->low_ino, de);
 	if (!inode)
 		goto out_de_put;
-	shadow = d_alloc_name(parent, de->name);
+	shadow = d_alloc(dentry->d_parent, &dentry->d_name);
 	if (!shadow)
 		goto out_iput;
-	shadow->d_op = parent->d_op; /* proc_dentry_operations */
+	shadow->d_op = dentry->d_op; /* proc_dentry_operations */
 	d_instantiate(shadow, inode);
+
+	/* Make the dentry looked hashed */
+	shadow->d_hash.pprev = &shadow->d_hash.next;
+	shadow->d_flags &= ~DCACHE_UNHASHED;
 out:
 	return shadow;
 out_iput:
@@ -77,36 +122,36 @@ out_de_put:
 	goto out;
 }
 
-static void *proc_net_follow_link(struct dentry *parent, struct nameidata *nd)
+static void *proc_net_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct net *net = current->nsproxy->net_ns;
 	struct dentry *shadow;
-	shadow = proc_net_shadow_dentry(parent, net->proc_net);
+
+	shadow = proc_net_shadow_dentry(net, dentry);
 	if (!shadow)
-		return ERR_PTR(-ENOENT);
+		goto out_err;
 
 	dput(nd->dentry);
-	/* My dentry count is 1 and that should be enough as the
-	 * shadow dentry is thrown away immediately.
-	 */
 	nd->dentry = shadow;
+
 	return NULL;
+out_err:
+	return ERR_PTR(-ENOENT);
 }
 
-static struct dentry *proc_net_lookup(struct inode *dir, struct dentry *dentry,
-				      struct nameidata *nd)
+static int proc_net_getattr(struct vfsmount *mnt, struct dentry *dentry,
+			    struct kstat *stat)
 {
 	struct net *net = current->nsproxy->net_ns;
 	struct dentry *shadow;
+	int ret;
 
-	shadow = proc_net_shadow_dentry(nd->dentry, net->proc_net);
+	shadow = proc_net_shadow_dentry(net, dentry);
 	if (!shadow)
-		return ERR_PTR(-ENOENT);
-
-	dput(nd->dentry);
-	nd->dentry = shadow;
-
-	return shadow->d_inode->i_op->lookup(shadow->d_inode, dentry, nd);
+		return -ENOENT;
+	ret = shadow->d_inode->i_op->getattr(mnt, shadow, stat);
+	dput(shadow);
+	return ret;
 }
 
 static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
@@ -115,7 +160,7 @@ static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
 	struct dentry *shadow;
 	int ret;
 
-	shadow = proc_net_shadow_dentry(dentry->d_parent, net->proc_net);
+	shadow = proc_net_shadow_dentry(net, dentry);
 	if (!shadow)
 		return -ENOENT;
 	ret = shadow->d_inode->i_op->setattr(shadow, iattr);
@@ -123,13 +168,38 @@ static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
 	return ret;
 }
 
+static int proc_net_open(struct inode *inode, struct file *filp)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct dentry *shadow;
+	int ret;
+
+	shadow = proc_net_shadow_dentry(net, filp->f_dentry);
+	if (!shadow)
+		return -ENOENT;
+
+	inode = shadow->d_inode;
+
+	fops_put(filp->f_op);
+	dput(filp->f_dentry);
+
+	filp->f_mapping = inode->i_mapping;
+	filp->f_op = fops_get(inode->i_fop);
+	filp->f_dentry = shadow;
+
+	ret = 0;
+	if (filp->f_op && filp->f_op->open)
+		ret = filp->f_op->open(inode, filp);
+	return ret;
+}
+
 static const struct file_operations proc_net_dir_operations = {
-	.read			= generic_read_dir,
+	.open			= proc_net_open,
 };
 
 static struct inode_operations proc_net_dir_inode_operations = {
 	.follow_link	= proc_net_follow_link,
-	.lookup		= proc_net_lookup,
+	.getattr	= proc_net_getattr,
 	.setattr	= proc_net_setattr,
 };
 
-- 
1.5.3.rc6.17.g1911

