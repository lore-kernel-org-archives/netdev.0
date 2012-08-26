From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 10/15] userns: Convert debugfs to use kuid/kgid where appropriate.
Date: Sat, 25 Aug 2012 17:03:41 -0700
Message-ID: <871uiufrj6.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34832 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab2HZADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 20:03:53 -0400
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/debugfs/inode.c |   26 ++++++++++++++++++--------
 init/Kconfig       |    1 -
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index 4733eab..36e2b66 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -128,8 +128,8 @@ static inline int debugfs_positive(struct dentry *dentry)
 }
 
 struct debugfs_mount_opts {
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	umode_t mode;
 };
 
@@ -156,6 +156,8 @@ static int debugfs_parse_options(char *data, struct debugfs_mount_opts *opts)
 	substring_t args[MAX_OPT_ARGS];
 	int option;
 	int token;
+	kuid_t uid;
+	kgid_t gid;
 	char *p;
 
 	opts->mode = DEBUGFS_DEFAULT_MODE;
@@ -169,12 +171,18 @@ static int debugfs_parse_options(char *data, struct debugfs_mount_opts *opts)
 		case Opt_uid:
 			if (match_int(&args[0], &option))
 				return -EINVAL;
-			opts->uid = option;
+			uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(uid))
+				return -EINVAL;
+			opts->uid = uid;
 			break;
 		case Opt_gid:
 			if (match_octal(&args[0], &option))
 				return -EINVAL;
-			opts->gid = option;
+			gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(gid))
+				return -EINVAL;
+			opts->gid = gid;
 			break;
 		case Opt_mode:
 			if (match_octal(&args[0], &option))
@@ -226,10 +234,12 @@ static int debugfs_show_options(struct seq_file *m, struct dentry *root)
 	struct debugfs_fs_info *fsi = root->d_sb->s_fs_info;
 	struct debugfs_mount_opts *opts = &fsi->mount_opts;
 
-	if (opts->uid != 0)
-		seq_printf(m, ",uid=%u", opts->uid);
-	if (opts->gid != 0)
-		seq_printf(m, ",gid=%u", opts->gid);
+	if (!uid_eq(opts->uid, GLOBAL_ROOT_UID))
+		seq_printf(m, ",uid=%u",
+			   from_kuid_munged(&init_user_ns, opts->uid));
+	if (!gid_eq(opts->gid, GLOBAL_ROOT_GID))
+		seq_printf(m, ",gid=%u",
+			   from_kgid_munged(&init_user_ns, opts->gid));
 	if (opts->mode != DEBUGFS_DEFAULT_MODE)
 		seq_printf(m, ",mode=%o", opts->mode);
 
diff --git a/init/Kconfig b/init/Kconfig
index 7327869..af41fa7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -955,7 +955,6 @@ config UIDGID_CONVERTED
 	depends on CODA_FS = n
 	depends on CONFIGFS_FS = n
 	depends on CRAMFS = n
-	depends on DEBUG_FS = n
 	depends on ECRYPT_FS = n
 	depends on EFS_FS = n
 	depends on EXOFS_FS = n
-- 
1.7.5.4
