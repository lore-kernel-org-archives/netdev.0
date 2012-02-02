From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/4] sysctl: Comments to make the code clearer.
Date: Wed, 01 Feb 2012 19:29:39 -0800
Message-ID: <m1pqdxvroc.fsf_-_@fess.ebiederm.org>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
	<m139atx6bs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m139atx6bs.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 01 Feb 2012 19:27:51 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Document get_subdir and that find_subdir alwasy takes a reference.

Suggested-by:  Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 722ec11..e5601dc 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -73,6 +73,7 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
 	return cmp;
 }
 
+/* Called under sysctl_lock */
 static struct ctl_table *find_entry(struct ctl_table_header **phead,
 	struct ctl_dir *dir, const char *name, int namelen)
 {
@@ -864,6 +865,18 @@ static struct ctl_dir *new_dir(struct ctl_table_set *set,
 	return new;
 }
 
+/**
+ * get_subdir - find or create a subdir with the specified name.
+ * @dir:  Directory to create the subdirectory in
+ * @name: The name of the subdirectory to find or create
+ * @namelen: The length of name
+ *
+ * Takes a directory with an elevated reference count so we know that
+ * if we drop the lock the directory will not go away.  Upon success
+ * the reference is moved from @dir to the returned subdirectory.
+ * Upon error an error code is returned and the reference on @dir is
+ * simply dropped.
+ */
 static struct ctl_dir *get_subdir(struct ctl_dir *dir,
 				  const char *name, int namelen)
 {
@@ -885,12 +898,14 @@ static struct ctl_dir *get_subdir(struct ctl_dir *dir,
 	if (!new)
 		goto failed;
 
+	/* Was the subdir added while we dropped the lock? */
 	subdir = find_subdir(dir, name, namelen);
 	if (!IS_ERR(subdir))
 		goto found;
 	if (PTR_ERR(subdir) != -ENOENT)
 		goto failed;
 
+	/* Nope.  Use the our freshly made directory entry. */
 	err = insert_header(dir, &new->header);
 	subdir = ERR_PTR(err);
 	if (err)
@@ -1190,6 +1205,7 @@ struct ctl_table_header *__register_sysctl_table(
 
 	spin_lock(&sysctl_lock);
 	dir = &set->dir;
+	/* Reference moved down the diretory tree get_subdir */
 	dir->header.nreg++;
 	spin_unlock(&sysctl_lock);
 
-- 
1.7.2.5
