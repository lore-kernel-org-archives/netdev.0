From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 03/31] CAPI: Eliminate capifs_root variable
Date: Wed, 6 Jan 2010 14:49:00 +0100
Message-ID: <579c7b0a63eea4dc7005ab914c8972d7d16e7115.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755453Ab0AVXTa@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

capifs_mnt->mnt_sb->s_root already contains what we need.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capifs.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 91aafad..6ae0edf 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -32,7 +32,6 @@ static char *revision = "$Revision: 1.1.2.3 $";
 #define CAPIFS_SUPER_MAGIC (('C'<<8)|'N')
 
 static struct vfsmount *capifs_mnt;
-static struct dentry *capifs_root;
 
 static struct {
 	int setuid;
@@ -118,7 +117,7 @@ capifs_fill_super(struct super_block *s, void *data, int silent)
 	inode->i_fop = &simple_dir_operations;
 	inode->i_nlink = 2;
 
-	capifs_root = s->s_root = d_alloc_root(inode);
+	s->s_root = d_alloc_root(inode);
 	if (s->s_root)
 		return 0;
 	
@@ -143,15 +142,17 @@ static struct file_system_type capifs_fs_type = {
 
 struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
 {
+	struct super_block *s = capifs_mnt->mnt_sb;
+	struct dentry *root = s->s_root;
 	struct dentry *dentry;
 	struct inode *inode;
 	char name[10];
 	int namelen;
 
-	mutex_lock(&capifs_root->d_inode->i_mutex);
+	mutex_lock(&root->d_inode->i_mutex);
 
 	namelen = sprintf(name, "%d", number);
-	dentry = lookup_one_len(name, capifs_root, namelen);
+	dentry = lookup_one_len(name, root, namelen);
 	if (IS_ERR(dentry)) {
 		dentry = NULL;
 		goto unlock_out;
@@ -163,7 +164,7 @@ struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
 		goto unlock_out;
 	}
 
-	inode = new_inode(capifs_mnt->mnt_sb);
+	inode = new_inode(s);
 	if (!inode) {
 		dput(dentry);
 		dentry = NULL;
@@ -181,19 +182,20 @@ struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
 	dget(dentry);
 
 unlock_out:
-	mutex_unlock(&capifs_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 
 	return dentry;
 }
 
 void capifs_free_ncci(struct dentry *dentry)
 {
+	struct dentry *root = capifs_mnt->mnt_sb->s_root;
 	struct inode *inode;
 
 	if (!dentry)
 		return;
 
-	mutex_lock(&capifs_root->d_inode->i_mutex);
+	mutex_lock(&root->d_inode->i_mutex);
 
 	inode = dentry->d_inode;
 	if (inode) {
@@ -203,7 +205,7 @@ void capifs_free_ncci(struct dentry *dentry)
 	}
 	dput(dentry);
 
-	mutex_unlock(&capifs_root->d_inode->i_mutex);
+	mutex_unlock(&root->d_inode->i_mutex);
 }
 
 static int __init capifs_init(void)
-- 
1.6.0.2
