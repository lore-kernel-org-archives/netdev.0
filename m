From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 01/41] CAPI: Fix leaks in capifs_new_ncci
Date: Mon,  8 Feb 2010 21:12:05 +0100
Message-ID: <81d94ed7f89889cd0df8f426c50a1caee93fc938.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When something went wrong during capifs_new_ncci, the looked up dentry
was not properly released. Neither was the allocated inode. Refactor the
function to avoid leaks.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capifs.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 9f8f67b..dc68fcb 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -152,22 +152,33 @@ static struct dentry *get_node(int num)
 void capifs_new_ncci(unsigned int number, dev_t device)
 {
 	struct dentry *dentry;
-	struct inode *inode = new_inode(capifs_mnt->mnt_sb);
-	if (!inode)
-		return;
-	inode->i_ino = number+2;
+	struct inode *inode;
 
 	dentry = get_node(number);
+	if (IS_ERR(dentry))
+		goto unlock_out;
+
+	if (dentry->d_inode) {
+		dput(dentry);
+		goto unlock_out;
+	}
+
+	inode = new_inode(capifs_mnt->mnt_sb);
+	if (!inode) {
+		dput(dentry);
+		goto unlock_out;
+	}
 
 	/* config contents is protected by root's i_mutex */
 	inode->i_uid = config.setuid ? config.uid : current_fsuid();
 	inode->i_gid = config.setgid ? config.gid : current_fsgid();
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_ino = number + 2;
 	init_special_inode(inode, S_IFCHR|config.mode, device);
-	//inode->i_op = &capifs_file_inode_operations;
 
-	if (!IS_ERR(dentry) && !dentry->d_inode)
-		d_instantiate(dentry, inode);
+	d_instantiate(dentry, inode);
+
+unlock_out:
 	mutex_unlock(&capifs_root->d_inode->i_mutex);
 }
 
-- 
1.6.0.2
