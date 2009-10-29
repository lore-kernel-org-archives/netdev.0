From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Thu, 29 Oct 2009 19:38:48 -0400
Message-ID: <20091029233848.GV3141@kvack.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45937 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756045AbZJ2Xio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 19:38:44 -0400
Content-Disposition: inline
In-Reply-To: <m1d445yf2x.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 04:07:18PM -0700, Eric W. Biederman wrote:
> Could you keep me in the loop with that.  I have some pending cleanups for
> all of those pieces of code and may be able to help/advice/review.

Here are the sysfs scaling improvements.  I have to break them up, as there 
are 3 separate changes in this patch: 1. use an rbtree for name lookup in 
sysfs, 2. keep track of the number of directories for the purpose of 
generating the link count, as otherwise too much cpu time is spent in 
sysfs_count_nlink when new entries are added, and 3. when adding a new 
sysfs_dirent, walk the list backwards when linking it in, as higher 
numbered inodes tend to be at the end of the list, not the beginning.

		-ben


diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 5fad489..38ad7c8 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -43,10 +43,18 @@ static DEFINE_IDA(sysfs_ino_ida);
 static void sysfs_link_sibling(struct sysfs_dirent *sd)
 {
 	struct sysfs_dirent *parent_sd = sd->s_parent;
-	struct sysfs_dirent **pos;
+	struct sysfs_dirent **pos, *prev = NULL;
+	struct rb_node **new, *parent;
 
 	BUG_ON(sd->s_sibling);
 
+	if (parent_sd->s_dir.children_tail &&
+	    parent_sd->s_dir.children_tail->s_ino < sd->s_ino) {
+		prev = parent_sd->s_dir.children_tail;
+		pos = &prev->s_sibling;
+		goto got_it;
+	}
+
 	/* Store directory entries in order by ino.  This allows
 	 * readdir to properly restart without having to add a
 	 * cursor into the s_dir.children list.
@@ -54,9 +62,36 @@ static void sysfs_link_sibling(struct sysfs_dirent *sd)
 	for (pos = &parent_sd->s_dir.children; *pos; pos = &(*pos)->s_sibling) {
 		if (sd->s_ino < (*pos)->s_ino)
 			break;
+		prev = *pos;
 	}
+got_it:
+	if (prev == parent_sd->s_dir.children_tail)
+		parent_sd->s_dir.children_tail = sd;
 	sd->s_sibling = *pos;
+	sd->s_sibling_prev = prev;
 	*pos = sd;
+	parent_sd->s_nr_children_dir += (sysfs_type(sd) == SYSFS_DIR);
+
+	// rb tree insert
+	new = &(parent_sd->s_dir.child_rb_root.rb_node);
+	parent = NULL;
+
+	while (*new) {
+		struct sysfs_dirent *this =
+			container_of(*new, struct sysfs_dirent, s_rb_node);
+		int result = strcmp(sd->s_name, this->s_name);
+
+		parent = *new;
+		if (result < 0)
+			new = &((*new)->rb_left);
+		else if (result > 0)
+			new = &((*new)->rb_right);
+		else
+			BUG();
+	}
+
+	rb_link_node(&sd->s_rb_node, parent, new);
+	rb_insert_color(&sd->s_rb_node, &parent_sd->s_dir.child_rb_root);
 }
 
 /**
@@ -71,16 +106,22 @@ static void sysfs_link_sibling(struct sysfs_dirent *sd)
  */
 static void sysfs_unlink_sibling(struct sysfs_dirent *sd)
 {
-	struct sysfs_dirent **pos;
+	struct sysfs_dirent **pos, *prev = NULL;
 
-	for (pos = &sd->s_parent->s_dir.children; *pos;
-	     pos = &(*pos)->s_sibling) {
-		if (*pos == sd) {
-			*pos = sd->s_sibling;
-			sd->s_sibling = NULL;
-			break;
-		}
-	}
+	prev = sd->s_sibling_prev;
+	if (prev)
+		pos = &prev->s_sibling;
+	else
+		pos = &sd->s_parent->s_dir.children;
+	if (sd == sd->s_parent->s_dir.children_tail)
+		sd->s_parent->s_dir.children_tail = prev;
+	*pos = sd->s_sibling;
+	if (sd->s_sibling)
+		sd->s_sibling->s_sibling_prev = prev;
+	
+	sd->s_parent->s_nr_children_dir -= (sysfs_type(sd) == SYSFS_DIR);
+	sd->s_sibling_prev = NULL;
+	rb_erase(&sd->s_rb_node, &sd->s_parent->s_dir.child_rb_root);
 }
 
 /**
@@ -331,6 +372,9 @@ struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type)
 	sd->s_mode = mode;
 	sd->s_flags = type;
 
+	if (type == SYSFS_DIR)
+		sd->s_dir.child_rb_root = RB_ROOT;
+
 	return sd;
 
  err_out2:
@@ -630,11 +674,20 @@ void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt)
 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 				       const unsigned char *name)
 {
-	struct sysfs_dirent *sd;
-
-	for (sd = parent_sd->s_dir.children; sd; sd = sd->s_sibling)
-		if (!strcmp(sd->s_name, name))
-			return sd;
+	struct rb_node *node = parent_sd->s_dir.child_rb_root.rb_node;
+
+	while (node) {
+		struct sysfs_dirent *data =
+			container_of(node, struct sysfs_dirent, s_rb_node);
+		int result;
+		result = strcmp(name, data->s_name);
+		if (result < 0)
+			node = node->rb_left;
+		else if (result > 0)
+			node = node->rb_right;
+		else
+			return data;
+	}
 	return NULL;
 }
 
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index e28cecf..ff6e960 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -191,14 +191,7 @@ static struct lock_class_key sysfs_inode_imutex_key;
 
 static int sysfs_count_nlink(struct sysfs_dirent *sd)
 {
-	struct sysfs_dirent *child;
-	int nr = 0;
-
-	for (child = sd->s_dir.children; child; child = child->s_sibling)
-		if (sysfs_type(child) == SYSFS_DIR)
-			nr++;
-
-	return nr + 2;
+	return sd->s_nr_children_dir + 2;
 }
 
 static void sysfs_init_inode(struct sysfs_dirent *sd, struct inode *inode)
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index af4c4e7..22fd1bc 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -9,6 +9,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/rbtree.h>
 
 struct sysfs_open_dirent;
 
@@ -16,7 +17,10 @@ struct sysfs_open_dirent;
 struct sysfs_elem_dir {
 	struct kobject		*kobj;
 	/* children list starts here and goes through sd->s_sibling */
+	
 	struct sysfs_dirent	*children;
+	struct sysfs_dirent	*children_tail;
+	struct rb_root		child_rb_root;
 };
 
 struct sysfs_elem_symlink {
@@ -52,6 +56,8 @@ struct sysfs_dirent {
 	atomic_t		s_active;
 	struct sysfs_dirent	*s_parent;
 	struct sysfs_dirent	*s_sibling;
+	struct sysfs_dirent	*s_sibling_prev;
+	struct rb_node		s_rb_node;
 	const char		*s_name;
 
 	union {
@@ -65,6 +71,8 @@ struct sysfs_dirent {
 	ino_t			s_ino;
 	umode_t			s_mode;
 	struct sysfs_inode_attrs *s_iattr;
+
+	int			s_nr_children_dir;
 };
 
 #define SD_DEACTIVATED_BIAS		INT_MIN
