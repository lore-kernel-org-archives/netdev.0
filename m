From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/5] sysfs: Reject with a warning invalid uses of tagged directories.
Date: Thu, 13 Oct 2011 01:02:43 -0700
Message-ID: <m1aa959v4s.fsf_-_@fess.ebiederm.org>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
	<m1wrc99vjx.fsf@fess.ebiederm.org>
	<m1sjmx9vhf.fsf_-_@fess.ebiederm.org>
	<m1mxd59vfa.fsf_-_@fess.ebiederm.org>
	<m1ehyh9v6p.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Tejun Heo <htejun@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Greg Kroah-Hartman <gregkh@suse.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ehyh9v6p.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 13 Oct 2011 01:01:34 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


sysfs is a core piece of ifrastructure that many people use and
few people have all of the rules in their head on how to use
it correctly.  Add warnings for people using tagged directories
improperly to that any misuses can be caught and diagnosed quickly.

A single inexpensive test in sysfs_find_dirent is almost sufficient
to catch all possible misuses.  An additional warning is needed
in sysfs_add_dirent so that we actually fail when attempting to
add an untagged dirent in a tagged directory.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c  |   14 ++++++++++++++
 fs/sysfs/file.c |    3 ---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 352d26d..26f370a 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -384,6 +384,13 @@ int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
 {
 	struct sysfs_inode_attrs *ps_iattr;
 
+	if (!!sysfs_ns_type(acxt->parent_sd) != !!sd->s_ns) {
+		WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
+			sysfs_ns_type(acxt->parent_sd)? "required": "invalid",
+			acxt->parent_sd->s_name, sd->s_name);
+		return -EINVAL;
+	}
+
 	if (sysfs_find_dirent(acxt->parent_sd, sd->s_ns, sd->s_name))
 		return -EEXIST;
 
@@ -542,6 +549,13 @@ struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 {
 	struct sysfs_dirent *sd;
 
+	if (!!sysfs_ns_type(parent_sd) != !!ns) {
+		WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
+			sysfs_ns_type(parent_sd)? "required": "invalid",
+			parent_sd->s_name, name);
+		return NULL;
+	}
+
 	for (sd = parent_sd->s_dir.children; sd; sd = sd->s_sibling) {
 		if (sd->s_ns != ns)
 			continue;
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 07c1b4e..d4e6080 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -466,9 +466,6 @@ void sysfs_notify(struct kobject *k, const char *dir, const char *attr)
 	mutex_lock(&sysfs_mutex);
 
 	if (sd && dir)
-		/* Only directories are tagged, so no need to pass
-		 * a tag explicitly.
-		 */
 		sd = sysfs_find_dirent(sd, NULL, dir);
 	if (sd && attr)
 		sd = sysfs_find_dirent(sd, NULL, attr);
-- 
1.7.2.5
