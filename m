From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Sun, 1 Nov 2009 11:31:30 -0500
Message-ID: <20091101163130.GA7911@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:55756 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826AbZKAQb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2009 11:31:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use an rbtree in sysfs_dirent to speed up file lookup times

Systems with large numbers (tens of thousands and more) of network 
interfaces stress the sysfs code in ways that make the linear search for 
a name match take far too long.  Avoid this by using an rbtree.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 5fad489..30c3fc5 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -44,6 +44,7 @@ static void sysfs_link_sibling(struct sysfs_dirent *sd)
 {
 	struct sysfs_dirent *parent_sd = sd->s_parent;
 	struct sysfs_dirent **pos;
+	struct rb_node **new, *parent;
 
 	BUG_ON(sd->s_sibling);
 
@@ -57,6 +58,27 @@ static void sysfs_link_sibling(struct sysfs_dirent *sd)
 	}
 	sd->s_sibling = *pos;
 	*pos = sd;
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
@@ -81,6 +103,8 @@ static void sysfs_unlink_sibling(struct sysfs_dirent *sd)
 			break;
 		}
 	}
+
+	rb_erase(&sd->s_rb_node, &sd->s_parent->s_dir.child_rb_root);
 }
 
 /**
@@ -331,6 +355,9 @@ struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type)
 	sd->s_mode = mode;
 	sd->s_flags = type;
 
+	if (type == SYSFS_DIR)
+		sd->s_dir.child_rb_root = RB_ROOT;
+
 	return sd;
 
  err_out2:
@@ -630,11 +657,20 @@ void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt)
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
 
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index af4c4e7..600109c 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -9,6 +9,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/rbtree.h>
 
 struct sysfs_open_dirent;
 
@@ -17,6 +18,7 @@ struct sysfs_elem_dir {
 	struct kobject		*kobj;
 	/* children list starts here and goes through sd->s_sibling */
 	struct sysfs_dirent	*children;
+	struct rb_root		child_rb_root;
 };
 
 struct sysfs_elem_symlink {
@@ -52,6 +54,7 @@ struct sysfs_dirent {
 	atomic_t		s_active;
 	struct sysfs_dirent	*s_parent;
 	struct sysfs_dirent	*s_sibling;
+	struct rb_node		s_rb_node;
 	const char		*s_name;
 
 	union {
