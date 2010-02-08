From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 04/41] CAPI: Pin capifs instead of mounting it
Date: Mon,  8 Feb 2010 21:12:08 +0100
Message-ID: <225c4c6dbff38f6f8fa780ca91dcffd81b139bb0.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:53527 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293Ab0BHUNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:00 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auto-mounting the capifs during module init prevents unloading its
module. Instead, pin the filesystem as long as some NCCI node exists.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capifs.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 6ae0edf..51c01ef 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -32,6 +32,7 @@ static char *revision = "$Revision: 1.1.2.3 $";
 #define CAPIFS_SUPER_MAGIC (('C'<<8)|'N')
 
 static struct vfsmount *capifs_mnt;
+static int capifs_mnt_count;
 
 static struct {
 	int setuid;
@@ -140,7 +141,7 @@ static struct file_system_type capifs_fs_type = {
 	.kill_sb	= kill_anon_super,
 };
 
-struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
+static struct dentry *new_ncci(unsigned int number, dev_t device)
 {
 	struct super_block *s = capifs_mnt->mnt_sb;
 	struct dentry *root = s->s_root;
@@ -187,6 +188,20 @@ unlock_out:
 	return dentry;
 }
 
+struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
+{
+	struct dentry *dentry;
+
+	if (simple_pin_fs(&capifs_fs_type, &capifs_mnt, &capifs_mnt_count) < 0)
+		return NULL;
+
+	dentry = new_ncci(number, device);
+	if (!dentry)
+		simple_release_fs(&capifs_mnt, &capifs_mnt_count);
+
+	return dentry;
+}
+
 void capifs_free_ncci(struct dentry *dentry)
 {
 	struct dentry *root = capifs_mnt->mnt_sb->s_root;
@@ -206,6 +221,8 @@ void capifs_free_ncci(struct dentry *dentry)
 	dput(dentry);
 
 	mutex_unlock(&root->d_inode->i_mutex);
+
+	simple_release_fs(&capifs_mnt, &capifs_mnt_count);
 }
 
 static int __init capifs_init(void)
@@ -222,13 +239,6 @@ static int __init capifs_init(void)
 		strcpy(rev, "1.0");
 
 	err = register_filesystem(&capifs_fs_type);
-	if (!err) {
-		capifs_mnt = kern_mount(&capifs_fs_type);
-		if (IS_ERR(capifs_mnt)) {
-			err = PTR_ERR(capifs_mnt);
-			unregister_filesystem(&capifs_fs_type);
-		}
-	}
 	if (!err)
 		printk(KERN_NOTICE "capifs: Rev %s\n", rev);
 	return err;
@@ -237,7 +247,6 @@ static int __init capifs_init(void)
 static void __exit capifs_exit(void)
 {
 	unregister_filesystem(&capifs_fs_type);
-	mntput(capifs_mnt);
 }
 
 EXPORT_SYMBOL(capifs_new_ncci);
-- 
1.6.0.2

