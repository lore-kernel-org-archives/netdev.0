From: James Morris <jmorris@namei.org>
Subject: [PATCH 2/3][RFC] security: pass mount flags to
 security_sb_kern_mount()
Date: Fri, 19 Dec 2008 12:06:32 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812191205530.4137@tundra.namei.org>
References: <49381644.8020502@intel.com>  <20081204175236.GA19808@x200.localdomain>  <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>  <20081204.102138.123959105.davem@davemloft.net>  <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
 <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>  <m1bpvrslk0.fsf@frodo.ebiederm.org>  <1228486339.20274.3.camel@localhost.localdomain>  <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>  <20081212052420.GA14948@x200.localdomain>
 <alpine.LRH.1.10.0812122022520.32426@tundra.namei.org> <1229117086.3134.22.camel@localhost.localdomain> <alpine.LRH.1.10.0812160021030.10723@tundra.namei.org> <alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Eric Paris <eparis@parisplace.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Al Viro <viro@ftp.linux.org.uk>,
	Chris Wright <chrisw@sous-sol.org>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:4783 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752229AbYLSBHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 20:07:03 -0500
In-Reply-To: <alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pass mount flags to security_sb_kern_mount(), so security modules
can determine if a mount operation is being performed by the kernel.

Signed-off-by: James Morris <jmorris@namei.org>
---
 fs/super.c                 |    2 +-
 include/linux/security.h   |    6 +++---
 security/capability.c      |    2 +-
 security/security.c        |    4 ++--
 security/selinux/hooks.c   |    2 +-
 security/smack/smack_lsm.c |    3 ++-
 6 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 400a760..ddba069 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -914,7 +914,7 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 		goto out_free_secdata;
 	BUG_ON(!mnt->mnt_sb);
 
- 	error = security_sb_kern_mount(mnt->mnt_sb, secdata);
+ 	error = security_sb_kern_mount(mnt->mnt_sb, flags, secdata);
  	if (error)
  		goto out_sb;
 
diff --git a/include/linux/security.h b/include/linux/security.h
index c13f1ce..dff563b 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1327,7 +1327,7 @@ struct security_operations {
 	int (*sb_alloc_security) (struct super_block *sb);
 	void (*sb_free_security) (struct super_block *sb);
 	int (*sb_copy_data) (char *orig, char *copy);
-	int (*sb_kern_mount) (struct super_block *sb, void *data);
+	int (*sb_kern_mount) (struct super_block *sb, int flags, void *data);
 	int (*sb_show_options) (struct seq_file *m, struct super_block *sb);
 	int (*sb_statfs) (struct dentry *dentry);
 	int (*sb_mount) (char *dev_name, struct path *path,
@@ -1596,7 +1596,7 @@ int security_bprm_secureexec(struct linux_binprm *bprm);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
-int security_sb_kern_mount(struct super_block *sb, void *data);
+int security_sb_kern_mount(struct super_block *sb, int flags, void *data);
 int security_sb_show_options(struct seq_file *m, struct super_block *sb);
 int security_sb_statfs(struct dentry *dentry);
 int security_sb_mount(char *dev_name, struct path *path,
@@ -1877,7 +1877,7 @@ static inline int security_sb_copy_data(char *orig, char *copy)
 	return 0;
 }
 
-static inline int security_sb_kern_mount(struct super_block *sb, void *data)
+static inline int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
 {
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index 2458748..0f6612d 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -64,7 +64,7 @@ static int cap_sb_copy_data(char *orig, char *copy)
 	return 0;
 }
 
-static int cap_sb_kern_mount(struct super_block *sb, void *data)
+static int cap_sb_kern_mount(struct super_block *sb, int flags, void *data)
 {
 	return 0;
 }
diff --git a/security/security.c b/security/security.c
index c0acfa7..5a37d79 100644
--- a/security/security.c
+++ b/security/security.c
@@ -266,9 +266,9 @@ int security_sb_copy_data(char *orig, char *copy)
 }
 EXPORT_SYMBOL(security_sb_copy_data);
 
-int security_sb_kern_mount(struct super_block *sb, void *data)
+int security_sb_kern_mount(struct super_block *sb, int flags, void *data)
 {
-	return security_ops->sb_kern_mount(sb, data);
+	return security_ops->sb_kern_mount(sb, flags, data);
 }
 
 int security_sb_show_options(struct seq_file *m, struct super_block *sb)
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 470763a..3897758 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2452,7 +2452,7 @@ out:
 	return rc;
 }
 
-static int selinux_sb_kern_mount(struct super_block *sb, void *data)
+static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
 {
 	struct avc_audit_data ad;
 	int rc;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 6e2dc0b..f23e927 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -248,11 +248,12 @@ static int smack_sb_copy_data(char *orig, char *smackopts)
 /**
  * smack_sb_kern_mount - Smack specific mount processing
  * @sb: the file system superblock
+ * @flags: the mount flags
  * @data: the smack mount options
  *
  * Returns 0 on success, an error code on failure
  */
-static int smack_sb_kern_mount(struct super_block *sb, void *data)
+static int smack_sb_kern_mount(struct super_block *sb, int flags, void *data)
 {
 	struct dentry *root = sb->s_root;
 	struct inode *inode = root->d_inode;
-- 
1.6.0.4

